// SPDX-License-Identifier: BSD Zero Clause License
// Taken from https://github.com/silvematt/ghostty-shaders
// by Matt Delac and contributors

float cursor_distance(vec2 uv) {
    vec2 cursor = iMouse.xy / iResolution.xy;
    cursor.y = 1.0 - cursor.y;
    vec2 scaled_uv = uv * iResolution.xy / max(iResolution.x, iResolution.y);
    vec2 scaled_cursor = cursor * iResolution.xy / max(iResolution.x, iResolution.y);

    return distance(scaled_uv, scaled_cursor);
}

vec2 cursor_direction(vec2 uv) {
    vec2 cursor = iMouse.xy / iResolution.xy;
    cursor.y = 1.0 - cursor.y;
    return uv - cursor;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    float distance = cursor_distance(uv);

    vec2 direction = cursor_direction(uv);
    vec2 warped_uv = uv + direction * -0.15 * exp(-distance * 6.0);

    fragColor = texture(iChannel0, warped_uv);
}
