extends Control

func _ready():
	# Start offscreen
	self.position.x = 3000


	var tween = create_tween()
	tween.tween_property(self, "position:x", 750, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
