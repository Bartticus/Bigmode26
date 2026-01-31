extends Node2D

@onready var snap_timer: Timer = %SnapTimer
@onready var point_light_2d: PointLight2D = %PointLight2D
@onready var debug_line: Line2D = %DebugLine

@export var max_tug_distance: float = 800
@export var max_tug_power: float = 3000
@export var tug_decay: float = 2.5
@export var max_snap_multiplier: float = 2.0
@export var snap_timer_wait_time: float = 1.5
@export var debug_line_active: bool = true

var current_bone: Bone : set = set_current_bone
var dist_to_current_bone: float
var force_applied: Vector2

enum Status { IDLE, TUGGING, SNAPPING }
# Every time the 'status' is set, set_status will run and perform any side effects for the new status
var status: Status = Status.IDLE : set = set_status

func set_status(new_status) -> void:
	status = new_status
	match status:
		Status.IDLE:
			point_light_2d.enabled = false
			current_bone = null
			snap_timer.stop()
			debug_line.clear_points()
		Status.TUGGING:
			point_light_2d.enabled = true
			snap_timer.start(snap_timer_wait_time)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and !event.is_echo():
		var key_string: String = OS.get_keycode_string(event.keycode)
		if key_string == name && status != Status.TUGGING:
			status = Status.TUGGING
	
	if event is InputEventKey and event.is_released():
		var key_string: String = OS.get_keycode_string(event.keycode)
		if key_string == name:
			if status != Status.SNAPPING:
				status = Status.SNAPPING
			else:
				status = Status.IDLE


func find_closest_bone() -> void:
	var closest_bone: Bone = null
	var shortest_dist: float
	var blob_bones = Global.blob.bodies
	for i in blob_bones.size():
		var bone = blob_bones[i]
		var dist_to_bone: float = global_position.distance_to(bone.global_position)
		if bone is Bone:
			if (bone.status != Bone.Status.FREE) && (bone != current_bone):
				continue
			
			if closest_bone == null:
				shortest_dist = dist_to_bone
				closest_bone = bone
			
			if dist_to_bone < shortest_dist:
				shortest_dist = dist_to_bone
				closest_bone = bone
	
	current_bone = closest_bone
	dist_to_current_bone = shortest_dist


func set_current_bone(new_current_bone) -> void:
	if (current_bone == new_current_bone):
		return
	if (current_bone is Bone):
		current_bone.status = Bone.Status.FREE
	if (new_current_bone is Bone):
		new_current_bone.status = Bone.Status.TUGGED
	current_bone = new_current_bone


func find_and_tug_target() -> void:
	find_closest_bone()
	move_bone()
	

func move_bone() -> void:
	if (current_bone is not Bone):
		return
	var new_force: Vector2 = current_bone.global_position.direction_to(global_position) * calculate_tugging_power()
	var weight: float = dist_to_current_bone / max_tug_distance
	match status:
		Status.SNAPPING:
			force_applied = -(new_force * calculate_snap_multiplier())
		Status.TUGGING:
			force_applied = force_applied.lerp(new_force, weight)
	current_bone.apply_force(force_applied)
	if debug_line_active:
		debug_line.draw_line_to_bone(current_bone)


func calculate_snap_multiplier() -> float:
	return (max_snap_multiplier * ((snap_timer.wait_time - snap_timer.time_left) / snap_timer.wait_time))


func snap_away() -> void:
	move_bone()
	status = Status.IDLE


# Tugging power drops off exponentially
func calculate_tugging_power() -> float:
	if (dist_to_current_bone >= max_tug_distance):
		return 0

	var power_multiplier = dist_to_current_bone / max_tug_distance
	var tugging_power = max_tug_power * exp(-tug_decay * power_multiplier)
	return tugging_power


func _physics_process(_delta: float) -> void:
	match status:
		Status.TUGGING:
			find_and_tug_target()
		Status.SNAPPING:
			snap_away()
