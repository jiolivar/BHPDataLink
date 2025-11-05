extends Button

var tab_index := -1

func set_tab_index(_tab_index : int) -> void:
	tab_index = _tab_index
	$"%Text".text = _get_button_text(_tab_index)
	if tab_index == 0:
		$"%TextureRect".texture = preload("res://assets/images/mini1.png")
	elif tab_index == 1:
		$"%TextureRect".texture = preload("res://assets/images/mini2.png")
	elif tab_index == 2:
		$"%TextureRect".texture = preload("res://assets/images/mini3.png")


func _get_button_text(_tab_index: int) -> String:
	var start = _tab_index * 40 + 1
	var end = (_tab_index + 1) * 40
	return "NIVEL %d: %02d - %d VEHICULOS" % [_tab_index, start, end]
