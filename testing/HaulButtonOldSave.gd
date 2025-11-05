# TruckButton.gd
tool
extends Button

# ====================================================================
# SEÑALES Y VARIABLES DE DOBLE CLIC
# ====================================================================

# Señal de doble clic (para abrir la ventana principal)
signal double_click_detected(machine_id) 
# Nueva señal para notificar al controlador el cambio rápido de estado (clic derecho)
signal status_update_requested(machine_id, status_code) 
signal quick_dispatch_request(machine_id, status_code) # Nueva señal para el atajo
signal right_click_detected(machine_id)
signal popup_opened(button_name)

var last_click_time = 0.0
const DOUBLE_CLICK_TIME = 0.3 # Umbral de doble clic.
const QUICK_STATUS_CODES = [1000, 2000, 4010, 5000]
# --- Menús Contextuales ---
var context_menu: PopupMenu       # Menú principal (Operativo, Demora, etc.)
var reason_code_menu: PopupMenu # Submenú de códigos (0200, 1200, etc.)
var is_opening_submenu = false # Nueva flag para la cancelación de cierre.
# Ahora es una función que devuelve el valor, lo que evita el error del parser.

# Diccionario de codigos
const CATEGORIZED_REASON_CODES = {
	"OPERATIVO": [
		{"code": 1000, "reason": "OPERATIVO BASE"} # Example name
		# Add other 1xxx codes if needed
	],
	"DEMORA": [
		{"code": 2000, "reason": "DEMORA BASE"},
		{"code": 2010, "reason": "COLACION"},
		{"code": 2020, "reason": "OTRA DEMORA"},
		{"code": 2090, "reason": "FIN DEMORA"}
		# Add other 2xxx codes
	],
	"ESPERA": [ # Using "ESPERA" for 4xxx codes as per your request
		{"code": 4000, "reason": "ESPERA BASE"},
		{"code": 4010, "reason": "CAMBIO DE SITIO"},
		{"code": 4020, "reason": "OTRA ESPERA"},
		{"code": 4040, "reason": "ESPERA X"},
		{"code": 4070, "reason": "ESPERA Y"},
		{"code": 4080, "reason": "ESPERA Z"},
		{"code": 4150, "reason": "ESPERA W"}
	],
	"PANNE": [
		{"code": 5000, "reason": "MALFUNCIONAMIENTO"},
		{"code": 5010, "reason": "OTRO PANNE"}
		# Add other 5xxx codes
	]
}

# Mapping from main menu ID to category key in the dictionary above
const MENU_ID_TO_CATEGORY = {
	1000: "OPERATIVO",
	2000: "DEMORA",
	3000: "ESPERA", # Assuming Reserva maps to Espera codes
	4000: "PANNE"
}


# Función auxiliar para desactivar el flag después de la apertura.
func _reset_submenu_flag():
	is_opening_submenu = false




func _get_reason_codes_master() -> Array:
	return [
		# Añadir los códigos de estado principales que activan el atajo
		{"code": 1000, "reason": "OPERATIVO"}, 
		{"code": 2000, "reason": "CAMBIO DE TURNO"}, 
		{"code": 4010, "reason": "CAMBIO DE SITIO"}, 
		{"code": 5000, "reason": "MALFUNCIONAMIENTO"}
		# Añadir otros códigos de razón detallados si es necesario (ej: 2010, 1200)
		#{"code": 2010, "reason": "COLACION"},
		#{"code": 1200, "reason": "ENTRENAMIENTO/PRUEBAS"},
	]

# ====================================================================
# ENUMs, EXPORTACIONES y DICCIONARIOS
# ====================================================================

enum TruckStatus {
	BLANCO, VERDE, AMARILLO, ROJO
}

# --- Variables Exportadas con setget ---
export(String) var truck_id = "CEX00" setget _set_truck_id
export(TruckStatus) var truck_status = TruckStatus.BLANCO setget _set_truck_status
export(bool) var show_x_overlay_on_label = false setget _set_show_x_overlay_on_label
export(Color) var x_color_on_label = Color.yellow setget _set_x_color_on_label
export(float) var x_line_width_on_label = 3.0 setget _set_x_line_width_on_label

