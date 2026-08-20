#include "common.h"
//Fixed glows by skyloader
struct vv
{
	float4	P	: POSITION;
	float2	Tex0	: TEXCOORD0;
	float4	Color	: COLOR; 
};

struct	v2p
{
	float2 	Tex0	: TEXCOORD0;
	float4 tctexgen	: TEXCOORD1;
	float4	Color	: COLOR;
	float4 	HPos	: POSITION;	// Clip-space position 	(for rasterization)
};

//////////////////////////////////////////////////////////////////////////////////////////
// Vertex
//////////////////////////////////////////////////////////////////////////////////////////
v2p main ( vv I )
{
	v2p		O;

	O.HPos 		= mul(m_VP, I.P);		// xform, input in world coords
	O.Tex0 		= I.Tex0;			// copy tc
	O.Color 	= I.Color;			// copy color
	O.tctexgen	= mul( mVPTexgen, I.P);
	O.tctexgen.z	= O.HPos.z;

 	return O;
}