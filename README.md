# Bayer-Dithering-Shader

This Godot shader applies a dithering effect to a texture using Bayer matrix dithering. Download `bayer_mat_dither.gdshader` and add the shader to your material. You can also download the project files here to test out the shader.

Made with Godot 4.4

## Parameters

`int dither_type` - The type of dithering to apply to the texture. The 3 types of dithering are 'Flat', 'Gradient', and 'Point'.

`bool invert` - When set to true, the dithering effect inverts.

`int matrix_size` - The size of the matrix to apply dithering with. The available sizes are 2, 4, and 8. Lower matrix sizes give the dithering effect more contrast while higher sizes are smoother.

2x2 matrix:

![2x2](https://files.catbox.moe/2aaqsm.png)

4x4 matrix:

![4x4](https://files.catbox.moe/w8cqes.png)

8x8 matrix:

![8x8](https://files.catbox.moe/jqe1e9.png)

`bool debug` - Switches on debug mode. Use only for in editor testing. Debug mode will display a red pixel where your point is in the texture when using Point dithering and place red dots on the two gradient points in Gradient dithering.

### Flat Dithering

Flat Dithering applies a flat level of dithering to the entire texture.

![GIF of flat dithering](https://files.catbox.moe/fexawt.gif)

`float flat_dither_level` - The flat level of dithering to apply to the texture. Ranges between 0.0 and 1.0.

### Gradient Dithering

Gradient Dithering creates a dithering gradient between two points.

![GIF of gradient dithering](https://files.catbox.moe/rgnvci.gif)

`vec2 gradient_point_opaque` - The world point of the opaque end of the gradient.

`vec2 gradient_point_trans` - The world point of the transparent end of the gradient.

### Point Dithering

Point Dithering applies a dithering effect to a single point and extends outward.

![GIF of point dithering](https://files.catbox.moe/at4aj5.gif)

`vec2 dither_point` - The world point to apply the dithering effect.

`float dither_point_radius` - The radius in pixels of the dithering effect.

## Crediting

You are free to use this shader for commercial and non-commercial projects. Please attribute credit to n0cture or N0cturneDev. Links to the repository are appreciated.
