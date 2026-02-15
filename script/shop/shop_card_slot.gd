class_name ShopCardSlot
extends PanelContainer
## 商店单个卡牌槽：显示卡牌信息与购买按钮，并支持在鼠标悬停时做简单 3D 倾斜效果。

const CardData = preload("res://script/card/card_data.gd")

signal buy_pressed(card)

var _card

# --- 鼠标悬停倾斜相关 -------------------------
var following_mouse: bool = false
var is_hovering: bool = false
const angle_x_max := 0.15  # 弧度约 8.6°
const angle_y_max := 0.15

@onready var card_image: TextureRect = $Margin/VBox/CardImage
@onready var name_label: Label = $Margin/VBox/NameLabel
@onready var desc_label: Label = $Margin/VBox/DescLabel
@onready var price_label: Label = $Margin/VBox/PriceLabel
@onready var buy_btn: Button = $Margin/VBox/BuyBtn

var tween_hover : Tween
var tween_rotate : Tween
var snow_timer : Timer

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)
	
	# 为每个卡牌槽创建材质的副本，避免共享材质导致的问题
	if card_image.material:
		card_image.material = card_image.material.duplicate()
	
	# 创建雪花定时器
	snow_timer = Timer.new()
	snow_timer.wait_time = 0.1  # 每0.1秒生成一次雪花
	snow_timer.autostart = false
	snow_timer.timeout.connect(func():
		if _card and _card.card_name == "山顶":
			mouse_snow()
	)
	add_child(snow_timer)

func set_card(card) -> void:
	_card = card
	if not is_node_ready():
		await ready
	name_label.text = card.card_name
	desc_label.text = card.description
	price_label.text = "%d 金币" % card.price
	name_label.add_theme_color_override("font_color", CardData.get_rarity_color(card.rarity))
	
	# 图片展示：没有贴图时隐藏
	if card.texture != null:
		card_image.texture = card.texture
		card_image.visible = true
	else:
		card_image.texture = null
		card_image.visible = false
	
	buy_btn.text = "购买"
	if not buy_btn.pressed.is_connected(_on_buy):
		buy_btn.pressed.connect(_on_buy)


func _on_buy() -> void:
	if _card:
		buy_pressed.emit(_card)

#------------------------------------------------
# 鼠标悬停倾斜效果 + 点击传递
#------------------------------------------------
func _on_gui_input(event: InputEvent) -> void:
	_handle_mouse_click(event)
	
	# 拖拽时不要计算倾斜
	if following_mouse:
		return
	# 仅在鼠标移动时更新角度
	if not event is InputEventMouseMotion:
		return
	
	# 获取局部鼠标位置
	var mouse_pos: Vector2 = get_local_mouse_position()
	var size: Vector2 = get_size()
	if size == Vector2.ZERO:
		return
	
	# 将鼠标位置映射到 [-1, 1] 范围，使中心点为 (0,0)
	var mapped_x = (mouse_pos.x / size.x) * 2.0 - 1.0
	var mapped_y = (mouse_pos.y / size.y) * 2.0 - 1.0

	# 直接根据映射值计算旋转角度，以获得更线性和对称的效果
	var rot_x = -mapped_y * rad_to_deg(angle_x_max)
	var rot_y = mapped_x * rad_to_deg(angle_y_max)
	
	# 将角度传给材质 shader（若有）
	if card_image.material != null:
		card_image.material.set_shader_parameter("x_rot", rot_x)
		card_image.material.set_shader_parameter("y_rot", rot_y)
	




func _handle_mouse_click(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		# 单击左键视为购买
		_on_buy()


func _on_mouse_entered() -> void:
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	
	# 设置轴心点到中心，使其从中心缩放
	card_image.pivot_offset = card_image.size / 2.0
	
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(card_image,"scale",Vector2(1.1, 1.1), 0.5)
	
	# 如果是山顶卡牌，启动雪花定时器
	if _card and _card.card_name == "山顶":
		snow_timer.start()
	

func _on_mouse_exited() -> void:
	if tween_rotate and tween_rotate.is_running():
		tween_rotate.kill()
	tween_rotate = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
	tween_rotate.tween_property(card_image.material,"shader_parameter/x_rot", 0.0, 0.3)
	tween_rotate.tween_property(card_image.material,"shader_parameter/y_rot", 0.0, 0.3)
	
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(card_image,"scale",Vector2.ONE, 0.55)
	
	# 停止雪花定时器
	snow_timer.stop()


func mouse_snow() -> void:
	# 1. 创建粒子节点
	var particles = CPUParticles2D.new()
	add_child(particles) # 添加到卡牌槽下
	
	# 2. 基础物理属性配置 (让它看起来像雪花)
	particles.amount = 8                  # 每次触发生成的数量
	particles.explosiveness = 1.0         # 爆发式发射
	particles.one_shot = true             # 只发射一次
	particles.lifetime = 0.8              # 粒子存活时间
	
	# 3. 运动与重力
	particles.direction = Vector2(0, 1)    # 向下飘落
	particles.spread = 60.0               # 扩散角度
	particles.gravity = Vector2(0, 200)   # 轻微重力
	particles.initial_velocity_min = 20.0 # 初始速度
	particles.initial_velocity_max = 50.0
	
	# 4. 视觉配置 (可爱感)
	particles.scale_amount_min = 1.0
	particles.scale_amount_max = 3.0      # 随机大小
	# 颜色渐变：从白色变透明
	var gradient = Gradient.new()
	gradient.set_color(0, Color.WHITE)
	gradient.set_color(1, Color("0d3558ff")                                                                              )
	particles.color_ramp = gradient
	
	# 5. 设置位置为当前鼠标局部坐标
	particles.position = get_local_mouse_position()
	
	# 6. 播放并自动销毁
	particles.emitting = true
	# 使用 Timer 或 Tween 的 finished 信号清理节点
	get_tree().create_timer(particles.lifetime + 0.1).timeout.connect(
		func(): particles.queue_free()
	)
