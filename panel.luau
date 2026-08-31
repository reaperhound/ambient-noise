local soundLoaded = false

local function render()
    panel.render(
        ui.column({
            gap = 16,
            padding = 20,
        }, {
            ui.label({
                text = "Ambient Sounds",
                fontSize = 22,
                fontWeight = "bold",
            }),

            ui.label({
                text = soundLoaded and "Ready" or "Loading sound...",
            }),

            ui.button({
                text = "🎧  Test Sound",
                onClick = "playTest",
                enabled = soundLoaded,
            }),
        })
    )
end

local function onSoundLoaded(ok, err)
    if ok then
        soundLoaded = true
        render()
    else
        noctalia.notifyError(
            "Ambient Sounds",
            "Could not load sound: " .. tostring(err)
        )
    end
end

noctalia.sound.load(
    "test",
    "sounds/test.ogg",
    onSoundLoaded
)

function onOpen(context)
    render()
end

function playTest()
    if soundLoaded then
        noctalia.sound.play("test")
    end
end
