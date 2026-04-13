#ifndef	COMMON_H
#define COMMON_H

#include "shared\common.h"

uniform float4		L_dynamic_props;	// per object, xyz=sun,w=hemi
uniform float4		L_dynamic_color;	// dynamic light color (rgb1)	- spot/point
uniform float4		L_dynamic_pos;		// dynamic light pos+1/range(w) - spot/point
uniform float4x4 	L_dynamic_xform;

uniform float4x4	m_plmap_xform;
uniform float4 		m_plmap_clamp	[2];	// 0.w = factor
uniform float4		r1a_fog_params;	// x=near start, y=1/(near_end-near_start), z=near curve, w=max density
uniform float4		r1a_fog_height;	// x=height level, y=height density, z,w reserved
uniform float4		r1a_hfog_color;	// xyz=height fog color, w=blend to fog_color in distance
uniform float4		r1a_hfog_dist;	// x=color dist start (in linear fog), y=1/range, z=emitter_mul
uniform float4		r1a_hfog_emitter_bb;	// x=minX, y=minZ, z=maxX, w=maxZ
uniform float4		r1a_hfog_emitter_params;	// x=enable, y=edge, z=texel_world, w=packed8_flag
uniform float4		r1a_hfog_emitter_height;	// x=minY, y=rangeY, z=signed_distance_range, w=reserved
uniform float4		r1a_mipfog_params;	// x=enable, y=near_to_detail_start, z=directional_amount, w=reserved

float  	calc_fogging 	(float4 w_pos)	{ return dot(w_pos,fog_plane); 	}

float r1a_fog_factor(float3 fog_pos)
{
	return saturate(calc_fogging(float4(fog_pos, 1.0f)));
}

float3	r1a_fog_color(float3 fog_pos)
{
	float3 fog_target = fog_color.rgb;

	if (r1a_mipfog_params.x > 0.5f)
	{
		float4 clip = mul(m_VP, float4(fog_pos, 1.0f));
		float inv_w = 1.0f / max(abs(clip.w), 1e-4f);
		float2 ndc = clip.xy * inv_w;
		float2 uv = float2(ndc.x * 0.5f + 0.5f, 0.5f - ndc.y * 0.5f);
		uv = saturate(uv);

		float linear_fog = r1a_fog_factor(fog_pos);
		float detail_t = saturate((linear_fog - r1a_mipfog_params.y) / max(1.0f - r1a_mipfog_params.y, 1e-3f));
		float3 directional_fog = tex2D(r1a_fog_sky_lut, uv).rgb;
		fog_target = lerp(directional_fog, fog_color.rgb, detail_t * r1a_mipfog_params.z);
	}

	return fog_target;
}

