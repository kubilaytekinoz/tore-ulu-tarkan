extends Control

const GOLD: Color = Color("#d3aa5b")
const GOLD_BRIGHT: Color = Color("#f0d79a")
const GOLD_DARK: Color = Color("#76552d")
const PANEL: Color = Color("#0b121a")
const PANEL_2: Color = Color("#111b28")
const TEXT: Color = Color("#f2eadc")
const MUTED: Color = Color("#9aa6b5")
const GREEN: Color = Color("#174f42")
const RED: Color = Color("#60272d")
const TRACK: Color = Color("#202a36")
const BAR_FILL: Color = Color("#c7a252")
const BLUE_FILL: Color = Color("#6f9bb3")
const GREEN_FILL: Color = Color("#6fc395")
const RED_FILL: Color = Color("#c96d69")

var stats: Dictionary = {"kut":61, "halk":54, "ordu":67, "hazine":46, "guven":58}
var year: int = 682
var season: String = "Sonbahar"
var cards: Array = []
var card_index: int = 0

var menu_layer: Control
var game_layer: Control
var chronicle_layer: Control
var dynasty_layer: Control
var tribes_layer: Control
var nav_layer: Control

var stat_bars: Dictionary = {}
var stat_states: Dictionary = {}
var trust_label: Label
var speaker_label: Label
var card_text: Label
var year_label: Label
var feedback_label: Label
var left_button: Button
var right_button: Button

func _ready() -> void:
    _build_background()
    _build_menu()
    _build_game()
    _build_chronicle()
    _build_dynasty()
    _build_tribes()
    _build_navigation()
    _load_cards()
    _show_layer(menu_layer)

func _build_background() -> void:
    var bg: ColorRect = ColorRect.new()
    bg.color = Color("#05080d")
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(bg)

    var glow: ColorRect = ColorRect.new()
    glow.color = Color("#0d1d2c")
    glow.set_anchors_preset(Control.PRESET_TOP_WIDE)
    glow.offset_bottom = 760
    glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(glow)

func _build_menu() -> void:
    menu_layer = Control.new()
    menu_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(menu_layer)

    var header_tex: TextureRect = TextureRect.new()
    header_tex.texture = load("res://assets/ui/steppe_header.svg") as Texture2D
    header_tex.set_anchors_preset(Control.PRESET_TOP_WIDE)
    header_tex.offset_bottom = 760
    header_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    header_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    header_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
    menu_layer.add_child(header_tex)

    var shade: ColorRect = ColorRect.new()
    shade.color = Color(0.015, 0.025, 0.04, 0.48)
    shade.set_anchors_preset(Control.PRESET_TOP_WIDE)
    shade.offset_bottom = 760
    shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
    menu_layer.add_child(shade)

    var safe: MarginContainer = MarginContainer.new()
    safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    safe.add_theme_constant_override("margin_left", 70)
    safe.add_theme_constant_override("margin_right", 70)
    safe.add_theme_constant_override("margin_top", 105)
    safe.add_theme_constant_override("margin_bottom", 70)
    menu_layer.add_child(safe)

    var column: VBoxContainer = VBoxContainer.new()
    column.alignment = BoxContainer.ALIGNMENT_CENTER
    column.add_theme_constant_override("separation", 22)
    safe.add_child(column)

    var logo_wrap: CenterContainer = CenterContainer.new()
    logo_wrap.custom_minimum_size = Vector2(0, 120)
    column.add_child(logo_wrap)

    var logo: TextureRect = TextureRect.new()
    logo.texture = load("res://assets/ui/wolf_emblem.svg") as Texture2D
    logo.custom_minimum_size = Vector2(104, 104)
    logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    logo_wrap.add_child(logo)

    var title: Label = Label.new()
    title.text = "TÖRE"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 112)
    title.add_theme_color_override("font_color", GOLD_BRIGHT)
    column.add_child(title)

    var subtitle: Label = Label.new()
    subtitle.text = "U L U   T A R K A N"
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.add_theme_font_size_override("font_size", 27)
    subtitle.add_theme_color_override("font_color", GOLD)
    column.add_child(subtitle)

    var motto: Label = Label.new()
    motto.text = "Kağanlar değişir. Töre kalır."
    motto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    motto.add_theme_font_size_override("font_size", 27)
    motto.add_theme_color_override("font_color", TEXT)
    column.add_child(motto)

    var hero_space: Control = Control.new()
    hero_space.custom_minimum_size = Vector2(0, 210)
    column.add_child(hero_space)

    var start: Button = _menu_button("◈   YENİ KAĞANLIK", Color("#17382f"))
    start.pressed.connect(_start_game)
    column.add_child(start)

    var continue_btn: Button = _menu_button("DEVAM ET  •  YAKINDA", Color("#17212d"))
    continue_btn.disabled = true
    column.add_child(continue_btn)

    var journal_btn: Button = _menu_button("KAĞANLIK YILLIĞI", Color("#171b22"))
    journal_btn.pressed.connect(func() -> void: _show_layer(chronicle_layer))
    column.add_child(journal_btn)

    var dynasty_btn: Button = _menu_button("HANEDAN VE İLİŞKİLER", Color("#171b22"))
    dynasty_btn.pressed.connect(func() -> void: _show_layer(dynasty_layer))
    column.add_child(dynasty_btn)

    var tribes_btn: Button = _menu_button("BOYLAR HARİTASI", Color("#171b22"))
    tribes_btn.pressed.connect(func() -> void: _show_layer(tribes_layer))
    column.add_child(tribes_btn)

    var foot_spacer: Control = Control.new()
    foot_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
    column.add_child(foot_spacer)

    var foot: Label = Label.new()
    foot.text = "PROTOTİP  •  v0.4"
    foot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    foot.add_theme_font_size_override("font_size", 20)
    foot.add_theme_color_override("font_color", Color("#687483"))
    column.add_child(foot)

