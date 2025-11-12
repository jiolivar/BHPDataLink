extends VBoxContainer

onready var header_rows = $HeaderRows

func generate_row_numbers():
	header_rows.clear()
	for i in range(num_rows):
		var label = Label.new()
		label.text = str(i + 1)
		label.rect_min_size = Vector2(40, 24)
		label.align = Label.ALIGN_CENTER
		header_rows.add_child(label)
