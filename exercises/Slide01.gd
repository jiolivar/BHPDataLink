extends BaseQuestionPanel


func _ready():
	pass


func _on_NextButton_pressed():
	Signals.emit_signal("exercise_win", 3, 0)
	end()
	
	yield(get_tree().create_timer(1.0), "timeout")
	
	Transition.change_scene(Main.advance_exercise_and_get_next())
