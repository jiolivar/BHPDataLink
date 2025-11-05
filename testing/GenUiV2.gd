extends Control

# ----------------------------
# Helpers
# ----------------------------
func _make_field(label_text: String, value_text: String, bg_color: Color = Color(0,0,0,0)) -> VBoxContainer:
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var lbl = Label.new()
	lbl.text = label_text
	lbl.add_color_override("font_color", Color(0,0,0))
	vbox.add_child(lbl)

	var input = LineEdit.new()
	input.text = value_text
	input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	input.add_color_override("font_color", Color(0,0,0))

	var style = StyleBoxFlat.new()
	if bg_color.a > 0.0:
		style.bg_color = bg_color
	else:
		style.bg_color = Color(1,1,1,1)
	style.border_color = Color(0,0,0,1)
	# usar propiedades en vez de style.set(...) para evitar errores
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	input.set("custom_styles/normal", style)

	vbox.add_child(input)
	return vbox


func _make_option_field(label_text: String, items: Array, placeholder: String = "") -> VBoxContainer:
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var lbl = Label.new()
	lbl.text = label_text
	lbl.add_color_override("font_color", Color(0,0,0))
	vbox.add_child(lbl)

	var ob = OptionButton.new()
	ob.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if placeholder != "":
		ob.add_item(placeholder)
	for it in items:
		ob.add_item(it)
	vbox.add_child(ob)
	return vbox


# slot vacío (tercer espacio vacío)
func _empty_slot() -> VBoxContainer:
	var v = VBoxContainer.new()
	# este slot reserva espacio pero no muestra nada
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_child(spacer)
	return v


func _add_title(parent: Node, text: String) -> void:
	var l = Label.new()
	l.text = text
	l.add_color_override("font_color", Color(0,0,0))
	parent.add_child(l)


func _add_separator(parent: Node) -> void:
	parent.add_child(HSeparator.new())


# ----------------------------
# Parámetros de anchura (ajusta según tu UI)
# ----------------------------
const COL_MIN = 180        # ancho "normal" para 1 columna
const COL_DOUBLE_MIN = COL_MIN * 2  # ancho "doble" para 2 columnas visuales


# ----------------------------
# ready: construye UI con 3 slots por fila
# ----------------------------
func _ready() -> void:
	# Theme base
	var theme = Theme.new()
	var sb_white = StyleBoxFlat.new()
	sb_white.bg_color = Color(1,1,1,1)
	sb_white.border_width_top = 1
	sb_white.border_width_bottom = 1
	sb_white.border_color = Color(0.9,0.9,0.9,1)

	theme.set_stylebox("panel", "Panel", sb_white)
	theme.set_stylebox("normal", "LineEdit", sb_white)
	theme.set_stylebox("normal", "OptionButton", sb_white)
	theme.set_stylebox("panel", "PopupMenu", sb_white)

	theme.set_color("font_color", "Label", Color(0,0,0))
	theme.set_color("font_color", "LineEdit", Color(0,0,0))
	theme.set_color("font_color", "OptionButton", Color(0,0,0))
	theme.set_color("font_color", "PopupMenu", Color(0,0,0))
	self.theme = theme

	# Panel raíz
	var panel := Panel.new()
	panel.anchor_left = 0
	panel.anchor_top = 0
	panel.anchor_right = 1
	panel.anchor_bottom = 1
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.anchor_left = 0
	vbox.anchor_top = 0
	vbox.anchor_right = 1
	vbox.anchor_bottom = 1
	vbox.margin_left = 12
	vbox.margin_top = 12
	vbox.margin_right = 12
	vbox.margin_bottom = 12
	panel.add_child(vbox)

	# ====== GENERAL ======
	_add_title(vbox, "General")

	# fila 1 (3 campos)
	var fila1 = HBoxContainer.new()
	fila1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# slot 1
	var s1 = _make_field("Unidad:", "CEX05")
	s1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s1.rect_min_size.x = COL_MIN
	fila1.add_child(s1)
	# slot 2
	var s2 = _make_field("Ubicación:", "SRDC_NORTE")
	s2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s2.rect_min_size.x = COL_MIN
	fila1.add_child(s2)
	# slot 3
	var s3 = _make_field("Destino:", "CGD05")
	s3.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s3.rect_min_size.x = COL_MIN
	fila1.add_child(s3)
	vbox.add_child(fila1)

