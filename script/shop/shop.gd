class_name Shop
extends PanelContainer
## 商店 UI：显示金币、商店卡牌列表，处理购买

const CARD_SLOT_SCENE := preload("res://scene/shop_card_slot.tscn")
const CardData = preload("res://script/card/card_data.gd")

signal closed

@onready var title_label: Label = $MarginContainer/VBox/Title
@onready var gold_label: Label = $MarginContainer/VBox/GoldRow/GoldLabel
@onready var cards_container: HBoxContainer = $MarginContainer/VBox/CardsContainer
@onready var refresh_btn: Button = $MarginContainer/VBox/BtnRow/RefreshBtn
@onready var close_btn: Button = $MarginContainer/VBox/BtnRow/CloseBtn


func _ready() -> void:
	title_label.text = "商店"
	_refresh_ui()
	CardManager.gold_changed.connect(_on_gold_changed)
	CardManager.inventory_changed.connect(_on_inventory_changed)
	refresh_btn.pressed.connect(_on_refresh_pressed)
	refresh_btn.text = "刷新"
	close_btn.pressed.connect(_on_close_pressed)
	close_btn.text = "关闭"


func _refresh_ui() -> void:
	gold_label.text = "金币: %d" % CardManager.gold
	_build_card_slots()


func _build_card_slots() -> void:
	for c in cards_container.get_children():
		c.queue_free()
	for card in CardManager.get_shop_items():
		var slot := CARD_SLOT_SCENE.instantiate()
		slot.set_card(card)
		slot.buy_pressed.connect(_on_buy_pressed.bind(card))
		cards_container.add_child(slot)


func _on_buy_pressed(card) -> void:
	if CardManager.buy_card(card):
		_refresh_ui()


func _on_gold_changed() -> void:
	gold_label.text = "金币: %d" % CardManager.gold


func _on_inventory_changed() -> void:
	_refresh_ui()


func _on_refresh_pressed() -> void:
	CardManager.refresh_shop()
	_refresh_ui()


func _on_close_pressed() -> void:
	hide()
	closed.emit()
