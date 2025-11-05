extends TrueFalseSequence

func _ready():
	questions = {
		0 : {
			"Question" : "Se puede estar fuera del sistema temporalmente (En reserva).",
			"Answer" : true
		},
		1 : {
			"Question" : "El código 9010 es para equipos reubicados.",
			"Answer" : true
		},
		2 : {
			"Question" : "Un equipo puede estar fuera de TUM cuando está detenido debido a una falla interna que no ha sido reportada en terreno.",
			"Answer" : false
		},
		3 : {
			"Question" : "Un equipo siempre debe estar en TUM.",
			"Answer" : true
		}
	}


func _on_PopUp_button_pressed():
	yield(get_tree().create_timer(0.5), "timeout")
	Transition.change_scene(Main.advance_exercise_and_get_next())
