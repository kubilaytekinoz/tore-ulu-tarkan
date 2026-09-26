extends Control

const GOLD: Color = Color("#d3aa5b")
const GOLD_BRIGHT: Color = Color("#f0d79a")
const GOLD_DARK: Color = Color("#6d512f")
const BG: Color = Color("#05080d")
const PANEL: Color = Color("#0b121a")
const PANEL_2: Color = Color("#111b28")
const TEXT: Color = Color("#f2eadc")
const MUTED: Color = Color("#98a4b2")
const GREEN: Color = Color("#17513f")
const RED: Color = Color("#672b31")
const TRACK: Color = Color("#202a36")
const KUT_FILL: Color = Color("#d9b96f")
const HALK_FILL: Color = Color("#79c7a0")
const ORDU_FILL: Color = Color("#c96d69")
const HAZINE_FILL: Color = Color("#7aa8be")

const CHARACTER_PORTRAITS: Dictionary = {
    "BÖRÜ KAĞAN": "res://assets/characters/boru_kagan_v2.webp",
    "ALTUN HATUN": "res://assets/characters/altun_hatun_main.webp",
    "ALP ŞAD": "res://assets/characters/alp_shad_main.webp",
    "KARA YABGU": "res://assets/characters/kara_yabgu_main.webp",
    "AK BÖRÜ": "res://assets/characters/ak_boru_main.webp"
}

const CHARACTER_DESCRIPTIONS: Dictionary = {
    "BÖRÜ KAĞAN": "Kağan  •  Töre'nin sahibi",
    "ALTUN HATUN": "Hatun  •  Sarayın güçlü sesi",
    "ALP ŞAD": "Şad  •  Sınır ordularının kumandanı",
    "KARA YABGU": "Yabgu  •  Batı kanadının kudretli beyi",
    "AK BÖRÜ": "Kam  •  Bozkırın bilgesi"
}

var stats: Dictionary = {"kut":61, "halk":54, "ordu":67, "hazine":46, "guven":58}
var year: int = 682
var season: String = "Sonbahar"
var cards: Array = []
var card_lookup: Dictionary = {}
var scenario_start: String = ""
var current_card_id: String = ""
var turn_no: int = 0
var story_state: Dictionary = {
    "boy_anger": 0,
    "kara_power": 0,
    "kara_anger": 0,
    "alp_loyalty": 0,
    "altun_influence": 0,
    "guard_loyalty": 0,
    "plot": 0,
    "arslan_support": 0
}

var menu_layer: Control
var game_layer: Control
var stat_bars: Dictionary = {}
var stat_states: Dictionary = {}
var trust_label: Label
var year_label: Label
var speaker_label: Label
var card_text: Label
var feedback_label: Label
var left_button: Button
var right_button: Button
var portrait: TextureRect
var ruler_name: Label
var ruler_desc: Label
var intro_overlay: Control
var intro_title: Label
var intro_text: Label
var intro_button: Button

func _ready() -> void:
    _build_background()
    _build_menu()
    _build_game()
    _load_cards()
    _show_menu()

func _build_background() -> void:
    var bg: ColorRect = ColorRect.new()
    bg.color = BG
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(bg)

