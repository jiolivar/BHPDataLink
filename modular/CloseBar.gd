extends ColorRect

signal close()

func _on_CloseButton_pressed():
	emit_signal("close")
