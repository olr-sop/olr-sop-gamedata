#include "common.h"

struct vf
{
	float4 hpos	: POSITION;
	float2 tc0	: TEXCOORD0;		// base
	float4 c0	: COLOR0;		// color
};

vf main (v_vert v)
{
	vf 		o;
	
#ifdef RETRO_MODE
		o.hpos = snap_to_position(mul(m_WVP, v.P));
#else	
	o.hpos = mul(m_WVP, v.P); // xform, input in world coords
#endif

	o.tc0		= unpack_tc_base	(v.uv,v.T.w,v.B.w);	// copy tc

	// calculate fade
	float3  dir_v 	= normalize		(mul(m_WV,v.P));
	float3 	norm_v 	= normalize 		(mul(m_WV,unpack_normal(v.N)));
	float 	fade 	= abs			(dot(dir_v,norm_v));
	o.c0		= fade;

	return o;
}




