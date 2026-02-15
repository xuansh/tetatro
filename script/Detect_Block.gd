class_name Detect_Block extends RefCounted


## 检测方块类型并返回加分
static func detect_and_add_score(block : Block) -> int:
	if not block:
		return 0
	
	var score : int
	match block.type:
		"normal":
			score = GameData.get_color_basic_score(block.color)
	return score


## 检查对象是否有某个属性
static func has_attribute(obj, attr) -> bool:
	return obj and obj.has_method("get_property_list") and attr in obj.get_property_list()
