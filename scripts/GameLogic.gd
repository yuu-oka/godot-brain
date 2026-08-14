class_name GameLogic
extends RefCounted
## 式の生成、Nバック履歴管理、正誤判定を担当する

var n_back: int = Constants.MIN_N_BACK

var scored_count: int = 0
var correct_count: int = 0

var _answer_history: Array[int] = []
var _answered_this_round: bool = false


func reset(new_n_back: int) -> void:
	n_back = new_n_back
	_answer_history.clear()
	_answered_this_round = false
	scored_count = 0
	correct_count = 0


## 新しい式を生成して履歴に積み、式のテキスト(例: "7-3=")を返す
func generate_next_problem() -> String:
	var use_addition := randi() % 2 == 0
	var a: int
	var b: int
	var answer: int
	var text: String

	if use_addition:
		a = randi_range(Constants.DIGIT_MIN, Constants.DIGIT_MAX)
		b = randi_range(Constants.DIGIT_MIN, Constants.DIGIT_MAX - a)
		answer = a + b
		text = "%d+%d=" % [a, b]
	else:
		a = randi_range(Constants.DIGIT_MIN, Constants.DIGIT_MAX)
		b = randi_range(Constants.DIGIT_MIN, a)
		answer = a - b
		text = "%d-%d=" % [a, b]

	_answer_history.append(answer)
	_answered_this_round = false
	return text


## Nバック分の履歴が溜まり採点対象になっているか
func is_scoring_active() -> bool:
	return _answer_history.size() > n_back


func get_target_answer() -> int:
	return _answer_history[_answer_history.size() - 1 - n_back]


## 現在出題中の式の通し番号(1始まり)
func get_current_question_number() -> int:
	return _answer_history.size()


## 今回答えるべき式(Nバック前に出題されたもの)の通し番号
func get_target_question_number() -> int:
	return _answer_history.size() - n_back


func has_answered_this_round() -> bool:
	return _answered_this_round


## プレイヤーの入力(0〜9)を判定する。
## 採点対象外(ウォームアップ中)、または既にこの設問に回答済みならnullを返す
func submit_answer(input_digit: int) -> Variant:
	if _answered_this_round:
		return null
	_answered_this_round = true

	if not is_scoring_active():
		return null

	var correct := input_digit == get_target_answer()
	scored_count += 1
	if correct:
		correct_count += 1
	return correct


## 制限時間内に未入力だった場合を記録する(不正解扱い)。
## 採点対象外、または既に回答済みならnullを返す
func submit_timeout() -> Variant:
	if _answered_this_round:
		return null
	_answered_this_round = true

	if not is_scoring_active():
		return null

	scored_count += 1
	return false


func is_session_complete() -> bool:
	return scored_count >= Constants.PROBLEMS_PER_SESSION


func get_accuracy() -> float:
	if scored_count == 0:
		return 0.0
	return float(correct_count) / float(scored_count)
