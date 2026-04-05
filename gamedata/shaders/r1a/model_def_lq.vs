#include "common.h"
#include "skin.h"

struct vf
{
	float4 hpos	: POSITION;
	float2 tc0	: TEXCOORD0;		// base
	float3 c0	: COLOR0;		// color
	float  fog	: FOG;
		float3 fog_pos : TEXCOORD6;
	float  fog_y : TEXCOORD7;
};

vf 	_main (v_model v)
{
	vf 		o;

	float4 	pos 	= v.pos;
	float3  pos_w 	= mul			(m_W, pos);
	float3 	norm_w 	= normalize 		(mul(m_W,v.norm));

#ifdef RETRO_MODE
	o.hpos = snap_to_position(mul(m_WVP, pos));
#else	
	o.hpos = mul(m_WVP, pos); // xform, input in world coords
#endif

	o.tc0		= v.tc.xy;					// copy tc
	o.c0 		= calc_model_lq_lighting(norm_w);
	o.fog_pos = (float4(pos_w,1)).xyz;
	o.fog_y = (float4(pos_w,1)).y;
	o.fog   = distance((float4(pos_w,1)).xyz, eye_position);	// fog, input in world coords

#ifdef SKIN_COLOR
	o.c0.rgb	*= v.rgb_tint;
#endif

	return o;
}

/////////////////////////////////////////////////////////////////////////
#define SKIN_LQ
#define SKIN_VF vf
#include "skin_main.h"





