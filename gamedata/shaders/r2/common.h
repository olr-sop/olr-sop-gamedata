#ifndef		COMMON_H
#define		COMMON_H

#include "shared\common.h"

#include "common_defines.h"
#include "common_uniforms.h"
#include "common_iostructs.h"
#include "common_samplers.h"
#include "common_functions.h"

#define FXPS technique _render{pass _code{PixelShader=compile ps_3_0 main();}}
#define FXVS technique _render{pass _code{VertexShader=compile vs_3_0 main();}}

#endif