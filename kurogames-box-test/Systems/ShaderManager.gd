extends Node

func set_outline(sprite : Sprite2D , color : Color):
	# get the material reference
	var outline_mat = ShaderMaterial.new()
	outline_mat.shader = load("uid://bho7fbmbrs0x2")
	# Set the shader parameters (uniforms)
	outline_mat.set_shader_parameter("outline_thickness", 1.0)
	outline_mat.set_shader_parameter("outline_color", color)
	#outline_mat.set_shader_parameter("allow_out_of_bounds", true)
	# Assign outline material
	sprite.material = outline_mat

func remove_shader(sprite : Sprite2D):
	sprite.material = null
