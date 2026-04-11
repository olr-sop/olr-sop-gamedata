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
	float3 fog_pos : TEXCOORD6;
	float  fog_y : TEXCOORD7;
};

vf main (vv v)
{
	vf 		o;

#ifdef RETRO_MODE
	o.hpos = snap_to_position(mul(m_WVP, v.P));
#else	
	o.hpos = mul(m_WVP, v.P); // xform, input in world coords
#endif
	
	o.tc		= v.tc;				// copy tc
	o.c		= v.c;				// copy color
	o.fog_pos = (v.P).xyz;
	o.fog_y = (v.P).y;
	o.fog   = distance((v.P).xyz, eye_position);		// fog, input in world coords

	return o;
}







