#include "common.h"

struct vf
{
	float4 hpos	: POSITION	;
	float4 C 	: COLOR0	;
};

uniform float4 		tfactor;
vf main (float4	P:POSITION)
{
	vf 		o;

#ifdef RETRO_MODE
	o.hpos = snap_to_position(mul(m_WVP, P));
#else	
	o.hpos = mul(m_WVP, P); // xform, input in world coords
#endif
	
	o.C 		= tfactor;

	return o;
}
