extends CharacterBody2D

@export var SPEED: float = 5
@export var initial_position: Vector2i = Vector2i(5, 5)  
@export var grid_size: float = 28.8  

var direction: Vector2i = Vector2i.RIGHT
var next_direction: Vector2i = direction
var segment_positions: Array = []  
var segments: Array = [] 
var is_dying = false
signal _on_snake_died
@onready var snake_head: Node2D = $snake_head
@onready var snake_tail: Node2D = $snake_tail
var move_timer: float = 0.0
@onready var snake_head_sprite: Sprite2D = $snake_head/snake_head_sprite
@onready var snake_segment: PackedScene = preload("res://scenes/snake_segment.tscn")
@onready var apple: Node2D = $"../apple"
var move_progress: float = 0.0  # Tracks progress toward the next grid cell


func _ready() -> void:
	segments.append(snake_head)
	segments.append(snake_tail)
	segment_positions.append(initial_position)
	segment_positions.append(segment_positions[0] - Vector2i(1, 0))
	update_snake_positions()

func _process(_delta: float) -> void:
	var input_direction: Vector2i = Input.get_vector("left_ui", "right_ui", "up_ui", "down_ui")
	
	if input_direction != Vector2i.ZERO and input_direction != -direction:
		next_direction = input_direction

func _physics_process(delta: float) -> void:
	if is_dying:
		return
	move_snake(delta)

func move_snake(delta: float) -> void:
	var move_distance = SPEED * grid_size * delta
	if move_progress + move_distance >= grid_size:
		direction = next_direction
		move_progress = 0.0
		direction = next_direction
		
		var head_new_position = segment_positions[0] + direction
		segment_positions.insert(0, head_new_position)
		segment_positions.pop_back()
		
		update_snake_positions()
		update_head_rotation()
		update_tail_rotation()
		move_progress = 0.0
	else:
		move_progress += move_distance		
		

func update_snake_positions() -> void:
	for i in range(segments.size()):
		var grid_pos = segment_positions[i]
		var segment = segments[i]
		segment.position = grid_pos * grid_size
		
		if i > 0 and i < segments.size() - 1:
			var prev_pos = segment_positions[i - 1]
			var next_pos = segment_positions[i + 1]
			
			var is_horizontal = (prev_pos.x != next_pos.x)
			var is_vertical = (prev_pos.y != next_pos.y)
			
			var segment_horizontal_sprite = segment.get_node("snake_segment_horizontal")
			segment_horizontal_sprite.visible = is_horizontal
			var segment_vertical_sprite = segment.get_node("snake_segment_vertical")
			segment_vertical_sprite.visible = is_vertical
			var show_bend = false
			var bend_sprite = segment.get_node("snake_segment_vertical_up") 
		
			bend_sprite.visible = false
			
			if prev_pos.x < grid_pos.x and next_pos.y > grid_pos.y: # up left
				show_bend = true
				bend_sprite.rotation_degrees = -90
			elif prev_pos.y < grid_pos.y and next_pos.x < grid_pos.x: # right up
				show_bend = true
				bend_sprite.rotation_degrees = 0
			elif prev_pos.x > grid_pos.x and next_pos.y < grid_pos.y: # down right
				show_bend = true
				bend_sprite.rotation_degrees = 90
			elif prev_pos.y > grid_pos.y and next_pos.x > grid_pos.x: # left down
				show_bend = true
				bend_sprite.rotation_degrees = 180
			elif prev_pos.x < grid_pos.x and next_pos.y < grid_pos.y: # down left
				show_bend = true
				bend_sprite.rotation_degrees = 0
			elif prev_pos.y < grid_pos.y and next_pos.x > grid_pos.x: # left up
				show_bend = true
				bend_sprite.rotation_degrees = 90
			elif prev_pos.x > grid_pos.x and next_pos.y > grid_pos.y: # up right
				show_bend = true
				bend_sprite.rotation_degrees = 180
			elif prev_pos.y > grid_pos.y and next_pos.x < grid_pos.x: # right down
				show_bend = true
				bend_sprite.rotation_degrees = -90
			
			if show_bend:
				segment_horizontal_sprite.visible = false
				segment_vertical_sprite.visible = false
				bend_sprite.visible = true


func update_head_rotation() -> void:
	match direction:
		Vector2i.LEFT:
			snake_head.rotation_degrees = 180
		Vector2i.RIGHT:
			snake_head.rotation_degrees = 0
		Vector2i.DOWN:
			snake_head.rotation_degrees = 90
		Vector2i.UP:
			snake_head.rotation_degrees = -90

func update_tail_rotation() -> void:
	var tail_direction = segment_positions[segment_positions.size() - 2] - segment_positions[segment_positions.size() - 1]
	match tail_direction:
		Vector2i.LEFT:
			snake_tail.rotation_degrees = 180
		Vector2i.RIGHT:
			snake_tail.rotation_degrees = 0
		Vector2i.DOWN:
			snake_tail.rotation_degrees = 90
		Vector2i.UP:
			snake_tail.rotation_degrees = -90
			
func grow_snake():
	var new_segment = snake_segment.instantiate()
	self.call_deferred("add_child", new_segment)
	var tail_position = segment_positions[segment_positions.size() - 1]
	var tail_direction = segment_positions[segment_positions.size() - 2] - tail_position
	segment_positions.append(tail_position - tail_direction)
	segments.insert(segments.size() - 1, new_segment)
	new_segment.self_collision.connect(_on_self_hit)


	
func die():
	_on_snake_died.emit()
	is_dying = true

func apple_eaten():
	self.call_deferred("grow_snake")
	update_snake_positions()
func _on_death_timer_timeout() -> void:
	queue_free()


func _on_snake_head_area_body_entered(_body: Node2D) -> void:
	print('dying')
	is_dying = true
	die()
	
func _on_self_hit():
	print('dying')
	is_dying = true
	die()