float3	r1a_apply_fog(float3 color, float3 fog_pos)
{
	float fog_factor = r1a_fog_factor(fog_pos);
	float linear_fog = 1.0f - fog_factor;

	float emitter_mask = 1.0f;
	float height_level = r1a_fog_height.x;
	if (r1a_hfog_emitter_params.x > 0.5f)
	{
		float2 span = float2(max(r1a_hfog_emitter_bb.z - r1a_hfog_emitter_bb.x, 0.01f), max(r1a_hfog_emitter_bb.w - r1a_hfog_emitter_bb.y, 0.01f));
		float2 uv = float2((fog_pos.x - r1a_hfog_emitter_bb.x) / span.x, (fog_pos.z - r1a_hfog_emitter_bb.y) / span.y);
		float4 m = tex2D(r1a_hfog_emitter_mask, uv);
		if (r1a_hfog_emitter_params.w > 0.5f)
		{
			const float deband = 0.5f / 255.0f;
			m.r = saturate(m.r + deband);
			m.g = saturate(m.g + deband);
		}
		float signed_dist = (m.r * 2.0f - 1.0f) * max(r1a_hfog_emitter_height.z, 0.01f);
		float edge = max(r1a_hfog_emitter_params.y, r1a_hfog_emitter_params.z * 1.5f);
		edge = max(edge, 0.05f);
		emitter_mask = smoothstep(-edge * 1.5f, edge * 0.5f, signed_dist);
		height_level = r1a_hfog_emitter_height.x + m.g * r1a_hfog_emitter_height.y;
	}

	float density = r1a_fog_height.y * saturate(emitter_mask * r1a_hfog_dist.z);
	float height_fog = 0.0f;
	height_fog = saturate((height_level - fog_pos.y) * density);
	height_fog = 1.0f - exp2(-height_fog * 2.0f);
	height_fog = smoothstep(0.0f, 1.0f, height_fog);
	height_fog = min(height_fog, saturate(r1a_fog_params.w));

	float near_fade = saturate((distance(fog_pos, eye_position) - r1a_fog_params.x) * r1a_fog_params.y);
	near_fade = pow(near_fade, max(r1a_fog_params.z, 0.2f));
	height_fog *= near_fade;

	float result_fog = max(linear_fog, height_fog);
	float3 fog_target = r1a_fog_color(fog_pos);
	float color_dist = saturate((linear_fog - r1a_hfog_dist.x) * r1a_hfog_dist.y);
	float3 hfog_color = lerp(r1a_hfog_color.rgb, fog_color.rgb, saturate(color_dist * r1a_hfog_color.w));
	fog_target = lerp(fog_target, hfog_color, height_fog);

	return lerp(fog_target, color, 1.0f - result_fog);
}
float2 	calc_detail 	(float3 w_pos)	{ 
	float  	dtl	= distance(w_pos,eye_position)*dt_params.w;
		dtl	= min(dtl*dtl, 1);
	float  	dt_mul	= 1  - dtl;	// dt*  [1 ..  0 ]
	float  	dt_add	= .5 * dtl;	// dt+	[0 .. 0.5]
	return	float2	(dt_mul,dt_add);
}
float3 	calc_reflection	(float3 pos_w, float3 norm_w)
{
    return reflect(normalize(pos_w-eye_position), norm_w);
}
float4	calc_spot 	(out float4 tc_lmap, out float2 tc_att, float4 w_pos, float3 w_norm)	{
	float4 	s_pos	= mul	(L_dynamic_xform, w_pos);
	tc_lmap		= s_pos.xyww;			// projected in ps/ttf
	tc_att 		= s_pos.z;			// z=distance * (1/range)
	float3 	L_dir_n = normalize	(w_pos - L_dynamic_pos.xyz);
	float 	L_scale	= dot(w_norm,-L_dir_n);
	return 	L_dynamic_color*L_scale*saturate(calc_fogging(w_pos));
}
float4	calc_point 	(out float2 tc_att0, out float2 tc_att1, float4 w_pos, float3 w_norm)	{
	float3 	L_dir_n = normalize	(w_pos - L_dynamic_pos.xyz);
	float 	L_scale	= dot		(w_norm,-L_dir_n);
	float3	L_tc 	= (w_pos - L_dynamic_pos.xyz) * L_dynamic_pos.w + .5f;	// tc coords
	tc_att0		= L_tc.xz;
	tc_att1		= L_tc.xy;
	return 	L_dynamic_color*L_scale*saturate(calc_fogging(w_pos));
}
float3	calc_sun		(float3 norm_w)	{ return L_sun_color*max(dot((norm_w),-L_sun_dir_w),0); 		}
float3 	calc_model_hemi 	(float3 norm_w)	{ return (norm_w.y*0.5+0.5)*L_dynamic_props.w*L_hemi_color; 		}
float3	calc_model_lq_lighting	(float3 norm_w) { return calc_model_hemi(norm_w) + L_ambient + L_dynamic_props.xyz*calc_sun(norm_w); 	}
float3 	_calc_model_hemi 	(float3 norm_w)	{ return max(0,norm_w.y)*.2*L_hemi_color; 				}
float3	_calc_model_lq_lighting	(float3 norm_w) { return calc_model_hemi(norm_w) + L_ambient + .5*calc_sun(norm_w); 	}
float4 	calc_model_lmap 	(float3 pos_w)	{
	float3  pos_wc	= clamp		(pos_w,m_plmap_clamp[0],m_plmap_clamp[1]);		// clamp to BBox
	float4 	pos_w4c	= float4	(pos_wc,1);	
	float4 	plmap 	= mul		(m_plmap_xform,pos_w4c);				// calc plmap tc
	return  plmap.xyww;
}

