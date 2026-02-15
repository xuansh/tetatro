class_name HoldPiece extends Node2D

const WiDTH = 6
const HIGHT = 4

var is_ghost = false

var hold_piece: Tetromino


func hold(tetromino: Tetromino) -> Tetromino:
	var temp = hold_piece
	hold_piece = tetromino
	hold_piece.orientation = 0
	is_ghost = true
	queue_redraw()
	return temp

func ghost(enable: bool):
	is_ghost = enable
	queue_redraw()

func _draw() -> void:
	# 小丑牌风格：深紫底 + 青边
	var bg = Color(0.12, 0.05, 0.2, 0.95)
	var border = Color(0.35, 0.85, 1.0, 0.9)
	draw_rect(Rect2(0, 0, WiDTH * PlayField.CELL_WIDTH, HIGHT * PlayField.CELL_WIDTH), bg, true)
	draw_rect(Rect2(0, 0, WiDTH * PlayField.CELL_WIDTH, HIGHT * PlayField.CELL_WIDTH), border, false, 4)
	
	if hold_piece != null:
		var color: Color = hold_piece.COLOR
		if is_ghost:
			color.a = 0.3
			
		Global.draw_tetromino(self, hold_piece, Vector2i(1, -2))
