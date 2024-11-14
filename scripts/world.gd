extends Node2D
@export var width = 72
@export var height = 40
@onready var tile_map_layer: TileMapLayer = $tiles
@onready var snake: CharacterBody2D = $snake
@onready var apple: PackedScene = preload("res://scenes/apple.tscn")
@onready var death_timer: Timer = $death_timer
var score: int = 0
var score_string: String = "Score: %s"
@onready var label: Label = $Label

var rng = RandomNumberGenerator.new()
var walkable_coordinates = []


var top_left_corner_border = Vector2i(0, 0)
var top_right_corner_border = Vector2i(7, 0)
var bottom_left_corner_border = Vector2i(0, 5)
var bottom_right_corner_border = Vector2i(7, 5)

var top_border_array = [Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 0), Vector2i(5, 0), Vector2i(6, 0)]
var bottom_border_array = [Vector2i(1, 5), Vector2i(2, 5), Vector2i(3, 5), Vector2i(4, 5), Vector2i(5, 5), Vector2i(6, 5)]
var left_border_array = [Vector2i(0, 1), Vector2i(0, 2), Vector2i(0, 3), Vector2i(0, 4)]
var right_border_array = [Vector2i(7, 1), Vector2i(7, 2), Vector2i(7, 3), Vector2i(7, 4)]

var walkable_array = [
	Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1), Vector2i(5, 1), Vector2i(6, 1),
	Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2), Vector2i(5, 2), Vector2i(6, 2),
	Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3), Vector2i(4, 3), Vector2i(5, 3), Vector2i(6, 3),
	Vector2i(1, 4), Vector2i(2, 4), Vector2i(3, 4), Vector2i(4, 4), Vector2i(5, 4), Vector2i(6, 4),
	]

func _ready() -> void:
	snake._on_snake_died.connect(snake_died)
	snake.SPEED = 5
	var source_id = 1
	
	tile_map_layer.set_cell(Vector2i(0, 0), source_id, top_left_corner_border)
	tile_map_layer.set_cell(Vector2i(width - 1, 0), source_id, top_right_corner_border)
	tile_map_layer.set_cell(Vector2i(0, height - 1), source_id, bottom_left_corner_border)
	tile_map_layer.set_cell(Vector2i(width - 1, height - 1), source_id, bottom_right_corner_border)

	for x in range(1, width - 1):
		tile_map_layer.set_cell(Vector2i(x, 0), source_id, top_border_array[x % top_border_array.size()])
		tile_map_layer.set_cell(Vector2i(x, height - 1), source_id, bottom_border_array[x % bottom_border_array.size()])

	for y in range(1, height - 1):
		tile_map_layer.set_cell(Vector2i(0, y), source_id, left_border_array[y % left_border_array.size()])
		tile_map_layer.set_cell(Vector2i(width - 1, y), source_id, right_border_array[y % right_border_array.size()])

	for x in range(1, width - 1):
		for y in range(1, height - 1):
			tile_map_layer.set_cell(Vector2i(x, y), source_id, walkable_array.pick_random())
	
	for x in range(2, width - 2):
		for y in range(2, height -2):
			walkable_coordinates.append(Vector2i(x, y))
	label.global_position = tile_map_layer.map_to_local(Vector2i(1, 1))
	label.visible = true
	label.text = score_string % score
	var new_apple = apple.instantiate()
	add_child(new_apple)
	new_apple.set_deferred("global_position", tile_map_layer.map_to_local(walkable_coordinates.pick_random()))
	new_apple.set_deferred("visible", true)
	new_apple._on_apple_eaten.connect(handle_apple_eaten)
	
func snake_died():
	death_timer.start()

func handle_apple_eaten(eaten_apple: Node2D):
	eaten_apple.queue_free()
	score += 1
	var apples_to_spawn: int = floor(score as float / 10) + 1 
	snake.SPEED += 0.5
	snake.grow_snake()
	label.text = score_string % score
	for i in range(apples_to_spawn, apples_to_spawn + 1):
		print(i)
		var new_apple = apple.instantiate()
		self.call_deferred("add_child", new_apple)
		new_apple.set_deferred("global_position", tile_map_layer.map_to_local(walkable_coordinates.pick_random()))
		new_apple.set_deferred("visible", true)
		new_apple._on_apple_eaten.connect(handle_apple_eaten)

	


func _on_death_timer_timeout() -> void:
	get_tree().reload_current_scene()
