#
		#´´´´´´´´██´´´´´´´
		#´´´´´´´████´´´´´´
		#´´´´´████████´´´´
		#´´`´███▒▒▒▒███´´´´´
		#´´´███▒●▒▒●▒██´´´
		#´´´███▒▒▒▒▒▒██´´´´´
		#´´´███▒▒▒▒██´                      项目：Tetris + balantro
		#´´██████▒▒███´´´´´                 语言： gdscript
		#´██████▒▒▒▒███´´                   框架： godot
		#██████▒▒▒▒▒▒███´´´´                构建工具： godot
		#´´▓▓▓▓▓▓▓▓▓▓▓▓▓▒´´                 版本控制： git-github
		#´´▒▒▒▒▓▓▓▓▓▓▓▓▓▒´´´´´              css预处理: less
		#´.▒▒▒´´▓▓▓▓▓▓▓▓▒´´´´´              代码风格：eslint-standard
		#´.▒▒´´´´▓▓▓▓▓▓▓▒                   编辑器： godot
		#..▒▒.´´´´▓▓▓▓▓▓▓▒                  数据库:  mysql
		#´▒▒▒▒▒▒▒▒▒▒▒▒                     
		#´´´´´´´´´███████´´´´´              author: Koma
		#´´´´´´´´████████´´´´´´´
		#´´´´´´´█████████´´´´´´
		#´´´´´´██████████´´´´             大部分人都在关注你飞的高不高，却没人在乎你飞的累不累，这就是现实！
		#´´´´´´██████████´´´                     我从不相信梦想，我，只，相，信，自，己！
		#´´´´´´´█████████´´
		#´´´´´´´█████████´´´
		#´´´´´´´´████████´´´´´
		#________▒▒▒▒▒
		#_________▒▒▒▒
		#_________▒▒▒▒
		#________▒▒_▒▒
		#_______▒▒__▒▒
		#_____ ▒▒___▒▒
		#_____▒▒___▒▒
		#____▒▒____▒▒
		#___▒▒_____▒▒
		#███____ ▒▒
		#████____███
		#█ _███_ _█_███
#——————————————————————————女神保佑，代码无bug——————————————————————



@tool
class_name PlayField extends Node2D

const Triggers := preload("res://script/triggers.gd")
const Detect_Block := preload("res://script/Detect_Block.gd")
var spawn_text_font = preload("uid://dwtr25ajxnlhn")

# 音效播放器
@onready var sound_effect_player: AudioStreamPlayer = $"../Audio/SoundEffectPlayer"

# 音效资源
@onready var clear_sound: AudioStream = load("res://Audios/方块消除.mp3")


# 清了多少行
signal cleared(t_score: int, t_basic: int, t_mult: int)

## 格子大小
const CELL_WIDTH = 25
## 格子线宽
const CELL_line_WIDTH = 2

## 天花板 
## 1~20行 颜色较深的那一部分
const CEILING = 20
## 缓冲区大小 
## 顶上颜色较淡的那三行
const BUFFER_ZONE_HEIGHT = 3


## _playfield容器水平方向的大小。
const H_CAPACITY = 10
## _playfield容器垂直方向的大小。
const V_CAPACITY = CEILING + BUFFER_ZONE_HEIGHT


# 二维数组，存储方块（Block）信息。 数据类型是：Array[Array[Block]]
var _playfield = []
var tween_shaking : Tween

# 总分
var total_score: int = 0
var _effect_container: Node2D #用于存放显示加分的node
static var the_height_of_the_block: int = 0



func _init() -> void:
	#信號連接
	CardManager.triggered.connect(_on_trigger_conn)
	
	_effect_container = Node2D.new()
	_effect_container.name = "EffectContainer"
	add_child(_effect_container)

	
	_playfield.clear()
	for row in V_CAPACITY:
		
		var row_array = []
		for col in H_CAPACITY:
			row_array.append(null)
			
		_playfield.append(row_array)


func _draw() -> void:
	_draw_grid()
	_draw_blocks()


