function normal(shader, t_base, t_second, t_detail)
	shader:begin("effects_sun","stub_default")
		: blend		(true,blend.srcalpha,blend.one)
		: zb		(false,false)
	shader:sampler("s_base"):texture(t_base):clamp
end