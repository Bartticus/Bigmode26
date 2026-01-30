extends Node2D

@export var max_tug_distance: float = 800
@export var max_tug_power: float = 2500
@export var tug_decay: float = 2.5

var current_body: RigidBody2D
var dist_to_current_body: float

enum Status { IDLE, TUGGING }
# Every time the 'status' is set, set_status will run and perform any side effects for the new status
var status: Status = Status.IDLE : set = set_status

func set_status(new_status) -> void:
	status = new_status
	match status:
		Status.IDLE:
			$PointLight2D.enabled = false
			current_body = null

		Status.TUGGING:
			$PointLight2D.enabled = true

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		var key_string: String = OS.get_keycode_string(event.keycode)
		if key_string == name:
			status = Status.TUGGING
	
	if event is InputEventKey and event.is_released():
		var key_string: String = OS.get_keycode_string(event.keycode)
		if key_string == name:
			status = Status.IDLE

func find_closest_body() -> void:
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
			
	current_body = closest_body
	dist_to_current_body = shortest_dist

func find_and_tug_target() -> void:
	find_closest_body()
	current_body.apply_force(current_body.global_position.direction_to(global_position) * calculate_tugging_power())

# Tugging power drops off exponentially
func calculate_tugging_power() -> float:
	if (dist_to_current_body >= max_tug_distance):
		return 0

	var power_multiplier = dist_to_current_body / max_tug_distance
	var tugging_power = max_tug_power * exp(-tug_decay * power_multiplier)
	print(tugging_power)
	return tugging_power

func _physics_process(_delta: float) -> void:
	match status:
		Status.TUGGING:
			find_and_tug_target()		