func _draw_grid():
	
	var l_to_r = H_CAPACITY * Vector2.RIGHT * CELL_WIDTH
	var b_to_t = CEILING * Vector2.UP * CELL_WIDTH
	
	var line_points:PackedVector2Array = PackedVector2Array()

	for i in H_CAPACITY + 1:
		var bottom_point = i * Vector2.RIGHT * CELL_WIDTH
		var top_point = bottom_point + b_to_t
		line_points.append(bottom_point)
		line_points.append(top_point)
	
	for i in CEILING + 1:
		var left_point = i * Vector2.UP * CELL_WIDTH
		var right_point = left_point + l_to_r
		line_points.append(left_point)
		line_points.append(right_point)
	
	
	var line_points_2:PackedVector2Array = PackedVector2Array()
	for i in H_CAPACITY + 1:
		var bottom_point = i * Vector2.RIGHT * CELL_WIDTH + b_to_t
		var top_point = bottom_point + BUFFER_ZONE_HEIGHT * Vector2.UP * CELL_WIDTH
		line_points_2.append(bottom_point)
		line_points_2.append(top_point)
	
	for i in BUFFER_ZONE_HEIGHT:
		var left_point = (i + CEILING + 1) * Vector2.UP * CELL_WIDTH
		var right_point = left_point + l_to_r
		line_points_2.append(left_point)
		line_points_2.append(right_point)


## 绘制场地中的方块（Block）
func _draw_blocks() -> void:
	for row in _playfield.size():
		for col in _playfield[row].size():
			var block = _playfield[row][col]
			if block == null:
				continue
			var rect = Rect2(col * CELL_WIDTH, (row + 1) * -CELL_WIDTH, CELL_WIDTH, CELL_WIDTH)
			if block.texture:
				draw_texture_rect(block.texture, rect, false)


## 将给定方块正式添加入场地中。在此之前活动砖块只作显示，并未加入二维数组_playfield中。
func add_blocks(tetromino: Tetromino, coordinates: Vector2i) -> void:
	var blocks = tetromino.get_blocks()
	for row in blocks.size():
		for col in blocks[row].size():
			if (blocks[row][col]):
				_playfield[coordinates.y - row][coordinates.x + col] = Block.new(tetromino.TYPE, tetromino.COLOR, tetromino.TEXTURE)
	
	# 立即重绘，确保活动块消失和棋盘显示无缝衔接
	queue_redraw()
	
	await clear(tetromino, coordinates)
	the_height_of_the_block = get_blocks_height_range()
	queue_redraw()


# 判断给定砖块是否会与场地中已有的方块（Block）重叠。
func is_overlap(tetromino: Tetromino, coordinates: Vector2i) -> bool:
	var blocks = tetromino.get_blocks()
	for row in blocks.size():
		for col in blocks[row].size():
			if (blocks[row][col]):
				var i = coordinates.x + col
				var j = coordinates.y - row
				var rect = Rect2i(0, 0, H_CAPACITY, V_CAPACITY)
				if rect.has_point(Vector2i(i, j)):
					if _playfield[j][i] != null:
						return true
				else:
					return true
	return false

#region clearer

