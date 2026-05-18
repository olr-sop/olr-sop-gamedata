function normal		(shader, t_base, t_second, t_detail)
	shader	: begin	("model_def_lplanes", "models_noise_self")
			: fog		(false)
			: zb		(true, false)
			: blend 	(false, blend.srcalpha, blend.one)
			: aref		(true, 0)
			: sorting	(2, true)
	shader:sampler	("s_base"):texture(t_base)
end