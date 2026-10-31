#ifndef	LMODEL_H
#define LMODEL_H

#include "common.h"

float pow2(float x) { return x * x; }

//-----------------------------------------------------------------------------------
// Аналитическая модель света (LUT s_material удалён):
//   диффуз  : Lambert, saturate(NdotL)
//   спекуляр: Blinn-Phong, pow(saturate(NdotH), P) * (P+2)/8,
//             P = exp2(lerp(log2(pow_min), log2(pow_max), gloss)) — gloss из G-буфера
//             гейт pow(saturate(NdotL), 1/32) гасит спек от засвеченной со спины
//             поверхности (аналог модуляции ld^(1/32) из старой LUT)
//   spec_params: x=fresnel, y=scale, z=log2(pow_min), w=log2(pow_max) — из консоли

float  spec_power    (float gloss)  { return exp2(lerp(spec_params.z, spec_params.w, gloss)); }
float  blinn_lobe    (float ndoth, float ndotl, float P)
{
	return pow(saturate(ndoth), P) * ((P + 2.f) * 0.125f) * pow(saturate(ndotl), 1.f/32.f);
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
    light.rgb		= saturate(dot(L,N));					// Lambert
    light.a			= blinn_lobe(dot(H,N), dot(L,N), P);	// Blinn specular

    return light;
}

// Ванильная аттенюация — saturate(1 - d²). Линейный спад по квадрату расстояния,
// резкая граница на R.
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
    light.rgb	= saturate(dot(L,N));					// Lambert
    light.a		= blinn_lobe(dot(H,N), dot(L,N), P);	// Blinn specular

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
