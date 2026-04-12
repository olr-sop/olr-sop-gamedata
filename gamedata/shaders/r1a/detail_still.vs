#include "common.h"

struct vf
{
	float4 hpos	: POSITION;
	float4 C	: COLOR0;
	float2 tc	: TEXCOORD0;
	float fog : FOG;
	float3 fog_pos : TEXCOORD6;
};

uniform float4 		consts; // {1/quant,1/quant,diffusescale,ambient}
uniform float4 		array	[200] : register(c10);

vf main (v_detail v)
{
	vf 		o;

	// index
	int 	i 	= v.misc.w;
	float4  m0 	= array[i+0];
	float4  m1 	= array[i+1];
	float4  m2 	= array[i+2];
	float4  c0 	= array[i+3];

	// Transform to world coords
	float4 	pos;
  	pos.x 		= dot	(m0, v.pos);
  	pos.y 		= dot	(m1, v.pos);
  	pos.z 		= dot	(m2, v.pos);
	pos.w 		= 1;

	// Final out
#ifdef RETRO_MODE
	o.hpos = snap_to_position(mul(m_WVP, pos));
#else	
	o.hpos = mul(m_WVP, pos); // xform, input in world coords
#endif
	
	o.C		= c0;
	o.tc.xy		= (v.misc * consts).xy;
	o.fog		= calc_fogging	(pos);
	o.fog_pos	= pos.xyz;

	return o;
}







