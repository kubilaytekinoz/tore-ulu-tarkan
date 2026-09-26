extends Control

const GOLD := Color("#d5ad58")
const GOLD_SOFT := Color("#f0d79a")
const PANEL := Color("#111925")
const PANEL_2 := Color("#182231")
const TEXT := Color("#f3ead8")
const MUTED := Color("#9eabbb")
const GREEN := Color("#1e604f")
const RED := Color("#712f35")

var stats := {"kut":61, "halk":54, "ordu":67, "hazine":46, "guven":58}
var year := 682
var season := "Sonbahar"
var cards: Array = []
var card_index := 0
var menu_layer: Control
var game_layer: Control
var stat_labels := {}
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
    _load_cards()
    _show_menu()

func _build_background() -> void:
    var bg := ColorRect.new()
    bg.color = Color("#070b11")
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(bg)
    var top_glow := ColorRect.new()
    top_glow.color = Color("#112238")
    top_glow.set_anchors_preset(Control.PRESET_TOP_WIDE)
    top_glow.offset_bottom = 520
    top_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(top_glow)

func _build_menu() -> void:
    menu_layer = Control.new()
    menu_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(menu_layer)
    var safe := MarginContainer.new()
    safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    safe.add_theme_constant_override("margin_left", 72)
    safe.add_theme_constant_override("margin_right", 72)
    safe.add_theme_constant_override("margin_top", 110)
    safe.add_theme_constant_override("margin_bottom", 90)
    menu_layer.add_child(safe)
    var column := VBoxContainer.new()
    column.alignment = BoxContainer.ALIGNMENT_CENTER
    column.add_theme_constant_override("separation", 34)
    safe.add_child(column)
    var spacer_top := Control.new(); spacer_top.custom_minimum_size = Vector2(0, 210); column.add_child(spacer_top)
    var emblem := Label.new(); emblem.text = "ᛏ"; emblem.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; emblem.add_theme_font_size_override("font_size", 92); emblem.add_theme_color_override("font_color", GOLD); column.add_child(emblem)
    var title := Label.new(); title.text = "TÖRE"; title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; title.add_theme_font_size_override("font_size", 118); title.add_theme_color_override("font_color", GOLD_SOFT); column.add_child(title)
    var subtitle := Label.new(); subtitle.text = "ULU TARKAN"; subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; subtitle.add_theme_font_size_override("font_size", 34); subtitle.add_theme_color_override("font_color", MUTED); column.add_child(subtitle)
    var motto := Label.new(); motto.text = "Kağanlar değişir. Töre kalır."; motto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; motto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; motto.add_theme_font_size_override("font_size", 29); motto.add_theme_color_override("font_color", TEXT); column.add_child(motto)
    var spacer := Control.new(); spacer.custom_minimum_size = Vector2(0, 120); column.add_child(spacer)
    var start := Button.new(); start.text = "YENİ KAĞANLIK"; start.custom_minimum_size = Vector2(0,112); start.add_theme_font_size_override("font_size",31); _style_button(start,GOLD,Color("#0b1017")); start.pressed.connect(_start_game); column.add_child(start)
    var continue_btn := Button.new(); continue_btn.text = "DEVAM ET  •  YAKINDA"; continue_btn.disabled = true; continue_btn.custom_minimum_size = Vector2(0,90); continue_btn.add_theme_font_size_override("font_size",25); _style_button(continue_btn,Color("#303a47"),MUTED); column.add_child(continue_btn)
    var foot_spacer := Control.new(); foot_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL; column.add_child(foot_spacer)
    var foot := Label.new(); foot.text = "İlk oynanabilir prototip • v0.1"; foot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; foot.add_theme_font_size_override("font_size",22); foot.add_theme_color_override("font_color",Color("#647080")); column.add_child(foot)

