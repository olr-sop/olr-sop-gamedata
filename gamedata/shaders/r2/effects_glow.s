function normal(shader, t_base, t_second, t_detail)
  		shader:begin("effects_glow", "effects_glow")
		: blend		(true, blend.srcalpha, blend.one)
		: sorting	(3, false)
		: zb		(false, false)
		: fog		(true)
		shader : sampler("s_base")		: texture (t_base) 
		shader : sampler("s_position")	: texture ("$user$position"):clamp()
end
