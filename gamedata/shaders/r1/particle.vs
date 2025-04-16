#include "common.h"

struct vv
{
	float4 P	: POSITION;
	float2 tc	: TEXCOORD0;
	float4 c	: COLOR0;
};
struct vf
{
	float4 hpos	: POSITION;
	float2 tc	: TEXCOORD0;
	float4 c	: COLOR0;
	float  fog	: FOG;
};

vf main (vv v)
{
	vf 		o;

#ifdef RETRO_MODE
	o.hpos = snap_to_position(mul(m_WVP, v.P));
	if (affine_mapping)	
		o.hpos /= abs(o.hpos.w);
#else	
	o.hpos = mul(m_WVP, v.P); // xform, input in world coords
#endif
	
	o.tc		= v.tc;				// copy tc
	o.c		= v.c;				// copy color
	o.fog 		= calc_fogging (v.P);		// fog, input in world coords

	return o;
}
