shader_type canvas_item;

// Variables with 'position' are done with uv coordinates and are between 0.0 and 1.0. Variables with
// 'point' are done int pixel coordinates.

/**
 * The type of dithering to apply to your texture.
 * FLAT: Flat dithering applies a flat level of dithering to the entire texture.
 * GRADIENT: Gradient dithering takes in two points and generates a gradient between them.
 * POINT: Point dithering takes in a single world point and a radius to dither around that point.
 */
uniform int dither_type: hint_enum("FLAT", "GRADIENT", "POINT");

/**
 * Inverts the opaque and transparent parts of the dither.
 */
uniform bool invert;

/**
 * The size in pixels of bayer matrix to apply. Lower sizes have more contrast while higher sizes are smoother.
 */
uniform int matrix_size: hint_enum("2:2", "4:4", "8:8") = 2;

group_uniforms Flat_Dithering;
/**
 * Level of dither used for texture. 0.0 is trasparent and 1.0 is opaque.
 * Used only for FLAT type dithering.
 */
uniform float flat_dither_level: hint_range(0, 1.0) = 0.5;
group_uniforms;

group_uniforms Gradient_Dithering;
/**
 * The world point where the gradient becomes opaque.
 * Used only for GRADIENT type dithering.
 */
uniform vec2 gradient_point_opaque;
/**
 * The world point where the gradient becomes transparent.
 * Used only for GRADIENT type dithering.
 */
uniform vec2 gradient_point_trans;
group_uniforms;

group_uniforms Point_Dithering;
/**
 * The point in world position of where to apply dithering.
 * Used only for POINT type dithering.
 */
uniform vec2 dither_point;
/**
 * The radius in pixels of the dither point.
 * Used only for POINT type dithering.
 */
uniform float dither_point_radius = 16.0;
group_uniforms;

/**
 * Enables debugging features.
 */
uniform bool debug = false;


const float EPSILON = 0.0001;
const mat2 BAYER_2x2 = mat2(vec2(0.0, 3.0),
                            vec2(2.0, 1.0)) / 4.0;
const mat4 BAYER_4x4 = mat4(vec4(0.0, 8.0, 2.0, 10.0),
                            vec4(12.0, 4.0, 14.0, 6.0),
							vec4(3.0, 11.0, 1.0, 9.0),
							vec4(15.0, 7.0, 13.0, 5.0)) / 16.0;
// Matricies only go as high as 4 so the 8x8 matrix is an array accessed via [y + (x * n)] rather than [x][y]
const float BAYER_8x8[64] = {
								0.0, 32.0, 8.0, 40.0, 2.0, 34.0, 10.0, 42.0,
                                48.0, 16.0, 56.0, 24.0, 50.0, 18.0, 58.0, 26.0,
								12.0, 44.0, 4.0, 36.0, 14.0, 46.0, 6.0, 38.0,
								60.0, 28.0, 52.0, 20.0, 62.0, 30.0, 54.0, 22.0,
								3.0, 35.0, 11.0, 43.0, 1.0, 33.0, 9.0, 41.0,
								51.0, 19.0, 59.0, 27.0, 49.0, 17.0, 57.0, 25.0,
								15.0, 47.0, 7.0, 39.0, 13.0, 45.0, 5.0, 37.0,
								63.0, 31.0, 55.0, 23.0, 61.0, 29.0, 53.0, 21.0
                              };

// Variables calculated in vertex.
varying vec2 current_vertex;
varying vec2 current_world_vertex;

/*
	inout vec4 color - pass in COLOR variable here.
	float fragment_dither - dither threshold of fragment. Range 0.0 - 1.0
	float dither_level - level of dithering to be applied. Range 0.0 - 1.0
	bool lowest_threshold_inclusive - true if lowest threshold applied. (Used for
		lowest level of dithering to be applied to the dither range).
*/
void apply_dithering(inout vec4 color, float fragment_dither, float dither_level, bool lowest_threshold_inclusive) {
	// If the lowest threshold (no dithering) is not included in the range, then
	// alter the fragment dither to exclude it.
	float matrix_length = pow(float(matrix_size), 2.0);
	if (!lowest_threshold_inclusive) {
		// If the lowest threshold is not included then oftset the number of levels
		// by 1
		fragment_dither /= (matrix_length - 1.0) / matrix_length;
	}

	// If dither_level is greater than the next fragment dither set to transparent.
	// If lowest inclusive
	bool is_past_threshold = (fragment_dither + (1.0 / matrix_length) * float(lowest_threshold_inclusive)
							< dither_level + EPSILON && 0.0
							<= dither_level - EPSILON)
	    				!= invert;

	if (is_past_threshold) {
		// If you want to apply an effect that isn't transparancy to the texture, change
		// the code here:
		color.a = 0.0;
	}
}

void vertex() {
	current_vertex = VERTEX;
	current_world_vertex = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	float fragment_dither = 0.0;

	int x = int(mod(current_vertex.y, float(matrix_size)) + EPSILON);
	int y = int(mod(current_vertex.x, float(matrix_size)) + EPSILON);
	switch(matrix_size) {
		case 2:
			fragment_dither = BAYER_2x2[x][y];
			break;

		case 4:
			fragment_dither = BAYER_4x4[x][y];
			break;

		case 8:
			// Arrays can't be divided at initiation so this is divided at access.
			fragment_dither = BAYER_8x8[y + (x * matrix_size)] / 64.0;
			break;

		default:
			fragment_dither = 0.0;
			break;
	}

	// If you want to apply an effect that isn't transpar
	switch (dither_type) {
		case 0: // FLAT
			apply_dithering(COLOR, fragment_dither, clamp(flat_dither_level, 0.0, 1.0), false);
			break;

		case 1: // GRADIENT
			vec2 x_to_y = gradient_point_opaque - gradient_point_trans;
			vec2 x_to_z = current_world_vertex - gradient_point_trans;
			float w = dot(x_to_y, x_to_z) / length(x_to_y);
			apply_dithering(COLOR, fragment_dither, clamp(w / distance(gradient_point_trans, gradient_point_opaque), 0.0, 1.0), false);
			if (debug
				&& ((current_world_vertex.x + EPSILON >= gradient_point_opaque.x && current_world_vertex.y + EPSILON >= gradient_point_opaque.y
					&& current_world_vertex.x - EPSILON <= gradient_point_opaque.x + 1.0 && current_world_vertex.y - EPSILON <= gradient_point_opaque.y + 1.0)
				|| (current_world_vertex.x + EPSILON >= gradient_point_trans.x && current_world_vertex.y + EPSILON >= gradient_point_trans.y
					&& current_world_vertex.x - EPSILON <= gradient_point_trans.x + 1.0 && current_world_vertex.y - EPSILON <= gradient_point_trans.y + 1.0))) {
					COLOR = vec4(1.0, 0.0, 0.0, 1.0);
			}
			break;

		 case 2: // POINT
			float length_from_point = distance(current_world_vertex, dither_point);
			apply_dithering(COLOR, fragment_dither, clamp(length_from_point / dither_point_radius, 0.0, 1.0), true);
			if (debug
				&& current_world_vertex.x + EPSILON >= dither_point.x && current_world_vertex.y + EPSILON >= dither_point.y
				&& current_world_vertex.x - EPSILON <= dither_point.x + 1.0 && current_world_vertex.y - EPSILON <= dither_point.y + 1.0) {
					COLOR = vec4(1.0, 0.0, 0.0, 1.0);
			}
			break;
	}
}