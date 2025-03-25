#include "common.h"
#include "skin.h"

struct vf_spot
{
	float4 hpos	: POSITION;
	float2 tc0	: TEXCOORD0;		// base
	float2 tc1	: TEXCOORD1;		// base
	float2 tc2	: TEXCOORD2;		// base
	float4 c0	: COLOR0;		// color
};

vf_spot _main (v_model v)
{
	vf_spot		o;

	float4 	pos 	= v.P;
	float3  pos_w 	= mul			(m_W, pos);
	float4  pos_w4 	= float4		(pos_w,1);
	float3 	norm_w 	= normalize 		(mul(m_W,v.N));

	o.hpos 		= mul			(m_WVP, pos);			// xform, input in world coords
	o.tc0		= v.tc.xy;						// copy tc
	o.c0		= calc_spot 		(o.tc1,o.tc2,pos_w4,norm_w);	// just hemisphere

	return o;
}

/////////////////////////////////////////////////////////////////////////
#ifdef 	SKIN_NONE
vf	main_vs_2_0(v_model v) 		{ return _main(v); 		}
#endif

#ifdef 	SKIN_0
vf	main_vs_2_0(v_model_skinned_0 v) 	{ return _main(skinning_0(v)); }
#endif

#ifdef	SKIN_1
vf	main_vs_2_0(v_model_skinned_1 v) 	{ return _main(skinning_1(v)); }
#endif

#ifdef	SKIN_2
vf	main_vs_2_0(v_model_skinned_2 v) 	{ return _main(skinning_2(v)); }
#endif