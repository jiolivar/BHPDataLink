extends ContentSlide


func _ready():
	titles = {
		0 : {"Title": "Evaluación y estrellas"},
		1 : {"Title": "Dinámicas"},
		2 : {"Title": "Dinámicas"},
		3 : {"Title": "Dinámicas"},
		4 : {"Title": "Dinámicas"},
		5 : {"Title": "Dinámicas"},
		6 : {"Title": "Dinámicas"},
		7 : {"Title": "¿Qué es TUM?"},
		8 : {"Title": "¿Para qué sirve el TUM?"},
		9 : {"Title": "La importancia del TUM"},
		10 : {"Title": "Categorías principales de tiempo"},
		11 : {"Title": "Jerarquía del tiempo"},
		12 : {"Title": "Códigos TUM"},
		13 : {"Title": "Indicadores derivados"},
		14 : {"Title": "Beneficio principal"},
		15 : {"Title": "Relación con la mejora continua"}
	}


func _on_SlideIntro01_slides_completed():
	Signals.emit_signal("exercise_win", 3, 0)
