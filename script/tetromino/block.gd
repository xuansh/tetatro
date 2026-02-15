class_name Block 

var type: String
var color: String
var basic_score_per_block : int = 0
var texture: Texture2D

func _init(_type: String, _color: String, _texture: Texture2D = null) -> void:
	self.type = _type
	self.color = _color
	self.texture = _texture
	
