extends Control
## コンテンツ選択画面: Constants.MODESを一覧表示し、実装済みモードのみ選択可能にする

@onready var button_list: VBoxContainer = $ScrollContainer/ButtonList


func _ready() -> void:
	_build_mode_buttons()


func _build_mode_buttons() -> void:
	for mode: Dictionary in Constants.MODES:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 16)

		var button := Button.new()
		button.text = mode.name
		button.custom_minimum_size = Vector2(240, 52)
		button.add_theme_font_size_override("font_size", 24)
		button.disabled = not mode.enabled
		if mode.enabled:
			button.pressed.connect(_on_mode_button_pressed.bind(mode.id))
		row.add_child(button)

		if not mode.enabled:
			var coming_soon_label := Label.new()
			coming_soon_label.text = "Coming Soon"
			coming_soon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			coming_soon_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.66))
			coming_soon_label.add_theme_font_size_override("font_size", 18)
			row.add_child(coming_soon_label)

		button_list.add_child(row)


func _on_mode_button_pressed(mode_id: String) -> void:
	Constants.selected_mode_id = mode_id
	get_tree().change_scene_to_file("res://scenes/RuleExplain.tscn")
