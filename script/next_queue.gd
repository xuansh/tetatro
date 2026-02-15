class_name NextQueue extends Node2D

var randomizer: Randomizer = Randomizer.new()

# 预览 3 个
const CAPACITY = 3

const WIDTH = 6
const HIGHT = 10

var next_queue: Array[Tetromino] = []


func _init() -> void:
	for i in CAPACITY:
		next_queue.push_back(randomizer.provide())


func _draw() -> void:
	# 小丑牌风格：深紫底 + 青边
	var bg = Color(0.12, 0.05, 0.2, 0.95)
	var border = Color(0.35, 0.85, 1.0, 0.9)
	draw_rect(Rect2(0, - HIGHT * PlayField.CELL_WIDTH, \
		WIDTH * PlayField.CELL_WIDTH, HIGHT * PlayField.CELL_WIDTH), bg, true)
	draw_rect(Rect2(0, - HIGHT * PlayField.CELL_WIDTH, \
		WIDTH * PlayField.CELL_WIDTH, HIGHT * PlayField.CELL_WIDTH), border, false, 4)
	
	for i in next_queue.size():
		Global.draw_tetromino(self, next_queue[i], Vector2i(1, HIGHT - 2 - i * 3))


func provice() -> Tetromino:
	var next_piece = next_queue.pop_front()
	next_queue.push_back(randomizer.provide())
	queue_redraw()
	return next_piece