# Diccionario de colores (Se mantiene igual)
var status_colors = {
	TruckStatus.BLANCO: Color(0xfbfdfcff),
	TruckStatus.VERDE: Color(0x88df90ff),
	TruckStatus.ROJO: Color(0xfe7145ff),
	TruckStatus.AMARILLO: Color(0xfbcb01ff),
}


# ====================================================================
# SETTERS y APARIENCIA (Se mantienen igual)
# ====================================================================

func _set_truck_id(new_id: String):
	truck_id = new_id
	if not is_inside_tree(): return
	var label_node = get_node_or_null("Label")
	if label_node:
		label_node.text = truck_id

func _set_truck_status(new_status: int):
	truck_status = new_status
	if not is_inside_tree(): return
	_update_button_appearance()

func _set_show_x_overlay_on_label(value: bool):
	show_x_overlay_on_label = value
	if not is_inside_tree(): return
	var label_node = get_node_or_null("Label")
	if label_node and label_node.has_method("_set_show_x_overlay"):
		label_node._set_show_x_overlay(value)
		disabled = value

func _set_x_color_on_label(value: Color):
	x_color_on_label = value
	if not is_inside_tree(): return
	var label_node = get_node_or_null("Label")
	if label_node and label_node.has_method("_set_x_color"):
		label_node._set_x_color(value)

func _set_x_line_width_on_label(value: float):
	x_line_width_on_label = value
	if not is_inside_tree(): return
	var label_node = get_node_or_null("Label")
	if label_node and label_node.has_method("_set_x_line_width"):
		label_node._set_x_line_width(value)

func _update_button_appearance():
	var base_color = status_colors.get(truck_status, status_colors[TruckStatus.BLANCO])
	var text_color = Color.black if base_color.v > 0.5 else Color.white
	
	# 1. ACTUALIZAR EL BOTÓN (Fondo del Button)
	
	# Estilo Normal (Button)
	var normal_style = get_stylebox("normal")
	if not (normal_style is StyleBoxFlat):
		normal_style = StyleBoxFlat.new()
		add_stylebox_override("normal", normal_style)
	if normal_style.resource_path != "":
		normal_style = normal_style.duplicate()
		add_stylebox_override("normal", normal_style)
	normal_style.bg_color = base_color

	# Estilos Hover y Pressed (Solo para completar la funcionalidad)
	var hover_style = get_stylebox("hover")
	if not (hover_style is StyleBoxFlat):
		hover_style = StyleBoxFlat.new()
		add_stylebox_override("hover", hover_style) 
	if hover_style.resource_path != "":
		hover_style = hover_style.duplicate()
		add_stylebox_override("hover", hover_style)
	hover_style.bg_color = base_color.lightened(0.15)
	
	var pressed_style = get_stylebox("pressed")
	if not (pressed_style is StyleBoxFlat):
		pressed_style = StyleBoxFlat.new()
		add_stylebox_override("pressed", pressed_style) 
	if pressed_style.resource_path != "":
		pressed_style = pressed_style.duplicate()
		add_stylebox_override("pressed", pressed_style)
	pressed_style.bg_color = base_color.darkened(0.15)
	
	# Color del texto nativo del Button
	add_color_override("font_color", text_color)
	
	# 2. ACTUALIZAR EL LABEL HIJO (Fondo del Label y Color de Fuente)
	
	var label_node = get_node_or_null("Label")
	if label_node:
		# Fondo del Label
		var label_bg_style = label_node.get_stylebox("normal")
		if not (label_bg_style is StyleBoxFlat):
			label_bg_style = StyleBoxFlat.new()
			label_node.add_stylebox_override("normal", label_bg_style) 
		if label_bg_style.resource_path != "":
			label_bg_style = label_bg_style.duplicate()
			label_node.add_stylebox_override("normal", label_bg_style)

		label_bg_style.bg_color = base_color 

		# Color de fuente del Label
		label_node.add_color_override("font_color", text_color)


# ====================================================================
# INICIALIZACIÓN
# ====================================================================

func _ready():
	_set_truck_id(truck_id)
	_set_truck_status(truck_status)
	_set_show_x_overlay_on_label(show_x_overlay_on_label)
	_set_x_color_on_label(x_color_on_label)
	_set_x_line_width_on_label(x_line_width_on_label)
	
	# NUEVO: Configuración de menús y conexión de entrada
	_setup_context_menus()
	connect("gui_input", self, "_on_haul_button_gui_input")
	
	

