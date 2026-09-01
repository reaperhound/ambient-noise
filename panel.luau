local function soundCard(icon, title, description, enabled, level, pan)
    local panText

    if pan == 0 then
        panText = "CTR"
    elseif pan < 0 then
        panText = "L" .. math.abs(pan)
    else
        panText = "R" .. pan
    end

    return ui.column({
        gap = 12,
        padding = 16,
        flexGrow = 1,
        fill = "surface_variant/0.32",
        radius = 16,
        border = "outline/0.35",
        borderWidth = 1,
        minWidth = 300,
    }, {
        -- Card header
        ui.row({
            gap = 12,
            align = "center",
        }, {
            ui.box({
                width = 46,
                height = 46,
                fill = "surface/0.7",
                radius = 12,
                border = "outline/0.25",
                borderWidth = 1,
                align = "center",
            }, {
                ui.label({
                    text = icon,
                    fontSize = 22,
                }),
            }),

            ui.column({
                gap = 3,
                flexGrow = 1,
            }, {
                ui.label({
                    text = title,
                    fontSize = 15,
                    fontWeight = "bold",
                }),

                ui.label({
                    text = description,
                    fontSize = 11,
                    color = "on_surface_variant",
                    maxLines = 2,
                }),
            }),

            ui.toggle({
                checked = enabled,
            }),
        }),

        ui.separator({
            thickness = 1,
            color = "outline/0.25",
        }),

        -- Level
        ui.row({
            gap = 10,
            align = "center",
        }, {
            ui.label({
                text = "LEVEL",
                fontSize = 10,
                color = "on_surface_variant",
                width = 42,
            }),

            ui.slider({
                min = 0,
                max = 100,
                step = 1,
                value = level,
                controlSize = "sm",
                flexGrow = 1,
            }),

            ui.label({
                text = level .. "%",
                fontSize = 11,
                color = "primary",
                width = 35,
                textAlign = "end",
            }),
        }),

        -- Pan
        ui.row({
            gap = 10,
            align = "center",
        }, {
            ui.label({
                text = "PAN",
                fontSize = 10,
                color = "on_surface_variant",
                width = 42,
            }),

            ui.slider({
                min = -100,
                max = 100,
                step = 1,
                value = pan,
                controlSize = "sm",
                flexGrow = 1,
            }),

            ui.label({
                text = panText,
                fontSize = 11,
                color = "primary",
                width = 35,
                textAlign = "end",
            }),
        }),
    })
end


local function preset(text, selected)
    return ui.button({
        text = text,
        variant = selected and "primary" or "outline",
        controlSize = "sm",
        flexGrow = 1,
    })
end


