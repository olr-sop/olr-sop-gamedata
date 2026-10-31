#ifndef SLOAD_H
#define SLOAD_H

#include "common.h"

// Новый пайплайн текстур — единственный:
//   s_bump  : r=gloss, g=-Y (+OGL флип), a=+X   (нормаль в GA, глосс в R)
//   s_bumpX : g=height, a=spec
//   s_detail (старый формат): rgb=diffuse, a=gloss
// Для террейна см. deffer_impl_* — там своя 4-слойная сборка (_nmap: R=gloss, G=Y, A=X)
#define USE_PLUS_Y_NRM	 // Использовать +Y (OGL) карту нормалей

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

surface_bumped sload_i(p_bumped I)
{
	surface_bumped S;
	float2 tc = I.tcdh;

	// Параллакс — высота в канале G (s_bumpX)
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
	S.gloss	   = Nu.x;				// глосс — сырьё, экспонента считается в месте использования
	S.spec	   = NuE.a;				// спекуляр — интенсивность отражения
	S.height   = NuE.g;				// высота из канала G

#ifdef USE_TDETAIL
	float4 detail = tex2D(s_detail, I.tcdbump);	// старый формат: rgb=diffuse, a=gloss
	S.base.rgb *= detail.rgb * 2;
	S.gloss	   *= detail.a * 2;	// деталь модулирует только глосс, спек-канала в ней нет
#endif

	return S;
}

surface_bumped sload(p_bumped I)
{
	surface_bumped S = sload_i(I);
	return S;
}

#endif
