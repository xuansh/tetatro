extends Label

func _ready():
	# 创建一个简单的动画：向上飘移并变透明
	var tween = create_tween()
	tween.set_parallel(true)
	# 向上移动 40 像素
	tween.tween_property(self, "position", position + Vector2.UP * 40, 0.6)
	# 渐隐
	tween.tween_property(self, "modulate:a", 0.0, 0.6)
	# 播放完后销毁自己
	tween.set_parallel(false)
	tween.tween_callback(queue_free)
