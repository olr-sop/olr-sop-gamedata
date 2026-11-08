#ifndef	common_iostructs_h_included
#define	common_iostructs_h_included

////////////////////////////////////////////////////////////////
//	This file contains io structs:
//	v_name	:	input for vertex shader.
//	v2p_name:	output for vertex shader.
//	p_name	:	input for pixel shader.
////////////////////////////////////////////////////////////////

//	TL
struct v_TL_positiont {
	float4	P		: POSITION;
	float2	Tex0	: TEXCOORD0;
	float4	Color	: COLOR; 
};

struct v_TL {
	float4	P		: POSITION;
	float2	Tex0	: TEXCOORD0;
	float4	Color	: COLOR; 
};

struct v2p_TL {
	float2	Tex0	: TEXCOORD0;
	float4	Color	: COLOR;
	float4	HPos	: POSITION;		// Clip-space position	(for rasterization)
};

struct p_TL {
	float2	Tex0	: TEXCOORD0;
	float4	Color	: COLOR;
};

//	build(bloom_build)
struct v_build {
	float4	P		: POSITIONT;
	float2	Tex0	: TEXCOORD0;
	float2	Tex1	: TEXCOORD1;
	float2	Tex2	: TEXCOORD2;
	float2	Tex3	: TEXCOORD3;
};

struct v2p_build {
	float2	Tex0	: TEXCOORD0;
	float2	Tex1	: TEXCOORD1;
	float2	Tex2	: TEXCOORD2;
	float2	Tex3	: TEXCOORD3;
	float4	HPos	: POSITION;		// Clip-space position 	(for rasterization)
};

struct p_build {
	float2 	Tex0	: TEXCOORD0;
	float2	Tex1	: TEXCOORD1;
	float2 	Tex2	: TEXCOORD2;
	float2	Tex3	: TEXCOORD3;
};

//	filter(bloom_filter)
struct v_filter {
	float4	P		: POSITION;
	float4	Tex0	: TEXCOORD0;
	float4	Tex1	: TEXCOORD1;
	float4	Tex2	: TEXCOORD2;
	float4	Tex3	: TEXCOORD3;
	float4	Tex4	: TEXCOORD4;
	float4	Tex5	: TEXCOORD5;
	float4	Tex6	: TEXCOORD6;
	float4	Tex7	: TEXCOORD7;
};

struct v2p_filter {
	float4	Tex0	: TEXCOORD0;
	float4	Tex1	: TEXCOORD1;
	float4	Tex2	: TEXCOORD2;
	float4	Tex3	: TEXCOORD3;
	float4	Tex4	: TEXCOORD4;
	float4	Tex5	: TEXCOORD5;
	float4	Tex6	: TEXCOORD6;
	float4	Tex7	: TEXCOORD7;
	float4	HPos	: POSITION;		// Clip-space position 	(for rasterization)
};

struct p_filter {
	float4	Tex0	: TEXCOORD0;
	float4	Tex1	: TEXCOORD1;
	float4	Tex2	: TEXCOORD2;
	float4	Tex3	: TEXCOORD3;
	float4	Tex4	: TEXCOORD4;
	float4	Tex5	: TEXCOORD5;
	float4	Tex6	: TEXCOORD6;
	float4	Tex7	: TEXCOORD7;
};

//////////////////////////////////////////////////////////////////////////////////////////
struct v_static {
	float4	P		: POSITION;		// (float,float,float,1)
	float4	Nh		: NORMAL;		// (nx,ny,nz,hemi occlusion)
	float4	T		: TANGENT;		// tangent
	float4	B		: BINORMAL;		// binormal
	float2	tc		: TEXCOORD0;	// (u,v)
	float2	lmh		: TEXCOORD1;	// (lmu,lmv)
	float4	color	: COLOR0;		// (r,g,b,dir-occlusion)
};

struct v_tree {
	float4	P		: POSITION;		// (float,float,float,1)
	float4	Nh		: NORMAL;		// (nx,ny,nz)
	float3	T		: TANGENT;		// tangent
	float3	B		: BINORMAL;		// binormal
	float4	tc		: TEXCOORD0;	// (u,v,frac,???)
};

