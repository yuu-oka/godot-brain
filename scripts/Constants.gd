extends Node
## ゲーム全体で使う定数をまとめたシングルトン(autoload)

# セッション設定
const PROBLEMS_PER_SESSION: int = 20

# セッション成績によるレベル変化の閾値
const LEVEL_UP_THRESHOLD: float = 0.85
const LEVEL_DOWN_THRESHOLD: float = 0.65

# 出題間隔(秒)
const NORMAL_INTERVAL: float = 2.5
const FAST_INTERVAL: float = 1.5

# Nバックの最小値(レベルダウンの下限)
const MIN_N_BACK: int = 1

# 式に使う一桁の範囲
const DIGIT_MIN: int = 0
const DIGIT_MAX: int = 9

# コンテンツ選択画面に表示するモード一覧(鬼計算のみ実装済み)
const MODES: Array[Dictionary] = [
	{
		"id": "onikeisan",
		"name": "鬼計算",
		"enabled": true,
		"rule_text": "画面に次々と計算式が表示されます。\nNバック(N個前)の式の答えを覚えておき、\nテンキーで入力してください。\n\n正解するとレベルアップ、\n間違いが多いとレベルダウンします。",
	},
	{"id": "onimekuri", "name": "鬼めくり", "enabled": false, "rule_text": ""},
	{"id": "oninezumi", "name": "鬼ネズミ", "enabled": false, "rule_text": ""},
	{"id": "onirodoku", "name": "鬼朗読", "enabled": false, "rule_text": ""},
	{"id": "onikigou", "name": "鬼記号", "enabled": false, "rule_text": ""},
	{"id": "onicup", "name": "鬼カップ", "enabled": false, "rule_text": ""},
	{"id": "oniblock", "name": "鬼ブロック", "enabled": false, "rule_text": ""},
	{"id": "oniansan", "name": "鬼耳算", "enabled": false, "rule_text": ""},
]

# ModeSelect画面で選ばれ、RuleExplain画面へ引き継がれる選択中モードID
var selected_mode_id: String = "onikeisan"
