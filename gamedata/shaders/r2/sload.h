#ifndef SLOAD_H
#define SLOAD_H

#include "common.h"

// Новый пайплайн текстур — единственный:
//   s_bump  : r=gloss, g=-Y (+OGL флип), a=+X   (нормаль в GA, глосс в R)
//   s_bumpX : g=height, a=spec
//   s_detail (старый формат): rgb=diffuse, a=gloss
// Для террейна см. deffer_impl_* — там своя 4-слойная сборка (_nmap: R=gloss, G=Y, A=X)
#define USE_PLUS_Y_NRM	 // Использовать +Y (OGL) карту нормалей
//#define DETAIL_GLOSS_LEGACY // пысо-глосс в детейлах detail.a * 2.f

//////////////////////////////////////////////////////////////////////////////////////////
// Bumped surface loader				//
//////////////////////////////////////////////////////////////////////////////////////////
struct surface_bumped
{
	float4 base;
	float3 normal;
	float  gloss;		// 0..1 — полировка (экспонента блинна), сырьё, без маппинга
	float  height;
	float  spec;		// 0..1 — что отражает поверхность (интенсивность)
};

#ifdef DBG_TMAPPING
float4 tbase(float2 tc)
{
	float2 tile = max(ddx(tc), ddy(tc));
	return (1 - max(tile.x, tile.y)); //*tex2D(s_base, tc);
}
#else
float4 tbase(float2 tc)
{
	return tex2D(s_base, tc);
}
#endif

// Combine the base NDF with the detail NDF. Angular variances add:
//   1/(P12 + 2) = 1/(P1 + 2) + 1/(P2 + 2)
// — the Blinn analogue of multiplying the average normal lengths from
// CoD WWII "Combining Detail Gloss" (length_combined = length_base * length_detail).
// A detail NDF can only roughen the base, never sharpen it.
float gloss_combine(float a, float b)
{
	float Pa = spec_power(a);
	float Pb = spec_power(b);
	float Pc = 1.f / (1.f / (Pa + 2.f) + 1.f / (Pb + 2.f)) - 2.f;
	return spec_gloss(Pc);
}

surface_bumped sload_i(p_bumped I)
{
	surface_bumped S;
	float2 tc = I.tcdh;

	// Параллакс: parallax.x = per-texture vh (thm bump_virtual_height),
	// parallax.y = -vh/2 (центрирование), значения приходят из uber_deffer.
#ifdef USE_PARALLAX
	float height = tex2D(s_bumpX, I.tcdh).g;
	height = height * parallax.x + parallax.y;
	tc = I.tcdh + height * normalize(I.eye);
#endif

	float4 Nu  = tex2D(s_bump,	tc);	// r=gloss, g=-Y, a=+X
	float4 NuE = tex2D(s_bumpX, tc);	// g=height, a=spec
	float2 nXY = Nu.wy * 2.f - 1.f;		// A=X, G=Y, full range
	S.base	   = tbase(tc);
	S.normal   = float3(nXY, sqrt(saturate(1.f - dot(nXY, nXY))));
#if defined(USE_PLUS_Y_NRM)
	S.normal.y = -S.normal.y;		// Переворачиваем огл нормали в дх
#endif
	S.gloss	   = Nu.x;				// глосс — сырьё 0..1 (канал текстуры), экспонента — в месте использования
	S.spec	   = NuE.a;				// спек — интенсивность отражения
	S.height   = NuE.g;				// высота из канала G

#ifdef USE_TDETAIL
	float4 detail = tex2D(s_detail, I.tcdbump);	// old format: rgb = diffuse detail, a = gloss
	S.base.rgb *= detail.rgb * 2;
#ifdef DETAIL_GLOSS_LEGACY
	float dg = saturate(detail.a * 2.f);	// legacy: 0.5 = neutral
#else
	float dg = detail.a;					// new: 1.0 = neutral, full range roughens
#endif
	S.gloss  = gloss_combine(S.gloss, dg);
#endif

	// страховка на будущие модуляции глосса (деталь/эффекты); сырьё из текстуры уже 0..1
	//S.gloss = saturate(S.gloss);

	return S;
}

surface_bumped sload(p_bumped I)
{
	surface_bumped S = sload_i(I);
	return S;
}

#endif
