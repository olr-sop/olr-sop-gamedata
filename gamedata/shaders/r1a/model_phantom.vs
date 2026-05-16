#include "common.h"
#include "skin.h"

struct vf {
	float4 hpos	: POSITION;
	float2 tc0	: TEXCOORD0;	// base
	float3 tc1	: TEXCOORD1;	// environment
	float3 c0	: COLOR0;		// color
	float  fog	: FOG;
	float  riml	: TEXCOORD2;
};

#define EDGE_INTENSITY 1.2
#define EDGE_POWER 2.1

vf	_main (v_model v) {
	vf 		o;

	float4 	pos 	= v.pos;
	float3  pos_w 	= mul			(m_W, pos);
	float3 eye_dir = normalize(eye_position - pos_w);
	float3 	norm_w 	= normalize 	(mul(m_W,v.norm));
	float rim = 1.0 - saturate(dot(norm_w, eye_dir));

#ifdef RETRO_MODE
	o.hpos = snap_to_position(mul(m_WVP, pos));
#else	
	o.hpos = mul(m_WVP, pos); // xform, input in world coords
#endif

	o.tc0		= v.tc.xy;					// copy tc
	o.tc1		= calc_reflection	(pos_w, norm_w);
	o.c0 		= calc_model_lq_lighting(norm_w);
	o.fog 		= calc_fogging 		(float4(pos_w,1));	// fog, input in world coords
	
	float edge_factor = pow(saturate(rim * EDGE_INTENSITY), EDGE_POWER);
	o.riml		= edge_factor;

#ifdef SKIN_COLOR
	o.c0.rgb	*= v.rgb_tint;
#endif
	return o;
}

/////////////////////////////////////////////////////////////////////////
#define SKIN_LQ
#define SKIN_VF vf
#include "skin_main.h"