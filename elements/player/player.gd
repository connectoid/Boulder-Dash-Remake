extends CharacterBody2D

const TILE_SIZE = Vector2(16, 16)
var move_timer = Timer.new()
var MOVE_INTERVAL = 0.2
var window_size = Vector2.ZERO


func _ready():
	update_window_size()
	add_child(move_timer)
	move_timer.wait_time = MOVE_INTERVAL
	move_timer.connect("timeout", _on_timer_timeout)
	
	

func update_window_size():
	window_size = DisplayServer.screen_get_size()
	window_size = Vector2(256, 128)
	print(window_size)
	

func dig_ground(player_position):
	var tilemap = get_parent().get_node("GroundTileLayer")
	var ground_tiles = $"../GroundTileLayer"
	var cell_coords = tilemap.local_to_map(player_position)
	ground_tiles.erase_cell(cell_coords)
		



func _process(delta):
	pass

func _physics_process(delta):

	# Направления движения
	var horizontal_dir = Vector2.ZERO
	var vertical_dir = Vector2.ZERO

	var player_position = $".".global_position
	dig_ground(player_position)
	
	
		# Определение горизонтального направления
	if Input.is_action_pressed("ui_right"):  # Стрелка вправо
		horizontal_dir.x += 1
	elif Input.is_action_pressed("ui_left"):  # Стрелка влево
		horizontal_dir.x -= 1
	
	# Определение вертикального направления
	if Input.is_action_pressed("ui_down"):  # Стрелка вниз
		vertical_dir.y += 1
	elif Input.is_action_pressed("ui_up"):  # Стрелка вверх
		vertical_dir.y -= 1
	
	# Если оба направления активны, выбираем приоритетное (горизонтальное)
	if horizontal_dir != Vector2.ZERO && vertical_dir != Vector2.ZERO:
		vertical_dir = Vector2.ZERO
	
	# Объединяем финальное направление
	var final_direction = horizontal_dir + vertical_dir
	
	# Если есть ненулевое направление, пытаемся двинуть персонажа
	if final_direction.length_squared() > 0:
		if not move_timer.is_stopped(): 
			return  # Игнорируем повторные команды пока таймер запущен
		# Проверяем границы экрана перед движением
		var new_position = position + final_direction.normalized() * TILE_SIZE
		if is_valid_position(new_position):
			try_move(final_direction)
		if final_direction == Vector2(-1.0, 0.0):
			var collision_left = get_objects_in_pos(new_position)
			var collisionn_left = get_objectss_in_pos(new_position)
			if collision_left.has('StaticBody2D'):
				push_stone('left', collisionn_left[0].collider)
		if final_direction == Vector2(1.0, 0.0):
			var collision_right = get_objects_in_pos(new_position)
			var collisionn_right = get_objectss_in_pos(new_position)
			if collision_right.has('StaticBody2D'):
				push_stone('right', collisionn_right[0].collider)


func push_stone(dir, object):
	object.move_stone(dir)
	#object.position.x = object.position.x - TILE_SIZE.x
		
func get_objects_in_pos(pos):
	var direct_space_state = get_world_2d().direct_space_state
	var point_query = PhysicsPointQueryParameters2D.new()
	point_query.position = pos
	var objects = direct_space_state.intersect_point(point_query)
	var results = []
	for object in objects:
		results.append(object.collider.get_class())
	return results
	
		
func get_objectss_in_pos(pos):
	var direct_space_state = get_world_2d().direct_space_state
	var point_query = PhysicsPointQueryParameters2D.new()
	point_query.position = pos
	var objects = direct_space_state.intersect_point(point_query)
	var results = []
	return objects
	
		
func is_valid_position(pos):
	var colliders = get_objects_in_pos(pos)
	if 'StaticBody2D' in colliders:
		return false
	return pos.x >= 0 && pos.x <= window_size.x && pos.y >= 0 && pos.y <= window_size.y

func try_move(dir):
	# Масштабируем направление на размер тайла
	dir = dir.normalized() * TILE_SIZE
	
	# Пробуем двигать персонажа с учётом столкновений
	var collision_result = move_and_collide(dir)
	
	# Если нет результата столкновения, считаем ход завершённым
	if collision_result == null:
		move_timer.start()

func _on_timer_timeout():
	move_timer.stop()





func _on_dig_area_2d_area_entered(area: Area2D) -> void:
	print('Player collision', area.name)