func _build_menu() -> void:
    menu_layer = Control.new()
    menu_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(menu_layer)

    var landscape: TextureRect = TextureRect.new()
    landscape.texture = load("res://assets/ui/steppe_header.svg") as Texture2D
    landscape.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    landscape.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    landscape.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    landscape.mouse_filter = Control.MOUSE_FILTER_IGNORE
    menu_layer.add_child(landscape)

    var darkness: ColorRect = ColorRect.new()
    darkness.color = Color(0.01, 0.02, 0.03, 0.52)
    darkness.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    darkness.mouse_filter = Control.MOUSE_FILTER_IGNORE
    menu_layer.add_child(darkness)

    var bottom_fade: ColorRect = ColorRect.new()
    bottom_fade.color = Color(0.01, 0.015, 0.02, 0.78)
    bottom_fade.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
    bottom_fade.offset_top = -780
    bottom_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
    menu_layer.add_child(bottom_fade)

    var safe: MarginContainer = MarginContainer.new()
    safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    safe.add_theme_constant_override("margin_left", 74)
    safe.add_theme_constant_override("margin_right", 74)
    safe.add_theme_constant_override("margin_top", 120)
    safe.add_theme_constant_override("margin_bottom", 84)
    menu_layer.add_child(safe)

    var col: VBoxContainer = VBoxContainer.new()
    col.alignment = BoxContainer.ALIGNMENT_CENTER
    col.add_theme_constant_override("separation", 20)
    safe.add_child(col)

    var top_space: Control = Control.new()
    top_space.custom_minimum_size = Vector2(0, 120)
    col.add_child(top_space)

    var logo_wrap: CenterContainer = CenterContainer.new()
    logo_wrap.custom_minimum_size = Vector2(0, 138)
    col.add_child(logo_wrap)

    var logo: TextureRect = TextureRect.new()
    logo.texture = load("res://assets/ui/wolf_emblem.svg") as Texture2D
    logo.custom_minimum_size = Vector2(120, 120)
    logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    logo_wrap.add_child(logo)

    var title: Label = Label.new()
    title.text = "TÖRE"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 120)
    title.add_theme_color_override("font_color", GOLD_BRIGHT)
    col.add_child(title)

    var subtitle: Label = Label.new()
    subtitle.text = "U L U   T A R K A N"
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.add_theme_font_size_override("font_size", 28)
    subtitle.add_theme_color_override("font_color", GOLD)
    col.add_child(subtitle)

    var motto: Label = Label.new()
    motto.text = "Kağanlar değişir. Töre kalır."
    motto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    motto.add_theme_font_size_override("font_size", 26)
    motto.add_theme_color_override("font_color", TEXT)
    col.add_child(motto)

    var middle_space: Control = Control.new()
    middle_space.size_flags_vertical = Control.SIZE_EXPAND_FILL
    col.add_child(middle_space)

    var start: Button = Button.new()
    start.text = "YENİ KAĞANLIK"
    start.custom_minimum_size = Vector2(0, 112)
    start.add_theme_font_size_override("font_size", 30)
    _style_button(start, Color("#15382e"), GOLD_BRIGHT, GOLD)
    start.pressed.connect(_start_game)
    col.add_child(start)

    var continue_btn: Button = Button.new()
    continue_btn.text = "DEVAM ET  •  YAKINDA"
    continue_btn.disabled = true
    continue_btn.custom_minimum_size = Vector2(0, 94)
    continue_btn.add_theme_font_size_override("font_size", 24)
    _style_button(continue_btn, Color("#151d27"), MUTED, Color("#3b4755"))
    col.add_child(continue_btn)

    var settings_btn: Button = Button.new()
    settings_btn.text = "AYARLAR  •  YAKINDA"
    settings_btn.disabled = true
    settings_btn.custom_minimum_size = Vector2(0, 86)
    settings_btn.add_theme_font_size_override("font_size", 22)
    _style_button(settings_btn, Color("#111820"), MUTED, Color("#343d47"))
    col.add_child(settings_btn)

    var version: Label = Label.new()
    version.text = "PROTOTİP  •  v0.8"
    version.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    version.add_theme_font_size_override("font_size", 18)
    version.add_theme_color_override("font_color", Color("#687483"))
    col.add_child(version)

