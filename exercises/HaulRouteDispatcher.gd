extends Control

signal goal_achieved(machine_id)
# Variable para mantener la referencia a tu PopupPanel.
onready var dispatch_window = null 

# Referencias a los nodos hijos.
onready var header_haul = $"%Header"
onready var diagrama_control = $"%DiagramaControl"



# Diccionario maestro de todos los IDs de máquina
const MACHINE_IDS_MASTER = {
	"CAEX": ["CEX01","CEX02","CEX03","CEX04","CEX05", "CEX06", "CEX07", "CEX08"],
	"PAL": ["PAL02", "PAL04", "PAL06", "PAL08", "PAL11", "PAL12", "PAL13", "PAL15"],
	"BULL": ["PER05", "PER10", "PER15", "CH01","CH06", "REG01", "REG02", "REG03", "BULL05", "BULL06", "BULL08"]
}

# CLAVE: [ID de Máquina, Código de Estado]
const ACTIVITY_GOALS = {
	"PAL02": 4010
}
var activity_status = {}

func _get_initial_window_data(machine_type: String, initial_load: bool = false) -> Dictionary:
	
	var data = {}
	
	if machine_type != "":
		data["truck_ids"] = MACHINE_IDS_MASTER.get(machine_type, [])
	else:
		data["truck_ids"] = [] 
		
	if initial_load:
		data["location_ids"] = []
		data["destination_ids"] = [] 
		data["status_codes"] = []
		data["material_types"] = []
		data["law_types"] = []
		data["operator_ids"] = []
		data["action_next_types"] = []
		data["action_cancel_types"] = ["Seleccionar acción a ejecutar"] 
	else:
		data["location_ids"] = ["SRDC_NORTE", "SRDC_SUR", "SRDC_CENTRO"]
		data["destination_ids"] = ["CGD05", "CGD06", "CGD07", "OTRO_DESTINO"]
		data["status_codes"] = ["1000", "2000","2010","2020","2090","4000","4010","4020","4040","4070","4080","4150", "5000","5010"] 
		data["material_types"] = ["Vacio", "Medio", "Lleno"]
		data["law_types"] = ["NONE", "YES", "IDontKnow"]
		data["operator_ids"] = ["AGUILANTE C. ALBA - 2102", "RICARDO D. DIAZ - 2103", "JOHN DOE - 1946"]
		data["action_next_types"] = ["Llegada", "Salida", "Espera"]
		data["action_cancel_types"] = ["Seleccionar acción a ejecutar", "Anular", "Reasignar", "Finalizar"]

	return data

func _ready():
	# --- ASIGNACIÓN DE LA VENTANA ---
	dispatch_window = $"%DispatchWindow" 
	show_DispatchWindow(false)
	
	# --- CONEXIÓN DE SEÑALES ---
	
	if header_haul:
		header_haul.connect("open_dispatch_window_requested", self, "open_dispatch_window")
		
	if diagrama_control:
		# Conexión principal (doble clic)
		diagrama_control.connect("open_dispatch_window_requested", self, "open_dispatch_window")
		# Conexión del atajo rápido (clic derecho)
		diagrama_control.connect("quick_dispatch_request", self, "open_dispatch_quick_status") 
	
	if dispatch_window:
		dispatch_window.connect("mission_check_requested", self, "_check_activity_completion")
	
	# Inicializar el estado de la actividad
	for id in ACTIVITY_GOALS:
		activity_status[id] = false
	
	


# Función que abre la ventana y recibe el tipo de máquina (Doble Clic)
func open_dispatch_window(machine_type: String = "CAEX", machine_id: String = ""):
	
	if dispatch_window:
		show_DispatchWindow(true)
		
		var filter_type = machine_type
		if machine_id != "":
			filter_type = machine_id.left(3).to_upper()
		var filtered_data = _get_initial_window_data(filter_type, false)
		
		dispatch_window.load_options(filtered_data)
		if machine_id != "":
			dispatch_window.set_selected_id_and_load_state(machine_id)
			
		#dispatch_window.popup_centered()
		
# Función de atajo: Recibe el código y abre la ventana preseleccionada. (Clic Derecho)
func open_dispatch_quick_status(machine_id: String, status_code: int):
	if machine_id == "":
		return
		
	var filter_type = machine_id.left(3).to_upper()
	var filtered_data = _get_initial_window_data(filter_type, false)
	
	if dispatch_window:
		show_DispatchWindow(true)
		
		dispatch_window.load_options(filtered_data)
		
		# 1. Forzar la selección del ID del vehículo (machine_id).
		dispatch_window.set_selected_id_and_load_state(machine_id)
		
		# 2. Forzar la selección del CÓDIGO DE ESTADO (convierte INT a STRING).
		dispatch_window.set_selected_status_code(str(status_code)) 


# Control.gd

func _check_activity_completion(machine_id: String, status_code):
	
	var required_code = ACTIVITY_GOALS.get(machine_id, null)
	
	var required_code_int = int(required_code) if required_code != null else null

	if required_code_int == null:
		return

	if status_code == required_code_int:
		
		activity_status[machine_id] = true
		print("¡ACTIVIDAD CORRECTA! El vehículo " + machine_id + " alcanzó el estado requerido.")
		
		# CRÍTICO: Emitir la señal de éxito para que otros nodos reaccionen
		emit_signal("goal_achieved", machine_id)
		
		_check_all_goals_completed()
		
	else:
		activity_status[machine_id] = false
		print("ERROR DE ACTIVIDAD: La comparación falló para " + machine_id + ". Tipos y valores son diferentes.")

func _check_all_goals_completed():
	var all_completed = true
	for id in activity_status:
		if activity_status[id] == false:
			all_completed = false
			break
			
	if all_completed:
		print("\n🏆 ¡TODOS LOS OBJETIVOS CUMPLIDOS! La misión ha sido completada con éxito.")


func _on_DispatchWindowBack_button_down():
	
	show_DispatchWindow(false)
	pass # Replace with function body.


func show_DispatchWindow(_show : bool) -> void:
	if _show:
		dispatch_window.show()
		$"%DispatchWindowBack".show()

	else:
		dispatch_window.hide()
		$"%DispatchWindowBack".hide()
	
func _lets_continue_():
	Signals.emit_signal("exercise_win", 3, 0)
	Transition.change_scene(Main.advance_exercise_and_get_next())
