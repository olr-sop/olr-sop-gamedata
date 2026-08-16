#include "common.h"
//Fixed glows by skyloader
struct	v_TL
{
	float4	P	: POSITION;
	float2	Tex0	: TEXCOORD0;
	float4	Color	: COLOR; 
};

struct	v2p_TL
{
	float2 	Tex0	: TEXCOORD0;
	float4	Color	: COLOR;
	float4 	HPos	: POSITION;	// Clip-space position 	(for rasterization)
	float4 tctexgen	: TEXCOORD1;
};

//////////////////////////////////////////////////////////////////////////////////////////
// Vertex
v2p_TL main ( v_TL I )
{
	v2p_TL O;

	O.HPos = mul(m_VP, I.P);
	O.Tex0 = I.Tex0;
	O.Color = I.Color;
	O.tctexgen 	= mul( mVPTexgen, I.P);
	O.tctexgen.z	= O.HPos.z;

 	return O;
}