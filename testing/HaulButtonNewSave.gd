# TruckButton.gd
tool
extends Button

# ====================================================================
# SEÑALES Y VARIABLES DE DOBLE CLIC
# ====================================================================
signal double_click_detected(machine_id)
signal status_update_requested(machine_id, status_code) # Emits NUMERIC code (1000, etc.)
signal quick_dispatch_request(machine_id, status_code) # Emits NUMERIC code (1000, etc.)
signal right_click_detected(machine_id)

var last_click_time = 0.0
const DOUBLE_CLICK_TIME = 0.3
const QUICK_STATUS_CODES = [
	1000, # Operativo
	2000, 2010, 2020, 2090, # Demora
	4000, 4010, 4020, 4040, 4070, 4080, 4150, # Espera
	5000, 5010 # Panne
]
# --- Menús Contextuales ---
var context_menu: PopupMenu       # Menú principal
var operativo_submenu: PopupMenu
var demora_submenu: PopupMenu
var espera_submenu: PopupMenu
var panne_submenu: PopupMenu

# ====================================================================
# ORGANIZACIÓN DE CÓDIGOS
# ====================================================================
const CATEGORIZED_REASON_CODES = {
	"OPERATIVO": [{"code": 1000, "reason": "OPERATIVO BASE"}],
	"DEMORA": [
		{"code": 2000, "reason": "DEMORA BASE"}, {"code": 2010, "reason": "COLACION"},
		{"code": 2020, "reason": "OTRA DEMORA"}, {"code": 2090, "reason": "FIN DEMORA"}
	],
	"ESPERA": [ # Mapeado desde el ID 3000 (Reserva)
		{"code": 4000, "reason": "ESPERA BASE"}, {"code": 4010, "reason": "CAMBIO DE SITIO"},
		{"code": 4020, "reason": "OTRA ESPERA"}, {"code": 4040, "reason": "ESPERA X"},
		{"code": 4070, "reason": "ESPERA Y"}, {"code": 4080, "reason": "ESPERA Z"},
		{"code": 4150, "reason": "ESPERA W"}
	],
	"PANNE": [ # Mapeado desde el ID 4000 (Panne)
		{"code": 5000, "reason": "MALFUNCIONAMIENTO"}, {"code": 5010, "reason": "OTRO PANNE"}
	]
}
const MENU_ID_TO_CATEGORY = {
	1000: "OPERATIVO", 2000: "DEMORA", 3000: "ESPERA", 4000: "PANNE"
}

# ====================================================================
# ENUMs, EXPORTACIONES y DICCIONARIOS
# ====================================================================
enum TruckStatus { BLANCO, VERDE, AMARILLO, ROJO }
export(String) var truck_id = "CEX00" setget _set_truck_id
export(TruckStatus) var truck_status = TruckStatus.BLANCO setget _set_truck_status
export(bool) var show_x_overlay_on_label = false setget _set_show_x_overlay_on_label
export(Color) var x_color_on_label = Color.yellow setget _set_x_color_on_label
export(float) var x_line_width_on_label = 3.0 setget _set_x_line_width_on_label

var status_colors = {
	TruckStatus.BLANCO: Color(0xfbfdfcff), TruckStatus.VERDE: Color(0x88df90ff),
	TruckStatus.ROJO: Color(0xfe7145ff), TruckStatus.AMARILLO: Color(0xfbcb01ff),
}

# ====================================================================
# SETTERS y APARIENCIA (SIMPLE SETTER RESTORED)
# ====================================================================
func _set_truck_id(new_id: String):
	truck_id = new_id
	if not is_inside_tree(): return
	var label_node = get_node_or_null("Label")
	if label_node: label_node.text = truck_id

# Setter simple restaurado - Espera el índice del ENUM (0, 1, 2, 3)
func _set_truck_status(new_status_index: int):
	if new_status_index >= 0 and new_status_index < TruckStatus.size():
		truck_status = new_status_index
	else:
		print("WARN: Invalid TruckStatus index received: ", new_status_index)
		truck_status = TruckStatus.BLANCO
	if is_inside_tree():
		call_deferred("_update_button_appearance") # Usar call_deferred por seguridad en tool mode

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

