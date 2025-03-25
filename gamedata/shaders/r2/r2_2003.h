//dark_buildings
//high	=		low/def_hdr		;        // 8x dynamic range

//bright-macron
high	= 	half4(rgb-def_lum_hrange, dot( min(rgb,def_lum_hrange), LUMINANCE_VECTOR ) )/3.5;


//very_bright_buildings-flyer
//high	= 	half4(rgb-def_lum_hrange, dot( min(rgb,def_lum_hrange), LUMINANCE_VECTOR ) );