func _build_game() -> void:
    game_layer = Control.new()
    game_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(game_layer)

    var top_art: TextureRect = TextureRect.new()
    top_art.texture = load("res://assets/ui/steppe_header.svg") as Texture2D
    top_art.set_anchors_preset(Control.PRESET_TOP_WIDE)
    top_art.offset_bottom = 330
    top_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    top_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    top_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
    game_layer.add_child(top_art)

    var top_shade: ColorRect = ColorRect.new()
    top_shade.color = Color(0.01, 0.02, 0.03, 0.34)
    top_shade.set_anchors_preset(Control.PRESET_TOP_WIDE)
    top_shade.offset_bottom = 330
    top_shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
    game_layer.add_child(top_shade)

    var safe: MarginContainer = MarginContainer.new()
    safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    safe.add_theme_constant_override("margin_left", 34)
    safe.add_theme_constant_override("margin_right", 34)
    safe.add_theme_constant_override("margin_top", 26)
    safe.add_theme_constant_override("margin_bottom", 30)
    game_layer.add_child(safe)

    var col: VBoxContainer = VBoxContainer.new()
    col.add_theme_constant_override("separation", 10)
    safe.add_child(col)

    var header: HBoxContainer = HBoxContainer.new()
    header.custom_minimum_size = Vector2(0, 72)
    header.add_theme_constant_override("separation", 12)
    col.add_child(header)

    var logo: TextureRect = TextureRect.new()
    logo.texture = load("res://assets/ui/wolf_emblem.svg") as Texture2D
    logo.custom_minimum_size = Vector2(54, 54)
    logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    header.add_child(logo)

    var brand: VBoxContainer = VBoxContainer.new()
    brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    brand.add_theme_constant_override("separation", -4)
    header.add_child(brand)

    var game_title: Label = Label.new()
    game_title.text = "TÖRE"
    game_title.add_theme_font_size_override("font_size", 42)
    game_title.add_theme_color_override("font_color", GOLD_BRIGHT)
    brand.add_child(game_title)

    var game_subtitle: Label = Label.new()
    game_subtitle.text = "ULU TARKAN"
    game_subtitle.add_theme_font_size_override("font_size", 12)
    game_subtitle.add_theme_color_override("font_color", GOLD)
    brand.add_child(game_subtitle)

    year_label = Label.new()
    year_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    year_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    year_label.add_theme_font_size_override("font_size", 22)
    year_label.add_theme_color_override("font_color", TEXT)
    header.add_child(year_label)

    var home: Button = Button.new()
    home.text = "☰"
    home.custom_minimum_size = Vector2(58, 54)
    home.add_theme_font_size_override("font_size", 24)
    _style_button(home, Color("#0e151e"), GOLD_BRIGHT, GOLD_DARK)
    home.pressed.connect(_show_menu)
    header.add_child(home)

    var stats_panel: PanelContainer = PanelContainer.new()
    stats_panel.custom_minimum_size = Vector2(0, 132)
    stats_panel.add_theme_stylebox_override("panel", _panel_style(Color("#071019e8"), GOLD_DARK, 2, 14))
    col.add_child(stats_panel)

    var stats_pad: MarginContainer = MarginContainer.new()
    stats_pad.add_theme_constant_override("margin_left", 14)
    stats_pad.add_theme_constant_override("margin_right", 14)
    stats_pad.add_theme_constant_override("margin_top", 12)
    stats_pad.add_theme_constant_override("margin_bottom", 12)
    stats_panel.add_child(stats_pad)

    var stats_grid: GridContainer = GridContainer.new()
    stats_grid.columns = 4
    stats_grid.add_theme_constant_override("h_separation", 10)
    stats_pad.add_child(stats_grid)

    _make_stat(stats_grid, "Kut", "kut", KUT_FILL)
    _make_stat(stats_grid, "Halk", "halk", HALK_FILL)
    _make_stat(stats_grid, "Ordu", "ordu", ORDU_FILL)
    _make_stat(stats_grid, "Hazine", "hazine", HAZINE_FILL)

    var trust: PanelContainer = PanelContainer.new()
    trust.custom_minimum_size = Vector2(0, 62)
    trust.add_theme_stylebox_override("panel", _panel_style(Color("#09121ae8"), Color("#4c3d29"), 1, 10))
    col.add_child(trust)

    var trust_row: HBoxContainer = HBoxContainer.new()
    trust_row.add_theme_constant_override("separation", 10)
    trust.add_child(trust_row)

    var trust_icon: Label = Label.new()
    trust_icon.text = "◆"
    trust_icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    trust_icon.add_theme_font_size_override("font_size", 18)
    trust_icon.add_theme_color_override("font_color", GOLD)
    trust_row.add_child(trust_icon)

    var trust_text: Label = Label.new()
    trust_text.text = "Kağanın sana bakışı"
    trust_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    trust_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    trust_text.add_theme_font_size_override("font_size", 18)
    trust_text.add_theme_color_override("font_color", TEXT)
    trust_row.add_child(trust_text)

    trust_label = Label.new()
    trust_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    trust_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    trust_label.add_theme_font_size_override("font_size", 20)
    trust_row.add_child(trust_label)

    var portrait_panel: PanelContainer = PanelContainer.new()
    portrait_panel.custom_minimum_size = Vector2(0, 640)
    portrait_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
    portrait_panel.add_theme_stylebox_override("panel", _panel_style(Color("#0c121a"), GOLD, 2, 18))
    col.add_child(portrait_panel)

    var portrait_stack: Control = Control.new()
    portrait_stack.custom_minimum_size = Vector2(0, 640)
    portrait_panel.add_child(portrait_stack)

    portrait = TextureRect.new()
    portrait.texture = load("res://assets/characters/boru_kagan_v2.webp") as Texture2D
    portrait.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
    portrait_stack.add_child(portrait)

    var name_fade: ColorRect = ColorRect.new()
    name_fade.color = Color(0.01, 0.015, 0.02, 0.74)
    name_fade.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
    name_fade.offset_top = -128
    name_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
    portrait_stack.add_child(name_fade)

    var name_box: VBoxContainer = VBoxContainer.new()
    name_box.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
    name_box.offset_top = -112
    name_box.offset_bottom = -18
    name_box.alignment = BoxContainer.ALIGNMENT_CENTER
    name_box.add_theme_constant_override("separation", 2)
    portrait_stack.add_child(name_box)

    ruler_name = Label.new()
    ruler_name.text = "BÖRÜ KAĞAN"
    ruler_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    ruler_name.add_theme_font_size_override("font_size", 32)
    ruler_name.add_theme_color_override("font_color", GOLD_BRIGHT)
    name_box.add_child(ruler_name)

    ruler_desc = Label.new()
    ruler_desc.text = "Kağan  •  Töre'nin sahibi"
    ruler_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    ruler_desc.add_theme_font_size_override("font_size", 18)
    ruler_desc.add_theme_color_override("font_color", MUTED)
    name_box.add_child(ruler_desc)

    var card: PanelContainer = PanelContainer.new()
    card.custom_minimum_size = Vector2(0, 328)
    card.add_theme_stylebox_override("panel", _panel_style(Color("#081019f6"), GOLD_DARK, 2, 16))
    col.add_child(card)

    var card_pad: MarginContainer = MarginContainer.new()
    card_pad.add_theme_constant_override("margin_left", 28)
    card_pad.add_theme_constant_override("margin_right", 28)
    card_pad.add_theme_constant_override("margin_top", 22)
    card_pad.add_theme_constant_override("margin_bottom", 20)
    card.add_child(card_pad)

    var card_col: VBoxContainer = VBoxContainer.new()
    card_col.add_theme_constant_override("separation", 12)
    card_pad.add_child(card_col)

    speaker_label = Label.new()
    speaker_label.add_theme_font_size_override("font_size", 22)
    speaker_label.add_theme_color_override("font_color", GOLD)
    card_col.add_child(speaker_label)

    var divider: HSeparator = HSeparator.new()
    divider.add_theme_color_override("separator", Color("#5d482c"))
    card_col.add_child(divider)

    card_text = Label.new()
    card_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
    card_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    card_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    card_text.add_theme_font_size_override("font_size", 27)
    card_text.add_theme_color_override("font_color", TEXT)
    card_col.add_child(card_text)

    feedback_label = Label.new()
    feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    feedback_label.add_theme_font_size_override("font_size", 17)
    feedback_label.add_theme_color_override("font_color", MUTED)
    card_col.add_child(feedback_label)

    var choices: HBoxContainer = HBoxContainer.new()
    choices.custom_minimum_size = Vector2(0, 126)
    choices.add_theme_constant_override("separation", 12)
    col.add_child(choices)

    left_button = Button.new()
    left_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    left_button.add_theme_font_size_override("font_size", 20)
    left_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _style_button(left_button, GREEN, TEXT, Color("#9f8050"))
    left_button.pressed.connect(func() -> void: _choose("left"))
    choices.add_child(left_button)

    right_button = Button.new()
    right_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    right_button.add_theme_font_size_override("font_size", 20)
    right_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _style_button(right_button, RED, TEXT, Color("#9f8050"))
    right_button.pressed.connect(func() -> void: _choose("right"))
    choices.add_child(right_button)

    _build_intro()