struct 	v_lmap
{
	float4 	P	: POSITION;			// (float,float,float,1)
	float4	N	: NORMAL;			// (nx,ny,nz,hemi occlusion)
	float4 	T	: TANGENT;
	float4 	B	: BINORMAL;
	float2 	uv0	: TEXCOORD0;		// (base)
	float2	uv1	: TEXCOORD1;		// (lmap/compressed)
};
struct	v_vert
{
	float4 	P		: POSITION;		// (float,float,float,1)
	float4	N		: NORMAL;		// (nx,ny,nz,hemi occlusion)
	float4 	T		: TANGENT;
	float4 	B		: BINORMAL;
	float4	color	: COLOR0;		// (r,g,b,dir-occlusion)
	float2 	uv		: TEXCOORD0;	// (u0,v0)
};
struct 	v_model
{
	float4 	pos	: POSITION;	// (float,float,float,1)
	float3	norm	: NORMAL;	// (nx,ny,nz)
	float3	T	: TANGENT;	// (nx,ny,nz)
	float3	B	: BINORMAL;	// (nx,ny,nz)
	float2	tc	: TEXCOORD0;	// (u,v)
#ifdef SKIN_COLOR
	float3 	rgb_tint;
#endif
};
struct	v_detail
{
	float4 	pos	: POSITION;	// (float,float,float,1)
	int4 	misc	: TEXCOORD0;	// (u(Q),v(Q),frac,matrix-id)
};
struct 	vf_spot
{
	float4 hpos	: POSITION;
	float2 tc0	: TEXCOORD0;	// base
	float4 tc1	: TEXCOORD1;	// lmap, projected
	float2 tc2	: TEXCOORD2;	// att + clipper
	float4 color	: COLOR0;
};
struct 	vf_point
{
	float4 hpos	: POSITION;
	float2 tc0	: TEXCOORD0;	// base
	float2 tc1	: TEXCOORD1;	// att1 + clipper
	float2 tc2	: TEXCOORD2;	// att2 + clipper
	float4 color	: COLOR0;
};

struct 	impl_vf_spot
{
	float4 hpos	: POSITION;
	float2 tc0	: TEXCOORD0;	// base
	float4 tc1	: TEXCOORD1;	// lmap, projected
	float2 tc2	: TEXCOORD2;	// att + clipper
	float2 tcd	: TEXCOORD3;	// details	
	float4 color	: COLOR0;
};
struct 	impl_vf_point
{
	float4 hpos	: POSITION;
	float2 tc0	: TEXCOORD0;	// base
	float2 tc1	: TEXCOORD1;	// att1 + clipper
	float2 tc2	: TEXCOORD2;	// att2 + clipper
	float2 tcd	: TEXCOORD3;	// details	
	float4 color	: COLOR0;
};

//	TL
struct	p_TL
{
	float2 	tc0		: TEXCOORD0;
	float4	color	: COLOR;
};
struct	v_TL
{
	float4	hpos	: POSITION;
	float2	tc0		: TEXCOORD0;
	float4	color	: COLOR; 
};
struct	v2p_TL
{
	float2 	tc0		: TEXCOORD0;
	float4	color	: COLOR;
	float4 	hpos	: POSITION;	// Clip-space position 	(for rasterization)
};
//////////////////////////////////////////////////////////////////////////////////////////
uniform sampler2D 	s_base;
uniform samplerCUBE	s_env;
uniform sampler2D 	s_lmap;
uniform sampler2D 	s_hemi;
uniform sampler2D 	s_att;
uniform sampler2D 	s_detail;

#define def_distort	float(0.05f)	// we get -0.5 .. 0.5 range, this is -512 .. 512 for 1024, so scale it

