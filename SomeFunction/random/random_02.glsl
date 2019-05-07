float randSeed;

uint tausStep(uint z,int s1,int s2,int s3,uint M){
    uint b=(((z << s1) ^ z) >> s2);
    return (((z & M) << s3) ^ b);
}

void initRandom(uint seed1,uint seed2,uint seed3){
    uint seed = seed1 * 1099087573U;
    uint seedb = seed2 * 1099087573U;
    uint seedc = seed3 * 1099087573U;

    // Round 1: Randomise seed
    uint z1 = tausStep(seed,13,19,12,429496729U);
    uint z2 = tausStep(seed,2,25,4,4294967288U);
    uint z3 = tausStep(seed,3,11,17,429496280U);
    uint z4 = (1664525U*seed + 1013904223U);

    // Round 2: Randomise seed again using second seed
    uint r1 = (z1^z2^z3^z4^seedb);

    z1 = tausStep(r1,13,19,12,429496729U);
    z2 = tausStep(r1,2,25,4,4294967288U);
    z3 = tausStep(r1,3,11,17,429496280U);
    z4 = (1664525U*r1 + 1013904223U);

    // Round 3: Randomise seed again using third seed
    r1 = (z1^z2^z3^z4^seedc);

    z1 = tausStep(r1,13,19,12,429496729U);
    z2 = tausStep(r1,2,25,4,4294967288U);
    z3 = tausStep(r1,3,11,17,429496280U);
    z4 = (1664525U*r1 + 1013904223U);

    randSeed = float(z1^z2^z3^z4) * 2.3283064365387e-10;
}

float getRand(){
    uint hashed_seed = uint(randSeed * float(1099087573U));

    uint z1 = tausStep(hashed_seed,13,19,12,429496729U);
    uint z2 = tausStep(hashed_seed,2,25,4,4294967288U);
    uint z3 = tausStep(hashed_seed,3,11,17,429496280U);
    uint z4 = (1664525U*hashed_seed + 1013904223U);

    float old_seed = randSeed;

    randSeed = float(z1^z2^z3^z4) * 2.3283064365387e-10;

    return old_seed;
}

void main() {
  float time = iGlobalTime * 1.0;
   vec2 uv =  gl_FragCoord.xy  / iResolution.xy;
   //uv -= 0.5;
   //uv.x *= iResolution.x / iResolution.y;
   //uv *= 2.0;

    uint seedX=uint((uv*vec2(1024)).x);
    uint seedY=uint((uv*vec2(1024)).y);
    uint seedZ=uint(iFrame);
    initRandom(seedX,seedY,seedZ);
    float d = getRand();
    gl_FragColor = vec4(d,d,d,1.0);
    gl_FragColor.a = 1.0;
}