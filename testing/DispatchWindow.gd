extends Panel 

# ====================================================================
# 1. ONREADY REFERENCES & STATE
# ====================================================================

# OptionButton Principal (IDs de Máquina).
onready var machine_id_option_button: OptionButton = $"%MachineSearchLineEdit" 

# OptionButtons Dependientes para Autocompletado
onready var location_option_button: OptionButton = $"%OptionButton2" 	
onready var destination_option_button: OptionButton = $"%DestinationButton" 
onready var status_code_option_button: OptionButton = $"%CodeStateButton" 

# OptionButtons con rutas largas (para Autocompletado y Persistencia)
onready var material_option_button: OptionButton = $VBoxContainer/HBoxContainer4/VBoxContainer/OptionButton
onready var law_option_button: OptionButton = $VBoxContainer/HBoxContainer4/VBoxContainer2/OptionButton
onready var operator_option_button: OptionButton = $VBoxContainer/HBoxContainer5/VBoxContainer/OptionButton
onready var action_next_option_button: OptionButton = $VBoxContainer/HBoxContainer6/VBoxContainer2/OptionButton
onready var action_cancel_option_button: OptionButton = $VBoxContainer/HBoxContainer6/VBoxContainer3/OptionButton

signal mission_check_requested(machine_id, status_code)

# Variables de persistencia
var machine_states = {} 
var current_machine_id = "" 
var is_loaded = false 


# ====================================================================
# 2. INICIALIZACIÓN Y CONEXIÓN DE SEÑALES
# ====================================================================

func _ready():
	
	if machine_id_option_button:
		# ¡CRÍTICO! Mantenemos SOLO la conexión de la máquina ID al manejador de carga.
		machine_id_option_button.connect("item_selected", self, "_on_machine_id_selected")
	
	# --- CONEXIÓN DE GUARDADO REACTIVO (Consolidado) ---
	# La conexión del status_code_option_button y todos los demás ocurre aquí dentro.
	_connect_reactive_save_signals()
	if status_code_option_button:
		status_code_option_button.disabled = true
		
# ====================================================================
# 3. LÓGICA DE CARGA DE DATOS (load_options)
# ====================================================================

func load_options(data: Dictionary):
	
	if is_loaded and current_machine_id != "":
		_save_current_state()
	
	is_loaded = false
	current_machine_id = "" 
	
	if status_code_option_button:  #Deshabilitar estado y razon sin tener ID 
		status_code_option_button.disabled = true
	
	_fill_option_button(machine_id_option_button, data.get("truck_ids", []))
	_fill_option_button(location_option_button, data.get("location_ids", []))
	_fill_option_button(destination_option_button, data.get("destination_ids", []))
	_fill_option_button(status_code_option_button, data.get("status_codes", []))
	_fill_option_button(material_option_button, data.get("material_types", []))
	_fill_option_button(law_option_button, data.get("law_types", []))
	_fill_option_button(operator_option_button, data.get("operator_ids", []))
	_fill_option_button(action_next_option_button, data.get("action_next_types", []))
	_fill_option_button(action_cancel_option_button, data.get("action_cancel_types", []))
	
	if action_cancel_option_button and action_cancel_option_button.get_item_count() > 0:
		action_cancel_option_button.set_item_disabled(0, true)
		
	is_loaded = true


# ====================================================================
# 4. LÓGICA DE PERSISTENCIA Y AUTOCOMPLETADO
# ====================================================================

func _on_machine_id_selected(index: int):
	var new_machine_id = ""
	
	# ----------------------------------------------------
	# CRÍTICO: GUARDAR EL ESTADO DEL ID ANTERIOR ANTES DE CONTINUAR
	# Si current_machine_id tiene un valor, significa que hay un estado en pantalla
	# que debe guardarse antes de cargar el siguiente.
	if current_machine_id != "":
		_save_current_state()
	# ----------------------------------------------------

	if index > 0:
		new_machine_id = machine_id_option_button.get_item_text(index)
		if status_code_option_button: #Habilitar boton estado
			status_code_option_button.disabled = false
		# _load_state_for_machine internamente actualizará current_machine_id = new_machine_id
		_load_state_for_machine(new_machine_id)
	else:
		current_machine_id = ""
		if status_code_option_button: #Deshabilitar
			status_code_option_button.disabled = true
		_select_placeholder(location_option_button)
		_select_placeholder(destination_option_button)
		_select_placeholder(status_code_option_button)
		_select_placeholder(material_option_button)
		_select_placeholder(law_option_button)
		_select_placeholder(operator_option_button)
		_select_placeholder(action_next_option_button)
		_select_placeholder(action_cancel_option_button)


# Función llamada desde Control.gd para forzar la selección (Doble Clic)
func set_selected_id_and_load_state(selected_id: String):
	var target_index = -1
	
	if machine_id_option_button:
		target_index = _get_index_by_text(machine_id_option_button, selected_id)
		
	if target_index >= 0:
		machine_id_option_button.select(target_index)
		_on_machine_id_selected(target_index) 
	else:
		machine_id_option_button.select(0)
		_on_machine_id_selected(0)
		
