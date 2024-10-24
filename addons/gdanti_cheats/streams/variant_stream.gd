class_name VariantStream extends StreamValue
var value : Variant:
	set(e):
		set_stream(value)
	get:
		return get_stream()

func _init_value() -> void:
	_slot[_idx].set_value(null)
