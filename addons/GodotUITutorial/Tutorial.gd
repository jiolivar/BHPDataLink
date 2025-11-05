extends Control

var current_step := -1
var current_element = null
var prev_element = null
var focusing_element := false
var element_rect_with_margins
var main_panel
export(NodePath) var main_panel_path
var parent_scroll_container = null
var automatic_end_step := -1

signal back_button_pressed
signal tutorial_end
signal outro_shown
signal step_changed(new_step_index)

var offset := Vector2(0,0)

var tutorial_ended := false

func _ready():
	#get_tree().get_root().connect("size_changed", self, "_apply_rect_properties", [0])
	get_tree().get_root().connect("size_changed", self, "_apply_rect_properties")
	main_panel = get_node(main_panel_path)


func _input(event):
	return
	var evLocal = $"%ClickArea".make_input_local(event)
	if visible and !Rect2(Vector2(0,0),$"%ClickArea".rect_size).has_point(evLocal.position):
		accept_event()


func _process(delta):
	if current_element and is_instance_valid(current_element) and main_panel:
		element_rect_with_margins = current_element.get_global_rect()
		element_rect_with_margins.position.y -= 100
		element_rect_with_margins.size.y += 200 
		var area_element = element_rect_with_margins.get_area()
		var intersection_area = intersection(main_panel.get_global_rect(), element_rect_with_margins).get_area()
		var area_ratio = intersection_area/area_element
		if area_ratio < 0.99 and !focusing_element: #not visible enough
			focusing_element = true
			_focus_element()
		if focusing_element or $"%NextStepButton".visible:
			_apply_rect_properties()
			
		if automatic_end_step > 0:
			var a = InputEventMouseButton.new()
			a.position = get_viewport_transform() * get_global_transform() * $"%CursorHelp".rect_global_position
			a.button_index = BUTTON_LEFT
			a.pressed = true
			Input.parse_input_event(a)
			yield(get_tree(),"idle_frame")
			a.pressed = false
			Input.parse_input_event(a)
		
		#make sure the popup dont hide if we press something else
		#popup_exclusive = true is not good because it wont let us press other buttons, like the back button
		elif current_element is PopupMenu:
			current_element.visible = true
			
			

func run_up_to(step):
	automatic_end_step = step
	_on_IntroStartButton_pressed()
	if step > 0:
		Engine.time_scale = 1000
		var index = AudioServer.get_bus_index("Master")
		AudioServer.set_bus_volume_db(index, -80.0)
		$"%LoadingCanvasLayer".visible = true
	

func _focus_element():
	if parent_scroll_container:
		var global_rect = parent_scroll_container.get_global_rect()

		var diff = max(min(element_rect_with_margins.position.y, global_rect.position.y), element_rect_with_margins.position.y + element_rect_with_margins.size.y - global_rect.size.y)

		var target_scroll_pos = parent_scroll_container.get_v_scroll() + (diff - global_rect.position.y)

		var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(parent_scroll_container.get_v_scrollbar(),"value",target_scroll_pos,0.6).from(parent_scroll_container.get_v_scrollbar().value)
		yield(tween, "finished")
		focusing_element = false
	

