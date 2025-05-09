extends Node2D

@export var uis: Array[Control]


func _on_item_list_item_selected(index):
	for i in uis.size():
		if i == index:
			uis[i].show()
		else:
			uis[i].hide()
