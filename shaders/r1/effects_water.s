function normal(shader, t_base, t_second, t_detail)
	shader:begin("vert","vert")
			: sorting	(2, true)
			: blend		(true,blend.srcalpha,blend.invsrcalpha)
			: zb 		(true,false)
	shader:sampler("s_base"):texture(t_base)
	shader:sampler("s_position"):texture("$user$position")
end