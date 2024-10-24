#GDAntiCheats
@icon("icon.png")
extends Node
signal stream_buffer_change(buffer_size : int, flush_rate : int)

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
var _rnd : RandomNumberGenerator = RandomNumberGenerator.new()

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
			val.set_value(_rnd.randi_range(-2147483648, 2147483647))
			return
		TYPE_FLOAT:
			val.set_value(_rnd.randf_range(-1.795, 1.795))
			return
		TYPE_BOOL:
			val.set_value(bool(_rnd.randi() % 2))
			return
		_:
			val.set_value(null)
			return

func _ready() -> void:
	_garbage_strings.clear()
	var characters : String = 'abcdefghijklmnopqrstuvwxyz'
	for x in range(0, 6):
		var n_char : int = len(characters)
		var word: String = ""
		for i in range(_rnd.randi_range(4, 8)):
			if _rnd.randi() % 2 == 0:
				word += characters[randi()% n_char].to_upper()
			else:
				word += characters[randi()% n_char]
		_garbage_strings.append(word)

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
