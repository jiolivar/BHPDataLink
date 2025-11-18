extends Button

# Sintaxis de Godot 3.5.3 para nodos "onready"
onready var line_edit = $LineEdit
var cell_data = {} # Los datos que esta celda mostrará

func _ready():
	# 1. Ocultar el LineEdit al inicio
	line_edit.visible = false
	
	# 2. Conectar las señales INTERNAS de esta celda
	# (Sintaxis de conexión de Godot 3)
	line_edit.connect("text_submitted", self, "_on_text_submitted")
	line_edit.connect("focus_exited", self, "_on_focus_lost")
	
	# NOTA: NO conectamos la señal "pressed" aquí.
	# El "ExcelSheet" se encargará de escucharla.

# El ExcelSheet usará esta función para "pintar" la celda
func set_data(data):
	cell_data = data
	self.text = str(data.value)
	line_edit.text = str(data.value)

# Esta función la llamará el ExcelSheet cuando hagamos doble clic
func start_editing():
	self.text = "" # Oculta el texto del botón
	line_edit.visible = true
	line_edit.grab_focus()
	line_edit.select_all()

# El usuario presionó Enter
func _on_text_submitted(new_text):
	# Actualiza el dato en memoria
	cell_data.value = new_text
	
	# Actualiza la vista del botón
	self.text = new_text
	
	# Vuelve al modo "vista"
	line_edit.visible = false
	self.grab_focus() # Devuelve el foco al botón

# El usuario hizo clic fuera del LineEdit
func _on_focus_lost():
	# Hacemos lo mismo que si hubiera presionado Enter
	_on_text_submitted(line_edit.text)