float3	v_hemi 		(float3 n)		{	return L_hemi_color/* *(.5f + .5f*n.y) */; 		}
float3	v_hemi_wrap	(float3 n, float w)	{	return L_hemi_color/* *(w + (1-w)*n.y) */; 		}
float3 	v_sun 		(float3 n)		{	return L_sun_color*max(0,dot(n,-L_sun_dir_w));		}
float3 	v_sun_wrap	(float3 n, float w)	{	return L_sun_color*(w+(1-w)*dot(n,-L_sun_dir_w));	}
float3	p_hemi		(float2 tc) 	{
	float3	t_lmh 	= tex2D		(s_hemi, tc);
	return  dot	(t_lmh,1.h/3.h);
}

// -----------------------------------------------------------------------------
// Stochastic sampling switch
// 0 - off (regular tex2D)
// 1 - per-tile transform + 4-corner blend
// 2 - voronoi weighted neighborhood
// 3 - virtual-pattern blend
// 4 - by-example triangle blend (Godot-adapted, self-contained)
// 5 - stochastic hex-tiling (Mikkelsen/Godot-adapted, self-contained)
#ifndef R1A_STOCHASTIC_MODE
	#define R1A_STOCHASTIC_MODE 3
#endif

// Mode 1 controls (tile transform)
#ifndef R1A_ST1_SMOOTH_MIN
	#define R1A_ST1_SMOOTH_MIN 0.25f
#endif
#ifndef R1A_ST1_SMOOTH_MAX
	#define R1A_ST1_SMOOTH_MAX 0.75f
#endif

// Mode 2 controls (voronoi)
#ifndef R1A_ST2_EXP_FALLOFF
	#define R1A_ST2_EXP_FALLOFF 5.0f
#endif

// Mode 3 controls (virtual patterns)
#ifndef R1A_ST3_PATTERN_COUNT
	#define R1A_ST3_PATTERN_COUNT 8.0f
#endif
#ifndef R1A_ST3_NOISE_SCALE
	#define R1A_ST3_NOISE_SCALE 0.005f
#endif
#ifndef R1A_ST3_OFFSET_SCALE
	#define R1A_ST3_OFFSET_SCALE 1.0f
#endif
#ifndef R1A_ST3_LUMA_BIAS
	#define R1A_ST3_LUMA_BIAS 0.1f
#endif

// Mode 4 controls (triangle by-example)
#ifndef R1A_ST4_APPLY_NORM
	#define R1A_ST4_APPLY_NORM 1
#endif

// Mode 5 controls (hex tiling)
#ifndef R1A_ST5_ROT_STRENGTH
	#define R1A_ST5_ROT_STRENGTH 0.5f
#endif
#ifndef R1A_ST5_WEIGHT_EXP
	#define R1A_ST5_WEIGHT_EXP 7.0f
#endif
#ifndef R1A_ST5_GAIN
	#define R1A_ST5_GAIN 0.75f
#endif

float r1a_hash1(float2 p)
{
	return frac(sin(dot(p, float2(127.1f, 311.7f))) * 43758.5453f);
}

float2 hash2D2D(float2 p)
{
	return frac(sin(float2(dot(p, float2(127.1f, 311.7f)), dot(p, float2(269.5f, 183.3f)))) * 43758.5453f);
}

float4 r1a_hash4(float2 p)
{
	return frac(sin(float4(
		dot(p, float2(127.1f, 311.7f)),
		dot(p, float2(269.5f, 183.3f)),
		dot(p, float2(419.2f, 371.9f)),
		dot(p, float2(95.7f, 541.3f)))) * 43758.5453f);
}

float r1a_sum3(float3 v)
{
	return v.x + v.y + v.z;
}

float r1a_value_noise(float2 p)
{
	float2 i = floor(p);
	float2 f = frac(p);
	f = f * f * (3.0f - 2.0f * f);

	float a = r1a_hash1(i);
	float b = r1a_hash1(i + float2(1.0f, 0.0f));
	float c = r1a_hash1(i + float2(0.0f, 1.0f));
	float d = r1a_hash1(i + float2(1.0f, 1.0f));

	return lerp(lerp(a, b, f.x), lerp(c, d, f.x), f.y);
}

