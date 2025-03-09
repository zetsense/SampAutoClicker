local imgui = require 'mimgui'
local json = require "jbp"
local MoonCore = require "ubplibs.MoonCore"
local faicons = require('fAwesome6')
local encoding = require('encoding')
local vk = require('vkeys')
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
                        clickMainInterval = 100,
                        clickInterval = 20,
                        clickButton = 0,
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
    }
})

return render
