function normal		(shader, t_base, t_second, t_detail)
	shader:begin	("deffer_base_flat","deffer_base_flat")
			: fog		(false)
			: emissive 	(true)
	shader:sampler	("s_base")      :texture	(t_base)
end

function l_special	(shader, t_base, t_second, t_detail)
//	shader:begin	("shadow_direct_base",	"accum_emissive2")
//	shader:begin	("simple",	"accum_emissive")
	shader:begin	("simple",	"accum_emissive_zp")
			: zb 		(true,false)
			: fog		(false)
			: emissive 	(true)
end