# --- FUNCIÓN DE APARIENCIA CORREGIDA ---
func _update_button_appearance():
	if truck_status < 0 or truck_status >= TruckStatus.size():
		print("ERROR: _update_button_appearance called with invalid truck_status index: ", truck_status)
		truck_status = TruckStatus.BLANCO

	var base_color = status_colors.get(truck_status, status_colors[TruckStatus.BLANCO])
	var text_color = Color.black if base_color.v > 0.5 else Color.white

	# 1. ACTUALIZAR EL BOTÓN (Fondo del Button)
	var normal_style = get_stylebox("normal", "Button")
	if not (normal_style is StyleBoxFlat): normal_style = StyleBoxFlat.new()
	if normal_style.resource_path != "": normal_style = normal_style.duplicate()
	normal_style.bg_color = base_color
	add_stylebox_override("normal", normal_style) # Nombre correcto

	var hover_style = get_stylebox("hover", "Button")
	if not (hover_style is StyleBoxFlat): hover_style = StyleBoxFlat.new()
	if hover_style.resource_path != "": hover_style = hover_style.duplicate()
	hover_style.bg_color = base_color.lightened(0.15)
	add_stylebox_override("hover", hover_style) # Nombre correcto

	var pressed_style = get_stylebox("pressed", "Button")
	if not (pressed_style is StyleBoxFlat): pressed_style = StyleBoxFlat.new()
	if pressed_style.resource_path != "": pressed_style = pressed_style.duplicate()
	pressed_style.bg_color = base_color.darkened(0.15)
	add_stylebox_override("pressed", pressed_style) # Nombre correcto

	add_color_override("font_color", text_color)
	add_color_override("font_color_hover", text_color)
	add_color_override("font_color_pressed", text_color)

	# 2. ACTUALIZAR EL LABEL HIJO
	var label_node = get_node_or_null("Label")
	if label_node:
		var label_bg_style = label_node.get_stylebox("normal", "Label")
		if not (label_bg_style is StyleBoxFlat): label_bg_style = StyleBoxFlat.new()
		if label_bg_style.resource_path != "": label_bg_style = label_bg_style.duplicate()
		label_bg_style.bg_color = base_color
		label_node.add_stylebox_override("normal", label_bg_style) # Nombre correcto
		label_node.add_color_override("font_color", text_color)
		label_node.update()

	update()
# --- FIN FUNCIÓN CORREGIDA ---

# ====================================================================
# INICIALIZACIÓN
# ====================================================================
func _ready():
	_set_truck_id(truck_id)
	call_deferred("_set_truck_status", truck_status) # Llamada diferida
	_set_show_x_overlay_on_label(show_x_overlay_on_label)
	_set_x_color_on_label(x_color_on_label)
	_set_x_line_width_on_label(x_line_width_on_label)
	_setup_context_menus()
	connect("gui_input", self, "_on_haul_button_gui_input")

# ====================================================================
# CONFIGURACIÓN DE MENÚS CONTEXTUALES ANIDADOS
# ====================================================================
func _setup_context_menus():
	context_menu = PopupMenu.new()
	context_menu.name = "MachineContextMenu"
	add_child(context_menu)

	operativo_submenu = PopupMenu.new()
	operativo_submenu.name = "OperativoSubmenu"
	context_menu.add_child(operativo_submenu)

	demora_submenu = PopupMenu.new()
	demora_submenu.name = "DemoraSubmenu"
	context_menu.add_child(demora_submenu)

	espera_submenu = PopupMenu.new()
	espera_submenu.name = "EsperaSubmenu"
	context_menu.add_child(espera_submenu)

	panne_submenu = PopupMenu.new()
	panne_submenu.name = "PanneSubmenu"
	context_menu.add_child(panne_submenu)

	var white_panel_style = StyleBoxFlat.new()
	white_panel_style.bg_color = Color(1.0, 1.0, 1.0)
	var temp_theme = Theme.new()
	temp_theme.set_stylebox("panel", "PopupMenu", white_panel_style)
	temp_theme.set_color("font_color", "PopupMenu", Color.black)
	temp_theme.set_color("font_color_hover", "PopupMenu", Color.black)
	context_menu.set_theme(temp_theme)
	operativo_submenu.set_theme(temp_theme)
	demora_submenu.set_theme(temp_theme)
	espera_submenu.set_theme(temp_theme)
	panne_submenu.set_theme(temp_theme)

	_populate_submenu(operativo_submenu, CATEGORIZED_REASON_CODES.get("OPERATIVO", []))
	_populate_submenu(demora_submenu, CATEGORIZED_REASON_CODES.get("DEMORA", []))
	_populate_submenu(espera_submenu, CATEGORIZED_REASON_CODES.get("ESPERA", []))
	_populate_submenu(panne_submenu, CATEGORIZED_REASON_CODES.get("PANNE", []))

	context_menu.add_item("Pala " + truck_id, 999, false)
	context_menu.add_separator()
	context_menu.add_item("Mensaje", 100)
	context_menu.add_submenu_item("Operativo", operativo_submenu.name, 1000)
	context_menu.add_submenu_item("Demora", demora_submenu.name, 2000)
	context_menu.add_submenu_item("Reserva", espera_submenu.name, 3000)
	context_menu.add_submenu_item("Panne", panne_submenu.name, 4000)

	var item_ids_to_check = [1000, 2000, 3000, 4000]
	for item_id in item_ids_to_check:
		var index = context_menu.get_item_index(item_id)
		if index != -1:
			context_menu.set_item_as_checkable(index, true)

	context_menu.connect("id_pressed", self, "_on_context_menu_id_pressed")
	context_menu.connect("about_to_show", self, "_on_context_menu_about_to_show")

	operativo_submenu.connect("id_pressed", self, "_on_reason_code_selected")
	demora_submenu.connect("id_pressed", self, "_on_reason_code_selected")
	espera_submenu.connect("id_pressed", self, "_on_reason_code_selected")
	panne_submenu.connect("id_pressed", self, "_on_reason_code_selected")

