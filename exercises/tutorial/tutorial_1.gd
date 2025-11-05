extends Node2D

# category:
# 0 -> no user
# 1 -> disconected
# 2 -> glasses off
# 3 -> self management
# 4 -> low risk
# 5 -> med risk
# 6 -> high risk

var tutorial_4 = preload("res://exercises/tutorial/tutorial_4.tscn")
var tutorial_4_instance
var tutorial_4_close_enable := true

var tutorial_3 = preload("res://exercises/tutorial/tutorial_3.tscn")
var tutorial_3_instance
var tutorial_3_close_enable := true

signal more_info_pressed()
signal before_more_info_pressed()

func _ready():
	
	for user_data in Data.ordered_user_data:
		$"%IrisButtonContainer".add_button(user_data)
	
	$"%HighRiskCategory".set_count($"%IrisButtonContainer".categories[6])
	$"%MedRiskCategory".set_count($"%IrisButtonContainer".categories[5])
	$"%LowRiskCategory".set_count($"%IrisButtonContainer".categories[4])
	$"%DisconectedCategory".set_count($"%IrisButtonContainer".categories[1])
	$"%NoGlassesCategory".set_count($"%IrisButtonContainer".categories[2])
	$"%SelfManagementCategory".set_count($"%IrisButtonContainer".categories[3])
	
	tutorial_4_instance = tutorial_4.instance()
	tutorial_4_instance.connect("close", self, "_on_tutorial_4_close")
	tutorial_4_instance.connect("risk_user_pressed", self, "_on_tutorial_4_risk_user_pressed")
	$"%Tutorial_4_Container".add_child(tutorial_4_instance)
	tutorial_4_instance.rect_position = $"%Tutorial_4_Pivot".rect_position
	tutorial_4_instance.rect_scale = Vector2(0.85, 0.85)
	tutorial_4_instance.name = "Tutorial_4"
	
	
	tutorial_3_instance = tutorial_3.instance()
	tutorial_3_instance.connect("close", self, "_on_tutorial_3_close")
	#tutorial_4_instance.connect("risk_user_pressed", self, "_on_tutorial_4_risk_user_pressed")
	$"%Tutorial_3_Container".add_child(tutorial_3_instance)
	tutorial_3_instance.rect_position = $"%Tutorial_3_Pivot".rect_position
	tutorial_3_instance.rect_scale = Vector2(0.8, 0.8)
	tutorial_3_instance.name = "Tutorial3"
	
	yield(get_tree(), "idle_frame")
	
	name = "MainTutorial1"
	
	
	
	


func _on_Header_risk_summary_pressed():
	
	if $"%Tutorial_4_Container".visible:
		return
		
	$"%Tutorial_4_Container".visible = true
	tutorial_4_instance.clean_data()


func _on_tutorial_4_close() -> void:
	if not tutorial_4_close_enable:
		return
	
	if not $"%Tutorial_4_Container".visible:
		return
	
	$"%Tutorial_4_Container".visible = false


func _on_tutorial_4_risk_user_pressed() -> void:
	open_tutorial_3_window()


func open_tutorial_3_window() -> void:

	if $"%Tutorial_3_Container".visible:
		return
	
	$"%Tutorial_3_Container".visible = true
	tutorial_3_instance.clean_data()
	tutorial_3_instance.update_data()


func _on_tutorial_3_close() -> void:
	if not tutorial_3_close_enable:
		return
	
	if not $"%Tutorial_3_Container".visible:
		return
	
	$"%Tutorial_3_Container".visible = false


func _on_IrisButtonContainer_select_iris_button(iris_button_ref):
	
	if iris_button_ref != null:
	
		var graph_index : int = iris_button_ref.data.get("graph_index", 0)
		
		match graph_index:
			1:
				$"%ActivityGraph".texture = preload("res://assets/images/graph/graph_a_1.png")
			2:
				$"%ActivityGraph".texture = preload("res://assets/images/graph/graph_a_2.png")
			3:
				$"%ActivityGraph".texture = preload("res://assets/images/graph/graph_a_3.png")
			4:
				$"%ActivityGraph".texture = preload("res://assets/images/graph/graph_a_4.png")
			5:
				$"%ActivityGraph".texture = preload("res://assets/images/graph/graph_a_5.png")
			6:
				$"%ActivityGraph".texture = preload("res://assets/images/graph/graph_a_6.png")
			7:
				$"%ActivityGraph".texture = preload("res://assets/images/graph/graph_a_7.png")
			_:
				$"%ActivityGraph".texture = preload("res://assets/images/graph/graph_a_1.png")
		
		$"%ActivityGraph".show()
	else:
		$"%ActivityGraph".hide()


func _on_IrisButtonContainer_before_more_info_pressed():
	emit_signal("before_more_info_pressed")


func _on_IrisButtonContainer_more_info_pressed():
	emit_signal("more_info_pressed")
	yield(get_tree(), "idle_frame")
	$"%Pages".current_tab = 1
	$"%Tutorial2".update()


func _on_Tutorial2_back_pressed():
	$"%Pages".current_tab = 0


func _on_IrisButtonContainer_risk_tag_pressed(iris_button_ref):
	
	Main.tutorial_3_user_data = iris_button_ref.data
	open_tutorial_3_window()

