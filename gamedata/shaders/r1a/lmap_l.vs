#include "common.h"

struct vf
{
	float4 hpos	: POSITION;
	float2 tc0	: TEXCOORD0;
	float2 tc1	: TEXCOORD1;
	float3 c0	: COLOR0;
	float  fog	: FOG;
		float3 fog_pos : TEXCOORD6;
	float  fog_y : TEXCOORD7;
};

vf main (v_lmap v)
{
	vf 		o;

	
#ifdef RETRO_MODE
	o.hpos = snap_to_position(mul(m_VP, v.P));
#else	
	o.hpos = mul(m_VP, v.P); // xform, input in world coords
#endif

	o.tc0		= unpack_tc_lmap	(v.uv1);			// copy tc 
	o.tc1 		= o.tc0			;
	o.c0		= v_hemi		(unpack_normal(v.N));	// just hemisphere + ambient
	o.fog_pos = (v.P).xyz;
	o.fog_y = (v.P).y;
	o.fog   = distance((v.P).xyz, eye_position);				// fog, input in world coords

	return o;
}







