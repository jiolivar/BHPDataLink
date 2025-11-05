extends Control

var risk_summary_row = preload("res://modular/RiskSummaryRow.tscn")

signal close()
signal risk_user_pressed()

var all_risk_row := []

func _ready():
	for child in $"%RiskSummaryRowScrollContainer".get_children():
		if child is ScrollBar:
			child.set("custom_styles/grabber_highlight", $"%VScrollBar".get("custom_styles/grabber_highlight"))
			child.set("custom_styles/grabber", $"%VScrollBar".get("custom_styles/grabber"))
			child.set("custom_styles/scroll_focus", $"%VScrollBar".get("custom_styles/scroll_focus"))
			child.set("custom_styles/scroll", $"%VScrollBar".get("custom_styles/scroll"))
			child.set("custom_styles/grabber_pressed", $"%VScrollBar".get("custom_styles/grabber_pressed"))
			pass
	
	#$"%RiskSummaryRowScrollContainer".theme = null
	pass


func clean_data() -> void:
	
	$"%TimeTextBox".text = ""
	
	for risk_row in all_risk_row:
		risk_row.hide()
		risk_row.name += "_free"
		risk_row.queue_free()
	
	all_risk_row.clear()


func _on_risk_user_pressed(risk_summary_row_ref) -> void:
	
	Main.tutorial_3_user_data = risk_summary_row_ref.data
	
	emit_signal("risk_user_pressed")
	#get_tree().change_scene("res://exercises/tutorial/tutorial_3.tscn")
	
	pass


func _on_CloseBar_close():
	emit_signal("close")


func _on_RefreshButton_pressed():
	
	var validate_data = Date.validate_and_normalize_time($"%TimeTextBox".text)
	
	if not validate_data[1]:
		return
		
	var filtered_users := Date.filter_events(Data.data, validate_data[0])
	
	for risk_row in all_risk_row:
		risk_row.hide()
		risk_row.name += "_free"
		risk_row.queue_free()
	
	all_risk_row.clear()
	
	var i := 0
	for user_data in filtered_users:
		
		if user_data.get("user_state", 3) < 3:
			continue
		
		var risk_summary_row_instance = risk_summary_row.instance()
				
		$"%RiskSummaryRowContainer".add_child(risk_summary_row_instance)
		
		all_risk_row.append(risk_summary_row_instance)
		
		risk_summary_row_instance.name = "risk_summary_row_" + str(i)
		
		risk_summary_row_instance.set_data(user_data)
		
		risk_summary_row_instance.connect("user_pressed", self, "_on_risk_user_pressed")
		
		i += 1
