#ifndef SHARED_COMMON_H
#define SHARED_COMMON_H
//
uniform float3x4	m_W;
uniform float3x4	m_V;
uniform float4x4 	m_P;
uniform float3x4	m_WV;
uniform float4x4 	m_VP;
uniform float4x4 	m_WVP;
uniform float4x4 	L_dynamic_xform;
uniform half4		L_dynamic_pos;		// dynamic light pos+1/range(w) - spot/point
uniform half4		L_dynamic_color;	// dynamic light color (rgb1)	- spot/point
uniform half4		timers;
uniform half4		fog_plane;
uniform float4		fog_params;		// x=near*(1/(far-near)), ?,?, w = -1/(far-near)
uniform half4		fog_color;
uniform half3		L_sun_color;
uniform half3		L_sun_dir_w;
uniform half3		L_sun_dir_e;
uniform half4		L_hemi_color;
uniform half4		L_ambient;		// L_ambient.w = skynbox-lerp-factor
uniform half3		L_lmap_color;

uniform float3 		eye_position;
uniform half3		eye_direction;
uniform half3		eye_normal;
uniform	half4 		dt_params;

half3 	unpack_normal	(half3 v)	{ return 2.f*v-1.f; 		}
half3 	unpack_bx2	(half3 v)	{ return 2.f*v-1.f; 		}
half3 	unpack_bx4	(half3 v)	{ return 4.f*v-2.f; 		}

float2 	unpack_tc_base	(float2 tc, float du, float dv)		{
		return (tc.xy + float2	(du,dv))*(32.f/32768.f);
}

half2 	unpack_tc_lmap	(half2 tc)	{ return tc*(1.f/32768.f);	} // [-1  .. +1 ]

float 	calc_cyclic 	(float x)				{
	float 	phase 	= 1/(2*3.141592653589f);
	float 	sqrt2	= 1.4142136f;
	float 	sqrt2m2	= 2.8284271f;
	float 	f 	= sqrt2m2*frac(x)-sqrt2;	// [-sqrt2 .. +sqrt2]
	return 	f*f - 1.f;				// [-1     .. +1]
}
float2 	calc_xz_wave 	(float2 dir2D, float frac)		{
	// Beizer
	float2  ctrl_A	= float2(0.f,		0.f	);
	float2 	ctrl_B	= float2(dir2D.x,	dir2D.y	);
	return  lerp	(ctrl_A, ctrl_B, frac);
}



half Contrast(half Input, half ContrastPower)
{
     //piecewise contrast function
     bool IsAboveHalf = Input > 0.5 ;
     half ToRaise = saturate(2*(IsAboveHalf ? 1-Input : Input));
     half Output = 0.5*pow(ToRaise, ContrastPower);
     Output = IsAboveHalf ? 1-Output : Output;
     return Output;
} 



float4 convert_to_screen_space(float4 proj)
{
	float4 screen;
	screen.x = (proj.x + proj.w)*0.5;
	screen.y = (proj.w - proj.y)*0.5;
	screen.z = proj.z;
	screen.w = proj.w;
	return screen;
}



#endif