func _menu_button(text_value: String, bg: Color) -> Button:
    var button: Button = Button.new()
    button.text = text_value
    button.custom_minimum_size = Vector2(0, 88)
    button.add_theme_font_size_override("font_size", 24)
    _style_button(button, bg, GOLD_BRIGHT, Color("#65543a"))
    return button

func _build_game() -> void:
    game_layer = Control.new()
    game_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(game_layer)

    var header_bg: TextureRect = TextureRect.new()
    header_bg.texture = load("res://assets/ui/steppe_header.svg") as Texture2D
    header_bg.set_anchors_preset(Control.PRESET_TOP_WIDE)
    header_bg.offset_bottom = 315
    header_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    header_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    header_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
    game_layer.add_child(header_bg)

    var header_shade: ColorRect = ColorRect.new()
    header_shade.color = Color(0.015, 0.025, 0.04, 0.38)
    header_shade.set_anchors_preset(Control.PRESET_TOP_WIDE)
    header_shade.offset_bottom = 315
    header_shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
    game_layer.add_child(header_shade)

    var safe: MarginContainer = MarginContainer.new()
    safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    safe.add_theme_constant_override("margin_left", 34)
    safe.add_theme_constant_override("margin_right", 34)
    safe.add_theme_constant_override("margin_top", 30)
    safe.add_theme_constant_override("margin_bottom", 34)
    game_layer.add_child(safe)

    var col: VBoxContainer = VBoxContainer.new()
    col.add_theme_constant_override("separation", 12)
    safe.add_child(col)

    var header: HBoxContainer = HBoxContainer.new()
    header.add_theme_constant_override("separation", 12)
    col.add_child(header)

    _add_brand_to_header(header)

    year_label = Label.new()
    year_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    year_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    year_label.add_theme_font_size_override("font_size", 23)
    year_label.add_theme_color_override("font_color", TEXT)
    header.add_child(year_label)

    var menu_button: Button = Button.new()
    menu_button.text = "☰"
    menu_button.custom_minimum_size = Vector2(58, 54)
    menu_button.add_theme_font_size_override("font_size", 25)
    _style_button(menu_button, Color("#111923"), GOLD_BRIGHT, Color("#6f5734"))
    menu_button.pressed.connect(_open_navigation)
    header.add_child(menu_button)

    var stats_panel: PanelContainer = PanelContainer.new()
    stats_panel.add_theme_stylebox_override("panel", _panel_style(Color("#081018e8"), GOLD_DARK, 2, 12))
    col.add_child(stats_panel)

    var stats_pad: MarginContainer = MarginContainer.new()
    stats_pad.add_theme_constant_override("margin_left", 16)
    stats_pad.add_theme_constant_override("margin_right", 16)
    stats_pad.add_theme_constant_override("margin_top", 14)
    stats_pad.add_theme_constant_override("margin_bottom", 14)
    stats_panel.add_child(stats_pad)

    var stats_grid: GridContainer = GridContainer.new()
    stats_grid.columns = 4
    stats_grid.add_theme_constant_override("h_separation", 12)
    stats_pad.add_child(stats_grid)

    _make_stat(stats_grid, "☀", "Kut", "kut", GOLD_BRIGHT)
    _make_stat(stats_grid, "♟", "Halk", "halk", GREEN_FILL)
    _make_stat(stats_grid, "⚔", "Ordu", "ordu", RED_FILL)
    _make_stat(stats_grid, "●", "Hazine", "hazine", BLUE_FILL)

    var trust_panel: PanelContainer = PanelContainer.new()
    trust_panel.custom_minimum_size = Vector2(0, 64)
    trust_panel.add_theme_stylebox_override("panel", _panel_style(Color("#0b141de8"), Color("#4f402c"), 1, 10))
    col.add_child(trust_panel)

    var trust_row: HBoxContainer = HBoxContainer.new()
    trust_row.add_theme_constant_override("separation", 10)
    trust_panel.add_child(trust_row)

    var trust_icon: Label = Label.new()
    trust_icon.text = "◆"
    trust_icon.add_theme_font_size_override("font_size", 20)
    trust_icon.add_theme_color_override("font_color", GOLD)
    trust_row.add_child(trust_icon)

    var trust_title: Label = Label.new()
    trust_title.text = "Kağanın sana bakışı"
    trust_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    trust_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    trust_title.add_theme_font_size_override("font_size", 19)
    trust_title.add_theme_color_override("font_color", TEXT)
    trust_row.add_child(trust_title)

    trust_label = Label.new()
    trust_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    trust_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    trust_label.add_theme_font_size_override("font_size", 21)
    trust_label.add_theme_color_override("font_color", GREEN_FILL)
    trust_row.add_child(trust_label)

    var stage: VBoxContainer = VBoxContainer.new()
    stage.size_flags_vertical = Control.SIZE_EXPAND_FILL
    stage.add_theme_constant_override("separation", 10)
    col.add_child(stage)

    var portrait_panel: PanelContainer = PanelContainer.new()
    portrait_panel.custom_minimum_size = Vector2(0, 690)
    portrait_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    portrait_panel.add_theme_stylebox_override("panel", _panel_style(Color("#101925"), GOLD, 2, 20))
    stage.add_child(portrait_panel)

    var portrait_stack: Control = Control.new()
    portrait_stack.custom_minimum_size = Vector2(0, 690)
    portrait_panel.add_child(portrait_stack)

    var portrait: TextureRect = TextureRect.new()
    portrait.texture = load("res://assets/characters/boru_kagan.svg") as Texture2D
    portrait.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
    portrait_stack.add_child(portrait)

    var portrait_bottom: ColorRect = ColorRect.new()
    portrait_bottom.color = Color(0.015, 0.02, 0.03, 0.68)
    portrait_bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
    portrait_bottom.offset_top = -150
    portrait_bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
    portrait_stack.add_child(portrait_bottom)

    var name_box: VBoxContainer = VBoxContainer.new()
    name_box.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
    name_box.offset_top = -126
    name_box.offset_bottom = -24
    name_box.add_theme_constant_override("separation", 4)
    portrait_stack.add_child(name_box)

    var person: Label = Label.new()
    person.text = "BÖRÜ KAĞAN"
    person.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    person.add_theme_font_size_override("font_size", 34)
    person.add_theme_color_override("font_color", GOLD_BRIGHT)
    name_box.add_child(person)

    var desc: Label = Label.new()
    desc.text = "Yeni tahta çıktı  •  33 yaşında"
    desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    desc.add_theme_font_size_override("font_size", 19)
    desc.add_theme_color_override("font_color", MUTED)
    name_box.add_child(desc)

    var card: PanelContainer = PanelContainer.new()
    card.custom_minimum_size = Vector2(0, 350)
    card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    card.add_theme_stylebox_override("panel", _panel_style(Color("#0b1119f5"), GOLD_DARK, 2, 16))
    stage.add_child(card)

    var pad: MarginContainer = MarginContainer.new()
    pad.add_theme_constant_override("margin_left", 28)
    pad.add_theme_constant_override("margin_right", 28)
    pad.add_theme_constant_override("margin_top", 24)
    pad.add_theme_constant_override("margin_bottom", 22)
    card.add_child(pad)

    var ccol: VBoxContainer = VBoxContainer.new()
    ccol.alignment = BoxContainer.ALIGNMENT_CENTER
    ccol.add_theme_constant_override("separation", 14)
    pad.add_child(ccol)

    speaker_label = Label.new()
    speaker_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    speaker_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    speaker_label.add_theme_font_size_override("font_size", 22)
    speaker_label.add_theme_color_override("font_color", GOLD)
    ccol.add_child(speaker_label)

    var divider: HSeparator = HSeparator.new()
    divider.add_theme_color_override("separator", GOLD_DARK)
    ccol.add_child(divider)

    card_text = Label.new()
    card_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
    card_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    card_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    card_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    card_text.add_theme_font_size_override("font_size", 28)
    card_text.add_theme_color_override("font_color", TEXT)
    ccol.add_child(card_text)

    feedback_label = Label.new()
    feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    feedback_label.add_theme_font_size_override("font_size", 18)
    feedback_label.add_theme_color_override("font_color", MUTED)
    ccol.add_child(feedback_label)

    var choices: HBoxContainer = HBoxContainer.new()
    choices.add_theme_constant_override("separation", 12)
    col.add_child(choices)

    left_button = Button.new()
    left_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    left_button.custom_minimum_size = Vector2(0, 126)
    left_button.add_theme_font_size_override("font_size", 21)
    left_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _style_button(left_button, GREEN, TEXT, Color("#9e8050"))
    left_button.pressed.connect(func() -> void: _choose("left"))
    choices.add_child(left_button)

    right_button = Button.new()
    right_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    right_button.custom_minimum_size = Vector2(0, 126)
    right_button.add_theme_font_size_override("font_size", 21)
    right_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _style_button(right_button, RED, TEXT, Color("#9e8050"))
    right_button.pressed.connect(func() -> void: _choose("right"))
    choices.add_child(right_button)

