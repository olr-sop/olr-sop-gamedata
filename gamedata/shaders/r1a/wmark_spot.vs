#include "common.h"
#include "shared\wmark.h"

vf_spot main 	(v_vert v)
{
	vf_spot 	o;

	float3 	N 	= 	unpack_normal	(v.N);
	float4 	P 	= 	wmark_shift		(v.P,N);
	
#ifdef RETRO_MODE
	o.hpos = snap_to_position(mul(m_VP, P));
#else	
	o.hpos = mul(m_VP, P); // xform, input in world coords
#endif

	o.tc0		= 	unpack_tc_base	(v.uv,v.T.w,v.B.w);		// copy tc
	o.color		= 	calc_spot 		(o.tc1,o.tc2,P,N);		// just hemisphere

	return 		o;
}




