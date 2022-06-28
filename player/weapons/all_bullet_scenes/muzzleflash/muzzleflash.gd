extends AnimatedSprite

func _on_fuzzleflash_animation_finished():
	queue_free()
