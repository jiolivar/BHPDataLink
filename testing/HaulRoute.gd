extends Control

# Señales que el controlador principal (Control.gd) está esperando.
signal open_dispatch_window_requested(machine_type, machine_id)
signal quick_dispatch_request(machine_id, status_code)

# Lista de rutas de botones que deben ser conectados.
var target_buttons_paths = ["%Button", "%Button2", "%ButtonDown"] 

# ====================================================================
# INICIALIZACIÓN Y CONEXIÓN DE BOTONES
# ====================================================================

func _ready():
	_setup_truck_button_connections()


func _setup_truck_button_connections():
	# 1. Conexión de botones predefinidos
	for path in target_buttons_paths:
		var button = get_node_or_null(path)
		if button:
			# Conexión DOBLE CLIC (Abre ventana para selección de máquina)
			if button.has_signal("double_click_detected"):
				button.connect("double_click_detected", self, "_on_button_double_clicked")

			# Conexión CLIC DERECHO (Atajo Rápido)
			if button.has_signal("quick_dispatch_request"):
				button.connect("quick_dispatch_request", self, "_on_truck_quick_dispatch_request")
		else:
			print("ERROR DIAGRAMA: Botón no encontrado en ruta: " + path)


# ====================================================================
# MANEJADORES DE RETRANSMISIÓN DE SEÑALES
# ====================================================================

# Maneja la señal de DOBLE CLIC (Retransmite para abrir la ventana de Despacho)
func _on_button_double_clicked(machine_id: String):
	# Determinamos el tipo de máquina a partir del ID.
	var machine_type = machine_id.left(3).to_upper()
	
	# Emitimos la señal con el tipo (Ej: PAL) y el ID (Ej: PAL04)
	emit_signal("open_dispatch_window_requested", machine_type, machine_id)


# Maneja la señal de CLIC DERECHO (Retransmite para el Atajo Rápido)
func _on_truck_quick_dispatch_request(machine_id: String, status_code: int):
	# Retransmitimos el ID de máquina y el Código de Estadado al Control.gd
	emit_signal("quick_dispatch_request", machine_id, status_code)
