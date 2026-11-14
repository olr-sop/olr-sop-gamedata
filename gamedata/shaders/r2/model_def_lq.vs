#include "common.h"
#include "skin.h"

struct vf
{
    float4 hpos : POSITION;
    float2 tc0  : TEXCOORD0;   // base
    float3 c0   : COLOR0;      // color
    float3 fog_pos : TEXCOORD1; // world position for per-pixel fog
};

vf 	_main (v_model v)
{
	vf 		o;

	float4 	pos 	= v.P;
	float3	pos_w	= mul(m_W, pos).xyz;
	float3 	norm_w 	= normalize 		(mul(m_W,v.N));

	o.hpos 		= mul			(m_WVP, pos);		// xform, input in world coords
	o.tc0		= v.tc.xy;					// copy tc
	o.c0 		= calc_model_lq_lighting(norm_w);
	o.fog_pos	= pos_w;
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