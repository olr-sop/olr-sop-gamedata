function normal		(shader, t_base, t_second, t_detail)
	shader:begin	("null","hud_ui_mask")
			: fog		(false)
			: zb		(false,false)
			: blend		(true,blend.srcalpha,blend.invsrcalpha)
	shader:sampler	("s_base")	:texture(t_base)
	shader:sampler	("s_mask")	:texture(t_second) :clamp() :f_linear()
end
