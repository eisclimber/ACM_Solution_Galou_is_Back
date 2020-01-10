extends Button

export(String, "Add", "Remove") var type = "Add"


func get_drag_data(position):
	set_drag_preview(make_preview())
	return type


func can_drop_data(position, data):
	return true


func make_preview():
	var preview = Control.new()
	var icon = TextureRect.new()
	preview.rect_size = rect_size
	icon.rect_size = rect_size
	icon.rect_position = icon.rect_position - (preview.rect_size / 2)
	icon.texture = self.icon
	preview.add_child(icon)
	return preview