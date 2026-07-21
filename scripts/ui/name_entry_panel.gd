extends PanelContainer
## Arcade-style initials entry: three letters, each cycled with up/down
## buttons. Builds its whole UI in code so unit tests can drive it directly.

signal submitted(player_name: String)
signal skipped

const ALPHABET := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
const SLOT_COUNT := 3

var _letters: Array[int] = [0, 0, 0]
var _labels: Array[Label] = []
var _current_slot: int = 0


func _ready() -> void:
	visibility_changed.connect(func() -> void:
		if visible:
			_select_slot(0)
	)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	add_child(vbox)

	var title := Label.new()
	title.text = tr("ENTER_NAME")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Palette.UI_ACCENT)
	title.add_theme_font_size_override("font_size", 12)
	vbox.add_child(title)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 14)
	vbox.add_child(row)

	for slot in range(SLOT_COUNT):
		row.add_child(_build_slot(slot))

	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 10)
	vbox.add_child(buttons)

	var ok_btn := Button.new()
	ok_btn.text = "OK"
	ok_btn.custom_minimum_size = Vector2(80, 26)
	ok_btn.add_theme_font_size_override("font_size", 12)
	ok_btn.focus_mode = Control.FOCUS_NONE
	ok_btn.pressed.connect(func() -> void: submitted.emit(get_player_name()))
	buttons.add_child(ok_btn)

	var skip_btn := Button.new()
	skip_btn.text = tr("SKIP")
	skip_btn.custom_minimum_size = Vector2(80, 26)
	skip_btn.add_theme_font_size_override("font_size", 12)
	skip_btn.focus_mode = Control.FOCUS_NONE
	skip_btn.pressed.connect(func() -> void: skipped.emit())
	buttons.add_child(skip_btn)

	_select_slot(0)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_up"):
		cycle(_current_slot, 1)
	elif event.is_action_pressed("ui_down"):
		cycle(_current_slot, -1)
	elif event.is_action_pressed("ui_right"):
		_select_slot((_current_slot + 1) % SLOT_COUNT)
	elif event.is_action_pressed("ui_left"):
		_select_slot((_current_slot - 1 + SLOT_COUNT) % SLOT_COUNT)
	elif event.is_action_pressed("ui_accept"):
		submitted.emit(get_player_name())


func _select_slot(slot: int) -> void:
	_current_slot = slot
	for i in range(_labels.size()):
		_labels[i].add_theme_color_override(
			"font_color", Palette.UI_ACCENT if i == _current_slot else Palette.UI_TEXT
		)


func _build_slot(slot: int) -> VBoxContainer:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 2)

	var up := Button.new()
	up.text = "^"
	up.custom_minimum_size = Vector2(34, 24)
	up.focus_mode = Control.FOCUS_NONE
	up.pressed.connect(cycle.bind(slot, 1))
	col.add_child(up)

	var letter := Label.new()
	letter.text = ALPHABET[_letters[slot]]
	letter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	letter.add_theme_color_override("font_color", Palette.UI_TEXT)
	letter.add_theme_font_size_override("font_size", 22)
	col.add_child(letter)
	_labels.append(letter)

	var down := Button.new()
	down.text = "v"
	down.custom_minimum_size = Vector2(34, 24)
	down.focus_mode = Control.FOCUS_NONE
	down.pressed.connect(cycle.bind(slot, -1))
	col.add_child(down)
	return col


func cycle(slot: int, delta: int) -> void:
	_letters[slot] = posmod(_letters[slot] + delta, ALPHABET.length())
	if slot < _labels.size():
		_labels[slot].text = ALPHABET[_letters[slot]]


func get_player_name() -> String:
	var out := ""
	for idx in _letters:
		out += ALPHABET[idx]
	return out
