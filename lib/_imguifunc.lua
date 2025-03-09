local imgui = require 'mimgui'
local MoonCore = require "ubplibs.MoonCore"

local encoding = require('encoding')
encoding.default = 'CP1251'
local u8 = encoding.UTF8

local imguiHandler = MoonCore.class("imguiHandler", {
    extends = MoonCore.BaseClass,
    private = {
        -- ˜˜˜˜˜˜˜ ˜˜˜ ˜˜˜˜˜˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜ ˜ ˜˜˜˜˜˜˜ ˜˜˜˜˜˜
        _formatTime = function(self, milliseconds)
            local seconds = math.floor(milliseconds / 1000)
            local ms = milliseconds % 1000
            
            if seconds < 1 then
                return string.format(u8"%d ìñ", ms)
            else
                return string.format(u8"%d.%03d ñåê", seconds, ms)
            end
        end
    },
    public = {
        init = function(self, dependencies)
            MoonCore.BaseClass.init(self, dependencies)
            
            -- ˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜ ˜˜ ˜˜˜˜˜˜˜˜˜˜˜
            self.dependencies = dependencies

            -- ˜˜˜˜˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜
            self.fonts = {
                title = nil,
                regular = nil
            }
            
            -- ˜˜˜˜˜ ˜˜˜ ˜˜˜˜˜˜˜˜˜˜
            self.colors = {
                accent = imgui.ImVec4(0.2, 0.7, 0.2, 1.0),
                background = imgui.ImVec4(0.13, 0.16, 0.2, 1.00),
                text = imgui.ImVec4(1.00, 1.00, 1.00, 0.85),
                textDim = imgui.ImVec4(0.70, 0.70, 0.70, 0.85)
            }

        end,
        toggleButton = function(self, label, value, size)
            -- ˜˜˜˜˜˜˜˜˜ ˜˜˜ value ˜ ˜˜˜˜˜˜˜ ImBool ˜˜˜˜ ˜˜˜˜˜
            if type(value) == "boolean" then
                value = imgui.new.bool(value)
            end
            
            local drawList = imgui.GetWindowDrawList()
            local pos = imgui.GetCursorScreenPos()
            local width = size and size.x or 50
            local height = size and size.y or 24
            local padding = 4  -- ˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜
            local rounding = height / 2
            
            -- ˜˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜
            local bgColor = value[0] and
                imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.2, 0.7, 0.2, 1.0)) or
                imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.15, 0.15, 0.15, 1.0))  -- ˜˜˜˜˜˜ ˜˜˜˜˜˜
                
            local circleColor = value[0] and
                imgui.ColorConvertFloat4ToU32(imgui.ImVec4(1, 1, 1, 1.0)) or
                imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.7, 0.7, 0.7, 1.0))  -- ˜˜˜˜˜˜˜ ˜˜˜˜˜˜
            
            -- ˜˜˜˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜ ˜ ˜˜˜˜˜˜˜
            local circleRadius = (height - padding * 2) / 2
            local circleOffset = padding + circleRadius  -- ˜˜˜˜˜˜ ˜˜˜ ˜˜˜˜˜˜
            
            -- ˜˜˜˜˜˜ ˜˜˜ ˜˜˜˜˜˜˜˜˜ (˜˜˜˜˜˜ ˜˜ ˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜)
            local isHovered = imgui.IsItemHovered()
            
            if isHovered then
                local hoverColor = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(1, 1, 1, 0.1))
                
                -- ˜˜˜˜˜˜ ˜˜˜ ˜˜˜ ˜˜˜˜˜˜˜˜˜ (˜˜˜˜˜˜˜˜˜˜˜˜˜ ˜ ˜˜˜˜˜˜)
                drawList:AddRectFilled(
                    imgui.ImVec2(pos.x + rounding, pos.y),
                    imgui.ImVec2(pos.x + width - rounding, pos.y + height),
                    hoverColor
                )
                
                -- ˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜˜˜˜ ˜˜˜˜ ˜˜˜ ˜˜˜˜˜˜˜˜˜
                drawList:AddCircleFilled(
                    imgui.ImVec2(pos.x + rounding, pos.y + height/2),
                    rounding,
                    hoverColor,
                    32
                )
                drawList:AddCircleFilled(
                    imgui.ImVec2(pos.x + width - rounding, pos.y + height/2),
                    rounding,
                    hoverColor,
                    32
                )
            end
            
            -- ˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜ ˜˜˜ (˜˜˜˜˜˜˜˜˜˜˜˜˜ ˜ ˜˜˜˜˜˜)
            drawList:AddRectFilled(
                imgui.ImVec2(pos.x + rounding, pos.y),
                imgui.ImVec2(pos.x + width - rounding, pos.y + height),
                bgColor
            )
            
            -- ˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜˜˜˜ ˜˜˜˜
            drawList:AddCircleFilled(
                imgui.ImVec2(pos.x + rounding, pos.y + height/2),
                rounding,
                bgColor,
                32
            )
            drawList:AddCircleFilled(
                imgui.ImVec2(pos.x + width - rounding, pos.y + height/2),
                rounding,
                bgColor,
                32
            )
            
            -- ˜˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜˜˜˜˜ ˜ ˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜
            local circlePos = value[0] and 
                imgui.ImVec2(pos.x + width - circleOffset, pos.y + height/2) or
                imgui.ImVec2(pos.x + circleOffset, pos.y + height/2)
            
            -- ˜˜˜˜˜˜ ˜˜˜˜ ˜˜˜ ˜˜˜˜˜˜˜
            drawList:AddCircleFilled(
                imgui.ImVec2(circlePos.x, circlePos.y + 1),
                circleRadius,
                imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0, 0, 0, 0.15)),
                32
            )
            
            -- ˜˜˜˜˜˜ ˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜˜˜˜˜
            drawList:AddCircleFilled(
                circlePos,
                circleRadius,
                circleColor,
                32
            )
            
            -- ˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜ ˜˜˜˜˜˜
            local totalWidth = width
            if label then
                local labelSize = imgui.CalcTextSize(label)
                totalWidth = width + labelSize.x + 20
                
                drawList:AddText(
                    imgui.ImVec2(pos.x + width + 10, pos.y + height/2 - labelSize.y/2),
                    imgui.ColorConvertFloat4ToU32(imgui.ImVec4(1, 1, 1, 0.8)),
                    label
                )
            end
            
            -- ˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜ (˜˜˜˜˜˜˜˜˜˜ ˜ ˜˜˜˜˜)
            local clicked = imgui.InvisibleButton(
                "##toggle" .. (label or ""), 
                imgui.ImVec2(totalWidth, height)
            )
            
            if clicked then
                value[0] = not value[0]
            end
            
            return clicked
        end,  
        renderClickerPanel = function(self, config)
            -- ˜˜˜˜˜˜˜˜˜, ˜˜˜ ˜˜˜˜˜˜ ˜˜˜˜˜˜˜
            if not config then return config end
            
            local changed = false
            local settings = config:get("window.clickerSettings")
            
            -- ˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜
            imgui.PushFont(self.fonts.title or imgui.GetFont())
            local titleText = u8"Íàñòðîéêè àâòîêëèêåðà"
            local titleSize = imgui.CalcTextSize(titleText)
            local windowWidth = imgui.GetWindowWidth()
            imgui.SetCursorPosX((windowWidth - titleSize.x) / 2)
            imgui.TextColored(self.colors.text, titleText)
            imgui.PopFont()
            
            imgui.Spacing()
            imgui.Spacing()
            
            -- ˜˜˜˜˜˜˜˜˜˜˜
            local drawList = imgui.GetWindowDrawList()
            local pos = imgui.GetCursorScreenPos()
            local lineStart = imgui.ImVec2(pos.x + 10, pos.y)
            local lineEnd = imgui.ImVec2(pos.x + windowWidth - 20, pos.y)
            drawList:AddLine(lineStart, lineEnd, imgui.ColorConvertFloat4ToU32(self.colors.textDim), 1.0)
            
            imgui.Spacing()
            imgui.Spacing()
            
            
            -- ˜˜˜˜˜˜˜˜˜ ˜˜˜ ˜˜˜˜˜˜˜˜˜ ˜˜ ˜˜˜˜˜˜˜˜˜˜˜˜˜
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.PushTextWrapPos(300)
                imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"˜˜˜˜˜˜˜˜ ˜˜˜ ˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜˜˜")
                imgui.TextColored(imgui.ImVec4(0.8, 0.8, 0.8, 1.0), u8"˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜, ˜˜˜˜˜˜ ˜˜ ˜˜˜˜˜ ˜˜˜˜˜˜˜˜ ˜˜˜˜ ˜˜˜ ˜˜˜˜˜˜˜ ˜˜˜˜˜˜ ˜˜˜˜˜˜˜")
                imgui.PopTextWrapPos()
                imgui.EndTooltip()
            end
            
            imgui.Spacing()
            imgui.Spacing()
            
            -- ˜˜˜˜˜˜˜˜ ˜˜˜ ˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜˜
            imgui.PushStyleColor(imgui.Col.FrameBg, self.colors.background)
            imgui.PushStyleColor(imgui.Col.SliderGrab, self.colors.accent)
            imgui.PushStyleColor(imgui.Col.SliderGrabActive, imgui.ImVec4(0.3, 0.8, 0.3, 1.0))
            
            -- ˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜˜ ˜˜˜ ˜˜˜˜˜˜˜˜˜
            local mainInterval = imgui.new.int(settings.clickMainInterval)
            local clickInterval = imgui.new.int(settings.clickInterval)
            
            -- ˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜
            imgui.SetCursorPosX(20)
            imgui.TextColored(self.colors.text, u8"Èíòåðâàë çàäåðæêè:")
            
            --     
            local timeUnits = {
                {name = u8"Ìèëëèñåêóíäû", multiplier = 1, max = 20000},
                {name = u8"Ñåêóíäû", multiplier = 1000, max = 300},
                {name = u8"Ìèíóòû", multiplier = 60000, max = 30}
            }
            
            --       
            local currentTimeUnit = imgui.new.int(settings.timeUnitIndex or 0) --   
            
            --        
            if settings.timeUnitIndex == nil then --      
                if settings.clickMainInterval >= 60000 then
                    currentTimeUnit[0] = 2 -- 
                elseif settings.clickMainInterval >= 1000 then
                    currentTimeUnit[0] = 1 -- 
                end
            end
            
            --     
            local convertedValue = imgui.new.int(math.floor(settings.clickMainInterval / timeUnits[currentTimeUnit[0] + 1].multiplier))
            
            --       
            imgui.SetCursorPosX(20)
            imgui.PushItemWidth(windowWidth - 150)
            
            local unitChanged = false
            if imgui.SliderInt("##MainInterval", convertedValue, 1, timeUnits[currentTimeUnit[0] + 1].max, "%d") then
                --   
                settings.clickMainInterval = convertedValue[0] * timeUnits[currentTimeUnit[0] + 1].multiplier
                changed = true
            end
            
            --       
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.PushTextWrapPos(300)
                imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"Íàñòðîéêà èíòåðâàëà ìåæäó ñåðèÿìè êëèêîâ")
                imgui.TextColored(imgui.ImVec4(0.8, 0.8, 0.8, 1.0), u8"×åì áîëüøå çíà÷åíèå, òåì ðåæå áóäóò ïðîèñõîäèòü ñåðèè êëèêîâ")
                imgui.TextColored(imgui.ImVec4(0.7, 0.9, 0.7, 1.0), string.format(u8"Òåêóùåå çíà÷åíèå: %d ìñ (%.2f ñåê, %.2f ìèí)", 
                    settings.clickMainInterval, 
                    settings.clickMainInterval / 1000, 
                    settings.clickMainInterval / 60000))
                imgui.PopTextWrapPos()
                imgui.EndTooltip()
            end
            
            imgui.SameLine()
            
            --  -
            imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.15, 0.18, 0.22, 1.0))
            imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.18, 0.22, 0.25, 1.0))
            imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.22, 0.26, 0.29, 1.0))
            imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.25, 0.30, 0.34, 1.0))
            imgui.PushStyleColor(imgui.Col.PopupBg, imgui.ImVec4(0.13, 0.16, 0.20, 0.95))
            imgui.PushStyleColor(imgui.Col.Header, imgui.ImVec4(0.2, 0.7, 0.2, 0.7))
            imgui.PushStyleColor(imgui.Col.HeaderHovered, imgui.ImVec4(0.2, 0.7, 0.2, 0.8))
            imgui.PushStyleColor(imgui.Col.HeaderActive, imgui.ImVec4(0.2, 0.7, 0.2, 1.0))
            
            imgui.PushItemWidth(100)
            
            -- ˜˜˜˜˜˜˜ ˜˜˜˜˜˜ ˜ ˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜ ˜˜˜ ˜˜˜˜˜-˜˜˜˜˜
            local unitLabels = u8"Ìèëëèñåêóíäû\0Ñåêóíäû\0Ìèíóòû\0"
            
            local prevUnit = currentTimeUnit[0]
            if imgui.ComboStr("##TimeUnit", currentTimeUnit, unitLabels) then
                --      
                local newMultiplier = timeUnits[currentTimeUnit[0] + 1].multiplier
                local oldMultiplier = timeUnits[prevUnit + 1].multiplier
                
                --    
                local currentValueMs = convertedValue[0] * oldMultiplier
                
                --     
                convertedValue[0] = math.floor(currentValueMs / newMultiplier)
                
                --   
                settings.clickMainInterval = convertedValue[0] * newMultiplier
                settings.timeUnitIndex = currentTimeUnit[0] --   
                
                unitChanged = true
                changed = true
            end
            
            imgui.PopItemWidth()
            imgui.PopStyleColor(8)
            
            -- ˜˜˜˜˜˜˜˜˜ ˜˜˜ ˜˜˜˜˜˜˜˜˜ ˜˜ ˜˜˜˜˜-˜˜˜˜ ˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.PushTextWrapPos(300)
                imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"Âûáåðèòå åäèíèöû èçìåðåíèÿ âðåìåíè")
                imgui.TextColored(imgui.ImVec4(0.8, 0.8, 0.8, 1.0), u8"Çíà÷åíèå áóäåò àâòîìàòè÷åñêè ïåðåñ÷èòàíî")
                imgui.PopTextWrapPos()
                imgui.EndTooltip()
            end
            
            imgui.PopItemWidth()
            
            imgui.Spacing()
            
            --   
            imgui.SetCursorPosX(20)
            imgui.TextColored(self.colors.text, u8"Èíòåðâàë ìåæäó êëèêàìè:")
            
            --         
            local clickIntervalUnits = {
                {name = u8"Ìèëëèñåêóíäû", multiplier = 1, max = 5000},
                {name = u8"Ñåêóíäû", multiplier = 1000, max = 10}
            }
            
            --       
            local currentClickIntervalUnit = imgui.new.int(settings.clickIntervalUnitIndex or 0) --   
            
            --        
            if settings.clickIntervalUnitIndex == nil then --      
                if settings.clickInterval >= 1000 then
                    currentClickIntervalUnit[0] = 1 -- 
                end
            end
            
            --     
            local convertedClickInterval = imgui.new.int(math.floor(settings.clickInterval / clickIntervalUnits[currentClickIntervalUnit[0] + 1].multiplier))
            
            -- ˜˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜ ˜ ˜˜˜˜˜ ˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜ ˜ ˜˜˜˜˜ ˜˜˜˜˜˜
            imgui.SetCursorPosX(20)
            imgui.PushItemWidth(windowWidth - 150)
            
            if imgui.SliderInt("##ClickInterval", convertedClickInterval, 1, clickIntervalUnits[currentClickIntervalUnit[0] + 1].max, "%d") then
                -- ˜˜˜˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜ ˜ ˜˜˜˜˜˜˜˜˜˜˜˜
                settings.clickInterval = convertedClickInterval[0] * clickIntervalUnits[currentClickIntervalUnit[0] + 1].multiplier
                changed = true
            end
            
            -- ˜˜˜˜˜˜˜˜˜ ˜˜˜ ˜˜˜˜˜˜˜˜˜ ˜˜ ˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜ ˜˜˜˜˜˜˜
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.PushTextWrapPos(300)
                imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"Íàñòðîéêà èíòåðâàëà ìåæäó ñåðèÿìè êëèêîâ")
                imgui.TextColored(imgui.ImVec4(0.8, 0.8, 0.8, 1.0), u8"×åì áîëüøå çíà÷åíèå, òåì ðåæå áóäóò ïðîèñõîäèòü ñåðèè êëèêîâ")
                imgui.TextColored(imgui.ImVec4(0.7, 0.9, 0.7, 1.0), string.format(u8"Òåêóùåå çíà÷åíèå: %d ìñ (%.2f ñåê, %.2f ìèí)", 
                    settings.clickInterval, 
                    settings.clickInterval / 1000, 
                    settings.clickInterval / 60000))
                imgui.PopTextWrapPos()
                imgui.EndTooltip()
            end
            
            imgui.SameLine()
            
            --  -
            imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.15, 0.18, 0.22, 1.0))
            imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.18, 0.22, 0.25, 1.0))
            imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.22, 0.26, 0.29, 1.0))
            imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.25, 0.30, 0.34, 1.0))
            imgui.PushStyleColor(imgui.Col.PopupBg, imgui.ImVec4(0.13, 0.16, 0.20, 0.95))
            imgui.PushStyleColor(imgui.Col.Header, imgui.ImVec4(0.2, 0.7, 0.2, 0.7))
            imgui.PushStyleColor(imgui.Col.HeaderHovered, imgui.ImVec4(0.2, 0.7, 0.2, 0.8))
            imgui.PushStyleColor(imgui.Col.HeaderActive, imgui.ImVec4(0.2, 0.7, 0.2, 1.0))
            
            imgui.PushItemWidth(100)
            
            -- ˜˜˜˜˜˜˜ ˜˜˜˜˜˜ ˜ ˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜ ˜˜˜ ˜˜˜˜˜-˜˜˜˜˜
            local clickUnitLabels = u8"Ìèëëèñåêóíäû\0Ñåêóíäû\0"
            
            local prevClickUnit = currentClickIntervalUnit[0]
            if imgui.ComboStr("##ClickIntervalUnit", currentClickIntervalUnit, clickUnitLabels) then
                --      
                local newMultiplier = clickIntervalUnits[currentClickIntervalUnit[0] + 1].multiplier
                local oldMultiplier = clickIntervalUnits[prevClickUnit + 1].multiplier
                
                --    
                local currentValueMs = convertedClickInterval[0] * oldMultiplier
                
                --     
                convertedClickInterval[0] = math.floor(currentValueMs / newMultiplier)
                
                --   
                settings.clickInterval = convertedClickInterval[0] * newMultiplier
                settings.clickIntervalUnitIndex = currentClickIntervalUnit[0] --   
                
                changed = true
            end
            
            imgui.PopItemWidth()
            imgui.PopStyleColor(8)
            
            --     -  
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.PushTextWrapPos(300)
                imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"Âûáåðèòå åäèíèöû èçìåðåíèÿ âðåìåíè")
                imgui.TextColored(imgui.ImVec4(0.8, 0.8, 0.8, 1.0), u8"Çíà÷åíèå áóäåò àâòîìàòè÷åñêè ïåðåñ÷èòàíî")
                imgui.PopTextWrapPos()
                imgui.EndTooltip()
            end
            
            imgui.PopItemWidth()
            
            imgui.Spacing()
            
            --   
            imgui.SetCursorPosX(20)
            imgui.TextColored(self.colors.text, u8"Êíîïêà äëÿ êëèêà:")
            imgui.SetCursorPosX(20)
            imgui.PushItemWidth(windowWidth - 40)
            
            --     
            local clickCount = imgui.new.int(settings.clickCount)
            if imgui.SliderInt("##ClickCount", clickCount, 1, 20, "%d") then
                settings.clickCount = clickCount[0]
                changed = true
            end
            
            --       
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.PushTextWrapPos(300)
                imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8" ,    ")
                imgui.TextColored(imgui.ImVec4(0.8, 0.8, 0.8, 1.0), u8"        ")
                imgui.TextColored(imgui.ImVec4(0.7, 0.9, 0.7, 1.0), string.format(u8" : %d ", settings.clickCount))
                imgui.PopTextWrapPos()
                imgui.EndTooltip()
            end
            
            imgui.PopItemWidth()
            
            imgui.Spacing()
            
            --    
            imgui.SetCursorPosX(20)
            imgui.TextColored(self.colors.text, u8"Âûáîð êíîïêè äëÿ êëèêà:")
            
            local buttonNames = u8"Ëåâàÿ êíîïêà ìûøè\0Ïðàâàÿ êíîïêà ìûøè\0Ñðåäíÿÿ êíîïêà ìûøè\0"
            
            local currentButton = imgui.new.int(settings.clickButton)
            imgui.SetCursorPosX(20)
            imgui.PushItemWidth(windowWidth - 40)
            if imgui.ComboStr("##ClickButton", currentButton, buttonNames) then
                settings.clickButton = currentButton[0]
                changed = true
            end
            imgui.PopItemWidth()
            
            imgui.PopStyleColor(3)
            
            imgui.Spacing()
            imgui.Spacing()
            
            -- 
            pos = imgui.GetCursorScreenPos()
            lineStart = imgui.ImVec2(pos.x + 10, pos.y)
            lineEnd = imgui.ImVec2(pos.x + windowWidth - 20, pos.y)
            drawList:AddLine(lineStart, lineEnd, imgui.ColorConvertFloat4ToU32(self.colors.textDim), 1.0)
            
            imgui.Spacing()
            imgui.Spacing()
            
            -- -   
            imgui.SetCursorPosX(20)
            
            --  
            local quickStartText = u8"? Áûñòðûé çàïóñê ñ òàéìåðîì:"
            local quickStartTextSize = imgui.CalcTextSize(quickStartText)
            imgui.TextColored(imgui.ImVec4(0.9, 0.7, 0.3, 1.0), quickStartText)
            
            --     
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.PushTextWrapPos(300)
                imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"Áûñòðûé çàïóñê ñ ïðåäóñòàíîâëåííûì âðåìåíåì àâòîîñòàíîâêè")
                imgui.PopTextWrapPos()
                imgui.EndTooltip()
            end
            
            imgui.Spacing()
            
            -- ˜˜˜˜˜˜˜˜˜ ˜˜˜ ˜˜˜˜˜˜
            local buttonPanelWidth = windowWidth - 40
            imgui.SetCursorPosX(20)
            imgui.BeginChild("##QuickButtonsPanel", imgui.ImVec2(buttonPanelWidth, 60), true)
                
                -- ˜˜˜˜˜ ˜˜˜ ˜˜˜˜-˜˜˜˜˜˜
                imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0.08, 0.08, 0.08, 1.0))
                
                -- ˜˜˜˜˜˜˜˜ ˜˜˜ ˜˜˜˜˜˜ (˜˜˜˜˜˜˜˜˜)
                local pulseSpeed = 1.5 -- ˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜
                local pulseAmount = 0.05 -- ˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜ (5%)
                local pulseFactor = math.sin(os.clock() * pulseSpeed) * pulseAmount + 1.0 -- ˜˜˜˜˜˜˜˜ ˜˜ 0.95 ˜˜ 1.05
                
                -- ˜˜˜˜˜˜ "˜˜˜˜˜˜˜˜˜ ˜˜ 5 ˜˜˜˜˜"
                local smallButtonWidth = (buttonPanelWidth - 30) / 2
                imgui.SetCursorPos(imgui.ImVec2(10, 15))
                
                -- ˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜ ˜˜˜ ˜˜˜˜˜˜ ˜˜˜˜˜˜
                local isHovered1 = imgui.IsMouseHoveringRect(
                    imgui.GetCursorScreenPos(),
                    imgui.ImVec2(
                        imgui.GetCursorScreenPos().x + smallButtonWidth,
                        imgui.GetCursorScreenPos().y + 30
                    )
                )
                
                -- ˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜ ˜˜˜˜˜˜ ˜˜˜ ˜˜˜˜˜˜˜˜˜
                local buttonSize1 = imgui.ImVec2(
                    smallButtonWidth * (isHovered1 and pulseFactor or 1.0),
                    30 * (isHovered1 and pulseFactor or 1.0)
                )
                
                imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.2, 0.5, 0.7, 1.0))
                imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.3, 0.6, 0.8, 1.0))
                imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.4, 0.7, 0.9, 1.0))
                
                if imgui.Button(u8"Çàïóñòèòü íà 5 ìèíóò", buttonSize1) then
                    settings.isClicking[0] = true
                    settings.isActivated[0] = true
                    if self.dependencies and self.dependencies.render then
                        self.dependencies.render:StartClickerWithTimer(5)
                    end
                    changed = true
                end
                
                --     
                if imgui.IsItemHovered() then
                    imgui.BeginTooltip()
                    imgui.PushTextWrapPos(300)
                    imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"Çàïóñòèòü êëèêåð íà 5 ìèíóò")
                    imgui.PopTextWrapPos()
                    imgui.EndTooltip()
                end
                
                imgui.PopStyleColor(3)
                
                --  "  10 "
                imgui.SameLine()
                imgui.SetCursorPosX(smallButtonWidth + 20)
                
                -- ˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜ ˜˜˜ ˜˜˜˜˜˜ ˜˜˜˜˜˜
                local isHovered2 = imgui.IsMouseHoveringRect(
                    imgui.ImVec2(imgui.GetCursorScreenPos().x, imgui.GetCursorScreenPos().y),
                    imgui.ImVec2(
                        imgui.GetCursorScreenPos().x + smallButtonWidth,
                        imgui.GetCursorScreenPos().y + 30
                    )
                )
                
                -- ˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜ ˜˜˜˜˜˜ ˜˜˜ ˜˜˜˜˜˜˜˜˜
                local buttonSize2 = imgui.ImVec2(
                    smallButtonWidth * (isHovered2 and pulseFactor or 1.0),
                    30 * (isHovered2 and pulseFactor or 1.0)
                )
                
                imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.7, 0.5, 0.2, 1.0))
                imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.8, 0.6, 0.3, 1.0))
                imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.9, 0.7, 0.4, 1.0))
                
                if imgui.Button(u8"Çàïóñòèòü íà 10 ìèíóò", buttonSize2) then
                    settings.isClicking[0] = true
                    settings.isActivated[0] = true
                    if self.dependencies and self.dependencies.render then
                        self.dependencies.render:StartClickerWithTimer(10)
                    end
                    changed = true
                end
                
                --     
                if imgui.IsItemHovered() then
                    imgui.BeginTooltip()
                    imgui.PushTextWrapPos(300)
                    imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"Çàïóñòèòü êëèêåð íà 10 ìèíóò")
                    imgui.PopTextWrapPos()
                    imgui.EndTooltip()
                end
                
                imgui.PopStyleColor(3)
                imgui.PopStyleColor() -- ChildBg
            
            imgui.EndChild()
            
            imgui.Spacing()
            imgui.Spacing()
            
            -- ˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜
            imgui.SetCursorPosX(20)
            
            -- ˜˜˜˜˜˜˜˜˜ ˜ ˜˜˜˜˜˜˜
            local statusText = u8"Ñòàòóñ êëèêåðà:"
            local statusTextSize = imgui.CalcTextSize(statusText)
            imgui.TextColored(imgui.ImVec4(0.3, 0.7, 0.9, 1.0), statusText)
            
            -- ˜˜˜˜˜˜˜˜˜ ˜˜˜ ˜˜˜˜˜˜˜˜˜ ˜˜ ˜˜˜˜˜˜˜˜˜
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.PushTextWrapPos(300)
                imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"Òåêóùåå ñîñòîÿíèå êëèêåðà")
                imgui.PopTextWrapPos()
                imgui.EndTooltip()
            end
            
            imgui.Spacing()
            
            --   
            local indicatorPanelWidth = windowWidth - 40
            imgui.SetCursorPosX(20)
            imgui.BeginChild("##StatusIndicatorPanel", imgui.ImVec2(indicatorPanelWidth, 120), true)
                
                -- ˜˜˜˜˜ ˜˜˜ ˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜˜
                imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0.08, 0.08, 0.08, 1.0))
                
                -- ˜˜˜˜˜˜ ˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜
                local centerX = 40
                local centerY = 40
                local radius = 25
                
                -- ˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜ ˜˜˜ ˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜˜
                local pulseRadius = radius
                if settings.isClicking[0] then
                    -- ˜˜˜˜˜˜˜ ˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜ ˜˜ ˜˜˜˜˜˜ ˜˜˜˜˜˜˜
                    local pulseSpeed = 2.0 -- ˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜
                    local pulseAmount = 3.0 -- ˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜
                    local pulseFactor = math.sin(os.clock() * pulseSpeed) * 0.5 + 0.5 -- ˜˜˜˜˜˜˜˜ ˜˜ 0 ˜˜ 1
                    pulseRadius = radius + pulseFactor * pulseAmount
                end
                
                imgui.SetCursorPos(imgui.ImVec2(centerX - radius, centerY - radius))
                
                local indicatorPos = imgui.GetCursorScreenPos()
                local indicatorCenter = imgui.ImVec2(indicatorPos.x + radius, indicatorPos.y + radius)
                
                -- ˜˜˜˜˜˜˜ ˜˜˜˜ (˜˜˜˜˜)
                drawList:AddCircleFilled(
                    indicatorCenter,
                    radius,
                    imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.2, 0.2, 0.2, 1.0)),
                    32
                )
                
                -- ˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜ ˜˜˜ ˜˜˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜ ˜˜ ˜˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜
                if settings.isClicking[0] then
                    -- ˜˜˜˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜ (˜˜ 0 ˜˜ 1)
                    local progress = 1.0 - (settings.currentTime / settings.clickMainInterval)
                    
                    -- ˜˜˜˜˜˜ ˜˜˜˜ ˜˜˜˜˜˜˜˜˜
                    local segments = 32 -- ˜˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜ ˜˜˜ ˜˜˜˜˜˜˜ ˜˜˜˜
                    local arcRadius = radius + 2 -- ˜˜˜˜˜˜ ˜˜˜˜ (˜˜˜˜˜˜˜ ˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜)
                    local startAngle = -math.pi / 2 -- ˜˜˜˜˜˜˜˜ ˜ ˜˜˜˜˜˜˜ ˜˜˜˜˜ (-90 ˜˜˜˜˜˜˜˜)
                    local endAngle = startAngle + math.pi * 2 * progress -- ˜˜˜˜, ˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜
                    
                    -- ˜˜˜˜ ˜˜˜˜˜˜˜˜˜ (˜˜ ˜˜˜˜˜˜˜ ˜ ˜˜˜˜˜˜˜˜)
                    local progressColor = imgui.ImVec4(
                        0.2 + (1.0 - progress) * 0.8, -- R: ˜˜ 1.0 ˜˜ 0.2
                        0.7 + progress * 0.2, -- G: ˜˜ 0.7 ˜˜ 0.9
                        0.2, -- B: ˜˜˜˜˜˜˜˜˜˜
                        1.0  -- A: ˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜˜˜˜˜˜
                    )
                    
                    -- ˜˜˜˜˜˜ ˜˜˜˜ ˜˜˜˜˜˜˜˜˜
                    local arcThickness = 3.0 -- ˜˜˜˜˜˜˜ ˜˜˜˜
                    drawList:PathClear()
                    
                    -- ˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜ ˜˜˜ ˜˜˜˜˜˜˜˜ ˜˜˜˜
                    for i = 0, segments do
                        local angle = startAngle + (endAngle - startAngle) * (i / segments)
                        local x = indicatorCenter.x + math.cos(angle) * arcRadius
                        local y = indicatorCenter.y + math.sin(angle) * arcRadius
                        drawList:PathLineTo(imgui.ImVec2(x, y))
                    end
                    
                    -- ˜˜˜˜˜˜ ˜˜˜˜
                    drawList:PathStroke(
                        imgui.ColorConvertFloat4ToU32(progressColor),
                        false, -- ˜˜ ˜˜˜˜˜˜˜˜ ˜˜˜˜
                        arcThickness
                    )
                end
                
                -- ˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜ ˜˜˜ ˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜˜
                if settings.isClicking[0] then
                    -- ˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜ (˜˜˜˜˜˜˜˜)
                    local glowColor = imgui.ImVec4(0.2, 0.8, 0.2, 0.2) -- ˜˜˜˜˜˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜
                    drawList:AddCircleFilled(
                        indicatorCenter,
                        pulseRadius + 5,
                        imgui.ColorConvertFloat4ToU32(glowColor),
                        32
                    )
                end
                
                -- ˜˜˜˜˜˜˜˜ ˜˜˜˜ (˜˜˜˜˜˜˜ ˜˜˜ ˜˜˜˜˜˜˜)
                local activeColor = settings.isClicking[0] and 
                    imgui.ImVec4(0.2, 0.8, 0.2, 1.0) or 
                    imgui.ImVec4(0.8, 0.2, 0.2, 1.0)
                
                drawList:AddCircleFilled(
                    indicatorCenter,
                    settings.isClicking[0] and pulseRadius - 3 or radius - 3, -- ˜˜˜˜˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜ ˜˜˜ ˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜
                    imgui.ColorConvertFloat4ToU32(activeColor),
                    32
                )
                
                -- ˜˜˜˜˜˜˜˜˜˜ ˜˜˜˜ (˜˜˜˜˜˜˜)
                local innerColor = settings.isClicking[0] and 
                    imgui.ImVec4(0.3, 0.9, 0.3, 1.0) or 
                    imgui.ImVec4(0.9, 0.3, 0.3, 1.0)
                
                drawList:AddCircleFilled(
                    indicatorCenter,
                    settings.isClicking[0] and pulseRadius / 2 or radius / 2, -- ˜˜˜˜˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜ ˜˜˜ ˜˜˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜
                    imgui.ColorConvertFloat4ToU32(innerColor),
                    32
                )
                
                -- ˜˜˜˜˜ ˜˜˜˜˜˜˜ ˜˜˜˜˜˜ ˜˜ ˜˜˜˜˜˜˜˜˜˜
                local statusIndicatorText = settings.isClicking[0] and 
                    u8"Êëèêåð àêòèâåí" or 
                    u8"Êëèêåð îñòàíîâëåí"
                
                imgui.SetCursorPos(imgui.ImVec2(centerX + radius + 20, centerY - 20))
                imgui.TextColored(
                    settings.isClicking[0] and imgui.ImVec4(0.2, 0.8, 0.2, 1.0) or imgui.ImVec4(0.8, 0.2, 0.2, 1.0),
                    statusIndicatorText
                )
                
                -- ˜˜˜˜˜ ˜˜ ˜˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜
                local timeText
                if settings.isClicking[0] then
                    timeText = string.format(u8"Äî ñëåäóþùåãî êëèêà: %s", self:_formatTime(settings.currentTime))
                    
                    if settings.timerEndTime and settings.timerEndTime > 0 then
                        local remainingSeconds = math.max(0, settings.timerEndTime - os.time())
                        local minutes = math.floor(remainingSeconds / 60)
                        local seconds = remainingSeconds % 60
                        
                        imgui.SetCursorPos(imgui.ImVec2(centerX + radius + 20, centerY + 25))
                        
                        local timerColor
                        if remainingSeconds < 30 then
                            timerColor = imgui.ImVec4(0.9, 0.3, 0.3, 1.0)
                        elseif remainingSeconds < 60 then
                            timerColor = imgui.ImVec4(0.9, 0.5, 0.2, 1.0)
                        else
                            timerColor = imgui.ImVec4(0.9, 0.7, 0.3, 1.0)
                        end
                        
                        imgui.TextColored(
                            timerColor,
                            string.format(u8"Îñòàëîñü âðåìÿ: %02d:%02d", minutes, seconds)
                        )
                        
                        imgui.SetCursorPos(imgui.ImVec2(centerX + radius + 20, centerY + 45))
                        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.7, 0.3, 0.3, 0.8))
                        imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.8, 0.4, 0.4, 0.9))
                        imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.9, 0.5, 0.5, 1.0))
                        
                        if imgui.Button(u8"Îòìåíèòü òàéìåð", imgui.ImVec2(150, 20)) then
                            settings.timerEndTime = 0
                            changed = true
                            
                            if self.dependencies and self.dependencies.render then
                                self.dependencies.render.storage:save_to_file(self.dependencies.render.ConfigName, true, 2)
                            end
                        end
                        
                        if imgui.IsItemHovered() then
                            imgui.BeginTooltip()
                            imgui.PushTextWrapPos(300)
                            imgui.TextColored(imgui.ImVec4(1, 0.5, 0.5, 1.0), u8"Îòìåíèòü àâòîìàòè÷åñêóþ îñòàíîâêó")
                            imgui.TextColored(imgui.ImVec4(0.8, 0.8, 0.8, 1.0), u8"Êëèêåð ïðîäîëæèò ðàáîòàòü áåç îãðàíè÷åíèÿ ïî âðåìåíè")
                            imgui.PopTextWrapPos()
                            imgui.EndTooltip()
                        end
                        
                        imgui.PopStyleColor(3)
                    end
                else
                    timeText = u8"Îæèäàíèå çàïóñêà..."
                end
                
                imgui.SetCursorPos(imgui.ImVec2(centerX + radius + 20, centerY + 5))
                imgui.TextColored(self.colors.textDim, timeText)
                
                imgui.PopStyleColor() -- ChildBg
            
            imgui.EndChild()
            
            imgui.Spacing()
            imgui.Spacing()
            
            -- ˜˜˜˜˜˜˜˜˜˜˜
            pos = imgui.GetCursorScreenPos()
            lineStart = imgui.ImVec2(pos.x + 10, pos.y)
            lineEnd = imgui.ImVec2(pos.x + windowWidth - 20, pos.y)
            drawList:AddLine(lineStart, lineEnd, imgui.ColorConvertFloat4ToU32(self.colors.textDim), 1.0)
            
            imgui.Spacing()
            imgui.Spacing()
            
            -- ˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜/˜˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜
            local buttonWidth = windowWidth - 40
            imgui.SetCursorPosX(20)
            
            local buttonColor = settings.isClicking[0] and 
                imgui.ImVec4(0.8, 0.2, 0.2, 1.0) or 
                self.colors.accent
            
            local buttonText = settings.isClicking[0] and u8"Îñòàíîâèòü êëèêåð" or u8"Çàïóñòèòü êëèêåð"
            
            --    
            local mainButtonPulseSpeed = 2.0 --  
            local mainButtonPulseAmount = 0.03 --   (3%)
            local mainButtonPulseFactor = math.sin(os.clock() * mainButtonPulseSpeed) * mainButtonPulseAmount + 1.0
            
            --     
            local isMainButtonHovered = imgui.IsMouseHoveringRect(
                imgui.ImVec2(imgui.GetCursorScreenPos().x, imgui.GetCursorScreenPos().y),
                imgui.ImVec2(
                    imgui.GetCursorScreenPos().x + buttonWidth,
                    imgui.GetCursorScreenPos().y + 40
                )
            )
            
            -- ˜˜˜˜˜˜ ˜˜˜˜˜˜ ˜ ˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜
            local mainButtonSize = imgui.ImVec2(
                buttonWidth * (isMainButtonHovered and mainButtonPulseFactor or 1.0),
                40 * (isMainButtonHovered and mainButtonPulseFactor or 1.0)
            )
            
            -- ˜˜˜˜˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜ ˜ ˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜
            local buttonPosX = 20
            if isMainButtonHovered then
                buttonPosX = 20 - (mainButtonSize.x - buttonWidth) / 2
            end
            imgui.SetCursorPosX(buttonPosX)
            
            imgui.PushStyleColor(imgui.Col.Button, buttonColor)
            imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(
                settings.isClicking[0] and 0.9 or 0.3,
                settings.isClicking[0] and 0.3 or 0.8,
                settings.isClicking[0] and 0.3 or 0.3,
                1.0
            ))
            imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(
                settings.isClicking[0] and 1.0 or 0.4,
                settings.isClicking[0] and 0.4 or 0.9,
                settings.isClicking[0] and 0.4 or 0.4,
                1.0
            ))
            
            if imgui.Button(buttonText, mainButtonSize) then
                if settings.isClicking[0] then
                    -- ˜˜˜˜˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜
                    if self.dependencies and self.dependencies.render then
                        self.dependencies.render:StopClicker()
                    else
                        settings.isClicking[0] = false
                    end
                else
                    -- ˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜
                    settings.isClicking[0] = true
                end
                changed = true
            end
            
            -- ˜˜˜˜˜˜˜˜˜ ˜˜˜ ˜˜˜˜˜˜˜˜˜ ˜˜ ˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.PushTextWrapPos(300)
                if settings.isClicking[0] then
                    imgui.TextColored(imgui.ImVec4(1, 0.5, 0.5, 1.0), u8"Îñòàíîâèòü ðàáîòó êëèêåðà")
                    imgui.TextColored(imgui.ImVec4(0.8, 0.8, 0.8, 1.0), u8"Ïðåêðàòèòü àâòîìàòè÷åñêèå êëèêè è îñòàíîâèòü ðàáîòó ïðîãðàììû")
                else
                    imgui.TextColored(imgui.ImVec4(0.5, 1, 0.5, 1.0), u8"Çàïóñòèòü ðàáîòó êëèêåðà")
                    imgui.TextColored(imgui.ImVec4(0.8, 0.8, 0.8, 1.0), u8"Íà÷íóòñÿ àâòîìàòè÷åñêèå êëèêè ñ çàäàííûìè ïàðàìåòðàìè")
                end
                imgui.PopTextWrapPos()
                imgui.EndTooltip()
            end
            
            imgui.PopStyleColor(3)
            
            --  ,   
            return changed and config or nil
        end,      
        setupTheme = function(self)
            imgui.SwitchContext()
            --==[ STYLE ]==--
            imgui.GetStyle().WindowPadding = imgui.ImVec2(0, 0)
            imgui.GetStyle().FramePadding = imgui.ImVec2(5, 5)
            imgui.GetStyle().ItemSpacing = imgui.ImVec2(5, 5)
            imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(2, 2)
            imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)
            imgui.GetStyle().IndentSpacing = 5  
            imgui.GetStyle().ScrollbarSize = 2.5
            imgui.GetStyle().GrabMinSize = 15
        
            --==[ BORDER ]==--
            imgui.GetStyle().WindowBorderSize = 0
            imgui.GetStyle().ChildBorderSize = 0
            imgui.GetStyle().PopupBorderSize = 0
            imgui.GetStyle().FrameBorderSize = 0
            imgui.GetStyle().TabBorderSize = 0
        
            --==[ ROUNDING ]==--
            imgui.GetStyle().WindowRounding = 12
            imgui.GetStyle().ChildRounding = 10
            imgui.GetStyle().FrameRounding = 7
            imgui.GetStyle().PopupRounding = 5
            imgui.GetStyle().ScrollbarRounding = 5
            imgui.GetStyle().GrabRounding = 5
            imgui.GetStyle().TabRounding = 5
        
            --==[ ALIGN ]==--
            imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
            imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
            imgui.GetStyle().SelectableTextAlign = imgui.ImVec2(0.5, 0.5)
            
            --==[ COLORS ]==--
            imgui.GetStyle().Colors[imgui.Col.Text]                   = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
            imgui.GetStyle().Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.03, 0.03, 0.03, 1)
            imgui.GetStyle().Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.1, 0.13, 0.17, 0)
            imgui.GetStyle().Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Border]                 = imgui.ImVec4(0.25, 0.25, 0.26, 0.54)
            imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
            imgui.GetStyle().Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.13, 0.16, 0.2, 1.00)
            imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.13, 0.16, 0.2, 1.00)
            imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.13, 0.16, 0.2, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.HeaderHovered]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.HeaderActive]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Header]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00) 
            imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]              = imgui.ImVec4(0.12, 0.12, 0.12, 0) 
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]              = imgui.ImVec4(0.12, 0.12, 0.12, 0) 
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]              = imgui.ImVec4(0.12, 0.12, 0.12, 0) 
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]              = imgui.ImVec4(0.12, 0.12, 0.12, 0)
        end,
    }
})


return imguiHandler

