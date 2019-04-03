
#define Max_Step  250 
#define Max_Dist 100.0
#define Surf_Dist 0.01 

float sdSphere( vec3 p, float s )
{
    return length(p)-s;
}

float map( in vec3 pos )
{
    return sdSphere( pos - vec3( 0.0,0.0, 0.0 ), 1.0 );
}

vec3 castRay( in vec3 ro, in vec3 rd )
{
    vec3  res = vec3(0.0,0.0,0.0);
    float t = 0.0 ;
    for( int i = 0 ; i < Max_Step && t < Max_Dist ; i++ )
    {
        float h = map( ro+rd*t );
        if( abs(h)<( Surf_Dist * t ))
        { 
            res = vec3(t,h,1.0); 
            break;
         }
         t += h;
    }
    return res;
}

vec3 render( in vec3 ro, in vec3 rd )
{ 
    vec3 res = castRay(ro,rd) ;
    return vec3(res.x);
}


mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
	vec3 cw = normalize(ta-ro);
	vec3 cp = vec3(sin(cr), cos(cr),0.0);
	vec3 cu = normalize( cross(cw,cp) );
	vec3 cv =          ( cross(cu,cw) );
    return mat3( cu, cv, cw );
}

void main() {
    float time = iGlobalTime * 1.0;
    
    vec2 mo = iMouse.xy/iResolution.xy;
    // camera	
    vec3 ro = vec3( 4.6*cos(0.1*time + 6.0*mo.x), 1.0 + 2.0*mo.y, 0.5 + 4.6*sin(0.1*time + 6.0*mo.x) );
    vec3 ta = vec3( -0.5, -0.4, 0.5 );
    // camera-to-world transformation
    mat3 ca = setCamera( ro, ta, 0.0 );

    vec3 tot = vec3(0.0);
	vec2 p = (-iResolution.xy + 2.0*gl_FragCoord.xy )/iResolution.y;
     // ray direction
    vec3 rd = ca * normalize( vec3(p.xy,2.0) );
    // render	
    vec3 col = render( ro, rd );

    tot += col;
    
	gl_FragColor = vec4( tot, 1.0 );


}