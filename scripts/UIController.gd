extends Control
## メイン画面のUI制御:表示更新とキー入力受付を担当する

const CORRECT_COLOR := Color(0.4, 0.9, 0.4)
const INCORRECT_COLOR := Color(0.9, 0.4, 0.4)
const ANSWER_NEUTRAL_COLOR := Color(1, 1, 1, 1)

# カードの正解/不正解フィードバック演出
const CARD_POP_SCALE := Vector2(1.06, 1.06)
const CARD_SHAKE_DISTANCE: float = 10.0

@onready var play_layer: Control = $PlayLayer
@onready var level_label: Label = $LevelLabel
@onready var stack_panel: PanelContainer = $PlayLayer/StackPanel
@onready var question_label: Label = $PlayLayer/StackPanel/StackLayout/QuestionLabel
@onready var lower_label: Label = $PlayLayer/StackPanel/StackLayout/LowerLabel
@onready var answer_prefix_label: Label = $PlayLayer/AnswerRow/AnswerPrefixLabel
@onready var answer_value_label: Label = $PlayLayer/AnswerRow/AnswerValueLabel

@onready var session_end_layer: Control = $SessionEndLayer
@onready var result_label: Label = $SessionEndLayer/ResultLabel
@onready var next_button: Button = $SessionEndLayer/NextButton
@onready var mode_select_button: Button = $SessionEndLayer/ModeSelectButton

@onready var round_timer: Timer = $RoundTimer
@onready var timer_bar: ProgressBar = $TimerBar
@onready var answer_blink_timer: Timer = $AnswerBlinkTimer

var _game_logic := GameLogic.new()
var _level_manager := LevelManager.new()

# 回答エリアに表示する、今回のキー入力内容
var _current_input_digit: int = -1

# カードのStyleBoxとアニメーション用Tween(連続採点時に前の演出を打ち切るため保持)
var _stack_style: StyleBoxFlat
var _card_glow_tween: Tween
var _card_motion_tween: Tween
var _timer_bar_tween: Tween


func _ready() -> void:
	_stack_style = stack_panel.get_theme_stylebox("panel") as StyleBoxFlat
	round_timer.timeout.connect(_on_round_timer_timeout)
	answer_blink_timer.timeout.connect(_on_answer_blink_timeout)
	next_button.pressed.connect(_on_next_button_pressed)
	mode_select_button.pressed.connect(_on_mode_select_button_pressed)
	_start_session()


func _start_session() -> void:
	session_end_layer.visible = false
	play_layer.visible = true
	level_label.visible = true
	timer_bar.visible = true

	_game_logic.reset(_level_manager.get_n_back())
	round_timer.wait_time = _level_manager.get_interval()

	question_label.text = ""

	_update_level_label()
	_show_next_problem()


func _show_next_problem() -> void:
	_current_input_digit = -1

	var text := _game_logic.generate_next_problem()
	lower_label.text = text
	question_label.text = "問%d" % _game_logic.get_current_question_number()
	_reset_answer_display()

	round_timer.start()
	_start_round_progress_bar()


## 残り時間プログレスバーを出題間隔いっぱいから0まで一定速度で減らす
func _start_round_progress_bar() -> void:
	if _timer_bar_tween:
		_timer_bar_tween.kill()
	var duration: float = round_timer.wait_time
	timer_bar.max_value = duration
	timer_bar.value = duration
	_timer_bar_tween = create_tween()
	_timer_bar_tween.tween_property(timer_bar, "value", 0.0, duration).set_trans(Tween.TRANS_LINEAR)


## 回答エリアを「未入力」の点滅表示に戻す。「回答: 」の接頭辞は点滅させず、値(_)だけを点滅させる
func _reset_answer_display() -> void:
	answer_prefix_label.modulate = ANSWER_NEUTRAL_COLOR
	answer_value_label.modulate = ANSWER_NEUTRAL_COLOR
	answer_value_label.text = "_"

	if _game_logic.is_scoring_active():
		answer_prefix_label.text = "問%dの回答: " % _game_logic.get_target_question_number()
	else:
		answer_prefix_label.text = "回答: "

	answer_blink_timer.start()


func _on_answer_blink_timeout() -> void:
	answer_value_label.modulate.a = 1.0 - answer_value_label.modulate.a


## 入力が確定した(キー入力またはタイムアウト)ので点滅を止めて表示を固定する
func _stop_answer_blink() -> void:
	answer_blink_timer.stop()
	answer_value_label.modulate.a = 1.0


func _update_level_label() -> void:
	level_label.text = "レベル: %s" % _level_manager.get_level_label()


