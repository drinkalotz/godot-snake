extends Node2D
signal self_collision


func _on_snake_segment_area_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	self_collision.emit()
