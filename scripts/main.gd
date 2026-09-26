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

const CHARACTERS_PATH: String = "res://data/characters.json"
const DYNASTIES_PATH: String = "res://data/dynasties.json"
const WORLD_STATE_PATH: String = "res://data/world_state.json"
const SCENARIO_INDEX_PATH: String = "res://data/scenarios/index.json"
const RANDOM_EVENTS_PATH: String = "res://data/events/random_events.json"
const CRISIS_EVENTS_PATH: String = "res://data/events/crisis_events.json"
const CARDS_PATH: String = "res://data/cards.json"
const OUTCOME_POOLS_PATH: String = "res://data/outcome_pools.json"

var stats: Dictionary = {"kut":6, "halk":6, "ordu":7, "hazine":5, "guven":6}
var year: int = 682
var season: String = "Sonbahar"
var cards: Array = []
var card_lookup: Dictionary = {}
var characters: Dictionary = {}
var dynasties: Dictionary = {}
var world_defaults: Dictionary = {}
var scenario_index: Dictionary = {}
var random_events: Array = []
var crisis_rules: Array = []
var character_state: Dictionary = {}
var flags: Array[String] = []
var history: Array[Dictionary] = []
var current_era_id: String = ""
var current_ruler_id: String = ""
var scenario_start: String = ""
var current_card_id: String = ""
var turn_no: int = 0
var last_world_event_turn: int = -999
var input_locked: bool = false
var event_overlay_active: bool = false
var event_queue: Array[Dictionary] = []
var presented_important: Array[String] = []
var v3_mode: bool = false
var outcome_pools: Dictionary = {}
var relationships: Dictionary = {}
var seen_cards: Dictionary = {}
var last_card_year: Dictionary = {}
var pending_game_over: bool = false
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
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
var card_panel: PanelContainer
var choices_container: HBoxContainer
var portrait: TextureRect
var ruler_name: Label
var ruler_desc: Label
var intro_overlay: Control
var intro_title: Label
var intro_text: Label
var intro_button: Button
var event_overlay: Control
var event_kicker_label: Label
var event_title_label: Label
var event_body_label: Label
var event_effects_label: Label
var event_button: Button

func _ready() -> void:
    rng.randomize()
    _build_background()
    _build_menu()
    _build_game()
    _load_game_data()
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
    version.text = "PROTOTİP  •  v1.3"
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

    card_panel = PanelContainer.new()
    card_panel.custom_minimum_size = Vector2(0, 328)
    card_panel.add_theme_stylebox_override("panel", _panel_style(Color("#081019f6"), GOLD_DARK, 2, 16))
    col.add_child(card_panel)

    var card_pad: MarginContainer = MarginContainer.new()
    card_pad.add_theme_constant_override("margin_left", 28)
    card_pad.add_theme_constant_override("margin_right", 28)
    card_pad.add_theme_constant_override("margin_top", 22)
    card_pad.add_theme_constant_override("margin_bottom", 20)
    card_panel.add_child(card_pad)

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

    choices_container = HBoxContainer.new()
    choices_container.custom_minimum_size = Vector2(0, 126)
    choices_container.add_theme_constant_override("separation", 12)
    col.add_child(choices_container)

    left_button = Button.new()
    left_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    left_button.add_theme_font_size_override("font_size", 20)
    left_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _style_button(left_button, GREEN, TEXT, Color("#9f8050"))
    left_button.pressed.connect(func() -> void: _choose("left"))
    choices_container.add_child(left_button)

    right_button = Button.new()
    right_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    right_button.add_theme_font_size_override("font_size", 20)
    right_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _style_button(right_button, RED, TEXT, Color("#9f8050"))
    right_button.pressed.connect(func() -> void: _choose("right"))
    choices_container.add_child(right_button)

    _build_intro()
    _build_event_overlay()

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

