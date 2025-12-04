
extends StaticBody2D

func _ready() -> void:
	$".".visible = false
	


func _process(delta: float) -> void:
	if $"../Player" and $"../Player".gems_amount >= $"../Player".WIN_GEMS_AMOUNT and not $".".visible:
		$".".visible = true
		$Area2D/CollisionShape2D.disabled = false
		print('i am exit')


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("Body entered: ", body)
	print('You Win! Exit game!')
	if body.get_name() == 'Player':
		body.queue_free()
		queue_free()
