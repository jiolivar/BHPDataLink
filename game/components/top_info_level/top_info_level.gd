tool

extends Control

export (String) var description : String setget set_description
export (int) var countdown setget set_countdown
export var countdown_on := true 

const TIEMPO_STR = "Tiempo: "

func _ready():
	if not countdown_on:
		$Control/Margin/HBox/Time.visible = false
	
func set_description(_description : String):
	description = _description
	$"%Description".text = description


func set_countdown(_countdown : int):
	countdown = _countdown
	$"%Time".text = TIEMPO_STR + str(countdown)


func get_time() -> int:
	return countdown


func start_timer():
	if countdown_on:
		$Timer.start()


func stop_timer():
	$Timer.stop()


func _on_Timer_timeout():
	if countdown > 0:
		countdown -= 1
		$"%Time".text = TIEMPO_STR + str(countdown)
	else:
		$Timer.stop()
		
		Signals.emit_signal("stage_ended")