# Función llamada desde Control.gd para forzar la selección del estado (Clic Derecho)
func set_selected_status_code(status_code: String):
	if status_code_option_button:
		var target_index = _get_index_by_text(status_code_option_button, status_code)
		if target_index >= 0:
			# 1. Seleccionar el ítem. Esto disparará _on_any_option_changed (el guardado).
			status_code_option_button.select(target_index)
			
			# 2. CRÍTICO: Forzar la validación de forma ASÍNCRONA (próxima frame).
			# Esto evita el bloqueo de la señal.
			call_deferred("_trigger_validation")
		
# Carga el estado guardado o aplica el autocompletado inicial.
func _load_state_for_machine(selected_id: String):
	current_machine_id = selected_id
	var saved_state = machine_states.get(selected_id, null)
	
	if saved_state != null:
		location_option_button.select(saved_state.location)
		destination_option_button.select(saved_state.destination)
		status_code_option_button.select(saved_state.status_code)
		material_option_button.select(saved_state.material)
		law_option_button.select(saved_state.law)
		operator_option_button.select(saved_state.operator)
		action_next_option_button.select(saved_state.action_next)
		action_cancel_option_button.select(saved_state.action_cancel)
	else:
		_apply_initial_autoselect()
	
	var current_status_code_int = _get_selected_value(status_code_option_button)
	#emit_signal("mission_check_requested", selected_id, current_status_code_int)


# ====================================================================
# 5. CONEXIÓN DE CIERRE Y GUARDADO REACTIVO
# ====================================================================

func _connect_reactive_save_signals():
	var all_save_buttons = [
		machine_id_option_button,
		location_option_button,
		destination_option_button,
		status_code_option_button,
		material_option_button,
		law_option_button,
		operator_option_button,
		action_next_option_button,
		action_cancel_option_button,
	]
	
	for button in all_save_buttons:
		if button:
			button.connect("item_selected", self, "_on_any_option_changed")


func _on_any_option_changed(index: int):
	
	# 1. Guarda el estado reactivamente (soluciona el reseteo de datos).
	_save_current_state()
	
	# 2. Obtener el código de estado actual.
	var current_status_code_int = _get_selected_value(status_code_option_button)
	
	# 3. Validar la actividad si el cambio fue en el código de estado
	# (Comprobamos si el valor es mayor que 0, que es el placeholder)
	if current_status_code_int != 0 and status_code_option_button.get_selected() == index:
		# El cambio fue en el botón de estado: ¡Validar!
		emit_signal("mission_check_requested", current_machine_id, current_status_code_int)

func _on_window_popup_hide():
	_save_current_state()


# ====================================================================
# 6. FUNCIONES AUXILIARES (Helper Functions)
# ====================================================================

func _get_index_by_text(option_button: OptionButton, text_to_find: String) -> int:
	for i in range(option_button.get_item_count()):
		if option_button.get_item_text(i) == text_to_find:
			return i
	return -1
	
func _get_selected_value(option_button: OptionButton) -> int:
	if option_button and option_button.get_item_count() > 0:
		var selected_index = option_button.get_selected()
		# Devuelve el ID asociado al índice seleccionado, no el índice.
		return option_button.get_item_id(selected_index) 
	return -1

func _get_current_selections():
	return {
		"location": location_option_button.get_selected(),
		"destination": destination_option_button.get_selected(),
		"status_code": status_code_option_button.get_selected(),
		"material": material_option_button.get_selected(),
		"law": law_option_button.get_selected(),
		"operator": operator_option_button.get_selected(),
		"action_next": action_next_option_button.get_selected(),
		"action_cancel": action_cancel_option_button.get_selected()
	}

func _save_current_state():
	if current_machine_id:
		machine_states[current_machine_id] = _get_current_selections()

func _fill_option_button(option_button: OptionButton, items: Array):
	if option_button:
		option_button.clear()
		
		option_button.add_item("-- Elija una opción --", 0) 
		option_button.set_item_disabled(0, true)
		
		if not items.empty():
			for item in items:
				if typeof(item) == TYPE_STRING:
					var item_id_int = int(item) if item.is_valid_integer() else item.hash() 
					option_button.add_item(item, item_id_int) 
				else:
					option_button.add_item(str(item), item)
					
		option_button.select(0)

func _apply_initial_autoselect():
	# Eliminamos la autoselección del status_code_option_button.
	_select_first_if_available(location_option_button)
	_select_first_if_available(destination_option_button)
	# _select_first_if_available(status_code_option_button) <--- ¡ELIMINADO!
	_select_first_if_available(material_option_button)
	_select_first_if_available(law_option_button)
	_select_first_if_available(operator_option_button)
	_select_first_if_available(action_next_option_button)
	_select_first_if_available(action_cancel_option_button)

func _select_first_if_available(option_button: OptionButton):
	if option_button and option_button.get_item_count() > 1:
		option_button.select(1)

func _select_placeholder(option_button: OptionButton):
	if option_button and option_button.get_item_count() > 0:
		option_button.select(0)
func _trigger_validation():
	# 1. Obtenemos el valor actual (el que ya fue guardado por el atajo)
	var current_status_code_int = _get_selected_value(status_code_option_button)
	
	# 2. Emitimos la señal solo si no es el placeholder (valor 0)
	if current_status_code_int != 0:
		emit_signal("mission_check_requested", current_machine_id, current_status_code_int)
