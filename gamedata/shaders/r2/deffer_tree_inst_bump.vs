#include "common.h"

uniform float4 		consts; 	// {1/quant,1/quant,???,???}
uniform float4 		wind,wave;

// [OLR] instanced tree: stream 1 = (world 3x4 rows) + (s*c_scale.hemi, s*c_bias.hemi, s*c_scale.sun, s*c_bias.sun)
p_bumped 	main 	(v_tree I, float4 m0 : TEXCOORD4, float4 m1 : TEXCOORD5, float4 m2 : TEXCOORD6, float4 c : TEXCOORD7)
{
	float3x4	M	= { m0, m1, m2 };
	// m_V is 3x4 (view^T); extend to 4x4 and build MV = M * V, matching
	// the engine's m_xform_v = transpose(view * xform).
	float4x4	M4	= { m0, m1, m2, float4(0,0,0,1) };
	float4x4	V4	= { m_V[0], m_V[1], m_V[2], float4(0,0,0,1) };
	float4x4	MV4	= mul(M4, V4);
	float3x4	MV	= { MV4[0], MV4[1], MV4[2] };

	// Transform to world coords
	float3 	pos		= mul			(M, I.P);

	//
	float 	base 	= m1.w	;		// take base height from matrix
	float 	dp		= calc_cyclic  	(wave.w+dot(pos,(float3)wave));
	float 	H 		= pos.y - base	;		// height of vertex (scaled, rotated, etc.)
	float 	frac 	= I.tc.z*consts.x;		// fractional (or rigidity)
	float 	inten 	= H * dp;				// intensity
	float2 	result	= calc_xz_wave	(wind.xz*inten, frac);
#ifdef		USE_TREEWAVE
			result	= 0;
#endif
	float4 	w_pos 	= float4(pos.x+result.x, pos.y, pos.z+result.y, 1);
	float2 	tc 		= (I.tc * consts).xy;
	float 	hemi 	= I.Nh.w * c.x + c.y;

	// Eye-space pos/normal
	p_bumped 		O;
	float3	Pe		= mul		(m_V,  	w_pos		);
	O.tcdh 			= float4	(tc.xyyy			);
	O.hpos 			= mul		(m_VP,	w_pos		);
	O.position		= float4	(Pe, 	hemi		);

#if defined(USE_R2_STATIC_SUN) && !defined(USE_LM_HEMI)
	float 	suno 	= I.Nh.w * c.z + c.w	;
	O.tcdh.w		= suno;					// (,,,dir-occlusion)
#endif

	// Calculate the 3x3 transform from tangent space to eye-space
	float3 	N 		= unpack_bx4(I.Nh);	// just scale (assume normal in the -.5f, .5f)
	float3 	T 		= unpack_bx4(I.T);	//
	float3 	B 		= unpack_bx4(I.B);	//
	float3x3 xform	= mul	((float3x3)MV, float3x3(
						T.x,B.x,N.x,
						T.y,B.y,N.y,
						T.z,B.z,N.z
					));

	// Feed this transform to pixel shader
	O.M1 			= xform[0];
	O.M2 			= xform[1];
	O.M3 			= xform[2];

#ifdef 	USE_PARALLAX
	O.eye 			= mul		(float3x3(T,B,N),-(w_pos - eye_position));
#endif

#ifdef 	USE_TDETAIL
	O.tcdbump		= O.tcdh * dt_params;		// dt tc
#endif

	return O;
}
FXVS;
