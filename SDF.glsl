
#define Max_Step  250 
#define Max_Dist 100.0
#define Surf_Dist 0.000001 

float sdSphere( vec3 p, float s )
{
    return length(p)-s;
}

vec2 map( in vec3 pos )
{
    return vec2( sdSphere(  pos-vec3( 0.0,0.25, 0.0), 0.25 ),40 ) ;
} 

vec3 calcNormal( in vec3 pos )
{
    vec2 e = vec2(1.0,-1.0)*0.5773*0.0005;
    return normalize( e.xyy*map( pos + e.xyy ).x + 
					  e.yyx*map( pos + e.yyx ).x + 
					  e.yxy*map( pos + e.yxy ).x + 
					  e.xxx*map( pos + e.xxx ).x);
}



//res : (x) distance -t  (y) material type - h.y  (z) not-use                                        
vec3 castRay( in vec3 ro, in vec3 rd )
{
    vec3 res = vec3(-1.0,-1.0,1.0);
    float t = 0.0 ;
    float tmax = Max_Dist ;
    float tp1 = (0.0-ro.y)/rd.y;
    if( tp1>0.0 )
    {
        tmax = min( tmax, tp1 );
        res = vec3( tp1, 1.0 ,1.0);
    }

    for( int i = 0 ; i < Max_Step && t < Max_Dist ; i++ )
    {
        vec2 h = map( ro+rd*t );
        if( abs(h.x)<( Surf_Dist * t ))
        { 
            res = vec3(t,h.y,1.0); 
            break;
         }
         t += h.x;
    }
    return res;
}

float checkersGradBox( in vec2 p )
{
    // filter kernel
    vec2 w = fwidth(p) + 0.001;
    // analytical integral (box filter)
    vec2 i = 2.0*(abs(fract((p-0.5*w)*0.5)-0.5)-abs(fract((p+0.5*w)*0.5)-0.5))/w;
    // xor pattern
    return 0.5 - 0.5*i.x*i.y;                  
}

vec3 render( in vec3 ro, in vec3 rd )
{ 
    vec3 col = vec3(0, 0, 0);
    col =  sin( vec3(0.9,0.1,0.1));
    vec3 res = castRay(ro,rd) ;
    float t = res.x;
    float m = res.y;
    vec3 pos = t * rd + ro ;
    

    if( m>-0.5 ){
        
        if(m<1.5)
        {  
            float f = checkersGradBox( 5.0*pos.xz );
            col = 0.3 + f*vec3(0.1);
            return col ;
        }
        vec3 normal = calcNormal(pos);
        vec3 ref = reflect( rd, normal );
        // light dir 
        vec3  lig = normalize( vec3(-0.4, 0.7, -0.6) );
        // Half vector 
        vec3  hal = normalize( lig-rd );
        // ambient 
        float amb = clamp( 0.5+0.5*normal.y, 0.0, 1.0 );
        // back 
        float bac = clamp( dot( normal, normalize(vec3(-lig.x,0.0,-lig.z))), 0.0, 1.0 )*clamp( 1.0-pos.y,0.0,1.0);
        // cube map rel
        float dom = smoothstep( -0.2, 0.2, ref.y );
        // rim 
        float fre = pow( clamp(1.0+dot(normal,rd),0.0,1.0), 2.0 );
        // diffuse 
        float dif = clamp( dot( normal, lig ), 0.0, 1.0 );
        col = col * dif ;
    }

    return col  ;
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
        0.7*cos(time)-1.0, 
        1.0+2.0*0.001, 
        0.7*sin(time )-1.0
    );
    // target 
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