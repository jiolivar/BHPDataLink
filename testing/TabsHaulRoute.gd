extends TabContainer

# Se llama cuando el nodo y todos sus hijos ya están en el árbol de la escena.
func _ready():
	# EJEMPLO 1: Seleccionar la PRIMERA pestaña (índice 0)
	# self.current_tab = 0 
	
	# EJEMPLO 2: Seleccionar la SEGUNDA pestaña (índice 1)
	self.current_tab = 1
	
	# El 'self' hace referencia al nodo TabContainer al que está adjunto este script.
