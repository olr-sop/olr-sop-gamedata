function normal(shader, t_base, t_second, t_detail)
	shader:begin("model_env_lq","model_env_lq")
		: sorting	(1,false)
		: blend		(true,blend.srcalpha,blend.invsrcalpha)
	shader:sampler("s_base"):texture(t_base)
	shader:sampler("s_env"):texture("$user$sky0"):clamp()
end