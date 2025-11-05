extends Control



# Helper: crea un campo Label + LineEdit
func _add_field(container: GridContainer, label_text: String, value_text: String, bg_color: Color = Color(0,0,0,0)):
	var lbl = Label.new()
	lbl.text = label_text
	# el theme global pone el color de fuente, aquí solo lo aseguramos
	lbl.add_color_override("font_color", Color(0,0,0))
	container.add_child(lbl)

	var input = LineEdit.new()
	input.text = value_text
	input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	input.add_color_override("font_color", Color(0,0,0))

	# Si nos piden un color especial (verde por ejemplo), lo aplicamos
	var style := StyleBoxFlat.new()
	if bg_color.a > 0.0:
		style.bg_color = bg_color
	else:
		style.bg_color = Color(1,1,1,1) # blanco por defecto
		# Fondo + borde para que parezca “casilla”
	style.border_color = Color(0,0,0,1)
	style.set("border_width_left", 1)
	style.set("border_width_top", 1)
	style.set("border_width_right", 1)
	style.set("border_width_bottom", 1)
	
	input.set("custom_styles/normal", style)

	container.add_child(input)
	return input


func _add_option_field(container: GridContainer, label_text: String, items: Array, placeholder: String = ""):
	var lbl = Label.new()
	lbl.text = label_text
	lbl.add_color_override("font_color", Color(0,0,0))
	container.add_child(lbl)

	var ob = OptionButton.new()
	ob.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if placeholder != "":
		ob.add_item(placeholder)
	for it in items:
		ob.add_item(it)
	container.add_child(ob)
	return ob


func _add_title(parent: Node, text: String) -> void:
	var l = Label.new()
	l.text = text
	l.add_color_override("font_color", Color(0,0,0))
	parent.add_child(l)


func _add_separator(parent: Node) -> void:
	parent.add_child(HSeparator.new())


func _ready() -> void:
	# ----------------------------
	# 1) Theme local: blanca + texto negro para controles claves
	# ----------------------------
	var theme = Theme.new()
	var sb_white = StyleBoxFlat.new()
	sb_white.bg_color = Color(1,1,1,1)
	# opcional: borde suave para separar campos
	sb_white.border_width_top = 1
	sb_white.border_width_bottom = 1
	sb_white.border_color = Color(0.9,0.9,0.9,1)

	# Aplicar stylebox blanco a Panel, LineEdit, OptionButton y PopupMenu
	theme.set_stylebox("panel", "Panel", sb_white)
	theme.set_stylebox("normal", "LineEdit", sb_white)
	theme.set_stylebox("normal", "OptionButton", sb_white)
	theme.set_stylebox("panel", "PopupMenu", sb_white)
	theme.set_stylebox("panel", "PopupMenu", sb_white) # por si acaso

	# Forzar color de fuente negro
	theme.set_color("font_color", "Label", Color(0,0,0))
	theme.set_color("font_color", "LineEdit", Color(0,0,0))
	theme.set_color("font_color", "OptionButton", Color(0,0,0))
	theme.set_color("font_color", "PopupMenu", Color(0,0,0))

	# Asignar theme al Control raíz (se propaga a hijos)
	self.theme = theme

	# ----------------------------
	# 2) Panel que cubre TODO el viewport (evita bandas grises)
	# ----------------------------
	var panel := Panel.new()
	# anclarlo a todo el rect para que NO deje franjas
	panel.anchor_left = 0
	panel.anchor_top = 0
	panel.anchor_right = 1
	panel.anchor_bottom = 1
	panel.margin_left = 0
	panel.margin_top = 0
	panel.margin_right = 0
	panel.margin_bottom = 0
	add_child(panel)

	# ----------------------------
	# 3) Contenedor principal con márgenes interiores
	# ----------------------------
	var vbox := VBoxContainer.new()
	# anclar también para que ocupe el interior del panel
	vbox.anchor_left = 0
	vbox.anchor_top = 0
	vbox.anchor_right = 1
	vbox.anchor_bottom = 1
	# márgenes internos (ajusta a gusto)
	vbox.margin_left = 12
	vbox.margin_top = 12
	vbox.margin_right = -12
	vbox.margin_bottom = -12
	panel.add_child(vbox)

	# ====== GENERAL ======
	_add_title(vbox, "General")
	var grid_general := GridContainer.new()
	grid_general.columns = 4
	grid_general.rect_min_size = Vector2(900, 0)
	vbox.add_child(grid_general)

	_add_field(grid_general, "Unidad:", "CEX05")
	_add_field(grid_general, "Ubicación:", "SRDC_NORTE")
	_add_field(grid_general, "Destino:", "CGD05")
	_add_field(grid_general, "Estado y razón (15-JUL-25 08:52:35):", "2010", Color(0.75,1,0.75,1.0)) # verde
	_add_field(grid_general, "Demora de asignación:", "NINGUNA")
	_add_field(grid_general, "Cargas:", "2")
	_add_field(grid_general, "Combustible restante:", "2.330")

	_add_separator(vbox)

	# ====== MATERIALES ======
	_add_title(vbox, "Materiales")
	var grid_mat := GridContainer.new()
	grid_mat.columns = 4
	vbox.add_child(grid_mat)

	_add_field(grid_mat, "Material:", "Vacío")
	_add_field(grid_mat, "Ley:", "NONE")
	_add_field(grid_mat, "Carga:", "0")

	_add_separator(vbox)

	# ====== OPERADOR ACTUAL ======
	_add_title(vbox, "Operador actual")
	var grid_op := GridContainer.new()
	grid_op.columns = 6
	vbox.add_child(grid_op)

	_add_field(grid_op, "Operador:", "AGUILANTE C. ALBA - 2102")
	_add_field(grid_op, "Nivel de calificación:", "Calificado")
	_add_field(grid_op, "Equipo de trabajo:", "2")

	_add_separator(vbox)

	# ====== ACCIONES ======
	_add_title(vbox, "Acciones")
	var grid_acc := GridContainer.new()
	grid_acc.columns = 6
	vbox.add_child(grid_acc)

	_add_field(grid_acc, "Última:", "Asignar")
	_add_field(grid_acc, "Siguiente (en 3,1 minutos):", "Llegada")
	_add_option_field(grid_acc, "Anulación de ciclo:", ["Acción A", "Acción B", "Acción C"], "Seleccionar acción a ejecutar")

	_add_separator(vbox)

	# ====== ETIQUETAS ======
	_add_title(vbox, "Etiquetas")
	var tag := LineEdit.new()
	tag.placeholder_text = "Ingrese la etiqueta aquí"
	tag.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(tag)
