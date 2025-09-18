extends TextureButton


func _ready():
	# Start offscreen
	self.position.x = -3000


	var tween = create_tween()
	tween.tween_property(self, "position:x", 20, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
