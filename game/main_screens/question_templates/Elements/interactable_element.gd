tool

extends Area2D

class_name InteractableElement

export var id := 0
export(String, MULTILINE) var text = ""
export(Texture) var image
export var image_scale := 1.0

export var custom_collision_transform := false

var settings_applied := 0
var completed := false

signal notify_correct
signal notify_wrong

func _ready():
	_apply_settings()
	
func _process(delta):
	if Engine.is_editor_hint() or settings_applied<5: #not sure why need 5 times to work
		_apply_settings()
		settings_applied = settings_applied+1

func _apply_settings():
	if image:
		$"%Icon".material.set_shader_param("width",0.0/image_scale)
		if not Engine.is_editor_hint():
			$"%Icon".material.set_shader_param("color",Main.highlite_color)
		$"%Icon".texture = image
		$"%Icon".scale = Vector2.ONE*image_scale
		$"%CollisionShape2D".shape.extents = $"%Icon".texture.get_size()*image_scale*0.5+Vector2.ONE*5
		$"%CollisionShape2D".position = Vector2.ZERO
	else:
		$"%Label".text = text
		$"%Label".rect_position = _calcule_label_position()
		
		$"%CollisionShape2D".shape.extents = $"%Label".rect_size*0.5+Vector2(20,10)
		if not custom_collision_transform:
			#$"%CollisionShape2D".position = $"%CollisionShape2D".shape.extents-Vector2(20,10)
			$"%CollisionShape2D".position = _calcule_collision_shape_position() #$"%CollisionShape2D".shape.extents*-0.5 -Vector2(20,10)
		
		$"%HighLite".rect_size = $"%Label".rect_size+Vector2(40,20)
		if not custom_collision_transform:
			#$"%HighLite".rect_position = -Vector2(20,10)
			$"%HighLite".rect_position = _calcule_highlite_position()
		if not Engine.is_editor_hint():
			$"%HighLite".get("custom_styles/panel").border_color = Main.highlite_color
			$"%HighLite".get("custom_styles/panel").border_width_bottom = Main.highlight_width
			$"%HighLite".get("custom_styles/panel").border_width_left = Main.highlight_width
			$"%HighLite".get("custom_styles/panel").border_width_right = Main.highlight_width
			$"%HighLite".get("custom_styles/panel").border_width_top = Main.highlight_width



func _calcule_label_position() -> Vector2:
	return $"%Label".rect_size*-0.5

func _calcule_collision_shape_position() -> Vector2:
	return Vector2.ZERO

func _calcule_highlite_position() -> Vector2:
	return $"%Label".rect_size*-0.5 - Vector2(20,10)


func get_id():
	return id

func set_highlite(_enable : bool):
	if image:
		$"%Icon".material.set_shader_param("width",int(_enable and not completed)*Main.highlight_width/image_scale)
	else:
		$"%HighLite".visible = _enable and not completed

func _on_InteractableElement_mouse_entered():
	if not Main.grabbing_element:
		set_highlite(true)


func _on_InteractableElement_mouse_exited():
	set_highlite(false)


func _on_InteractableElement_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		Signals.emit_signal("interactable_element_clicked")
