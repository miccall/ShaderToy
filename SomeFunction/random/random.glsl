
float random_linear( vec2 p )
{
    return fract( 256. * p.x );
}

float nrand( vec2 n )
{
	 return fract(sin(dot(n.xy, vec2(12.9898, 78.233)))* 43758.5453);
}

float random_1( vec2 p )
{
    vec2 r = vec2(
        23.14069263277926, // e^pi (Gelfond's constant)
         2.665144142690225 // 2^sqrt(2) (Gelfondâ€“Schneider constant)
    );
    return fract( cos( mod( 12345678.0, 512.0 * dot(p,r) ) ) );
}

float random_2(vec2 p)
{
  return fract(cos(dot(p,vec2(23.14069263277926,2.665144142690225)))*123456.);
}

float snoise(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float random_sony( vec2 p )
{
    return mod( p.x, 4.0 );
}


float n1rand( vec2 n )
{
	float t = fract( iTime );
	float nrnd0 = nrand( n + 0.07*t );
	return nrnd0;
}

float n2rand( vec2 n )
{
	float t = fract( iTime );
	float nrnd0 = nrand( n + 0.07*t );
	float nrnd1 = nrand( n + 0.11*t );
	return (nrnd0+nrnd1) / 2.0;
}

float n3rand( vec2 n )
{
	float t = fract( iTime );
	float nrnd0 = nrand( n + 0.07*t );
	float nrnd1 = nrand( n + 0.11*t );
	float nrnd2 = nrand( n + 0.13*t );
	return (nrnd0+nrnd1+nrnd2) / 3.0;
}

float n4rand( vec2 n )
{
	float t = fract( iTime );
	float nrnd0 = nrand( n + 0.07*t );
	float nrnd1 = nrand( n + 0.11*t );	
	float nrnd2 = nrand( n + 0.13*t );
	float nrnd3 = nrand( n + 0.17*t );
	return (nrnd0+nrnd1+nrnd2+nrnd3) / 4.0;
}

float n8rand( vec2 n )
{
	float t = fract( iTime );
	float nrnd0 = nrand( n + 0.07*t );
	float nrnd1 = nrand( n + 0.11*t );	
	float nrnd2 = nrand( n + 0.13*t );
	float nrnd3 = nrand( n + 0.17*t );
    
  float nrnd4 = nrand( n + 0.19*t );
  float nrnd5 = nrand( n + 0.23*t );
  float nrnd6 = nrand( n + 0.29*t );
  float nrnd7 = nrand( n + 0.31*t );
    
	return (nrnd0+nrnd1+nrnd2+nrnd3 +nrnd4+nrnd5+nrnd6+nrnd7) / 8.0;
}
float hash( vec2 p ) {
	float h = dot(p,vec2(127.1,311.7));	
    return fract(sin(h)*43758.5453123);
}

float noise( in vec2 p ) {
    p=p*150.0;
    vec2 i = floor( p );
    vec2 f = fract( p );	
	  vec2 u = f*f*(3.0-2.0*f);
    return -1.0+2.0*mix( mix( hash( i + vec2(0.0,0.0) ), 
                     hash( i + vec2(1.0,0.0) ), u.x),
                mix( hash( i + vec2(0.0,1.0) ), 
                     hash( i + vec2(1.0,1.0) ), u.x), u.y);
}


void main() {
  float time = iGlobalTime * 1.0;
  vec2 uv = (gl_FragCoord.xy / iResolution.xx );
  float n = 1.0 ;
  //n = random_linear(uv);
  //n = random_1(uv);
  //n = random_2(uv);
  //n = snoise(uv);
  // n = random_sony(uv);
  // n =  noise(uv);
  // n = hash(uv);
  // n = n1rand(uv);
  // n = n2rand(uv);
  // n = n3rand(uv);
  // n = n4rand(uv);
  // n = n8rand(uv);

  gl_FragColor = vec4(n,n,n, 1.0);
}