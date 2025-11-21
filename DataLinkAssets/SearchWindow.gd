extends WindowDialog

# IMPORTANTE: Ajusta esta ruta según cómo nombraste tus nodos en el Editor
onready var tree = $"%Tree"

func _ready():
	# 1. Configuración de columnas
	tree.columns = 2
	tree.set_column_title(0, "Data Item")
	tree.set_column_title(1, "Description")
	tree.set_column_titles_visible(true)
	tree.hide_root = true
	tree.select_mode = Tree.SELECT_MULTI
	
	# --- NUEVO: ESTILO DE CABECERA (Header) ---
	# A. Texto Negro en los títulos
	tree.add_color_override("title_button_color", Color.black)
	
	# B. Fondo Blanco en los títulos
	var estilo_header = StyleBoxFlat.new()
	estilo_header.bg_color = Color.white
	estilo_header.set_border_width_all(1)      # Borde fino
	estilo_header.border_color = Color("#cccccc") # Borde gris suave
	
	# Aplicamos este estilo blanco a los botones de cabecera (normal, hover y presionado)
	tree.add_stylebox_override("title_button_normal", estilo_header)
	tree.add_stylebox_override("title_button_hover", estilo_header)
	tree.add_stylebox_override("title_button_pressed", estilo_header)
	# -------------------------------------------

	popup_centered()
	llenar_datos_de_prueba()

func llenar_datos_de_prueba():
	tree.clear()
	
	var root = tree.create_item()
	
	for i in range(50):
		var item = tree.create_item(root)
		
		# --- COLUMNA 0 (Tag) ---
		var tag_name = "\\\\SCL0EPPIH01\\MEL.CH.TAG.00" + str(i)
		item.set_text(0, tag_name)
		
		# --- COLUMNA 1 (Descripción) ---
		var desc = "Escondida - Chancado - Alarma de Temperatura " + str(i)
		item.set_text(1, desc)
		
		# --- ESTILO DE FILAS ---
		item.set_custom_color(0, Color.black)
		item.set_custom_color(1, Color("#444444"))
