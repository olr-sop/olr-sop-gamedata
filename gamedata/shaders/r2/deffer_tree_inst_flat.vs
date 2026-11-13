#include "common.h"

uniform float4 		consts; 	// {1/quant,1/quant,???,???}
uniform float4 		wind,wave;

// [OLR] instanced tree: stream 1 = (world 3x4 rows) + (s*c_scale.hemi, s*c_bias.hemi, s*c_scale.sun, s*c_bias.sun)
p_flat 	main 	(v_tree I, float4 m0 : TEXCOORD4, float4 m1 : TEXCOORD5, float4 m2 : TEXCOORD6, float4 c : TEXCOORD7)
{
	p_flat 		o;

	float3x4	M	= { m0, m1, m2 };
	// m_V is 3x4 (view^T); extend to 4x4 and build MV = M * V, matching
	// the engine's m_xform_v = transpose(view * xform).
	float4x4	M4	= { m0, m1, m2, float4(0,0,0,1) };
	float4x4	V4	= { m_V[0], m_V[1], m_V[2], float4(0,0,0,1) };
	float4x4	MV4	= mul(M4, V4);
	float3x4	MV	= { MV4[0], MV4[1], MV4[2] };

	// Transform to world coords
	float3 	pos		= mul		(M, I.P);

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

	// Final xform(s)
	float3	Pe		= mul		(m_V,  f_pos				);
	float 	hemi 	= I.Nh.w*c.x + c.y;
	o.hpos			= mul		(m_VP, f_pos				);
	o.N 			= mul		((float3x3)MV, unpack_bx2(I.Nh)	);
	o.tcdh 			= float4	((I.tc * consts).xyyy		);
	o.position		= float4	(Pe, hemi					);

#if defined(USE_R2_STATIC_SUN) && !defined(USE_LM_HEMI)
	float 	suno 	= I.Nh.w * c.z + c.w	;
	o.tcdh.w		= suno;			// (,,,dir-occlusion)
#endif

	#ifdef USE_TDETAIL
	o.tcdbump	= o.tcdh*dt_params;					// dt tc
	#endif

	return o;
}
FXVS;
