local imgui = require 'mimgui'
local json = require "jbp"
local MoonCore = require "ubplibs.MoonCore"
local faicons = require('fAwesome6')
local vk = require('vkeys')
local encoding = require('encoding')
encoding.default = 'CP1251'
local u8 = encoding.UTF8

local render = MoonCore.class("render", {
    extends = MoonCore.BaseClass,
    private = {
        _initStorage = function(self, dependencies)
            if not doesDirectoryExist(dependencies.render.path) then
                createDirectory(dependencies.render.path)
                print("Created directory: " .. dependencies.render.path)
            end
            local defaultConfig = {
                window = {
                    show = imgui.new.bool(false),
                    clickerSettings = {
                        isClicking = imgui.new.bool(false),
                        isActivated = imgui.new.bool(false),
                        clickMainInterval = 100,
                        clickInterval = 20,
                        clickButton = 0,
                        clickCount = 5,
                        currentTime = 0,
                        timerEndTime = 0,
                        timeUnitIndex = 0,
                        clickIntervalUnitIndex = 0
                    }
                }
            }
            local function compareTableStructure(t1, t2)
                if type(t1) ~= type(t2) then return false end
                if type(t1) ~= "table" then return true end
                
                for k, v in pairs(t1) do
                    if t2[k] == nil then return false end
                    if not compareTableStructure(v, t2[k]) then return false end
                end
                
                for k, v in pairs(t2) do
                    if t1[k] == nil then return false end
                end
                
                return true
            end
            local function mergeConfigs(default, saved)
                local result = {}
                for k, v in pairs(default) do
                    if type(v) == "table" and type(saved[k]) == "table" then
                        result[k] = mergeConfigs(v, saved[k])
                    else
                        result[k] = saved[k] ~= nil and saved[k] or v
                    end
                end
                return result
            end
            self.storage = json.create(defaultConfig)
            if doesFileExist(self.ConfigName) then
                local savedConfig = json.load_from_file(self.ConfigName)
                if savedConfig then
                    if compareTableStructure(defaultConfig, savedConfig) then
                        self.storage = json.create(savedConfig)
                    else
                        local mergedConfig = mergeConfigs(defaultConfig, savedConfig)
                        self.storage = json.create(mergedConfig)
                        self.storage:save_to_file(self.ConfigName, true, 2)
                    end
                else
                    self.storage:save_to_file(self.ConfigName, true, 2)
                end
            else
                self.storage:save_to_file(self.ConfigName, true, 2)
            end            
        end
    },
    public = {
        init = function(self, dependencies)
            MoonCore.BaseClass.init(self, dependencies)
            self.ConfigName = dependencies.render.path .. "render.json"
            self:_initStorage(dependencies)
            self:InitializeFonts(dependencies)
            self:RenderWindow(dependencies)
            
            self.timerID = lua_thread.create(function()
                while true do
                    wait(50)
                    self:_updateClickerTimer()
                end
            end)
        end, 
        InitializeFonts = function(self, dependencies)
            imgui.OnInitialize(function()
                local status, err = pcall(function()
                    dependencies.imguifunc:setupTheme()
                    imgui.GetIO().IniFilename = nil
                    local config = imgui.ImFontConfig()
                    config.MergeMode = true
                    config.PixelSnapH = true
                    iconRanges = imgui.new.ImWchar[3](faicons.min_range, faicons.max_range, 0)
                    imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(faicons.get_font_data_base85('solid'), 14, config, iconRanges) -- solid - тип иконок, так же есть thin, regular, light и duotone
                end)
                if not status then
                    print("Error loading fonts: " .. tostring(err))
                end
            end)
        end,     
        OpenMenu = function(self)
            self.storage:set("window.show.value", not self.storage:get("window.show")[0])
        end,
        RenderWindow = function(self, dependencies)
            imgui.OnFrame(
                function() return self.storage:get("window.show")[0] end,
                function(selfFrame)
                    local status, err = pcall(function()   
                        local resX, resY = getScreenResolution()
                        imgui.SetNextWindowPos(imgui.ImVec2(resX/2, resY/2), imgui.Cond.FirstUseEver)
                        imgui.SetNextWindowSize(imgui.ImVec2(350, 550), imgui.Cond.Always)
                        imgui.Begin(u8"clickerMenu", self.storage:get("window.show"), 
                        imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
                            imgui.SetCursorPos(imgui.ImVec2(15, 15))
                            imgui.BeginChild("panel", imgui.ImVec2(320, 520), true)
                                local updatedConfig = dependencies.imguifunc:renderClickerPanel(self.storage)
                                if updatedConfig then
                                    updatedConfig:save_to_file(self.ConfigName, true, 2)
                                end                                     
                            imgui.EndChild()
                        imgui.End()
                    end)
                    if not status then
                        print("Error loading fonts: " .. tostring(err))
                    end
                end
            )
        end,
        _updateClickerTimer = function(self)
            local settings = self.storage:get("window.clickerSettings")
            
            if settings.isClicking[0] then
                local currentTime = os.clock() * 1000
                local remainingTime = math.max(0, settings.clickMainInterval - (currentTime % settings.clickMainInterval))
                settings.currentTime = math.floor(remainingTime)
                
                if remainingTime < 10 and settings.clickCount > 0 then
                    self:_performClicks(settings.clickCount, settings.clickInterval, settings.clickButton)
                end
                
                if settings.timerEndTime > 0 and os.time() >= settings.timerEndTime then
                    settings.isClicking[0] = false
                    settings.timerEndTime = 0
                    self.storage:save_to_file(self.ConfigName, true, 2)
                end
            else
                settings.currentTime = 0
            end
        end,
        _performClicks = function(self, count, interval, button)
            local settings = self.storage:get("window.clickerSettings")
            if not settings.isActivated[0] then return end
            
            lua_thread.create(function()
                for i = 1, count do
                    if not settings.isClicking[0] then break end
                    
                    -- Выполняем клик
                    if button == 0 then
                        -- Левая кнопка мыши
                        setGameKeyState(1, 255) -- Нажатие
                        wait(10)
                        setGameKeyState(1, 0) -- Отпускание
                    elseif button == 1 then
                        -- Правая кнопка мыши
                        setGameKeyState(2, 255) -- Нажатие
                        wait(10)
                        setGameKeyState(2, 0) -- Отпускание
                    elseif button == 2 then
                        -- Средняя кнопка мыши
                        setGameKeyState(4, 255) -- Нажатие
                        wait(10)
                        setGameKeyState(4, 0) -- Отпускание
                    end
                    
                    -- Ждем указанный интервал между кликами
                    wait(interval)
                end
            end)
        end,
        StartClickerWithTimer = function(self, minutes)
            local settings = self.storage:get("window.clickerSettings")
            settings.isClicking[0] = true
            settings.isActivated[0] = true
            settings.timerEndTime = os.time() + (minutes * 60)
            self.storage:save_to_file(self.ConfigName, true, 2)
        end,
        StopClicker = function(self)
            local settings = self.storage:get("window.clickerSettings")
            settings.isClicking[0] = false
            settings.timerEndTime = 0
            self.storage:save_to_file(self.ConfigName, true, 2)
        end
    }
})

return render
