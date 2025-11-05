extends Control

export var user_name := "Laura González"

var risk_row = preload("res://modular/RiskRow.tscn")

signal close()

func _ready():
	update_data()


func update_data():
	
	user_name = Main.tutorial_3_user_data.get("user_name", "Laura Gonzáles")
	
	$"%UserName".text = Main.tutorial_3_user_data.get("user_name", "")
	$"%Place".text = Main.tutorial_3_user_data.get("place", "-")
	$"%Vehicle".text = Main.tutorial_3_user_data.get("vehicle", "")
	
	if not Data.risk_data.has(user_name):
		return
	
	for child in $"%RiskRowContainer".get_children():
		child.hide()
		child.name += "_free"
		child.queue_free()
	
	for data in Data.risk_data[user_name]:
		
		var risk_row_instance = risk_row.instance()
		
		$"%RiskRowContainer".add_child(risk_row_instance)
		
		risk_row_instance.set_data(data)


func clean_data() -> void:
	
	$"%Option1".pressed = false
	$"%Option2".pressed = false
	$"%Option3".pressed = false
	$"%DescriptionTextBox".text = ""


func _on_CloseBar_close():
	emit_signal("close")


func _on_AddRecordButton_pressed():
	
	if $"%DescriptionTextBox".text == "":
		return
	
	var risk_row_instance = risk_row.instance()
	
	$"%RiskRowContainer".add_child(risk_row_instance)
	$"%RiskRowContainer".move_child(risk_row_instance, 0)
	
	var data = {
		"event_time" : Date.get_date_text(OS.get_datetime()),
		"desc" : $"%DescriptionTextBox".text
	}
	
	risk_row_instance.set_data(data)
	
	if not Data.risk_data.has(user_name):
		Data.risk_data[user_name] = []
	
	Data.risk_data[user_name].push_front(data)

