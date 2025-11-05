tool

extends Control

class_name BaseQuestionPanel

export var title := ""
export var enunc := ""
export(String, MULTILINE) var question
export var auto_show := true
const anim_speed = 0.5

signal notify_end_prev
signal notify_end

func _ready():
	visible = false
	_apply_settings()
	
	if auto_show:
		yield(get_tree().create_timer(0.2), "timeout")
		show()
		
func _process(delta):
	if Engine.is_editor_hint():
		_apply_settings()

func _apply_settings():
	$"%Title".text = title
	$"%Enunc".text = enunc
	$"%Question".text = question

func show():
	visible = true
	$"%SwipeAudio".play()
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self,"rect_position",Vector2.ZERO,anim_speed).from(rect_position-Vector2(rect_size.x,0))
	
	
func end(_end_prev : bool = false):
	yield(get_tree().create_timer(0.2), "timeout")
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(self,"rect_position",rect_position+Vector2(rect_size.x,0),anim_speed).from(Vector2.ZERO)
	yield(get_tree().create_timer(0.3), "timeout")
	$"%SwipeAudio".play()
	yield(tween, "finished")
	visible = false
	if _end_prev:
		emit_signal("notify_end_prev")
	else:
		emit_signal("notify_end")
	
	