func _build_event_overlay() -> void:
    event_overlay = Control.new()
    event_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    event_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
    event_overlay.z_index = 120
    event_overlay.visible = false
    game_layer.add_child(event_overlay)

    var shade: ColorRect = ColorRect.new()
    shade.color = Color(0.005, 0.008, 0.012, 0.92)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    shade.mouse_filter = Control.MOUSE_FILTER_STOP
    event_overlay.add_child(shade)

    var center: CenterContainer = CenterContainer.new()
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    center.mouse_filter = Control.MOUSE_FILTER_IGNORE
    event_overlay.add_child(center)

    var panel: PanelContainer = PanelContainer.new()
    panel.custom_minimum_size = Vector2(850, 650)
    panel.add_theme_stylebox_override("panel", _panel_style(Color("#081019f5"), GOLD, 2, 24))
    center.add_child(panel)

    var pad: MarginContainer = MarginContainer.new()
    pad.add_theme_constant_override("margin_left", 62)
    pad.add_theme_constant_override("margin_right", 62)
    pad.add_theme_constant_override("margin_top", 54)
    pad.add_theme_constant_override("margin_bottom", 50)
    panel.add_child(pad)

    var col: VBoxContainer = VBoxContainer.new()
    col.alignment = BoxContainer.ALIGNMENT_CENTER
    col.add_theme_constant_override("separation", 22)
    pad.add_child(col)

    event_kicker_label = Label.new()
    event_kicker_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    event_kicker_label.add_theme_font_size_override("font_size", 19)
    event_kicker_label.add_theme_color_override("font_color", GOLD)
    col.add_child(event_kicker_label)

    event_title_label = Label.new()
    event_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    event_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    event_title_label.add_theme_font_size_override("font_size", 46)
    event_title_label.add_theme_color_override("font_color", GOLD_BRIGHT)
    col.add_child(event_title_label)

    var divider: HSeparator = HSeparator.new()
    divider.add_theme_color_override("separator", Color("#72572f"))
    col.add_child(divider)

    event_body_label = Label.new()
    event_body_label.custom_minimum_size = Vector2(700, 280)
    event_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    event_body_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    event_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    event_body_label.add_theme_font_size_override("font_size", 27)
    event_body_label.add_theme_color_override("font_color", TEXT)
    col.add_child(event_body_label)

    event_effects_label = Label.new()
    event_effects_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    event_effects_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    event_effects_label.add_theme_font_size_override("font_size", 21)
    event_effects_label.add_theme_color_override("font_color", MUTED)
    col.add_child(event_effects_label)

    event_button = Button.new()
    event_button.text = "DEVAM ET"
    event_button.custom_minimum_size = Vector2(0, 96)
    event_button.add_theme_font_size_override("font_size", 24)
    _style_button(event_button, Color("#15382e"), GOLD_BRIGHT, GOLD)
    event_button.pressed.connect(_dismiss_event_overlay)
    col.add_child(event_button)

func _queue_event(data: Dictionary) -> void:
    event_queue.append(data)

func _play_next_event() -> void:
    if event_overlay_active:
        return

    if event_queue.is_empty():
        input_locked = false
        _set_choice_buttons_enabled(true)
        return

    input_locked = true
    _set_choice_buttons_enabled(false)
    event_overlay_active = true
    var data: Dictionary = event_queue.pop_front()

    event_kicker_label.text = str(data.get("kicker", "BOZKIRDAN HABER"))
    event_title_label.text = str(data.get("title", "BİR ŞEYLER DEĞİŞİYOR"))
    event_body_label.text = str(data.get("text", ""))
    event_effects_label.text = str(data.get("effects_text", ""))

    var tone: String = str(data.get("tone", "neutral"))
    if tone == "danger":
        event_title_label.add_theme_color_override("font_color", Color("#d9827d"))
    elif tone == "positive":
        event_title_label.add_theme_color_override("font_color", Color("#9fd0ad"))
    else:
        event_title_label.add_theme_color_override("font_color", GOLD_BRIGHT)

    event_overlay.visible = true
    event_overlay.modulate = Color(1, 1, 1, 0)
    event_title_label.modulate = Color(1, 1, 1, 0)
    event_body_label.modulate = Color(1, 1, 1, 0)
    event_effects_label.modulate = Color(1, 1, 1, 0)
    event_button.modulate = Color(1, 1, 1, 0)
    event_button.disabled = true

    var tween: Tween = create_tween()
    tween.tween_property(event_overlay, "modulate:a", 1.0, 0.22)
    tween.tween_property(event_title_label, "modulate:a", 1.0, 0.28)
    tween.parallel().tween_property(event_body_label, "modulate:a", 1.0, 0.38)
    tween.tween_property(event_effects_label, "modulate:a", 1.0, 0.22)
    tween.parallel().tween_property(event_button, "modulate:a", 1.0, 0.22)
    await tween.finished
    event_button.disabled = false

