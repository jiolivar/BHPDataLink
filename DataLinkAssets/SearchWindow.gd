extends WindowDialog

# REFERENCIAS
onready var tree = $"%Tree"
onready var search_bar = $"%SearchBar" # <--- Asegúrate que tu LineEdit se llame así

# MEMORIA DE DATOS (Nuestra "Base de Datos" local)
var datos_completos = []

func _ready():
	# --- 1. CONFIGURACIÓN VISUAL DEL TREE ---
	tree.columns = 2
	tree.set_column_title(0, "Data Item")
	tree.set_column_title(1, "Description")
	tree.set_column_titles_visible(true)
	tree.hide_root = true
	tree.select_mode = Tree.SELECT_MULTI
	
	# Estilos de Cabecera (Tu código original)
	tree.add_color_override("title_button_color", Color.black)
	var estilo_header = StyleBoxFlat.new()
	estilo_header.bg_color = Color.white
	estilo_header.set_border_width_all(1)
	estilo_header.border_color = Color("#cccccc")
	tree.add_stylebox_override("title_button_normal", estilo_header)
	tree.add_stylebox_override("title_button_hover", estilo_header)
	tree.add_stylebox_override("title_button_pressed", estilo_header)
	
	# --- 2. LÓGICA DE BÚSQUEDA ---
	# Generamos los datos en memoria UNA sola vez
	generar_datos_memoria()
	
	# Conectamos la señal "text_changed" del LineEdit
	# Cada vez que escribas una letra, se llamará a "_on_search_text_changed"
	search_bar.connect("text_changed", self, "_on_search_text_changed")
	
	# Mostramos todo al inicio (filtro vacío)
	actualizar_tree("")
	
	popup_centered()

# --- PASO A: GENERAR DATOS EN MEMORIA ---
func generar_datos_memoria():
	datos_completos.clear()
	for i in range(50):
		# Guardamos los datos en diccionarios simples, NO en el Tree todavía
		var dato = {
			"tag": "\\\\SCL0EPPIH01\\MEL.CH.TAG.00" + str(i),
			"desc": "Escondida - Chancado - Alarma de Temperatura " + str(i)
		}
		datos_completos.append(dato)

# --- PASO B: ESCUCHAR EL TECLADO ---
func _on_search_text_changed(nuevo_texto):
	# 1. Limpieza estilo PI DataLink: Quitamos el asterisco "*"
	var texto_limpio = nuevo_texto.replace("*", "")
	
	# 2. Llamamos a actualizar la vista con el texto limpio
	actualizar_tree(texto_limpio)

# --- PASO C: FILTRAR Y DIBUJAR ---
func actualizar_tree(filtro):
	tree.clear() # Borramos lo visual (no los datos de memoria)
	var root = tree.create_item()
	
	# Recorremos nuestra memoria
	for dato in datos_completos:
		
		# LÓGICA DE FILTRADO
		# Si el filtro está vacío, pasa.
		# Si NO está vacío, buscamos si el Tag O la Descripción contienen el texto.
		# findn() busca sin importar mayúsculas/minúsculas. Retorna -1 si no encuentra.
		var coincide = false
		if filtro == "":
			coincide = true
		elif dato.tag.findn(filtro) != -1 or dato.desc.findn(filtro) != -1:
			coincide = true
			
		# Si coincide, LO DIBUJAMOS
		if coincide:
			var item = tree.create_item(root)
			
			# Usamos los datos del diccionario
			item.set_text(0, dato.tag)
			item.set_text(1, dato.desc)
			
			# Tu estilo original
			item.set_custom_color(0, Color.black)
			item.set_custom_color(1, Color("#444444"))