func _build_game() -> void:
    game_layer = Control.new(); game_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); add_child(game_layer)
    var safe := MarginContainer.new(); safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); safe.add_theme_constant_override("margin_left",48); safe.add_theme_constant_override("margin_right",48); safe.add_theme_constant_override("margin_top",58); safe.add_theme_constant_override("margin_bottom",48); game_layer.add_child(safe)
    var col := VBoxContainer.new(); col.add_theme_constant_override("separation",22); safe.add_child(col)
    var header := HBoxContainer.new(); header.add_theme_constant_override("separation",12); col.add_child(header)
    var title := Label.new(); title.text="TÖRE"; title.size_flags_horizontal=Control.SIZE_EXPAND_FILL; title.add_theme_font_size_override("font_size",44); title.add_theme_color_override("font_color",GOLD_SOFT); header.add_child(title)
    year_label = Label.new(); year_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT; year_label.add_theme_font_size_override("font_size",24); year_label.add_theme_color_override("font_color",MUTED); header.add_child(year_label)
    var stats_grid := GridContainer.new(); stats_grid.columns=5; stats_grid.add_theme_constant_override("h_separation",10); col.add_child(stats_grid)
    _make_stat(stats_grid,"KUT","kut"); _make_stat(stats_grid,"HALK","halk"); _make_stat(stats_grid,"ORDU","ordu"); _make_stat(stats_grid,"HAZİNE","hazine"); _make_stat(stats_grid,"GÜVEN","guven")
    var line := HSeparator.new(); line.add_theme_color_override("separator",Color("#3a3428")); col.add_child(line)
    var stage := VBoxContainer.new(); stage.size_flags_vertical=Control.SIZE_EXPAND_FILL; stage.alignment=BoxContainer.ALIGNMENT_CENTER; stage.add_theme_constant_override("separation",22); col.add_child(stage)
    var portrait := PanelContainer.new(); portrait.custom_minimum_size=Vector2(0,520); portrait.size_flags_horizontal=Control.SIZE_EXPAND_FILL; portrait.add_theme_stylebox_override("panel",_panel_style(PANEL_2,GOLD,2,28)); stage.add_child(portrait)
    var portrait_inner := VBoxContainer.new(); portrait_inner.alignment=BoxContainer.ALIGNMENT_CENTER; portrait_inner.add_theme_constant_override("separation",10); portrait.add_child(portrait_inner)
    var rune := Label.new(); rune.text="☾  𐱅  ☽"; rune.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; rune.add_theme_font_size_override("font_size",58); rune.add_theme_color_override("font_color",GOLD); portrait_inner.add_child(rune)
    var person := Label.new(); person.text="BÖRÜ KAĞAN"; person.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; person.add_theme_font_size_override("font_size",39); person.add_theme_color_override("font_color",TEXT); portrait_inner.add_child(person)
    var desc := Label.new(); desc.text="Yeni tahta çıktı • 33 yaşında"; desc.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; desc.add_theme_font_size_override("font_size",23); desc.add_theme_color_override("font_color",MUTED); portrait_inner.add_child(desc)
    var card := PanelContainer.new(); card.custom_minimum_size=Vector2(0,430); card.size_flags_horizontal=Control.SIZE_EXPAND_FILL; card.add_theme_stylebox_override("panel",_panel_style(PANEL,Color("#66583d"),2,24)); stage.add_child(card)
    var pad := MarginContainer.new(); pad.add_theme_constant_override("margin_left",34); pad.add_theme_constant_override("margin_right",34); pad.add_theme_constant_override("margin_top",30); pad.add_theme_constant_override("margin_bottom",28); card.add_child(pad)
    var ccol := VBoxContainer.new(); ccol.alignment=BoxContainer.ALIGNMENT_CENTER; ccol.add_theme_constant_override("separation",18); pad.add_child(ccol)
    speaker_label=Label.new(); speaker_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; speaker_label.add_theme_font_size_override("font_size",25); speaker_label.add_theme_color_override("font_color",GOLD); ccol.add_child(speaker_label)
    card_text=Label.new(); card_text.size_flags_vertical=Control.SIZE_EXPAND_FILL; card_text.vertical_alignment=VERTICAL_ALIGNMENT_CENTER; card_text.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; card_text.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; card_text.add_theme_font_size_override("font_size",31); card_text.add_theme_color_override("font_color",TEXT); ccol.add_child(card_text)
    feedback_label=Label.new(); feedback_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; feedback_label.add_theme_font_size_override("font_size",20); feedback_label.add_theme_color_override("font_color",MUTED); ccol.add_child(feedback_label)
    var choices := HBoxContainer.new(); choices.add_theme_constant_override("separation",14); col.add_child(choices)
    left_button=Button.new(); left_button.size_flags_horizontal=Control.SIZE_EXPAND_FILL; left_button.custom_minimum_size=Vector2(0,142); left_button.add_theme_font_size_override("font_size",23); left_button.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; _style_button(left_button,GREEN,TEXT); left_button.pressed.connect(func(): _choose("left")); choices.add_child(left_button)
    right_button=Button.new(); right_button.size_flags_horizontal=Control.SIZE_EXPAND_FILL; right_button.custom_minimum_size=Vector2(0,142); right_button.add_theme_font_size_override("font_size",23); right_button.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; _style_button(right_button,RED,TEXT); right_button.pressed.connect(func(): _choose("right")); choices.add_child(right_button)

