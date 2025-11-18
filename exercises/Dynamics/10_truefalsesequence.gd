extends TrueFalseSequence

func _ready():
	questions = {
		0 : {
			"Question" : "Los campos de entrada aceptan tanto valores directos como referencias a celdas.",
			"Answer" : true
		},
		1 : {
			"Question" : "Ingresar una hora como 9:45 siempre será interpretado como una marca de tiempo válida.",
			"Answer" : false
		},
		2 : {
			"Question" : "Los campos con listas permiten elegir unidades o propiedades predefinidas.",
			"Answer" : true
		},
		3 : {
			"Question" : "Las referencias de celda pueden usar el formato de tiempo absoluto de Excel.",
			"Answer" : true
		}
	}


func _on_PopUp_button_pressed():
	yield(get_tree().create_timer(0.5), "timeout")
	Transition.change_scene(Main.advance_exercise_and_get_next())
