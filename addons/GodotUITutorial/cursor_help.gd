extends Control

var move_done := true
var resolution_ratio := Vector2.ONE
var enabled := true
export var from_real_cursor := true

func _ready():
	get_tree().root.connect("size_changed", self, "_on_viewport_size_changed")
	_move()

func _process(delta):
	if enabled:
		if move_done:
			_move()


func _on_interactable_element_clicked():
	enabled = false
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self,"modulate",Color.transparent,0.2).from(Color.white)
	yield(tween, "finished")
	visible = false


func _on_viewport_size_changed():
	resolution_ratio = OS.get_window_size()/get_viewport_rect().size
	

func _move():
	move_done = false
	if from_real_cursor:
		var origin_pos = rect_global_position.direction_to(get_viewport().get_mouse_position())*150
		var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property($"%Cursor","rect_position",Vector2.ZERO,0.7).from(origin_pos)
		tween.parallel().tween_property($"%Cursor","modulate",Color.white,0.6).from(Color.transparent)
		yield(tween, "finished")
		$"%AnimationPlayer".play("ClickEffect")
		yield(get_tree().create_timer(0.4), "timeout")
		var tween2 = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween2.tween_property($"%Cursor","modulate",Color.transparent,0.2).from(Color.white)
		yield(tween2, "finished")
		yield(get_tree().create_timer(0.8), "timeout")
	else:
		$"%Cursor".rect_position = Vector2.ZERO
		var tween2 = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween2.parallel().tween_property($"%Cursor","modulate",Color.white,0.2).from(Color.transparent)
		yield(tween2, "finished")
		yield(get_tree().create_timer(0.4), "timeout")
		$"%AnimationPlayer".play("ClickEffect")
		yield(get_tree().create_timer(0.4), "timeout")
		var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property($"%Cursor","rect_position",$"%Target".rect_position,0.7)
		tween.parallel().tween_property($"%Cursor","modulate",Color.transparent,0.7).from(Color.white).set_ease(Tween.EASE_IN)
		yield(tween, "finished")
		yield(get_tree().create_timer(0.8), "timeout")
	move_done = true


func reset() -> void:
#	modulate = Color.white
#	move_done = false
#	visible = true
	enabled = true
	
	$"%AnimationPlayer".seek(0)
#	$"%AnimationPlayer".play("RESET")
	
#	_ready()
