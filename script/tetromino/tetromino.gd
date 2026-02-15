class_name Tetromino

# 1. 属性解耦
var TYPE : String    # 逻辑类型：normal, gold, whale 等
var COLOR : String   # 颜色属性：red, green, blue, yellow 等
var TEXTURE: Texture2D

var state_array = []
var orientation = 0

const COIN = preload("uid://cq2trd2siqsx")
const NORMAL = preload("uid://bc8426s38dvk2")

# 2. 结构化数据：Key 是类型，Value 是该类型支持的颜色及其图片
var SKIN_DATA = {
}

func _init() -> void:
	add_block_type_img(NORMAL)
	
	# 第一步：先抽类型 (TYPE)
	var type_pool = SKIN_DATA.keys()
	TYPE = type_pool.pick_random() 
	
	# 第二步：再从该类型下抽颜色 (COLOR)
	var color_pool = SKIN_DATA[TYPE]
	var available_colors = color_pool.keys()
	COLOR = available_colors.pick_random()
	
	# 第三步：获取图片
	var texture_path = color_pool[COLOR]
	TEXTURE = load(texture_path)

func add_block_type_img(block_type : BlockType):
	if block_type:
		var block_type_name = block_type.blockTypeName
		SKIN_DATA[block_type_name] = {}
		SKIN_DATA[block_type_name]["red"] = block_type.red_img
		SKIN_DATA[block_type_name]["green"] = block_type.green_img
		SKIN_DATA[block_type_name]["blue"] = block_type.blue_img
		SKIN_DATA[block_type_name]["yellow"] = block_type.yellow_img
	else: return
	

func get_blocks():
	if state_array.is_empty():
		return []
	return state_array[orientation]
