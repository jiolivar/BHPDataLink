extends Node

func _ready():
	# Tests
	#print(json_to_dict("res://Data/JSONData/Panels/FinancialReport/Page1.json"))
	pass
	
func json_to_dict(file_path : String):
	var result
	
	var file = File.new()
	var err = file.open(file_path, File.READ)
	
	if err == OK:
		var data_str := ""
		
		result = parse_json(file.get_as_text())
		
		file.close()
	
	return result
