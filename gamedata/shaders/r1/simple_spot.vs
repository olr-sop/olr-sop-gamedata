#include "common.h"

vf_spot main (v_lmap v)
{
	vf_spot		o;

#ifdef RETRO_MODE
	o.hpos = snap_to_position(mul(m_VP, v.P));
	if (affine_mapping)	
		o.hpos /= abs(o.hpos.w);
#else	
	o.hpos = mul(m_VP, v.P); // xform, input in world coords
#endif

	o.tc0		= unpack_tc_base	(v.uv0,v.T.w,v.B.w);		// copy tc
	o.color		= calc_spot 	(o.tc1,o.tc2,v.P,unpack_normal(v.N));	// just hemisphere

	return o;
}
