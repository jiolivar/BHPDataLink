extends Node

var OUTLINE_GREEN = preload("res://styles/GreenOutlineStylebox.tres")
var OUTLINE_RED = preload("res://styles/RedOutlineStylebox.tres")
var OUTLINE_YELLOW = preload("res://styles/YellowOutlineStylebox.tres")
var OUTLINE_LIGHTGREEN = preload("res://styles/LightGreenOutlineStylebox.tres")
var OUTLINE_BLUE = preload("res://styles/BlueOutlineStylebox.tres")

var GREY = preload("res://styles/GreyStylebox.tres")
var LIGHTGREY = preload("res://styles/LightGreyStylebox.tres")
var RED = preload("res://styles/RedStylebox.tres")
var YELLOW = preload("res://styles/YellowStylebox.tres")
var WHITE = preload("res://styles/WhiteStylebox.tres")
var DARK_BLUE = preload("res://styles/DarkBlueStylebox.tres")


func get_outline_style(id : int) -> StyleBox:
	match id:
		0: return OUTLINE_GREEN
		1: return OUTLINE_YELLOW
		2: return OUTLINE_RED
		3: return OUTLINE_LIGHTGREEN
		4: return OUTLINE_BLUE
	return OUTLINE_GREEN
