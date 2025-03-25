function normal		(shader, t_base, t_second, t_detail)
	shader:begin	("model_env_lq","model_env_sl")
			: fog		(false)
			: zb 		(true,false)
			: blend		(true,blend.one,blend.one)
			: aref 		(true,0)
			: sorting	(2, false)
	shader:sampler	("s_base")      :texture	(t_base)
	shader:sampler	("s_env")	:texture	("sky\\sky_cube_cone")	
			: clamp()
end

//function l_spot		(shader, t_base, t_second, t_detail)
//	r1_lspot 	(shader, t_base, "model_def_spot")
//end

//function l_point	(shader, t_base, t_second, t_detail)
//	r1_lpoint 	(shader, t_base, "model_def_point")
//end
