#include "common.h"
#include "skin.h"

struct vf
{
	float4	hpos	: POSITION;
	float4 	c0	: COLOR0;		// color
};

vf 	_main 	(v_model v)
{
	vf 		o;

#ifdef RETRO_MODE
	o.hpos = snap_to_position(mul(m_WVP, v.pos));
#else	
	o.hpos = mul(m_WVP, v.pos); // xform, input in world coords
#endif

	o.c0 		= 0;
	return o;
}

/////////////////////////////////////////////////////////////////////////
#define SKIN_LQ
#define SKIN_VF vf
#include "skin_main.h"