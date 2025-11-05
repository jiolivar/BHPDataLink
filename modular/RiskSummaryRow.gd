extends HBoxContainer

var data : Dictionary

signal user_pressed(risk_summary_row_ref)

func set_data(_data : Dictionary) -> void:
	
	data = _data
	
	$"%UserName".text = _data.get("user_name", "")
	$"%Id".text = str(_data.get("id", ""))
	$"%EventTime".text = Date.convert_date_format( _data.get("event_time", "18/01/2024 16:40:18") )
	
	var high_risk_count : int = _data.get("total_high_risk", 0)
	var med_risk_count : int = _data.get("total_med_risk", 0)
	
	$"%TotalHighRisk".text = str(high_risk_count)
	$"%TotalMedRisk".text = str(med_risk_count)
	$"%TotalRisk".text = str(high_risk_count + med_risk_count)
	
	$"%Place".text = _data.get("place", "-")



func _on_UserName_pressed():
	emit_signal("user_pressed", self)
