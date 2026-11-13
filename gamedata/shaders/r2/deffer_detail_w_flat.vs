#include "common.h"

uniform float4 		consts; // {1/quant,1/quant,diffusescale,ambient}
uniform float4 		wave; 	// cx,cy,cz,tm
uniform float4 		dir2D; 
uniform float4 		array	[200] : register(c12);

p_flat 	main (v_detail v)
{
	p_flat 		O;
	// [OLR] G5a: 2 float4 на инстанс - (cos*s, sin*s, s, ox) и (oy, oz, sun, hemi).
	// Инстансы травы всегда чистый поворот вокруг Y + равномерный масштаб.
	int 	i 	= v.misc.w;
	float4  r0 	= array[i+0];
	float4  r1 	= array[i+1];

	// Transform pos to world coords (Y-rotation + uniform scale + origin)
	float4 	pos;
	pos.x 		= r0.x*v.pos.x + r0.y*v.pos.z + r0.w;
	pos.y 		= r0.z*v.pos.y + r1.x;
	pos.z 		= r0.x*v.pos.z - r0.y*v.pos.x + r1.y;
	pos.w 		= 1;

	// 
	float 	base 	= r1.x;
	float 	dp	= calc_cyclic   (dot(pos,wave));
	float 	H 	= pos.y - base;			// height of vertex (scaled)
	float 	frac 	= v.misc.z*consts.x;		// fractional
	float 	inten 	= H * dp;
	float2 	result	= calc_xz_wave	(dir2D.xz*inten,frac);
	pos		= float4(pos.x+result.x, pos.y, pos.z+result.y, 1);

	// Normal in world coords
	float3 	norm;	//	= float3(0,1,0);
		norm.x 	= pos.x - r0.w	;
		norm.y 	= pos.y - r1.x	+ .75f;	// avoid zero
		norm.z	= pos.z - r1.y	;

	// Final out
	float4	Pp 	= mul		(m_WVP,	pos				);
	O.hpos 		= Pp;
	O.N 		= mul		(m_WV,  normalize(norm)	);
	float3	Pe	= mul		(m_WV,  pos				);
//	O.tcdh 		= float4	((v.misc * consts).xy	);
	O.tcdh 		= float4	((v.misc * consts).xyyy );

# if defined(USE_R2_STATIC_SUN)
	O.tcdh.w	= r1.z;								// (,,,dir-occlusion)
# endif
	O.position	= float4	(Pe, 		r1.w		);

	return O;
}
FXVS;