func _build_intro() -> void:
    intro_overlay = Control.new()
    intro_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    intro_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
    intro_overlay.z_index = 100
    intro_overlay.visible = false
    game_layer.add_child(intro_overlay)

    var shade: ColorRect = ColorRect.new()
    shade.color = Color(0.01, 0.015, 0.02, 0.94)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    shade.mouse_filter = Control.MOUSE_FILTER_STOP
    intro_overlay.add_child(shade)

    var center: CenterContainer = CenterContainer.new()
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    center.mouse_filter = Control.MOUSE_FILTER_IGNORE
    intro_overlay.add_child(center)

    var intro_panel: PanelContainer = PanelContainer.new()
    intro_panel.custom_minimum_size = Vector2(860, 760)
    intro_panel.add_theme_stylebox_override("panel", _panel_style(Color("#081019f2"), GOLD, 2, 24))
    center.add_child(intro_panel)

    var pad: MarginContainer = MarginContainer.new()
    pad.add_theme_constant_override("margin_left", 64)
    pad.add_theme_constant_override("margin_right", 64)
    pad.add_theme_constant_override("margin_top", 54)
    pad.add_theme_constant_override("margin_bottom", 54)
    intro_panel.add_child(pad)

    var col: VBoxContainer = VBoxContainer.new()
    col.alignment = BoxContainer.ALIGNMENT_CENTER
    col.add_theme_constant_override("separation", 24)
    pad.add_child(col)

    var emblem_wrap: CenterContainer = CenterContainer.new()
    emblem_wrap.custom_minimum_size = Vector2(0, 110)
    col.add_child(emblem_wrap)

    var emblem: TextureRect = TextureRect.new()
    emblem.texture = load("res://assets/ui/wolf_emblem.svg") as Texture2D
    emblem.custom_minimum_size = Vector2(96, 96)
    emblem.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    emblem.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    emblem_wrap.add_child(emblem)

    var era: Label = Label.new()
    era.text = "682  •  SONBAHAR"
    era.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    era.add_theme_font_size_override("font_size", 20)
    era.add_theme_color_override("font_color", GOLD)
    col.add_child(era)

    intro_title = Label.new()
    intro_title.text = "HOŞ GELDİN, ULU TARKAN"
    intro_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    intro_title.add_theme_font_size_override("font_size", 46)
    intro_title.add_theme_color_override("font_color", GOLD_BRIGHT)
    col.add_child(intro_title)

    var divider: HSeparator = HSeparator.new()
    divider.add_theme_color_override("separator", Color("#72572f"))
    col.add_child(divider)

    intro_text = Label.new()
    intro_text.text = "Beylik seni bekler.\n\nKağana yol göstermek, oba gütmek ve boyları bir arada tutmak kolay değildir.\n\nBir sözün savaşı başlatabilir; bir kararın açlığı dindirebilir. Dost bildiğin bey düşmana, kuşku duyduğun kişi en sadık yoldaşına dönüşebilir.\n\nKağanlar değişir. Töre kalır."
    intro_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    intro_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    intro_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    intro_text.add_theme_font_size_override("font_size", 27)
    intro_text.add_theme_color_override("font_color", TEXT)
    intro_text.custom_minimum_size = Vector2(700, 330)
    col.add_child(intro_text)

    intro_button = Button.new()
    intro_button.text = "TÖREYE ADIM AT"
    intro_button.custom_minimum_size = Vector2(0, 104)
    intro_button.add_theme_font_size_override("font_size", 25)
    _style_button(intro_button, Color("#15382e"), GOLD_BRIGHT, GOLD)
    intro_button.pressed.connect(_dismiss_intro)
    col.add_child(intro_button)

