#ifndef	common_samplers_h_included
#define	common_samplers_h_included

// Geometry phase / deferring
uniform sampler2D	s_base;					//
uniform sampler2D	s_bump;					//
uniform sampler2D	s_bumpX;				//
uniform sampler2D	s_detail;				//
uniform sampler2D	s_bumpD;				//
uniform sampler2D	s_hemi;					//

uniform sampler2D	s_mask;					//

uniform sampler2D	s_dt_r;					//
uniform sampler2D	s_dt_g;					//
uniform sampler2D	s_dt_b;					//
uniform sampler2D	s_dt_a;					//

uniform sampler2D	s_dn_r;					//
uniform sampler2D	s_dn_g;					//
uniform sampler2D	s_dn_b;					//
uniform sampler2D	s_dn_a;					//

uniform sampler2D	s_dnX_r;				// _nmap#: g=height, a=spec (терраин, вторая половина пары)
uniform sampler2D	s_dnX_g;				//
uniform sampler2D	s_dnX_b;				//
uniform sampler2D	s_dnX_a;				//


// Lighting/shadowing phase
uniform sampler2D	s_depth;				//
uniform sampler2D	s_position;				// xyz = eye pos, w = gloss (static sun: sun occlusion)
uniform sampler2D	s_normal;				//
uniform sampler		s_lmap;					// 2D/cube projector lightmap
uniform sampler1D	s_attenuate;			//


// Combine phase
uniform sampler2D	s_diffuse;				// rgb.a = diffuse.spec
uniform sampler2D	s_accumulator;			// rgb.a = diffuse.specular
uniform sampler2D	s_generic;				//
uniform sampler2D	s_bloom;				//
uniform sampler		s_image;				// used in various post-processing
uniform sampler2D	s_tonemap;				// actually MidleGray / exp(Lw + eps)

#endif	//	#ifndef	common_samplers_h_included