#include "common.h"

struct vv
{
	float3 pos0		: POSITION0;
	float3 n0		: NORMAL0;
	float2 tc0		: TEXCOORD0;
	float4 rgbh0	: TEXCOORD2;		// rgb.h
	float4 sun_af	: COLOR0;			// x=sun_0, z=alpha
};

struct vf
{
	float4 hpos		: POSITION;
	float2 tc0		: TEXCOORD0;		// base0
	float4 c		: COLOR0;			// color.alpha
	float  fog		: FOG;
	float3 fog_pos	: TEXCOORD6;
};

#define L_SCALE		(1.55)
#define L_SUN_HACK	(.7)

vf main (vv v)
{
	vf o;
	float4 pos = float4(v.pos0, 1);

#ifdef RETRO_MODE
	o.hpos = snap_to_position(mul(m_VP, pos));
#else	 
	o.hpos = mul(m_VP, pos);
#endif

	o.tc0 = v.tc0;

	float3 normal = normalize(v.n0);
	normal.y += 1;
	normal = normalize(normal);
	
	float4 rgbh = v.rgbh0 * L_SCALE;
	float sun = v.sun_af.x * L_SCALE;
	float sun_c = 1 + L_SUN_HACK * dot(normal, L_sun_dir_w);

	float3 L_rgb = rgbh.rgb;
	float3 L_hemi = L_hemi_color * rgbh.w;
	float3 L_sun = L_sun_color * sun * sun_c;
	float3 L_final = L_rgb + L_hemi + L_sun + L_ambient;

	o.c = float4(L_final, v.sun_af.z);
	o.fog		= calc_fogging	(pos);
	o.fog_pos	= pos.xyz;

	return o;
}






