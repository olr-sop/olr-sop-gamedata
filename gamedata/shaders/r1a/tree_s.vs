#include "common.h"

struct av 
{
	float4 	pos	: POSITION;	// (float,float,float,1)
	float4 	nc	: NORMAL;	// (float,float,float,clr)
	float4 	misc	: TEXCOORD0;	// (u(Q),v(Q),frac,???)
};

struct vf
{
	float4 HPOS	: POSITION;
	float3 COL0	: COLOR0;
	float2 TEX0	: TEXCOORD0;
	float  fog	: FOG;
		float3 fog_pos : TEXCOORD6;
	float  fog_y : TEXCOORD7;
};

uniform float3x4	m_xform;
uniform float4 		consts;		// {1/quant,1/quant,???,???}
uniform float4 		wave; 		// cx,cy,cz,tm
uniform float4 		wind; 		// direction2D
uniform float4		c_bias;		// + color
uniform float4		c_scale;	// * color
uniform float2 		c_sun;		// x=*, y=+

vf main (av v)
{
	vf 		o;

	// Transform to world coords
	float3 	pos	= mul		(m_xform, v.pos);

	// 
	float 	base 	= m_xform._24;			// take base height from matrix
	float 	dp	= calc_cyclic  (wave.w+dot(pos,(float3)wave));
	float 	H 	= pos.y - base;			// height of vertex (scaled, rotated, etc.)
	float 	frac 	= v.misc.z*consts.x;		// fractional (or rigidity)
	float 	inten 	= H * dp;			// intensity
	float2 	result	= calc_xz_wave	(wind.xz*inten, frac);
	float4 	f_pos 	= float4(pos,1);//float4	(pos.x+result.x, pos.y, pos.z+result.y, 1);

	// Calc fog
	o.fog_pos = (f_pos).xyz;
	o.fog_y = (f_pos).y;
	o.fog   = distance((f_pos).xyz, eye_position);

	// Final xform
#ifdef RETRO_MODE
	o.HPOS = snap_to_position(mul(m_VP, f_pos));
#else	
	o.HPOS = mul(m_VP, f_pos); // xform, input in world coords
#endif

	// Lighting
	float3 	N 	= normalize 	(mul (m_xform,  unpack_normal(v.nc)));
	float 	L_base 	= v.nc.w;								// base hemisphere
	float4 	L_unpack= c_scale*L_base+c_bias;						// unpacked and decompressed
	float3 	L_rgb 	= L_unpack.xyz;								// precalculated RGB lighting
	float3 	L_hemi 	= v_hemi_wrap(N,.75f)* L_unpack.w;					// hemisphere
	float3 	L_sun 	= v_sun (N)* (L_base*c_sun.x+c_sun.y);			// sun
	float3 	L_final	= L_rgb + L_hemi + L_sun;
	o.COL0		= L_final;

	// final xform, color, tc
	o.TEX0.xy	= (v.misc * consts).xy;

	return o;
}







