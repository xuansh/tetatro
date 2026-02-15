class_name BackgroundParticles extends Node2D

## 背景粒子效果：全屏垂直下落的发光粒子

@onready var particles: CPUParticles2D = $CPUParticles2D

func _ready() -> void:
	# 设置粒子系统
	_setup_particles()
	
	# 开始播放粒子
	particles.emitting = true

func _setup_particles():
	# 基础设置
	particles.amount = 100  # 粒子数量
	particles.lifetime = 5.0  # 粒子生命周期
	particles.spread = 0.0  # 扩散角度（0表示垂直向下）
	particles.direction = Vector2(0, 1)  # 向下发射
	
	# 速度设置
	particles.initial_velocity_min = 5.0  # 最小初始速度
	particles.initial_velocity_max = 10.0  # 最大初始速度
	
	# 位置设置
	var viewport_size = get_viewport().size
	particles.position = Vector2(viewport_size.x / 2, -50)  # 顶部中央
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(viewport_size.x / 2, 0)  # 全屏宽度
	
	# 大小设置
	particles.scale_amount_min = 5
	particles.scale_amount_max = 10
	
	# 颜色设置
	var gradient = Gradient.new()
	gradient.set_color(0, Color(1, 1, 1, 1))  # 白色
	gradient.set_color(1, Color(1, 1, 1, 0))  # 透明
	particles.color_ramp = gradient
	
	# 应用发光 shader
	var shader_material = ShaderMaterial.new()
	shader_material.shader = preload("res://shaders/glow.gdshader")
	shader_material.set_shader_parameter("glow_strength", 3.0)
	shader_material.set_shader_parameter("glow_color", Color(0.5, 0.8, 1.0, 1.0))  # 淡蓝色发光
	particles.material = shader_material

func _on_viewport_resized():
	# 当视口大小改变时，更新粒子系统的位置和发射范围
	var viewport_size = get_viewport().size
	particles.position = Vector2(viewport_size.x / 2, -50)
	particles.emission_rect_extents = Vector2(viewport_size.x / 2, 0)
