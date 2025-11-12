extends HBoxContainer
onready var header_columns = $HeaderColumns

func _ready():
	generate_headers()
	generate_grid()

func generate_headers():
	header_columns.clear()
	for i in range(num_cols):
		var label = Label.new()
		label.text = String(char(65 + i))  # 65 = A
		label.rect_min_size = Vector2(80, 24)
		label.align = Label.ALIGN_CENTER
		header_columns.add_child(label)
