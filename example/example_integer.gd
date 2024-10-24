@icon("res://addons/gdanti_cheats/icon.png")
extends Control

var secure_int : IntStream = IntStream.new()
var unsecure_int : int = 0

func _on_add_secure_pressed() -> void:
	secure_int.value += 1
	update_gui()


func _on_minus_secure_pressed() -> void:
	secure_int.value -= 1
	update_gui()


func _on_minus_unsecure_pressed() -> void:
	unsecure_int -= 1
	update_gui()


func _on_add_unsecure_pressed() -> void:
	unsecure_int += 1
	update_gui()

func update_gui() -> void:
	$MarginContainer/VB/HBoxContainer/Unsecure/value.text = str(unsecure_int)
	$MarginContainer/VB/HBoxContainer/Secure/value.text = str(secure_int.value)
