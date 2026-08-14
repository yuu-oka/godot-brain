class_name LevelManager
extends RefCounted
## 現在のNバック数・速度の管理とレベルアップ/ダウン判定を担当する
##
## レベルは「段階(_level_step)」で表現し、2段階進むごとにNバック数が1増える。
## step 0 = 1バック(通常), step 1 = 1バック(速い), step 2 = 2バック(通常), ...

enum Speed { NORMAL, FAST }
enum LevelChange { UP, KEEP, DOWN }

var _level_step: int = 0


func get_n_back() -> int:
	return _level_step / 2 + 1


func get_speed() -> Speed:
	return Speed.FAST if _level_step % 2 == 1 else Speed.NORMAL


func get_interval() -> float:
	return Constants.FAST_INTERVAL if get_speed() == Speed.FAST else Constants.NORMAL_INTERVAL


func get_speed_label() -> String:
	return "速い" if get_speed() == Speed.FAST else "通常"


func get_level_label() -> String:
	return "%dバック(%s)" % [get_n_back(), get_speed_label()]


## セッションの正答率に応じてレベルを更新し、変化の種類を返す
func evaluate_and_update(accuracy: float) -> LevelChange:
	if accuracy >= Constants.LEVEL_UP_THRESHOLD:
		_level_step += 1
		return LevelChange.UP
	elif accuracy >= Constants.LEVEL_DOWN_THRESHOLD:
		return LevelChange.KEEP
	else:
		var min_step := (Constants.MIN_N_BACK - 1) * 2
		_level_step = max(min_step, _level_step - 1)
		return LevelChange.DOWN
