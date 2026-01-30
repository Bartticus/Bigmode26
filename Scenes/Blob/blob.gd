class_name Blob
extends Node2D

@export var softbody: SoftBody2D
@export var bodies: Array = [RigidBody2D]

func _ready() -> void:
	Global.blob = self
	
	for child in softbody.get_children():
		if child is RigidBody2D:
			bodies.append(child)
		
func _process(delta: float) -> void:
	print($"Egg/Bone-0".global_position)
