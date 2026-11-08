#ifndef	common_uniforms_h_included
#define	common_uniforms_h_included

uniform float4	L_material;				// x=hemi(ROS), y=sun(ROS), z=0, w=0 (быв. material id, LUT удалён)
uniform float4	hemi_cube_pos_faces;
uniform float4	hemi_cube_neg_faces;
uniform float4	Ldynamic_color;			// dynamic light color (rgb1)	- spot/point
uniform float4	Ldynamic_pos;			// dynamic light pos+1/range(w) - spot/point
uniform float4	Ldynamic_dir;			// dynamic light direction		- sun
uniform float4	spec_params;			// x=fresnel_amt, y=spec_scale, z=log2(pow_min), w=log2(pow_max)

uniform float4	J_direct[6];
uniform float4	J_spot[6];

#endif	//	common_uniforms_h_included