#include "common.h"

struct vf
{
	float4 hpos	: POSITION;
	float2 tc0	: TEXCOORD0;
	float2 tc1	: TEXCOORD1;
	float2 tc2	: TEXCOORD2;
	float4 c0	: COLOR0;		// c0=hemi+v-lights, 	c0.a = dt*
	float4 c1	: COLOR1;		// c1=sun, 		c1.a = dt+
	float  fog	: FOG;
	float3 fog_pos : TEXCOORD6;
};

vf main (v_lmap v)
{
	vf 		o;

	float2 	dt 	= calc_detail		(v.P.xyz);
	float3	N 	= unpack_normal		(v.N);
	
#ifdef RETRO_MODE
	o.hpos = snap_to_position(mul(m_VP, v.P));
#else	
	o.hpos = mul(m_VP, v.P);
#endif
	
	o.tc0		= unpack_tc_base	(v.uv0,v.T.w,v.B.w);
	o.tc1		= o.tc0;
	o.tc2		= o.tc0*dt_params;
	o.c0		= float4 		(v_hemi(N),	dt.x);
	o.c1 		= float4 		(v_sun(N),	dt.y);
	o.fog		= calc_fogging	(v.P);
	o.fog_pos	= v.P.xyz;

	return o;
}







