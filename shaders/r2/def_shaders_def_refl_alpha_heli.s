//local tex_base              = "veh\\veh_mi24_fire"
local tex_nmap              = "water\\water_normal_0"
//local tex_dist            = "water\\water_dudv"
local tex_env0              = "$user$sky0"         
local tex_env1              = "$user$sky1"         



function normal          (shader, t_base, t_second, t_detail)

shader:begin           ("heli","heli")

        : sorting        (2,false)
//      : blend          (false,blend.srcalpha,blend.invsrcalpha)
//      : blend          (false,false)
//      : zb             (true,false)
//      : distort        (false)
        : fog            (true)

  shader:sampler        ("s_base")       :texture  (t_base)
  shader:sampler        ("s_nmap")       :texture  (tex_nmap)
  shader:sampler        ("s_env0")       :texture  (tex_env0)  : clamp()
  shader:sampler        ("s_env1")       :texture  (tex_env1)  : clamp()
end