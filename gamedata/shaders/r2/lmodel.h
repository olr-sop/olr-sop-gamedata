#ifndef	LMODEL_H
#define LMODEL_H

#include "common.h"

float pow2(float x) { return x * x; }

//////////////////////////////////////////////////////////////////////////////////////////
// Lighting formulas
float4 plight_infinity(float m, float3 point, float3 normal, float3 light_direction)
{
    float3 N		= normal;
    float3 V		= -normalize(point);
    float3 L		= -light_direction;
    float3 H		= normalize(L+V);
    float4 light	= tex3D(s_material, float3(saturate(dot(L,N)), dot(H,N), m));
	
    return light;
}

// Режимы аттенюации (r2_lmodel_attenuation):
// 0: ванильный — saturate(1 - d²). Линейный спад по квадрату расстояния.
//    Свет гаснет равномерно от центра до радиуса. Резкая граница на R.
// 1: Source smooth — pow2(saturate(1 - d²)).
//    Квадрат ванильной формулы. Свет ярче у центра, быстрее гаснет к краю.
//    Та же резкая граница на R, но спад более естественный.
// 2: Invsq мягкий — saturate(1 / (1 + 4d²)).
//    Физически-инспирированный спад 1/(1+k*d²). Плавный, без резкой границы.
//    На R сила ~0.2 — нужен расширенный объём чтобы дойти до ~0.
// 3: Invsq резкий — saturate(1/max(d², .001)) * saturate(1 - .25d²).
//    Честный 1/d² с окном до 2R. Самый агрессивный спад у центра,
//    самый естественный вид. Расширенный объём обязателен.
float hl_atten(float rsqr, float inv_range_sq)
{
	float d2 = rsqr * inv_range_sq;
	float att;
	
	att = saturate(1.0 - d2);

	return att;
}

float4 plight_local(float m, float3 point, float3 normal, float3 light_position, float light_range_rsq, out float rsqr)
{
    float3 N    = normal;
    float3 L2P  = point - light_position;
    float3 V    = -normalize(point);
    float3 L    = -normalize((float3)L2P);
    float3 H    = normalize(L+V);
    rsqr        = dot(L2P, L2P);
    float  att  = hl_atten(rsqr, light_range_rsq);
    float4 light = tex3D(s_material, float3(saturate(dot(L,N)), dot(H,N), m));

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