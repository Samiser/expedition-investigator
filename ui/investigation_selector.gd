extends HBoxContainer
class_name InvestigationSelector

@onready var victim_label := $Victim
@onready var killer_selector := $Killer
@onready var weapon_selector := $Object

var body: Body = null
var potential_killers: Array[Node] = []
var potential_weapons: Array[Node] = []

func set_body(b: Body) -> void:
	body = b
	victim_label.text = body.character_name

func _ready() -> void:
	add_to_group("selector")
	potential_killers = get_tree().get_nodes_in_group("body")
	
	for killer: Body in potential_killers:
		killer_selector.add_item(killer.character_name)

	potential_weapons = get_tree().get_nodes_in_group("weapon")

	for weapon: Scannable in potential_weapons:
		weapon_selector.add_item(weapon.scannable_name)

	killer_selector.select(-1)
	weapon_selector.select(-1)

func check_guess() -> bool:
	return (body.killer.character_name == killer_selector.get_item_text(killer_selector.selected) and
	 body.weapon.scannable_name == weapon_selector.get_item_text(weapon_selector.selected))
