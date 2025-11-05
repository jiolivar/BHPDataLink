extends Control

var user_info = preload("res://modular/UserInfo.tscn")

var button_group := ButtonGroup.new()

var all_user_info := []

signal back_pressed()

func update():
	
	for user_info_instance in all_user_info:
		user_info_instance.hide()
		user_info_instance.queue_free()
	
	all_user_info.clear()
	
	for data in Main.tutorial_2_user_datas:
		
		var user_info_instance = user_info.instance()
		$"%UserInfoContainer".add_child(user_info_instance)
		
		user_info_instance.name = "user_info_" + str(all_user_info.size())
		user_info_instance.set_user_data(data)
		user_info_instance.set_button_group(button_group)
		user_info_instance.connect("pressed", self, "_on_user_info_pressed")
		user_info_instance.set_is_button(true)
		
		if all_user_info.size() == 0:
			user_info_instance.get_node("Button").pressed = true
			_on_user_info_pressed(user_info_instance, true)
		
		all_user_info.append(user_info_instance)
		

func _on_user_info_pressed(user_info_ref, pressed : bool) -> void:
	print("pressed: ", user_info_ref.data)
	
	if user_info_ref != null:
	
		var graph_index : int = user_info_ref.data.get("graph_index", 0)
		
		match graph_index:
			1:
				$"%graphB".texture = preload("res://assets/images/graph/graph_b_1.png")
			2:
				$"%graphB".texture = preload("res://assets/images/graph/graph_b_2.png")
			3:
				$"%graphB".texture = preload("res://assets/images/graph/graph_b_3.png")
			4:
				$"%graphB".texture = preload("res://assets/images/graph/graph_b_4.png")
			5:
				$"%graphB".texture = preload("res://assets/images/graph/graph_b_5.png")
			6:
				$"%graphB".texture = preload("res://assets/images/graph/graph_b_6.png")
			7:
				$"%graphB".texture = preload("res://assets/images/graph/graph_b_7.png")
			_:
				$"%graphB".texture = preload("res://assets/images/graph/graph_b_1.png")
	


func _on_BackButton_pressed():
	
	for user_info_instance in all_user_info:
		user_info_instance.hide()
		user_info_instance.queue_free()
	
	all_user_info.clear()
	
	emit_signal("back_pressed")

