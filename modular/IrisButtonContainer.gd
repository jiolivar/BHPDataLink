extends Control

export var max_buttons_per_page_count := 20
var buttons_per_page_count := 0

var start_angle := -85.5
var angle_per_button := 18.0

var current_buttons_page := -1

var pages := []

var iris_button = preload("res://modular/IrisButton.tscn")
var iris_tab_button = preload("res://modular/IrisTabButton.tscn")
onready var tab_buttons_group := ButtonGroup.new()

var selected_iris_buttons := []

var categories := {
	0 : 0,
	1 : 0,
	2 : 0,
	3 : 0,
	4 : 0,
	5 : 0,
	6 : 0
}

# category:
# 0 -> no user
# 1 -> disconected
# 2 -> glasses off
# 3 -> self management
# 4 -> low risk
# 5 -> med risk
# 6 -> high risk

signal select_iris_button(iris_button_ref)
signal risk_tag_pressed(iris_button_ref)
signal more_info_pressed()
signal before_more_info_pressed()

func _ready():
	pass

func add_button(data : Dictionary) -> void:
	
	if current_buttons_page < 0 || buttons_per_page_count >= max_buttons_per_page_count:
		var new_page = Control.new()
		pages.append(new_page)
		$"%Tabs".add_child(new_page)
		
		buttons_per_page_count = 0
		current_buttons_page += 1
		
		var new_tab_button = iris_tab_button.instance()
		$"%TabsButtonContainer".add_child(new_tab_button)
		new_tab_button.name = "IrisTabButton_" + str(current_buttons_page)
		new_tab_button.set_tab_index(current_buttons_page)
		new_tab_button.group = tab_buttons_group
		
		new_page.name = "Page_" + str(current_buttons_page)
		
		if current_buttons_page == 0:
			new_tab_button.pressed = true
		
		new_tab_button.connect("pressed", self, "_on_tab_button_pressed", [current_buttons_page])
	
	var iris_button_instance = iris_button.instance()
	
	var page : Control = pages[current_buttons_page] as Control
	page.add_child(iris_button_instance)
	iris_button_instance.name = "IrisButton_" + str(buttons_per_page_count)
	iris_button_instance.set_user_data(data)
	
	if categories.has(iris_button_instance.category):
		categories[iris_button_instance.category] += 1
	
	iris_button_instance.connect("pressed", self, "_on_iris_button_pressed")
	iris_button_instance.connect("risk_tag_pressed", self, "_on_risk_tag_pressed")
	
	iris_button_instance.rect_rotation = start_angle + buttons_per_page_count * angle_per_button
		
	buttons_per_page_count += 1


func fill_empty_spaces(page_index : int) -> void:
	var page : Control = pages[page_index] as Control
	for i in range(buttons_per_page_count, max_buttons_per_page_count):
		page.add_button({"user_state": 0})


func set_page(page_index : int) -> void:
	$"%Tabs".current_tab = page_index


func _on_iris_button_pressed(iris_button_ref, pressed) -> void:
	if pressed:
		if not selected_iris_buttons.empty():
			selected_iris_buttons.back().set_last_selected(false)
		selected_iris_buttons.append(iris_button_ref)
		selected_iris_buttons.back().set_last_selected(true)
		$"%UserInfo".set_user_data(selected_iris_buttons.back().data)
	else:
		selected_iris_buttons.erase(iris_button_ref)
		if selected_iris_buttons.empty():
			$"%UserInfo".hide()
		else:
			selected_iris_buttons.back().set_last_selected(true)
			$"%UserInfo".set_user_data(selected_iris_buttons.back().data)
	
	if selected_iris_buttons.empty():
		emit_signal("select_iris_button", null)
	else:
		emit_signal("select_iris_button", selected_iris_buttons.back())


func _on_risk_tag_pressed(iris_button_ref) -> void:
	emit_signal("risk_tag_pressed", iris_button_ref)


func _on_tab_button_pressed(tab_index : int) -> void:
	set_page(tab_index)


func _on_MoreInfoButton_pressed():
	emit_signal("before_more_info_pressed")
	
	if not selected_iris_buttons.empty():
		Main.tutorial_2_user_datas.clear()
		for selected_iris_button in selected_iris_buttons:
			Main.tutorial_2_user_datas.append(selected_iris_button.data)
		
		emit_signal("more_info_pressed")