void r1a_triangle_grid(float2 uv, out float w1, out float w2, out float w3, out float2 vertex1, out float2 vertex2, out float2 vertex3)
{
	float2 skewed_coord = mul(float2x2(1.0f, 0.0f, -0.57735027f, 1.15470054f), uv * 3.464f);
	float2 base_id = floor(skewed_coord);
	float3 temp = float3(frac(skewed_coord), 0.0f);
	temp.z = 1.0f - temp.x - temp.y;

	if (temp.z > 0.0f)
	{
		w1 = temp.z;
		w2 = temp.y;
		w3 = temp.x;
		vertex1 = base_id;
		vertex2 = base_id + float2(0.0f, 1.0f);
		vertex3 = base_id + float2(1.0f, 0.0f);
	}
	else
	{
		w1 = -temp.z;
		w2 = 1.0f - temp.y;
		w3 = 1.0f - temp.x;
		vertex1 = base_id + float2(1.0f, 1.0f);
		vertex2 = base_id + float2(1.0f, 0.0f);
		vertex3 = base_id + float2(0.0f, 1.0f);
	}
}

float4 tex2DStochastic_V1(sampler2D tex, float2 uv)
{
	float2 iuv = floor(uv);
	float2 fuv = frac(uv);

	float4 ofa = r1a_hash4(iuv + float2(0.0f, 0.0f));
	float4 ofb = r1a_hash4(iuv + float2(1.0f, 0.0f));
	float4 ofc = r1a_hash4(iuv + float2(0.0f, 1.0f));
	float4 ofd = r1a_hash4(iuv + float2(1.0f, 1.0f));

	float2 ddx_uv = ddx(uv);
	float2 ddy_uv = ddy(uv);

	ofa.z = (ofa.z < 0.5f) ? -1.0f : 1.0f;
	ofa.w = (ofa.w < 0.5f) ? -1.0f : 1.0f;
	ofb.z = (ofb.z < 0.5f) ? -1.0f : 1.0f;
	ofb.w = (ofb.w < 0.5f) ? -1.0f : 1.0f;
	ofc.z = (ofc.z < 0.5f) ? -1.0f : 1.0f;
	ofc.w = (ofc.w < 0.5f) ? -1.0f : 1.0f;
	ofd.z = (ofd.z < 0.5f) ? -1.0f : 1.0f;
	ofd.w = (ofd.w < 0.5f) ? -1.0f : 1.0f;

	float2 uva = uv * ofa.zw + ofa.xy;
	float2 uvb = uv * ofb.zw + ofb.xy;
	float2 uvc = uv * ofc.zw + ofc.xy;
	float2 uvd = uv * ofd.zw + ofd.xy;

	float4 ca = tex2D(tex, uva, ddx_uv * ofa.zw, ddy_uv * ofa.zw);
	float4 cb = tex2D(tex, uvb, ddx_uv * ofb.zw, ddy_uv * ofb.zw);
	float4 cc = tex2D(tex, uvc, ddx_uv * ofc.zw, ddy_uv * ofc.zw);
	float4 cd = tex2D(tex, uvd, ddx_uv * ofd.zw, ddy_uv * ofd.zw);

	float2 b = smoothstep(R1A_ST1_SMOOTH_MIN, R1A_ST1_SMOOTH_MAX, fuv);
	return lerp(lerp(ca, cb, b.x), lerp(cc, cd, b.x), b.y);
}

float4 tex2DStochastic_V2(sampler2D tex, float2 uv)
{
	float2 p = floor(uv);
	float2 f = frac(uv);
	float2 ddx_uv = ddx(uv);
	float2 ddy_uv = ddy(uv);

	float4 va = float4(0.0f, 0.0f, 0.0f, 0.0f);
	float wt = 0.0f;

	for (int j = -1; j <= 1; j++)
	{
		for (int i = -1; i <= 1; i++)
		{
			float2 g = float2((float)i, (float)j);
			float4 o = r1a_hash4(p + g);
			float2 r = g - f + o.xy;
			float d = dot(r, r);
			float w = exp(-R1A_ST2_EXP_FALLOFF * d);
			float4 c = tex2D(tex, uv + o.zw, ddx_uv, ddy_uv);
			va += w * c;
			wt += w;
		}
	}

	return va / max(wt, 0.00001f);
}

