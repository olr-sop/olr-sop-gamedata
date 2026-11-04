function normal(shader, t_base, t_second, t_detail)
	shader:begin("model_env_lq","model_env_lq")
		: sorting	(1,false)
		shader:sampler("s_base"):texture(t_base)
		shader:sampler("s_env"):texture("$user$sky0"):clamp()
end

function normal_lq(shader, t_base, t_second, t_detail)
	shader:begin("model_env_lq","model_env_lq")
		: sorting	(1,false)
		shader:sampler("s_base"):texture(t_base)
		shader:sampler("s_env"):texture("$user$sky1"):clamp()
end