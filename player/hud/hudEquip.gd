extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalPlayer.update.connect(self.updateHud)
	GlobalPlayer.instantiate()

func updateHud():
	match GlobalPlayer.instrument:
		"lute":
			%Instrument.texture = load(GlobalInstruments.instruments["lute"]["icon"]) as Texture
			%name.text = str(GlobalPlayer.rarity).capitalize() + " " + str(GlobalPlayer.instrument).capitalize()
			%desc.text = GlobalInstruments.instruments["lute"]["description"]
			%active.text = GlobalInstruments.instruments["lute"]["active"]
			%passive.text = "+Range"
		"drum":
			%Instrument.texture = load(GlobalInstruments.instruments["drum"]["icon"]) as Texture
			%name.text = str(GlobalPlayer.rarity).capitalize() + " " + str(GlobalPlayer.instrument).capitalize()
			%desc.text = GlobalInstruments.instruments["drum"]["description"]
			%active.text = GlobalInstruments.instruments["drum"]["active"]
			%passive.text = "+Walkspeed"
			
		"recorder":
			%Instrument.texture = load(GlobalInstruments.instruments["recorder"]["icon"]) as Texture
			%name.text = str(GlobalPlayer.rarity).capitalize() + " " + str(GlobalPlayer.instrument).capitalize()
			%desc.text = GlobalInstruments.instruments["recorder"]["description"]
			%active.text = GlobalInstruments.instruments["recorder"]["active"]
			%passive.text = "+MaxHealth"
		_:
			%Instrument.texture = null
			%name.text = "None"
			%desc.text = ""
			%active.text = ""
			%passive.text = ""

	match GlobalPlayer.rarity:
		"common":
			%name.label_settings.font_color = Color(0.754, 0.754, 0.754)
		"rare":
			%name.label_settings.font_color = Color(0.141,0.443,0.639)
		"epic":
			%name.label_settings.font_color = Color(0.49,0.235,0.596)
		"legendary":
			%name.label_settings.font_color = Color(0.945,0.769,0.059)

	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
