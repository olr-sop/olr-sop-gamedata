#include "common.h"

struct vf
{
	float4 hpos	: POSITION;
	float2 tc0	: TEXCOORD0;
	float  fog	: FOG;
};

vf main (v_vert v)
{
	vf 		o;
	
#ifdef RETRO_MODE
	o.hpos = snap_to_position(mul(m_VP, v.P));
	if (affine_mapping)	
		o.hpos /= abs(o.hpos.w);
#else	
	o.hpos = mul(m_VP, v.P); // xform, input in world coords
#endif	
	
	o.tc0		= unpack_tc_base	(v.uv,v.T.w,v.B.w);		// copy tc
	o.fog 		= calc_fogging 		(v.P);				// fog, input in world coords

	return o;
}
