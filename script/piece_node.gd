class_name PieceNode
extends Node2D

var cells: Array = [] # Array[Vector2i]
var grid_size: int = 40
var color: Color = Color.AQUA

func setup(_cells: Array, _grid_size: int, _color: Color) -> void:
	cells = _cells
	grid_size = _grid_size
	color = _color
	queue_redraw()

func _draw() -> void:
	for v in cells:
		var rect := Rect2(Vector2(v.x, v.y) * grid_size, Vector2(grid_size, grid_size)).grow(-2)
		draw_rect(rect, color)
