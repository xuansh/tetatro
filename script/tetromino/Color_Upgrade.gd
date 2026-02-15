extends Resource
class_name ColorUpgrade

@export_group("Basic Info")
@export var target_color: String     # 对应方块的颜色名
@export var color_icon: Texture2D            # 在商店里显示的图标

@export_group("Leveling Stats")
@export var base_score_add: int = 5          # 每次升级增加的基础分 (Basic)
@export var base_mult_add: float = 0.0       # 每次升级增加的倍率 (Mult)

@export_group("Cost Settings")
@export var initial_cost: int = 100          # 初始升级花费
@export var cost_multiplier: float = 1.5     # 价格增长倍数 (每次升级后价格 = 当前价格 * 这个)

# 辅助函数：计算当前等级下的分数
func get_score_for_level(level: int) -> int:
	# 初始分 10 + (等级-1) * 增量
	return (level)

# 辅助函数：计算下一次升级需要的金币
func get_upgrade_cost(current_level: int) -> int:
	return int(initial_cost * pow(cost_multiplier, current_level - 1))
