extends Panel

export var category_name := "ALTO RIESGO"

func _ready():
	$"%CategoryName".text = category_name

func set_count(count : int) -> void:
	$"%CategoryCount".text = str(count)
