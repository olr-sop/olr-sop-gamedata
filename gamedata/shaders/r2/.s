function printf(fmt,...)
	log(string.format(fmt,unpack(arg)))
end

t_point_att 	= "fx\\light\\spot"

function r1_lspot	(shader, t_base, vs, aref)
	shader:begin	(vs,"add_spot")
	  		: fog		(false)
			: zb 		(true,false)
			: blend		(true,blend.one,blend.one)
			: aref 		(true,aref or 0)
	shader:sampler	("s_base")    	:texture	(t_base)
	shader:sampler	("s_lmap")    	:texture	("fx\\light\\torch")
			: clamp		()
			: f_linear 	()
			: project   	(true)
	shader:sampler	("s_att")    	:texture	("fx\\light\\light_grad")
			: clamp		()
			: f_linear	()
end

function r1_lpoint	(shader, t_base, vs, aref)
	shader:begin	(vs,"add_point")
	  		: fog		(false)
			: zb 		(true,false)
			: blend		(true,blend.one,blend.one)
			: aref 		(true,aref or 0)
	shader:sampler	("s_base")    	:texture	(t_base)
	shader:sampler	("s_lmap")    	:texture	(t_point_att)
			: clamp		()
			: f_linear 	()
	shader:sampler	("s_att")    	:texture	(t_point_att)
			: clamp		()
			: f_linear	()
end
