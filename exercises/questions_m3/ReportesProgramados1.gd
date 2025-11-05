extends TrueFalseSequence

func _ready():
	questions = {
		0 : {
			"Question" : "El sistema Optalert elabora y envía una serie de informes para facilitar la gestión de la fatiga.",
			"Answer" : true
		},
		1 : {
			"Question" : "Si deseo agregar mi correo a la lista de distribución debo levantar el requerimiento al representante de Optalert.",
			"Answer" : true
		},
		2 : {
			"Question" : "Los reportes son anónimos y no muestran al conductor que generó una alerta, por lo tanto no hay forma de gestionar a las personas en base a estos informes.",
			"Answer" : false
		}
	}


func _on_PopUp_button_pressed():
	yield(get_tree().create_timer(0.5), "timeout")
	Transition.change_scene(Main.advance_exercise_and_get_next())

