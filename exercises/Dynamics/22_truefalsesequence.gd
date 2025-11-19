extends TrueFalseSequence

func _ready():
	questions = {
		0 : {
			"Question" : "Compartir una hoja requiere que el otro usuario tenga PI DataLink.",
			"Answer" : true
		},
		1 : {
			"Question" : "Datos se actualizan en solo lectura.",
			"Answer" : false
		},
		2 : {
			"Question" : "Copiar valores fijos con Pegado especial.",
			"Answer" : true
		}
	}


func _on_PopUp_button_pressed():
	yield(get_tree().create_timer(0.5), "timeout")
	Transition.change_scene(Main.advance_exercise_and_get_next())
