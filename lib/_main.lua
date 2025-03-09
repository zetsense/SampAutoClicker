local MoonCore = require "ubplibs.MoonCore" 
local vk = require('vkeys')
local main = MoonCore.class("main", {
    extends = MoonCore.BaseClass,
    public = {
        init = function(self, dependencies)
            MoonCore.BaseClass.init(self, dependencies)
            self.isRunning = true
            self.dependencies = dependencies
        end, 
        initialize = function(self)
            lua_thread.create(function()
                while self.isRunning do
                    while not isSampAvailable() or not sampIsLocalPlayerSpawned() do wait(0) end
                    if isKeyJustPressed(vk.VK_END) then
                        self.dependencies.render:OpenMenu()
                    end
                    wait(0)
                end
            end)
        end
    }
})

return main