## 开始做消行工作
func clear(_tetromino: Tetromino, _coordinates: Vector2i):
	var current_session_basic : int = 0
	var current_session_mult : int = 0 
	
	var rows_to_clear = []
	for y in range(V_CAPACITY):
		if _playfield[y].all(func(element): return element != null):
			rows_to_clear.append(y)
	
	if rows_to_clear.is_empty():
		return

	rows_to_clear.sort()
	
	# 让卡牌在“消行结算前”修改本次初始 basic/mult
	# 此时基础分还未统计砖块，为 0
	var before_clear_ctx := {
		"basic": current_session_basic,
		"mult": current_session_mult,
		"lines": rows_to_clear.size()
	}
	before_clear_ctx = CardManager.trigger(Triggers.BEFORE_CLEAR, before_clear_ctx)
	current_session_basic = int(before_clear_ctx.basic)
	current_session_mult = int(before_clear_ctx.mult)
	
	# 发射初始信号（例如显示卡牌带来的保底分）
	cleared.emit(total_score, current_session_basic, current_session_mult)
	
	# 记录总共要消除多少行（连消数）
	var total_lines = rows_to_clear.size()
	
	# 规则调整：先按“连消行数”一次性增加倍率（而不是逐行 +1）
	current_session_mult = GameLogic.add_multiplier(current_session_mult, total_lines)
	
	# 数行特效：先查出所有能消的行后，一次性在每行左侧显示 +1（蓝色）
	for row in rows_to_clear:
		_spawn_line_count_effect(row, "+1")
	
	# 再进行消除操作：逐行逐列做动画（不再在动画中计算基础分）
	var cleared_basic_so_far := current_session_basic
	for i in range(total_lines):
		var row = rows_to_clear[i]
		var row_basic := _calc_row_basic(row)
		await line_clear_animation(row, current_session_mult, cleared_basic_so_far)
		cleared_basic_so_far += row_basic
		
		# 触发条件：每消除完一行（line_cleared）
		var line_ctx := {
			"basic": cleared_basic_so_far,
			"mult": current_session_mult,
			"lines": total_lines,
			"row": row
		}
		line_ctx = CardManager.trigger(Triggers.LINE_CLEARED, line_ctx)
		cleared_basic_so_far = int(line_ctx.basic)
		current_session_basic = cleared_basic_so_far
		current_session_mult = int(line_ctx.mult)
		
		# 行与行之间强制同步一次 UI，避免下一行开始时基础分显示回到 0
		cleared.emit(total_score, current_session_basic, current_session_mult)
	
	CardManager.trigger(Triggers.FINISH_CLEAR, Dictionary())
	
	# 【改动】所有动画播放完后，一次性移除所有满行并下移
	rows_to_clear.sort()
	rows_to_clear.reverse()  # 从下往上删除，避免索引错乱
	for row in rows_to_clear:
		_playfield.remove_at(row)
	
	# 在顶部补充相应数量的空行
	for i in range(total_lines):
		var new_empty_row = []
		new_empty_row.resize(H_CAPACITY)
		new_empty_row.fill(null)
		_playfield.push_back(new_empty_row)
		
	
	
	# 整个消除序列完成后，先停顿一下让玩家看清本次基础值/倍率
	await get_tree().create_timer(0.6).timeout
	
	# 结算总分
	var final_b = GameLogic.add_basic_score(0, current_session_basic)
	var final_m = GameLogic.add_multiplier(0, current_session_mult)
	total_score += GameLogic.calculate_final_score(final_b, final_m)
	cleared.emit(total_score, 0, 0)
	
	for child in _effect_container.get_children(): #清除+1提示
		child.queue_free()
	queue_redraw()

## 【改名】播放某一行的消除动画（不移除行）
func line_clear_animation(row: int, current_m: int, cleared_basic_before_row: int) -> void:
	
	var current_row_blocks = _playfield[row]
	
	# 再进行消除操作：逐列播放动画、飘字，并把格子置空
	# 注意：本次基础分/数行特效已经在 clear() 的“先查所有行”阶段完成
	var cleared_basic_in_this_row := 0
	for col in H_CAPACITY:
		var block = current_row_blocks[col]
		if block:
			# 使用Detect_Block检测方块类型并计算加分
			var block_score = Detect_Block.detect_and_add_score(block)
			cleared_basic_in_this_row += block_score
			_spawn_floating_score(col, row, "+" + str(block_score))
			
			# 计算实时全场总数据：按“已消除的砖块”逐步增加
			# cleared_basic_before_row 是上一行结算后的累计基础分（包含卡牌加成）
			var gained_basic = cleared_basic_before_row + cleared_basic_in_this_row
			var realtime_basic = gained_basic
			var realtime_mult = current_m
			# UI 展示（方案A）：总分保持不变，本次消行的得分只体现在 basic/mult 上
			# 总分会在 clear() 全部结束后一次性结算增加
			cleared.emit(total_score, realtime_basic, realtime_mult)
			
			# 执行消除（逐格动画）：先等待一小段时间再置空，避免一开始就闪没
			await get_tree().create_timer(0.1).timeout
			_playfield[row][col] = null
			print(block.type)
			CardManager.trigger(Triggers.SINGLE_BLOCK_CLEARED, {"block_type": block.type, "block_score": block_score})
			queue_redraw()
			continue
		
		await get_tree().create_timer(0.1).timeout
		queue_redraw()
	
