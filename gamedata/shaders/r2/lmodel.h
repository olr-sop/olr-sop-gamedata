#ifndef	LMODEL_H
#define LMODEL_H

#include "common.h"

float pow2(float x) { return x * x; }

//-----------------------------------------------------------------------------------
// Analytic light model (the s_material 3D lookup table was removed).
//
//   diffuse  : Lambert, saturate(N·L)
//   specular : normalized Blinn-Phong, pow(saturate(N·H), P)
//
//     P = spec_power(gloss): log-linear over the console range [pow_min..pow_max]
//         (P = exp2(lerp(log2(pow_min), log2(pow_max), gloss)));
//         gloss is stored in G-buffer position.w by the deferred passes;
//         pow_max acts as the anti-aliasing ceiling (high exponents are
//         sub-pixel without LEAN mips).
//
//   spec_params (bound from the console):
//       x = fresnel amount, y = specular scale,
//       z = log2(pow_min),  w = log2(pow_max)
//
//   spec_visibility(): the vanilla LUT multiplied the specular lookup by ld^(1/32)
//   (ld = N·L). The effect: ~1.0 for any N·L > 0 and a hard 0 at N·L <= 0 — a very
//   soft terminator gate that keeps specular off back-lit surfaces (no rim
//   artifacts) and only inside the directly lit region. Kept for vanilla parity.
//-----------------------------------------------------------------------------------

float spec_visibility(float ndotl)  { return pow(saturate(ndotl), 1.f/32.f); }

float blinn_lobe    (float ndoth, float ndotl, float P)
{
	return pow(saturate(ndoth), P) * ((P + 2.f) * 0.125f) * pow(saturate(ndotl), 1.f/32.f); // пысовариант
//	return pow(saturate(ndoth), P) * spec_visibility(ndotl);
}

//////////////////////////////////////////////////////////////////////////////////////////
// Lighting formulas
float4 plight_infinity(float gloss, float3 point, float3 normal, float3 light_direction)
{
    float3 N		= normal;
    float3 V		= -normalize(point);
    float3 L		= -light_direction;
    float3 H		= normalize(L+V);
    float  P		= spec_power(gloss);

    float4 light;
    light.rgb		= saturate(dot(L,N));					// Lambert (diffuse)
    light.a			= blinn_lobe(dot(H,N), dot(L,N), P);	// Blinn-Phong (specular)

    return light;
}

// Linear-quadratic attenuation, saturate(1 - d²/R²) — vanilla X-Ray.
// Sharp cutoff at the light radius, no physical 1/d² falloff.
float hl_atten(float rsqr, float inv_range_sq)
{
	float d2 = rsqr * inv_range_sq;
	float att;
	
	att = saturate(1.0 - d2);

	return att;
}

float4 plight_local(float gloss, float3 point, float3 normal, float3 light_position, float light_range_rsq, out float rsqr)
{
    float3 N    = normal;
    float3 L2P  = point - light_position;
    float3 V    = -normalize(point);
    float3 L    = -normalize((float3)L2P);
    float3 H    = normalize(L+V);
    rsqr        = dot(L2P, L2P);
    float  att  = hl_atten(rsqr, light_range_rsq);
    float  P    = spec_power(gloss);

    float4 light;
    light.rgb	= saturate(dot(L,N));					// Lambert (diffuse)
    light.a		= blinn_lobe(dot(H,N), dot(L,N), P);	// Blinn-Phong (specular)

    return float4(att * light.xyz, att * light.w);
}

float4 blendp(float4 value, float4 tcp)
{
#ifndef FP16_BLEND
		value	+= (float4)tex2Dproj(s_accumulator, tcp);
#endif
	return value;
}

float4 blend(float4 value, float2 tc)
{
#ifndef FP16_BLEND
		value	+= (float4)tex2D(s_accumulator, tc);
#endif
	return value;
}

#endif
