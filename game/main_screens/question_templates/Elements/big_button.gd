tool

extends Button

export var color : Color
export var button_text = "VERDADERO"

func _ready():
	_apply_settings()

func _process(delta):
	if Engine.is_editor_hint():
		_apply_settings()

func _apply_settings():
	$"%BigButton".modulate = color
	$"%BigButton".rect_size = rect_size
	$"%BigButtonBorder".rect_size = rect_size
	$"%Label".text = button_text


func _on_BigButton_mouse_entered():
	$"%BigButton".modulate = color*1.2


func _on_BigButton_mouse_exited():
	$"%BigButton".modulate = color


func _on_BigButton_button_down():
	$"%BigButton".modulate = color*0.8


func _on_BigButton_button_up():
	$"%BigButton".modulate = color*1.2
