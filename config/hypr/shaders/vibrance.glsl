// Simple saturation boost shader for Hyprland (screen_shader)
#version 300 es
precision highp float;
in highp vec2 v_texcoord;
uniform sampler2D tex;

out vec4 fragColor;

// Adjust this to taste: 1.0 = no change, 1.3-1.6 = noticeable boost
const float SATURATION = 1.3;

void main() {
    vec4 pixColor = texture(tex, v_texcoord);
    float gray = dot(pixColor.rgb, vec3(0.299, 0.587, 0.114));
    vec3 boosted = mix(vec3(gray), pixColor.rgb, SATURATION);
    fragColor = vec4(boosted, pixColor.a);
}