# ====================================================================
# CONFIGURACIÓN DE MENÚS CONTEXTUALES ANIDADOS
# ====================================================================

func _setup_context_menus():
	# 1. Instanciar los nodos
	context_menu = LockablePopupMenu.new()
	reason_code_menu = LockablePopupMenu.new()
	
	#context_menu.debug_lock = OS.is_debug_build()
	#reason_code_menu.debug_lock = OS.is_debug_build()

	# 2. CREAR TEMA PERSONALIZADO (Fondo Blanco, Texto Negro)
	var white_panel_style = StyleBoxFlat.new()
	white_panel_style.bg_color = Color(1.0, 1.0, 1.0) # Fondo Blanco
	
	var temp_theme = Theme.new()
	temp_theme.set_stylebox("panel", "PopupMenu", white_panel_style)
	temp_theme.set_color("font_color", "PopupMenu", Color.black)
	temp_theme.set_color("font_color_hover", "PopupMenu", Color.black)
	
	# Aplicar el tema a ambos menús
	context_menu.set_theme(temp_theme)
	reason_code_menu.set_theme(temp_theme)

	# 3. CONSTRUCCIÓN DE LA JERARQUÍA
	context_menu.name = "MachineContextMenu"
	
	add_child(context_menu)
	reason_code_menu.name = "ReasonCodeMenu"
	context_menu.add_child(reason_code_menu) # Submenú es hijo del menú principal
	reason_code_menu.connect("id_pressed", self, "_on_reason_code_selected")
	# 4. LLENADO DEL SUBMENÚ (Usa la lista corregida)
	var reason_codes = _get_reason_codes_master()
	
	for item in reason_codes:
		var menu_text = str(item.code).pad_zeros(4) + " " + item.reason
		reason_code_menu.add_item(menu_text, item.code) 
	
	# 5. LLENADO DEL MENÚ PRINCIPAL
	context_menu.add_item("Pala " + truck_id, 999, false)
	context_menu.add_separator()
	
	# Opciones de Submenú
	context_menu.add_item("Mensaje", 100)
	# Utilizamos el prefijo >> para simular visualmente que estos son submenús
	context_menu.add_item("Operativo >", 1000) 
	context_menu.add_item("Demora >", 2000)
	context_menu.add_item("Reserva >", 3000)
	context_menu.add_item("Panne >", 4000) # Usamos 4000 como ID

	# Habilitar el chequeo para los ítems de estado (se mantiene)
	var item_ids_to_check = [1000, 2000, 3000, 4000] 
	
	for item_id in item_ids_to_check:
		var index = context_menu.get_item_index(item_id)
		if index != -1:
			context_menu.set_item_as_checkable(index, true)
			
	# --- CONEXIONES ---
	context_menu.connect("id_pressed", self, "_on_context_menu_id_pressed")
	context_menu.connect("about_to_show", self, "_on_context_menu_about_to_show")

# --------------------------------------------------------------------
# LÓGICA DE ACTUALIZACIÓN DEL MARCADO (✓)
# --------------------------------------------------------------------

# Función que se llama justo antes de mostrar el menú para actualizar la marca de verificación.
func _on_context_menu_about_to_show():
	
	var status_to_check = -1
	
	# 1. Mapear el estado actual del botón (enum) al ID del menú (int).
	match truck_status:
		TruckStatus.VERDE: # Mapea VERDE (Operativo)
			status_to_check = 1000
		TruckStatus.AMARILLO: # Mapea AMARILLO (Demora - aunque el submenú maneja los detalles)
			status_to_check = 2000 
		TruckStatus.BLANCO: # Mapea BLANCO (Reserva/Mensaje)
			status_to_check = 3000 # Asumiendo 3000 es el estado por defecto o Reserva
		TruckStatus.ROJO: # Mapea ROJO (Panne)
			status_to_check = 4000
	
	# 2. Desmarcar todos los ítems y marcar solo el activo
	for i in range(context_menu.get_item_count()):
		context_menu.set_item_checked(i, false) # Desmarcar todos
		
	if status_to_check != -1:
		var item_index = context_menu.get_item_index(status_to_check)
		if item_index != -1:
			context_menu.set_item_checked(item_index, true) # Marcar el ítem actual


