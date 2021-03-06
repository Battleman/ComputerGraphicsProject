#version 330

in vec2 position;
out vec4 vpoint_mv;
out float cloud;
out vec2 uv;

uniform mat4 projection;
uniform mat4 model;
uniform mat4 view;
uniform sampler2D tex;
uniform int triangles_number;

uniform float speed;
const float height = 15;

void main() {
    mat4 MV = view * model;

    uv = (position + vec2(15.0, 15.0)) * 0.5/15.0;
    vpoint_mv = MV * vec4(position.x, position.y, height, 1.0);
    gl_Position = projection * vpoint_mv;

    cloud = texture(tex, vec2(mod(uv.x + speed, 1), uv.y)).r;

}
