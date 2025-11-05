extends Panel

var is_button := false
var data : Dictionary

signal pressed(user_info_ref, pressed)


func _ready():
	set_is_button(is_button)


func set_is_button(_is_button : bool) -> void:
	is_button = _is_button
	$"%Button".disabled = not is_button


func set_button_group(button_group : ButtonGroup) -> void:
	$"%Button".group = button_group


func _on_Button_pressed():
	if is_button:
		emit_signal("pressed", self, $"%Button".pressed)


func set_user_data(user_data: Dictionary) -> void:
	
	if user_data.get("user_state", 3) < 2:
		hide()
	else:
		show()
	
	$"%UserName".text = user_data.get("user_name", "")
	$"%Punctuation".text = str(user_data.get("punctuation", ""))
	$"%Id".text = user_data.get("id", "")
	
	var risk = _calculate_risk(
		user_data.get("punctuation", 0.0), 
		user_data.get("self_management", false),
		user_data.get("user_state", 3)
	)
	
	$"%Risk".text = risk[0]
	
	$"%InfoPanel1".set("custom_styles/panel", risk[1])
	
	$"%EventTime".text = Date.convert_date_format( user_data.get("event_time", "18/01/2024 16:40:18") )
	$"%TotalHighRisk".text = str(user_data.get("total_high_risk", ""))
	$"%TotalMedRisk".text = str(user_data.get("total_med_risk", ""))
	$"%Vehicle".text = user_data.get("vehicle", "")
	$"%Place".text = user_data.get("place", "")
	
	data = user_data


func _calculate_risk(punctuation : float, self_management : bool, user_state : int) -> Array:
	
	if user_state == 2:
		return ["LENTES OFF", UI.OUTLINE_LIGHTGREEN]
	elif self_management:
		return ["ALTO RIESGO", UI.OUTLINE_BLUE]
	elif punctuation >= 5.0:
		return ["ALTO RIESGO", UI.OUTLINE_RED]
	elif punctuation >= 4.5:
		return ["MEDIO RIESGO", UI.OUTLINE_YELLOW]
	else:
		return ["BAJO RIESGO", UI.OUTLINE_GREEN]


func _on_Button_toggled(button_pressed):
	if button_pressed:
		set("custom_styles/panel", UI.DARK_BLUE)
	else:
		set("custom_styles/panel", UI.WHITE)
