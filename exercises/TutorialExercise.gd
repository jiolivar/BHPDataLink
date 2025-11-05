extends "res://exercises/tutorial/tutorial_1.gd"

func _ready():
	pass


func _on_Tutorial_tutorial_end():
	
	Signals.emit_signal("exercise_win", 3, 1)
	yield(get_tree().create_timer(0.5), "timeout")
	Transition.change_scene(Main.advance_exercise_and_get_next())


func _on_MainTutorial1_before_more_info_pressed():
	
	var page : Control = $"%IrisButtonContainer".pages[0] as Control
	
	for i in range(4):
		var button = page.get_node("IrisButton_" + str(i))
		if not button.is_pressed():
			button.set_pressed(true)
			button._on_Button_pressed()
			print("> pressed iris button by code :", i)
	
