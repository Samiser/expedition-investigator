extends Node2D
class_name Scannable

@export var scannable_name: String
@export var dna: Array[Body]

@onready var highlight_light := $Highlight

func highlight(show: bool) -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(highlight_light, "energy", 2.0 if show else 0.0, 0.13)

func get_dna() -> Array[Body]:
	return dna

func get_scan_info() -> String:
	return "no scan info"
