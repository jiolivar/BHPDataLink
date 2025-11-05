extends TrueFalseSequence

func _ready():
	questions = {
		0 : {
			"Question" : "Utilización es igual a disponibilidad.",
			"Answer" : false
		},
		1 : {
			"Question" : "Tiempo medio entre fallas mide confiabilidad.",
			"Answer" : true
		},
		2 : {
			"Question" : " Tasa de producción se mide por hora.",
			"Answer" : true
		}
	}


func _on_PopUp_button_pressed():
	yield(get_tree().create_timer(0.5), "timeout")
	Transition.change_scene(Main.advance_exercise_and_get_next())
