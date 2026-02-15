class_name MousePiecePreview
extends Node2D

var cells: Array = [] # Array[Vector2i]
var grid_size: int = 30
var color: Color = Color(0, 1, 1, 0.6)

func setup(piece_type: String, _grid_size: int = 30) -> void:
	grid_size = _grid_size
	cells = _get_shape(piece_type)
	queue_redraw()

func _process(_delta: float) -> void:
	position = get_global_mouse_position()

func _draw() -> void:
	for v in cells:
		var rect := Rect2(Vector2(v.x, v.y) * grid_size, Vector2(grid_size, grid_size)).grow(-2)
		draw_rect(rect, color)

func rotate_ccw() -> void:
	# (x, y) -> (-y, x)
	for i in range(cells.size()):
		var c: Vector2i = cells[i]
		cells[i] = Vector2i(-c.y, c.x)
	_normalize()
	queue_redraw()

func rotate_cw() -> void:
	# (x, y) -> (y, -x)
	for i in range(cells.size()):
		var c: Vector2i = cells[i]
		cells[i] = Vector2i(c.y, -c.x)
	_normalize()
	queue_redraw()

func _normalize() -> void:
	var min_x := 999999
	var min_y := 999999
	for c in cells:
		min_x = min(min_x, c.x)
		min_y = min(min_y, c.y)
	for i in range(cells.size()):
		var c: Vector2i = cells[i]
		cells[i] = Vector2i(c.x - min_x, c.y - min_y)

func get_cells() -> Array:
	return cells

func _get_shape(t: String) -> Array:
	match t:
		"I":
			return [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(3,0)]
		"O":
			return [Vector2i(0,0), Vector2i(1,0), Vector2i(0,1), Vector2i(1,1)]
		"T":
			return [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(1,1)]
		"L":
			return [Vector2i(0,0), Vector2i(0,1), Vector2i(0,2), Vector2i(1,2)]
		"J":
			return [Vector2i(1,0), Vector2i(1,1), Vector2i(1,2), Vector2i(0,2)]
		"S":
			return [Vector2i(1,0), Vector2i(2,0), Vector2i(0,1), Vector2i(1,1)]
		"Z":
			return [Vector2i(0,0), Vector2i(1,0), Vector2i(1,1), Vector2i(2,1)]
		_:
			return [Vector2i(0,0)]
