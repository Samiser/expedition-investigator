extends CharacterBody2D

@onready var scan_area := $ScanArea

var speed := 200

var using_terminal := false
signal terminal_toggled(status: bool)

func get_input() -> void:
	var input_direction := Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_terminal"):
		using_terminal = !using_terminal
		emit_signal("terminal_toggled", using_terminal)
	
	if not using_terminal:
		get_input()
		move_and_slide()
		$PointLight2D.look_at(get_global_mouse_position())
		$PointLight2D.rotate(PI/2)

func _highlight_area_parent(area: Area2D, should_highlight: bool) -> void:
	var node := area.get_parent()
	
	if node.has_method("highlight"):
		node.highlight(should_highlight)

func _on_scan_area_entered(area: Area2D) -> void:
	_highlight_area_parent(area, true)

func _on_scan_area_exited(area: Area2D) -> void:
	_highlight_area_parent(area, false)

func get_scannable_areas() -> Array[Area2D]:
	return scan_area.get_overlapping_areas()

func _ready() -> void:
	scan_area.area_entered.connect(_on_scan_area_entered)
	scan_area.area_exited.connect(_on_scan_area_exited)
