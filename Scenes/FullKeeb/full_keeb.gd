@tool
extends Node2D

@onready var number_row: Node2D = %NumberRow
@onready var q_row: Node2D = %QRow
@onready var a_row: Node2D = %ARow
@onready var z_row: Node2D = %ZRow

@export var x_spacing: float
@export var x_offset: float
@export var y_spacing: float
@export var y_offset: float

@export var snap_keys_to_position: bool = false:
	set(value):
		snap_keys_to_position = value
		if snap_keys_to_position and Engine.is_editor_hint():
			set_key_positions()

func set_key_positions():
	var all_rows = [number_row, q_row, a_row, z_row]

	for i in all_rows.size():
		var row = all_rows[i]
		if !(row is Node2D):
			continue

		var row_keys = row.get_children()
		for j in row_keys.size():
			var key: Node2D = row_keys[j]
			key.position.x = x_spacing * j + x_offset
			key.position.y = y_spacing * i + y_offset

func _ready() -> void:
	set_key_positions()
