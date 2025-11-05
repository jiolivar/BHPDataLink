extends "res://game/main_screens/popups/base_popup.gd"


export(String, "Comenzar", "Reintentar", "Continuar", "Custom" ) var buton_text2 := "Custom"
export var custom_buton_text2 := ""
signal button_pressed2
signal button_pressed3

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	_apply_settings()

func _process(delta):
	if Engine.is_editor_hint():
		_apply_settings()

func _apply_settings():
	._apply_settings()
	$"%Stars".visible = false
	if buton_text2 == "Custom":
		$"%Button2".text = custom_buton_text2
	else:
		$"%Button2".text = buton_text2
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button2_pressed():
	$"%AudioStreamPlayer".play()
	$"%Button2".disabled = true
	print("se cierra question")
	close_popup()
	yield(self,"closed")
	emit_signal("button_pressed2")


func _on_Button3_pressed():
	$"%AudioStreamPlayer".play()
	$"%Button3".disabled = true
	close_popup()
	yield(self,"closed")
	emit_signal("button_pressed3")
	
func show():
	.show()
	$"%Button".disabled = false
	$"%Button2".disabled = false
	$"%Button3".disabled = false
