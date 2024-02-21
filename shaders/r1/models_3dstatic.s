function normal        (shader, t_base, t_second, t_detail)
  shader:begin      ("model_def_lq_3dstatic","model_def_lq_3dstatic")
      : fog            (true)
      : zb             (true,true)
  	shader:sampler    ("s_base")      :texture  (t_base)
end