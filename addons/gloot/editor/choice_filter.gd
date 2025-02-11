extends Control
tool

signal choice_picked
signal choice_selected


onready var lbl_filter: Label = $HBoxContainer/Label
onready var line_edit: LineEdit = $HBoxContainer/LineEdit
onready var item_list: ItemList = $ItemList
onready var btn_pick: Button = $Button
export(bool) var pick_button_visible: bool = true setget _set_pick_button_visible
export(String) var pick_text: String setget _set_pick_text
export(Texture) var pick_icon: Texture setget _set_pick_icon
export(String) var filter_text: String = "Filter:" setget _set_filter_text
export(Texture) var filter_icon: Texture setget _set_filter_icon
export(Array, String) var values: Array setget _set_values


func _set_values(new_values: Array) -> void:
    values = new_values
    refresh()


func _set_pick_button_visible(new_pick_button_visible: bool) -> void:
    pick_button_visible = new_pick_button_visible
    if btn_pick:
        btn_pick.visible = pick_button_visible


func _set_pick_text(new_pick_text: String) -> void:
    pick_text = new_pick_text
    if btn_pick:
        btn_pick.text = pick_text


func _set_pick_icon(new_pick_icon: Texture) -> void:
    pick_icon = new_pick_icon
    if btn_pick:
        btn_pick.icon = pick_icon


func _set_filter_text(new_filter_text: String) -> void:
    filter_text = new_filter_text
    if lbl_filter:
        lbl_filter.text = filter_text


func _set_filter_icon(new_filter_icon: Texture) -> void:
    filter_icon = new_filter_icon
    if line_edit:
        line_edit.right_icon = filter_icon


func refresh() -> void:
    _clear()
    _populate()


func _clear() -> void:
    if item_list:
        item_list.clear()


func _populate() -> void:
    if line_edit == null || item_list == null:
        return

    if values == null || values.size() == 0:
        return

    for value_index in range(values.size()):
        var value = values[value_index]
        assert(value is String, "values must be an array of strings!")

        if !line_edit.text.empty() && !(line_edit.text.to_lower() in value.to_lower()):
            continue

        item_list.add_item(value)
        item_list.set_item_metadata(item_list.get_item_count() - 1, value_index)


func _ready() -> void:
    btn_pick.connect("pressed", self, "_on_btn_pick")
    line_edit.connect("text_changed", self, "_on_filter_text_changed")
    item_list.connect("item_activated", self, "_on_item_activated")
    item_list.connect("item_selected", self, "_on_item_selected")
    refresh()
    if btn_pick:
        btn_pick.text = pick_text
        btn_pick.icon = pick_icon
        btn_pick.visible = pick_button_visible
    if lbl_filter:
        lbl_filter.text = filter_text
    if line_edit:
        line_edit.right_icon = filter_icon


func _on_btn_pick() -> void:
    var selected_items: PoolIntArray = item_list.get_selected_items()
    if selected_items.size() == 0:
        return

    var selected_item = selected_items[0]
    var selected_value_index = item_list.get_item_metadata(selected_item)
    emit_signal("choice_picked", selected_value_index)


func _on_filter_text_changed(_new_text: String) -> void:
    refresh()


func _on_item_activated(index: int) -> void:
    var selected_value_index = item_list.get_item_metadata(index)
    emit_signal("choice_picked", selected_value_index)


func _on_item_selected(index: int) -> void:
    var selected_value_index = item_list.get_item_metadata(index)
    emit_signal("choice_selected", selected_value_index)


func get_selected_item() -> int:
    var selected := item_list.get_selected_items()
    if selected.size() > 0:
        return item_list.get_item_metadata(selected[0])
    return -1


func get_selected_text() -> String:
    var selected := get_selected_item()
    if selected >= 0:
        return values[selected]
        
    return ""
