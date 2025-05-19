extends Window
class_name Terminal

@onready var connected_info: RichTextLabel = $VBoxContainer/TabContainer/Terminal/StatusTextLabel
@onready var output_label: RichTextLabel = $VBoxContainer/TabContainer/Terminal/OutputTextLabel
@onready var input: LineEdit = $VBoxContainer/TabContainer/Terminal/HBoxContainer/InputLineEdit
@onready var investigation_selectors: VBoxContainer = $VBoxContainer/TabContainer/Investigation/InvestigationSelectors
@onready var guess_button: Button = $VBoxContainer/TabContainer/Investigation/Button
@onready var finished_label: Label = $VBoxContainer/TabContainer/Investigation/Finished

@export var player: CharacterBody2D
@export var map: Node2D

var investigator_selector_scene := preload("res://ui/investigation_selector.tscn")

var connected: Computer = null
var dna_collected: Array[Body] = []

func error(msg: String) -> String:
	return "[b]Error:[/b] %s" % msg

func help(_params: Array[String]) -> String:
	return '''Commands:
	scan - list scannable objects in range
	scan [name] - scan an in-range scannable
	connect [host] - connect to in-range host
	clear - clear terminal output'''

func scan(params: Array[String]) -> String:
	var areas: Array[Area2D] = player.get_scannable_areas()
	var output := ""

	if params.size() == 2:
		var scannable: Node2D = null
		for area in areas:
			if area.get_parent().scannable_name == params[1]:
				scannable = area.get_parent()

		if not scannable:
			return error("No scannable with that name in range!")

		return scannable.get_scan_info()

	elif params.size() == 1:
		if areas.size() == 0:
			return error("No scannables in range!")
		var lines := []
		lines.append("[b]Scannables in range:[/b]")
		for area in areas:
			lines.append(area.get_parent().scannable_name)
		output = '\n'.join(lines)

	return output

func dna(params: Array[String]) -> String:
	if params.size() != 2:
		return error("[b]dna[/b] takes one argument")

	for area: Area2D in player.get_scannable_areas():
		var parent: Scannable = area.get_parent()
		if parent.scannable_name == params[1]:
			if parent is Body:
				dna_collected.append(parent)
				return "DNA of [b]%s[/b] collected!" % parent.scannable_name
			elif parent is Scannable:
				var lines: Array[String] = ["DNA present on [b]%s[/b]:" % parent.scannable_name]
				for dna: Body in parent.get_dna():
					if dna in dna_collected:
						dna_collected.append(dna)

	return "No matching scannable"

func host_connect(params: Array[String]) -> String:
	if params.size() != 2:
		return error("[b]connect[/b] takes one argument")
	
	for area: Area2D in player.get_scannable_areas():
		if area.get_parent().scannable_name == params[1] and area.get_parent() is Computer:
			connected = area.get_parent()
			connected.client = self
			connected_info.text = "[b]Connected[/b]: %s" % connected.scannable_name

	if connected == null:
		return error("Failed to connect to host [b]%s[/b]" % params[1])
	else:
		return '''Successfully connected to [b]%s[/b]

Use the [b]help[/b] command to view available commands on this terminal''' % connected.scannable_name

func host_disconnect() -> String:
	if connected == null:
		return error("No currently connected host")
	
	var output := "Successfully disconnected from [b]%s[/b]" % connected.scannable_name
	connected_info.text = ""
	connected = null
	return output

func clear() -> String:
	output_label.clear()
	return ""

func parse_command(params: Array[String]) -> String:
	match params[0]:
		"help":
			return help(params)
		"scan":
			return scan(params)
		"dna":
			return dna(params)
		"connect":
			return host_connect(params)
		"clear":
			return clear()
		_:
			return error("[b]Unknown Command[/b], type 'help' to see all commands")

func text_submitted(text: String) -> void:
	var params := text.strip_edges().split(" ")
	var output := ""
	output_label.append_text("$ " + text + '\n')
	if connected:
		output = connected.parse_command(params)
	else:
		output = parse_command(params)
	output_label.append_text(output + '\n')
	input.clear()

func set_visibility(visibility: bool) -> void:
	if visibility:
		visible = true
		input.grab_focus()
	else:
		visible = false

func check_guesses() -> void:
	var correct := true
	
	for guesser: InvestigationSelector in get_tree().get_nodes_in_group("selector"):
		if not guesser.check_guess():
			correct = false
	
	if correct:
		finished_label.text = "Correct! Investigation Solved!"
	else:
		finished_label.text = "Not quite right, try looking closer..."

func _ready() -> void:
	input.text_submitted.connect(text_submitted)
	player.terminal_toggled.connect(set_visibility)
	guess_button.pressed.connect(check_guesses)
	for body in get_tree().get_nodes_in_group("body"):
		var selector: InvestigationSelector = investigator_selector_scene.instantiate()
		investigation_selectors.add_child(selector)
		selector.set_body(body)
		