func _play_intro() -> void:
    intro_overlay.visible = true
    intro_overlay.modulate = Color(1, 1, 1, 0)
    intro_title.modulate = Color(1, 1, 1, 0)
    intro_text.modulate = Color(1, 1, 1, 0)
    intro_button.modulate = Color(1, 1, 1, 0)
    intro_button.disabled = true

    var tween: Tween = create_tween()
    tween.tween_property(intro_overlay, "modulate:a", 1.0, 0.35)
    tween.tween_property(intro_title, "modulate:a", 1.0, 0.45)
    tween.tween_interval(0.12)
    tween.tween_property(intro_text, "modulate:a", 1.0, 0.65)
    tween.tween_interval(0.18)
    tween.tween_property(intro_button, "modulate:a", 1.0, 0.4)
    await tween.finished
    intro_button.disabled = false

func _dismiss_intro() -> void:
    intro_button.disabled = true
    var tween: Tween = create_tween()
    tween.tween_property(intro_overlay, "modulate:a", 0.0, 0.35)
    await tween.finished
    intro_overlay.visible = false
    intro_button.disabled = false

func _load_cards() -> void:
    var file: FileAccess = FileAccess.open("res://data/cards.json", FileAccess.READ)
    if file == null:
        push_error("cards.json açılamadı.")
        return

    var parsed: Variant = JSON.parse_string(file.get_as_text())
    card_lookup.clear()
    cards.clear()

    if parsed is Dictionary:
        var scenario: Dictionary = parsed as Dictionary
        scenario_start = str(scenario.get("start_id", ""))
        var loaded_cards: Array = scenario.get("cards", []) as Array
        cards = loaded_cards
        for item: Variant in loaded_cards:
            var card: Dictionary = item as Dictionary
            card_lookup[str(card.get("id", ""))] = card
    elif parsed is Array:
        cards = parsed as Array
        for item: Variant in cards:
            var card: Dictionary = item as Dictionary
            var id: String = str(card.get("id", ""))
            card_lookup[id] = card
            if scenario_start.is_empty():
                scenario_start = id
    else:
        push_error("cards.json geçerli bir senaryo değil.")

