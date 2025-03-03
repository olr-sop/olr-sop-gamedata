//Лава в Саркофаге

local tex_base          = "fx\\fx_lavahell1" //Подумать, оставить или нет...

function normal		(shader, t_base, t_second, t_detail)
	shader:begin	("deffer_lava_flat","deffer_base_flat")
			: fog		(false)
			: emissive 	(true)
	shader:sampler	("s_base")      :texture	(tex_base)	//(t_base)	// ?=/=!
end

function l_special	(shader, t_base, t_second, t_detail)
	shader:begin	("simple","accum_emissive_lava")
			: zb 		(true,false)
			: fog		(false)
			: emissive 	(true)
end
