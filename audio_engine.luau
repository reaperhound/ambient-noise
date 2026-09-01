-- Owns mpv processes, their IPC sockets, and PipeWire master volume.
local AudioEngine = {}
AudioEngine.__index = AudioEngine

-- The bundled recordings are quieter than typical desktop audio. Keep the UI
-- at a familiar 0–100 range while giving each source a small 35% gain boost.
local SOURCE_GAIN = 1.35
local AMPLIFY_GAIN = 1.5

local function playerVolume(sound)
    local amplify = sound.amplified and AMPLIFY_GAIN or 1
    return math.floor(sound.level * SOURCE_GAIN * amplify)
end

local function systemVolume(callback)
    noctalia.runAsync({ "wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@" }, function(result)
        local volume = 100
        local value = result and result.stdout and result.stdout:match("(%d+%.?%d*)")

        if value then
            volume = math.floor((tonumber(value) or 1) * 100)
        end

        callback(volume)
    end)
end

local function commandJson(command)
    local json = '{"command":['

    for index, value in ipairs(command) do
        if index > 1 then
            json = json .. ","
        end

        if type(value) == "string" then
            json = json .. '"' .. value:gsub("\\", "\\\\"):gsub('"', '\\"') .. '"'
        elseif type(value) == "boolean" then
            json = json .. (value and "true" or "false")
        else
            json = json .. tostring(value)
        end
    end

    return json .. "]}"
end

function AudioEngine.new(sounds)
    return setmetatable({
        sounds = sounds,
        running = false,
        masterVolume = 100,
        volumeRequestInFlight = false,
        socketDir = "/tmp/noctalia-ambient-" .. tostring(os.time()),
    }, AudioEngine)
end

function AudioEngine:socketPath(sound)
    return self.socketDir .. "/" .. sound.id .. ".sock"
end

function AudioEngine:sendCommand(sound, command)
    local json = commandJson(command)

    noctalia.runAsync({
        "/bin/sh",
        "-c",
        "printf '%s\\n' '" .. json:gsub("'", "'\\''") .. "' | /usr/bin/socat - UNIX-CONNECT:" .. self:socketPath(sound),
    })
end

function AudioEngine:startSound(sound)
    if sound.playerStarted or sound.starting then
        return
    end

    sound.starting = true
    local socket = self:socketPath(sound)

    -- mpv cannot create this directory itself, so create it before binding IPC.
    noctalia.runAsync({ "mkdir", "-p", self.socketDir }, function(result)
        if not result or result.exitCode ~= 0 then
            sound.starting = false
            noctalia.notifyError("Ambient Sounds", "Could not create the audio control socket directory.")
            return
        end

        noctalia.runAsync({ "rm", "-f", socket }, function()
            sound.playerStarted = true
            sound.starting = false
            noctalia.runAsync({
                "/usr/bin/mpv", "--no-video", "--no-terminal", "--loop-file=inf",
                "--input-ipc-server=" .. socket, "--volume=" .. tostring(playerVolume(sound)),
                noctalia.expandPath(sound.file),
            })
        end)
    end)
end

function AudioEngine:stopSound(sound)
    self:sendCommand(sound, { "quit" })
    noctalia.runAsync({ "/usr/bin/pkill", "-f", "input-ipc-server=" .. self:socketPath(sound) })
    sound.playerStarted = false
    sound.starting = false
end

function AudioEngine:start()
    for _, sound in ipairs(self.sounds) do
        if sound.enabled then
            self:startSound(sound)
        end
    end
    self.running = true
end

function AudioEngine:stopAll()
    for _, sound in ipairs(self.sounds) do
        self:stopSound(sound)
    end
    self.running = false
end

function AudioEngine:toggleSound(id, enabled)
    for _, sound in ipairs(self.sounds) do
        if sound.id == id then
            sound.enabled = enabled == nil and not sound.enabled or enabled
            if self.running then
                if sound.enabled then
                    self:startSound(sound)
                else
                    self:stopSound(sound)
                end
            end
            return
        end
    end
end

function AudioEngine:setSoundVolume(id, value)
    for _, sound in ipairs(self.sounds) do
        if sound.id == id then
            sound.level = value
            if self.running then
                self:sendCommand(sound, { "set_property", "volume", playerVolume(sound) })
            end
            return
        end
    end
end

function AudioEngine:setAmplified(id, enabled)
    for _, sound in ipairs(self.sounds) do
        if sound.id == id then
            sound.amplified = enabled
            if self.running and sound.playerStarted then
                self:sendCommand(sound, { "set_property", "volume", playerVolume(sound) })
            end
            return
        end
    end
end

function AudioEngine:setMasterVolume(value)
    self.masterVolume = value
    noctalia.runAsync({ "wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", tostring(value) .. "%" })
end

function AudioEngine:pauseAll()
    if self.running then
        for _, sound in ipairs(self.sounds) do
            self:sendCommand(sound, { "set_property", "pause", true })
        end
    end
end

function AudioEngine:refreshSystemVolume(onChanged)
    if self.volumeRequestInFlight then
        return
    end
    self.volumeRequestInFlight = true
    systemVolume(function(volume)
        self.volumeRequestInFlight = false
        if volume ~= self.masterVolume then
            self.masterVolume = volume
            onChanged()
        end
    end)
end

function AudioEngine:cleanup()
    self:stopAll()
    noctalia.runAsync({ "/usr/bin/pkill", "-f", "input-ipc-server=" .. self.socketDir })
    noctalia.runAsync({ "rm", "-rf", self.socketDir })
end

return AudioEngine
