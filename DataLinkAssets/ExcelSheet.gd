extends Control

export var num_rows := 20
export var num_cols := 10

onready var grid = $"%Grid"
onready var header_rows = $"%HeaderRows"
onready var header_columns = $"%HeaderColumns"

func _ready():
	generate_headers()
	generate_row_numbers()
	generate_grid()

func generate_headers():
	for i in range(num_cols):
		var label = Label.new()
		label.text = String(char(65 + i))  # 65 = A
		label.rect_min_size = Vector2(80, 24)
		label.align = Label.ALIGN_CENTER
		header_columns.add_child(label)

func generate_grid():
	grid.columns = num_cols
	for r in range(num_rows):
		for c in range(num_cols):
			var cell = LineEdit.new()
			cell.name = "R%dC%d" % [r+1, c+1]
			cell.text = ""
			cell.rect_min_size = Vector2(80, 24)
			cell.align = LineEdit.ALIGN_CENTER
			cell.expand_to_text_length = false
			cell.add_color_override("font_color", Color(0,0,0))
			cell.add_color_override("caret_color", Color(0,0,0))
			var style = StyleBoxFlat.new()
			style.bg_color = Color(1, 1, 1)
			style.border_color = Color(0.8, 0.8, 0.8)
			style.set_border_width(MARGIN_LEFT, 1)
			style.set_border_width(MARGIN_TOP, 1)
			style.set_border_width(MARGIN_RIGHT, 1)
			style.set_border_width(MARGIN_BOTTOM, 1)
			cell.add_stylebox_override("normal", style)
			grid.add_child(cell)


func generate_row_numbers():
	for i in range(num_rows):
		var label = Label.new()
		label.text = str(i + 1)
		label.rect_min_size = Vector2(40, 24)
		label.align = Label.ALIGN_CENTER
		header_rows.add_child(label)
