local MoonCore = require "ubplibs.MoonCore" 
local _main = require "SampAutoClicker.lib._main" 
local _imguifunc = require "SampAutoClicker.lib._imguifunc"  
local _gui = _imguifunc:new()
local _render = require "SampAutoClicker.lib._render" 
local _render = _render:new({render = {path = getWorkingDirectory() .. "/SampAutoClicker/storage/"}, imguifunc = _gui})
local _main = _main:new({render = _render})

local BotHandler = MoonCore.class("BotHandler", {
    extends = MoonCore.BaseClass,
    public = {
        init = function(self, dependencies)
            MoonCore.BaseClass.init(self, dependencies)
            if self._dependencies.main then
                self._dependencies.main:initialize()
            end
        end 
    }
})

local botHandler = BotHandler:new({main = _main})

return botHandler

