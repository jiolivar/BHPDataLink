extends ColorRect

signal risk_summary_pressed()

func _ready():
	
	for child in $"%Options".get_children():
		if child is PopupMenu:
			(child as PopupMenu).connect("id_pressed", self, "_on_options_item_pressed")
	
	yield(get_tree(), "idle_frame")
	$"%Options".get_child(0).name = "OptionsPopupMenu"
	


func _on_options_item_pressed(id : int) -> void:
	match id:
		1:
			emit_signal("risk_summary_pressed")

