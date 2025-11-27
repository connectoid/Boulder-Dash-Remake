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
	vertical_dir.y = 1
	var final_direction = vertical_dir
	var new_position = position + vertical_dir.normalized() * TILE_SIZE
	#if vertical_dir.length_squared() > 0 && is_valid_position(new_position):
	if is_no_colliders(new_position) && is_no_walls(new_position):
		vertical_dir.y += 1
		new_position = position + vertical_dir.normalized() * TILE_SIZE
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


func is_no_colliders(pos):
	var colliders_list = ['StaticBody2D', 'TileMapLayer', 'CharacterBody2D']
	var denied_colliders_list = get_objects_in_pos(pos)
	for collider in colliders_list:
		if denied_colliders_list.has(collider):
			return false
	return true

func is_no_walls(pos):
	var is_valid = pos.x >= 0 && pos.x <= window_size.x && pos.y >= 0 && pos.y <= window_size.y
	return is_valid

func try_move(dir):
	# Масштабируем направление на размер тайла
	dir = dir.normalized() * TILE_SIZE
	
	# Пробуем двигать персонажа с учётом столкновений
	var collision_result = move_and_collide(dir)
	
	# Если нет результата столкновения, считаем ход завершённым
