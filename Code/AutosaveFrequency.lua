local LICENSE = [[
Any code from https://github.com/HaemimontGames/SurvivingMars is copyright by their LICENSE

All of my code is licensed under the MIT License as follows:

MIT License

Copyright (c) [2018] [Dawnmist]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

-- Update the autosave frequency
local modName = "Dawnmist_AutosaveFrequency"
-- Defaults for period and number of autosaves
local autosaveInterval = 1
local numAutosaves = 5

-- Load translation data
local mod_dir = Mods[modName].path

-- Set Autosave Frequency, and align next autosave to multiple of frequency
local function SetAutosaveFrequency()
    const.AutosavePeriod = autosaveInterval -- sols
    if not UICity then
        return
    end
    local autosaveRemainder = UICity.day % autosaveInterval
    -- Align next autosave to next Sol divisible by the frequency
    -- e.g. if set to 4 days at day 90, next autosave sol will be 92, then incrementing by 4 after that.
    g_NextAutosaveSol = UICity.day + (const.AutosavePeriod - autosaveRemainder)
end

local function SetNextAutosaveSol()
    g_NextAutosaveSol = UICity.day + const.AutosavePeriod
end

-- Unfortunately, the number of autosaves to keep is *not* a configurable option normally, so
-- in order to be able to customise it the entire original Autosave function needs to be replaced.
local oldAutosave = Autosave
function Autosave()
    if Platform.demo or GameState.multiplayer or not AccountStorage.Options.Autosave or g_Tutorial then
        SetNextAutosaveSol()
        return
    end
        
    while not CanSaveGame() do
        Sleep(1000)
    end
        
    LoadingScreenOpen("idAutosaveScreen", "save savegame")
    SetNextAutosaveSol()
    --make sure the ingame interface is in a UnitDirection Mode before saving
    --switch to selection mode if needed
    local igi = GetInGameInterface()
    if igi and not igi.mode_dialog:IsKindOf("UnitDirectionModeDialog") then
        igi:SetMode("selection")
    end
        
    local err, list = Savegame.ListForTag("savegame")

    -- 1. Get a list of autosaves
    local autosaves = {}
    if not err then
        for _, v in ipairs(list) do
            err = GetFullMetadata(v)
            if not err and v.autosave then
                autosaves[#autosaves + 1] = v
            end
        end
    end

    -- Sort saves by timestamp from newest to oldest (we'll remove the oldest few)
    table.sort(autosaves,
        function(a, b)
            return a.timestamp > b.timestamp
        end
    )

    -- Game's normal autosave translation string
    local display_name = _InternalTranslate(T{3688, "Autosave Sol <current_sol>", current_sol = UICity.day})
        
    -- 2. Save
    err = SaveAutosaveGame(display_name)
    -- ATTN: delay closing the saving screen until we delete the old autosaves
        
    if err then
        LoadingScreenClose("idAutosaveScreen", "save savegame")
        local preset
        if err == "Disk Full" or err == "orbis1gb" then
            preset = Platform.ps4 and "AutosaveFailedNoSpacePS4" or "AutosaveFailedNoSpace"
        else
            preset = "AutosaveFailedGeneric"
        end
        WaitPopupNotification(preset, {error_code = T{err}})
        return 
    end
        
    -- 3. Leave only the last X savegames (default 5)
    --    no error handler, since this is not a user-initiated action, and we've done our main job already
    for i=numAutosaves, #autosaves do
        DeleteGame(autosaves[i].savename)
    end
    
    LoadingScreenClose("idAutosaveScreen", "save savegame")
end

-- Optional Mod Configuration
function OnMsg.ModConfigReady()
    -- Register mod's name and description
    ModConfig:RegisterMod(modName,
        T{10203040, "Autosave Frequency"},
        T{10203041, "Configure the frequency of autosaving and the number of autosave files to keep"}
    )
    
    ModConfig:RegisterOption(modName, "AutosaveInterval", {
        name = T{10203042, "Autosave Interval"},
        desc = T{10203043, "Number of Sols between Autosaves"},
        order = 0,
        default = 1,
        type = "number",
        min = 1,
        max = 10,
        step = 1
    })
    
    ModConfig:RegisterOption(modName, "NumAutosaves", {
        name = T{10203044, "Autosave Count"},
        desc = T{10203045, "Number of Autosave files to keep"},
        order = 1,
        default = 5,
        type = "number",
        min = 1,
        max = 10,
        step = 1
    })
end

-- Updated settings from ModConfig
function OnMsg.ModConfigChanged(mod_id, option_id, value, old_value)
    if mod_id == modName then
        if option_id == "AutosaveInterval" then
            autosaveInterval = value
            SetAutosaveFrequency()
        elseif option_id == "NumAutosaves" then
            numAutosaves = value
        end
    end
end

-- Load settings from ModConfig
function OnMsg.UIReady()
    local ModConfig_id = "1340775972"
    local g_ModConfigLoaded = table.find_value(ModsLoaded, "steam_id", ModConfig_id) or false

    if g_ModConfigLoaded then
        autosaveInterval = ModConfig:Get(modName, "AutosaveInterval")
        numAutosaves = ModConfig:Get(modName, "NumAutosaves")
        SetAutosaveFrequency()
    end
end

-- Load default settings on reloading a save file
function OnMsg.PersistLoad(data)
    SetAutosaveFrequency()
end

-- Load default settings on loading a new map
function OnMsg.NewMap(data)
    SetAutosaveFrequency()
end
