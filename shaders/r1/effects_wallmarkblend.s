//Уоллмарки (пятна крови, блевотины:) , ) теперь могут освещаться фонариками, лампами, фарами и т.п.
//Но есть один неприятный баг - они становятся не видны при взгляде
//на них под некоторыми углами. Если тебя это бесит, шли sms на номер... 
//кхм... в смысле - удаляй вот этот вот файл. "Пропадать" перестанут,
//но и подсвечиваться не будут...

function normal		(shader, t_base, t_second, t_detail)
	shader:begin	("wmark",	"vert")
			: sorting	(0, false)
			: blend		(true,blend.srcalpha,blend.invsrcalpha)
			: aref 		(true,0)
			: zb 		(true,false)
			: fog		(true)
	shader:sampler	("s_base")      :texture	(t_base)
end

function l_spot    (shader, t_base, t_second, t_detail)
  r1_lspot	(shader, t_base, "wmark_spot")
end

function l_point  (shader, t_base, t_second, t_detail)
  r1_lpoint	(shader, t_base, "wmark_point")
end