func next_step(advance := 1):

	current_step += advance
	current_step = int( clamp(current_step, 0.0, float(ElementTracker.sequence.size())) )
	emit_signal("step_changed", current_step)
	
	$"%Steps".text = str(current_step+1) + "/" + str(ElementTracker.sequence.size())
	
	if automatic_end_step >= 0 and automatic_end_step < current_step:
		automatic_end_step = -1
		Engine.time_scale = 1
		var index = AudioServer.get_bus_index("Master")
		AudioServer.set_bus_volume_db(index, 0.0)
		$"%LoadingCanvasLayer".visible = false
	
	if current_step:
		$"%BackButton".visible = false#true
	$"%IdleTimer".start()
	$"%CursorHelp".visible = false
	$"%NextStepButton".visible = false
	$"%ClickArea".mouse_filter = MOUSE_FILTER_IGNORE
	
	yield(get_tree(),"idle_frame")
			
	if current_step < ElementTracker.sequence.size():
		#print(">>> CURRENT STEP: ", ElementTracker.sequence[current_step]["element"])
		
		print(" new elem : ", ElementTracker.sequence[current_step]["element"])
		current_element = get_tree().get_root().get_node(ElementTracker.sequence[current_step]["element"])
		print(" new elem find: ", current_element)
		if ElementTracker.sequence[current_step].has("offset"):
			offset = Vector2(ElementTracker.sequence[current_step]["offset"][0], ElementTracker.sequence[current_step]["offset"][1])
		else:
			offset = Vector2(0,0)
		
		var parent = current_element.get_parent()
		while(parent):
			if parent.get_class() == "ScrollContainer":
				parent_scroll_container = parent
				break
			parent = parent.get_parent()

		if current_element == null:
			yield(get_tree(),"idle_frame")
			current_element = get_tree().get_root().get_node(ElementTracker.sequence[current_step]["element"])
		
		if ElementTracker.sequence[current_step].has("custom_event"):
			current_element.connect(ElementTracker.sequence[current_step]["custom_event"], self, "_element_pressed")
		elif current_element is OptionButton:
			if ElementTracker.sequence[current_step].has("force_as_button"):
				current_element.connect("pressed", self, "_element_pressed", [0])
			else:
				current_element.connect("item_selected", self, "_element_pressed")
		elif current_element is BaseButton: #elif, make sure LineGrabbable doesnt enter here
			current_element.connect("pressed", self, "_element_pressed", [0])
		elif current_element is MenuButton:
			current_element.connect("about_to_show", self, "_element_pressed", [0])
		elif current_element is PopupMenu:
			current_element.connect("id_pressed", self, "_element_pressed")
			#if automatic_end_step > 0:
			#	current_element.popup_exclusive = true #now its being forced visible in process
			#current_element.set_hide_on_window_lose_focus(false)
		elif current_element is Tree:
			current_element.connect("item_edited", self, "_element_pressed", [0])
		elif current_element is LineEdit:
			current_element.connect("text_changed", self, "_element_pressed")
		elif current_element is Tabs:
			current_element.connect("tab_clicked", self, "_element_pressed")
		elif current_element is Control:
			$"%NextStepButton".visible = true
			$"%ClickArea".mouse_filter = MOUSE_FILTER_STOP
		
		if current_element != null:
			print("ELEM: ", current_element.name)
			current_element.grab_focus()
		_apply_rect_properties()
		if ElementTracker.sequence[current_step].has("delayed_apply_rect"):
			make_delayed_apply_rect()
			
		$"%InfoText".text = ElementTracker.sequence[current_step]["text"]
		var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
		#$"%TextWriteSound".play()
		tween.tween_property($"%InfoText","percent_visible",1.0,0.01*$"%InfoText".text.length()).from(0.0)
		yield(tween, "finished")
		#$"%TextWriteSound".stop()
		
	else:
		$"%ClickArea".rect_global_position = Vector2(-2029,-25)
		$"%ClickArea".rect_size = Vector2(17,15)
		$"%ClickArea".rect_scale = Vector2(1,1)
		
		$"%Outro".visible = true
		$"%InfoText".visible = false
		tutorial_ended = true
		emit_signal("outro_shown")
		yield(get_tree().create_timer(0.4), "timeout")
		$"%ClickArea".rect_global_position = Vector2(-2029,-25)
		$"%ClickArea".rect_size = Vector2(17,15)
		$"%ClickArea".rect_scale = Vector2(1,1)
		$"%CursorHelp".rect_global_position = Vector2(-2029,-25)
		$"%CursorHelp".hide()


func make_delayed_apply_rect() -> void:
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	_apply_rect_properties()


func _on_Button_pressed():
	next_step()
	