func _load_cards() -> void:
    var file := FileAccess.open("res://data/cards.json",FileAccess.READ)
    if file == null: push_error("cards.json açılamadı."); return
    var parsed = JSON.parse_string(file.get_as_text())
    if parsed is Array: cards = parsed
    else: push_error("cards.json geçerli bir dizi değil.")

func _show_menu() -> void:
    menu_layer.visible=true; game_layer.visible=false

func _start_game() -> void:
    card_index=0; stats={"kut":61,"halk":54,"ordu":67,"hazine":46,"guven":58}; year=682; season="Sonbahar"
    menu_layer.visible=false; game_layer.visible=true; _refresh_stats(); _show_card()

func _show_card() -> void:
    if cards.is_empty(): speaker_label.text="TÖRE"; card_text.text="Kart verisi bulunamadı."; return
    if card_index >= cards.size(): card_index=0; year += 1; season="İlkbahar"
    var card: Dictionary = cards[card_index]
    speaker_label.text=str(card.get("speaker","")); card_text.text=str(card.get("text",""))
    left_button.text="←  "+str(card["left"].get("text","")); right_button.text=str(card["right"].get("text",""))+"  →"
    feedback_label.text="Kararını ver, Ulu Tarkan."; _refresh_year()

func _choose(side: String) -> void:
    if cards.is_empty(): return
    var card: Dictionary = cards[card_index]
    var choice: Dictionary = card.get(side,{})
    var effects: Dictionary = choice.get("effects",{})
    for key in effects.keys():
        if stats.has(key): stats[key]=clampi(int(stats[key])+int(effects[key]),0,100)
    feedback_label.text=_effects_text(effects); _refresh_stats(); card_index += 1
    left_button.disabled=true; right_button.disabled=true
    await get_tree().create_timer(0.55).timeout
    left_button.disabled=false; right_button.disabled=false; _show_card()

func _effects_text(effects: Dictionary) -> String:
    var names={"kut":"Kut","halk":"Halk","ordu":"Ordu","hazine":"Hazine","guven":"Güven"}
    var parts:Array[String]=[]
    for key in effects.keys():
        var value:=int(effects[key]); var sign := "+" if value > 0 else ""
        parts.append("%s %s%d" % [names.get(key,key),sign,value])
    return "  •  ".join(parts)

func _refresh_stats() -> void:
    for key in stat_labels.keys(): stat_labels[key].text=str(stats[key])

func _refresh_year() -> void:
    year_label.text="%d • %s" % [year,season]

func _make_stat(parent: GridContainer,title_text:String,key:String) -> void:
    var panel:=PanelContainer.new(); panel.size_flags_horizontal=Control.SIZE_EXPAND_FILL; panel.custom_minimum_size=Vector2(0,122); panel.add_theme_stylebox_override("panel",_panel_style(Color("#0d141d"),Color("#353e48"),1,16)); parent.add_child(panel)
    var col:=VBoxContainer.new(); col.alignment=BoxContainer.ALIGNMENT_CENTER; panel.add_child(col)
    var title:=Label.new(); title.text=title_text; title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; title.add_theme_font_size_override("font_size",17); title.add_theme_color_override("font_color",MUTED); col.add_child(title)
    var value:=Label.new(); value.text=str(stats[key]); value.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; value.add_theme_font_size_override("font_size",29); value.add_theme_color_override("font_color",GOLD_SOFT); col.add_child(value); stat_labels[key]=value

func _style_button(button:Button,base:Color,font_color:Color) -> void:
    var normal:=_panel_style(base,base.lightened(0.18),2,18); var hover:=_panel_style(base.lightened(0.08),GOLD,2,18); var pressed:=_panel_style(base.darkened(0.10),GOLD_SOFT,2,18)
    button.add_theme_stylebox_override("normal",normal); button.add_theme_stylebox_override("hover",hover); button.add_theme_stylebox_override("pressed",pressed); button.add_theme_stylebox_override("focus",hover); button.add_theme_color_override("font_color",font_color); button.add_theme_color_override("font_hover_color",TEXT); button.add_theme_color_override("font_pressed_color",TEXT)

func _panel_style(bg:Color,border:Color,border_width:int,radius:int) -> StyleBoxFlat:
    var s:=StyleBoxFlat.new(); s.bg_color=bg; s.border_color=border; s.set_border_width_all(border_width); s.corner_radius_top_left=radius; s.corner_radius_top_right=radius; s.corner_radius_bottom_left=radius; s.corner_radius_bottom_right=radius; s.content_margin_left=18; s.content_margin_right=18; s.content_margin_top=14; s.content_margin_bottom=14; return s
