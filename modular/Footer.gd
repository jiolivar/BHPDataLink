extends MarginContainer

onready var fecha_label = $"%CurrentDate"
onready var timer = Timer.new()

func _ready():
	actualizar_fecha_hora()
	
	# Configurar timer para actualización automática
	timer.wait_time = 60
	timer.one_shot = false
	timer.connect("timeout", self, "actualizar_fecha_hora")
	add_child(timer)
	timer.start()

func actualizar_fecha_hora():
	var datos_tiempo = OS.get_datetime()
	
	var dias = ["Domingo", "Lunes", "Martes", "Miércoles", 
			  "Jueves", "Viernes", "Sábado"]
			  
	var meses = ["Enero", "Febrero", "Marzo", "Abril", 
			   "Mayo", "Junio", "Julio", "Agosto", 
			   "Septiembre", "Octubre", "Noviembre", "Diciembre"]
	
	var texto_fecha = "%s, %d de %s %d %02d:%02d" % [
		dias[datos_tiempo["weekday"]],
		datos_tiempo["day"],
		meses[datos_tiempo["month"] - 1],
		datos_tiempo["year"],
		datos_tiempo["hour"],
		datos_tiempo["minute"]
	]
	
	fecha_label.text = texto_fecha