func _unhandled_input(event: InputEvent) -> void:
	if not play_layer.visible:
		return
	if not event is InputEventKey or not event.pressed or event.echo:
		return

	var digit := _digit_from_key(event.keycode)
	if digit == -1:
		return
	_submit_digit(digit)


func _digit_from_key(keycode: Key) -> int:
	if keycode >= KEY_0 and keycode <= KEY_9:
		return keycode - KEY_0
	if keycode >= KEY_KP_0 and keycode <= KEY_KP_9:
		return keycode - KEY_KP_0
	return -1


func _submit_digit(digit: int) -> void:
	# 1設問につき最初の入力のみ受け付ける
	if _game_logic.has_answered_this_round():
		return
	_current_input_digit = digit
	_stop_answer_blink()
	answer_value_label.text = str(digit)

	var result: Variant = _game_logic.submit_answer(digit)
	_show_feedback(result)


func _on_round_timer_timeout() -> void:
	# 未入力のまま制限時間が切れた場合のみ不正解として記録する
	if not _game_logic.has_answered_this_round():
		_stop_answer_blink()
		answer_value_label.text = "-"

		var result: Variant = _game_logic.submit_timeout()
		_show_feedback(result)

	if _game_logic.is_session_complete():
		_end_session()
	else:
		_show_next_problem()


func _show_feedback(result: Variant) -> void:
	if result == null:
		return

	var result_color := CORRECT_COLOR if result else INCORRECT_COLOR
	answer_prefix_label.modulate = result_color
	answer_value_label.modulate = result_color

	if result:
		_animate_correct()
	else:
		_animate_incorrect()


## カードの枠を緑に光らせて軽く拡大する正解演出
func _animate_correct() -> void:
	_play_card_glow(CORRECT_COLOR)

	if _card_motion_tween:
		_card_motion_tween.kill()
	stack_panel.pivot_offset = stack_panel.size / 2.0
	_card_motion_tween = create_tween()
	_card_motion_tween.tween_property(stack_panel, "scale", CARD_POP_SCALE, 0.1) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_card_motion_tween.tween_property(stack_panel, "scale", Vector2.ONE, 0.2) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


## カードの枠を赤に光らせて左右にシェイクする不正解演出
func _animate_incorrect() -> void:
	_play_card_glow(INCORRECT_COLOR)

	if _card_motion_tween:
		_card_motion_tween.kill()
	stack_panel.position.x = 0.0
	var d := CARD_SHAKE_DISTANCE
	_card_motion_tween = create_tween()
	_card_motion_tween.tween_property(stack_panel, "position:x", -d, 0.05)
	_card_motion_tween.tween_property(stack_panel, "position:x", d, 0.06)
	_card_motion_tween.tween_property(stack_panel, "position:x", -d * 0.6, 0.06)
	_card_motion_tween.tween_property(stack_panel, "position:x", d * 0.6, 0.06)
	_card_motion_tween.tween_property(stack_panel, "position:x", 0.0, 0.05)


## カードの枠を指定色でパッと光らせてからゆっくり透明に戻す
func _play_card_glow(color: Color) -> void:
	if _card_glow_tween:
		_card_glow_tween.kill()
	_stack_style.border_color = Color(color.r, color.g, color.b, 1.0)
	_card_glow_tween = create_tween()
	_card_glow_tween.tween_property(_stack_style, "border_color", Color(color.r, color.g, color.b, 0.0), 0.4) \
		.set_delay(0.1)


func _end_session() -> void:
	play_layer.visible = false
	level_label.visible = false
	session_end_layer.visible = true
	timer_bar.visible = false
	answer_blink_timer.stop()
	if _timer_bar_tween:
		_timer_bar_tween.kill()

	var accuracy := _game_logic.get_accuracy()
	var change: LevelManager.LevelChange = _level_manager.evaluate_and_update(accuracy)
	result_label.text = _build_result_text(accuracy, change)


func _build_result_text(accuracy: float, change: LevelManager.LevelChange) -> String:
	var lines: Array[String] = []
	lines.append("正答率: %d%%" % int(round(accuracy * 100)))

	match change:
		LevelManager.LevelChange.UP:
			lines.append("レベルアップ!")
		LevelManager.LevelChange.KEEP:
			lines.append("レベル据え置き")
		LevelManager.LevelChange.DOWN:
			lines.append("レベルダウン")

	lines.append("次のレベル: %s" % _level_manager.get_level_label())
	return "\n".join(lines)


func _on_next_button_pressed() -> void:
	_start_session()


func _on_mode_select_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ModeSelect.tscn")
