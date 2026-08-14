extends Control
## ルール説明画面: 選択中モードの遊び方を表示する
## 「はじめる」でゲーム画面へ、「戻る」でモード選択画面へ遷移する

@onready var title_label: Label = $CenterLayout/TitleLabel
@onready var rule_label: Label = $CenterLayout/RuleLabel
@onready var start_button: Button = $CenterLayout/ButtonRow/StartButton
@onready var back_button: Button = $CenterLayout/ButtonRow/BackButton


func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)
	_show_selected_mode_rule()


func _show_selected_mode_rule() -> void:
	for mode: Dictionary in Constants.MODES:
		if mode.id == Constants.selected_mode_id:
			title_label.text = mode.name
			rule_label.text = mode.rule_text
			return


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ModeSelect.tscn")
