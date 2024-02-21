#include "common.h"

float3	waterrefl	(out float amount, float3 P, float3 N)	{
	float3 	v2point	= normalize	(P-eye_position);
	float3	vreflect= reflect	(v2point, N);
	float 	fresnel	= (.5f + .5f*dot(vreflect,v2point));
	amount	= 1 - fresnel*fresnel;			// 0=full env, 1=no env
	return	vreflect;}

struct        v_vert
{
        float4         P        : POSITION;        // (float,float,float,1)
        float4         N        : NORMAL;        // (nx,ny,nz,hemi occlusion)
        float4         T        : TANGENT;
        float4         B        : BINORMAL;
        float4        color     : COLOR0;        // (r,g,b,dir-occlusion)
        float2         uv       : TEXCOORD0;        // (u0,v0)
};
struct   vf
{
        float4      hpos        :        POSITION         ;
        float2      tbase       :        TEXCOORD0        ;  // base
        float2      tnorm0      :        TEXCOORD1        ;  // nm0
        float2      tnorm1      :        TEXCOORD2        ;  // nm1
        half3       M1          :        TEXCOORD3        ;
        half3       M2          :        TEXCOORD4        ;
        half3       M3        	:        TEXCOORD5        ;
        half3       v2point     :        TEXCOORD6        ;
        half4        c0         :        COLOR0           ;
        float        fog        :        FOG              ;
};


vf main_vs_2_0 (v_vert v)
{
        vf             o;
        float4         P  = v.P;                // world
        float3         NN = unpack_normal(v.N);
	//P= watermove(P);

        o.v2point       = P-eye_position;
        o.tbase         = unpack_tc_base(v.uv,v.T.w,v.B.w);                // copy tc
        o.tnorm0        = 0; //watermove_tc(0, P.xz, 0);
        o.tnorm1        = 0; //watermove_tc(0, P.xz, 0);

        // Calculate the 3x3 transform from tangent space to eye-space
        // TangentToEyeSpace = object2eye * tangent2object
        // = object2eye * transpose(object2tangent) (since the inverse of a rotation is its transpose)
        float3          N         = unpack_bx2(v.N);        // just scale (assume normal in the -.5f, .5f)
        float3          T         = unpack_bx2(v.T);        //
        float3          B         = unpack_bx2(v.B);        //
        float3x3 xform            = mul        ((float3x3)m_W, float3x3(
                                                T.x,B.x,N.x,
                                                T.y,B.y,N.y,
                                                T.z,B.z,N.z));

        // Feed this transform to pixel shader
        o.M1                 = xform        [0];
        o.M2                 = xform        [1];
        o.M3                 = xform        [2];

        float3         L_rgb    = v.color.xyz;                          // precalculated RGB lighting
        float3         L_hemi   = v_hemi(N)*v.N.w;                      // hemisphere
        float3         L_sun    = v_sun(N)*v.color.w;                   // sun
        float3         L_final  = L_rgb + L_hemi + L_sun + L_ambient;
     // L_final        = v.N.w  + L_ambient;
        o.hpos         = mul (m_VP, P);                                // xform, input in world coords
	o.fog       = calc_fogging  (v.P);

	o.c0		= float4		(L_final,1);
     //	o.c0		= float4		(L_final,o.fog);
        return o;
}