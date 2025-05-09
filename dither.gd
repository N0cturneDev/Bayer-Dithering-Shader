extends Sprite2D

@export var matrix_size: int = 2;
@export_enum("FLAT:0", "GRADIENT:1", "POINT:2") var dither_type: int = 1;
@export_range(0.0, 1.0) var flat_dither_level: float = 0.5;
@export var gradient_point_trans: Node;
@export var gradient_point_opaque: Node;
@export var invert: bool;
@export var debug: bool;

@export var invert_box: CheckBox;
@export var debug_box: CheckBox;
@export var flat_slider: HSlider;

func _ready():
	material.set("shader_parameter/matrix_size", matrix_size)
	material.set("shader_parameter/dither_type", dither_type)


func _process(delta):
	if Input.is_action_pressed("ui_up"):
		flat_dither_level = clamp(flat_dither_level + 0.02, 0.0, 1.0)
		flat_slider.value = flat_dither_level
	
	if Input.is_action_pressed("ui_down"):
		flat_dither_level = clamp(flat_dither_level - 0.02, 0.0, 1.0)
		flat_slider.value = flat_dither_level
	
	if Input.is_action_pressed("mouse1"):
		gradient_point_trans.global_position = get_viewport().get_mouse_position()
	
	if Input.is_action_pressed("mouse2"):
		gradient_point_opaque.global_position = get_viewport().get_mouse_position()
	
	if Input.is_action_just_pressed("invert"):
		invert = !invert
		invert_box.button_pressed = invert
	
	if Input.is_action_just_pressed("debug"):
		debug = !debug
		debug_box.button_pressed = debug
	
	if Input.is_action_just_pressed("2"):
		material.set("shader_parameter/matrix_size", 2)
	
	if Input.is_action_just_pressed("4"):
		material.set("shader_parameter/matrix_size", 4)
	
	if Input.is_action_just_pressed("8"):
		material.set("shader_parameter/matrix_size", 8)
	
	material.set("shader_parameter/dither_point", get_viewport().get_mouse_position())
	material.set("shader_parameter/gradient_point_trans", gradient_point_trans.global_position)
	material.set("shader_parameter/gradient_point_opaque", gradient_point_opaque.global_position)
	material.set("shader_parameter/flat_dither_level", flat_dither_level) 
	material.set("shader_parameter/invert", invert)
	material.set("shader_parameter/debug", debug) 


func _on_x_2_button_down():
	material.set("shader_parameter/matrix_size", 2)


func _on_x_4_button_down():
	material.set("shader_parameter/matrix_size", 4)


func _on_x_8_button_down():
	material.set("shader_parameter/matrix_size", 8)


func _on_item_list_item_selected(index):
	material.set("shader_parameter/dither_type", index)


func _on_spin_box_value_changed(value):
	material.set("shader_parameter/dither_point_radius", value) 


func _on_h_slider_value_changed(value):
	flat_dither_level = value


func _on_check_box_toggled(toggled_on):
	material.set("shader_parameter/invert", toggled_on)
	invert = toggled_on


func _on_check_box_2_toggled(toggled_on):
	material.set("shader_parameter/debug", toggled_on)
	debug = toggled_on
