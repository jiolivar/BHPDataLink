extends TrueFalseSequence

func _ready():
	questions = {
		0 : {
			"Question" : "El tercer nivel es sobre mitigación de riesgos utilizando informes y análisis de datos para generar reportes del riesgo.",
			"Answer" : true
		},
		1 : {
			"Question" : "Estos reportes están públicos y los puede ver cualquier persona.",
			"Answer" : false
		},
		2 : {
			"Question" : " Permite optimizar diseños para cambios de turno, realizando cambios basados en evidencia y permite cuantificar la efectividad de esos cambios.",
			"Answer" : true
		}
	}


func _on_PopUp_button_pressed():
	yield(get_tree().create_timer(0.5), "timeout")
	Transition.change_scene(Main.advance_exercise_and_get_next())

