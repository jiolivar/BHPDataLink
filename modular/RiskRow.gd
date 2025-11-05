extends HBoxContainer

func set_data(data : Dictionary) -> void:
	
	$"%Date".text = data.get("event_time", "")
	
	if data.has("desc"):
		$"%Vehicle".text = "SOPORTE01"
		$"%RiskDesc".text = data.get("desc", "")
	else:
		$"%Vehicle".text = data.get("vehicle", "")
		$"%RiskDesc".text = _get_risk_description(data.get("punctuation", 0.0))
	

func _get_risk_description(punctuation : float) -> String:
	if punctuation >= 5.0:
		return "Advertencia de Alto Riesgo: " + str(punctuation)
	elif punctuation >= 4.5:
		return "Advertencia de Medio Riesgo: " + str(punctuation)
	else:
		return "Advertencia de Bajo Riesgo: " + str(punctuation)