#endregion

func _calc_row_basic(row: int) -> int:
	var sum := 0
	var current_row_blocks = _playfield[row]
	for col in H_CAPACITY:
		var block = current_row_blocks[col]
		if block:
			# 使用Detect_Block检测方块类型并计算加分
			sum += Detect_Block.detect_and_add_score(block)
	return sum

#region effect_spawner

func _spawn_line_count_effect(row: int, text_content: String) -> void:
	var label = Label.new()
	label.text = text_content
	label.add_theme_font_override("font", spawn_text_font)
	label.add_theme_font_size_override("font_size", 22)
	label.modulate = Color(0.4, 0.85, 1.0)
	
	# 放在消除行的左边
	var spawn_pos = Vector2(-CELL_WIDTH, (row + 1) * -CELL_WIDTH)
	label.position = spawn_pos
	
	label.set_script(load("res://FloatingText.gd"))
	_effect_container.add_child(label)

	
func _spawn_floating_score(col: int, row: int, text_content: String):
	var label = Label.new()
	label.text = text_content
	label.add_theme_font_override("font", spawn_text_font)
	label.add_theme_font_size_override("font_size", 20)
	label.modulate = Color.YELLOW
	
	# 使用你原本的坐标逻辑 
	var spawn_pos = Vector2(col * CELL_WIDTH, (row + 1) * -CELL_WIDTH)
	label.position = spawn_pos
	
	# 加载脚本处理自身的向上飘动和自动销毁
	label.set_script(load("res://FloatingText.gd"))
	
	# 添加到特效容器中
	_effect_container.add_child(label)

#endregion

func playfield_shaking():
	if tween_shaking and tween_shaking.is_valid() and tween_shaking.is_running():
		return
	
	var original_position_y = self.position.y
	tween_shaking = create_tween()
	tween_shaking.tween_method(
		func(v):
			var offset = spring_pulse(v, 5.5, 2)
			self.position.y += offset
	, 0.0, 1.0, 0.1).set_trans(Tween.TRANS_LINEAR)
	tween_shaking.chain().tween_property(self, "position:y", original_position_y, 0.1)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_IN_OUT)

# t: 当前进度 (0 到 1)
# intensity: 震动强度 (最高点的高度)
# frequency: 震动频率 (抖动的次数)
func spring_pulse(t: float, intensity: float = 0.5, frequency: float = 10.0) -> float:
	if t >= 1.0: return 0.0
	var decay = exp(-5.0 * t)
	var oscillation = sin(t * frequency * PI)
	return intensity * decay * oscillation

#region getter

## 计算当前地图中有方块的最高层到最低层的层数
## 返回值：有方块的层数，如果没有方块则返回0
func get_blocks_height_range() -> int:
	var highest_layer = -1  # 最高层索引（0-22），-1表示没有方块
	var lowest_layer = V_CAPACITY  # 最低层索引（0-22），V_CAPACITY表示没有方块
	
	# 遍历每一行，检查是否有方块
	for row in range(V_CAPACITY):
		for col in range(H_CAPACITY):
			if _playfield[row][col] != null:
				# 找到有方块的行，更新最高层和最低层
				if row > highest_layer:
					highest_layer = row
				if row < lowest_layer:
					lowest_layer = row
				# 一行中只要有一个方块就可以了，不需要检查其他列
				break
	
	# 检查是否有方块
	if highest_layer == -1 or lowest_layer == V_CAPACITY:
		return 0
	
	# 计算层数（包含两端）
	return highest_layer - lowest_layer + 1

