function normal(shader, t_base, t_second, t_detail)
	shader:begin("null", "r1a_bloom_prefilter")
			: fog(false)
			: zb(false, false)
	shader:sampler("s_image"):texture(t_rt):clamp():f_linear()
end
