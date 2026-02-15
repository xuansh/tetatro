class_name Arena extends  Node2D

const REWARD_GRADES = {
	10: {"id": "reward_200"},
	50: {"id": "reward_500"},
	100: {"id": "reward_1000"},
	200: {"id": "reward_2000"},
	500: {"id": "reward_5000"}
}

# 记录各奖励档位的发放状态（替代原有单一的 _rewarded_200）
var reward_status = {
	"reward_200": false,
	"reward_500": false,
	"reward_1000": false,
	"reward_2000": false,
	"reward_5000": false
}

var total_score: int:
	set(value):
		total_score = value
		total_score_label.text = str(value)

var basic_score: int:
	set(value):
		basic_score = value
		basic_score_label.text = str(value)

var multiplier_score: int:
	set(value):
		multiplier_score = value
		multiplier_score_label.text = str(value)



@onready var play_field: PlayField = $PlayField

@onready var basic_score_label: Label = $CanvasLayer/UIRoot/Container/basicScore
@onready var multiplier_score_label: Label = $CanvasLayer/UIRoot/Container/multiplierScore
@onready var total_score_label: Label = $CanvasLayer/UIRoot/Container/totalScore


@onready var panel: Panel = $CanvasLayer/UIRoot/Panel
@onready var reason: Label = $CanvasLayer/UIRoot/Panel/VBoxContainer/Reason
@onready var active_piece: ActivePiece = $PlayField/ActivePiece
@onready var shop: Shop = $CanvasLayer/UIRoot/Shop
@onready var reward_pick: RewardPick = $CanvasLayer/UIRoot/RewardPick
@onready var inventory_field: InventoryField = $CanvasLayer/UIRoot/InventoryPanel/InventoryField

var _rewarded_200: bool = false
var _current_preview: MousePiecePreview = null
var _pending_rewards: Array = []
var _current_reward_index: int = 0

func _ready() -> void:
	
	play_field.cleared.connect(_on_playfield_cleared)
	active_piece.gameovered.connect(_on_gameovered)
	shop.closed.connect(_on_shop_closed)
	reward_pick.picked.connect(_on_reward_picked)
	reward_pick.skipped.connect(_on_reward_skipped)
	reward_pick.closed.connect(_on_reward_closed)
	# inventory 的变化不再自动生成方块到库存棋盘；后续由“预览块点击放置”来决定
	# CardManager.inventory_changed.connect(_on_inventory_changed)
	# _on_inventory_changed()


func _input(event: InputEvent) -> void:
	if _current_preview == null:
		return
	
	if event.is_action_pressed("rotation_left"):
		_current_preview.rotate_ccw()
		get_viewport().set_input_as_handled()
		return
	
	if event.is_action_pressed("rotation_right"):
		_current_preview.rotate_cw()
		get_viewport().set_input_as_handled()
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_try_place_preview()
		get_viewport().set_input_as_handled()
		return


func _try_place_preview() -> void:
	if _current_preview == null:
		return
	
	var origin := inventory_field.global_to_grid(_current_preview.global_position)
	var cells := _current_preview.get_cells()
	
	if inventory_field.place_preview(origin, cells, Color.AQUA):
		_current_preview.queue_free()
		_current_preview = null
		# 处理下一个奖励
		_process_next_reward()


func _on_playfield_cleared(t_score: int, t_basic: int, t_mult: int):
	total_score = t_score
	basic_score = t_basic
	multiplier_score = t_mult
	# 消行奖励金币，便于在商店购买卡牌
	GameData.score = t_score
	
	var sorted_grades = REWARD_GRADES.keys()
	sorted_grades.sort()
	
	# 收集所有达标的奖励档位
	var rewards_to_claim = []
	for score_threshold in sorted_grades:
		# 获取当前档位的奖励配置
		var reward_config = REWARD_GRADES[score_threshold]
		var reward_id = reward_config.id
		
		# 条件：分数达标 + 奖励未发放
		if total_score >= score_threshold and not reward_status[reward_id]:
			reward_status[reward_id] = true
			rewards_to_claim.append(reward_id)
	
	# 如果有新的奖励，添加到待处理奖励列表中
	if rewards_to_claim.size() > 0:
		_pending_rewards.append_array(rewards_to_claim)
		# 如果当前没有正在处理的奖励，开始处理
		if _current_reward_index == 0:
			_process_next_reward()


func _process_next_reward() -> void:
	# 检查是否有待处理的奖励
	if _pending_rewards.is_empty():
		# 没有待处理的奖励，重置索引并恢复游戏
		_current_reward_index = 0
		active_piece.fall_timer.start()
		get_tree().paused = false
		return
	
	# 处理下一个奖励
	_open_reward_pick()

func _open_reward_pick() -> void:
	# 停止active_piece的定时器，防止方块继续下落
	active_piece.fall_timer.stop()
	active_piece.move_timer.stop()
	active_piece.lock_delay_timer.stop()
	
	var cards = CardManager.get_reward_pool()
	# 如果奖励卡池为空，直接处理下一个奖励
	if cards.is_empty():
		_process_next_reward()
		return
	
	get_tree().paused = true
	reward_pick.set_cards(cards)
	reward_pick.show()


func _on_reward_picked(card) -> void:
	CardManager.grant_card(card)
	reward_pick.hide()
	# 不在这里立即取消暂停，等预览方块处理完再说
	
	# 移除当前处理的奖励
	if not _pending_rewards.is_empty():
		_pending_rewards.remove_at(0)
	
	# 创建跟随鼠标的预览方块
	if card.piece_type and not String(card.piece_type).is_empty():
		if _current_preview:
			_current_preview.queue_free()
		
		_current_preview = MousePiecePreview.new()
		$CanvasLayer/UIRoot.add_child(_current_preview)
		_current_preview.setup(String(card.piece_type), inventory_field.GRID_SIZE)
	else:
		# 如果卡牌没有方块属性，则处理下一个奖励
		_process_next_reward()

func _on_reward_skipped() -> void:
	reward_pick.hide()
	# 移除当前处理的奖励
	if not _pending_rewards.is_empty():
		_pending_rewards.remove_at(0)
	# 处理下一个奖励
	_process_next_reward()

func _on_reward_closed() -> void:
	reward_pick.hide()
	# 移除当前处理的奖励
	if not _pending_rewards.is_empty():
		_pending_rewards.remove_at(0)
	# 处理下一个奖励
	_process_next_reward()


func _on_gameovered(type: Global.GameOverType):
	get_tree().paused = true
	var reason_str: String
	match type:
		Global.GameOverType.OVERLAPPED:
			reason_str = '方块重叠'
		Global.GameOverType.OVERFLOW:
			reason_str = '方块溢出'
			
	reason.text = reason_str
	panel.show()


func _on_shop_btn_pressed() -> void:
	get_tree().paused = true
	shop.show()


func _on_shop_closed() -> void:
	get_tree().paused = false


func _on_inventory_changed() -> void:
	inventory_field.sync_from_inventory(CardManager.inventory)


func restart():
	get_tree().paused = false
	get_tree().reload_current_scene()
