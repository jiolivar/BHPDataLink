extends Button

func _ready():
	var style = StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 1) # Blanco 100% opaco
	style.border_color = Color(0.8, 0.8, 0.8)
	style.set_border_width(MARGIN_LEFT, 1)
	style.set_border_width(MARGIN_TOP, 1)
	style.set_border_width(MARGIN_RIGHT, 1)
	style.set_border_width(MARGIN_BOTTOM, 1)
	add_stylebox_override("normal", style)