struct v_model {
	float4	P		: POSITION;		// (float,float,float,1)
	float3	N		: NORMAL;		// (nx,ny,nz)
	float3	T		: TANGENT;		// (nx,ny,nz)
	float3	B		: BINORMAL;		// (nx,ny,nz)
	float2	tc		: TEXCOORD0;	// (u,v)
};

struct v_detail {
	float4	pos		: POSITION;		// (float,float,float,1)
	int4	misc	: TEXCOORD0;	// (u(Q),v(Q),frac,matrix-id)
};

#ifdef	USE_HWSMAP
struct v_shadow_direct_aref {
	float4	hpos	: POSITION;		// Clip-space position			(for rasterization)
	float2	tc0		: TEXCOORD1;	// Diffuse map for aref
};

struct v_shadow_direct {
	float4	hpos	: POSITION;		// Clip-space position			(for rasterization)
};
#else
struct v_shadow_direct_aref {
	float4	hpos	: POSITION;		// Clip-space position			(for rasterization)
	float	depth	: TEXCOORD0;	// Depth
	float2	tc0		: TEXCOORD1;	// Diffuse map for aref
};

struct v_shadow_direct {
	float4	hpos	: POSITION;		// Clip-space position			(for rasterization)
	float	depth	: TEXCOORD0;	// Depth
};
#endif

//////////////////////////////////////////////////////////////////////////////////////////
struct p_bumped {
	float4	hpos	: POSITION;
#if defined(USE_R2_STATIC_SUN) && !defined(USE_LM_HEMI)
	float4	tcdh	: TEXCOORD0;	// Texture coordinates,			w=sun_occlusion
#else
	float2	tcdh	: TEXCOORD0;	// Texture coordinates
#endif
	float4	position: TEXCOORD1;	// position + hemi
	float3	M1		: TEXCOORD2;	// nmap 2 eye - 1
	float3	M2		: TEXCOORD3;	// nmap 2 eye - 2
	float3	M3		: TEXCOORD4;	// nmap 2 eye - 3
#ifdef USE_PARALLAX
	float3	eye		: TEXCOORD5;	// vector to point in tangent space
#ifdef USE_TDETAIL
	float2	tcdbump	: TEXCOORD6;	// d-bump
	#ifdef USE_LM_HEMI
	float2	lmh		: TEXCOORD7;	// lm-hemi
	#endif
#else
	#ifdef USE_LM_HEMI
	float2	lmh		: TEXCOORD6;	// lm-hemi
	#endif
#endif
#else
#ifdef USE_TDETAIL
	float2	tcdbump	: TEXCOORD5;	// d-bump
	#ifdef USE_LM_HEMI
	float2	lmh		: TEXCOORD6;	// lm-hemi
	#endif
#else
	#ifdef USE_LM_HEMI
	float2	lmh		: TEXCOORD5;	// lm-hemi
	#endif
#endif
#endif
};

struct p_flat {
	float4	hpos	: POSITION;
#if defined(USE_R2_STATIC_SUN) && !defined(USE_LM_HEMI)
	float4	tcdh	: TEXCOORD0;	// Texture coordinates,		w=sun_occlusion
#else
	float2	tcdh	: TEXCOORD0;	// Texture coordinates
#endif
	float4	position: TEXCOORD1;	// position + hemi
	float3	N		: TEXCOORD2;	// Eye-space normal		(for lighting)
#ifdef USE_TDETAIL
	float2	tcdbump	: TEXCOORD3;	// d-bump
	#ifdef USE_LM_HEMI
	float2	lmh		: TEXCOORD4;	// lm-hemi
	#endif
#else
	#ifdef USE_LM_HEMI
	float2	lmh		: TEXCOORD3;	// lm-hemi
	#endif
#endif
};

//////////////////////////////////////////////////////////////////////////////////////////
struct f_deffer {
	float4	position: COLOR0;		 // px,py,pz, gloss (в static-sun режиме: sun occlusion)
	float4	Ne		: COLOR1;		 // nx,ny,nz, hemi
	float4	C		: COLOR2;		 // r, g, b,spec
};

struct p_screen {
	float4	hpos	: POSITION;
	float2	tc0		: TEXCOORD0;	// Texture coordinates		(for sampling maps)
};


#endif	//	common_iostructs_h_included