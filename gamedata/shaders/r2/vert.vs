#include "common.h"

struct vf
{
	float4 hpos	: POSITION;
	float2 tc0	: TEXCOORD0;
	float4 c0	: COLOR0;		// c0=all lighting
	float3 fog_pos	: TEXCOORD1;	// world position for per-pixel fog
};

vf main (v_static v)
{
	vf 		o;

	float3 	N 	= unpack_normal		(v.Nh);
	o.hpos 		= mul				(m_VP, v.P);			// xform, input in world coords
	o.tc0		= unpack_tc_base	(v.tc,v.T.w,v.B.w);		// copy tc

	float3 	L_rgb 	= v.color.xyz;						// precalculated RGB lighting
	float3 	L_hemi 	= v_hemi(N)*v.Nh.w;					// hemisphere
	float3 	L_sun 	= v_sun(N)*v.color.w;					// sun
	float3 	L_final	= L_rgb + L_hemi + L_sun + L_ambient;

	o.c0		= float4(L_final, 1.0f);
	o.fog_pos	= v.P.xyz;					// world position for per-pixel fog

	return o;
}
