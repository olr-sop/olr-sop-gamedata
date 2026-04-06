function normal(shader, t_base, t_second, t_detail)
	shader:begin("null", "r1a_bloom_combine")
			: fog(false)
			: zb(false, false)
	shader:sampler("s_image"):texture(t_rt):clamp():f_linear()
	shader:sampler("s_bloom0"):texture("$user$r1a_tm_bloom2"):clamp():f_linear()
end
