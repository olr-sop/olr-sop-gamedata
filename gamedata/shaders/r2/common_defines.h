#ifndef	common_defines_h_included
#define	common_defines_h_included

// #define USE_GAMMA_22
// #define USE_SJITTER
// #define USE_SUNFILTER
//
// #define USE_MBLUR					//- HW-options defined
// #define USE_HWSMAP					//- HW-options defined

// #define USE_HWSMAP_PCF				//- nVidia GF3+, R600+

// #define USE_BRANCHING				//- HW-options defined
// #define USE_VTF						//- HW-options defined, VertexTextureFetch
// #define FP16_FILTER					//- HW-options defined
// #define FP16_BLEND					//- HW-options defined
//
// #define USE_PARALLAX					//- shader defined
// #define USE_TDETAIL					//- shader defined
// #define USE_LM_HEMI					//- shader defined
// #define USE_DISTORT					//- shader defined
// #define USE_SUNMASK					//- shader defined
// #define DBG_TMAPPING

#define def_gloss		float(0.2f)				// soft wide highlight, P ≈ 8
#define def_spec		float(0.04f)			// спекуляр ноль, ~0.05 (13.f/255.f) изначально было
#define def_aref		float(128.f/255.f)
#define def_dbumph		float(0.333f)
#define def_virtualh	float(.05f)				// 5cm
#define def_distort		float(0.05f)			// we get -0.5 .. 0.5 range, this is -512 .. 512 for 1024, so scale it
#define def_hdr			float(8.h)				// hight luminance range float(3.h)
#define def_hdr_clip	float(0.75h)

#define	LUMINANCE_VECTOR	float3(0.3f, 0.48f, 0.22f)

//////////////////////////////////////////////////////////////////////////////////////////
#ifndef		SMAP_size
#define		SMAP_size	2048
#endif

#endif	//	common_defines_h_included