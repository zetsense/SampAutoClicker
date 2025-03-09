local MoonCore = require "ubplibs.MoonCore" 

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
                    self.dependencies.render:render()
                    wait(0)
                end
            end)
        end
    }
})

return main