func _build_chronicle() -> void:
    chronicle_layer = _make_secondary_layer("KAĞANLIK YILLIĞI", "Kağanlığın hafızası, geleceğe yol gösterir.")
    var body: VBoxContainer = chronicle_layer.get_meta("body") as VBoxContainer

    var scroll: ScrollContainer = ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    body.add_child(scroll)

    var list: VBoxContainer = VBoxContainer.new()
    list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    list.add_theme_constant_override("separation", 14)
    scroll.add_child(list)

    _add_history_card(list, "682", "♛", "BÖRÜ KAĞAN TAHTA ÇIKTI", "Gök yurdun boyları, töre üzere Börü Kağan’ı kağan ilan etti. Yeni bir dönem başladı.")
    _add_history_card(list, "683", "●", "BAYIR BOYU VERGİSİ ERTELENDİ", "Kışın ağır geçmesi nedeniyle Bayır boyuna bir mevsim daha süre verildi.")
    _add_history_card(list, "684", "⚔", "DOĞU SINIRINDA İLK ÇATIŞMA", "Yabancı atlılarla ilk çatışma yaşandı. Akın püskürtüldü; sınırdaki gerginlik sürüyor.")
    _add_history_card(list, "685", "♜", "ŞÜPHELİ ZEHİRLENME GİRİŞİMİ", "Kağan’ın sofrasında şüpheli bir madde bulundu. Kimin gönderdiği henüz bilinmiyor.")
    _add_history_card(list, "686", "⌂", "KURULTAY TOPLANDI", "Boy beyleri otağda toplandı. Kağanlığın geleceğine dair ağır kararlar konuşuldu.")

