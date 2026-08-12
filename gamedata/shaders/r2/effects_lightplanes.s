function normal		(shader, t_base, t_second, t_detail)
	shader:begin	("base_lplanes","base_lplanes")
			: fog		(false)
			: zb 		(false,false)
			: blend		(true,blend.srcalpha,blend.one)
			: aref 		(false,0)
			: sorting	(2, false)
	shader:sampler	("s_base")      :texture	(t_base)
end
