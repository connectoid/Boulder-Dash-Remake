extends CharacterBody2D

const TILE_SIZE = Vector2(16, 16)
var move_timer = Timer.new()
var MOVE_INTERVAL = 0.25
var window_size = Vector2.ZERO
var directions = [
	Vector2.RIGHT,
	Vector2.DOWN,
	Vector2.LEFT,
	Vector2.UP
]
var current_direction = 0


func _ready():
	update_window_size()
	add_child(move_timer)
	move_timer.wait_time = MOVE_INTERVAL
	move_timer.connect("timeout", _on_timer_timeout)
	move_timer.start()


func update_window_size():
	window_size = DisplayServer.screen_get_size()
	window_size = Vector2(256, 128)


func change_direction():
	current_direction += 1
	if current_direction >= directions.size():
		current_direction = 0

func second_change_direction():
	match current_direction:
		0:  # Правое направление (RIGHT)
			current_direction = 3  # Следующее направление: вниз (UP)
		1:  # Нижнее направление (DOWN)
			current_direction = 0  # Следующее направление: влево (RIGHT)
		2:  # Левое направление (LEFT)
			current_direction = 1  # Следующее направление: вверх (DOWN)
		3:  # Верхнее направление (UP)
			current_direction = 2  # Возвращаемся обратно вправо (LEFT)


func next_direction(direction):
	var index = directions.find(direction)  # Получаем индекс элемента
	return directions[(index + 1) % directions.size()]


func previos_direction(direction):
	var index = directions.find(direction)  # Получаем индекс элемента
	return directions[(index - 1 + directions.size()) % directions.size()]


func _physics_process(delta):
	if move_timer.is_stopped(): 
		var final_direction = directions[current_direction]
		var new_position = position + final_direction * TILE_SIZE
		if is_valid_position(new_position):
			var second_final_direction = second_change_direction()
			var second_new_position = new_position + final_direction * TILE_SIZE
			try_move(final_direction)
		else:
			change_direction()
				

func try_move(dir):
	dir = dir * TILE_SIZE
	var collision_result = move_and_collide(dir)
	if collision_result == null:
		move_timer.start()


func explode(pos):
	for y in range(-1, 2):
		for x in range(-1, 2):
			var expolde_position = Vector2(pos.x + (x*TILE_SIZE.x), pos.y + (y*TILE_SIZE.y))
			var objects = get_objects_in_pos(expolde_position)
			for object in objects:
				var collider = object.get('collider')
				if collider.name == 'GroundTileLayer':
					$"../Player".dig_ground(expolde_position)
				elif collider.get_class() == 'StaticBody2D':
					var tween = get_tree().create_tween()
					tween.tween_property(collider, "modulate:a", 0.0, 0.25)
					tween.tween_callback(collider.queue_free)
				else:
					collider.queue_free()



func die_and_explode(pos):
	print('BOOOOM!')
	explode(pos)
	velocity = Vector2.ZERO
	$CollisionShape2D.set_deferred('disabled', true)
	queue_free()


func get_object_classes_in_pos(pos):
	var direct_space_state = get_world_2d().direct_space_state
	var point_query = PhysicsPointQueryParameters2D.new()
	point_query.position = pos
	var objects = direct_space_state.intersect_point(point_query)
	var results = []
	for object in objects:
		results.append(object.collider.get_class())
	return results


func get_object_names_in_pos(pos):
	var direct_space_state = get_world_2d().direct_space_state
	var point_query = PhysicsPointQueryParameters2D.new()
	point_query.position = pos
	var objects = direct_space_state.intersect_point(point_query)
	var results = []
	for object in objects:
		results.append(object.collider.name.split('2D')[0] + '2D')
	return results


func get_objects_in_pos(pos):
	var direct_space_state = get_world_2d().direct_space_state
	var point_query = PhysicsPointQueryParameters2D.new()
	point_query.position = pos
	var objects = direct_space_state.intersect_point(point_query)
	return objects


func is_valid_position(pos):
	var denied_colliders_list = ['StaticBody2D', 'TileMapLayer', 'CharacterBody2D']
	var colliders = get_object_classes_in_pos(pos)
	for denied_collider in denied_colliders_list:
		if denied_collider in colliders:
			return false
	return pos.x >= 0 && pos.x <= window_size.x && pos.y >= 0 && pos.y <= window_size.y





func _on_timer_timeout():
	move_timer.stop()
