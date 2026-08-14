extends Control
## コンテンツ選択画面: Constants.MODESを一覧表示し、実装済みモードのみ選択可能にする
## TitleScreenと同じ和風(暗紫背景 + 赤×金)のテーマで、各モードをカード状に表示する

@onready var button_list: VBoxContainer = $ScrollContainer/ButtonList

# --- テーマカラー(TitleScreenと共通の配色) ---
const GOLD := Color(0.851, 0.702, 0.302, 1)
const GOLD_BRIGHT := Color(0.98, 0.851, 0.451, 1)
const RED_NORMAL := Color(0.68, 0.164, 0.121, 1)
const RED_HOVER := Color(0.82, 0.259, 0.184, 1)
const RED_PRESSED := Color(0.396, 0.086, 0.066, 1)
const TEXT_LIGHT := Color(0.97, 0.94, 0.88, 1)
const DISABLED_BG := Color(0.16, 0.145, 0.19, 1)
const DISABLED_BORDER := Color(0.4, 0.37, 0.44, 0.55)
const DISABLED_TEXT := Color(0.72, 0.7, 0.76, 1)


func _ready() -> void:
	_build_mode_buttons()


func _build_mode_buttons() -> void:
	for mode: Dictionary in Constants.MODES:
		button_list.add_child(_build_mode_card(mode))


func _build_mode_card(mode: Dictionary) -> Control:
	var enabled: bool = mode.enabled

	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _make_card_style(enabled))

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 6)
	card.add_child(content)

	# 上段: モードボタン + ステータスバッジ
	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 12)
	content.add_child(top_row)

	var button := Button.new()
	button.text = mode.name
	button.custom_minimum_size = Vector2(0, 56)
	button.size_flags_horizontal = SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 24)
	button.disabled = not enabled
	button.focus_mode = Control.FOCUS_ALL

	if enabled:
		button.add_theme_color_override("font_color", TEXT_LIGHT)
		button.add_theme_color_override("font_hover_color", Color(1, 0.96, 0.85, 1))
		button.add_theme_color_override("font_pressed_color", Color(0.85, 0.78, 0.62, 1))
		button.add_theme_stylebox_override("normal", _make_button_style(RED_NORMAL, GOLD))
		button.add_theme_stylebox_override("hover", _make_button_style(RED_HOVER, GOLD_BRIGHT))
		button.add_theme_stylebox_override("pressed", _make_button_style(RED_PRESSED, Color(0.651, 0.518, 0.216, 1)))
		button.add_theme_stylebox_override("focus", _make_focus_style())
		button.pressed.connect(_on_mode_button_pressed.bind(mode.id))
	else:
		button.add_theme_color_override("font_disabled_color", DISABLED_TEXT)
		button.add_theme_stylebox_override("disabled", _make_button_style(DISABLED_BG, DISABLED_BORDER))

	top_row.add_child(button)

	var badge := _make_badge(enabled)
	badge.size_flags_vertical = SIZE_SHRINK_CENTER
	top_row.add_child(badge)

	# 下段: ひとことサマリー
	var summary_text: String = ""
	if enabled:
		summary_text = String(mode.get("summary", ""))
	if summary_text != "":
		var summary_label := Label.new()
		summary_label.text = summary_text
		summary_label.add_theme_font_size_override("font_size", 17)
		summary_label.add_theme_color_override("font_color", Color(0.88, 0.83, 0.72, 0.9))
		summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		content.add_child(summary_label)

	return card


func _make_badge(enabled: bool) -> PanelContainer:
	var badge := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 3
	style.content_margin_bottom = 3

	var label := Label.new()
	label.add_theme_font_size_override("font_size", 14)

	if enabled:
		style.bg_color = GOLD
		label.text = "プレイ可能"
		label.add_theme_color_override("font_color", Color(0.25, 0.08, 0.06, 1))
	else:
		style.bg_color = Color(0.3, 0.28, 0.34, 1)
		label.text = "Coming Soon"
		label.add_theme_color_override("font_color", Color(0.8, 0.78, 0.82, 1))

	badge.add_theme_stylebox_override("panel", style)
	badge.add_child(label)
	return badge


func _make_card_style(enabled: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	if enabled:
		style.bg_color = Color(0.16, 0.06, 0.06, 0.55)
		style.border_width_left = 1
		style.border_width_top = 1
		style.border_width_right = 1
		style.border_width_bottom = 1
		style.border_color = Color(0.851, 0.702, 0.302, 0.35)
	else:
		style.bg_color = Color(0.1, 0.09, 0.13, 0.5)
		style.border_width_left = 1
		style.border_width_top = 1
		style.border_width_right = 1
		style.border_width_bottom = 1
		style.border_color = Color(1, 1, 1, 0.06)
	return style


func _make_button_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = border
	style.corner_radius_top_left = 14
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_right = 14
	style.corner_radius_bottom_left = 14
	style.content_margin_left = 20
	style.content_margin_right = 20
	return style


func _make_focus_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = GOLD_BRIGHT
	style.border_color.a = 0.9
	style.corner_radius_top_left = 14
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_right = 14
	style.corner_radius_bottom_left = 14
	return style


func _on_mode_button_pressed(mode_id: String) -> void:
	Constants.selected_mode_id = mode_id
	get_tree().change_scene_to_file("res://scenes/RuleExplain.tscn")
