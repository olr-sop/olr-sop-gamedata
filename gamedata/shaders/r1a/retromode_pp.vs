#include "common.h"

uniform float4 screen_res; // (width, height, 1/width, 1/height)

struct v {
    float3 P : POSITION;
    float2 tc0 : TEXCOORD0;
};

struct v2p {
    float2 tc0 : TEXCOORD0;
    float4 HPos : POSITION;
};

v2p main(v I) {
    v2p O;
    // Half-pixel offset делается здесь
    O.HPos = float4((I.P.x + 0.5) * screen_res.z * 2 - 1, 1 - (I.P.y + 0.5) * screen_res.w * 2, 0, 1);
    O.tc0 = I.tc0;
    return O;
}