func _dismiss_event_overlay() -> void:
    if not event_overlay_active:
        return

    event_button.disabled = true
    var tween: Tween = create_tween()
    tween.tween_property(event_overlay, "modulate:a", 0.0, 0.20)
    await tween.finished
    event_overlay.visible = false
    event_overlay_active = false

    if not event_queue.is_empty():
        _play_next_event()
    elif pending_game_over:
        pending_game_over = false
        _show_menu()
    else:
        input_locked = false
        _set_choice_buttons_enabled(true)

func _set_choice_buttons_enabled(enabled: bool) -> void:
    left_button.disabled = not enabled
    right_button.disabled = not enabled

func _animate_card_out() -> void:
    var tween: Tween = create_tween()
    tween.tween_property(card_panel, "modulate:a", 0.0, 0.16)
    tween.parallel().tween_property(choices_container, "modulate:a", 0.0, 0.16)
    tween.parallel().tween_property(portrait, "modulate:a", 0.35, 0.16)
    await tween.finished

func _animate_card_in() -> void:
    card_panel.modulate.a = 0.0
    choices_container.modulate.a = 0.0
    portrait.modulate.a = 0.35

    var tween: Tween = create_tween()
    tween.tween_property(portrait, "modulate:a", 1.0, 0.24)
    tween.parallel().tween_property(card_panel, "modulate:a", 1.0, 0.28)
    tween.parallel().tween_property(choices_container, "modulate:a", 1.0, 0.30)
    await tween.finished

func _queue_time_and_world_events(previous_year: int, previous_season: String) -> void:
    if turn_no <= 0:
        return

    if year == previous_year and season == previous_season:
        return

    _maybe_queue_world_event()

func _maybe_queue_world_event() -> void:
    if random_events.is_empty():
        return

    var simulation: Dictionary = world_defaults.get("simulation", {}) as Dictionary
    var chance: float = float(simulation.get("season_event_chance", 0.36))
    var min_gap: int = int(simulation.get("world_event_min_gap_turns", 3))
    if turn_no - last_world_event_turn < min_gap:
        return

    var eligible: Array[Dictionary] = []

    for event_variant: Variant in random_events:
        var event_data: Dictionary = event_variant as Dictionary
        var seasons: Array = event_data.get("seasons", []) as Array
        if not seasons.is_empty() and not seasons.has(season):
            continue

        var event_flag: String = "world_event_%s_%d" % [str(event_data.get("id", "")), year]
        if bool(event_data.get("once_per_year", true)) and flags.has(event_flag):
            continue

        var requires: Dictionary = event_data.get("requires", {}) as Dictionary
        if not requires.is_empty() and not _condition_matches(requires):
            continue

        eligible.append(event_data)

    if eligible.is_empty() or rng.randf() > chance:
        return

    var total_weight: float = 0.0
    for event_data: Dictionary in eligible:
        total_weight += maxf(float(event_data.get("weight", 1.0)), 0.01)

    var pick: float = rng.randf_range(0.0, total_weight)
    var selected: Dictionary = eligible[0]
    for event_data: Dictionary in eligible:
        pick -= maxf(float(event_data.get("weight", 1.0)), 0.01)
        if pick <= 0.0:
            selected = event_data
            break

    var effects: Dictionary = selected.get("effects", {}) as Dictionary
    _apply_stat_effects(effects, true)

    var state_effects: Dictionary = selected.get("state", {}) as Dictionary
    for key: Variant in state_effects.keys():
        story_state[key] = int(story_state.get(key, 0)) + int(state_effects[key])

    last_world_event_turn = turn_no
    _set_flag("world_event_%s_%d" % [str(selected.get("id", "")), year])
    history.append({
        "year": year,
        "season": season,
        "era": current_era_id,
        "event": str(selected.get("id", "")),
        "choice": "world"
    })

    _queue_event({
        "kicker": str(selected.get("kicker", "BOZKIRDAN HABER")),
        "title": str(selected.get("title", "BEKLENMEDİK OLAY")),
        "text": str(selected.get("text", "")),
        "effects_text": _effects_text(effects),
        "tone": str(selected.get("tone", "neutral"))
    })

func _queue_important_card(card: Dictionary) -> void:
    var card_id: String = str(card.get("id", ""))
    var presentation: Dictionary = card.get("presentation", {}) as Dictionary
    if presentation.is_empty() or presented_important.has(card_id):
        return

    presented_important.append(card_id)
    _queue_event({
        "kicker": str(presentation.get("kicker", "ÖNEMLİ GELİŞME")),
        "title": str(presentation.get("title", "DENGELER DEĞİŞİYOR")),
        "text": str(presentation.get("text", card.get("text", ""))),
        "effects_text": "",
        "tone": str(presentation.get("tone", "neutral"))
    })

