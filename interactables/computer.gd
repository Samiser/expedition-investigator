extends Scannable
class_name Computer

@export var files: Dictionary[String, String]

var client: Terminal = null

func error(msg: String) -> String:
	return "[b]Error:[/b] %s" % msg

func list() -> String:
	var lines: Array[String] = []
	for file in files:
		lines.append(file)
	return '\n'.join(lines)

func cat(params: Array[String]) -> String:
	if params.size() == 1:
		return error("'cat' requires at least one argument")
	else:
		var lines: Array[String] = []
		for file: String in params.slice(1, params.size()):
			if file in files:
				lines.append(files[file])
		return '\n'.join(lines)

func get_scan_info() -> String:
	return '''A terminal used by crewmembers for various base operations

You can connect to this terminal using the [b]connect[/b] command'''

func client_disconnect() -> String:
	var output := client.host_disconnect()
	client = null
	return output

func clear() -> String:
	return client.clear()

func help(_params: Array[String]) -> String:
	return '''Commands:
	ls - list files
	cat - print file contents
	disconnect - disconnect from this host
	clear - clear terminal output'''

func parse_command(params: Array[String]) -> String:
	match params[0]:
		"help":
			return help(params)
		"ls":
			return list()
		"cat":
			return cat(params)
		"clear":
			return clear()
		"disconnect":
			return client_disconnect()
		_:
			return error("[b]Unknown Command[/b], type 'help' to see all commands")

func _ready() -> void:
	add_to_group("computer")
