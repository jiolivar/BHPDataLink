extends Control

var splash_duration := 1.8

# Called when the node enters the scene tree for the first time.
func _ready():
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property($"%Logo","modulate",Color.white,0.8).from(Color.transparent)
	tween.parallel().tween_property($"%Logo","scale",Vector2(0.3, 0.3),splash_duration+0.5)
	yield(get_tree().create_timer(splash_duration), "timeout")
	Transition.change_scene("res://game/main_screens/main_menu/main_menu.tscn")
	
	
	
