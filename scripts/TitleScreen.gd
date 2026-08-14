extends Control
## タイトル画面: 「はじめる」ボタンでモード選択画面へ遷移する

@onready var start_button: Button = $CenterLayout/StartButton


func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ModeSelect.tscn")
