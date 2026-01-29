extends Node2D

var current_body: RigidBody2D

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var key_string: String = OS.get_keycode_string(event.keycode)
		if key_string == name:
			$PointLight2D.enabled = true
			
			current_body = find_closest_body()

	
	if event is InputEventKey and event.is_released():
		var key_string: String = OS.get_keycode_string(event.keycode)
		if key_string == name:
			$PointLight2D.enabled = false
			current_body = null

func find_closest_body() -> RigidBody2D:
	var closest_body: RigidBody2D
	var shortest_dist: float
	
	for body in Global.blob.bodies:
		if body is RigidBody2D:
			var temp: float = global_position.distance_to(body.global_position)
			
			if shortest_dist == 0:
				shortest_dist = temp
				closest_body = body
			
			if temp < shortest_dist:
				shortest_dist = temp
				closest_body = body
			
	return closest_body

func _physics_process(_delta: float) -> void:
	if current_body:
		current_body.apply_force(current_body.global_position.direction_to(global_position) * 1000)
	