func _build_dynasty() -> void:
    dynasty_layer = _make_secondary_layer("HANEDAN VE İLİŞKİLER", "Kan bağları törenin direğidir.")
    var body: VBoxContainer = dynasty_layer.get_meta("body") as VBoxContainer

    var ruler: PanelContainer = PanelContainer.new()
    ruler.custom_minimum_size = Vector2(0, 480)
    ruler.add_theme_stylebox_override("panel", _panel_style(PANEL_2, GOLD, 2, 18))
    body.add_child(ruler)

    var ruler_row: HBoxContainer = HBoxContainer.new()
    ruler_row.add_theme_constant_override("separation", 22)
    ruler.add_child(ruler_row)

    var portrait: TextureRect = TextureRect.new()
    portrait.texture = load("res://assets/characters/boru_kagan.svg") as Texture2D
    portrait.custom_minimum_size = Vector2(380, 450)
    portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    ruler_row.add_child(portrait)

    var ruler_text: VBoxContainer = VBoxContainer.new()
    ruler_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    ruler_text.alignment = BoxContainer.ALIGNMENT_CENTER
    ruler_text.add_theme_constant_override("separation", 12)
    ruler_row.add_child(ruler_text)

    _add_text(ruler_text, "BÖRÜ KAĞAN", 34, GOLD_BRIGHT)
    _add_text(ruler_text, "Kağan • Hanedanın Reisi", 19, MUTED)
    _add_badge(ruler_text, "◆ Hanedanın Birleştiricisi", Color("#164737"))
    _add_text(ruler_text, "“Gök bize soy, töre bize yol gösterir.”", 20, TEXT)

    var relation_grid: GridContainer = GridContainer.new()
    relation_grid.columns = 2
    relation_grid.add_theme_constant_override("h_separation", 12)
    relation_grid.add_theme_constant_override("v_separation", 12)
    body.add_child(relation_grid)

    _add_relation_card(relation_grid, "ALTUN HATUN", "Baş Hatun", "Sadık", "♥", Color("#18533f"), "Hanedanın dirliği, hatunun aklıyla güçlenir.")
    _add_relation_card(relation_grid, "KARA YABGU", "Baş Yabgu", "Temkinli", "⚖", Color("#5b4224"), "Güçlüdür; ama kendi yolunu gözetir.")
    _add_relation_card(relation_grid, "ALP ŞAD", "Başkomutan", "Güçleniyor", "⚔", Color("#22513c"), "Orduda sözü her geçen gün daha çok dinleniyor.")
    _add_relation_card(relation_grid, "ARSLAN TEGİN", "Tegin", "Kuşkulu", "◉", Color("#612a30"), "Sadakati sınanıyor; gölgede kendi hesabı olabilir.")

