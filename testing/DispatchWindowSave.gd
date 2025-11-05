extends PopupPanel

func _ready():
	# usando rutas relativas desde este nodo raíz (PopupPanel)
	var ob = $"%OptionButton"
	ob.clear()
	ob.add_item("CEX05")
	ob.add_item("CEX06")
	ob.add_item("CEX07")

	var ob2 = $"%OptionButton2"
	ob2.clear()
	ob2.add_item("SRDC_NORTE")
	ob2.add_item("SRDC_SUR")
	ob2.add_item("SRDC_CENTRO")

	var ob3 = $VBoxContainer/HBoxContainer/VBoxContainer3/OptionButton
	ob3.clear()
	ob3.add_item("CGD05")
	ob3.add_item("CGD06")
	ob3.add_item("CGD07")

	var ob4 = $VBoxContainer/HBoxContainer2/VBoxContainer/OptionButton
	ob4.clear()
	ob4.add_item("2010")
	ob4.add_item("2100")
	ob4.add_item("3000")

	var ob5 = $VBoxContainer/HBoxContainer4/VBoxContainer/OptionButton
	ob5.clear()
	ob5.add_item("Vacio")
	ob5.add_item("Medio")
	ob5.add_item("Lleno")

	var ob6 = $VBoxContainer/HBoxContainer4/VBoxContainer2/OptionButton
	ob6.clear()
	ob6.add_item("NONE")
	ob6.add_item("YES")
	ob6.add_item("IDontKnow")

	var ob7 = $VBoxContainer/HBoxContainer5/VBoxContainer/OptionButton
	ob7.clear()
	ob7.add_item("AGUILANTE C.ALBA - 2102")
	ob7.add_item("RICARDO D.DIAZ -2103")
	ob7.add_item("JOHN DOE - 1946")

	var ob8 = $VBoxContainer/HBoxContainer6/VBoxContainer2/OptionButton
	ob8.clear()
	ob8.add_item("Llegada")
	ob8.add_item("Salida")

	var ob9 = $VBoxContainer/HBoxContainer6/VBoxContainer3/OptionButton
	ob9.clear()
	ob9.add_item("Seleccionar acción a ejecutar")
	ob9.set_item_disabled(0, true)
	ob9.add_item("Opcion A")
	ob9.add_item("Opcion B")
	ob9.add_item("Opcion C")
