#ifndef SLOAD_H
#define SLOAD_H

#include "common.h"

// Для террейна нужно будет отдельно переделывать шейдер под новый пайплайн

//#define USE_NEW_PIPELINE	 // Подключение нового пайплайна со спекуляром
//#define USE_PLUS_Y_NRM	 // Использовать +Y (OGL) карту нормалей
//#define USE_SEPARATE_SPEC	 // Отдельный спекуляр в г-буффер (требуется полное ковыряние всего для его использования в остальных местах)

//////////////////////////////////////////////////////////////////////////////////////////
// Bumped surface loader				//
//////////////////////////////////////////////////////////////////////////////////////////
struct surface_bumped
{
	float4 base;
	float3 normal;
	float  gloss;
	float  height;
#ifdef USE_SEPARATE_SPEC
	float  spec;
#endif
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

	// Параллакс
#ifdef USE_PARALLAX
	// Выбор канала высоты в зависимости от пайплайна
	#if defined(USE_NEW_PIPELINE)
		#define HEIGHT_CHANNEL g
	#else
		#define HEIGHT_CHANNEL w
	#endif
	float height = tex2D(s_bumpX, I.tcdh).HEIGHT_CHANNEL;
	height = height * parallax.x + parallax.y;
	tc = I.tcdh + height * normalize(I.eye);
	#undef HEIGHT_CHANNEL
#endif

#if defined(USE_NEW_PIPELINE)
	float4 Nu  = tex2D(s_bump,	tc);	// r=gloss, g=-Y, a=+X
	float4 NuE = tex2D(s_bumpX, tc);	// g=height, a=spec
	float2 nXY = Nu.wy * 2.f - 1.f;		// A=X, G=Y, full range
	S.base	   = tbase(tc);
	S.normal   = float3(nXY, sqrt(saturate(1.f - dot(nXY, nXY))));
	#if defined(USE_PLUS_Y_NRM)
		S.normal.y = -S.normal.y;		// Переворачиваем огл нормали в дх
	#endif
	#if defined(USE_SEPARATE_SPEC)
		S.gloss = Nu.x * Nu.x;			// gloss^2
		S.spec	= NuE.a;				// spec
	#else
		S.gloss = Nu.x * Nu.x * NuE.a;	// gloss^2 * spec
	#endif
	S.height = NuE.g;					// высота из канала G
#else
	// ориг пайплайн
	float4 Nu  = tex2D(s_bump,	tc);
	float4 NuE = tex2D(s_bumpX, tc);
	S.base	   = tbase(tc);
	S.normal   = Nu.wzy + (NuE.xyz - 1.0f);
	S.gloss	   = Nu.x * Nu.x;
	S.height   = NuE.w;
	#if defined(USE_SEPARATE_SPEC)
		S.spec = 1.0f;					// Если отдельный spec включён без нового пайплайна
	#endif
#endif

#ifdef USE_TDETAIL
	float4 detail = tex2D(s_detail, I.tcdbump);
	S.base.rgb *= detail.rgb * 2;
	S.gloss	   *= detail.w * 2;
	#if defined(USE_SEPARATE_SPEC)
		S.spec *= detail.w * 2;
	#endif
#endif

	return S;
}

surface_bumped sload(p_bumped I)
{
	surface_bumped S = sload_i(I);
	return S;
}

#endif