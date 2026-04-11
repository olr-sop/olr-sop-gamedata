function normal(shader, t_base, t_second, t_detail)
	shader:begin	("fog_volume", "fog_volume")
			: sorting	(2, false)
			: blend		(true, blend.srcalpha, blend.invsrcalpha)
			: aref		(false, 0)
			: zb		(true, false)
			: fog		(false)
end