func _apply_rect_properties():
	if tutorial_ended:
		return
	
	if current_step >= ElementTracker.sequence.size():
		return
	
	var flag = ElementTracker.sequence[current_step]["flag"]
	
	var box_offset = Vector2(0,0)
	if ElementTracker.sequence[current_step].has("box_offset"):
		box_offset = Vector2(ElementTracker.sequence[current_step]["box_offset"][0], ElementTracker.sequence[current_step]["box_offset"][1])
	
	yield(get_tree(),"idle_frame")
	if current_element != null and is_instance_valid(current_element):
		
		var pos = current_element.rect_global_position
		var size = current_element.rect_size * current_element.get_global_transform().get_scale()
		
		var current_element_transform_global = current_element.get_global_transform()
		var new_transform_local = $"%ClickArea".get_parent().get_global_transform().affine_inverse() * current_element_transform_global
		var rot = rad2deg( new_transform_local.get_rotation() )
		
		if current_element is PopupMenu:
			#if current_step == 2:
			#	return
			#current_element.rect_global_position.x = current_element.get_parent().rect_global_position.x
			#current_element.rect_global_position.y = min(current_element.get_parent().rect_global_position.y + current_element.get_parent().rect_size.y, get_viewport_rect().size.y - current_element.rect_size.y)
			
			var margin = 8
			####pos.y = current_element.get_parent().rect_size.y
			# esto no se porque estaba
			pos.y = current_element.rect_global_position.y
			size.y = (current_element.rect_size.y - margin * 2)/(current_element.get_item_count())
			pos.y = pos.y + margin + size.y*flag
			if current_element.has_method("lock"):
				current_element.lock(flag)
			elif current_element.get_parent().has_method("lock"):
				current_element.get_parent().lock(flag)
			
		elif current_element is Tree:
			var rect_string : String = ElementTracker.sequence[current_step]["rect"].replace("(","").replace(")","")
			var rect_array = rect_string.split_floats(",")
			var rect = Rect2(rect_array[0],rect_array[1],rect_array[2],rect_array[3])
			pos += rect.position
			size = rect.size
			size.x = 130
			
		elif current_element is Tabs:
			var rect_string : String = ElementTracker.sequence[current_step]["rect"].replace("(","").replace(")","")
			var rect_array = rect_string.split_floats(",")
			var rect = Rect2(rect_array[0],rect_array[1],rect_array[2],rect_array[3])
			pos += rect.position
			size = rect.size
		
		var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property($"%ClickArea","rect_global_position",pos + box_offset,0.3).from($"%ClickArea".rect_global_position)
		tween.parallel().tween_property($"%ClickArea","rect_size",size,0.3).from($"%ClickArea".rect_size)
		
		tween.parallel().tween_property($"%ClickArea","rect_rotation",rot,0.3).from($"%ClickArea".rect_rotation)
		
		if $"%NextStepButton".visible:
			$"%CursorHelp".rect_global_position = $"%NextStepButton".rect_global_position + $"%NextStepButton".rect_size*0.5
		else:
			$"%CursorHelp".rect_global_position = pos + box_offset + size*0.5
		
		$"%InfoText".rect_min_size.y = 0
		$"%InfoText".rect_size.y = 0
		
		_update_info_position(pos, size)
		
		

func _update_info_position(elem_pos : Vector2, elem_size : Vector2) -> void:
	
	var dir := -Vector2.ONE
	
	var elem_center : Vector2 = elem_pos + elem_size / 2.0
	var window_center : Vector2 = get_viewport_rect().size / 2.0
	
	if elem_center.x < window_center.x:
		dir.x = 1.0
	if elem_center.y < window_center.y:
		dir.y = 1.0
	
	var to_pos = elem_center + dir * elem_size / 2.0 + $"%InfoText".rect_size * (dir - Vector2.ONE) / 2.0 + 30 * dir
	
	var outside_offset_x = max(0.0, (to_pos.x+$"%InfoText".get_global_rect().size.x+10) - rect_size.x)
	to_pos.x = max(to_pos.x - outside_offset_x, 10)
	var outside_offset_y = max(0.0, (to_pos.y+$"%InfoText".get_global_rect().size.y+80) - rect_size.y)
	to_pos.y = to_pos.y - outside_offset_y
	
	to_pos += offset
	
	var tween3 = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween3.tween_property($"%InfoText","rect_global_position",to_pos,0.2).from($"%InfoText".rect_global_position)



func _on_size_changed() -> void:
	pass


