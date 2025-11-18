extends TrueFalseSequence

func _ready():
	questions = {
		0 : {
			"Question" : "Actualizar” recalcula todas las funciones de PI DataLink en los libros abiertos.",
			"Answer" : true
		},
		1 : {
			"Question" : "La actualización automática continúa funcionando incluso cuando la hoja está en modo de edición.",
			"Answer" : false
		},
		2 : {
			"Question" : "Actualizar” permite detener la actualización automática si se vuelve a hacer clic.",
			"Answer" : true
		},
		3 : {
			"Question" : "Los libros protegidos y de sólo lectura pueden actualizarse automáticamente.",
			"Answer" : false
		}
	}


func _on_PopUp_button_pressed():
	yield(get_tree().create_timer(0.5), "timeout")
	Transition.change_scene(Main.advance_exercise_and_get_next())