# fila 2 (Estado y razón ocupa 2 columnas; Demora ocupa 1)
	var fila2 = HBoxContainer.new()
	fila2.size_flags_horizontal = Control.SIZE_EXPAND_FILL

# Estado y razón (peso 2)
	var slot_estado = _make_field("Estado y razón (15-JUL-25 08:52:35):", "2010", Color(0.75,1,0.75,1))
	slot_estado.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slot_estado.size_flags_stretch_ratio = 2
	fila2.add_child(slot_estado)

# Demora de asignación (peso 1)
	var slot_demora = _make_field("Demora de asignación:", "NINGUNA")
	slot_demora.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slot_demora.size_flags_stretch_ratio = 1
	fila2.add_child(slot_demora)

	vbox.add_child(fila2)


	# fila 3 (2 campos y 1 slot vacío)
	var fila3 = HBoxContainer.new()
	fila3.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var s31 = _make_field("Cargas:", "2")
	s31.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s31.rect_min_size.x = COL_MIN
	fila3.add_child(s31)
	var s32 = _make_field("Combustible restante:", "2.330")
	s32.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s32.rect_min_size.x = COL_MIN
	fila3.add_child(s32)
	# tercer slot vacío
	fila3.add_child(_empty_slot())
	vbox.add_child(fila3)

	_add_separator(vbox)

	# ====== MATERIALES ======
	_add_title(vbox, "Materiales")
	var fila_mat = HBoxContainer.new()
	fila_mat.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var mat1 = _make_field("Material:", "Vacío")
	mat1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mat1.rect_min_size.x = COL_MIN
	fila_mat.add_child(mat1)
	var mat2 = _make_field("Ley:", "NONE")
	mat2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mat2.rect_min_size.x = COL_MIN
	fila_mat.add_child(mat2)
	var mat3 = _make_field("Carga:", "0")
	mat3.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mat3.rect_min_size.x = COL_MIN
	fila_mat.add_child(mat3)
	vbox.add_child(fila_mat)

	# (resto de secciones igual, siempre añadiendo 3 slots por fila)
	_add_separator(vbox)
	_add_title(vbox, "Operador actual")
	var fila_op = HBoxContainer.new()
	fila_op.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila_op.add_child(_make_field("Operador:", "AGUILANTE C. ALBA - 2102"))
	fila_op.add_child(_make_field("Nivel de calificación:", "Calificado"))
	fila_op.add_child(_make_field("Equipo de trabajo:", "2"))
	vbox.add_child(fila_op)

	_add_separator(vbox)
	_add_title(vbox, "Acciones")
	var fila_acc1 = HBoxContainer.new()
	fila_acc1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila_acc1.add_child(_make_field("Última:", "Asignar"))
	fila_acc1.add_child(_make_field("Siguiente (en 3,1 minutos):", "Llegada"))
	# tercer slot (opción)
	fila_acc1.add_child(_make_option_field("Anulación de ciclo:", ["Acción A", "Acción B", "Acción C"], "Seleccionar acción a ejecutar"))
	vbox.add_child(fila_acc1)

	_add_separator(vbox)
	_add_title(vbox, "Etiquetas")
	var fila_tags = HBoxContainer.new()
	fila_tags.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var tag = LineEdit.new()
	tag.placeholder_text = "Ingrese la etiqueta aquí"
	tag.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila_tags.add_child(tag)
	# aseguramos 3 slots: si quieres el tag centrado, añade dos empty slots alrededor
	fila_tags.add_child(_empty_slot())
	fila_tags.add_child(_empty_slot())
	vbox.add_child(fila_tags)
