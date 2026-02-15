extends Node
## 卡牌/库存管理器（Autoload）：管理玩家库存与商店刷新

const CardDataScript := preload("res://script/card/card_data.gd")
const Triggers := preload("res://script/triggers.gd")

const TETRIS_CARD: CardData = preload("res://card/tetris.tres")
const MOUNTAIN_TOP: CardData = preload("uid://bisaqnwcln5ys")

signal inventory_changed
signal gold_changed

signal triggered(trigger_condition: StringName, ctx: Dictionary)

const SHOP_SIZE: int = 4
const DEFAULT_GOLD: int = 100


var gold: int = DEFAULT_GOLD:
	set(v):
		gold = clampi(v, 0, 99999)
		gold_changed.emit()

var inventory: Array = []

## 已被选取过的奖励卡牌
var play_field : PlayField
var _rewarded_cards: Array = []


func _ready() -> void:
	play_field = get_node("/root/Arena/PlayField")
	_refresh_shop_items()


## 当前商店中出售的卡牌（每局/每次刷新）
var _shop_items: Array = []


func get_shop_items() -> Array:
	return _shop_items


func refresh_shop() -> void:
	_refresh_shop_items()


func _refresh_shop_items() -> void:
	_shop_items.clear()
	var pool := _get_card_pool()
	for i in SHOP_SIZE:
		if pool.is_empty():
			break
		var idx := randi() % pool.size()
		_shop_items.append(pool[idx])
		pool.remove_at(idx)


func _get_card_pool() -> Array:
	var list: Array = []
	list.append(TETRIS_CARD)
	list.append(MOUNTAIN_TOP)
	return list


func get_reward_pool() -> Array:
	# 奖励卡池：返回未被选取过的卡牌
	var full_pool = _get_card_pool()
	var available_pool = []
	
	# 过滤掉已被选取过的卡牌
	for card in full_pool:
		if not card in _rewarded_cards:
			available_pool.append(card)
	
	# 如果所有卡牌都已被选取过，返回空数组
	return available_pool




func buy_card(card) -> bool:
	if card.price > gold:
		return false
	if not card in _shop_items:
		return false
	gold -= card.price
	var idx := _shop_items.find(card)
	_shop_items.remove_at(idx)
	_grant_card_copy(card)
	return true


func grant_card(card) -> void:
	# 免费发放卡牌（不从商店移除，不扣钱）
	_grant_card_copy(card)
	# 将该卡牌添加到已被选取过的奖励卡牌数组中
	if not card in _rewarded_cards:
		_rewarded_cards.append(card)


func _grant_card_copy(card: CardData) -> void:
	# 使用 duplicate(true) 从 .tres 资源创建独立实例，避免共享同一 Resource
	var new_copy: CardData = card.duplicate(true)
	inventory.append(new_copy)
	inventory_changed.emit()


func add_gold(amount: int) -> void:
	gold += amount


func has_card_in_inventory(card_id: String) -> bool:
	for c in inventory:
		if c.id == card_id:
			return true
	return false


func trigger(trigger_condition: StringName, ctx: Dictionary) -> Dictionary:
	# 触发事件：先发信号（便于调试/接 UI），再执行匹配 trigger_condition 的卡牌效果
	triggered.emit(trigger_condition, ctx) #？

	
	# ctx 约定字段（按需扩展）：
	# - basic: int
	# - mult: int
	# - lines: int
	# - row: int
	for c in inventory:
		if c.trigger_condition != trigger_condition:
			#后期可以在这 发送 卡牌触发动画 的信号
			continue
		match c.effect_type:
			"plus_5_basic_score":
				ctx.basic = int(ctx.basic) + 5
			"detect_the_height_of_the_block_plus_the_basic_score":
				ctx.basic = int(ctx.basic) + PlayField.the_height_of_the_block
			"Humpback's_Song_effect":
				var arr = play_field.get_blocks_height_col() as Array
				play_field.settle_col_block(arr)
			_:
				pass
	return ctx
