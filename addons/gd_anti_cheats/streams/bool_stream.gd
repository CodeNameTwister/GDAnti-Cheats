class_name BoolStream extends StreamValue
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#	GDAnti-Cheats
#
#	https://github.com/CodeNameTwister/GDAnti-Cheats
#	author:	"Twister"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
var value : bool:
	set(e):
		set_stream(e)
	get:
		return get_stream()

func _init_value() -> void:
	_slot[_idx].set_value(false)
