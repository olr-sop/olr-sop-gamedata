#include "common.h"

struct vf
{
	float4 hpos	: POSITION;
	float2 tc0	: TEXCOORD0;
	float2 tc1	: TEXCOORD1;
	float3 c0	: COLOR0;
	float  fog	: FOG;
};

vf main (v_lmap v)
{
	vf 		o;

	
#ifdef RETRO_MODE
	o.hpos = snap_to_position(mul(m_VP, v.P));
	if (affine_mapping)	
		o.hpos /= abs(o.hpos.w);
#else	
	o.hpos = mul(m_VP, v.P); // xform, input in world coords
#endif

	o.tc0		= unpack_tc_lmap	(v.uv1);			// copy tc 
	o.tc1 		= o.tc0			;
	o.c0		= v_hemi		(unpack_normal(v.N));	// just hemisphere + ambient
	o.fog 		= calc_fogging 		(v.P);				// fog, input in world coords

	return o;
}
