-- Compact bar entry for opening the full ambient-sound mixer.
local customIconFont = noctalia.loadFont("icons/fluent-person-sound-spatial.otf")
if customIconFont then
    barWidget.setFont(customIconFont, "pictographic")
    barWidget.setText("\u{E000}")
else
    barWidget.setGlyph("headphones")
end
barWidget.setTooltip({
    { key = "Ambient Sounds", value = "Open mixer" },
    { key = "Click", value = "Toggle panel" },
})

function onClick()
    noctalia.togglePanel("reaper/ambient-sounds:main")
end
