#include "common.h"
#include "shared\wmark.h"

struct vf
{
	float4 hpos	: POSITION;
	float2 tc0	: TEXCOORD0;
	float3 c0	: COLOR0;		// c0=all lighting
	float  fog	: FOG;
	float3 fog_pos : TEXCOORD6;
};

vf main (v_vert v)
{
	vf 		o;

	float3 	N 	= 	unpack_normal	(v.N);
	float4 	P 	= 	wmark_shift		(v.P,N);
	float4	P_w4	= mul			(m_W, P);
	float3	pos_w	= P_w4.xyz;
	
#ifdef RETRO_MODE
	o.hpos = snap_to_position(mul(m_VP, P));
#else	
	o.hpos = mul(m_VP, P); // xform, input in world coords
#endif

	o.tc0		= 	unpack_tc_base	(v.uv,v.T.w,v.B.w);		// copy tc

	float3 		L_rgb 	= v.color.xyz;						// precalculated RGB lighting
	float3 		L_hemi 	= v_hemi(N)*v.N.w;					// hemisphere
	float3 		L_sun 	= v_sun(N)*v.color.w;				// sun
	float3 		L_final	= L_rgb + L_hemi + L_sun + L_ambient;

	o.c0		= 	L_final;
	o.fog		= 	calc_fogging	(P_w4);
	o.fog_pos	= 	pos_w;

	return o;
}







