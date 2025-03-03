#include "common.h"

struct vf
{
	float4 hpos	: POSITION;
	float2 tc0	: TEXCOORD0;
	float2 tc1	: TEXCOORD1;
	float2 tch	: TEXCOORD2;
	float2 tc2	: TEXCOORD3;
	float4 c0	: COLOR0;		// c0=hemi+v-lights, 	c0.a = dt*
	float4 c1	: COLOR1;		// c1=sun, 		c1.a = dt+
	float  fog	: FOG;
};

vf main (v_lmap v)
{
	vf 		o;

	float2 	dt 	= calc_detail		(v.P);
	float3	N 	= unpack_normal		(v.N);

	o.hpos 		= mul			(m_VP, v.P);			// xform, input in world coords
	o.tc0		= unpack_tc_base	(v.uv0,v.T.w,v.B.w);		// copy tc
//	o.tc0		= unpack_tc_base	(v.tc0);			// copy tc
	o.tc1		= unpack_tc_lmap	(v.uv1);			// copy tc 
	o.tch 		= o.tc1;
	o.tc2		= o.tc0*dt_params;					// dt tc
	o.fog 		= calc_fogging 		(v.P);				// fog, input in world coords
	
#if R1_FUCKUP_LEVEL == 1 || R1_FUCKUP_LEVEL == 2
	float3  L_hemi  = L_hemi_color*v.N.w+L_ambient;							// hemisphere + ambient
	float3  L_sun 	= L_sun_color*dot(N,-L_sun_dir_w);  // sun
	o.c0		= float4 		(L_hemi,dt.x);			// c0=hemi+v-lights, 	c0.a = dt*
	o.c1 		= float4 		(L_sun,	dt.y);			// c1=sun, 		c1.a = dt+
#else
	o.c0		= float4 		(v_hemi(N),dt.x);		// c0=hemi+v-lights, 	c0.a = dt*
	o.c1 		= float4 		(v_sun(N),dt.y);		// c1=sun, 		c1.a = dt+
#endif

	return o;
}
