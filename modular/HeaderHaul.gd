extends ColorRect

# Declara una señal personalizada. La llamaremos 'abrir_ventana_dispatch'
signal open_dispatch_window_requested(machine_type)

func _ready():
	# 1. Obtén referencias a los botones (usando las rutas relativas que proporcionaste)
	var button_caex = $"%ButtonCaex"
	var button_pal = $"%ButtonPal"
	var button_bull = $"%ButtonBull"
	
	# Conectar cada botón a su propia función para pasar el tipo específico.
	button_caex.connect("pressed", self, "_on_caex_button_pressed")
	button_pal.connect("pressed", self, "_on_pal_button_pressed")
	button_bull.connect("pressed", self, "_on_bull_button_pressed")

# Handler específico para CAEX
func _on_caex_button_pressed():
	# Emite la señal con el tipo "CAEX"
	emit_signal("open_dispatch_window_requested", "CAEX")

# Handler específico para PAL
func _on_pal_button_pressed():
	# Emite la señal con el tipo "PAL"
	emit_signal("open_dispatch_window_requested", "PAL")

# Handler específico para BULL
func _on_bull_button_pressed():
	# Emite la señal con el tipo "BULL"
	emit_signal("open_dispatch_window_requested", "BULL")
