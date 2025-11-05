extends Node2D

signal hook_start(trigger_data)
signal hook_trigger(hook)

var trigger_data : Dictionary

onready var dispatch_window = $"%DispatchWindow"
onready var evaluation_panel = $"%EvaluationPanel"
onready var Diagrama_control = $"%DiagramaControl"

func _ready():
	evaluation_panel.connect("step_changed", self, "_on_evaluation_step_changed")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	evaluation_panel.load_evaluation()
	$"%EvaluationPanel".connect("evaluation_ended", self, "_on_exercise_win")
	Signals.connect("exercise_win", self, "_on_exercise_win")
	call_deferred("_print_dispatch_state")
	pass # End of _ready

# --- HANDLER FUNCTION ---
func _on_evaluation_step_changed():
	# Call the helper function to print the state
	_print_dispatch_state()

# --- HELPER FUNCTION TO PRINT STATE ---
func _print_dispatch_state():
	# Get current machine ID
	var current_id = dispatch_window.current_machine_id

	# Get current status code value (the item_id, e.g., 4010)
	var current_status_code = dispatch_window._get_selected_value(dispatch_window.status_code_option_button)
	# Check if dispatch_window reference is valid
	print("hola soy el print")
	# Print the values
	print("--- Step Changed ---")
	print("Current Machine ID: ", current_id)
	print("Selected Status Code: ", current_status_code)
	print("--------------------")

	if not dispatch_window:
		print("Dispatch Window reference is not valid.")
		return

	# Check if the needed methods/variables exist in dispatch_window
	if not dispatch_window.has_method("_get_selected_value"):
		print("Dispatch Window script is missing '_get_selected_value' function.")
		return
	if not dispatch_window.has_node("CodeStateButton"): # Or use the actual variable name
		print("Dispatch Window is missing 'CodeStateButton' node reference.")
		return

	

#Aqui 
func _on_Node2D_hook_start(_trigger_data):
	
	trigger_data = _trigger_data
	if trigger_data["hook"] == "machine_id":
		dispatch_window.status_code_option_button.get_popup().connect("id_pressed", self, "_on_status_pressed")
		Diagrama_control.connect("quick_dispatch_request", self, "_on_quick_status_pressed")
func _on_status_pressed(id):
	yield(get_tree(), "idle_frame")
	print("Aqui esta la id: ", id)
	if dispatch_window.current_machine_id == trigger_data["machine_id"] and id == trigger_data["status_pressed"]:
		dispatch_window.status_code_option_button.get_popup().disconnect("id_pressed", self, "_on_status_pressed")
		Diagrama_control.disconnect("quick_dispatch_request", self, "_on_quick_status_pressed")		
		emit_signal("hook_trigger", "machine_id")
		print("Enviando señal")

func _on_quick_status_pressed(machine_id, status_code):
	yield(get_tree(), "idle_frame")
	print("Aqui esta la id: ", machine_id , " Y su estado: ", status_code)
	if dispatch_window.current_machine_id == trigger_data["machine_id"] and status_code == trigger_data["status_pressed"]:
		dispatch_window.status_code_option_button.get_popup().disconnect("id_pressed", self, "_on_status_pressed")
		Diagrama_control.disconnect("quick_dispatch_request", self, "_on_quick_status_pressed")
		emit_signal("hook_trigger", "machine_id")
		print("Enviando señal quick")
		
		
func _on_PopUp_button_pressed():
	Transition.change_scene(Main.advance_exercise_and_get_next())

func _on_exercise_win(points, total_time):
	points = 3
	total_time = 1
	$"%PopUp".star_count = points
	$"%PopUp".show()