func _build_tribes() -> void:
    tribes_layer = _make_secondary_layer("BOYLAR HARİTASI", "Bozkırdaki dostu ve rakibi bilmek, savaşı başlamadan kazandırır.")
    var body: VBoxContainer = tribes_layer.get_meta("body") as VBoxContainer

    var filters: HBoxContainer = HBoxContainer.new()
    filters.add_theme_constant_override("separation", 8)
    body.add_child(filters)
    _add_filter_chip(filters, "⌂ Tüm Boylar", true)
    _add_filter_chip(filters, "◆ Müttefik", false)
    _add_filter_chip(filters, "⚖ Tarafsız", false)
    _add_filter_chip(filters, "⚔ Rekabet", false)

    var map_panel: PanelContainer = PanelContainer.new()
    map_panel.custom_minimum_size = Vector2(0, 690)
    map_panel.add_theme_stylebox_override("panel", _panel_style(Color("#0d141c"), GOLD_DARK, 2, 18))
    body.add_child(map_panel)

    var map_tex: TextureRect = TextureRect.new()
    map_tex.texture = load("res://assets/maps/boylar_map.svg") as Texture2D
    map_tex.custom_minimum_size = Vector2(0, 680)
    map_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    map_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    map_panel.add_child(map_tex)

    var info: PanelContainer = PanelContainer.new()
    info.add_theme_stylebox_override("panel", _panel_style(PANEL_2, GOLD_DARK, 2, 16))
    body.add_child(info)

    var ip: MarginContainer = MarginContainer.new()
    ip.add_theme_constant_override("margin_left", 24)
    ip.add_theme_constant_override("margin_right", 24)
    ip.add_theme_constant_override("margin_top", 20)
    ip.add_theme_constant_override("margin_bottom", 20)
    info.add_child(ip)

    var ic: VBoxContainer = VBoxContainer.new()
    ic.add_theme_constant_override("separation", 10)
    ip.add_child(ic)

    _add_text(ic, "KAYI", 36, GOLD_BRIGHT)
    _add_text(ic, "Düzenli ve güçlü yapısıyla kağanlığın en güvenilir destekçilerinden biri.", 21, TEXT)
    _add_status_row(ic, "Sadakat", 82, GREEN_FILL, "Sadık")
    _add_status_row(ic, "Güç", 70, GOLD_BRIGHT, "Kuvvetli")
    _add_badge(ic, "Durum  •  Müttefik", Color("#174b3b"))

    var actions: HBoxContainer = HBoxContainer.new()
    actions.add_theme_constant_override("separation", 10)
    ic.add_child(actions)
    _add_action_button(actions, "Diplomasi\nGörüş", Color("#17212d"))
    _add_action_button(actions, "İttifakı\nGüçlendir", GREEN)
    _add_action_button(actions, "Sefer\nHazırla", RED)

func _make_secondary_layer(title_text: String, subtitle_text: String) -> Control:
    var layer: Control = Control.new()
    layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(layer)

    var top_art: TextureRect = TextureRect.new()
    top_art.texture = load("res://assets/ui/steppe_header.svg") as Texture2D
    top_art.set_anchors_preset(Control.PRESET_TOP_WIDE)
    top_art.offset_bottom = 310
    top_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    top_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    top_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layer.add_child(top_art)

    var shade: ColorRect = ColorRect.new()
    shade.color = Color(0.015, 0.025, 0.04, 0.48)
    shade.set_anchors_preset(Control.PRESET_TOP_WIDE)
    shade.offset_bottom = 310
    shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layer.add_child(shade)

    var safe: MarginContainer = MarginContainer.new()
    safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    safe.add_theme_constant_override("margin_left", 34)
    safe.add_theme_constant_override("margin_right", 34)
    safe.add_theme_constant_override("margin_top", 30)
    safe.add_theme_constant_override("margin_bottom", 30)
    layer.add_child(safe)

    var col: VBoxContainer = VBoxContainer.new()
    col.add_theme_constant_override("separation", 14)
    safe.add_child(col)

    var header: HBoxContainer = HBoxContainer.new()
    header.add_theme_constant_override("separation", 10)
    col.add_child(header)
    _add_brand_to_header(header)

    var back: Button = Button.new()
    back.text = "← OYUN"
    back.custom_minimum_size = Vector2(120, 50)
    back.add_theme_font_size_override("font_size", 18)
    _style_button(back, Color("#101923"), GOLD_BRIGHT, Color("#58472f"))
    back.pressed.connect(func() -> void: _show_layer(game_layer))
    header.add_child(back)

    var title_panel: PanelContainer = PanelContainer.new()
    title_panel.add_theme_stylebox_override("panel", _panel_style(Color("#081018ed"), GOLD_DARK, 2, 14))
    col.add_child(title_panel)

    var title_box: VBoxContainer = VBoxContainer.new()
    title_box.alignment = BoxContainer.ALIGNMENT_CENTER
    title_box.add_theme_constant_override("separation", 5)
    title_panel.add_child(title_box)

    _add_text(title_box, title_text, 38, GOLD_BRIGHT, HORIZONTAL_ALIGNMENT_CENTER)
    _add_text(title_box, subtitle_text, 18, MUTED, HORIZONTAL_ALIGNMENT_CENTER)

    var body: VBoxContainer = VBoxContainer.new()
    body.size_flags_vertical = Control.SIZE_EXPAND_FILL
    body.add_theme_constant_override("separation", 14)
    col.add_child(body)
    layer.set_meta("body", body)
    return layer

