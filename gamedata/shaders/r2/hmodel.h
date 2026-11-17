#include "common.h"

uniform samplerCUBE	env_s0;
uniform samplerCUBE	env_s1;
uniform samplerCUBE	sky_s0;		// full-res sky cubemap (bound in the combine pass)
uniform samplerCUBE	sky_s1;
uniform float4		env_color;	// .xyz = sky tint, .w = blend factor
uniform float3x4	m_v2w;		// view -> world

// Sky cube has no mipmaps: fade the sharp reflection into the blurred env cube when
// the per-pixel footprint gets too big (bump normal noise, distant/curved surfaces) —
// otherwise it sparkles. fp = reflection-direction derivative, radians per pixel;
// 150 ≈ 0.4° per pixel threshold.
#define SKY_FP_INV	150.f

// Hemisphere / environment lighting:
//   diffuse  — env cubemap sampled by normal, attenuated by the hemi factor h;
//   specular — two-level reflection LOD: blurred env (32px) <-> full sky cubemap.
//              Blend weight = gloss (polish = NDF width), same idea as picking a
//              prefiltered cubemap mip level in CoD (linear in gloss).
//              The spec texture (amplitude) is applied once in combine_1 (spec_eff).
//              Reflections are attenuated by the same hemi factor as diffuse:
//              vanilla did this through the s_material LUT (ls *= ld^(1/32) with
//              ld = hemi), which for the blinn slice gives an effective ~h^0.75 gate.
void hmodel(out float3 hdiffuse, out float3 hspecular, float gloss, float h, float3 point, float3 normal)
{
        float3	nw		= mul(m_v2w, normal);
        float	hscale	= h;	// hemi: lightmap brightness / vertex hemi occlusion
#ifdef         USE_GAMMA_22
			hscale = (hscale*hscale);
#endif

        // view ray and reflection vector (eye -> world)
        float3	v2point		= mul(m_v2w, normalize(point));
        float3	vreflect	= reflect(-v2point, nw);	// = -R, OLR convention (see env path)
        float3	vreflect_raw	= vreflect;			// true R for the sky cube (before the fake remap)

        // --- diffuse: env cubemap by normal
        float3	diffuse_tc	= float3(-nw.x, nw.y, nw.z);
        float3	env_d		= env_color.xyz * lerp(texCUBE(env_s0, diffuse_tc),
                                                      texCUBE(env_s1, diffuse_tc), env_color.w);
        hdiffuse = env_d * hscale + L_ambient.rgb;

        // --- specular: env cubemap — OLR-tuned path (max-normalise + Y fake-HDR remap)
        float3	vr = vreflect;
        vr /= max(abs(vr.x), max(abs(vr.y), abs(vr.z)));
        if (vr.y < 0.99)
            vr.y = vr.y * 2 - 1;
        float3	env_tc	= float3(-vr.x, vr.y, vr.z);
        float3	env_s	= env_color.xyz * lerp(texCUBE(env_s0, env_tc),
                                              texCUBE(env_s1, env_tc), env_color.w);

        // --- specular: sky cubemap (full-res). Convention matches sky2.ps:
        //     sample with (-R.x, R.y, R.z); in terms of vreflect (=-R): (vr.x, -vr.y, -vr.z).
        //     TODO: skybox rotation (rotY(sky_rotation)·rotY(90°)) is not applied yet.
        float3	sky_tc	= float3(vreflect_raw.x, -vreflect_raw.y, -vreflect_raw.z);
        float3	sky_s	= lerp(texCUBE(sky_s0, sky_tc), texCUBE(sky_s1, sky_tc), env_color.w);
        sky_s		= min(sky_s, 1.h);	// no mips: clamp fireflies

        // mip-less sky cube: fade back to the blurred env cube where the footprint is large
        float3	ddx_tc	= ddx(sky_tc);
        float3	ddy_tc	= ddy(sky_tc);
        float	fp	= sqrt(max(dot(ddx_tc, ddx_tc), dot(ddy_tc, ddy_tc)));	// rad/pixel
        float	w_sky	= saturate(gloss) * saturate(1 - fp * SKY_FP_INV);

        // gloss = reflection sharpness (env <-> sky); amplitude comes from the spec
        // texture in combine_1; hemi attenuation applies to reflections exactly as
        // it does to the diffuse term.
        hspecular = lerp(env_s, sky_s, w_sky) * hscale;
}
