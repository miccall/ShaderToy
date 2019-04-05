
#define Max_Step  250 
#define Max_Dist 100.0
#define Surf_Dist 0.000001 

float sdSphere( vec3 p, float s )
{
    return length(p)-s;
}

float map( in vec3 pos )
{
    return sdSphere(  pos-vec3( 0.0,0.25, 0.0), 0.25 ) ;
}

vec3 calcNormal( in vec3 pos )
{
    vec2 e = vec2(1.0,-1.0)*0.5773*0.0005;
    return normalize( e.xyy*map( pos + e.xyy ) + 
					  e.yyx*map( pos + e.yyx ) + 
					  e.yxy*map( pos + e.yxy ) + 
					  e.xxx*map( pos + e.xxx ));
}

vec3 castRay( in vec3 ro, in vec3 rd )
{
    vec3 res = vec3(-1.0,-1.0,1.0);
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
    vec3 pos = res.x * rd + ro ;
    vec3 normal = calcNormal( pos );
    
    return normal ;
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
    vec3 ro = vec3( 
        0.7*cos(time ), 
        1.0+2.0*0.01, 
        0.7*sin(time )
    );
    vec3 ta = vec3( 0.0,0.25, 0.0);
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