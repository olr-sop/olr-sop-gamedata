function normal(shader, t_base, t_second, t_detail)
	shader:begin("null","null")
	: aref(true,255)
	shader:sampler("s_base"):texture(t_base)
end
