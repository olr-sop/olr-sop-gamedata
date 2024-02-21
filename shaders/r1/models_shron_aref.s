//Шейдер для тайников: убирает тень от невидимого обьекта тайника. [ScaV]
function normal		(shader, t_base, t_second, t_detail)
	shader:begin	("dumb","dumb")
			: fog		(false)
			: zb 		(false,false)
			: blend		(true,blend.zero,blend.one)
			: aref 		(false,0)
			: sorting	(2, false)
	shader:sampler	("s_base")      :texture	(t_base)
end
