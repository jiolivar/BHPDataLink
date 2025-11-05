extends TrueFalseSequence

func _ready():
	questions = {
		0 : {
			"Question" : " El TUM permite comparar el desempeño de equipos distintos bajo una misma lógica.",
			"Answer" : true
		},
		1 : {
			"Question" : "El TUM solo aplica en un área específica de la faena.",
			"Answer" : false
		},
		2 : {
			"Question" : "El TUM ayuda a planificar y reducir ineficiencias.",
			"Answer" : true
		}
	}


func _on_PopUp_button_pressed():
	yield(get_tree().create_timer(0.5), "timeout")
	Transition.change_scene(Main.advance_exercise_and_get_next())
