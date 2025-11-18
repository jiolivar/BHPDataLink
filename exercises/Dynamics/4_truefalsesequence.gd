extends TrueFalseSequence

func _ready():
	questions = {
		0 : {
			"Question" : " PI DataLink admite tipo blob .",
			"Answer" : false
		},
		1 : {
			"Question" : "Se puede usar con datos de PI AF.",
			"Answer" : true
		},
		2 : {
			"Question" : "Los valores de atributo pueden ser fecha y hora.",
			"Answer" : true
		},
		3 : {
			"Question" : "No admite valores booleanos.",
			"Answer" : false
		}
	}


func _on_PopUp_button_pressed():
	yield(get_tree().create_timer(0.5), "timeout")
	Transition.change_scene(Main.advance_exercise_and_get_next())
