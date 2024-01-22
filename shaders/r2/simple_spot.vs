#include "common.h"


struct 	v_lmap
{
	float4 	hpos	: POSITION;	// (float,float,float,1)
	float4	N	: NORMAL;	// (nx,ny,nz,hemi occlusion)
	float2 	tc0	: TEXCOORD0;	// (base)
	float2	tc1	: TEXCOORD1;	// (lmap/compressed)
};

vf_spot main (v_lmap v)
{
	vf_spot		o;

	o.hpos 		= mul		(m_VP, v.P);					// xform, input in world coords
	o.tc0		= unpack_tc_base(v.tc0);					// copy tc
	o.c0		= calc_spot 	(o.tc1,o.tc2,v.P,unpack_normal(v.N));	// just hemisphere

	return o;
}