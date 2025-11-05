# CleanLabel.gd
extends Label

# Esta función tomará un texto "sucio", lo limpiará y lo asignará a este mismo Label.
func set_clean_text(texto_original):
	# Nos aseguramos de que el texto no sea nulo para evitar errores.
	if texto_original == null:
		texto_original = ""

	# 1. Reemplazamos todos los caracteres de espacio raros (NBSP, tabs, saltos de línea).
	var texto_pre_limpieza = texto_original.replace("\u00A0", " ").replace("\t", " ").replace("\n", " ")

	# 2. Limpiamos los espacios de los bordes.
	var texto_limpio = texto_pre_limpieza.strip_edges()

	# 3. Dividimos el texto en palabras y las volvemos a unir con un solo espacio.
	var palabras = texto_limpio.split(" ", true)
	var texto_final = " ".join(palabras)

	# 4. Asignamos el resultado limpio a la propiedad 'text' de este nodo Label.
	self.text = texto_final
