extends Node

var data : Array = []
var ordered_user_data : Array

var risk_data : Dictionary = {}

func _ready():
	
	risk_data = JsonReader.json_to_dict("res://data/risk_data_1.json")
	
	data += JsonReader.json_to_dict("res://data/users_data_1.json")
	data += JsonReader.json_to_dict("res://data/users_data_2.json")
	data += JsonReader.json_to_dict("res://data/users_data_3.json")
	data += JsonReader.json_to_dict("res://data/users_data_4.json")
	
	print(data.size())
	
	Date.populate_events(data, risk_data, 10)
	ordered_user_data = order_by_risk(data)
	pass
	
	
func order_by_risk(arr: Array) -> Array:
	var with_risk = []
	var without_risk = []
	
	# Pre-reservar memoria para mejor performance
	with_risk.resize(arr.size())
	without_risk.resize(arr.size())
	var idx_riesgo = 0
	var idx_without_risk = 0
	
	# Separacion eficiente sin asignaciones dinámicas
	for item in arr:
		var puntuacion: float = item["punctuation"]
		if puntuacion >= 4.5:
			with_risk[idx_riesgo] = item
			idx_riesgo += 1
		else:
			without_risk[idx_without_risk] = item
			idx_without_risk += 1
	
	# Recortar arrays al tamaño real
	with_risk.resize(idx_riesgo)
	without_risk.resize(idx_without_risk)
	
	# Ordenamiento optimizado (evitando lambdas)
	with_risk.sort_custom(self, "_compare_puntuacion")
	
	return with_risk + without_risk


# Funcion de comparacion separada para mejor performance
func _compare_puntuacion(a: Dictionary, b: Dictionary) -> bool:
	return a["punctuation"] > b["punctuation"]
