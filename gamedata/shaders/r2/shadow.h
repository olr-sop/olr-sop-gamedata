#ifndef	SHADOW_H
#define SHADOW_H

#include "common.h"

uniform	sampler	s_smap	: register(ps,s0);	// 2D/cube shadowmap

#define	KERNEL	.6f

//////////////////////////////////////////////////////////////////////////////////////////
// hardware PCF (D24X8): 4 bilinear taps
//////////////////////////////////////////////////////////////////////////////////////////
float	sample_hw_pcf	(float4 tc,float4 shift){
	static const float 	ts = KERNEL / float(SMAP_size);
	return tex2Dproj	(s_smap,tc + tc.w*shift*ts).x;
}
float	shadow_hw		(float4 tc)		{
	float  s0		= sample_hw_pcf	(tc,float4(-1,-1,0,0));
	float  s1		= sample_hw_pcf	(tc,float4(+1,-1,0,0));
	float  s2		= sample_hw_pcf	(tc,float4(-1,+1,0,0));
	float  s3		= sample_hw_pcf	(tc,float4(+1,+1,0,0));
	return	(s0+s1+s2+s3)/4.h;
}

//////////////////////////////////////////////////////////////////////////////////////////
// Poisson-disk samples (shared by medium/high quality)
//////////////////////////////////////////////////////////////////////////////////////////
static const float2 poisson_disk_12[12] =
{
	float2(-0.326212f, -0.405810f),
	float2(-0.840144f, -0.073580f),
	float2(-0.695914f,  0.457137f),
	float2(-0.203345f,  0.620716f),
	float2( 0.962340f, -0.194983f),
	float2( 0.473434f, -0.480026f),
	float2( 0.519456f,  0.767022f),
	float2( 0.185461f, -0.893124f),
	float2( 0.896420f,  0.412458f),
	float2(-0.321940f, -0.932615f),
	float2(-0.791559f, -0.597710f),
	float2( 0.943696f, -0.588044f),
};

// medium quality: 8 taps
float	shadow_medium	(float4 tc)
{
	const float kernel_scale = 2.0f;
	float s = 0;
	for (int i = 0; i < 8; i++)
		s += sample_hw_pcf(tc, float4(poisson_disk_12[i], 0, 0) * kernel_scale);
	return s * (1.h / 8.h);
}

// high quality: 12 taps
float	shadow_soft		(float4 tc)
{
	const float kernel_scale = 3.5f;
	float s = 0;
	for (int i = 0; i < 12; i++)
		s += sample_hw_pcf(tc, float4(poisson_disk_12[i], 0, 0) * kernel_scale);
	return s * (1.h / 12.h);
}

//////////////////////////////////////////////////////////////////////////////////////////
// quality switch (SHADOW_QUALITY define comes from the renderer)
//   0 = low    : 4 taps
//   1 = medium : 8 taps
//   2 = high   : 12 taps
//////////////////////////////////////////////////////////////////////////////////////////
float	shadow_quality	(float4 tc)
{
#if SHADOW_QUALITY == 2
	return shadow_soft   (tc);
#elif SHADOW_QUALITY == 1
	return shadow_medium (tc);
#else
	return shadow_hw     (tc);
#endif
}

//////////////////////////////////////////////////////////////////////////////////////////
#ifdef  USE_SUNMASK	
uniform float3x4	m_sunmask	;				// ortho-projection
float 	sunmask		(float4 P)	{				// 
	float2 		tc	= mul	(m_sunmask, P);		//
	return 		tex2D 		(s_lmap,tc).w;		// A8 
	
}
#else
float 	sunmask		(float4 P)	{ return 1.h; }	// 
#endif

//////////////////////////////////////////////////////////////////////////////////////////
uniform float4x4	m_shadow;

#endif