func _add_brand_to_header(header: HBoxContainer) -> void:
    var logo: TextureRect = TextureRect.new()
    logo.texture = load("res://assets/ui/wolf_emblem.svg") as Texture2D
    logo.custom_minimum_size = Vector2(52, 52)
    logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    header.add_child(logo)

    var box: VBoxContainer = VBoxContainer.new()
    box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    box.add_theme_constant_override("separation", -2)
    header.add_child(box)

    _add_text(box, "TÖRE", 38, GOLD_BRIGHT)
    _add_text(box, "ULU TARKAN", 12, GOLD)

func _add_history_card(parent: VBoxContainer, year_text: String, icon_text: String, title_text: String, desc_text: String) -> void:
    var panel: PanelContainer = PanelContainer.new()
    panel.custom_minimum_size = Vector2(0, 188)
    panel.add_theme_stylebox_override("panel", _panel_style(Color("#0c131cf2"), Color("#6c5738"), 2, 14))
    parent.add_child(panel)

    var row: HBoxContainer = HBoxContainer.new()
    row.add_theme_constant_override("separation", 18)
    panel.add_child(row)

    var year_box: VBoxContainer = VBoxContainer.new()
    year_box.custom_minimum_size = Vector2(126, 0)
    year_box.alignment = BoxContainer.ALIGNMENT_CENTER
    row.add_child(year_box)
    _add_text(year_box, year_text, 34, GOLD_BRIGHT, HORIZONTAL_ALIGNMENT_CENTER)
    _add_text(year_box, icon_text, 32, GOLD, HORIZONTAL_ALIGNMENT_CENTER)

    var text_box: VBoxContainer = VBoxContainer.new()
    text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    text_box.alignment = BoxContainer.ALIGNMENT_CENTER
    text_box.add_theme_constant_override("separation", 8)
    row.add_child(text_box)
    _add_text(text_box, title_text, 24, GOLD)
    _add_text(text_box, desc_text, 20, TEXT)

