#include "common.h"

struct vf
{
	float4 hpos	: POSITION;
	float2 tc0	: TEXCOORD0;		// base
	float4 c0	: COLOR0;		// color
	float   fog:        FOG;		// fog		
};

vf main (v_static v)
{
	vf 		o;

	o.hpos 		= mul			(m_WVP, v.P);		// xform, input in world coords
	o.tc0		= unpack_tc_base	(v.tc,v.T.w,v.B.w);	// copy tc

	// calculate fade
	float3  dir_v 	= normalize		(mul(m_WV,v.P));
	float3 	norm_v 	= normalize 		(mul(m_WV,unpack_normal(v.Nh)));
	float 	fade 	= abs			(dot(dir_v,norm_v));
	o.c0		= fade;
	
	// calculate fog
	float3  pos_w 	= mul( m_W, v.P );
	o.fog 			= saturate(calc_fogging( float4( pos_w, 1 ) ));	// fog, input in world coords	

	return o;
}
