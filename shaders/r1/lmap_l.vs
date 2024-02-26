#include "common.h"

struct vf
{
	float4 hpos	: POSITION;
	float2 tc0	: TEXCOORD0;
	float2 tc1	: TEXCOORD1;
	float3 c0	: COLOR0;
};

vf main (v_lmap v)
{
	vf 		o;

	
	o.hpos 		= mul			(m_VP, v.P);		// xform, input in world coords
	o.tc0		= unpack_tc_lmap	(v.uv1);			// copy tc 
	o.tc1 		= o.tc0			;
#if R1_FUCKUP_LEVEL == 1 || R1_FUCKUP_LEVEL == 2
	o.c0		= L_hemi_color*v.N.w + L_ambient;		// hemisphere + ambient
#else
	o.c0		= v_hemi(unpack_normal(v.N));			// just hemisphere
#endif

	return o;
}
