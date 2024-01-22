function normal        (shader, t_base, t_second, t_detail)
    shader:begin    ("simple","simple")
            : fog        (true)
            : zb         (true,true)
            : blend        (false,blend.srcalpha,blend.one)
            : aref         (false,0)
            : sorting    (1, false)
    shader:sampler    ("s_base")      :texture    (t_base)
end