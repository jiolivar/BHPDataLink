# UnscheduledProcessDowntimeSlide.gd
extends Control

# Referencias al contenedor de botones y al pop-up.
# ¡Asegúrate de que los nombres $GridContainer y $Popup coincidan!
onready var grid_container = $"%GridContainer"
onready var popup = $"%Popup"

var botones_checkeados = 0
var total_botones = 0
var botones_ya_contados = []
# Una variable para recordar cuál fue el último botón que se presionó.
var boton_activo = null

func _ready():
	# 1. Conectar la señal de CADA botón a nuestra función.
	# Recorremos todos los hijos del GridContainer.
	for boton in grid_container.get_children():
		# Conectamos su señal "boton_presionado" a nuestra función "_on_CodeButton_presionado".
		# Le pasamos el propio botón como argumento para saber cuál fue.
		boton.connect("boton_presionado", self, "_on_CodeButton_presionado", [boton])

	# 2. Conectamos la señal de cierre del pop-up.
	popup.connect("popup_cerrado", self, "_on_Popup_cerrado")
	
	#Contar total de botones al iniciar
	total_botones = grid_container.get_children().size()
	print("Total de botones a checkear: ", total_botones)

# Esta función se ejecuta cuando CUALQUIER CodeButton emite su señal.
func _on_CodeButton_presionado(codigo_recibido, titulo_recibido, descripcion_recibida, boton_que_fue_presionado):
	print("Señal recibida, abriendo popup...") # <-- Print para confirmar que la señal llega
	boton_activo = boton_que_fue_presionado
	# Unimos el código y el título para el primer argumento del pop-up
	var titulo_completo = codigo_recibido + " - " + titulo_recibido
	# Llamamos a TU función con los datos correctos
	popup.mostrar_info(titulo_completo, descripcion_recibida)


# Esta función se ejecuta cuando el pop-up se cierra.
func _on_Popup_cerrado():
	# Si tenemos un botón activo guardado...
	if boton_activo != null:
		# Comprobamos si el botón NO está en nuestra lista de ya contados.
		if not boton_activo in botones_ya_contados:
			# Si no está, entonces procedemos:
			
			# 1. Mostramos su check.
			boton_activo.mostrar_check()
			
			# 2. Lo añadimos a la lista para que no se vuelva a contar.
			botones_ya_contados.append(boton_activo)

			# 3. Incrementamos el contador.
			botones_checkeados += 1
			print("Botones checkeados: ", botones_checkeados, " de ", total_botones)

			# 4. Comprobamos si hemos terminado.
			if botones_checkeados == total_botones:
				print("¡TODOS LOS BOTONES HAN SIDO CHECKEADOS!")
				# Si completamos, llamamos a la transición AHORA.
				Signals.emit_signal("exercise_win", 3, 0)
				Transition.change_scene(Main.advance_exercise_and_get_next())

		# Limpiamos la variable para el próximo clic, sin importar si se contó o no.
		boton_activo = null
