#GDAntiCheats
@icon("icon.png")
extends Node
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#	GDAnti-Cheats
#
#	https://github.com/CodeNameTwister/GDAnti-Cheats
#	author:	"Twister"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
signal stream_buffer_change(buffer_size : int, flush_rate : int)
signal change_node(self_node : Node, new_node : Node)

const TYPES_FLUSH : Array[int] = [TYPE_STRING, TYPE_INT, TYPE_FLOAT, TYPE_BOOL, TYPE_NIL]

var BUFFER_SIZE : int = 10:
	set(e):
		BUFFER_SIZE = max(2, e)
		stream_buffer_change.emit(BUFFER_SIZE, FLUSH_RATE)

var FLUSH_RATE: int = 30:
	set(e):
		FLUSH_RATE = max(0, e)
		stream_buffer_change.emit(BUFFER_SIZE, FLUSH_RATE)

var _garbage_strings : Array[String] = [""]
var _garbage_references : Array[Object] = [null]
var _rnd : RandomNumberGenerator = RandomNumberGenerator.new()

static func get_instance() -> Node:
	for node in Engine.get_main_loop().get_nodes_in_group(_OVAL.GDAC_GROUP):
		return node
	return null

# Manual Caution Function
## Create new reference of this node.
func request_flush_self_reference() -> void:
	var parent : Node = get_parent()
	if null == parent:
		return
	var new_node : Node = get_script().new()
	new_node.FLUSH_RATE = FLUSH_RATE
	new_node.BUFFER_SIZE = BUFFER_SIZE
	parent.remove_child(self)
	parent.add_child(new_node)
	change_node.emit(self, new_node)
	queue_free()

func _notification(what: int) -> void:
	for x in _garbage_references:
		if is_instance_valid(x):
			x.free()

func flush_value(val : _VAL) -> void:
	var type : int =  typeof(val.get_value())
	var new_type : int = TYPES_FLUSH[_rnd.randi() % TYPES_FLUSH.size()]
	while type == new_type:
		new_type = TYPES_FLUSH[_rnd.randi() % TYPES_FLUSH.size()]
	match new_type:
		TYPE_STRING:
			val.set_value(_garbage_strings[_rnd.randi()%_garbage_strings.size()])
			return
		TYPE_INT:
			val.set_value(_rnd.randi_range(-9223372036854775808, 9223372036854775807))
			return
		TYPE_FLOAT:
			val.set_value(_rnd.randf_range(-1.79769e308, 1.79769e308))
			return
		TYPE_BOOL:
			val.set_value(bool(_rnd.randi() % 2))
			return
		_:
			val.set_value(_garbage_references[_rnd.randi()%_garbage_references.size()])
			return

func _enter_tree() -> void:
	_rnd.randomize()
	add_to_group(_OVAL.GDAC_GROUP)

func _exit_tree() -> void:
	remove_from_group(_OVAL.GDAC_GROUP)

func _ready() -> void:
	_garbage_strings.clear()
	for x in _garbage_references:
		if is_instance_valid(x):
			x.free()
	_garbage_references.clear()

	const CHARS : String = _OVAL.STRS
	for x in range(0, 6, 1):
		var n_char : int = len(CHARS)
		var word: String = ""
		for i in range(_rnd.randi_range(4, 8)):
			if _rnd.randi() % 2 == 0:
				word += CHARS[randi()% n_char].to_upper()
			else:
				word += CHARS[randi()% n_char]
		_garbage_strings.append(word)
	for x in range(0, 6, 1):
		var o : _OVAL = _OVAL.new()
		flush_value(o.value)
		_garbage_references.append(o)

func _generate_word(chars, length) -> String:
	var word: String
	var n_char = len(chars)
	for i in range(length):
		word += chars[randi()% n_char]
	return word

func unregister(o : StreamValue) -> void:
	if is_instance_valid(o):
		if stream_buffer_change.is_connected(o.globaL_update_settings):
			stream_buffer_change.disconnect(o.globaL_update_settings)
		if change_node.is_connected(o._on_change_node):
			change_node.disconnect(o._on_change_node)

func register(o : StreamValue, update_values : bool) -> void:
	if is_instance_valid(o):
		if !stream_buffer_change.is_connected(o.globaL_update_settings):
			stream_buffer_change.connect(o.globaL_update_settings)
		if !change_node.is_connected(o._on_change_node):
			change_node.connect(o._on_change_node)

		o.flush_value = flush_value

		if update_values:
			o.flush_rate = FLUSH_RATE
			o.buffer_size = BUFFER_SIZE
