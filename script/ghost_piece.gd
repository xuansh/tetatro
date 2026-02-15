class_name GhostPiece extends Node2D

@export var _playfield: PlayField
@export var _entity: ActivePiece

func _ready() -> void:
	_entity.coordinatesChanged.connect(func ():queue_redraw())


func _draw() -> void:
	var coordinate = _playfield.get_lock_position(_entity.tetromino, _entity.coordinates)
	if coordinate == _entity.coordinates:
		return

	Global.draw_tetromino(self, _entity.tetromino, coordinate)
	
