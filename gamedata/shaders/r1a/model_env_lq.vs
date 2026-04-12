#include "common.h"
#include "skin.h"

struct 	vf
{
	float4 hpos	: POSITION;
	float2 tc0	: TEXCOORD0;		// base
	float3 tc1	: TEXCOORD1;		// environment
	float3 c0	: COLOR0;		// color
	float  fog	: FOG;
	float3 fog_pos : TEXCOORD6;
};

vf 	_main (v_model v)
{
	vf 		o;

	float4 	pos 	= v.pos;
	float3  pos_w 	= mul			(m_W, pos);
	float4  pos_w4 	= float4		(pos_w,1);
	float3 	norm_w 	= normalize 		(mul(m_W,v.norm));

#ifdef RETRO_MODE
	o.hpos = snap_to_position(mul(m_WVP, pos));
#else	
	o.hpos = mul(m_WVP, pos); // xform, input in world coords
#endif

	o.tc0		= v.tc.xy;					// copy tc
	o.tc1		= calc_reflection	(pos_w, norm_w);
	o.c0 		= calc_model_lq_lighting(norm_w);
	o.fog		= calc_fogging	(pos_w4);
	o.fog_pos	= pos_w;

#ifdef SKIN_COLOR
	o.c0.rgb	*= v.rgb_tint	;
#endif
	return o;
}

/////////////////////////////////////////////////////////////////////////
#define SKIN_LQ
#define SKIN_VF vf
#include "skin_main.h"