func _era_summary_text() -> String:
    return "Bu dönemde %d karar verdin.\n\nKut: %s   •   Halk: %s\nOrdu: %s   •   Hazine: %s\n\nKağanın sana bakışı: %s\n\nVerdiğin kararlar ve bıraktığın izler sonraki dönemlerin hafızasında kalacak." % [
        history.size(),
        _resource_state(int(stats.get("kut", 0))),
        _resource_state(int(stats.get("halk", 0))),
        _resource_state(int(stats.get("ordu", 0))),
        _resource_state(int(stats.get("hazine", 0))),
        _trust_state(int(stats.get("guven", 0)))
    ]

func _load_game_data() -> void:
    var characters_doc: Dictionary = _load_json_dict(CHARACTERS_PATH)
    characters = characters_doc.get("characters", {}) as Dictionary

    var dynasties_doc: Dictionary = _load_json_dict(DYNASTIES_PATH)
    dynasties = dynasties_doc

    world_defaults = _load_json_dict(WORLD_STATE_PATH)
    scenario_index = _load_json_dict(SCENARIO_INDEX_PATH)
    var random_doc: Dictionary = _load_json_dict(RANDOM_EVENTS_PATH)
    random_events = random_doc.get("events", []) as Array
    var crisis_doc: Dictionary = _load_json_dict(CRISIS_EVENTS_PATH)
    crisis_rules = crisis_doc.get("crises", []) as Array

    var cards_doc: Dictionary = _load_json_dict(CARDS_PATH)
    v3_mode = int(cards_doc.get("schema_version", 0)) >= 3 or str(cards_doc.get("mode", "")) == "chronicle_scheduler"
    if v3_mode:
        cards = cards_doc.get("cards", []) as Array
        scenario_start = str(cards_doc.get("start_id", "boru_001"))
        card_lookup.clear()
        for item: Variant in cards:
            var card: Dictionary = item as Dictionary
            card_lookup[str(card.get("id", ""))] = card
        outcome_pools = _load_json_dict(OUTCOME_POOLS_PATH)
        if not cards.is_empty():
            current_era_id = str((cards[0] as Dictionary).get("era", "boru_kagan"))
        else:
            current_era_id = "boru_kagan"
    else:
        current_era_id = str(world_defaults.get("start_era", scenario_index.get("start_era", "boru_era")))
        _load_scenario(current_era_id)

func _load_json_dict(path: String) -> Dictionary:
    var file: FileAccess = FileAccess.open(path, FileAccess.READ)
    if file == null:
        push_error("%s açılamadı." % path)
        return {}

    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if parsed is Dictionary:
        return parsed as Dictionary

    push_error("%s geçerli bir JSON nesnesi değil." % path)
    return {}

func _load_scenario(era_id: String) -> void:
    var eras: Dictionary = scenario_index.get("eras", {}) as Dictionary
    if not eras.has(era_id):
        push_error("Senaryo dönemi bulunamadı: %s" % era_id)
        return

    var era_info: Dictionary = eras[era_id] as Dictionary
    var path: String = str(era_info.get("path", ""))
    if path.is_empty():
        push_error("Senaryo yolu boş: %s" % era_id)
        return

    var scenario: Dictionary = _load_json_dict(path)
    scenario_start = str(scenario.get("start_id", ""))
    current_ruler_id = str(scenario.get("ruler_id", era_info.get("ruler", "")))
    cards = scenario.get("cards", []) as Array
    card_lookup.clear()

    for item: Variant in cards:
        var card: Dictionary = item as Dictionary
        card_lookup[str(card.get("id", ""))] = card

func _show_menu() -> void:
    menu_layer.visible = true
    game_layer.visible = false