float4 tex2DStochastic_V3(sampler2D tex, float2 uv)
{
	float k = r1a_value_noise(uv * R1A_ST3_NOISE_SCALE);
	float index = k * R1A_ST3_PATTERN_COUNT;
	float i = floor(index);
	float f = frac(index);

	float2 offa = sin(float2(3.0f, 7.0f) * (i + 0.0f)) * R1A_ST3_OFFSET_SCALE;
	float2 offb = sin(float2(3.0f, 7.0f) * (i + 1.0f)) * R1A_ST3_OFFSET_SCALE;

	float2 dx = ddx(uv);
	float2 dy = ddy(uv);

	float4 cola = tex2D(tex, uv + offa, dx, dy);
	float4 colb = tex2D(tex, uv + offb, dx, dy);

	float t = smoothstep(0.2f, 0.8f, f - R1A_ST3_LUMA_BIAS * r1a_sum3(cola.rgb - colb.rgb));
	return lerp(cola, colb, t);
}

float4 tex2DStochastic_V4(sampler2D tex, float2 uv)
{
	float w1, w2, w3;
	float2 vertex1, vertex2, vertex3;
	r1a_triangle_grid(uv, w1, w2, w3, vertex1, vertex2, vertex3);

	float2 uv1 = uv + hash2D2D(vertex1);
	float2 uv2 = uv + hash2D2D(vertex2);
	float2 uv3 = uv + hash2D2D(vertex3);

	float2 duvdx = ddx(uv);
	float2 duvdy = ddy(uv);

	float4 g1 = tex2D(tex, uv1, duvdx, duvdy);
	float4 g2 = tex2D(tex, uv2, duvdx, duvdy);
	float4 g3 = tex2D(tex, uv3, duvdx, duvdy);

	float4 stoch = w1 * g1 + w2 * g2 + w3 * g3;

#if R1A_ST4_APPLY_NORM
	float norm = rsqrt(max(w1 * w1 + w2 * w2 + w3 * w3, 0.00001f));
	stoch.rgb = (stoch.rgb - 0.5f) * norm + 0.5f;
	stoch.a = (stoch.a - 0.5f) * norm + 0.5f;
#endif

	return stoch;
}

float2 r1a_make_cen_st(float2 vertex)
{
	float2x2 inv_skew = float2x2(1.0f, 0.0f, 0.5f, 1.0f / 1.15470054f);
	return mul(inv_skew, vertex) / 3.464f;
}

float2x2 r1a_load_rot2x2(float2 idx, float rot_strength)
{
	float pi = 3.14159265f;
	float two_pi = 6.28318530f;
	float angle = abs(idx.x * idx.y) + abs(idx.x + idx.y) + pi;
	angle = fmod(angle, two_pi);
	if (angle > pi)
	{
		angle -= two_pi;
	}
	angle *= rot_strength;

	float cs = cos(angle);
	float si = sin(angle);
	return float2x2(cs, -si, si, cs);
}

float3 r1a_gain3(float3 x, float r)
{
	float k = log(1.0f - r) / log(0.5f);
	float3 s = 2.0f * step(float3(0.5f, 0.5f, 0.5f), x);
	float3 m = 2.0f * (1.0f - s);
	float3 res = 0.5f * s + 0.25f * m * pow(max(float3(0.0f, 0.0f, 0.0f), s + x * m), k);
	return res / max(r1a_sum3(res), 0.00001f);
}

