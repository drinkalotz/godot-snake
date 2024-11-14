extends Node2D
signal _on_apple_eaten

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_apple_area_area_entered(area: Area2D) -> void:
	_on_apple_eaten.emit(self)
