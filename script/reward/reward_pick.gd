class_name RewardPick
extends PanelContainer

signal picked(card)
signal skipped
signal closed

const CARD_SLOT_SCENE := preload("res://scene/shop_card_slot.tscn")

@onready var title_label: Label = $MarginContainer/VBox/Title
@onready var cards_container: HBoxContainer = $MarginContainer/VBox/CardsContainer
@onready var skip_btn: Button = $MarginContainer/VBox/BtnRow/SkipBtn
@onready var close_btn: Button = $MarginContainer/VBox/BtnRow/CloseBtn

var _cards: Array = []

func _ready() -> void:
	title_label.text = "奖励选牌"
	skip_btn.text = "跳过"
	close_btn.text = "关闭"

	skip_btn.pressed.connect(_on_skip_pressed)
	close_btn.pressed.connect(_on_close_pressed)

	_refresh_ui()


func set_cards(cards: Array) -> void:
	_cards = cards
	if is_node_ready():
		_refresh_ui()


func _refresh_ui() -> void:
	if not is_node_ready():
		return

	for c in cards_container.get_children():
		c.queue_free()

	for card in _cards:
		var slot = CARD_SLOT_SCENE.instantiate()
		slot.set_card(card)
		# 奖励模式：隐藏价格，按钮改成“选取”
		slot.get_node("Margin/VBox/PriceLabel").visible = false
		slot.get_node("Margin/VBox/BuyBtn").text = "选取"
		# 注意：ShopCardSlot 的 buy_pressed 信号会发出它内部保存的 _card
		# 这里直接连到 RewardPick 的 picked 信号即可，避免 bind 外部 card 导致不一致
		slot.buy_pressed.connect(picked.emit)
		cards_container.add_child(slot)


func _on_pick_pressed(card) -> void:
	picked.emit(card)


func _on_skip_pressed() -> void:
	skipped.emit()


func _on_close_pressed() -> void:
	hide()
	closed.emit()