func _show_menu() -> void:
    menu_layer.visible = true
    game_layer.visible = false

func _start_game() -> void:
    stats = {"kut":61, "halk":54, "ordu":67, "hazine":46, "guven":58}
    story_state = {
        "boy_anger": 0,
        "kara_power": 0,
        "kara_anger": 0,
        "alp_loyalty": 0,
        "altun_influence": 0,
        "guard_loyalty": 0,
        "plot": 0,
        "arslan_support": 0
    }
    year = 682
    season = "Sonbahar"
    turn_no = 0
    current_card_id = scenario_start
    menu_layer.visible = false
    game_layer.visible = true
    _refresh_stats()
    _show_card()
    _play_intro()

func _show_card() -> void:
    if card_lookup.is_empty() or current_card_id.is_empty() or not card_lookup.has(current_card_id):
        speaker_label.text = "TÖRE"
        card_text.text = "Senaryonun yolu burada kayboldu."
        left_button.disabled = true
        right_button.disabled = true
        return

    var card: Dictionary = card_lookup[current_card_id] as Dictionary
    var left_data: Dictionary = card.get("left", {}) as Dictionary
    var right_data: Dictionary = card.get("right", {}) as Dictionary

    if card.has("year"):
        year = int(card["year"])
    if card.has("season"):
        season = str(card["season"])

    var speaker: String = str(card.get("speaker", "BÖRÜ KAĞAN"))
    speaker_label.text = speaker
    _set_character(speaker)
    card_text.text = "“" + str(card.get("text", "")) + "”"

    var is_ending: bool = bool(card.get("ending", false))
    if is_ending:
        feedback_label.text = str(card.get("ending_title", "KAĞANLIK YILLIĞI"))
        left_button.text = "YENİDEN BAŞLA"
        right_button.text = "ANA MENÜ"
        left_button.disabled = false
        right_button.disabled = false
    else:
        left_button.text = "←  " + str(left_data.get("text", ""))
        right_button.text = str(right_data.get("text", "")) + "  →"
        feedback_label.text = str(card.get("hint", "Kararını ver, Ulu Tarkan."))

    _refresh_year()

