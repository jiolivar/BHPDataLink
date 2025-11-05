extends Node

var month_names = [
		"", "Ene.", "Feb.", "Mar.", 
		"Abr.", "May.", "Jun.", 
		"Jul.", "Ago.", "Sep.", 
		"Oct.", "Nov.", "Dic."
	]

# Main filtering function (same as before)
func filter_events(events: Array, limit_time: String) -> Array:
	var result = []
	var current_date = OS.get_date()
	
	for event in events:
		var event_datetime = _parse_date_time(event["event_time"])
		var event_time_str = "%02d:%02d:%02d" % [event_datetime["hour"], event_datetime["minute"], event_datetime["second"]]
		
		if is_current_date(event_datetime, current_date) && is_time_later(event_time_str, limit_time):
			result.append(event)
	
	return result

# Updated date parser for new format
func _parse_date_time(date_time_str: String) -> Dictionary:
	var date_time_parts = date_time_str.split(" ")
	var date_part = date_time_parts[0].split("/")
	var time_part = date_time_parts[1].split(":")
	
	return {
		"day": int(date_part[0]),
		"month": int(date_part[1]),
		"year": int(date_part[2]),
		"hour": int(time_part[0]),
		"minute": int(time_part[1]),
		"second": int(time_part[2])
	}

func is_current_date(event_datetime: Dictionary, current_date: Dictionary) -> bool:
	return (
		event_datetime["day"] == current_date["day"] &&
		event_datetime["month"] == current_date["month"] &&
		event_datetime["year"] == current_date["year"]
	)

func is_time_later(event_time: String, limit_time: String) -> bool:
	var event_seconds = time_to_seconds(event_time)
	var limit_seconds = time_to_seconds(limit_time)
	return event_seconds > limit_seconds

func time_to_seconds(time_str: String) -> int:
	var parts = time_str.split(":")
	return int(parts[0]) * 3600 + int(parts[1]) * 60 + int(parts[2])



func populate_events(events: Array, risk_events: Dictionary, n_current_day: int) -> void:
	var current_time = OS.get_unix_time()
	var current_datetime = OS.get_datetime()
	
	# Calcular timestamp de medianoche actual
	var midnight_today = get_midnight_timestamp(current_datetime)
	
	# Rango para fechas pasadas (1 año atrás hasta ayer)
	var one_year_ago = midnight_today - 31536000  # 365 días en segundos
	
	var current_day_count = 0
	
	for event in events:
		var timestamp: int
		
		if current_day_count < n_current_day:
			# Generar timestamp para el día actual (hora anterior a actual)
			timestamp = generate_current_day_timestamp(midnight_today, current_time)
			if timestamp < current_time:  # Verificar válido
				current_day_count += 1
			else:
				timestamp = generate_past_timestamp(one_year_ago, midnight_today)
		else:
			# Generar timestamp para días anteriores
			timestamp = generate_past_timestamp(one_year_ago, midnight_today)
		
		var text_time = format_datetime(OS.get_datetime_from_unix_time(timestamp))
		event["event_time"] = text_time
		
		if risk_events.has(event["user_name"]):
			
			for risk_event in risk_events[event["user_name"]]:
				risk_event["event_time"] = text_time
			
			pass

# Genera timestamp para día actual (hora < actual)
func generate_current_day_timestamp(midnight: int, current: int) -> int:
	var start = midnight
	var end = current - 1  # Excluir momento actual
	
	if start > end:
		return start  # No válido, será filtrado
	
	var time_range = end - start + 1
	return start + (randi() % time_range)

# Genera timestamp para días pasados
func generate_past_timestamp(start_date: int, end_date: int) -> int:
	var time_range = end_date - start_date
	if time_range <= 0:
		return start_date
	
	return start_date + (randi() % time_range)

# Obtiene timestamp de medianoche del día actual
func get_midnight_timestamp(datetime: Dictionary) -> int:
	return OS.get_unix_time_from_datetime({
		"year": datetime["year"],
		"month": datetime["month"],
		"day": datetime["day"],
		"hour": 0,
		"minute": 0,
		"second": 0
	})

# Formatea datetime al string requerido
func format_datetime(dt: Dictionary) -> String:
	return "%02d/%02d/%04d %02d:%02d:%02d" % [
		dt["day"], dt["month"], dt["year"],
		dt["hour"], dt["minute"], dt["second"]
	]



func get_date_text(godot_date: Dictionary) -> String:
	
	var dia = str(godot_date["day"]).pad_zeros(2)
	var mes = month_names[godot_date["month"]]
	var anio = str(godot_date["year"])
	
	var hora = str(godot_date["hour"]).pad_zeros(2)
	var minuto = str(godot_date["minute"]).pad_zeros(2)
	var segundo = str(godot_date["second"]).pad_zeros(2)
	
	return "%s %s %s %s:%s:%s" % [dia, mes, anio, hora, minuto, segundo]


func convert_date_format(date_str: String) -> String:
	# Dividir la fecha y hora
	var parts = date_str.split(" ")
	var date_part = parts[0]
	var time_part = parts[1]
	
	# Dividir día, mes, año
	var date_components = date_part.split("/")
	var day = date_components[0]
	var month = int(date_components[1])
	var year = date_components[2]
	
	# Obtener abreviatura del mes
	var month_abbr = month_names[month] if month >= 1 && month <= 12 else "Inv."
	
	# Construir nuevo formato
	return "%s %s %s %s" % [day, month_abbr, year, time_part]


func validate_and_normalize_time(time_str: String) -> Array:
	var parts = time_str.split(":")
	
	# Validar cantidad de componentes
	if parts.size() != 3:
		return ["", false]
	
	# Validar y convertir componentes numéricos
	var time_components = []
	for part in parts:
		if not part.is_valid_integer():
			return ["", false]
		time_components.append(int(part))
	
	# Extraer componentes individuales
	var hours = time_components[0]
	var minutes = time_components[1]
	var seconds = time_components[2]
	
	# Validar rangos
	if hours < 0 or hours > 23:
		return ["", false]
	if minutes < 0 or minutes > 59:
		return ["", false]
	if seconds < 0 or seconds > 59:
		return ["", false]
	
	# Formatear con ceros iniciales
	var normalized = "%02d:%02d:%02d" % [hours, minutes, seconds]
	return [normalized, true]