# ====================================================================
# MANEJADORES DE EVENTOS DE ENTRADA Y SELECCIÓN
# ====================================================================

func _on_haul_button_gui_input(event: InputEvent):
	# Lógica de doble clic (Botón Izquierdo)
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		var time_since_last_click = OS.get_ticks_usec() / 1000000.0 - last_click_time
		
		if time_since_last_click < DOUBLE_CLICK_TIME:
			# Doble clic detectado. Emitir señal para abrir ventana principal.
			emit_signal("double_click_detected", truck_id) 
			get_tree().set_input_as_handled()
		
		last_click_time = OS.get_ticks_usec() / 1000000.0
	
	# Clic Derecho
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and event.pressed:
		# Mostrar el menú contextual en la posición del ratón.
		context_menu.popup(Rect2(get_global_mouse_position(), Vector2(10, 10))) 
		get_tree().set_input_as_handled()
		emit_signal("right_click_detected", truck_id)

# ====================================================================
# MANEJADORES DE CONEXIONES (Funciones Slot)
# ====================================================================

func _reopen_context_menu_deferred(item_index):
	# La reabrimos en el mismo lugar, pero de forma diferida.
	context_menu.call_deferred("popup", context_menu.get_global_rect())


func _on_context_menu_id_pressed(id: int):
	
	if id == 1000 or id == 2000 or id == 3000 or id == 4000:
		
		var index_of_item = context_menu.get_item_index(id)
		
		# 1. Calcular la posición y abrir el submenú (el código de submenú se mantiene).
		var main_menu_pos = context_menu.get_global_rect().position
		var submenu_x = main_menu_pos.x + context_menu.rect_size.x
		var item_height = 25.0
		var submenu_y = main_menu_pos.y + (index_of_item * item_height)
		
		# 2. Requerir la reapertura del menú principal de forma diferida.
		# Esto forzará que el menú principal se reabra inmediatamente después de que el motor lo cierre.
		call_deferred("_reopen_context_menu_deferred", index_of_item)
		
		# 3. Abrir el submenú.
		reason_code_menu.popup(Rect2(Vector2(submenu_x, submenu_y), Vector2(1, 1)))
		return

	# 2. PROCESAR ACCIONES DIRECTAS
	if id == 100:
		context_menu.hide() # Cerrar solo si la acción fue directa
		return
		
	# 3. PROCESAR ACCIONES DE ESTADO FINALES
	if id == 1000 or id == 3000 or id == 4000:
		emit_signal("status_update_requested", truck_id, id)
		# Esto es solo para acciones directas (aunque la lógica superior ya las interceptó)
		context_menu.hide()

# Función que se ejecuta cuando se selecciona un código del SUBMENÚ.
func _on_reason_code_selected(status_code: int):
	# status_code viene directamente del 'id' del ítem seleccionado en el PopupMenu.

	# 1. Verificar si es un código de "Atajo Rápido"
	if status_code in QUICK_STATUS_CODES:
		# Emite la señal para que el controlador abra la ventana de Despacho
		# y autocomplete con el ID de este botón y el código.
		emit_signal("quick_dispatch_request", truck_id, status_code)
		
		# Opcional: Cierra el menú automáticamente (siempre una buena práctica)
		if context_menu.is_visible():
			context_menu.hide()

	else:
		# 2. Comportamiento normal (solo actualiza el estado local/modelo)
		emit_signal("status_update_requested", truck_id, status_code)
		
	# --- CIERRE FINAL DE AMBOS MENÚS ---
	# Aseguramos que el submenú se oculte y luego el principal.
	if reason_code_menu.is_visible():
		reason_code_menu.hide()

	if context_menu.is_visible():
		context_menu.hide()


# La función _on_TruckButton_pressed() se puede eliminar o mantener como placeholder
func _on_TruckButton_pressed():
	pass

# Función nativa que se usa para consumir el evento tras el doble clic.
func _physics_process(_delta):
	set_physics_process(false)
	get_tree().set_input_as_handled()



