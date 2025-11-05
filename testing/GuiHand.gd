extends Control




# Called when the node enters the scene tree for the first time.
func _ready():
	var ob = $"%OptionButton"
	ob.add_item("CEX05")
	ob.add_item("CEX06")
	ob.add_item("CEX07")
	var ob2 = $"%OptionButton2"
	ob2.add_item("SRDC_NORTE")
	ob2.add_item("SRDC_SUR")
	ob2.add_item("SRDC_CENTRO")
	var ob3 = $Panel/VBoxContainer/HBoxContainer/VBoxContainer3/OptionButton
	ob3.add_item("CGD05")
	ob3.add_item("CGD06")
	ob3.add_item("CGD07")
	var ob4 = $Panel/VBoxContainer/HBoxContainer2/VBoxContainer/OptionButton
	ob4.add_item("2010")
	ob4.add_item("2100")
	ob4.add_item("3000")
	var ob5 = $Panel/VBoxContainer/HBoxContainer4/VBoxContainer/OptionButton
	ob5.add_item("Vacio")
	ob5.add_item("Medio")
	ob5.add_item("Lleno")
	var ob6 = $Panel/VBoxContainer/HBoxContainer4/VBoxContainer2/OptionButton
	ob6.add_item("NONE")
	ob6.add_item("YES")
	ob6.add_item("IDontKnow")
	var ob7 = $Panel/VBoxContainer/HBoxContainer5/VBoxContainer/OptionButton
	ob7.add_item("AGUILANTE C.ALBA - 2102")
	ob7.add_item("RICARDO D.DIAZ -2103")
	ob7.add_item("JOHN DOE - 1946")
	var ob8 = $Panel/VBoxContainer/HBoxContainer6/VBoxContainer2/OptionButton
	ob8.add_item("Llegada")
	ob8.add_item("Salida")
	var ob9 = $Panel/VBoxContainer/HBoxContainer6/VBoxContainer3/OptionButton
	ob9.add_item("Seleccionar acción a ejecutar")   # índice 0
	ob9.set_item_disabled(0, true) # lo bloqueamos
	ob9.add_item("Opcion A")
	ob9.add_item("Opcion B")
	ob9.add_item("Opcion C")

	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