func _start_game() -> void:
    var default_stats: Dictionary = world_defaults.get("stats", {}) as Dictionary
    stats = default_stats.duplicate(true)

    var default_story: Dictionary = world_defaults.get("story_state", {}) as Dictionary
    story_state = default_story.duplicate(true)

    var default_characters: Dictionary = world_defaults.get("character_state", {}) as Dictionary
    character_state = default_characters.duplicate(true)

    flags.clear()
    var default_flags: Array = world_defaults.get("flags", []) as Array
    for flag_value: Variant in default_flags:
        flags.append(str(flag_value))

    history.clear()
    event_queue.clear()
    presented_important.clear()
    input_locked = false
    event_overlay_active = false
    relationships.clear()
    seen_cards.clear()
    last_card_year.clear()
    pending_game_over = false
    if v3_mode:
        current_era_id = "boru_kagan"
    else:
        current_era_id = str(world_defaults.get("start_era", scenario_index.get("start_era", "boru_era")))
        _load_scenario(current_era_id)

    year = int(world_defaults.get("start_year", 682))
    season = "" if v3_mode else str(world_defaults.get("start_season", "Sonbahar"))
    turn_no = 0
    last_world_event_turn = -999
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

    var previous_year: int = year
    var previous_season: String = season
    var card: Dictionary = card_lookup[current_card_id] as Dictionary
    var left_data: Dictionary = card.get("left", {}) as Dictionary
    var right_data: Dictionary = card.get("right", {}) as Dictionary

    if v3_mode:
        current_era_id = str(card.get("era", current_era_id))
    else:
        if card.has("year"):
            year = int(card["year"])
        if card.has("season"):
            season = str(card["season"])

    var speaker_id: String = str(card.get("speaker_id", current_ruler_id))
    var character: Dictionary = characters.get(speaker_id, {}) as Dictionary
    speaker_label.text = str(character.get("name", "TÖRE"))
    _set_character(speaker_id)
    card_text.text = "“" + str(card.get("text", "")) + "”"

    var is_ending: bool = bool(card.get("ending", false))
    if is_ending:
        feedback_label.text = str(card.get("ending_title", "KAĞANLIK YILLIĞI"))
        left_button.text = "DÖNEM ÖZETİ"
        right_button.text = "ANA MENÜ"
    else:
        left_button.text = "←  " + str(left_data.get("text", ""))
        right_button.text = str(right_data.get("text", "")) + "  →"
        feedback_label.text = str(card.get("hint", "Kararını ver, Ulu Tarkan."))

    _refresh_year()
    var presentation: Dictionary = card.get("presentation", {}) as Dictionary
    if presentation.is_empty() and not v3_mode:
        _queue_time_and_world_events(previous_year, previous_season)
    _queue_important_card(card)

func _set_character(character_id: String) -> void:
    var fallback_character: Dictionary = characters.get("boru_kagan", {}) as Dictionary
    var character: Dictionary = characters.get(character_id, fallback_character) as Dictionary
    var portrait_path: String = str(character.get("portrait", ""))

    if portrait_path.is_empty():
        portrait_path = str(fallback_character.get("portrait", ""))

    if not portrait_path.is_empty():
        var texture: Texture2D = load(portrait_path) as Texture2D
        if texture != null:
            portrait.texture = texture

    ruler_name.text = str(character.get("name", "TÖRE"))
    ruler_desc.text = str(character.get("description", "Bozkırın konuğu"))

func _choose(side: String) -> void:
    if input_locked or current_card_id.is_empty() or not card_lookup.has(current_card_id):
        return

    input_locked = true
    _set_choice_buttons_enabled(false)
    var card: Dictionary = card_lookup[current_card_id] as Dictionary

    if bool(card.get("ending", false)):
        if side == "left":
            _queue_event({
                "kicker": "DÖNEM TAMAMLANDI",
                "title": str(card.get("ending_title", "KAĞANLIK YILLIĞI")),
                "text": _era_summary_text(),
                "effects_text": "",
                "tone": "neutral"
            })
            _play_next_event()
        else:
            input_locked = false
            _show_menu()
        return

    var choice: Dictionary = card.get(side, {}) as Dictionary
    var effects: Dictionary = choice.get("effects", {}) as Dictionary
    var hidden: Dictionary = choice.get("state", {}) as Dictionary

    _apply_stat_effects(effects, true)

    for key: Variant in hidden.keys():
        story_state[key] = int(story_state.get(key, 0)) + int(hidden[key])

    var set_flags: Array = choice.get("set_flags", []) as Array
    for flag_value: Variant in set_flags:
        _set_flag(str(flag_value))

    var clear_flags: Array = choice.get("clear_flags", []) as Array
    for flag_value: Variant in clear_flags:
        _clear_flag(str(flag_value))

    var relation_effects: Dictionary = choice.get("relations", {}) as Dictionary
    for relation_key: Variant in relation_effects.keys():
        var relation_id: String = str(relation_key)
        relationships[relation_id] = int(relationships.get(relation_id, 0)) + int(relation_effects[relation_key])

    var outcome_pool_id: String = str(choice.get("outcome_pool", ""))
    if v3_mode and not outcome_pool_id.is_empty():
        _apply_v3_outcome(outcome_pool_id)

    var history_entry: Dictionary = {
        "year": year,
        "season": season,
        "era": current_era_id,
        "event": current_card_id,
        "choice": side
    }
    history.append(history_entry)

    feedback_label.text = _effects_text(effects)
    turn_no += 1

    if bool(choice.get("game_over", false)):
        pending_game_over = true
        _queue_event({
            "kicker": "TARKAN OCAĞI",
            "title": "BİR DEVRİN SONU",
            "text": str(card.get("text", "Ulu Tarkan'ın yolu burada sona erdi.")),
            "effects_text": _effects_text(effects),
            "tone": "danger"
        })
        _play_next_event()
        return

    var next_id: String = ""
    if v3_mode:
        _mark_v3_card_seen(current_card_id)
        next_id = _select_next_v3_card()
    else:
        next_id = _resolve_critical_crisis()
        if next_id.is_empty():
            next_id = _resolve_next(choice.get("next", ""))
        if next_id.is_empty():
            next_id = _resolve_next(card.get("next", ""))

    await _animate_card_out()
    current_card_id = next_id
    _show_card()
    await _animate_card_in()

    if not event_queue.is_empty():
        _play_next_event()
    else:
        input_locked = false
        _set_choice_buttons_enabled(true)