func _set_character(character_name: String) -> void:
    var portrait_path: String = str(CHARACTER_PORTRAITS.get(character_name, CHARACTER_PORTRAITS["BÖRÜ KAĞAN"]))
    var texture: Texture2D = load(portrait_path) as Texture2D
    if texture != null:
        portrait.texture = texture

    ruler_name.text = character_name
    ruler_desc.text = str(CHARACTER_DESCRIPTIONS.get(character_name, "Bozkırın konuğu"))

func _choose(side: String) -> void:
    if current_card_id.is_empty() or not card_lookup.has(current_card_id):
        return

    var card: Dictionary = card_lookup[current_card_id] as Dictionary

    if bool(card.get("ending", false)):
        if side == "left":
            _start_game()
        else:
            _show_menu()
        return

    var choice: Dictionary = card.get(side, {}) as Dictionary
    var effects: Dictionary = choice.get("effects", {}) as Dictionary
    var hidden: Dictionary = choice.get("state", {}) as Dictionary

    for key: Variant in effects.keys():
        if stats.has(key):
            stats[key] = clampi(int(stats[key]) + int(effects[key]), 0, 100)

    for key: Variant in hidden.keys():
        story_state[key] = int(story_state.get(key, 0)) + int(hidden[key])

    feedback_label.text = _effects_text(effects)
    _refresh_stats()
    turn_no += 1

    var next_id: String = _resolve_next(choice.get("next", ""))
    if next_id.is_empty():
        next_id = _resolve_next(card.get("next", ""))

    left_button.disabled = true
    right_button.disabled = true
    await get_tree().create_timer(0.5).timeout
    left_button.disabled = false
    right_button.disabled = false

    current_card_id = next_id
    _show_card()

func _resolve_next(next_value: Variant) -> String:
    if next_value is String:
        return str(next_value)

    if next_value is Array:
        var routes: Array = next_value as Array
        for route_variant: Variant in routes:
            var route: Dictionary = route_variant as Dictionary
            if not route.has("when") or _condition_matches(route.get("when", {}) as Dictionary):
                return str(route.get("id", ""))

    return ""

func _condition_matches(condition: Dictionary) -> bool:
    if condition.is_empty():
        return true

    if condition.has("all"):
        var all_conditions: Array = condition["all"] as Array
        for item: Variant in all_conditions:
            if not _condition_matches(item as Dictionary):
                return false
        return true

    if condition.has("any"):
        var any_conditions: Array = condition["any"] as Array
        for item: Variant in any_conditions:
            if _condition_matches(item as Dictionary):
                return true
        return false

    var key: String = str(condition.get("key", ""))
    var source: String = str(condition.get("source", "story"))
    var value: int = int(story_state.get(key, 0))
    if source == "stats":
        value = int(stats.get(key, 0))

    if condition.has("gte") and value < int(condition["gte"]):
        return false
    if condition.has("lte") and value > int(condition["lte"]):
        return false
    if condition.has("gt") and value <= int(condition["gt"]):
        return false
    if condition.has("lt") and value >= int(condition["lt"]):
        return false
    if condition.has("eq") and value != int(condition["eq"]):
        return false

    return true

func _effects_text(effects: Dictionary) -> String:
    var names: Dictionary = {"kut":"Kut", "halk":"Halk", "ordu":"Ordu", "hazine":"Hazine", "guven":"Kağanın güveni"}
    var parts: Array[String] = []

    for key: Variant in effects.keys():
        var value: int = int(effects[key])
        if value == 0:
            continue

        var magnitude: int = absi(value)
        var arrows: String = "↑" if value > 0 else "↓"
        if magnitude >= 8:
            arrows = arrows + arrows + arrows
        elif magnitude >= 4:
            arrows = arrows + arrows

        parts.append("%s %s" % [str(names.get(key, key)), arrows])

    return "   •   ".join(parts)

