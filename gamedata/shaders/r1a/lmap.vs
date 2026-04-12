#include "common.h"

struct vf
{
	float4 hpos	: POSITION;
	float2 tc0	: TEXCOORD0;
	float2 tc1	: TEXCOORD1;
	float2 tch	: TEXCOORD2;
	float3 c0	: COLOR0;		// c0=hemi+v-lights, 	c0.a = dt*
	float3 c1	: COLOR1;		// c1=sun, 		c1.a = dt+
	float  fog	: FOG;
	float3 fog_pos : TEXCOORD6;
};

vf main (v_lmap v)
{
	vf 		o;

	float3	N 	= unpack_normal		(v.N);
	
#ifdef RETRO_MODE
	o.hpos = snap_to_position(mul(m_VP, v.P));
#else	
	o.hpos = mul(m_VP, v.P);
#endif

	o.tc0		= unpack_tc_base	(v.uv0,v.T.w,v.B.w);
	o.tc1		= unpack_tc_lmap	(v.uv1);
	o.tch 		= o.tc1;
	o.c0		= v_hemi(N);
	o.c1 		= v_sun(N);
	o.fog		= calc_fogging	(v.P);
	o.fog_pos	= v.P.xyz;

	return o;
}







