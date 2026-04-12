#include "common.h"

struct vf
{
	float4 hpos	: POSITION;
	float2 tc0	: TEXCOORD0;
	float  fog	: FOG;
	float3 fog_pos : TEXCOORD6;
};

vf main (v_vert v)
{
	vf 		o;
	
#ifdef RETRO_MODE
	o.hpos = snap_to_position(mul(m_VP, v.P));
#else	
	o.hpos = mul(m_VP, v.P); // xform, input in world coords
#endif	
	
	o.tc0		= unpack_tc_base	(v.uv,v.T.w,v.B.w);		// copy tc
	o.fog		= calc_fogging	(v.P);
	o.fog_pos	= 	v.P.xyz;

	return o;
}







