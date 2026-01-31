extends Node2D

@export var camera: Camera2D

func _on_screen_12_body_entered(_body: Node2D) -> void:
	camera.global_position = $Anchors/Anchor2.global_position


func _on_screen_23_body_entered(_body: Node2D) -> void:
	camera.global_position = $Anchors/Anchor3.global_position
