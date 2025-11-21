extends WindowDialog

# --- COLORES TEMA EXCEL/WINDOWS ---
const COL_BG_WHITE = Color("#ffffff")
const COL_BG_LIGHT_GRAY = Color("#f3f3f3") # Para fondos de paneles
const COL_BORDER = Color("#d4d4d4")        # Gris suave para bordes
const COL_TEXT_BLACK = Color("#000000")
const COL_TEXT_GRAY = Color("#444444")
const COL_SELECTION = Color("#c6e2ff")     # Azul clarito tipo Excel selección

# --- CONFIGURACIÓN ---
func _ready():
	window_title = "Tag Search"
	rect_min_size = Vector2(850, 550)
	resizable = true
	
	# 1. Aplicar estilo base a la ventana (Fondo Blanco)
	var style_window = StyleBoxFlat.new()
	style_window.bg_color = COL_BG_WHITE
	style_window.expand_margin_top = 25 # Truco para que la barra de título no quede apretada
	add_stylebox_override("panel", style_window)
	
	# 2. Construir UI
	_build_ui()
	
	# 3. Datos
	_populate_mock_data()
	
	popup_centered()

# --- CONSTRUCTOR DE UI ---
var tree_node 

func _build_ui():
	# > VBOX PRINCIPAL
	var main_vbox = VBoxContainer.new()
	main_vbox.set_anchors_preset(Control.PRESET_WIDE)
	# Márgenes internos para que no toque los bordes
	main_vbox.margin_left = 15
	main_vbox.margin_top = 15
	main_vbox.margin_right = -15
	main_vbox.margin_bottom = -15
	# Separación entre elementos
	main_vbox.add_constant_override("separation", 10)
	add_child(main_vbox)

	# ---------------------------------------------------------
	# 1. CABECERA (Estilo limpio)
	# ---------------------------------------------------------
	var header_hbox = HBoxContainer.new()
	main_vbox.add_child(header_hbox)
	
	var lbl_home = Label.new()
	lbl_home.text = "Home > SCL0EPPIH01"
	lbl_home.add_color_override("font_color", COL_TEXT_GRAY)
	header_hbox.add_child(lbl_home)
	
	# Barra de Búsqueda
	var search_bar = LineEdit.new()
	search_bar.text = "*MEL.CH*"
	search_bar.size_flags_horizontal = SIZE_EXPAND_FILL
	_apply_input_style(search_bar) # <--- Aplicamos estilo blanco
	header_hbox.add_child(search_bar)

	# ---------------------------------------------------------
	# 2. CUERPO (Split)
	# ---------------------------------------------------------
	var split_container = HSplitContainer.new()
	split_container.size_flags_vertical = SIZE_EXPAND_FILL
	main_vbox.add_child(split_container)
	
	# --- IZQUIERDA: FILTROS ---
	var filters_panel = PanelContainer.new()
	# Estilo del panel de filtros (Borde gris suave)
	var style_panel = StyleBoxFlat.new()
	style_panel.bg_color = COL_BG_WHITE
	style_panel.border_width_right = 1
	style_panel.border_color = COL_BORDER
	filters_panel.add_stylebox_override("panel", style_panel)
	filters_panel.rect_min_size.x = 240
	
	split_container.add_child(filters_panel)
	
	var filters_vbox = VBoxContainer.new()
	filters_panel.add_child(filters_vbox)
	
	# Título Filtros
	var lbl_filters = Label.new()
	lbl_filters.text = "Filters"
	lbl_filters.add_color_override("font_color", COL_TEXT_BLACK)
	filters_vbox.add_child(lbl_filters)
	
	# Añadir inputs
	_add_filter_input(filters_vbox, "Descriptor", "*")
	_add_filter_input(filters_vbox, "Point source", "*")
	_add_filter_input(filters_vbox, "Engineering units", "")
	_add_filter_input(filters_vbox, "Time stamp", "*")
	
	# --- DERECHA: RESULTADOS (TREE) ---
	tree_node = Tree.new()
	tree_node.columns = 2
	tree_node.set_column_title(0, "Data item")
	tree_node.set_column_title(1, "Description")
	tree_node.set_column_titles_visible(true)
	tree_node.hide_root = true
	tree_node.select_mode = Tree.SELECT_MULTI
	tree_node.set_column_min_width(0, 250)
	tree_node.set_column_expand(1, true)
	
	# ESTILIZAR EL TREE (IMPORTANTE)
	tree_node.add_color_override("font_color", COL_TEXT_BLACK)
	tree_node.add_color_override("title_button_color", COL_TEXT_BLACK) # Texto cabecera
	# Fondo blanco
	var style_tree_bg = StyleBoxFlat.new()
	style_tree_bg.bg_color = COL_BG_WHITE
	style_tree_bg.border_width_left = 1
	style_tree_bg.border_width_top = 1
	style_tree_bg.border_width_right = 1
	style_tree_bg.border_width_bottom = 1
	style_tree_bg.border_color = COL_BORDER
	tree_node.add_stylebox_override("bg", style_tree_bg)
	
	split_container.add_child(tree_node)

	# ---------------------------------------------------------
	# 3. FOOTER
	# ---------------------------------------------------------
	var footer_hbox = HBoxContainer.new()
	main_vbox.add_child(footer_hbox)
	
	var lbl_status = Label.new()
	lbl_status.text = "1000 items found"
	lbl_status.add_color_override("font_color", COL_TEXT_GRAY)
	footer_hbox.add_child(lbl_status)
	
	var spacer = Control.new()
	spacer.size_flags_horizontal = SIZE_EXPAND_FILL
	footer_hbox.add_child(spacer)
	
	# Botones estilo Windows
	var btn_ok = Button.new()
	btn_ok.text = "OK"
	btn_ok.rect_min_size = Vector2(90, 25)
	_apply_button_style(btn_ok) # <--- Estilo propio
	btn_ok.connect("pressed", self, "_on_ok_pressed")
	footer_hbox.add_child(btn_ok)

	var btn_cancel = Button.new()
	btn_cancel.text = "Cancel"
	btn_cancel.rect_min_size = Vector2(90, 25)
	_apply_button_style(btn_cancel) # <--- Estilo propio
	btn_cancel.connect("pressed", self, "hide")
	footer_hbox.add_child(btn_cancel)