func _populate_submenu(submenu: PopupMenu, codes: Array):
	submenu.clear()
	if codes.empty():
		submenu.add_item("No codes", -1, false)
	else:
		for item in codes:
			var menu_text = str(item.code).pad_zeros(4) + " " + item.reason
			submenu.add_item(menu_text, item.code)

# ====================================================================
# LÓGICA DE ACTUALIZACIÓN DEL MARCADO (✓)
# ====================================================================
func _on_context_menu_about_to_show():
	var status_to_check_id = -1
	match truck_status:
		TruckStatus.VERDE: status_to_check_id = 1000
		TruckStatus.AMARILLO: status_to_check_id = 2000
		TruckStatus.BLANCO: status_to_check_id = 3000
		TruckStatus.ROJO: status_to_check_id = 4000
	
	for i in range(context_menu.get_item_count()):
		if context_menu.is_item_checkable(i):
			context_menu.set_item_checked(i, false)
			
	if status_to_check_id != -1:
		var item_index = context_menu.get_item_index(status_to_check_id)
		if item_index != -1:
			context_menu.set_item_checked(item_index, true)

# ====================================================================
# MANEJADORES DE EVENTOS DE ENTRADA Y SELECCIÓN
# ====================================================================
func _on_haul_button_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		var time_since_last_click = OS.get_ticks_usec() / 1000000.0 - last_click_time
		if time_since_last_click < DOUBLE_CLICK_TIME:
			emit_signal("double_click_detected", truck_id)
			get_tree().set_input_as_handled()
		last_click_time = OS.get_ticks_usec() / 1000000.0
	
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and event.pressed:
		context_menu.popup(Rect2(get_global_mouse_position(), Vector2(10, 10)))
		get_tree().set_input_as_handled()
		emit_signal("right_click_detected", truck_id)

# ====================================================================
# MANEJADORES DE CONEXIONES (Funciones Slot)
# ====================================================================

func _on_context_menu_id_pressed(id: int):
	if id == 100:
		print("Mensaje action selected")
		context_menu.hide()

func _on_reason_code_selected(status_code: int):
	if status_code in QUICK_STATUS_CODES:
		emit_signal("quick_dispatch_request", truck_id, status_code)
	else:
		emit_signal("status_update_requested", truck_id, status_code)

	if operativo_submenu.is_visible(): operativo_submenu.hide()
	if demora_submenu.is_visible(): demora_submenu.hide()
	if espera_submenu.is_visible(): espera_submenu.hide()
	if panne_submenu.is_visible(): panne_submenu.hide()
	if context_menu.is_visible():
		context_menu.hide()

func _on_TruckButton_pressed():
	pass

func _physics_process(_delta):
	set_physics_process(false)
	get_tree().set_input_as_handled()