func _mark_v3_card_seen(card_id: String) -> void:
    if card_id.is_empty():
        return
    seen_cards[card_id] = int(seen_cards.get(card_id, 0)) + 1
    last_card_year[card_id] = year

func _v3_condition_token_matches(token: String) -> bool:
    if token.is_empty() or token == "normal":
        return true
    if token.begins_with("flag:"):
        return flags.has(token.substr(5))
    var source: Dictionary = stats
    var expr: String = token
    if token.begins_with("stat:"):
        expr = token.substr(5)
        source = stats
    elif token.begins_with("rel:"):
        expr = token.substr(4)
        source = relationships
    else:
        return true

    var operators: Array[String] = [">=", "<=", "==", ">", "<"]
    for op: String in operators:
        var pos: int = expr.find(op)
        if pos < 0:
            continue
        var key: String = expr.substr(0, pos)
        if key == "kagan_guveni":
            key = "guven"
        var rhs: int = int(expr.substr(pos + op.length()))
        var lhs: int = int(source.get(key, 0))
        match op:
            ">=":
                return lhs >= rhs
            "<=":
                return lhs <= rhs
            "==":
                return lhs == rhs
            ">":
                return lhs > rhs
            "<":
                return lhs < rhs
    return false

func _v3_card_conditions_match(card: Dictionary) -> bool:
    var required: Array = card.get("requires", []) as Array
    for token_value: Variant in required:
        if not _v3_condition_token_matches(str(token_value)):
            return false

    var any_required: Array = card.get("requires_any", []) as Array
    if not any_required.is_empty():
        var any_ok: bool = false
        for token_value: Variant in any_required:
            if _v3_condition_token_matches(str(token_value)):
                any_ok = true
                break
        if not any_ok:
            return false
    return true

func _v3_card_available(card: Dictionary, candidate_year: int) -> bool:
    var card_id: String = str(card.get("id", ""))
    if card_id.is_empty() or card_id == current_card_id:
        return false
    if candidate_year < int(card.get("year_min", card.get("year", candidate_year))):
        return false
    if candidate_year > int(card.get("year_max", card.get("year", candidate_year))):
        return false
    if bool(card.get("once", true)) and int(seen_cards.get(card_id, 0)) > 0:
        return false
    var cooldown: int = int(card.get("cooldown_years", 0))
    if cooldown > 0 and last_card_year.has(card_id):
        if candidate_year - int(last_card_year[card_id]) < cooldown:
            return false
    return _v3_card_conditions_match(card)

