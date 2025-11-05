# TUMDef.gd
extends Control

# La señal para comunicarse con la escena principal sigue igual.
signal boton_presionado(texto_para_mostrar)

# --- VARIABLES ---
onready var botones = [
	$VBoxContainer/Calendar/Button, $VBoxContainer/Required/Button2,
	$VBoxContainer/Required/Button, $VBoxContainer/Available/Button2,
	$VBoxContainer/Available/Button,
	$UEDButton, $SEDButton,
	$VBoxContainer/Cycle/Button2, $VBoxContainer/Cycle/Button,
	$UEDButton2, $SEDButton2,
	$NVPTButton, $PTButtom
]

var descripciones = [
	"Esto puede ser un turno, día, semana, mes o año.",
	"El tiempo en espera es cuando el equipo no es requerido o planificado, por ejemplo, cuando está fuera de arriendo o por algún otro factor fuera del control de BHP.",
	"El tiempo requerido es cuando el equipo está planificado para estar en el sitio (o en arriendo). Ya sea en uso para producción o en mantenimiento.",
	"El tiempo de inactividad del equipo significa que el equipo no está funcionando.",
	"El tiempo disponible significa que el equipo está funcionando y puede ser utilizado.",
	"El tiempo de inactividad no programado es cuando el equipo se vuelve inesperadamente no disponible, ya sea por daños o fallas del equipo.",
	"El mantenimiento programado es tiempo de inactividad planificado para realizar mantenimiento preventivo o correctivo.",
	"El tiempo de inactividad del proceso es cuando el ciclo de producción ha sido interrumpido.",
	"El tiempo de ciclo es cuando el equipo está operando dentro del ciclo de producción.",
	"El tiempo de inactividad no programado del proceso es cuando ocurre una interrupción no planificada debido a problemas ajenos al equipo, como eventos climáticos o movimientos no programados del equipo.",
	"El tiempo de inactividad programado del proceso es una interrupción planificada debido a actividades que apoyan la producción pero que no son directamente tiempo de producción.",
	"El tiempo en cola o espera es perjudicial para el tiempo de producción. Se clasifica como tiempo sin valor agregado dentro del ciclo de producción.",
	"El tiempo de producción cuenta para la Utilización y las horas Anualizadas de camiones."
]

var indice_boton_actual = -1

# --- FUNCIONES DE GODOT ---
func _ready():
	# La configuración inicial no cambia.
	for i in range(botones.size()):
		var boton = botones[i]
		if boton != null:
			boton.connect("pressed", self, "_on_BotonConcepto_pressed", [i])
		else:
			print("ADVERTENCIA en TUMDef: El botón en el índice ", i, " no fue encontrado.")

	for i in range(1, botones.size()):
		if botones[i] != null:
			botones[i].modulate.a = 0
			botones[i].mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if botones.size() > 0 and botones[0] != null:
		botones[0].modulate.a = 1
	# Pega esto al final de tu func _ready() en TUMDef.gd

	print("--- DIAGNÓSTICO DEL ARRAY 'botones' EN TUMDEF ---")
	for i in range(botones.size()):
		if botones[i] == null:
			print("Línea ", i, ": ¡ERROR! No se encontró el nodo. La ruta en esta línea del array está mal.")
		else:
			print("Línea ", i, ": OK - Encontrado: ", botones[i].name)
	print("--- FIN DEL DIAGNÓSTICO ---")

# --- FUNCIONES INTERNAS ---
func _on_BotonConcepto_pressed(indice):
	indice_boton_actual = indice
	if botones[indice] != null:
		botones[indice].disabled = true
	
	# Ahora emitimos la señal con ambos datos: el índice y el texto.
	if indice < descripciones.size():
		emit_signal("boton_presionado", indice, descripciones[indice])
	
	# La lógica de prueba para ejecutar la escena sola sigue funcionando igual.
	if get_parent() == get_tree().root:
		revelar_siguiente_boton()

# --- FUNCIONES PÚBLICAS ---
func revelar_siguiente_boton():
	var proximo_indice = indice_boton_actual + 1
	if proximo_indice < botones.size():
		var proximo_boton = botones[proximo_indice]
		if proximo_boton != null:
			proximo_boton.modulate.a = 1
			proximo_boton.mouse_filter = Control.MOUSE_FILTER_STOP

