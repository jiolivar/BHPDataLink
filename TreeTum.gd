extends ScrollContainer

onready var root_box = $VBoxContainer
var TumDefExplain = preload("res://testing/TumDefExplain.tscn")

func _ready():
	# Nodo raíz
	var root = TumDefExplain.instance()
	root.text = "Calendar Time"
	root.color = Color(1, 0.4, 0) # naranja
	root_box.add_child(root)

	# Hijos del root
	var required = TumDefExplain.instance()
	required.text = "Required Time"
	root.get_node("VBoxContainer").add_child(required)

	var standby = TumDefExplain.instance()
	standby.text = "Standby Time"
	root.get_node("VBoxContainer").add_child(standby)

	# Hijos de "Required Time"
	var available = TumDefExplain.instance()
	available.text = "Available Time"
	required.get_node("VBoxContainer").add_child(available)

	var downtime = TumDefExplain.instance()
	downtime.text = "Downtime"
	required.get_node("VBoxContainer").add_child(downtime)

	# Hijos de "Available Time"
	var production = TumDefExplain.instance()
	production.text = "Production Time"
	available.get_node("VBoxContainer").add_child(production)

	var idle = TumDefExplain.instance()
	idle.text = "Idle Time"
	available.get_node("VBoxContainer").add_child(idle)
