function normal		(shader, t_base, t_second, t_detail)
	-- pass #0
	shader:begin	("simple","simple")
		: fog		(false)
		: blend		(true,blend.one,blend.zero)
		: zb		(true,true)
		: sorting	(1, false)
	shader:sampler	("s_base"):texture(t_base)
	-- pass #1
	shader:begin	("simple","simple")
		: fog		(false)
		: blend		(true,blend.one,blend.srccolor)
		: zb		(true,true)
		: sorting	(1, false)
	shader:sampler	("s_base"):texture(t_base)
end

function l_spot		(shader, t_base, t_second, t_detail)
	r1_lspot 	(shader, t_base, "simple_spot")
end

function l_point	(shader, t_base, t_second, t_detail)
	r1_lpoint 	(shader, t_base, "simple_point")
end