local function render()
    panel.render(
        ui.column({
            gap = 18,
            padding = 22,
        }, {

            -- =====================================================
            -- HEADER
            -- =====================================================

            ui.row({
                gap = 18,
                padding = 20,
                align = "center",
                fill = "surface_variant/0.30",
                radius = 18,
                border = "primary/0.35",
                borderWidth = 1,
            }, {

                -- Icon
                ui.box({
                    width = 58,
                    height = 58,
                    fill = "surface/0.75",
                    radius = 16,
                    border = "primary/0.7",
                    borderWidth = 1,
                    align = "center",
                }, {
                    ui.label({
                        text = "♫",
                        fontSize = 30,
                        color = "primary",
                    }),
                }),

                -- Title
                ui.column({
                    gap = 4,
                    flexGrow = 1,
                }, {
                    ui.row({
                        gap = 8,
                        align = "center",
                    }, {
                        ui.label({
                            text = "Ambient Sounds",
                            fontSize = 25,
                            fontWeight = "bold",
                        }),

                        ui.label({
                            text = "v0.1.0",
                            fontSize = 10,
                            color = "primary",
                            fill = "primary/0.12",
                            radius = 7,
                            paddingH = 7,
                            paddingV = 3,
                        }),
                    }),

                    ui.label({
                        text = "High-Fidelity Ambient Sound Mixer",
                        fontSize = 12,
                        color = "on_surface_variant",
                    }),
                }),

                -- Engine controls
                ui.column({
                    gap = 8,
                    width = 190,
                }, {
                    ui.button({
                        text = "DSP SPECTRUM",
                        variant = "outline",
                        controlSize = "sm",
                    }),

                    ui.button({
                        text = "▶  START ENGINE",
                        variant = "primary",
                        controlSize = "md",
                    }),
                }),

                -- Master volume
                ui.column({
                    gap = 8,
                    width = 230,
                    padding = 12,
                    fill = "surface/0.45",
                    radius = 12,
                    border = "outline/0.25",
                    borderWidth = 1,
                }, {
                    ui.row({
                        gap = 10,
                        align = "center",
                    }, {
                        ui.label({
                            text = "🔊",
                            fontSize = 17,
                        }),

                        ui.slider({
                            min = 0,
                            max = 100,
                            step = 1,
                            value = 70,
                            controlSize = "sm",
                            flexGrow = 1,
                        }),

                        ui.label({
                            text = "70%",
                            fontSize = 11,
                            color = "primary",
                            width = 32,
                            textAlign = "end",
                        }),
                    }),
                }),
            }),


            -- =====================================================
            -- PRESETS HEADER
            -- =====================================================

            ui.row({
                align = "center",
                justify = "space_between",
            }, {
                ui.label({
                    text = "✦  CURATED SOUNDSCAPE PRESETS",
                    fontSize = 13,
                    fontWeight = "bold",
                    color = "on_surface_variant",
                }),

                ui.row({
                    gap = 8,
                }, {
                    ui.button({
                        text = "⤨  Shuffle Mix",
                        variant = "outline",
                        controlSize = "sm",
                    }),

                    ui.button({
                        text = "+  Save Mix",
                        variant = "outline",
                        controlSize = "sm",
                    }),
                }),
            }),


            -- =====================================================
            -- PRESET CHIPS
            -- =====================================================

            ui.row({
                gap = 8,
                align = "center",
            }, {
                preset("⚡  Cyberpunk Rainstorm", true),
                preset("💻  Deep Focus Terminal", false),
                preset("🔥  Nordic Cabin Fire", false),
                preset("🚆  Midnight Train", false),
                preset("🌌  Zen Space Drift", false),
                preset("🌙  Deep Sleep", false),
            }),


            -- =====================================================
            -- CATEGORY BAR
            -- =====================================================

            ui.row({
                gap = 6,
                align = "center",
            }, {
                ui.button({
                    text = "All Generators (6)",
                    variant = "primary",
                    controlSize = "sm",
                }),

                ui.button({
                    text = "Nature & Elements",
                    variant = "ghost",
                    controlSize = "sm",
                }),

                ui.button({
                    text = "Urban & Focus",
                    variant = "ghost",
                    controlSize = "sm",
                }),

                ui.button({
                    text = "Noise & Drones",
                    variant = "ghost",
                    controlSize = "sm",
                }),

                ui.spacer({
                    flexGrow = 1,
                }),

                ui.button({
                    text = "■  Stop All",
                    variant = "outline",
                    controlSize = "sm",
                }),
            }),

            ui.separator({
                thickness = 1,
                color = "outline/0.3",
            }),


            -- =====================================================
            -- SOUND GRID
            -- =====================================================

            ui.column({
                gap = 12,
                flexGrow = 1,
            }, {

                ui.row({
                    gap = 12,
                    flexGrow = 1,
                    align = "stretch",
                }, {
                    soundCard(
                        "🌧️",
                        "Rain Storm",
                        "Continuous rainfall with natural variations",
                        true,
                        65,
                        -20
                    ),

                    soundCard(
                        "⚡",
                        "Distant Thunder",
                        "Deep sub-bass acoustic thunder rumbles",
                        true,
                        45,
                        30
                    ),

                    soundCard(
                        "🌬️",
                        "Mountain Wind",
                        "Resonant howling gusts with depth",
                        false,
                        50,
                        0
                    ),
                }),

                ui.row({
                    gap = 12,
                    flexGrow = 1,
                    align = "stretch",
                }, {
                    soundCard(
                        "🔥",
                        "Campfire",
                        "Warm crackling embers and wood pops",
                        false,
                        60,
                        20
                    ),

                    soundCard(
                        "🌊",
                        "Ocean Waves",
                        "Cyclical low-frequency tidal waves",
                        false,
                        55,
                        0
                    ),

                    soundCard(
                        "⌨️",
                        "Mechanical Keys",
                        "Tactile mechanical keyboard typing",
                        true,
                        70,
                        -10
                    ),
                }),
            }),


            -- =====================================================
            -- BOTTOM CONTROL
            -- =====================================================

            ui.row({
                gap = 16,
                padding = 14,
                align = "center",
                fill = "surface_variant/0.30",
                radius = 16,
                border = "outline/0.3",
                borderWidth = 1,
            }, {
                ui.label({
                    text = "🔊  MASTER VOLUME",
                    fontSize = 11,
                    fontWeight = "bold",
                    color = "on_surface_variant",
                }),

                ui.slider({
                    min = 0,
                    max = 100,
                    step = 1,
                    value = 70,
                    controlSize = "sm",
                    flexGrow = 1,
                }),

                ui.label({
                    text = "70%",
                    fontSize = 12,
                    color = "primary",
                    width = 38,
                    textAlign = "end",
                }),

                ui.button({
                    text = "Ⅱ  Pause All",
                    variant = "outline",
                    controlSize = "sm",
                }),

                ui.button({
                    text = "■  Stop All",
                    variant = "outline",
                    controlSize = "sm",
                }),
            }),
        })
    )
end


function onOpen(context)
    render()
end
