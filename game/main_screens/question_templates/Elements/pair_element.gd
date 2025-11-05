tool

extends InteractableElement

class_name PairElement

var grabbed := false
var is_on_left_side := true
var current_other_pair_elements = []
var initial_line_point : Vector2
var end_line_point : Vector2


func _ready():
	#make sure its unique, local to scene sometimes doesn't work
	var unique_shape = $"%CollisionShape2D".shape.duplicate()
	$"%CollisionShape2D".shape = unique_shape
	get_tree().root.connect("size_changed", self, "_on_viewport_size_changed")
	$"%Line2D".visible = false
	$"%MouseArea".visible = false
	is_on_left_side = global_position.x < 0
	._ready()

func _on_viewport_size_changed():
	is_on_left_side = global_position.x < 0


func _on_Label_minimum_size_changed():
	_apply_settings()


func _process(delta):
	._process(delta)
	if grabbed:
		$"%Line2D".visible = true
		$"%MouseArea".global_position = get_viewport().get_mouse_position()
		end_line_point = get_viewport().get_mouse_position()-$"%Line2D".global_position
	$"%Line2D".points[1] = end_line_point

func _apply_settings():
	._apply_settings()
	if image:
		$"%Border".visible = false
		$"%Line2D".points[0].y = 0
		if is_on_left_side:
			$"%Line2D".points[0].x = $"%CollisionShape2D".shape.extents.x
		else:
			$"%Line2D".points[0].x = -$"%CollisionShape2D".shape.extents.x
	else:
		if is_on_left_side:
			$"%Line2D".points[0].x = $"%CollisionShape2D".shape.extents.x*2.0-20
			$"%Line2D".points[0].y = $"%CollisionShape2D".shape.extents.y-10
		else:
			$"%Line2D".points[0].x = -20
			$"%Line2D".points[0].y = $"%CollisionShape2D".shape.extents.y-10
	initial_line_point = $"%Line2D".points[0]
	$"%Line2D".default_color = Color.red * (1-id*0.1)
	$"%Border".rect_size = $"%Label".rect_size+Vector2(40,20)#$"%HighLite".rect_size
	$"%Border".rect_position = $"%HighLite".rect_position


func _on_PairElement_input_event(viewport, event, shape_idx):
	if not completed and event is InputEventMouseButton and event.pressed:
		grabbed = true
		$"%Line2D".visible = true
		$"%MouseArea".visible = true

func _input(event):
	if grabbed and not completed and event is InputEventMouseButton and not event.pressed:
		grabbed = false
		if current_other_pair_elements.size():
			var valid_pair_element
			for pair_element in current_other_pair_elements:
				if id == pair_element.id:
					valid_pair_element = pair_element
			if valid_pair_element and valid_pair_element.id == id:
				$"%CorrectAudio".play()
				end_line_point = valid_pair_element.position-position+valid_pair_element.initial_line_point
				completed = true
				valid_pair_element.completed = true
				$"%MouseArea".visible = false
				emit_signal("notify_correct")
				valid_pair_element.emit_signal("notify_correct")
			else:
				$"%WrongAudio".play()
				emit_signal("notify_wrong")
				_return_line()
		else:
			_return_line()
			

func _return_line():
	$"%MouseArea".visible = false
	var distance = $"%Line2D".points[0].distance_to($"%Line2D".points[1])
	$"%ReturnAudio".volume_db = clamp(-(30-distance*0.05), -30, -10)
	$"%ReturnAudio".play()
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self,"end_line_point",$"%Line2D".points[0],0.3)
	yield(tween, "finished")
	$"%Line2D".visible = false
	

func get_id():
	return id

func _on_MouseArea_area_entered(area):
	if area.has_method("get_id") and area != self:
		current_other_pair_elements.push_back(area)
		area.set_highlite(true)


func _on_MouseArea_area_exited(area):
	current_other_pair_elements.erase(area)
	if area.has_method("set_highlite"):
		area.set_highlite(false)


# override

func _calcule_label_position() -> Vector2:
	return Vector2.ZERO

func _calcule_collision_shape_position() -> Vector2:
	return $"%CollisionShape2D".shape.extents-Vector2(20,10)

func _calcule_highlite_position() -> Vector2:
	return -Vector2(20,10)

