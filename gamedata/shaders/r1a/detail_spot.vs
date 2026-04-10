#include "common.h"

struct av  {
	float4 	pos		: POSITION;
	float4 	nc		: NORMAL;
	float4 	misc	: TEXCOORD0;
};

uniform float3x4	m_xform;
uniform float4 		consts;		// {1/quant,1/quant,???,???}
uniform float4 		wave; 		// cx,cy,cz,tm
uniform float4 		wind; 		// direction2D
uniform float4		c_bias;		// + color
uniform float4		c_scale;	// * color
uniform float2 		c_sun;		// x=*, y=+

vf_spot main (av v) {
	vf_spot		o;

	// Transform to world coords
	float3 	pos	= mul	(m_xform, v.pos);
	float 	base 	= m_xform._24;			// take base height from matrix
	float 	dp	= calc_cyclic(wave.w+dot(pos,(float3)wave));
	float 	H 	= pos.y - base;				// height of vertex (scaled, rotated, etc.)
	float 	frac 	= v.misc.z*consts.x;	// fractional (or rigidity)
	float 	inten 	= H * dp;				// intensity
	float2 	result	= calc_xz_wave	(wind.xz*inten, frac);
	float4 	f_pos 	= float4(pos.x+result.x, pos.y, pos.z+result.y, 1);
	float3 	f_N 	= normalize(mul (m_xform,  unpack_normal(v.nc)));

#ifdef RETRO_MODE
	o.hpos = snap_to_position(mul(m_VP, f_pos));
#else	
	o.hpos = mul(m_VP, f_pos); // xform, input in world coords
#endif

	o.tc0		= (v.misc * consts).xy;
	o.color		= calc_spot(o.tc1,o.tc2,f_pos,f_N);

	return o;
}




