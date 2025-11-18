extends Control # O el nodo que tengas de raíz

# --- 1. Definiciones ---
onready var grid = $Grid # Asegúrate que tu GridContainer se llame "Grid"

# Pre-cargamos las escenas que instanciareremos
var cell_scene = preload("res://DataLinkAssets/Cell.tscn")
var header_scene = preload("res://DataLinkAssets/HeaderCell.tscn")

# Definimos el tamaño de nuestra *plantilla de datos*
const DATA_ROWS = 10
const DATA_COLS = 5

# El modelo de datos (como vimos en la Parte 1)
var sheet_data = []

# Guardamos la celda seleccionada
var selected_cell = null
var selected_coords = Vector2(-1, -1)

# --- 2. Inicialización ---
func _ready():
	# A. Ajustamos el GridContainer
	# Columnas totales = 5 de datos + 1 de índices de fila
	grid.columns = DATA_COLS + 1
	
	# B. Inicializamos la matriz de datos (vacía)
	# (Esto es para los datos, no para la UI)
	for r in DATA_ROWS:
		var row_data = []
		for c in DATA_COLS:
			row_data.append( {"value": "", "formula": ""} )
		sheet_data.append(row_data)
		
	# C. Llamamos a la función que "dibuja" el grid
	draw_grid()

# --- 3. El Armador de la UI ---
func draw_grid():
	
	# Filas totales = 10 de datos + 1 de índices de columna
	for r in DATA_ROWS + 1:
		
		# Columnas totales = 5 de datos + 1 de índices de fila
		for c in DATA_COLS + 1:
			
			# --- Lógica de qué celda poner ---
			
			# Caso 1: Esquina superior izquierda (0,0)
			if r == 0 and c == 0:
				var corner = Control.new()
				corner.rect_min_size = Vector2(100, 25) # Mismo tamaño
				grid.add_child(corner)
			
			# Caso 2: Fila de Headers (A, B, C...)
			elif r == 0:
				var header = header_scene.instance()
				# chr(65) es "A". chr(65 + 1) es "B"...
				header.set_text( char(64 + c) ) 
				grid.add_child(header)
				
			# Caso 3: Columna de Headers (1, 2, 3...)
			elif c == 0:
				var header = header_scene.instance()
				header.set_text( str(r) )
				grid.add_child(header)
				
			# Caso 4: ¡Una celda de datos!
			else:
				var cell = cell_scene.instance()
				
				# Le pasamos el diccionario de datos (ahora están vacíos)
				# Ojo: r y c vienen de la UI (empiezan en 1),
				# pero 'sheet_data' empieza en 0.
				cell.set_data( sheet_data[r-1][c-1] )
				
				# CONECTAMOS LA SEÑAL "pressed" (Sintaxis Godot 3)
				# Cuando se presione esta celda, llamará a NUESTRA función
				# Le "pasamos" la celda y sus coordenadas de *datos* (r-1, c-1)
				cell.connect("pressed", self, "_on_cell_selected", [cell, Vector2(c-1, r-1)])
				
				grid.add_child(cell)

# --- 4. Lógica de Selección y Edición ---

# Esta es la función que conectamos arriba
func _on_cell_selected(cell_node, coords):
	# Guardamos la celda y sus coordenadas
	selected_cell = cell_node
	selected_coords = coords
	print("Celda seleccionada: ", coords)
	
	# Le damos foco para que se vea el borde azul
	cell_node.grab_focus()

# Esta función se llama en CADA frame (para inputs)
func _unhandled_input(event):
	# Si tenemos una celda seleccionada Y
	# el usuario presiona Enter (o F2, o Doble Clic...)
	
	# Chequeamos Doble Clic
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.doubleclick:
			if selected_cell:
				# ¡Le damos la orden de editar al obrero!
				selected_cell.start_editing()
				
	# Chequeamos Teclado (F2 es clásico de Excel)
	if event.is_action_pressed("ui_accept"): # (Enter)
		if selected_cell:
			selected_cell.start_editing()
