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
