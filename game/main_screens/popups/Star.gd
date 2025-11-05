extends Control

const anim_speed = 0.8

export var start_hidden := true 
export var bg_modulate := Color(0.188235, 0.188235, 0.188235, 0.231373)

func _ready():
	$"%StarIconBG".modulate = bg_modulate
	if start_hidden:
		$"%StarIcon".rect_scale = Vector2.ZERO
		$"%CPUParticles2D".position = $"%CPUParticles2D".position*(rect_size.x/90.0)


func appear(index : int):
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property($"%StarIcon","rect_scale",Vector2.ONE,anim_speed).from(Vector2.ZERO)
	$"%CPUParticles2D".emitting = true
	yield(get_tree().create_timer(0.3), "timeout")
	$"%AudioStreamPlayer".pitch_scale = 0.8 + index*0.2
	$"%AudioStreamPlayer".play()


func appear_inmediate(_appear : bool):
	$"%StarIcon".rect_scale = Vector2.ONE if _appear else Vector2.ZERO