# --- HELPERS DE ESTILO ---

func _apply_input_style(node):
	# Fondo blanco, borde gris, texto negro
	var style = StyleBoxFlat.new()
	style.bg_color = COL_BG_WHITE
	style.set_border_width_all(1)
	style.border_color = COL_BORDER
	style.content_margin_left = 5 # Padding texto
	
	node.add_stylebox_override("normal", style)
	node.add_stylebox_override("focus", style) # Mismo estilo al enfocar (o cambiar borde a azul)
	node.add_color_override("font_color", COL_TEXT_BLACK)
	node.add_color_override("cursor_color", COL_TEXT_BLACK)

func _apply_button_style(node):
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#e1e1e1") # Gris botón estándar
	style.set_border_width_all(1)
	style.border_color = Color("#adadad")
	
	node.add_stylebox_override("normal", style)
	node.add_color_override("font_color", COL_TEXT_BLACK)
	
	# Estilo hover (un poco más claro)
	var style_hover = style.duplicate()
	style_hover.bg_color = Color("#e5f1fb") # Azul muy clarito al pasar mouse
	style_hover.border_color = Color("#0078d7")
	node.add_stylebox_override("hover", style_hover)

func _add_filter_input(parent_node, title, default_val):
	# Contenedor del filtro
	var vbox = VBoxContainer.new()
	vbox.add_constant_override("separation", 2) # Pegar label al input
	parent_node.add_child(vbox)
	
	var label = Label.new()
	label.text = title
	label.add_color_override("font_color", COL_TEXT_GRAY)
	vbox.add_child(label)
	
	var input = LineEdit.new()
	input.text = default_val
	_apply_input_style(input) # Aplicar estilo blanco
	vbox.add_child(input)
	
	# Espaciador
	var spacer = Control.new()
	spacer.rect_min_size.y = 8
	parent_node.add_child(spacer)

# --- DATOS ---
func _populate_mock_data():
	tree_node.clear()
	var root = tree_node.create_item()
	
	for i in range(20):
		var item = tree_node.create_item(root)
		item.set_text(0, "MEL.CH.TAG.00" + str(i))
		item.set_text(1, "Descripcion del tag de prueba " + str(i))
		
		# Colores de texto NEGRO para que se vea en fondo BLANCO
		item.set_custom_color(0, COL_TEXT_BLACK)
		item.set_custom_color(1, COL_TEXT_GRAY)
