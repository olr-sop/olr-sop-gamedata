#include "common.h"

struct vi
{
	float4	p	: POSITION;
	float4	c	: COLOR0;
	float3	tc0	: TEXCOORD0;
	float3	tc1	: TEXCOORD1;
};

struct vf
{
	float4 	hpos	: POSITION;
	float4	c	: COLOR0;
	float3	tc0	: TEXCOORD0;
	float3	tc1	: TEXCOORD1;
};

vf main (vi v)
{
	vf 		o;

	float4 tpos = mul(1000, v.p);
	
#ifdef RETRO_MODE
	o.hpos = snap_to_position(mul(m_WVP, tpos));
	o.hpos.z = o.hpos.w;
#else	
	o.hpos = mul(m_WVP, tpos); // xform, input in world coords
	o.hpos.z = o.hpos.w;
#endif	
	
	o.c		= v.c;				// copy color
	o.tc0		= v.tc0;			// copy tc
	o.tc1		= v.tc1;			// copy tc

	return o;
}
