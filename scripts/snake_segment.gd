extends Node2D
signal self_collision


func _on_snake_segment_area_area_shape_entered(_area_rid: RID, _area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	self_collision.emit()
