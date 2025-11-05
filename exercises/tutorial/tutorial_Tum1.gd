extends Control

var current_tutorial_step = -1
var button

func _ready():
	var tutorial = $"%Tutorial"
	button = get_node_or_null("/root/Control/Control/DiagramaControl/Panel2/Button")
	
	if tutorial:
		tutorial.connect("outro_shown", self, "_on_tutorial_end")
		tutorial.connect("step_changed", self, "_on_tutorial_step_changed")
		
func _on_tutorial_end():
	print("El tutorial ha terminado.")
	Signals.emit_signal("exercise_win", 3, 0)
	# Obtener el DiagramaControl
	var diagrama = get_node_or_null("%DiagramaControl")
	if diagrama == null:
		return

	# Iterar sobre las rutas definidas en su script
	for path in diagrama.target_buttons_paths:
		var button = diagrama.get_node_or_null(path)
		if button:
			# Intentar cerrar ambos menús si existen
			if button.has_variable("context_menu") and button.context_menu:
				button.context_menu.hide()
			if button.has_variable("reason_code_menu") and button.reason_code_menu:
				button.reason_code_menu.hide()

func _on_tutorial_step_changed(new_step_index: int):
	current_tutorial_step = new_step_index
	print("LOG: Tutorial advanced to step: ", current_tutorial_step)

	if button == null:
		print("⚠️ Button no encontrado")
		return

	# --- Lógica de pasos ---
	if current_tutorial_step == 4:
		if "enable_right_click" in button:
			button.enable_right_click = false
		if "enable_double_click" in button:
			button.enable_double_click = true
		print("Step 6: Bloqueado clic derecho y habilitando doble clic en Button")

	elif current_tutorial_step == 9:
		if "enable_right_click" in button:
			button.enable_right_click = true
		if "enable_double_click" in button:
			button.enable_double_click = false
		print("Step 9: Habilitado clic derecho y bloqueando doble clic en Button")