func _refresh_stats() -> void:
    for key: Variant in stat_bars.keys():
        var bar: ProgressBar = stat_bars[key] as ProgressBar
        bar.value = float(stats[key])

    for key: Variant in stat_states.keys():
        var state: Label = stat_states[key] as Label
        state.text = _resource_state(int(stats[key]))

    trust_label.text = _trust_state(int(stats["guven"]))
    trust_label.add_theme_color_override("font_color", _trust_color(int(stats["guven"])))

func _refresh_year() -> void:
    year_label.text = "%d  •  %s" % [year, season]

func _make_stat(parent: GridContainer, title_text: String, key: String, fill_color: Color) -> void:
    var box: VBoxContainer = VBoxContainer.new()
    box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    box.alignment = BoxContainer.ALIGNMENT_CENTER
    box.add_theme_constant_override("separation", 7)
    parent.add_child(box)

    var title: Label = Label.new()
    title.text = title_text
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 17)
    title.add_theme_color_override("font_color", TEXT)
    box.add_child(title)

    var bar: ProgressBar = ProgressBar.new()
    bar.min_value = 0
    bar.max_value = 100
    bar.value = float(stats[key])
    bar.show_percentage = false
    bar.custom_minimum_size = Vector2(0, 13)
    bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    bar.add_theme_stylebox_override("background", _bar_style(TRACK, 7))
    bar.add_theme_stylebox_override("fill", _bar_style(fill_color, 7))
    box.add_child(bar)
    stat_bars[key] = bar

    var state: Label = Label.new()
    state.text = _resource_state(int(stats[key]))
    state.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    state.add_theme_font_size_override("font_size", 15)
    state.add_theme_color_override("font_color", MUTED)
    box.add_child(state)
    stat_states[key] = state

func _resource_state(value: int) -> String:
    if value < 20:
        return "Çöküşte"
    if value < 40:
        return "Kırılgan"
    if value < 65:
        return "Dengeli"
    if value < 85:
        return "Güçlü"
    return "Çok güçlü"

func _trust_state(value: int) -> String:
    if value < 15:
        return "Seni düşman görüyor"
    if value < 30:
        return "Senden şüpheleniyor"
    if value < 50:
        return "Sana karşı temkinli"
    if value < 70:
        return "Sana güveniyor"
    if value < 90:
        return "Sözüne değer veriyor"
    return "En yakın sırdaşısın"

func _trust_color(value: int) -> Color:
    if value < 30:
        return Color("#d47777")
    if value < 50:
        return Color("#d6aa70")
    if value < 70:
        return GOLD_BRIGHT
    return Color("#8fd0a9")

func _style_button(button: Button, base: Color, font_color: Color, border: Color) -> void:
    var normal: StyleBoxFlat = _panel_style(base, border, 2, 14)
    var hover: StyleBoxFlat = _panel_style(base.lightened(0.07), GOLD_BRIGHT, 2, 14)
    var pressed: StyleBoxFlat = _panel_style(base.darkened(0.09), GOLD, 2, 14)

    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", hover)
    button.add_theme_stylebox_override("pressed", pressed)
    button.add_theme_stylebox_override("focus", hover)
    button.add_theme_color_override("font_color", font_color)
    button.add_theme_color_override("font_hover_color", TEXT)
    button.add_theme_color_override("font_pressed_color", TEXT)

func _panel_style(bg: Color, border: Color, border_width: int, radius: int) -> StyleBoxFlat:
    var style: StyleBoxFlat = StyleBoxFlat.new()
    style.bg_color = bg
    style.border_color = border
    style.set_border_width_all(border_width)
    style.corner_radius_top_left = radius
    style.corner_radius_top_right = radius
    style.corner_radius_bottom_left = radius
    style.corner_radius_bottom_right = radius
    style.content_margin_left = 18
    style.content_margin_right = 18
    style.content_margin_top = 14
    style.content_margin_bottom = 14
    return style

func _bar_style(color: Color, radius: int) -> StyleBoxFlat:
    var style: StyleBoxFlat = StyleBoxFlat.new()
    style.bg_color = color
    style.corner_radius_top_left = radius
    style.corner_radius_top_right = radius
    style.corner_radius_bottom_left = radius
    style.corner_radius_bottom_right = radius
    return style
