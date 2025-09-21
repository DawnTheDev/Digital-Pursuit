extends ColorRect
func _ready():
	visible = false
	await get_tree().create_timer(4).timeout
	visible = true
	# Start offscreen
	self.position.x = 3000


	var tween = create_tween()
	tween.tween_property(self, "position:x", 700, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
