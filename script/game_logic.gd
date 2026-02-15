# GameLogic.gd
extends Node

## 基础分（筹码）的统一处理公式
func add_basic_score(current: int, extra: int) -> int:
	# 这里可以方便地统一修改全游戏的计分平衡
	return current + extra

## 倍率的统一处理公式
func add_multiplier(current: int, extra: int) -> int:
	return current + extra

## 最终得分计算（Balatro 核心公式：筹码 * 倍率）
func calculate_final_score(chips: int, mult: int) -> int:
	# 确保倍率至少为 1，避免乘 0
	var safe_mult = max(1, mult)
	return chips * safe_mult
