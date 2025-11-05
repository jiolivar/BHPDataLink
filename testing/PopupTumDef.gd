# PopupUniversal.gd
extends Panel

signal popup_cerrado

# Solo declaramos con 'onready' los nodos que SIEMPRE existen.
onready var description_label = $"%LabelDescripcion"
onready var boton_cerrar = $"%BotonCerrar"

# NO usamos onready var para el título, porque es opcional.

func _ready():
	boton_cerrar.connect("pressed", self, "_on_BotonCerrar_pressed")
	hide()

# --- FUNCIÓN 1: La Completa ---
func mostrar_info(titulo, descripcion):
	# Intentamos encontrar el nodo del título.
	var title_label = get_node_or_null("Panel/Title")
	
	# Solo si lo encontramos...
	if is_instance_valid(title_label):
		# ...lo hacemos visible y le ponemos el texto.
		title_label.visible = true
		title_label.text = titulo # O title_label.set_clean_text(titulo) si usas ese script
	
	description_label.text = descripcion
	show()

# --- FUNCIÓN 2: La Simple ---
func mostrar_descripcion(descripcion):
	# Intentamos encontrar el nodo del título.
	var title_label = get_node_or_null("Panel/Title")
	
	# Solo si lo encontramos...
	if is_instance_valid(title_label):
		# ...lo ocultamos.
		title_label.visible = false
	
	description_label.text = descripcion
	show()

func _on_BotonCerrar_pressed():
	hide()
	emit_signal("popup_cerrado")
