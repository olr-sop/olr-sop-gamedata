#include "common.h"
#include "skin.h"

struct vf {
	float4 hpos	: POSITION;
	float2 tc0	: TEXCOORD0;	// base
	float3 tc1	: TEXCOORD1;	// environment
	float4 c0	: COLOR0;		// color.(fog)
	float  fog	: FOG;
	float  riml	: TEXCOORD2;
};

#define EDGE_INTENSITY 1.2
#define EDGE_POWER 2.1

vf	_main (v_model v) {
	vf 		o;

	float4 pos		= v.P;
	float3 pos_w 	= mul(m_W, pos);
	float3 eye_dir	= normalize(eye_position - pos_w);
	float3 norm_w 	= normalize(mul(m_W,v.N));
	float rim		= 1.0 - saturate(dot(norm_w, eye_dir));

	o.hpos 		= mul(m_WVP, pos); // xform, input in world coords

	o.tc0		= v.tc.xy;					// copy tc
	o.tc1		= calc_reflection(pos_w, norm_w);
	o.fog 		= saturate(calc_fogging(float4(pos_w,1)));	// fog, input in world coords
	o.c0 		= float4(calc_model_lq_lighting(norm_w), o.fog );
	
	float edge_factor = pow(saturate(rim * EDGE_INTENSITY), EDGE_POWER);
	o.riml		= edge_factor;

	return o;
}

/////////////////////////////////////////////////////////////////////////
#ifdef 	SKIN_NONE
vf	main(v_model v) 		{ return _main(v); 		}
#endif

#ifdef 	SKIN_0
vf	main(v_model_skinned_0 v) 	{ return _main(skinning_0(v)); }
#endif

#ifdef	SKIN_1
vf	main(v_model_skinned_1 v) 	{ return _main(skinning_1(v)); }
#endif

#ifdef	SKIN_2
vf	main(v_model_skinned_2 v) 	{ return _main(skinning_2(v)); }
#endif

#ifdef	SKIN_3
vf	main(v_model_skinned_3 v) 	{ return _main(skinning_3(v)); }
#endif

#ifdef	SKIN_4
vf	main(v_model_skinned_4 v) 	{ return _main(skinning_4(v)); }
#endif
