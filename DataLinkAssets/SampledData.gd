extends Panel

# --- REFERENCIAS A NODOS ---
# IMPORTANTE: Cambia estas rutas para que coincidan con tu árbol de escenas.
# Si usaste "Access as Unique Name" en el editor, puedes usar %ButtonClose
onready var close_btn = $"%ButtonClose"


func _ready():
	# 1. Conectar el botón de Cerrar
	# Esto hace que al pulsarlo, se ejecute la función _on_close_pressed
	if close_btn:
		close_btn.connect("pressed", self, "_on_close_pressed")
	else:
		print("ERROR: No encontré el ButtonClose. Revisa la ruta en el script.")


# --- LÓGICA DE CERRAR ---
func _on_close_pressed():
	# Oculta el panel (lo hace invisible pero no borra los datos escritos)
	hide() 
	
	# OPCIONAL: Si prefieres destruir la ventana para ahorrar memoria, usa:
	# queue_free()
