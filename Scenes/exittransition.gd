extends Control

func _ready():
	# Start offscreen
	visible = false
	await get_tree().create_timer(4).timeout
	visible = true
	self.position.x = 3000


	var tween = create_tween()
	tween.tween_property(self, "position:x", 750, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
