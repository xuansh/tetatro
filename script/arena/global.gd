class_name Global extends Object

enum GameOverType {
	OVERLAPPED, ## 方块重叠
	OVERFLOW, ## 方块溢出
}

static func draw_tetromino(canvas_item: CanvasItem, tetromino, 
	coordinates: Vector2i = Vector2i.ZERO) -> void:
	
	var blocks = tetromino.get_blocks()
	for row in blocks.size():
		for col in blocks[row].size():
			if (blocks[row][col]):
				var l_t_point = Vector2(col + coordinates.x, -row + 1 + coordinates.y) \
					* Vector2(PlayField.CELL_WIDTH, -PlayField.CELL_WIDTH)
				var size = Vector2(PlayField.CELL_WIDTH, PlayField.CELL_WIDTH)
				var rect = Rect2(l_t_point, size)
				if tetromino and "TEXTURE" in tetromino and tetromino.TEXTURE:
					canvas_item.draw_texture_rect(tetromino.TEXTURE, rect, false)
