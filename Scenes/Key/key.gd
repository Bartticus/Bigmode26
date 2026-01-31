extends Node2D

@onready var snap_timer: Timer = %SnapTimer
@onready var point_light_2d: PointLight2D = %PointLight2D

@export var max_tug_distance: float = 800
@export var max_tug_power: float = 3000
@export var tug_decay: float = 2.5
@export var max_snap_multiplier: float = 0.75

var current_body: RigidBody2D
var dist_to_current_body: float
static var tugged_bodies: Array = [RigidBody2D]

enum Status { IDLE, TUGGING, SNAPPING }
# Every time the 'status' is set, set_status will run and perform any side effects for the new status
var status: Status = Status.IDLE : set = set_status

func set_status(new_status) -> void:
	status = new_status
	match status:
		Status.IDLE:
			point_light_2d.enabled = false
			
			if tugged_bodies.has(current_body):
				tugged_bodies.erase(current_body)
			current_body = null
			snap_timer.stop()

		Status.TUGGING:
			point_light_2d.enabled = true
			snap_timer.start()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and !event.is_echo():
		var key_string: String = OS.get_keycode_string(event.keycode)
		if key_string == name && status != Status.TUGGING:
			status = Status.TUGGING
	
	if event is InputEventKey and event.is_released():
		var key_string: String = OS.get_keycode_string(event.keycode)
		if key_string == name && status != Status.SNAPPING:
			status = Status.SNAPPING

func find_closest_body() -> void:
	var closest_body: RigidBody2D
	var shortest_dist: float
	
	for body in Global.blob.bodies:
		if body is RigidBody2D:
			if tugged_bodies.has(body):
				continue
			
			var temp: float = global_position.distance_to(body.global_position)
			
			if shortest_dist == 0:
				shortest_dist = temp
				closest_body = body
			
			if temp < shortest_dist:
				shortest_dist = temp
				closest_body = body
	
	if current_body != closest_body:
		if tugged_bodies.has(current_body):
			tugged_bodies.erase(current_body)
		else:
			tugged_bodies.append(closest_body)
	
	current_body = closest_body
	dist_to_current_body = shortest_dist

func move_target() -> void:
	var force = current_body.global_position.direction_to(global_position) * calculate_tugging_power()
	if status == Status.SNAPPING:
		force = -(force * calculate_snap_multiplier())
	current_body.apply_force(force)

func calculate_snap_multiplier() -> float:
	return (max_snap_multiplier * ((snap_timer.wait_time - snap_timer.time_left) / snap_timer.wait_time))

func find_and_tug_target() -> void:
	find_closest_body()
	move_target()

func snap_away() -> void:
	move_target()
	status = Status.IDLE
	
# Tugging power drops off exponentially
func calculate_tugging_power() -> float:
	if (dist_to_current_body >= max_tug_distance):
		return 0

	var power_multiplier = dist_to_current_body / max_tug_distance
	var tugging_power = max_tug_power * exp(-tug_decay * power_multiplier)
	# print(tugging_power)
	return tugging_power

func _physics_process(_delta: float) -> void:
	match status:
		Status.TUGGING:
			find_and_tug_target()
			print(tugged_bodies)
		Status.SNAPPING:
			snap_away()
