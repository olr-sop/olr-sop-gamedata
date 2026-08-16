function normal( shader, t_base, t_second, t_detail )
  		shader:begin( "effects_glow_p", "effects_glow_p" )
		: blend		( true, blend.srcalpha, blend.one )
		: sorting	( 3, false )
		: zb            ( true, false ) --финальные глоу, не рисуются поверх геометрии
		: fog		( false )

		shader : sampler( "s_base" ) : texture  ( t_base ) 
		shader : sampler( "s_position" ) : texture  ("$user$position")
		: clamp()
end
