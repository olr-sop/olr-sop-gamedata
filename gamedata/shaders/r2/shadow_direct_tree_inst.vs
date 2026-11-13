#include "common.h"

uniform float4 			consts; 	// {1/quant,1/quant,???,???}
uniform float4 			wind,wave;

// [OLR] instanced tree shadow caster: stream 1 = world 3x4 rows
v_shadow_direct_aref 	main	( v_tree I, float4 m0 : TEXCOORD4, float4 m1 : TEXCOORD5, float4 m2 : TEXCOORD6 )
{
	v_shadow_direct_aref 	O;

	float3x4	M	= { m0, m1, m2 };

	// Transform to world coords
	float3 	pos	= mul		(M , I.P);

	//
	float 	base 	= m1.w;			// take base height from matrix
	float 	dp		= calc_cyclic  (wave.w+dot(pos,(float3)wave));
	float 	H 		= pos.y - base;			// height of vertex (scaled, rotated, etc.)
	float 	frac 	= I.tc.z*consts.x;		// fractional (or rigidity)
	float 	inten 	= H * dp;			// intensity
	float2 	result	= calc_xz_wave	(wind.xz*inten, frac);
#ifdef		USE_TREEWAVE
			result	= 0;
#endif
	float4 	f_pos 	= float4(pos.x+result.x, pos.y, pos.z+result.y, 1);

	O.hpos 	= mul		(m_VP,	f_pos	);
	O.tc0 	= (I.tc * consts).xy;		//	+ result;
#ifndef USE_HWSMAP
	O.depth = O.hpos.z;
#endif
	return	O;
}
FXVS;