func _element_pressed(_dummy):
	
	print("elem pressed: ", current_element)
	
	if current_element is LineEdit:
		if str(_dummy).to_lower() != ElementTracker.sequence[current_step]["flag"].to_lower():
			return
		else:
			current_element.release_focus()
	
	$"%CursorHelp".visible = false
	if current_element.has_signal("item_selected") and current_element.is_connected("item_selected", self, "_element_pressed"):
		current_element.disconnect("item_selected", self, "_element_pressed")
	
	if current_element.has_signal("pressed") and current_element.is_connected("pressed", self, "_element_pressed"):
		current_element.disconnect("pressed", self, "_element_pressed")
		
	if current_element.has_signal("about_to_show") and current_element.is_connected("about_to_show", self, "_element_pressed"):
		current_element.disconnect("about_to_show", self, "_element_pressed")
		
	if current_element.has_signal("id_pressed") and current_element.is_connected("id_pressed", self, "_element_pressed"):
		current_element.disconnect("id_pressed", self, "_element_pressed")
		
	if current_element.has_signal("item_edited") and current_element.is_connected("item_edited", self, "_element_pressed"):
		current_element.disconnect("item_edited", self, "_element_pressed")
		
	if current_element.has_signal("grabbed") and current_element.is_connected("grabbed", self, "_element_pressed"):
		current_element.disconnect("grabbed", self, "_element_pressed")
		
	if current_element.has_signal("droped") and current_element.is_connected("droped", self, "_element_pressed"):
		current_element.disconnect("droped", self, "_element_pressed")
		
	if current_element.has_signal("drag_ended") and current_element.is_connected("drag_ended", self, "_element_pressed"):
		current_element.disconnect("drag_ended", self, "_element_pressed")
		
	if current_element.has_signal("text_changed") and current_element.is_connected("text_changed", self, "_element_pressed"):
		current_element.disconnect("text_changed", self, "_element_pressed")
	
	if current_element.has_signal("item_moved") and current_element.is_connected("item_moved", self, "_element_pressed"):
		current_element.disconnect("item_moved", self, "_element_pressed")
	
	if current_element.has_signal("tab_clicked") and current_element.is_connected("tab_clicked", self, "_element_pressed"):
		current_element.disconnect("tab_clicked", self, "_element_pressed")
	
	
	
	if prev_element != null and prev_element.has_signal("bad_drop") and prev_element.is_connected("bad_drop", self, "_element_pressed"):
		prev_element.disconnect("bad_drop", self, "_element_pressed")
		print(">> Disconnetec bad drop ", prev_element.name)
	
	$"%CorrectSound".play()
	
	if current_element is PopupMenu:
		#current_element.popup_exclusive = false
		#current_element.set_hide_on_window_lose_focus(true)
		if current_element.has_method("unlock"):
			current_element.unlock()
		elif current_element.get_parent().has_method("unlock"):
			current_element.get_parent().unlock()
	
	prev_element = null
	next_step()


func _on_IdleTimer_timeout():
	$"%CursorHelp".reset()
	$"%CursorHelp".visible = true


func _on_IntroStartButton_pressed():
	$"%ButtonSound".play()
	$"%Intro".visible = false
	$"%InfoText".visible = true
	next_step()


func _on_OutroButton_pressed():
	#ElementTracker.last_step = -1
	#get_tree().reload_current_scene()
	$"%ButtonSound".play()
	emit_signal("tutorial_end")



#Rect2 functions not implemented yet in Godot 3.5
func min_vec(vec_1 : Vector2, vec_2 : Vector2) -> Vector2:
	return Vector2(min(vec_1.x, vec_2.x), min(vec_1.y, vec_2.y))
	
func max_vec(vec_1 : Vector2, vec_2 : Vector2) -> Vector2:
	return Vector2(max(vec_1.x, vec_2.x), max(vec_1.y, vec_2.y))

func intersection(rect_1 : Rect2, rect_2 : Rect2) -> Rect2:
	var new_rect : Rect2 = rect_2;

	if !rect_1.intersects(new_rect):
		return Rect2(0,0,0,0)

	new_rect.position = max_vec(rect_2.position, rect_1.position)

	var p_rect_end : Vector2 = rect_2.position + rect_2.size
	var end : Vector2 = rect_1.position + rect_1.size

	new_rect.size = min_vec(p_rect_end, end) - new_rect.position

	return new_rect


func _on_BackButton_pressed():
	#ElementTracker.last_step = current_step
	next_step(-1)
	emit_signal("back_button_pressed")

func _on_exercise_win(points, total_time):
	$"%PopUp".star_count = points
	$"%PopUp".show()
