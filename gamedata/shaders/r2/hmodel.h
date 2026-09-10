#include "common.h"

uniform samplerCUBE	env_s0;
uniform samplerCUBE	env_s1;
uniform float4		env_color;	// color.w  = lerp factor
uniform float3x4	m_v2w;

void hmodel(out float3 hdiffuse, out float3 hspecular, float m, float h, float s, float3 point, float3 normal)
{
        // hscale - something like diffuse reflection
        float3	nw		= mul(m_v2w,normal);
        float	hscale	= h;// слишком темно у обычной динамики выходит * (.75f + .25f*nw.y); // Не используем чистоганом функцию, но и при 0.5 слишком темно было, подкрутил таким макаром стало лучше, зато теперь ебало в небо тени на руках как надо, темно внизу но не слишком
		
#ifdef         USE_GAMMA_22
			hscale = (hscale*hscale);        // make it more linear
#endif

        // reflection vector
        float3	v2pointL	= normalize(point);
        float3	v2point		= mul(m_v2w,v2pointL);
        float3	vreflect	= reflect(-v2point,nw); // Тут должен быть минус иначе отражения некоректны
        float	hspec		= .5h+.5h*dot(vreflect,v2point);

        // material
		float4 light = tex3D(s_material, float3(hscale, hspec, m) );                // sample material

        // diffuse color
        float3 env_d;

		float3 diffuse_reflected_tc = float3(-nw.x, nw.y, nw.z);
        float3 e0d = texCUBE(env_s0,diffuse_reflected_tc);
        float3 e1d = texCUBE(env_s1,diffuse_reflected_tc);		
        env_d = env_color.xyz * lerp(e0d,e1d,env_color.w);

        hdiffuse = env_d * light.xyz + L_ambient.rgb;

        // specular color — тру ремаппинг
        float3 vreflectabs = abs(vreflect);
        float  vreflectmax = max(vreflectabs.x, max(vreflectabs.y, vreflectabs.z));
        vreflect /= vreflectmax;
        if (vreflect.y < 0.99)
            vreflect.y = vreflect.y * 2 - 1;

        float3 specular_reflected_tc = float3(-vreflect.x, vreflect.y, vreflect.z);
		
        float3 e0s		= texCUBE         (env_s0,specular_reflected_tc);
        float3 e1s		= texCUBE         (env_s1,specular_reflected_tc);
        float3 env_s	= env_color.xyz*lerp(e0s,e1s,env_color.w)        ;

		//hspecular = env_s*light.w*s;
		
		hspecular = env_s * light.w * s;
}