## 获取所有最高的列的索引 返回Array
func get_blocks_height_col() -> Array:
	var highest_layer = -1  # 最高层行索引（0-22），-1表示没有方块
	var highest_cols = []   # 存储最高层所有有方块的列索引
	
	# 先找到有方块的最高层（最顶部）行索引
	# 从最顶部（行索引0）往下遍历，找到第一个有方块的行
	for row in range(V_CAPACITY):
		for col in range(H_CAPACITY):
			if _playfield[row][col] != null:
				highest_layer = row
				break 
		if highest_layer != -1:
			break
	
	if highest_layer == -1:
		return highest_cols
	
	# 遍历最高层的所有列，收集所有有方块的列索引
	for col in range(H_CAPACITY):
		if _playfield[highest_layer][col] != null:
			highest_cols.append(col)
	
	return highest_cols

## 获取给定砖块在场地中幽灵砖块处的坐标
func get_lock_position(tetromino: Tetromino, start_coordinates: Vector2i) -> Vector2i:
	# I型方块从第23行到第1行需要移动22次。
	# 在下面代码中第一次循环其实是原地判定，所以对于I型移动22次则需要循环23次
	for i in V_CAPACITY + 1:
		if is_overlap(tetromino, start_coordinates + i * Coordinates.DOWN):
			if i == 0:
				break
				
			return start_coordinates + (i - 1) * Coordinates.DOWN
	return start_coordinates

#endregion	

#region settler

# 结算指定列的得分（仅加分，不消除/沉降方块）
# 参数 cols：需要结算得分的列索引数组（如 [1,3,5]）
func settle_col_block(cols : Array) -> void:
	# 边界检查：空数组直接返回
	if cols.is_empty():
		print("settle_col_block: 传入的列数组为空，无需结算")
		return
	
	# 累计本次列结算的基础分（用于实时UI更新）
	var total_col_basic_score = 0
	# 当前倍数（复用你现有逻辑的倍数变量，若需动态获取可调整）
	var current_m = 1  # 替换为你实际的倍数变量（比如从clear()中传入）
	
	# 遍历每一列进行加分结算
	for col in cols:
		# 列索引越界检查
		if col < 0 or col >= H_CAPACITY:
			print("settle_col_block: 列索引", col, "越界（0-", H_CAPACITY-1, "），跳过")
			continue
		
		# 该列的累计加分
		var col_basic_score = 0
		
		# ===================== 核心：遍历列内所有方块，计算得分 =====================
		for row in range(V_CAPACITY):
			var block = _playfield[row][col]
			if block:
				# 复用你现有的方块得分逻辑
				var block_score = Detect_Block.detect_and_add_score(block)
				col_basic_score += block_score
				total_col_basic_score += block_score
				
				# 飘字提示（和你消行逻辑一致的位置）
				_spawn_floating_score(col, row, "+" + str(block_score))
				
				# 触发卡牌事件（仅通知“列方块加分”，不做其他操作）
				CardManager.trigger(Triggers.SINGLE_BLOCK_CLEARED, {"block_type": block.type, "block_score": block_score})
				
				# 实时发射结算信号，更新UI（和你line_clear_animation逻辑一致）
				cleared.emit(total_score, total_col_basic_score, current_m)
				
				# 逐方块动画延迟（保持和你消行动画一致的节奏）
				await get_tree().create_timer(0.1).timeout
				queue_redraw()
		
		# 列结算完成日志（调试用）
		print("settle_col_block: 列", col, "加分完成，累计+", col_basic_score, "基础分")
		
		# 列之间的动画间隔
		await get_tree().create_timer(0.05).timeout
		queue_redraw()
	
	# 所有列结算完成
	print("settle_col_block: 所有列加分完成，总基础分+", total_col_basic_score)

func setlle_row_block(rows : Array):
	pass
	
#endregion

func _on_trigger_conn(trigger_condition : StringName, ctx : Dictionary):
	match trigger_condition:
		"hard_drop":
			sound_effect_player.play_sound(trigger_condition)
			playfield_shaking()
		"single_block_cleared":
			sound_effect_player.play_sound(trigger_condition) #后期可以加点屏幕抖动
		"finish_clear":
			sound_effect_player.play_sound(trigger_condition)
		_:
			pass
