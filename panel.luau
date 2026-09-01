-- Panel entry point: composes the sound library, audio engine, and UI.
local sounds = require("./sound_library.luau")
local AudioEngine = require("./audio_engine.luau")
local engine = AudioEngine.new(sounds)

local function soundCard(sound)
    local panText = sound.pan == 0 and "CTR" or (sound.pan < 0 and "L" .. math.abs(sound.pan) or "R" .. sound.pan)
    return ui.column({ gap = 12, padding = 16, flexGrow = 1, minWidth = 300,
        fill = sound.enabled and "surface_variant/0.38" or "surface_variant/0.20", radius = 16,
        border = sound.enabled and "primary/0.45" or "outline/0.35", borderWidth = 1 }, {
        ui.row({ gap = 12, align = "center" }, {
            ui.box({ width = 46, height = 46, fill = "surface/0.7", radius = 12, border = "outline/0.25", borderWidth = 1, align = "center" }, {
                ui.label({ text = sound.icon, fontSize = 22 }),
            }),
            ui.column({ gap = 3, flexGrow = 1 }, {
                ui.label({ text = sound.title, fontSize = 15, fontWeight = "bold" }),
                ui.label({ text = sound.description, fontSize = 11, color = "on_surface_variant", maxLines = 2 }),
            }),
            ui.toggle({ checked = sound.enabled, onChanged = function(value) engine:toggleSound(sound.id, value); render() end }),
        }),
        ui.separator({ thickness = 1, color = "outline/0.25" }),
        ui.row({ gap = 10, align = "center" }, {
            ui.label({ text = "LEVEL", fontSize = 10, color = "on_surface_variant", width = 42 }),
            ui.slider({ min = 0, max = 100, step = 1, value = sound.level, controlSize = "sm", flexGrow = 1,
                onChanged = function(value) engine:setSoundVolume(sound.id, value); render() end }),
            ui.label({ text = sound.level .. "%", fontSize = 11, color = "primary", width = 35, textAlign = "end" }),
        }),
        ui.row({ gap = 10, align = "center" }, {
            ui.label({ text = "PAN", fontSize = 10, color = "on_surface_variant", width = 42 }),
            ui.slider({ min = -100, max = 100, step = 1, value = sound.pan, controlSize = "sm", flexGrow = 1 }),
            ui.label({ text = panText, fontSize = 11, color = "primary", width = 35, textAlign = "end" }),
        }),
        ui.button({
            text = sound.amplified and "⚡  Amplified" or "⚡  Amplify",
            variant = sound.amplified and "primary" or "outline",
            controlSize = "sm",
            onClick = function()
                engine:setAmplified(sound.id, not sound.amplified)
                render()
            end,
        }),
    })
end

function render()
    local cards = {}
    for _, sound in ipairs(sounds) do table.insert(cards, soundCard(sound)) end

    panel.render(ui.column({ gap = 18, padding = 22 }, {
        ui.row({ gap = 18, padding = 20, align = "center", fill = "surface_variant/0.30", radius = 18,
            border = engine.running and "primary/0.65" or "primary/0.35", borderWidth = 1 }, {
            ui.box({ width = 58, height = 58, fill = "surface/0.75", radius = 16, border = "primary/0.7", borderWidth = 1, align = "center" }, {
                ui.label({ text = "♫", fontSize = 30, color = "primary" }),
            }),
            ui.column({ gap = 4, flexGrow = 1 }, {
                ui.label({ text = "Ambient Sounds", fontSize = 25, fontWeight = "bold" }),
                ui.label({ text = engine.running and "Engine running" or "High-Fidelity Ambient Sound Mixer", fontSize = 12, color = "on_surface_variant" }),
            }),
            ui.button({ text = engine.running and "■  STOP ENGINE" or "▶  START ENGINE", variant = engine.running and "outline" or "primary", controlSize = "md",
                onClick = function() if engine.running then engine:stopAll() else engine:start() end; render() end }),
        }),
        ui.row({ gap = 12, flexGrow = 1, align = "stretch" }, cards),
        ui.row({ gap = 16, padding = 14, align = "center", fill = "surface_variant/0.30", radius = 16, border = "outline/0.3", borderWidth = 1 }, {
            ui.label({ text = "🔊  SYSTEM VOLUME", fontSize = 11, fontWeight = "bold", color = "on_surface_variant" }),
            ui.slider({ min = 0, max = 100, step = 1, value = engine.masterVolume, controlSize = "sm", flexGrow = 1,
                onChanged = function(value) engine:setMasterVolume(value); render() end }),
            ui.label({ text = engine.masterVolume .. "%", fontSize = 12, color = "primary", width = 38, textAlign = "end" }),
            ui.button({ text = "Ⅱ  Pause All", variant = "outline", controlSize = "sm", onClick = function() engine:pauseAll() end }),
            ui.button({ text = "■  Stop All", variant = "outline", controlSize = "sm", onClick = function() engine:stopAll(); render() end }),
        }),
    }))
end

function onOpen(_context)
    noctalia.setUpdateInterval(1500)
    render()
    engine:refreshSystemVolume(render)
end

function update()
    engine:refreshSystemVolume(render)
end

function onExit(_signal, _reason)
    engine:cleanup()
end
