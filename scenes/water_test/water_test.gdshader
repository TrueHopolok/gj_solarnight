shader_type canvas_item;
uniform vec2 pixel_size = vec2(1.0, 1.0);
uniform float effect_scale = 1.0;
uniform vec3 col1 : source_color = vec3(0.239, 0.714, 0.984);
uniform vec3 modulate : source_color = vec3(1.,1.,1.);

// Color controls
uniform vec3 base_cell_color : source_color = vec3(0.0, 0.4, 1.4);
uniform float threshold_low  : hint_range(0.0, 1.0) = 0.64;
uniform float threshold_high : hint_range(0.0, 1.0) = 0.655;
uniform float brightness_mid  : hint_range(0.0, 3.0) = 1.0;
uniform float brightness_high : hint_range(0.0, 3.0) = 1.45;

vec2 hash2( vec2 p ) { p = vec2( dot(p,vec2(127.1,311.7)), dot(p,vec2(269.5,183.3)) ); return fract(sin(p)*43758.5453); }

vec4 voronoi( in vec2 x, float w, float di )
{
    vec2 n = floor( x );
    vec2 f = fract( x );
    vec4 m = vec4( 8.0, 0.0, 0.0, 0.0 );
    for( int j=-2; j<=2; j++ )
    for( int i=-2; i<=2; i++ )
    {
        vec2 g = vec2( float(i), float(j) );
        vec2 o = hash2( n + g );
        o = 0.5*sin( TIME + 6.2831*o );
        float d = 1.2*length(g - f + o);
        vec3 col = base_cell_color;  // <-- was hardcoded
        float h = smoothstep( -1.5, 0.3, (m.x-di*d)/w );
        m.x   = mix( m.x,   d,   h ) - h*(1.0-h)*w/(1.0+3.0*w);
        m.yzw = mix( m.yzw, col, h ) + h*(1.0-h)*w/(1.0+3.0*w);
    }
    return m;
}

void fragment()
{
    vec2 snapped_uv = floor(UV * pixel_size) / pixel_size * effect_scale;
    vec2 p = snapped_uv / vec2(TEXTURE_PIXEL_SIZE.y);
    float scale = 4.0;
    vec4 v1 = voronoi( 0.7*scale*p, 0.3, 1.5 );
    vec4 v2 = voronoi( 2.0*scale*p, 0.3, 0.8 );
    vec4 v3 = voronoi( 4.0*scale*p, 0.3, 0.4 );
    vec4 v = (2.0*v1 + 0.5*v2 + 0.5*v3) / 3.0;
    vec3 col = sqrt(v.yzw);
    if (col.g > threshold_low && col.g < threshold_high)
        col = brightness_mid  * col1;
    else if (col.g >= threshold_high)
        col = brightness_high * col1;
    COLOR = vec4(max(min(col, 1.), 0.) * modulate, 1.0);
}