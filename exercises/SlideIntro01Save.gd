extends ContentSlide


func _ready():
	titles = {
		0 : {"Title": "Fundamentos de la Fatiga Laboral"},
		1 : {"Title": "Introducción al Sistema Optalert"},
		2 : {"Title": "Objetivos del sistema"},
		3 : {"Title": "Componentes del Sistema Optalert"},
		4 : {"Title": "Uso Operacional del Sistema"},
		5 : {"Title": "Comprensión de la Escala JDS"},
		6 : {"Title": "Protocolos ante alertas"},
		7 : {"Title": "Buenas prácticas"}
		}
func _on_SlideIntro02_slides_completed():
	Signals.emit_signal("exercise_win", 3, 0)
