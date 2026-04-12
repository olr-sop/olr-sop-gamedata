#include "common.h"

struct vf
{
	float4 hpos	: POSITION;
	float4 c	: COLOR0;
	float  fog	: FOG;
	float3 fog_pos : TEXCOORD6;
};

vf main (v_vert v)
{
	vf 		o;

#ifdef RETRO_MODE
	o.hpos = snap_to_position(mul(m_VP, v.P));
#else	
	o.hpos = mul(m_VP, v.P); // xform, input in world coords
#endif	
	
	o.c 		= v.color;
	o.fog		= calc_fogging	(v.P);
	o.fog_pos	= 	v.P.xyz;

	return o;
}







