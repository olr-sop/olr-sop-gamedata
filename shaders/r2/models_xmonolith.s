



function normal    (shader, t_base, t_second, t_detail)
     shader:begin( "model_def_monolith", "model_def_monolith" )
      : sorting  (3, true)
      : blend    (true,blend.srccolor,blend.invsrcalpha)
      : aref     (true,0)
      : zb     (true,false)
      : fog    (false)
      : distort   (false)
  shader:sampler  ("s_base")      :texture  (t_base)
end

function l_special  (shader, t_base, t_second, t_detail)
     shader:begin( "model_def_monolith", "model_def_monolith" )
      : sorting   (3, true)
      : blend    (true,blend.srcalpha,blend.invsrcalpha)
      : zb        (true,false)
      : fog       (false)
      : distort   (true)
  shader:sampler  ("s_base")      :texture  (t_base)
  shader:sampler  ("s_distort")   :texture  ("fx\\distort\\glass_01")
end

function normal    (shader, t_base, t_second, t_detail)
     shader:begin( "model_def_monolith", "model_def_monolith" )
      : fog      (false)
      : zb       (true,false)
      : blend   (true,blend.srccolor,blend.one)
      : aref    (true,0)
      : sorting  (2, true)
  shader:sampler  ("s_base")      :texture  (t_base)
end
