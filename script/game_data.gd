extends Node

var score : int

# 存储升级配置资源
var upgrade_configs = {
	"red": preload("uid://chpwffpxq4603"),
	"blue": preload("uid://chjw67tfxisak"),
	"green": preload("uid://by60gw838uumx"),
	"yellow": preload("uid://bnut1waudg6bn")
}

# 玩家当前的等级记录
var color_levels = {
	"red": 1,
	"blue": 1,
	"green": 1,
	"yellow": 1
}

# 获取某个颜色的当前实时分值
func get_color_basic_score(color_name: String) -> int:
	if upgrade_configs.has(color_name):
		var config = upgrade_configs[color_name]
		var level = color_levels[color_name]
		return config.get_score_for_level(level)
	return 1 # 默认保底分

## 执行升级
#func level_up_color(color_name: String):
	#if color_levels.has(color_name):
		#color_levels[color_name] += 1
		## 这里可以播放一个全局的升级音效
