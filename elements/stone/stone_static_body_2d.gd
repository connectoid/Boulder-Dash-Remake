extends StaticBody2D


const TILE_SIZE = Vector2(16, 16)
var window_size = Vector2.ZERO

func _ready():
	update_window_size()
	
	

func update_window_size():
	window_size = DisplayServer.screen_get_size()
	window_size = Vector2(256, 128)


func _process(delta):
	var vertical_dir = Vector2.ZERO
	var horizontal_dir = Vector2.ZERO
	vertical_dir.y = 1
	horizontal_dir.x = -1
	var final_direction = vertical_dir
	var new_position = position + vertical_dir.normalized() * TILE_SIZE
	#if vertical_dir.length_squared() > 0 && is_valid_position(new_position):
	if is_no_colliders(new_position) && is_no_walls(new_position):
		vertical_dir.y += 1
		new_position = position + vertical_dir.normalized() * TILE_SIZE
		position = new_position
	if not is_no_colliders(position) && is_no_walls(position):
		if can_rolldown(position) == 'left':
			new_position = position + horizontal_dir.normalized() * TILE_SIZE
			position = new_position
		elif can_rolldown(position) == 'right': 
			new_position = position - horizontal_dir.normalized() * TILE_SIZE
			position = new_position

	#try_move(final_direction)


func get_objects_in_pos(pos):
	var direct_space_state = get_world_2d().direct_space_state
	var point_query = PhysicsPointQueryParameters2D.new()
	point_query.position = pos
	var objects = direct_space_state.intersect_point(point_query)
	var results = []
	for object in objects:
		results.append(object.collider.get_class())
	return results


func comape_lists(source_list, dest_list):
	# Проверяет есть ли вхождение любого элемента списка source_list
	# в список dest_list. Если есть, то возвращает true, иначе false
	for item in source_list:
		if dest_list.has(item):
			return true
	return false



func can_rolldown(pos):
	var denied_colliders_list = ['StaticBody2D', 'TileMapLayer', 'CharacterBody2D']
	var pos_below_aside_left = Vector2(pos.x - TILE_SIZE.x, pos.y + TILE_SIZE.y)
	var pos_below_aside_right = Vector2(pos.x + TILE_SIZE.x, pos.y + TILE_SIZE.y)
	var pos_below = Vector2(pos.x, pos.y + TILE_SIZE.y)
	var pos_aside_left = Vector2(pos.x - TILE_SIZE.x, pos.y)
	var pos_aside_right = Vector2(pos.x + TILE_SIZE.x, pos.y)
	var collisions_below_aside_left = get_objects_in_pos(pos_below_aside_left)
	var collisions_below_aside_right = get_objects_in_pos(pos_below_aside_right)
	var collisions_below = get_objects_in_pos(pos_below)
	var collisions_aside_left = get_objects_in_pos(pos_aside_left)
	var collisions_aside_right = get_objects_in_pos(pos_aside_right)
	var is_empty_below_aside_left = not comape_lists(collisions_below_aside_left, denied_colliders_list)
	var is_empty_below_aside_right = not comape_lists(collisions_below_aside_right, denied_colliders_list)
	var is_stone_below = comape_lists(collisions_below, ['StaticBody2D'])
	var is_player_aside_left = comape_lists(collisions_aside_left, ['CharacterBody2D', 'TileMapLayer'])
	var is_player_aside_right = comape_lists(collisions_aside_right, ['CharacterBody2D', 'TileMapLayer'])
	if is_empty_below_aside_left && is_stone_below && not is_player_aside_left:
		return 'left'
	elif is_empty_below_aside_right && is_stone_below && not is_player_aside_right:
		return 'right'
	return 'no'

func is_no_colliders(pos):
	var denied_colliders_list = ['StaticBody2D', 'TileMapLayer', 'CharacterBody2D']
	var colliders_list = get_objects_in_pos(pos)
	return not comape_lists(colliders_list, denied_colliders_list)


func is_no_walls(pos):
	var is_valid = pos.x >= 0 && pos.x <= window_size.x && pos.y >= 0 && pos.y <= window_size.y
	return is_valid

func try_move(dir):
	# Масштабируем направление на размер тайла
	dir = dir.normalized() * TILE_SIZE
	
	# Пробуем двигать персонажа с учётом столкновений
	var collision_result = move_and_collide(dir)
	
	# Если нет результата столкновения, считаем ход завершённым
