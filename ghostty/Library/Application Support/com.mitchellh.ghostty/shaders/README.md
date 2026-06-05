# Ghostty cursor shaders

This folder was copied from:

- https://github.com/sahaj-b/ghostty-cursor-shaders

I am keeping the upstream notes here because the shader options are not self-explanatory.

## Note

These shaders are very customizable.

## Demos

| Effect                              | Demo                                                                                                 |
| --------                            | ------                                                                                               |
| Cursor Warp<br>(Neovide-like)       | ![cursor_warp](https://github.com/user-attachments/assets/5323330c-e09d-4d80-963b-f0cb8413cac9)      |
| Cursor Sweep                        | ![cursor_sweep](https://github.com/user-attachments/assets/c8979569-e0fa-48f1-afd7-9eed36df7f0a)     |
| Cursor Tail<br>(Kitty-like)         | ![cursor_tail](https://github.com/user-attachments/assets/0c1ecd67-8ff4-4198-9e89-a4435289bfa0)      |
| Ripple Cursor                       | ![ripple_cursor](https://github.com/user-attachments/assets/e489f74e-620a-490a-b5c5-d3918a5077c1)    |
| Sonic Boom                          | ![sonic_boom](https://github.com/user-attachments/assets/91ac80e6-aa2b-41a3-8b49-d674ce287709)       |
| Ripple Rectangle                    | ![ripple_rectangle](https://github.com/user-attachments/assets/5c8028eb-6ffb-4e38-a5dd-e2c0ed6a4175) |
| Customized<br>(faded warp + ripple) | ![customized_warp](https://github.com/user-attachments/assets/3be0d82e-2bff-48ab-824e-3262cbb10d4d)  |

## Trails
- [cursor_warp.glsl](cursor_warp.glsl): Neovide-like cursor trail, most customizable shader
- [cursor_sweep.glsl](cursor_sweep.glsl): Animated trail that shrinks from previous to current cursor position
- [cursor_tail.glsl](cursor_tail.glsl): Comet-like trail, mimicking kitty terminal's `cursor_trail` effect

## Pulse/Boom effects
- These trigger on cursor mode changes (block to line or vice versa, looks cool on changing modes in vim)
- [sonic_boom_cursor.glsl](sonic_boom_cursor.glsl): expanding filled circle 
- [ripple_cursor.glsl](ripple_cursor.glsl): Expanding circular ring ripple effect
- [rectangle_boom_cursor.glsl](rectangle_boom_cursor.glsl): Same as boom_cursor but rectangular(cursor shape)
- [ripple_rectangle_cursor.glsl](ripple_rectangle_cursor.glsl): Same as ripple_cursor but rectangular(cursor shape)


> [!NOTE]
> If you have the line cursor (default), these effects will trigger and freeze on unfocus(as cursor changes to hollow block). The solution is to add `custom-shader-animation = always` to your ghostty config

## Usage

1. Put the shader files in the Ghostty shaders directory:
```bash
git clone https://github.com/sahaj-b/ghostty-cursor-shaders ~/.config/ghostty/shaders
```

2. In your `~/.config/ghostty/config`, add:
```config
custom-shader = shaders/yourshader1.glsl
custom-shader = shaders/yourshader2.glsl
# ...
```
Replace `yourshader` with the name of any shader file, for example `cursor_sweep` or `ripple_cursor`.


## Customization
- Every shader has adjustable parameters at the top of the file: color, duration, size, thickness, and so on.
- Each file also has easing function choices.
  - These control the animation curve.
  - In trail shaders, comment or uncomment the easing functions in the code.
  - In pulse and boom shaders, comment or uncomment the lines in the `ANIMATION` section.
  - Adding a custom easing function is straightforward if needed.

### Example (faded warp + ripple)
```glsl
// in cursor_warp.glsl
const float DURATION = 0.15;
const float TRAIL_SIZE = 0.8;
const float THRESHOLD_MIN_DISTANCE = 1.0;
const float BLUR = 1.0;
const float TRAIL_THICKNESS = 1.0;
const float TRAIL_THICKNESS_X = 0.9;

const float FADE_ENABLED = 1.0;
const float FADE_EXPONENT = 5.0;
```
```glsl
// in ripple_cursor.glsl
const float DURATION = 0.15;
const float MAX_RADIUS = 0.026;
const float RING_THICKNESS = 0.02;
const float CURSOR_WIDTH_CHANGE_THRESHOLD = 0.5;
vec4 COLOR = vec4(0.35, 0.36, 0.44, 0.8);
const float BLUR = 3.5;
const float ANIMATION_START_OFFSET = 0.01;
```

## Acknowledgements
Inspired by [Neovide](https://neovide.dev/) cursor animations and [KroneCorylus/ghostty-shader-playground](https://github.com/KroneCorylus/ghostty-shader-playground)

## License
MIT

## Why use branching (`if`/`else`) instead of branchless math

- This uses uniform branching, so there is no divergence penalty.
- All fragments take the same branch path.
- Branchless math would force the GPU to evaluate animations every frame, even when nothing is happening.
