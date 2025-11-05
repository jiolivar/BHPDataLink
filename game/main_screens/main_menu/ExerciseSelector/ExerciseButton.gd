extends Control

var exercise_index := -1


func _ready():
	$"%Stars".hide()

func set_status(status := 0) -> void:
	match status:
		0:
			$"%Start".disabled = false
			$"%completed".visible = false
			$"%locked".visible = false
		1:
			$"%Start".disabled = false
			$"%completed".visible = true
			$"%locked".visible = false
		2:
			$"%Start".disabled = true
			$"%completed".visible = false
			$"%locked".visible = true


func set_text(_text : String) -> void:
	#$Start.text = _text
	$"%Label".text = _text


func set_alt(alt : bool) -> void:
	if alt:
		$"%Start".set("custom_styles/hover", preload("res://game/assets/ui/theme/button_hover2.tres"))
		$"%Start".set("custom_styles/pressed", preload("res://game/assets/ui/theme/button_pressed2.tres"))
		$"%Start".set("custom_styles/normal", preload("res://game/assets/ui/theme/button_normal2.tres"))
	else:
		$"%Start".set("custom_styles/hover", preload("res://game/assets/ui/theme/button_hover.tres"))
		$"%Start".set("custom_styles/pressed", preload("res://game/assets/ui/theme/button_pressed.tres"))
		$"%Start".set("custom_styles/normal", preload("res://game/assets/ui/theme/button_normal.tres"))


func _on_Start_pressed():
	if exercise_index >= 0:
		Transition.change_scene( Main.set_exercise_and_get(exercise_index) )
		$"%AudioStreamPlayer".play()


func show_stars(_show : bool) -> void:
	$"%Stars".show()


func set_points(points : int):
	match points:
		0:
			$"%Star1".appear_inmediate(false)
			$"%Star2".appear_inmediate(false)
			$"%Star3".appear_inmediate(false)
		1:
			$"%Star1".appear_inmediate(true)
			$"%Star2".appear_inmediate(false)
			$"%Star3".appear_inmediate(false)
		2:
			$"%Star1".appear_inmediate(true)
			$"%Star2".appear_inmediate(true)
			$"%Star3".appear_inmediate(false)
		3:
			$"%Star1".appear_inmediate(true)
			$"%Star2".appear_inmediate(true)
			$"%Star3".appear_inmediate(true)
