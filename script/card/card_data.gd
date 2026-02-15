class_name CardData
extends Resource
## 卡牌数据结构：用于商店与库存的卡牌定义

@export var id: String = ""
@export var card_name: String = ""
@export var description: String = ""
@export var price: int = 0
@export var rarity: int = 0  ## 0=COMMON, 1=UNCOMMON, 2=RARE, 3=LEGENDARY
@export var effect_type: String = ""  ## 效果类型，后续可扩展（如加分、消行等）
@export var trigger_condition: StringName = &""
@export var piece_type: StringName = &""  ## "T"/"O"/"I"/"Z"/"S"/"L"/"J"
@export var texture: Texture2D

enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	LEGENDARY
}

static func get_rarity_color(r: int) -> Color:
	match r:
		Rarity.COMMON: return Color(0.7, 0.7, 0.7)
		Rarity.UNCOMMON: return Color(0.3, 0.8, 0.3)
		Rarity.RARE: return Color(0.3, 0.5, 1.0)
		Rarity.LEGENDARY: return Color(1.0, 0.6, 0.0)
		_: return Color.WHITE

static func get_rarity_name(r: int) -> String:
	match r:
		Rarity.COMMON: return "普通"
		Rarity.UNCOMMON: return "优秀"
		Rarity.RARE: return "稀有"
		Rarity.LEGENDARY: return "传说"
		_: return ""

func _to_string() -> String:
	return "CardData(%s,%s,%d)" % [id, card_name, price]
