extends Control

export(String) var text = "Nodo"
export(Color) var color = Color(1, 0.5, 0) # naranja por defecto
export(bool) var is_leaf = false

onready var btn = $Button
onready var children_box = $VBoxContainer

func _ready():
	btn.text = text
	_apply_style()
	children_box.visible = false
	btn.connect("pressed", self, "_on_pressed")

func _apply_style():
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.set("border_width_left", 2)
	style.set("border_width_top", 2)
	style.set("border_width_right", 2)
	style.set("border_width_bottom", 2)
	style.border_color = Color(0,0,0)

	btn.add_stylebox_override("normal", style)

	# color del texto
	btn.add_color_override("font_color", Color(1,1,1) if not is_leaf else Color(0,0,0))

func _on_pressed():
	children_box.visible = !children_box.visible
