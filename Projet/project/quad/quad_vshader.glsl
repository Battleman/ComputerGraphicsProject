#version 330

in vec2 position;

out vec3 light_dir, view_dir;
out vec4 vpoint_mv;
out vec3 material;
out float height;
out float visibility;
out vec3 normals_mv;

uniform mat4 projection;
uniform mat4 model;
uniform mat4 view;
uniform sampler2D tex;
uniform sampler2D tex2;
uniform sampler2D tex3;
uniform sampler2D tex4;
uniform vec3 light_pos;
uniform int triangles_number;

const float density = 0.07;
const float gradient = 10;

void main() {
    mat4 MV = view * model;

    vec2 uv = (position + vec2(10.0, 10.0)) * 0.05;
    vec3 normal_mv = vec3(0.0);
    height = texture(tex,uv).r+0.5;

    vpoint_mv = MV * vec4(position.x,position.y,height, 1.0);
    gl_Position = projection * vpoint_mv;
    light_dir = normalize(light_pos-vec3(vpoint_mv));
    view_dir = normalize(-vec3(vpoint_mv));

    float distance = length(vpoint_mv.xyz);
    visibility = exp(-pow((distance*density),gradient));
    visibility = clamp(visibility, 0.0, 1.0);

    float offset = 0.1;
    vec4 X0point_mv = MV * vec4(position.x-offset,position.y,texture(tex,vec2((position.x+offset+10.0f)*0.05,uv.y)).r, 1.0);
    vec4 Y0point_mv = MV * vec4(position.x,position.y-offset,texture(tex,vec2(uv.x,(position.y+offset+10.0f)*0.05)).r, 1.0);
    vec4 X1point_mv = MV * vec4(position.x+offset,position.y,texture(tex,vec2((position.x-offset+10.0f)*0.05,uv.y)).r, 1.0);
    vec4 Y1point_mv = MV * vec4(position.x,position.y+offset,texture(tex,vec2(uv.x,(position.y-offset+10.0f)*0.05)).r, 1.0);

    vec3 X = X1point_mv.xyz - X0point_mv.xyz;
    vec3 Y = Y1point_mv.xyz - Y0point_mv.xyz;
    normal_mv += normalize(cross(X,Y));
    normals_mv = normal_mv;

    //Next we use a gaussian function to make the color changes smoother
    vec3 height_material = vec3(0.0,0.0,0.0);
    float variance = 0.0;
    float color_height = 0.0;

    //sand: yellow, at height 0.05, spread: -0.45 to -0.35
    variance = 0.1;
    color_height = 0.05;
    height_material += exp((-pow((height-color_height),2))/(2*variance*variance)) * texture(tex4,uv).rgb;

    //dirt: brown, at height 0.2, spread: -0.35 to -0.25
    variance = 0.05;
    color_height = 0.20;
    height_material += exp((-pow((height-color_height),2))/(2*variance*variance)) * vec3(0.3,0.2,0.0);

    //grass/trees: green, at height 0.35, spread: -0.25 to -0.05
    variance = 0.1;
    color_height = 0.35;
    height_material += exp((-pow((height-color_height),2))/(2*variance*variance)) * texture(tex3,uv*10).rgb;

    //mountain: grey, at height 0.65, spread: -0.05 to 0.35
    variance = 0.20;
    color_height = 0.65;
    height_material += exp((-pow((height-color_height),2))/(2*variance*variance)) * texture(tex2,uv).rgb;

    //mountain top: white, at height 0.90, spread: 0.35 to 0.40
    variance = 0.05;
    color_height = 0.90;
    height_material += exp((-pow((height-color_height),2))/(2*variance*variance)) * vec3(1.0,1.0,1.0);

    if(height > 0.90) {
        height_material = vec3(1.2,1.2,1.2); // snow
    }

    if(height < 0.90 && height > 0.25 && (normal_mv.x < 0.25 || normal_mv.y < 0.25)) {
        height_material = mix(height_material, texture(tex2,uv).rgb, 0.3);
    }

    material = height_material;

}
