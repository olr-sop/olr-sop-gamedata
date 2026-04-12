#include "common.h"

struct vf
{
	float4 hpos	: POSITION;
	float  fog	: FOG;
	float3 fog_pos : TEXCOORD6;
	float  fog_y   : TEXCOORD7;
};

vf main(v_vert v)
{
	vf o;

#ifdef RETRO_MODE
	o.hpos = snap_to_position(mul(m_WVP, v.P));
#else
	o.hpos = mul(m_WVP, v.P);
#endif

	o.fog = calc_fogging(v.P);
	o.fog_pos = v.P.xyz;
	o.fog_y = v.P.y;

	return o;
}
