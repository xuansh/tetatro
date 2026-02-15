class_name InventoryField
extends Node2D

const GRID_SIZE := 30
const SIZE := 8

@onready var piece_layer: Node2D = Node2D.new()
var occupied: PackedByteArray = PackedByteArray()
var card_id_to_piece: Dictionary = {}

func _ready() -> void:
	add_child(piece_layer)
	piece_layer.name = "PieceLayer"
	occupied.resize(SIZE * SIZE)
	for i in SIZE * SIZE:
		occupied[i] = 0
	queue_redraw()

func _draw() -> void:
	var c := Color(1, 1, 1, 0.15)
	for i in SIZE + 1:
		draw_line(Vector2(i * GRID_SIZE, 0), Vector2(i * GRID_SIZE, SIZE * GRID_SIZE), c, 1)
		draw_line(Vector2(0, i * GRID_SIZE), Vector2(SIZE * GRID_SIZE, i * GRID_SIZE), c, 1)

func sync_from_inventory(cards: Array) -> void:
	for card in cards:
		var pt: String = String(card.piece_type)
		if pt.is_empty():
			continue
		if card_id_to_piece.has(card.id):
			continue
		add_piece_from_card(card)

func add_piece_from_card(card) -> void:
	var shape: Array = _get_shape(String(card.piece_type))
	var pos: Vector2i = _first_fit(shape)
	if pos == Vector2i(-1, -1):
		# TODO: temp pile
		return
	for cell in shape:
		var p: Vector2i = pos + cell
		_set_occupied(p, true)
	var piece := Node2D.new()
	piece.position = Vector2(pos) * GRID_SIZE
	piece.name = str(card.id)
	piece.set_meta("card_id", card.id)
	piece.set_meta("piece_type", String(card.piece_type))
	piece.set_script(load("res://script/piece_node.gd"))
	piece.call("setup", shape, GRID_SIZE, Color.AQUA)
	piece_layer.add_child(piece)
	card_id_to_piece[card.id] = piece

func can_place_at(origin: Vector2i, cells: Array) -> bool:
	for cell in cells:
		var p: Vector2i = origin + cell
		if p.x < 0 or p.x >= SIZE or p.y < 0 or p.y >= SIZE:
			return false
		if _is_occupied(p):
			return false
	return true

func place_preview(origin: Vector2i, cells: Array, color: Color = Color.AQUA) -> bool:
	if not can_place_at(origin, cells):
		return false
	for cell in cells:
		_set_occupied(origin + cell, true)
	var piece := Node2D.new()
	piece.position = Vector2(origin) * GRID_SIZE
	piece.set_script(load("res://script/piece_node.gd"))
	piece.call("setup", cells, GRID_SIZE, color)
	piece_layer.add_child(piece)
	return true

func global_to_grid(global_pos: Vector2) -> Vector2i:
	var local_pos := to_local(global_pos)
	return Vector2i(floor(local_pos.x / GRID_SIZE), floor(local_pos.y / GRID_SIZE))

func _first_fit(shape: Array) -> Vector2i:
	for y in SIZE:
		for x in SIZE:
			var ok := true
			for cell in shape:
				var p: Vector2i = Vector2i(x, y) + cell
				if p.x < 0 or p.x >= SIZE or p.y < 0 or p.y >= SIZE:
					ok = false
					break
				if _is_occupied(p):
					ok = false
					break
			if ok:
				return Vector2i(x, y)
	return Vector2i(-1, -1)

func _idx(p: Vector2i) -> int:
	return p.y * SIZE + p.x

func _is_occupied(p: Vector2i) -> bool:
	return occupied[_idx(p)] != 0

func _set_occupied(p: Vector2i, v: bool) -> void:
	occupied[_idx(p)] = 1 if v else 0

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
