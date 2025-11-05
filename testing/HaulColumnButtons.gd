# haul_column_buttons.gd
tool # Sigue siendo crucial para que funcione en el editor

extends Panel

# --- PROPIEDADES EXPORTADAS (Visible en el Inspector) ---

# 1. Propiedad para el texto del botón (Label)
export(String) var button_text: String setget set_button_text

# 2. Propiedad para el icono del botón (propiedad 'icon' del Button)
export(Texture) var button_icon: Texture setget set_button_icon

# --- Nodos Internos ---

# Obtenemos las referencias al Button y al Label (que es hijo del Button)
onready var button_node: Button = $Button
onready var label_node: Label = $Button/Label # El Label que mostrará el texto

# --- Métodos de Inicialización y Ejecución en Editor ---

func _ready():
	# Aseguramos que las propiedades exportadas se apliquen al iniciar
	set_button_text(button_text)
	set_button_icon(button_icon)

# --- Setters (Funciones que se llaman al cambiar la propiedad) ---

## Setter para 'button_text'
func set_button_text(new_text: String):
	button_text = new_text
	
	# Solo aplicamos si el nodo está listo y es válido (importante para el modo 'tool')
	if is_instance_valid(label_node):
		label_node.text = button_text

## Setter para 'button_icon'
func set_button_icon(new_icon: Texture):
	button_icon = new_icon
	
	# ¡Ajuste clave! Asignamos la textura a la propiedad 'icon' del nodo Button
	if is_instance_valid(button_node):
		button_node.icon = button_icon
		
# Puedes agregar aquí funciones de manejo de señales del botón, como _on_Button_pressed()
