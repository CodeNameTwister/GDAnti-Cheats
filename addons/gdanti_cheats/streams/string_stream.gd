class_name StringStream extends StreamValue
var value : String:
	set(e):
		set_stream(e)
	get:
		return get_stream()

func _init_value() -> void:
	_slot[_idx].set_value("")
