extends Control

var move_done := true
var resolution_ratio := Vector2.ONE
var enabled := true

func _ready():
	Signals.connect("interactable_element_clicked", self, "_on_interactable_element_clicked")
	Signals.connect("interactable_element_awaiting", self, "_on_interactable_element_awaiting")
	get_tree().root.connect("size_changed", self, "_on_viewport_size_changed")
	_move()

func _process(delta):
	if enabled:
		if move_done:
			_move()
		#inject_mouse_moved()
		#call_deferred("inject_mouse_moved")
	


func _on_interactable_element_clicked():
	enabled = false
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self,"modulate",Color.transparent,0.2).from(Color.white)
	yield(tween, "finished")
	visible = false
	
func _on_interactable_element_awaiting():
	enabled = true
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self,"modulate",Color.white,0.2).from(Color.transparent)
	yield(tween, "finished")
	visible = true


func _on_viewport_size_changed():
	resolution_ratio = OS.get_window_size()/get_viewport_rect().size
	

func _move():
	move_done = false
	$"%Cursor".rect_position = Vector2.ZERO
	var tween2 = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween2.parallel().tween_property($"%Cursor","modulate",Color.white,0.2).from(Color.transparent).set_ease(Tween.EASE_IN)
	yield(tween2, "finished")
	yield(get_tree().create_timer(0.4), "timeout")
	#call_deferred("inject_left_click_pressed")
	#inject_left_click_pressed()
	
	$"%AnimationPlayer".play("ClickEffect")
	yield(get_tree().create_timer(0.4), "timeout")
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property($"%Cursor","rect_position",$"%Target".rect_position,0.7)
	tween.parallel().tween_property($"%Cursor","modulate",Color.transparent,0.7).from(Color.white).set_ease(Tween.EASE_IN)
	yield(tween, "finished")
	#call_deferred("inject_left_click_released")
	#inject_left_click_released()
	yield(get_tree().create_timer(0.8), "timeout")
	move_done = true


func inject_mouse_moved():
	var mouse = InputEventMouseMotion.new()
	mouse.global_position = $"%Cursor".rect_global_position*resolution_ratio
	mouse.position = mouse.global_position
	Input.parse_input_event(mouse)


func inject_left_click_pressed():
	
	var left_click = InputEventMouseButton.new()
	left_click.pressed = true
	left_click.button_index = 1  
	left_click.global_position = $"%Cursor".rect_global_position*resolution_ratio
	left_click.position = left_click.global_position
	Input.parse_input_event(left_click)


func inject_left_click_released():
	
	var left_click = InputEventMouseButton.new()
	left_click.pressed = false
	left_click.button_index = 1  
	left_click.global_position = $"%Cursor".rect_global_position*resolution_ratio
	left_click.position = left_click.global_position
	Input.parse_input_event(left_click)


func reset() -> void:
	modulate = Color.white
	move_done = false
	visible = true
	enabled = true
	
	$"%AnimationPlayer".play("RESET")
	
	_ready()


func show() -> void:
	#if not move_done:
	#	yield(get_tree().create_timer(1.7), "timeout")
	.show()
	enabled = true
	move_done = true


func hide() -> void:
	.hide()
	enabled = false
	move_done = false
	
