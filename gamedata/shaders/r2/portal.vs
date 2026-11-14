#include "common.h"

struct	v_vert
{
	float4 	pos	: POSITION;	// (float,float,float,1)
	float4	color	: COLOR0;	// (r,g,b,dir-occlusion)
};
struct 	vf
{
	float4 hpos	: POSITION;
	float4 c	: COLOR0;
	float3 fog_pos	: TEXCOORD0;	// world position for per-pixel fog
};

vf main (v_vert v)
{
	vf 		o;

	o.hpos 		= mul(m_VP, v.pos);				// xform, input in world coords
	o.c 		= v.color;
	o.fog_pos	= v.pos.xyz;					// world position for per-pixel fog

	return o;
}
