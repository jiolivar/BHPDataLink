tool
extends Label

export(bool) var show_x_overlay = false setget _set_show_x_overlay
export(Color) var x_color = Color.yellow setget _set_x_color
export(float) var x_line_width = 3.0 setget _set_x_line_width

# --- Setters ---
func _set_show_x_overlay(value: bool):
	show_x_overlay = value
	if is_inside_tree():
		update()

func _set_x_color(value: Color):
	x_color = value
	if is_inside_tree():
		update()

func _set_x_line_width(value: float):
	x_line_width = value
	if is_inside_tree():
		update()

func _ready():
	_set_show_x_overlay(show_x_overlay)
	_set_x_color(x_color)
	_set_x_line_width(x_line_width)

func _draw():
	if show_x_overlay:
		var size = rect_size
		draw_line(Vector2(0, 0), size, x_color, x_line_width, true)
		draw_line(Vector2(size.x, 0), Vector2(0, size.y), x_color, x_line_width, true)
