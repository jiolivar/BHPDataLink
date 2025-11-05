extends Node


const VERSION = "v0.5.0"

var tutorial_2_user_datas := []

var tutorial_3_user_data : Dictionary


var current_try := 0
var current_countdown := 20
var highlight_width := 2.0
var highlite_color := Color(0.227451, 0.878431, 1)
var grabbing_element := false

var current_exercise := -1
var current_exercise_type := ""
var completed_all_exercises := false

var current_exercise_id := ""

var is_first_time := true

var score : Dictionary = {
	0 : { # Exercise 1
		0 : { # Try 1
			"Score" : 0,
			"Time" : 0,
			"Win" : false
		},
		1 : { # Try 2 
			"Score" : 0,
			"Time" : 0,
			"Win" : false
		},
		2 : { # Try 3
			"Score" : 0,
			"Time" : 0,
			"Win" : false
		},
		3 : { # Try 3
			"Score" : 0,
			"Time" : 0,
			"Win" : false
		}
	}
}


func advance_exercise() -> void:
	current_try = 0
	current_exercise = clamp(Exercises.get_next_exercise(current_exercise), 0, Exercises.exercises.size())
	update_exercise_type()


func reverse_exercise() -> void:
	current_exercise = current_exercise - 1
	update_exercise_type()


func advance_exercise_and_get_next() -> String:
	advance_exercise()
	if current_exercise == Exercises.exercises.size():
		reset_exercise()
		completed_all_exercises = true
		return "res://game/main_screens/main_menu/main_menu.tscn"
	else:
		current_exercise_id = Exercises.exercises[current_exercise]["id"]
		return Exercises.exercises[current_exercise]["path"]


func advance_exercise_and_get_prev() -> String:
	reverse_exercise()
	if current_exercise < 0:
		reset_exercise()
		return "res://game/main_screens/main_menu/main_menu.tscn"
	else:
		current_exercise_id = Exercises.exercises[current_exercise]["id"]
		return Exercises.exercises[current_exercise]["path"]


func start_excercises_and_get() -> String:
	current_exercise = -1
	advance_exercise()
	current_exercise_id = Exercises.exercises[current_exercise]["id"]
	return Exercises.exercises[current_exercise]["path"]


func set_exercise_and_get(exercise_index : int) -> String:
	current_try = 0
	current_exercise =  clamp(exercise_index, 0, Exercises.exercises.size())
	update_exercise_type()
	current_exercise_id = Exercises.exercises[current_exercise]["id"]
	return Exercises.exercises[current_exercise]["path"]


func reset_exercise() -> void:
	current_exercise = -1
	update_exercise_type()


func update_exercise_type() -> void:
	if current_exercise >= 0 and current_exercise < Exercises.exercises.size() and Exercises.exercises[current_exercise].has("type"):
		current_exercise_type = Exercises.exercises[current_exercise]["type"]
	else:
		current_exercise_type = ""


func get_completed_all_exercises() -> bool:
	return completed_all_exercises

func reset_completed_all_exercises():
	completed_all_exercises = false



