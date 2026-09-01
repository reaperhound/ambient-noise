-- Compact bar entry for opening the full ambient-sound mixer.
barWidget.setGlyph("headphones")
barWidget.setTooltip({
    { key = "Ambient Sounds", value = "Open mixer" },
    { key = "Click", value = "Toggle panel" },
})

function onClick()
    noctalia.togglePanel("reaper/ambient-sounds:main")
end
