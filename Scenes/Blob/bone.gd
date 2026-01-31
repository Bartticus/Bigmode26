extends RigidBody2D
class_name Bone

enum Status { FREE, TUGGED, PINCHED }
# Every time the 'status' is set, set_status will run and perform any side effects for the new status
var status: Status = Status.FREE : set = set_status

func set_status(new_status) -> void:
	status = new_status
	# match status:
	# 	pass