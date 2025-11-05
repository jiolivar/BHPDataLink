extends Button

export(String, MULTILINE) var button_text = "text"

export var is_back := false

func _ready():
	
	$"%Label".text = button_text
	
	if is_back:
		$"%Polygon2D1".hide()
		$"%Polygon2D2".show()
	else:
		$"%Polygon2D2".hide()
		$"%Polygon2D1".show()
	pass 
