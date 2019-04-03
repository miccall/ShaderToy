
#define Max_Step  250 
#define Max_Dist 100.0
#define Surf_Dist 0.01 

float SphereSDF(vec3 p , float r )
{
    return length(p) - r ;
}

float PlaneSDF( vec3 p )
{
    return p.y;
}
float GetDist(vec3 p)
{
    vec4 s = vec4(0.0,1.0,6.0,1.0);
    float sphereDist =  SphereSDF( p - s.xyz , s.w );
    float planeDist = PlaneSDF(p);
    
    float d = min(sphereDist , planeDist);
    return d ;
    
}
float RayMarch( vec3 ro ,vec3 rd )
{
    float Do = 0.0 ;
    
    for(int i = 0 ; i < Max_Step ; i++)
    {
        vec3 p = ro + Do * rd ;
        float ds = GetDist(p);
        Do += ds ;
        if(Do > Max_Dist || ds < Surf_Dist ) break ;
    }
    return Do; 
}

vec3 GetNormal(vec3 p )
{
    float d = GetDist(p);
    vec2 e = vec2(0.01, 0 );
    vec3 n = d - vec3(
                    GetDist(p-e.xyy),
                    GetDist(p-e.yxy),
                    GetDist(p-e.yyx)
                    );
    
    return normalize(n);
    
}
float GetLight(vec3 p )
{
    vec3 lightPos = vec3(0.0,8.0,0.0);
    lightPos.xz += vec2(sin(iTime),cos(iTime)) * 10.0 ;
    vec3 l = normalize(lightPos - p );
    vec3 n = GetNormal(p);
    float diffuse = clamp (dot(n,l),0.0,1.0) ;
    
    float d = RayMarch(p + n * Surf_Dist * 2.0 ,l );
    if( d < length(lightPos-p)) diffuse *= 0.4 ;
    return  diffuse ;
}

void main() {
  float time = iGlobalTime * 1.0;

    vec2 uv = (gl_FragCoord.xy - iResolution.xy * 0.5 ) / iResolution.y;
    vec3 col = vec3(uv,1.0);
    
    vec3 ro = vec3(0.0,1.0,0.0);
    vec3 rd = normalize( vec3 ( uv.x , uv.y , 1.0 ));
    
    float d = RayMarch(ro,rd);
    
    vec3 p = ro + rd * d ;
    float diff = GetLight( p ) ;
    
    col = vec3(0.4,0.6,0.8) * diff ;
    //col = GetNormal(p);
    gl_FragColor = vec4(col,1.0);

}