extends Scannable
class_name Body

@export var character_name: String
@export var role: String
@export var description: String

@export var killer: Body
@export var weapon: Scannable

@onready var sprite := $Sprite2D

func get_scan_info() -> String:
	var output := '''[b]Name:[/b] %s
[b]Role:[/b] %s
[b]Description:[/b] %s''' % [character_name, role, description]

	return output
