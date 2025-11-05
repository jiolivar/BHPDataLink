extends Node


var zoom_in := load("res://game/assets/ui/icons/zoomIn.png")
var zoom_out := load("res://game/assets/ui/icons/zoomOut.png")
var zoomed_in := false
var click_locked := false
var last_camera_click = null


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
