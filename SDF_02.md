## normal

<div align=center> 

![normal vector preview](mdtexture/normal.jpg)

</div>

1. 方法一 : 
来自 iq 的网站 ： [normalsSDF](http://iquilezles.org/www/articles/normalsSDF/normalsSDF.htm)

``` cpp

vec3 calcNormal( in vec3 pos )
{
    vec2 e = vec2(1.0,-1.0)*0.5773*0.0005;
    return normalize( e.xyy*map( pos + e.xyy ) + 
					  e.yyx*map( pos + e.yyx ) + 
					  e.yxy*map( pos + e.yxy ) + 
					  e.xxx*map( pos + e.xxx ) );
}

``` 

2.方法二 : 
来自 klems 

``` cpp
vec3 calcNormal( in vec3 pos )
{
    vec3 n = vec3(0.0);
    for( int i=ZERO; i<4; i++ )
    {
        vec3 e = 0.5773*(2.0*vec3((((i+3)>>1)&1),((i>>1)&1),(i&1))-1.0);
        n += e*map(pos+0.0005*e).x;
    }
    return normalize(n);
}
``` 

我们要在render方法中计算他的法线：

``` cpp

    vec3 res = castRay(ro,rd) ;
    vec3 pos = ro + res.x * rd;
    vec3 normal = calcNormal( pos );

``` 

如果球的位置不对，那么我们也把球更新一下位置 

``` cpp

float map( in vec3 pos )
{
    return sdSphere( pos-vec3( 0.0,0.25, 0.0), 0.25 );
}

``` 

我们可以调整一下摄像机

``` cpp
    
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
    
``` 

## diffuse

既然我们法线也有了，我们现在就可以模拟一个灯光，然后做一个漫反射材质了 ：

``` cpp

vec3 render( in vec3 ro, in vec3 rd )
{ 
    vec3 col = vec3(0, 0, 0);
    vec3 res = castRay(ro,rd) ;
    vec3 normal = calcNormal(res.x * rd + ro);
    col =  sin( vec3(0.9,0.1,0.1));
    vec3  lig = normalize( vec3(-0.4, 0.7, -0.6) );
    float dif = clamp( dot( normal, lig ), 0.0, 1.0 );
    return dif * col ;
}

``` 
<div align=center> 

![normal vector preview](mdtexture/diffuse.jpg)

</div>


## other shading

``` cpp

vec3 render( in vec3 ro, in vec3 rd )
{ 
    vec3 col = vec3(0, 0, 0);
    vec3 res = castRay(ro,rd) ;
    vec3 pos = res.x * rd + ro ;
    vec3 normal = calcNormal(pos);
    vec3 ref = reflect( rd, normal );
    col =  sin( vec3(0.9,0.1,0.1));
    
    
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
    
    return vec3(fre);

}
``` 
<div align=center> 

![ambient preview](mdtexture/ambient.png)

![backColor preview](mdtexture/backColor.png)

![cubemap preview](mdtexture/cubemap.png)

![rim preview](mdtexture/rim.png)

</div>

## plane 地面 

我们在castray的时候指定一个范围来当作地面 

``` cpp

    float tmax = Max_Dist ;
    float tp1 = (0.0-ro.y)/rd.y;
    if( tp1>0.0 )
    {
        tmax = min( tmax, tp1 );
        res = vec3( tp1, 1.0 ,1.0);
    }

```

<div align=center> 

![normal vector preview](mdtexture/plane.png)

</div>

## 材质分离 

我们需要一种方法来区分不同的问题，地板还是sphere？
所以我们把map函数改一下，我们增加一个通道来区分他们
``` cpp
vec2 map( in vec3 pos )
{
    return vec2(sdSphere(  pos-vec3( 0.0,0.25, 0.0), 0.25 ),40) ;
}
``` 
第二个通道随便指定一个值就行 

此外我们就很多地方需要修改一下 
calcNormal函数中返回指定x通道
castRay函数中，判断指定x通道，res指定y通道
``` cpp
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

``` 


这样我们就可以根据res的y通道来区分材质了

``` cpp

vec3 render( in vec3 ro, in vec3 rd )
{ 
    vec3 col = vec3(0, 0, 0);
    vec3 res = castRay(ro,rd) ;
    float m = res.y;
    vec3 pos = res.x * rd + ro ;
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

    if( m>-0.5 ){
    
        if(m<1.5)
        	return vec3(1.0,1.0,1.0);
    	col =  sin( vec3(0.9,0.1,0.1));
    
    }
    return col ;
}

``` 
<div align=center> 

![normal vector preview](mdtexture/materialstep.png)

</div>


## plane Checkboard
同样来自iq大神的文章 
[checkerfiltering](http://iquilezles.org/www/articles/checkerfiltering/checkerfiltering.htm)
``` cpp
// 
float checkersGradBox( in vec2 p )
{
    // filter kernel
    vec2 w = fwidth(p) + 0.001;
    // analytical integral (box filter)
    vec2 i = 2.0*(abs(fract((p-0.5*w)*0.5)-0.5)-abs(fract((p+0.5*w)*0.5)-0.5))/w;
    // xor pattern
    return 0.5 - 0.5*i.x*i.y;                  
}

```

在地板选择材质中调用他 ：
``` cpp

        if(m<1.5)
        {  
            float f = checkersGradBox( 5.0*pos.xz );
            col = 0.3 + f*vec3(0.1);
            return col ;
        }

```

<div align=center> 

![normal vector preview](mdtexture/planeCheckBoard.png)

</div>