func _select_weighted_v3(candidates: Array) -> String:
    var total: float = 0.0
    var weights: Array[float] = []
    for item: Variant in candidates:
        var card: Dictionary = item as Dictionary
        var w: float = maxf(float(card.get("weight", 100)), 1.0)
        var priority: String = str(card.get("priority", ""))
        if priority == "critical":
            w *= 8.0
        elif priority == "high":
            w *= 4.0
        var card_type: String = str(card.get("type", ""))
        if card_type in ["story", "callback", "transition", "branch"]:
            w *= 2.0
        elif card_type == "ambient":
            w *= 0.75
        var anchor: int = int(card.get("year", year))
        w /= 1.0 + 0.30 * absf(float(anchor - year))
        weights.append(w)
        total += w

    if total <= 0.0:
        return str((candidates[0] as Dictionary).get("id", ""))

    var roll: float = rng.randf() * total
    for i: int in range(candidates.size()):
        roll -= weights[i]
        if roll <= 0.0:
            return str((candidates[i] as Dictionary).get("id", ""))
    return str((candidates.back() as Dictionary).get("id", ""))

func _select_next_v3_card() -> String:
    var max_search: int = 28 if year >= 934 else 8
    for offset: int in range(max_search + 1):
        var candidate_year: int = year + offset
        var candidates: Array = []
        var urgent: bool = false
        for item: Variant in cards:
            var card: Dictionary = item as Dictionary
            if not _v3_card_available(card, candidate_year):
                continue
            candidates.append(card)
            var p: String = str(card.get("priority", ""))
            if p == "critical" or p == "high":
                urgent = true

        if candidates.is_empty():
            continue

        if offset == 0 and not urgent and year < 934 and rng.randf() > 0.52:
            continue

        year = candidate_year
        season = ""
        return _select_weighted_v3(candidates)

    return ""

func _apply_v3_outcome(pool_id: String) -> void:
    var pool: Dictionary = outcome_pools.get(pool_id, {}) as Dictionary
    if pool.is_empty():
        return
    var base: Dictionary = (pool.get("base", {}) as Dictionary).duplicate(true)
    var modifiers: Array = pool.get("modifiers", []) as Array
    for modifier_value: Variant in modifiers:
        var modifier: Dictionary = modifier_value as Dictionary
        if not _v3_condition_token_matches(str(modifier.get("if", ""))):
            continue
        for key: Variant in modifier.keys():
            if str(key) == "if":
                continue
            base[key] = maxf(float(base.get(key, 0)) + float(modifier[key]), 0.0)

    var total: float = 0.0
    for key: Variant in base.keys():
        total += maxf(float(base[key]), 0.0)
    if total <= 0.0:
        return

    var roll: float = rng.randf() * total
    var selected: String = ""
    for key: Variant in base.keys():
        roll -= maxf(float(base[key]), 0.0)
        if roll <= 0.0:
            selected = str(key)
            break
    if selected.is_empty():
        selected = str(base.keys().back())

    var results: Dictionary = pool.get("results", {}) as Dictionary
    var result: Dictionary = results.get(selected, {}) as Dictionary
    var result_effects: Dictionary = {}
    for stat_key: String in ["kut", "halk", "ordu", "hazine", "kagan_guveni"]:
        if not result.has(stat_key):
            continue
        var engine_key: String = "guven" if stat_key == "kagan_guveni" else stat_key
        result_effects[engine_key] = int(result[stat_key])
    _apply_stat_effects(result_effects, true)

    var result_flags: Array = result.get("set", []) as Array
    for flag_value: Variant in result_flags:
        _set_flag(str(flag_value))

