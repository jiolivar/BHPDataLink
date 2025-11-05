extends Control


onready var fullscreen_icon = preload("res://game/assets/ui/icons/FullscreenIcon.png")
onready var restore_icon = preload("res://game/assets/ui/icons/RestoreIcon.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().get_root().connect("size_changed", self, "_set_fullscreen_icon")
	_set_fullscreen_icon()
	if Main.current_exercise < 0:
		$"%HomeButton".hide()
		$"%SelectorButton".hide()
		$"%FullScreenButton".rect_position = Vector2(6,6)
	else:
		
		$"%HomeButton".show()
		$"%SelectorButton".show()
		$"%FullScreenButton".rect_position = Vector2(6,106)
		
		if Main.current_exercise_type == "Minigame":
			$"%HomeButtons".rect_position.y = 50
		else:
			$"%HomeButtons".rect_position.y = 0


func _set_fullscreen_icon():
	if OS.window_fullscreen:
		$"%FullScreenButton".icon = restore_icon
		$"%FullScreenButton".set_pressed_no_signal(true)
	else:
		$"%FullScreenButton".icon = fullscreen_icon
		$"%FullScreenButton".set_pressed_no_signal(false)
	

func _on_FullScreenButton_toggled(button_pressed):
	OS.window_fullscreen = button_pressed
	$"%AudioStreamPlayer".play()


func _on_HomeButton_pressed():
	Main.reset_exercise()
	Transition.change_scene("res://game/main_screens/main_menu/main_menu.tscn")
	$"%AudioStreamPlayer".play()


func _on_SelectorButton_pressed():
	Main.reset_exercise()
	Transition.change_scene("res://game/main_screens/main_menu/ExerciseSelector/exercise_selector.tscn")
	$"%AudioStreamPlayer".play()