float4 tex2DStochastic_V5(sampler2D tex, float2 uv)
{
	float2 d_uv_dx = ddx(uv);
	float2 d_uv_dy = ddy(uv);

	float w1, w2, w3;
	float2 vertex1, vertex2, vertex3;
	r1a_triangle_grid(uv, w1, w2, w3, vertex1, vertex2, vertex3);

	float2x2 rot1 = r1a_load_rot2x2(vertex1, R1A_ST5_ROT_STRENGTH);
	float2x2 rot2 = r1a_load_rot2x2(vertex2, R1A_ST5_ROT_STRENGTH);
	float2x2 rot3 = r1a_load_rot2x2(vertex3, R1A_ST5_ROT_STRENGTH);

	float2 cen1 = r1a_make_cen_st(vertex1);
	float2 cen2 = r1a_make_cen_st(vertex2);
	float2 cen3 = r1a_make_cen_st(vertex3);

	float2 st1 = mul(rot1, (uv - cen1)) + cen1 + hash2D2D(vertex1);
	float2 st2 = mul(rot2, (uv - cen2)) + cen2 + hash2D2D(vertex2);
	float2 st3 = mul(rot3, (uv - cen3)) + cen3 + hash2D2D(vertex3);

	float4 c1 = tex2D(tex, st1, mul(rot1, d_uv_dx), mul(rot1, d_uv_dy));
	float4 c2 = tex2D(tex, st2, mul(rot2, d_uv_dx), mul(rot2, d_uv_dy));
	float4 c3 = tex2D(tex, st3, mul(rot3, d_uv_dx), mul(rot3, d_uv_dy));

	float3 lw = float3(0.299f, 0.587f, 0.114f);
	float3 dw = float3(dot(c1.rgb, lw), dot(c2.rgb, lw), dot(c3.rgb, lw));
	dw = lerp(float3(1.0f, 1.0f, 1.0f), dw, 0.6f);

	float3 w = dw * pow(float3(w1, w2, w3), R1A_ST5_WEIGHT_EXP);
	w /= max(r1a_sum3(w), 0.00001f);

	if (R1A_ST5_GAIN != 0.5f)
	{
		w = r1a_gain3(w, saturate(R1A_ST5_GAIN));
	}

	return w.x * c1 + w.y * c2 + w.z * c3;
}

float4 tex2DStochastic(sampler2D tex, float2 UV)
{
#if R1A_STOCHASTIC_MODE == 0
	return tex2D(tex, UV);
#elif R1A_STOCHASTIC_MODE == 1
	return tex2DStochastic_V1(tex, UV);
#elif R1A_STOCHASTIC_MODE == 2
	return tex2DStochastic_V2(tex, UV);
#elif R1A_STOCHASTIC_MODE == 3
	return tex2DStochastic_V3(tex, UV);
#elif R1A_STOCHASTIC_MODE == 4
	return tex2DStochastic_V4(tex, UV);
#elif R1A_STOCHASTIC_MODE == 5
	return tex2DStochastic_V5(tex, UV);
#else
	return tex2DStochastic_V4(tex, UV);
#endif
}

float4 tex2DStochasticRGBKeepA(sampler2D tex, float2 UV)
{
	float4 regular = tex2D(tex, UV);
	float4 stochastic = tex2DStochastic(tex, UV);
	stochastic.a = regular.a;
	return stochastic;
}

//#define RETRO_MODE // Для отладки

#ifdef RETRO_MODE

// PS1/PSX Model (https://godotshaders.com/shader/ps1-psx-model/)
// Автор: Grau
// Порт на хрей: theysani

uniform float4 c_retromode_params;

float4 snap_to_position(float4 base_position)
{
	float jitter = c_retromode_params.x; // from 0.01 to 0.99
	float2 resolution;
	
	if (c_retromode_params.y == 0)
	{
		resolution = float2(320, 240);
	}
	else if (c_retromode_params.y == 1)
	{
		resolution = float2(640, 480);
	}
	
	float4 snapped_position = base_position;
	snapped_position.xyz = base_position.xyz / base_position.w;
	
	float2 snap_resulotion = floor(float2(resolution) * (1.0 - jitter));
	snapped_position.x = floor(snap_resulotion.x * snapped_position.x) / snap_resulotion.x;
	snapped_position.y = floor(snap_resulotion.y * snapped_position.y) / snap_resulotion.y;
	
	snapped_position.xyz *= base_position.w;
	return snapped_position;
}

#endif

#endif // COMMON_H
