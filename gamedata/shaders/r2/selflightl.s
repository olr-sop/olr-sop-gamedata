function normal		(shader, t_base, t_second, t_detail)
	shader:begin	("vert","vert")
			: fog		(false)
			: zb 		(true,false)
			: blend		(true,blend.srccolor,blend.one)
			: aref 		(false,0)
			: sorting	(2, false)
	shader:sampler	("s_base"):texture(t_base)
end