func _resolve_critical_crisis() -> String:
    for rule_variant: Variant in crisis_rules:
        var rule: Dictionary = rule_variant as Dictionary
        var once_flag: String = str(rule.get("once_flag", ""))
        if not once_flag.is_empty() and flags.has(once_flag):
            continue

        var condition: Dictionary = rule.get("when", {}) as Dictionary
        if condition.is_empty() or not _condition_matches(condition):
            continue

        if not once_flag.is_empty():
            _set_flag(once_flag)

        var extra_flags: Array = rule.get("set_flags", []) as Array
        for flag_value: Variant in extra_flags:
            _set_flag(str(flag_value))

        var ruler_id: String = str(rule.get("set_ruler", ""))
        if not ruler_id.is_empty():
            current_ruler_id = ruler_id

        var updates: Dictionary = rule.get("character_updates", {}) as Dictionary
        for character_key: Variant in updates.keys():
            var character_id: String = str(character_key)
            var current_state: Dictionary = character_state.get(character_id, {}) as Dictionary
            var patch: Dictionary = updates[character_key] as Dictionary
            for field: Variant in patch.keys():
                current_state[field] = patch[field]
            character_state[character_id] = current_state

        history.append({
            "year": year,
            "season": season,
            "era": current_era_id,
            "event": str(rule.get("id", "critical_crisis")),
            "choice": "crisis"
        })
        return str(rule.get("target_id", ""))

    return ""

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

    if condition.has("flags"):
        var required_flags: Array = condition["flags"] as Array
        for required_flag: Variant in required_flags:
            if not flags.has(str(required_flag)):
                return false
        return true

    if condition.has("not_flags"):
        var forbidden_flags: Array = condition["not_flags"] as Array
        for forbidden_flag: Variant in forbidden_flags:
            if flags.has(str(forbidden_flag)):
                return false
        return true

    if condition.has("character_alive"):
        var alive_id: String = str(condition["character_alive"])
        var alive_state: Dictionary = character_state.get(alive_id, {}) as Dictionary
        return bool(alive_state.get("alive", false))

    if condition.has("character_dead"):
        var dead_id: String = str(condition["character_dead"])
        var dead_state: Dictionary = character_state.get(dead_id, {}) as Dictionary
        return not bool(dead_state.get("alive", true))

    if condition.has("min_year") and year < int(condition["min_year"]):
        return false
    if condition.has("max_year") and year > int(condition["max_year"]):
        return false

    var key: String = str(condition.get("key", ""))
    var source: String = str(condition.get("source", "story"))
    var value: int = int(story_state.get(key, 0))
    if source == "stats":
        value = int(stats.get(key, 0))
    elif source == "character":
        var character_id: String = str(condition.get("character_id", ""))
        var state: Dictionary = character_state.get(character_id, {}) as Dictionary
        value = int(state.get(key, 0))

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

func _set_flag(flag_name: String) -> void:
    if flag_name.is_empty() or flags.has(flag_name):
        return
    flags.append(flag_name)

func _clear_flag(flag_name: String) -> void:
    var index: int = flags.find(flag_name)
    if index >= 0:
        flags.remove_at(index)

func _apply_stat_effects(effects: Dictionary, animated: bool = false) -> void:
    for key: Variant in effects.keys():
        if stats.has(key):
            stats[key] = clampi(int(stats[key]) + int(effects[key]), 0, 10)

    _refresh_stats(animated)

func _effects_text(effects: Dictionary) -> String:
    var names: Dictionary = {"kut":"Kut", "halk":"Halk", "ordu":"Ordu", "hazine":"Hazine", "guven":"Kağanın güveni"}
    var parts: Array[String] = []

    for key: Variant in effects.keys():
        var value: int = int(effects[key])
        if value == 0:
            continue

        var magnitude: int = absi(value)
        var arrows: String = "↑" if value > 0 else "↓"
        if magnitude >= 3:
            arrows = arrows + arrows + arrows
        elif magnitude >= 2:
            arrows = arrows + arrows

        parts.append("%s %s" % [str(names.get(key, key)), arrows])

    return "   •   ".join(parts)

func _refresh_stats(animated: bool = false) -> void:
    for key: Variant in stat_bars.keys():
        var bar: ProgressBar = stat_bars[key] as ProgressBar
        var target_value: float = float(stats[key])
        if animated and game_layer.visible:
            var tween: Tween = create_tween()
            tween.tween_property(bar, "value", target_value, 0.32)
        else:
            bar.value = target_value

    for key: Variant in stat_states.keys():
        var state: Label = stat_states[key] as Label
        state.text = _resource_state(int(stats[key]))

    trust_label.text = _trust_state(int(stats["guven"]))
    trust_label.add_theme_color_override("font_color", _trust_color(int(stats["guven"])))

func _refresh_year() -> void:
    if v3_mode or season.is_empty():
        year_label.text = "%d" % year
    else:
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
    bar.max_value = 10
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
    if value <= 1:
        return "Çöküşte"
    if value <= 3:
        return "Kırılgan"
    if value <= 6:
        return "Dengeli"
    if value <= 8:
        return "Güçlü"
    return "Çok güçlü"

func _trust_state(value: int) -> String:
    if value <= 1:
        return "Seni düşman görüyor"
    if value <= 3:
        return "Senden şüpheleniyor"
    if value <= 4:
        return "Sana karşı temkinli"
    if value <= 6:
        return "Sana güveniyor"
    if value <= 8:
        return "Sözüne değer veriyor"
    return "En yakın sırdaşısın"

func _trust_color(value: int) -> Color:
    if value <= 2:
        return Color("#d47777")
    if value <= 4:
        return Color("#d6aa70")
    if value <= 6:
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