func _add_relation_card(parent: GridContainer, name_text: String, role_text: String, status_text: String, icon_text: String, status_color: Color, quote_text: String) -> void:
    var panel: PanelContainer = PanelContainer.new()
    panel.custom_minimum_size = Vector2(0, 310)
    panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    panel.add_theme_stylebox_override("panel", _panel_style(Color("#0c131c"), Color("#645139"), 2, 14))
    parent.add_child(panel)

    var box: VBoxContainer = VBoxContainer.new()
    box.alignment = BoxContainer.ALIGNMENT_CENTER
    box.add_theme_constant_override("separation", 8)
    panel.add_child(box)
    _add_text(box, icon_text, 42, GOLD_BRIGHT, HORIZONTAL_ALIGNMENT_CENTER)
    _add_text(box, name_text, 25, GOLD_BRIGHT, HORIZONTAL_ALIGNMENT_CENTER)
    _add_text(box, role_text, 17, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
    _add_badge(box, status_text, status_color)
    _add_text(box, "“" + quote_text + "”", 17, TEXT, HORIZONTAL_ALIGNMENT_CENTER)

func _add_filter_chip(parent: HBoxContainer, text_value: String, selected: bool) -> void:
    var button: Button = Button.new()
    button.text = text_value
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.custom_minimum_size = Vector2(0, 66)
    button.add_theme_font_size_override("font_size", 16)
    var bg: Color = Color("#5a3d20") if selected else Color("#111923")
    var border: Color = GOLD if selected else Color("#424b55")
    _style_button(button, bg, TEXT, border)
    parent.add_child(button)

func _add_status_row(parent: VBoxContainer, title_text: String, value: int, color: Color, state_text: String) -> void:
    var row: HBoxContainer = HBoxContainer.new()
    row.add_theme_constant_override("separation", 12)
    parent.add_child(row)

    var label: Label = Label.new()
    label.text = title_text
    label.custom_minimum_size = Vector2(120, 0)
    label.add_theme_font_size_override("font_size", 18)
    label.add_theme_color_override("font_color", TEXT)
    row.add_child(label)

    var bar: ProgressBar = ProgressBar.new()
    bar.min_value = 0
    bar.max_value = 100
    bar.value = value
    bar.show_percentage = false
    bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    bar.custom_minimum_size = Vector2(0, 18)
    bar.add_theme_stylebox_override("background", _bar_style(TRACK, 8))
    bar.add_theme_stylebox_override("fill", _bar_style(color, 8))
    row.add_child(bar)

    var state: Label = Label.new()
    state.text = state_text
    state.custom_minimum_size = Vector2(110, 0)
    state.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    state.add_theme_font_size_override("font_size", 17)
    state.add_theme_color_override("font_color", MUTED)
    row.add_child(state)

func _add_badge(parent: VBoxContainer, text_value: String, color: Color) -> void:
    var badge: PanelContainer = PanelContainer.new()
    badge.custom_minimum_size = Vector2(0, 50)
    badge.add_theme_stylebox_override("panel", _panel_style(color, color.lightened(0.18), 1, 12))
    parent.add_child(badge)

    var label: Label = Label.new()
    label.text = text_value
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    label.add_theme_font_size_override("font_size", 18)
    label.add_theme_color_override("font_color", TEXT)
    badge.add_child(label)

func _add_action_button(parent: HBoxContainer, text_value: String, color: Color) -> void:
    var button: Button = Button.new()
    button.text = text_value
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.custom_minimum_size = Vector2(0, 100)
    button.add_theme_font_size_override("font_size", 18)
    _style_button(button, color, TEXT, Color("#80663c"))
    parent.add_child(button)

func _add_text(parent: Container, text_value: String, font_size: int, color: Color, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
    var label: Label = Label.new()
    label.text = text_value
    label.horizontal_alignment = align
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", color)
    parent.add_child(label)
    return label

func _build_navigation() -> void:
    nav_layer = Control.new()
    nav_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(nav_layer)

    var dim: ColorRect = ColorRect.new()
    dim.color = Color(0, 0, 0, 0.76)
    dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    nav_layer.add_child(dim)

    var panel: PanelContainer = PanelContainer.new()
    panel.set_anchors_preset(Control.PRESET_CENTER)
    panel.offset_left = -370
    panel.offset_right = 370
    panel.offset_top = -470
    panel.offset_bottom = 470
    panel.add_theme_stylebox_override("panel", _panel_style(Color("#0b121af8"), GOLD_DARK, 2, 20))
    nav_layer.add_child(panel)

    var pad: MarginContainer = MarginContainer.new()
    pad.add_theme_constant_override("margin_left", 42)
    pad.add_theme_constant_override("margin_right", 42)
    pad.add_theme_constant_override("margin_top", 36)
    pad.add_theme_constant_override("margin_bottom", 36)
    panel.add_child(pad)

    var box: VBoxContainer = VBoxContainer.new()
    box.add_theme_constant_override("separation", 16)
    pad.add_child(box)

    _add_text(box, "TÖRE", 48, GOLD_BRIGHT, HORIZONTAL_ALIGNMENT_CENTER)
    _add_text(box, "Kağanlık Menüsü", 20, MUTED, HORIZONTAL_ALIGNMENT_CENTER)

    var close: Button = _menu_button("OYUNA DÖN", Color("#17382f"))
    close.pressed.connect(func() -> void: nav_layer.visible = false)
    box.add_child(close)

    var journal: Button = _menu_button("KAĞANLIK YILLIĞI", Color("#171b22"))
    journal.pressed.connect(func() -> void: _navigate_from_overlay(chronicle_layer))
    box.add_child(journal)

    var dynasty: Button = _menu_button("HANEDAN VE İLİŞKİLER", Color("#171b22"))
    dynasty.pressed.connect(func() -> void: _navigate_from_overlay(dynasty_layer))
    box.add_child(dynasty)

    var tribes: Button = _menu_button("BOYLAR HARİTASI", Color("#171b22"))
    tribes.pressed.connect(func() -> void: _navigate_from_overlay(tribes_layer))
    box.add_child(tribes)

    var home: Button = _menu_button("ANA MENÜ", Color("#4a2529"))
    home.pressed.connect(func() -> void: _navigate_from_overlay(menu_layer))
    box.add_child(home)

    nav_layer.visible = false

func _open_navigation() -> void:
    nav_layer.visible = true

func _navigate_from_overlay(target: Control) -> void:
    nav_layer.visible = false
    _show_layer(target)

func _show_layer(target: Control) -> void:
    var layers: Array[Control] = [menu_layer, game_layer, chronicle_layer, dynasty_layer, tribes_layer]
    for layer: Control in layers:
        layer.visible = layer == target
    nav_layer.visible = false
    if target == game_layer:
        _refresh_stats()
        _refresh_year()

func _load_cards() -> void:
    var file: FileAccess = FileAccess.open("res://data/cards.json", FileAccess.READ)
    if file == null:
        push_error("cards.json açılamadı.")
        return
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if parsed is Array:
        cards = parsed as Array
    else:
        push_error("cards.json geçerli bir dizi değil.")

func _start_game() -> void:
    card_index = 0
    stats = {"kut":61, "halk":54, "ordu":67, "hazine":46, "guven":58}
    year = 682
    season = "Sonbahar"
    _show_layer(game_layer)
    _refresh_stats()
    _show_card()

func _show_card() -> void:
    if cards.is_empty():
        speaker_label.text = "TÖRE"
        card_text.text = "Kart verisi bulunamadı."
        return

    if card_index >= cards.size():
        card_index = 0
        year += 1
        season = "İlkbahar"

    var card: Dictionary = cards[card_index] as Dictionary
    var left_data: Dictionary = card["left"] as Dictionary
    var right_data: Dictionary = card["right"] as Dictionary
    speaker_label.text = str(card.get("speaker", ""))
    card_text.text = "“" + str(card.get("text", "")) + "”"
    left_button.text = "←  " + str(left_data.get("text", ""))
    right_button.text = str(right_data.get("text", "")) + "  →"
    feedback_label.text = "Kararını ver, Ulu Tarkan."
    _refresh_year()

func _choose(side: String) -> void:
    if cards.is_empty():
        return

    var card: Dictionary = cards[card_index] as Dictionary
    var choice: Dictionary = card.get(side, {}) as Dictionary
    var effects: Dictionary = choice.get("effects", {}) as Dictionary

    for key: Variant in effects.keys():
        if stats.has(key):
            stats[key] = clampi(int(stats[key]) + int(effects[key]), 0, 100)

    feedback_label.text = _effects_text(effects)
    _refresh_stats()
    card_index += 1

    left_button.disabled = true
    right_button.disabled = true
    await get_tree().create_timer(0.65).timeout
    left_button.disabled = false
    right_button.disabled = false
    _show_card()

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
            arrows += arrows + arrows
        elif magnitude >= 4:
            arrows += arrows
        parts.append("%s %s" % [str(names.get(key, key)), arrows])

    return "   •   ".join(parts)

func _refresh_stats() -> void:
    for key: Variant in stat_bars.keys():
        var bar: ProgressBar = stat_bars[key] as ProgressBar
        bar.value = float(stats[key])

    for key: Variant in stat_states.keys():
        var label: Label = stat_states[key] as Label
        label.text = _resource_state(int(stats[key]))

    if is_instance_valid(trust_label):
        trust_label.text = _trust_state(int(stats["guven"]))
        trust_label.add_theme_color_override("font_color", _trust_color(int(stats["guven"])))

func _refresh_year() -> void:
    if is_instance_valid(year_label):
        year_label.text = "%d  •  %s" % [year, season]

func _make_stat(parent: GridContainer, icon_text: String, title_text: String, key: String, fill_color: Color) -> void:
    var panel: PanelContainer = PanelContainer.new()
    panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    panel.custom_minimum_size = Vector2(0, 126)
    panel.add_theme_stylebox_override("panel", _panel_style(Color("#0a1119cc"), Color("#3c4248"), 1, 12))
    parent.add_child(panel)

    var col: VBoxContainer = VBoxContainer.new()
    col.alignment = BoxContainer.ALIGNMENT_CENTER
    col.add_theme_constant_override("separation", 5)
    panel.add_child(col)

    var top_row: HBoxContainer = HBoxContainer.new()
    top_row.alignment = BoxContainer.ALIGNMENT_CENTER
    top_row.add_theme_constant_override("separation", 5)
    col.add_child(top_row)

    var icon: Label = Label.new()
    icon.text = icon_text
    icon.add_theme_font_size_override("font_size", 18)
    icon.add_theme_color_override("font_color", GOLD)
    top_row.add_child(icon)

    var title: Label = Label.new()
    title.text = title_text
    title.add_theme_font_size_override("font_size", 16)
    title.add_theme_color_override("font_color", TEXT)
    top_row.add_child(title)

    var bar: ProgressBar = ProgressBar.new()
    bar.min_value = 0
    bar.max_value = 100
    bar.value = float(stats[key])
    bar.show_percentage = false
    bar.custom_minimum_size = Vector2(0, 12)
    bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    bar.add_theme_stylebox_override("background", _bar_style(TRACK, 6))
    bar.add_theme_stylebox_override("fill", _bar_style(fill_color, 6))
    col.add_child(bar)
    stat_bars[key] = bar

    var state: Label = Label.new()
    state.text = _resource_state(int(stats[key]))
    state.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    state.add_theme_font_size_override("font_size", 15)
    state.add_theme_color_override("font_color", MUTED)
    col.add_child(state)
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
    return "Seni en yakın sırdaşı görüyor"

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
