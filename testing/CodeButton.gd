tool
extends Button

# Señal que envía los datos ya limpios
signal boton_presionado(codigo, titulo, texto_descripcion)

# Variables exportadas para el Inspector
export(String, MULTILINE) var texto_popup = "Texto por defecto."
export(String) var code_text setget set_code_text
export(String) var title_text setget set_title_text
export(Texture) var icon_texture setget set_icon_texture
export(bool) var invert_colors setget set_invert_colors

# Referencias a nodos
onready var code_label = $VBoxContainer2/Code
onready var title_label = $VBoxContainer2/Title
onready var icon_rect = $VBoxContainer/TextureRect
onready var icono_check = $TextureButton

# Colores
var base_button_color = Color("#e65400")
var base_text_color   = Color("#f8b633")

func _ready():
	if not Engine.editor_hint and is_instance_valid(icono_check):
		icono_check.visible = false
	self.code_text = code_text
	self.title_text = title_text
	self.icon_texture = icon_texture
	self.invert_colors = invert_colors

# ESTA ES LA FUNCIÓN CLAVE
func _pressed():
	# 1. Limpiamos el TÍTULO
	var texto_base_titulo = title_text.replace("\u00A0", " ").replace("\t", " ").replace("\n", " ")
	var palabras_titulo = texto_base_titulo.strip_edges().split(" ", true)
	var titulo_limpio = " ".join(palabras_titulo)

	# 2. Limpiamos el CÓDIGO
	var texto_base_codigo = code_text.replace("\u00A0", " ").replace("\t", " ").replace("\n", " ")
	var palabras_codigo = texto_base_codigo.strip_edges().split(" ", true)
	var codigo_limpio = " ".join(palabras_codigo)
	
	# 3. NO limpiamos la descripción. Usamos la variable original.
	var descripcion_original = texto_popup
	
	# 4. Emitimos la señal con los datos correspondientes
	emit_signal("boton_presionado", codigo_limpio, titulo_limpio, descripcion_original)

func mostrar_check():
	if is_instance_valid(icono_check):
		icono_check.visible = true

# Setters para que el editor se actualice visualmente
func set_code_text(value):
	code_text = value
	var label = get_node_or_null("VBoxContainer2/Code")
	if is_instance_valid(label):
		label.text = value

func set_title_text(value):
	title_text = value
	var label = get_node_or_null("VBoxContainer2/Title")
	if is_instance_valid(label):
		label.text = value

func set_icon_texture(value):
	icon_texture = value
	var rect = get_node_or_null("VBoxContainer/TextureRect")
	if is_instance_valid(rect):
		rect.texture = value

func set_invert_colors(value):
	invert_colors = value
	if is_inside_tree():
		_apply_colors()

func _apply_colors():
	if not is_inside_tree():
		return
	var style_title = get_node_or_null("VBoxContainer2/Title")
	var normal = StyleBoxFlat.new()
	var hover = StyleBoxFlat.new()
	var pressed = StyleBoxFlat.new()
	var disabled = StyleBoxFlat.new()
	if invert_colors:
		normal.bg_color = base_text_color
		hover.bg_color = base_text_color.darkened(0.1)
		pressed.bg_color = base_text_color.lightened(0.1)
		disabled.bg_color = base_text_color.darkened(0.3)
		if is_instance_valid(style_title):
			style_title.add_color_override("font_color", base_button_color)
	else:
		normal.bg_color = base_button_color
		hover.bg_color = base_button_color.darkened(0.1)
		pressed.bg_color = base_button_color.lightened(0.1)
		disabled.bg_color = base_button_color.darkened(0.3)
		if is_instance_valid(style_title):
			style_title.add_color_override("font_color", base_text_color)
	add_stylebox_override("normal", normal)
	add_stylebox_override("hover", hover)
	add_stylebox_override("pressed", pressed)
	add_stylebox_override("disabled", disabled)
