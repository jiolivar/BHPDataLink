# En DefTumExplainSlide.gd

extends Control

onready var seccion_botones = $TUMDef
onready var mi_popup = $Popup # Asegúrate que este sea el nombre de tu nodo pop-up

var indice_activo_tumdef = -1

func _ready():
	seccion_botones.connect("boton_presionado", self, "_on_boton_presionado")
	mi_popup.connect("popup_cerrado", self, "_on_popup_cerrado")

# --- FUNCIÓN MODIFICADA ---
# Recibe el índice y el texto como antes...
func _on_boton_presionado(indice, texto_recibido):
	indice_activo_tumdef = indice
	
	# ...pero ahora llama a la nueva función simple del pop-up.
	mi_popup.mostrar_descripcion(texto_recibido)

# Esta función no necesita cambios
func _on_popup_cerrado():
	if indice_activo_tumdef != seccion_botones.botones.size() - 1:
		seccion_botones.revelar_siguiente_boton()
	else:
		print("¡Ejercicio TUMDef completado! Pasando al siguiente.")
		Signals.emit_signal("exercise_win", 3, 0)
		Transition.change_scene(Main.advance_exercise_and_get_next())
