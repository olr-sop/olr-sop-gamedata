function normal(shader, t_base, t_second, t_detail)
	shader:begin("null", "r1a_bloom_blur")
			: fog(false)
			: zb(false, false)
	shader:sampler("s_image"):texture("$user$r1a_tm_bloom1"):clamp():f_linear()
end
