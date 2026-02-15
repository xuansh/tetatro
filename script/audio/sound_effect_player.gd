extends AudioStreamPlayer

const 方块消除 = preload("uid://bty5mbkg7riuj")
const 放置 = preload("uid://k3fvw1dbaxui")
const 方块消除完毕 = preload("uid://yoh06w8i7nu5")


func play_sound(sound_effect_name : StringName):
	volume_db = 0.0
	pitch_scale = 1.0
	
	match sound_effect_name:
		"hard_drop":
			stream = 放置
			volume_db = 5.3
			pitch_scale = 0.78
			play()
		"single_block_cleared":
			stream = 方块消除
			pitch_scale = 0.6
			play()
		"finish_clear":
			stream = 方块消除完毕
			volume_db = 5
			pitch_scale = 0.6
			play()
		_:
			pass
