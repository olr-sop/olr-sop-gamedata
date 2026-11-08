#ifndef	common_functions_h_included
#define	common_functions_h_included

// gloss -> Blinn exponent: log-linear over the console range [pow_min..pow_max].
// pow_max is the anti-aliasing ceiling (high exponents are sub-pixel without LEAN mips).
// gloss is expected in [0..1] — all G-buffer writers clamp it (sload_i, def_gloss, terrain mask).
float spec_power(float gloss) {
	return exp2(lerp(spec_params.z, spec_params.w, gloss));
}

// Inverse mapping (exponent -> gloss), used by the detail gloss combiner in sload.h.
float spec_gloss(float P) {
	return saturate((log2(max(P, 1.f)) - spec_params.z) / max(spec_params.w - spec_params.z, 1e-3f));
}

float4 combine_bloom(float3 low, float4 high) {
	return float4(low + high*high.a, 1.h);
}

//	contrast function
float Contrast(float Input, float ContrastPower) {
	 //piecewise contrast function
	 bool IsAboveHalf = Input > 0.5 ;
	 float ToRaise = saturate(2*(IsAboveHalf ? 1-Input : Input));
	 float Output = 0.5*pow(ToRaise, ContrastPower);
	 Output = IsAboveHalf ? 1-Output : Output;
	 return Output;
}

void tonemap(out float4 low, out float4 high, float3 rgb, float scale) {
	rgb *= scale;			// avg pixel -> MiddleGray

	const float A = 0.22, B = 0.3, C = .1, D = 0.2, E = .01, F = 0.4;
	const float W = 1.7; const float WhSQR = 2.89f;
	float3 f = (rgb*(A*rgb + C*B) + D*E) / (rgb*(A*rgb + B) + D*F) - E/F;
	float3 fw = (W*(A*W + C*B) + D*E) / (W*(A*W + B) + D*F) - E/F;
	float3 c = f / fw;

	low = (f/fw + (rgb/WhSQR)).xyzz;
	high = c.xyzz/def_hdr;
}

float calc_fogging(float4 w_pos) { 
	return dot(w_pos,fog_plane);
}

float2 calc_detail(float3 w_pos) {
	float dtl = distance(w_pos,eye_position)*dt_params.w;
	dtl = min(dtl*dtl, 1);

	float dt_mul = 1- dtl;		// dt*	 [1 ..	0 ]
	float dt_add = .5 * dtl;	 // dt+	 [0 .. 0.5]
	return float2(dt_mul,dt_add);
}

float3 calc_reflection	(float3 pos_w, float3 norm_w) {
	return reflect(normalize(pos_w-eye_position), norm_w);
}

float3 calc_sun_r1(float3 norm_w) { 
	return L_sun_color*saturate(dot((norm_w),-L_sun_dir_w));
}

float3 calc_model_hemi_r1(float3 norm_w) {
	return max(0,norm_w.y)*L_hemi_color;
}

float3 calc_model_lq_lighting(float3 norm_w) {
	return L_material.x*calc_model_hemi_r1(norm_w) + L_ambient + L_material.y*calc_sun_r1(norm_w);
}

float3 p_hemi(float2 tc) {
	float3 t_lmh = tex2D(s_hemi, tc);
	return dot	(t_lmh,1.h/3.h);
}

float3 v_hemi(float3 n) {
	return L_hemi_color*(.5f + .5f*n.y);
}

float3 v_hemi_wrap(float3 n, float w) {
	return L_hemi_color*(w + (1-w)*n.y);
}

float3 v_sun(float3 n) {
	return L_sun_color*dot(n,-L_sun_dir_w);
}

float3 v_sun_wrap(float3 n, float w) {
	return L_sun_color*(w+(1-w)*dot(n,-L_sun_dir_w));
}

#endif	//	common_functions_h_included