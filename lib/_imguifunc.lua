local imgui = require 'mimgui'
local MoonCore = require "ubplibs.MoonCore"

local encoding = require('encoding')
encoding.default = 'CP1251'
local u8 = encoding.UTF8

local imguiHandler = MoonCore.class("imguiHandler", {
    extends = MoonCore.BaseClass,
    private = {
        -- Функция для форматирования времени в удобный формат
        _formatTime = function(self, milliseconds)
            local seconds = math.floor(milliseconds / 1000)
            local ms = milliseconds % 1000
            
            if seconds < 1 then
                return string.format("%d мс", ms)
            else
                return string.format("%d.%03d сек", seconds, ms)
            end
        end
    },
    public = {
        init = function(self, dependencies)
            MoonCore.BaseClass.init(self, dependencies)
            
            -- Сохраняем ссылку на зависимости
            self.dependencies = dependencies

            -- Инициализация необходимых ресурсов
            self.fonts = {
                title = nil,
                regular = nil
            }
            
            -- Цвета для интерфейса
            self.colors = {
                accent = imgui.ImVec4(0.2, 0.7, 0.2, 1.0),
                background = imgui.ImVec4(0.13, 0.16, 0.2, 1.00),
                text = imgui.ImVec4(1.00, 1.00, 1.00, 0.85),
                textDim = imgui.ImVec4(0.70, 0.70, 0.70, 0.85)
            }

        end,
        toggleButton = function(self, label, value, size)
            -- Проверяем тип value и создаем ImBool если нужно
            if type(value) == "boolean" then
                value = imgui.new.bool(value)
            end
            
            local drawList = imgui.GetWindowDrawList()
            local pos = imgui.GetCursorScreenPos()
            local width = size and size.x or 50
            local height = size and size.y or 24
            local padding = 4  -- Увеличил отступ
            local rounding = height / 2
            
            -- Определяем цвета
            local bgColor = value[0] and
                imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.2, 0.7, 0.2, 1.0)) or
                imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.15, 0.15, 0.15, 1.0))  -- Сделал темнее
                
            local circleColor = value[0] and
                imgui.ColorConvertFloat4ToU32(imgui.ImVec4(1, 1, 1, 1.0)) or
                imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.7, 0.7, 0.7, 1.0))  -- Немного темнее
            
            -- Рассчитываем размеры и позиции
            local circleRadius = (height - padding * 2) / 2
            local circleOffset = padding + circleRadius  -- Отступ для кружка
            
            -- Эффект при наведении (рисуем ДО основных элементов)
            local isHovered = imgui.IsItemHovered()
            
            if isHovered then
                local hoverColor = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(1, 1, 1, 0.1))
                
                -- Рисуем фон при наведении (прямоугольник в центре)
                drawList:AddRectFilled(
                    imgui.ImVec2(pos.x + rounding, pos.y),
                    imgui.ImVec2(pos.x + width - rounding, pos.y + height),
                    hoverColor
                )
                
                -- Рисуем закругленные края при наведении
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
            
            -- Рисуем основной фон (прямоугольник в центре)
            drawList:AddRectFilled(
                imgui.ImVec2(pos.x + rounding, pos.y),
                imgui.ImVec2(pos.x + width - rounding, pos.y + height),
                bgColor
            )
            
            -- Рисуем закругленные края
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
            
            -- Определяем позицию переключателя с учетом отступов
            local circlePos = value[0] and 
                imgui.ImVec2(pos.x + width - circleOffset, pos.y + height/2) or
                imgui.ImVec2(pos.x + circleOffset, pos.y + height/2)
            
            -- Рисуем тень под кружком
            drawList:AddCircleFilled(
                imgui.ImVec2(circlePos.x, circlePos.y + 1),
                circleRadius,
                imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0, 0, 0, 0.15)),
                32
            )
            
            -- Рисуем кружок переключателя
            drawList:AddCircleFilled(
                circlePos,
                circleRadius,
                circleColor,
                32
            )
            
            -- Вычисляем размер текста
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
            
            -- Обработка клика (перемещено в конец)
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
            -- Проверяем, что конфиг передан
            if not config then return config end
            
            local changed = false
            local settings = config:get("window.clickerSettings")
            
            -- Заголовок панели
            imgui.PushFont(self.fonts.title or imgui.GetFont())
            local titleText = u8"Настройки автокликера"
            local titleSize = imgui.CalcTextSize(titleText)
            local windowWidth = imgui.GetWindowWidth()
            imgui.SetCursorPosX((windowWidth - titleSize.x) / 2)
            imgui.TextColored(self.colors.text, titleText)
            imgui.PopFont()
            
            imgui.Spacing()
            imgui.Spacing()
            
            -- Разделитель
            local drawList = imgui.GetWindowDrawList()
            local pos = imgui.GetCursorScreenPos()
            local lineStart = imgui.ImVec2(pos.x + 10, pos.y)
            local lineEnd = imgui.ImVec2(pos.x + windowWidth - 20, pos.y)
            drawList:AddLine(lineStart, lineEnd, imgui.ColorConvertFloat4ToU32(self.colors.textDim), 1.0)
            
            imgui.Spacing()
            imgui.Spacing()
            
            
            -- Подсказка при наведении на переключатель
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.PushTextWrapPos(300)
                imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"Включает или отключает функцию автокликера")
                imgui.TextColored(imgui.ImVec4(0.8, 0.8, 0.8, 1.0), u8"Когда отключено, кликер не будет работать даже при нажатии кнопки запуска")
                imgui.PopTextWrapPos()
                imgui.EndTooltip()
            end
            
            imgui.Spacing()
            imgui.Spacing()
            
            -- Слайдеры для настройки интервалов
            imgui.PushStyleColor(imgui.Col.FrameBg, self.colors.background)
            imgui.PushStyleColor(imgui.Col.SliderGrab, self.colors.accent)
            imgui.PushStyleColor(imgui.Col.SliderGrabActive, imgui.ImVec4(0.3, 0.8, 0.3, 1.0))
            
            -- Создаем временные переменные для слайдеров
            local mainInterval = imgui.new.int(settings.clickMainInterval)
            local clickInterval = imgui.new.int(settings.clickInterval)
            
            -- Основной интервал
            imgui.SetCursorPosX(20)
            imgui.TextColored(self.colors.text, u8"Основной интервал:")
            
            -- Добавляем выбор единицы измерения времени
            local timeUnits = {
                {name = u8"Миллисекунды", multiplier = 1, max = 20000},
                {name = u8"Секунды", multiplier = 1000, max = 300},
                {name = u8"Минуты", multiplier = 60000, max = 30}
            }
            
            -- Создаем временную переменную для выбора единицы измерения
            local currentTimeUnit = imgui.new.int(settings.timeUnitIndex or 0) -- Используем сохраненное значение
            
            -- Определяем текущую единицу измерения на основе значения интервала
            if settings.timeUnitIndex == nil then -- Если значение еще не было сохранено
                if settings.clickMainInterval >= 60000 then
                    currentTimeUnit[0] = 2 -- Минуты
                elseif settings.clickMainInterval >= 1000 then
                    currentTimeUnit[0] = 1 -- Секунды
                end
            end
            
            -- Конвертируем значение в выбранную единицу измерения
            local convertedValue = imgui.new.int(math.floor(settings.clickMainInterval / timeUnits[currentTimeUnit[0] + 1].multiplier))
            
            -- Отображаем слайдер и выбор единицы измерения в одной строке
            imgui.SetCursorPosX(20)
            imgui.PushItemWidth(windowWidth - 150)
            
            local unitChanged = false
            if imgui.SliderInt("##MainInterval", convertedValue, 1, timeUnits[currentTimeUnit[0] + 1].max, "%d") then
                -- Конвертируем обратно в миллисекунды
                settings.clickMainInterval = convertedValue[0] * timeUnits[currentTimeUnit[0] + 1].multiplier
                changed = true
            end
            
            -- Подсказка при наведении на слайдер основного интервала
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.PushTextWrapPos(300)
                imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"Основной интервал между циклами кликов")
                imgui.TextColored(imgui.ImVec4(0.8, 0.8, 0.8, 1.0), u8"Чем больше значение, тем реже будут выполняться циклы кликов")
                imgui.TextColored(imgui.ImVec4(0.7, 0.9, 0.7, 1.0), string.format(u8"Текущее значение: %d мс (%.2f сек, %.2f мин)", 
                    settings.clickMainInterval, 
                    settings.clickMainInterval / 1000, 
                    settings.clickMainInterval / 60000))
                imgui.PopTextWrapPos()
                imgui.EndTooltip()
            end
            
            imgui.SameLine()
            
            -- Стилизация комбо-бокса
            imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.15, 0.18, 0.22, 1.0))
            imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.18, 0.22, 0.25, 1.0))
            imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.22, 0.26, 0.29, 1.0))
            imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.25, 0.30, 0.34, 1.0))
            imgui.PushStyleColor(imgui.Col.PopupBg, imgui.ImVec4(0.13, 0.16, 0.20, 0.95))
            imgui.PushStyleColor(imgui.Col.Header, imgui.ImVec4(0.2, 0.7, 0.2, 0.7))
            imgui.PushStyleColor(imgui.Col.HeaderHovered, imgui.ImVec4(0.2, 0.7, 0.2, 0.8))
            imgui.PushStyleColor(imgui.Col.HeaderActive, imgui.ImVec4(0.2, 0.7, 0.2, 1.0))
            
            imgui.PushItemWidth(100)
            
            -- Создаем строку с единицами измерения для комбо-бокса
            local unitLabels = u8"Миллисекунды\0Секунды\0Минуты\0"
            
            local prevUnit = currentTimeUnit[0]
            if imgui.ComboStr("##TimeUnit", currentTimeUnit, unitLabels) then
                -- Пересчитываем значение при смене единицы измерения
                local newMultiplier = timeUnits[currentTimeUnit[0] + 1].multiplier
                local oldMultiplier = timeUnits[prevUnit + 1].multiplier
                
                -- Сохраняем текущее значение в миллисекундах
                local currentValueMs = convertedValue[0] * oldMultiplier
                
                -- Пересчитываем значение для нового множителя
                convertedValue[0] = math.floor(currentValueMs / newMultiplier)
                
                -- Обновляем значение в настройках
                settings.clickMainInterval = convertedValue[0] * newMultiplier
                settings.timeUnitIndex = currentTimeUnit[0] -- Сохраняем выбранный индекс
                
                unitChanged = true
                changed = true
            end
            
            imgui.PopItemWidth()
            imgui.PopStyleColor(8)
            
            -- Подсказка при наведении на комбо-бокс единиц измерения
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.PushTextWrapPos(300)
                imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"Выберите единицу измерения времени")
                imgui.TextColored(imgui.ImVec4(0.8, 0.8, 0.8, 1.0), u8"Значение будет автоматически пересчитано")
                imgui.PopTextWrapPos()
                imgui.EndTooltip()
            end
            
            imgui.PopItemWidth()
            
            imgui.Spacing()
            
            -- Интервал между кликами
            imgui.SetCursorPosX(20)
            imgui.TextColored(self.colors.text, u8"Интервал между кликами:")
            
            -- Добавляем выбор единицы измерения времени для интервала между кликами
            local clickIntervalUnits = {
                {name = u8"Миллисекунды", multiplier = 1, max = 5000},
                {name = u8"Секунды", multiplier = 1000, max = 10}
            }
            
            -- Создаем временную переменную для выбора единицы измерения
            local currentClickIntervalUnit = imgui.new.int(settings.clickIntervalUnitIndex or 0) -- Используем сохраненное значение
            
            -- Определяем текущую единицу измерения на основе значения интервала
            if settings.clickIntervalUnitIndex == nil then -- Если значение еще не было сохранено
                if settings.clickInterval >= 1000 then
                    currentClickIntervalUnit[0] = 1 -- Секунды
                end
            end
            
            -- Конвертируем значение в выбранную единицу измерения
            local convertedClickInterval = imgui.new.int(math.floor(settings.clickInterval / clickIntervalUnits[currentClickIntervalUnit[0] + 1].multiplier))
            
            -- Отображаем слайдер и выбор единицы измерения в одной строке
            imgui.SetCursorPosX(20)
            imgui.PushItemWidth(windowWidth - 150)
            
            if imgui.SliderInt("##ClickInterval", convertedClickInterval, 1, clickIntervalUnits[currentClickIntervalUnit[0] + 1].max, "%d") then
                -- Конвертируем обратно в миллисекунды
                settings.clickInterval = convertedClickInterval[0] * clickIntervalUnits[currentClickIntervalUnit[0] + 1].multiplier
                changed = true
            end
            
            -- Подсказка при наведении на слайдер интервала между кликами
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.PushTextWrapPos(300)
                imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"Интервал между отдельными кликами в одном цикле")
                imgui.TextColored(imgui.ImVec4(0.8, 0.8, 0.8, 1.0), u8"Чем меньше значение, тем быстрее будут выполняться клики")
                imgui.TextColored(imgui.ImVec4(0.7, 0.9, 0.7, 1.0), string.format(u8"Текущее значение: %d мс (%.2f сек)", 
                    settings.clickInterval, 
                    settings.clickInterval / 1000))
                imgui.PopTextWrapPos()
                imgui.EndTooltip()
            end
            
            imgui.SameLine()
            
            -- Стилизация комбо-бокса
            imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.15, 0.18, 0.22, 1.0))
            imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.18, 0.22, 0.25, 1.0))
            imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.22, 0.26, 0.29, 1.0))
            imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.25, 0.30, 0.34, 1.0))
            imgui.PushStyleColor(imgui.Col.PopupBg, imgui.ImVec4(0.13, 0.16, 0.20, 0.95))
            imgui.PushStyleColor(imgui.Col.Header, imgui.ImVec4(0.2, 0.7, 0.2, 0.7))
            imgui.PushStyleColor(imgui.Col.HeaderHovered, imgui.ImVec4(0.2, 0.7, 0.2, 0.8))
            imgui.PushStyleColor(imgui.Col.HeaderActive, imgui.ImVec4(0.2, 0.7, 0.2, 1.0))
            
            imgui.PushItemWidth(100)
            
            -- Создаем строку с единицами измерения для комбо-бокса
            local clickUnitLabels = u8"Миллисекунды\0Секунды\0"
            
            local prevClickUnit = currentClickIntervalUnit[0]
            if imgui.ComboStr("##ClickIntervalUnit", currentClickIntervalUnit, clickUnitLabels) then
                -- Пересчитываем значение при смене единицы измерения
                local newMultiplier = clickIntervalUnits[currentClickIntervalUnit[0] + 1].multiplier
                local oldMultiplier = clickIntervalUnits[prevClickUnit + 1].multiplier
                
                -- Сохраняем текущее значение в миллисекундах
                local currentValueMs = convertedClickInterval[0] * oldMultiplier
                
                -- Пересчитываем значение для нового множителя
                convertedClickInterval[0] = math.floor(currentValueMs / newMultiplier)
                
                -- Обновляем значение в настройках
                settings.clickInterval = convertedClickInterval[0] * newMultiplier
                settings.clickIntervalUnitIndex = currentClickIntervalUnit[0] -- Сохраняем выбранный индекс
                
                changed = true
            end
            
            imgui.PopItemWidth()
            imgui.PopStyleColor(8)
            
            -- Подсказка при наведении на комбо-бокс единиц измерения
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.PushTextWrapPos(300)
                imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"Выберите единицу измерения времени")
                imgui.TextColored(imgui.ImVec4(0.8, 0.8, 0.8, 1.0), u8"Значение будет автоматически пересчитано")
                imgui.PopTextWrapPos()
                imgui.EndTooltip()
            end
            
            imgui.PopItemWidth()
            
            imgui.Spacing()
            
            -- Количество кликов в цикле
            imgui.SetCursorPosX(20)
            imgui.TextColored(self.colors.text, u8"Количество кликов в цикле:")
            imgui.SetCursorPosX(20)
            imgui.PushItemWidth(windowWidth - 40)
            
            -- Создаем временную переменную для слайдера
            local clickCount = imgui.new.int(settings.clickCount)
            if imgui.SliderInt("##ClickCount", clickCount, 1, 20, "%d") then
                settings.clickCount = clickCount[0]
                changed = true
            end
            
            -- Подсказка при наведении на слайдер количества кликов
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.PushTextWrapPos(300)
                imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"Количество кликов, выполняемых за один цикл")
                imgui.TextColored(imgui.ImVec4(0.8, 0.8, 0.8, 1.0), u8"При наступлении основного интервала будет выполнено указанное количество кликов")
                imgui.TextColored(imgui.ImVec4(0.7, 0.9, 0.7, 1.0), string.format(u8"Текущее значение: %d кликов", settings.clickCount))
                imgui.PopTextWrapPos()
                imgui.EndTooltip()
            end
            
            imgui.PopItemWidth()
            
            imgui.Spacing()
            
            -- Выбор кнопки для клика
            imgui.SetCursorPosX(20)
            imgui.TextColored(self.colors.text, u8"Кнопка для клика:")
            
            local buttonNames = u8"Левая кнопка мыши\0Правая кнопка мыши\0Средняя кнопка мыши\0"
            
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
            
            -- Разделитель
            pos = imgui.GetCursorScreenPos()
            lineStart = imgui.ImVec2(pos.x + 10, pos.y)
            lineEnd = imgui.ImVec2(pos.x + windowWidth - 20, pos.y)
            drawList:AddLine(lineStart, lineEnd, imgui.ColorConvertFloat4ToU32(self.colors.textDim), 1.0)
            
            imgui.Spacing()
            imgui.Spacing()
            
            -- Мини-панель с двумя кнопками запуска
            imgui.SetCursorPosX(20)
            
            -- Заголовок с иконкой
            local quickStartText = u8"? Быстрый запуск с таймером:"
            local quickStartTextSize = imgui.CalcTextSize(quickStartText)
            imgui.TextColored(imgui.ImVec4(0.9, 0.7, 0.3, 1.0), quickStartText)
            
            -- Подсказка при наведении на заголовок
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.PushTextWrapPos(300)
                imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"Запуск кликера с автоматической остановкой через указанное время")
                imgui.PopTextWrapPos()
                imgui.EndTooltip()
            end
            
            imgui.Spacing()
            
            -- Контейнер для кнопок
            local buttonPanelWidth = windowWidth - 40
            imgui.SetCursorPosX(20)
            imgui.BeginChild("##QuickButtonsPanel", imgui.ImVec2(buttonPanelWidth, 60), true)
                
                -- Стиль для мини-панели
                imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0.08, 0.08, 0.08, 1.0))
                
                -- Анимация для кнопок (пульсация)
                local pulseSpeed = 1.5 -- Скорость пульсации
                local pulseAmount = 0.05 -- Амплитуда пульсации (5%)
                local pulseFactor = math.sin(os.clock() * pulseSpeed) * pulseAmount + 1.0 -- Значение от 0.95 до 1.05
                
                -- Кнопка "Запустить на 5 минут"
                local smallButtonWidth = (buttonPanelWidth - 30) / 2
                imgui.SetCursorPos(imgui.ImVec2(10, 15))
                
                -- Эффект наведения для первой кнопки
                local isHovered1 = imgui.IsMouseHoveringRect(
                    imgui.GetCursorScreenPos(),
                    imgui.ImVec2(
                        imgui.GetCursorScreenPos().x + smallButtonWidth,
                        imgui.GetCursorScreenPos().y + 30
                    )
                )
                
                -- Анимация размера кнопки при наведении
                local buttonSize1 = imgui.ImVec2(
                    smallButtonWidth * (isHovered1 and pulseFactor or 1.0),
                    30 * (isHovered1 and pulseFactor or 1.0)
                )
                
                imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.2, 0.5, 0.7, 1.0))
                imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.3, 0.6, 0.8, 1.0))
                imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.4, 0.7, 0.9, 1.0))
                
                if imgui.Button(u8"Запустить на 5 минут", buttonSize1) then
                    settings.isClicking[0] = true
                    settings.isActivated[0] = true
                    -- Запускаем кликер на 5 минут
                    if self.dependencies and self.dependencies.render then
                        self.dependencies.render:StartClickerWithTimer(5)
                    end
                    changed = true
                end
                
                -- Подсказка при наведении на кнопку
                if imgui.IsItemHovered() then
                    imgui.BeginTooltip()
                    imgui.PushTextWrapPos(300)
                    imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"Запускает кликер и автоматически останавливает его через 5 минут")
                    imgui.PopTextWrapPos()
                    imgui.EndTooltip()
                end
                
                imgui.PopStyleColor(3)
                
                -- Кнопка "Запустить на 10 минут"
                imgui.SameLine()
                imgui.SetCursorPosX(smallButtonWidth + 20)
                
                -- Эффект наведения для второй кнопки
                local isHovered2 = imgui.IsMouseHoveringRect(
                    imgui.ImVec2(imgui.GetCursorScreenPos().x, imgui.GetCursorScreenPos().y),
                    imgui.ImVec2(
                        imgui.GetCursorScreenPos().x + smallButtonWidth,
                        imgui.GetCursorScreenPos().y + 30
                    )
                )
                
                -- Анимация размера кнопки при наведении
                local buttonSize2 = imgui.ImVec2(
                    smallButtonWidth * (isHovered2 and pulseFactor or 1.0),
                    30 * (isHovered2 and pulseFactor or 1.0)
                )
                
                imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.7, 0.5, 0.2, 1.0))
                imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.8, 0.6, 0.3, 1.0))
                imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.9, 0.7, 0.4, 1.0))
                
                if imgui.Button(u8"Запустить на 10 минут", buttonSize2) then
                    settings.isClicking[0] = true
                    settings.isActivated[0] = true
                    -- Запускаем кликер на 10 минут
                    if self.dependencies and self.dependencies.render then
                        self.dependencies.render:StartClickerWithTimer(10)
                    end
                    changed = true
                end
                
                -- Подсказка при наведении на кнопку
                if imgui.IsItemHovered() then
                    imgui.BeginTooltip()
                    imgui.PushTextWrapPos(300)
                    imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"Запускает кликер и автоматически останавливает его через 10 минут")
                    imgui.PopTextWrapPos()
                    imgui.EndTooltip()
                end
                
                imgui.PopStyleColor(3)
                imgui.PopStyleColor() -- ChildBg
            
            imgui.EndChild()
            
            imgui.Spacing()
            imgui.Spacing()
            
            -- Красивый индикатор состояния кликера
            imgui.SetCursorPosX(20)
            
            -- Заголовок с иконкой
            local statusText = u8"?? Статус кликера и таймер:"
            local statusTextSize = imgui.CalcTextSize(statusText)
            imgui.TextColored(imgui.ImVec4(0.3, 0.7, 0.9, 1.0), statusText)
            
            -- Подсказка при наведении на заголовок
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.PushTextWrapPos(300)
                imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"Отображает текущее состояние кликера, время до следующего клика и оставшееся время автостопа")
                imgui.PopTextWrapPos()
                imgui.EndTooltip()
            end
            
            imgui.Spacing()
            
            -- Контейнер для индикатора
            local indicatorPanelWidth = windowWidth - 40
            imgui.SetCursorPosX(20)
            imgui.BeginChild("##StatusIndicatorPanel", imgui.ImVec2(indicatorPanelWidth, 120), true)
                
                -- Стиль для панели индикатора
                imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0.08, 0.08, 0.08, 1.0))
                
                -- Рисуем круглый индикатор
                local centerX = 40
                local centerY = 40
                local radius = 25
                
                -- Анимация пульсации для активного индикатора
                local pulseRadius = radius
                if settings.isClicking[0] then
                    -- Создаем эффект пульсации на основе времени
                    local pulseSpeed = 2.0 -- Скорость пульсации
                    local pulseAmount = 3.0 -- Амплитуда пульсации
                    local pulseFactor = math.sin(os.clock() * pulseSpeed) * 0.5 + 0.5 -- Значение от 0 до 1
                    pulseRadius = radius + pulseFactor * pulseAmount
                end
                
                imgui.SetCursorPos(imgui.ImVec2(centerX - radius, centerY - radius))
                
                local indicatorPos = imgui.GetCursorScreenPos()
                local indicatorCenter = imgui.ImVec2(indicatorPos.x + radius, indicatorPos.y + radius)
                
                -- Фоновый круг (серый)
                drawList:AddCircleFilled(
                    indicatorCenter,
                    radius,
                    imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.2, 0.2, 0.2, 1.0)),
                    32
                )
                
                -- Добавляем круговую полосу прогресса для отображения времени до следующего клика
                if settings.isClicking[0] then
                    -- Рассчитываем прогресс (от 0 до 1)
                    local progress = 1.0 - (settings.currentTime / settings.clickMainInterval)
                    
                    -- Рисуем дугу прогресса
                    local segments = 32 -- Количество сегментов для плавной дуги
                    local arcRadius = radius + 2 -- Радиус дуги (немного больше основного круга)
                    local startAngle = -math.pi / 2 -- Начинаем с верхней точки (-90 градусов)
                    local endAngle = startAngle + math.pi * 2 * progress -- Угол, соответствующий прогрессу
                    
                    -- Цвет прогресса (от желтого к зеленому)
                    local progressColor = imgui.ImVec4(
                        0.2 + (1.0 - progress) * 0.8, -- R: от 1.0 до 0.2
                        0.7 + progress * 0.2, -- G: от 0.7 до 0.9
                        0.2, -- B: постоянный
                        1.0  -- A: полная непрозрачность
                    )
                    
                    -- Рисуем дугу прогресса
                    local arcThickness = 3.0 -- Толщина дуги
                    drawList:PathClear()
                    
                    -- Добавляем точки для создания дуги
                    for i = 0, segments do
                        local angle = startAngle + (endAngle - startAngle) * (i / segments)
                        local x = indicatorCenter.x + math.cos(angle) * arcRadius
                        local y = indicatorCenter.y + math.sin(angle) * arcRadius
                        drawList:PathLineTo(imgui.ImVec2(x, y))
                    end
                    
                    -- Рисуем дугу
                    drawList:PathStroke(
                        imgui.ColorConvertFloat4ToU32(progressColor),
                        false, -- не замыкаем путь
                        arcThickness
                    )
                end
                
                -- Добавляем внешнее свечение для активного индикатора
                if settings.isClicking[0] then
                    -- Внешнее свечение (градиент)
                    local glowColor = imgui.ImVec4(0.2, 0.8, 0.2, 0.2) -- Полупрозрачный зеленый
                    drawList:AddCircleFilled(
                        indicatorCenter,
                        pulseRadius + 5,
                        imgui.ColorConvertFloat4ToU32(glowColor),
                        32
                    )
                end
                
                -- Активный круг (зеленый или красный)
                local activeColor = settings.isClicking[0] and 
                    imgui.ImVec4(0.2, 0.8, 0.2, 1.0) or 
                    imgui.ImVec4(0.8, 0.2, 0.2, 1.0)
                
                drawList:AddCircleFilled(
                    indicatorCenter,
                    settings.isClicking[0] and pulseRadius - 3 or radius - 3, -- Анимированный радиус для активного состояния
                    imgui.ColorConvertFloat4ToU32(activeColor),
                    32
                )
                
                -- Внутренний круг (светлее)
                local innerColor = settings.isClicking[0] and 
                    imgui.ImVec4(0.3, 0.9, 0.3, 1.0) or 
                    imgui.ImVec4(0.9, 0.3, 0.3, 1.0)
                
                drawList:AddCircleFilled(
                    indicatorCenter,
                    settings.isClicking[0] and pulseRadius / 2 or radius / 2, -- Анимированный радиус для внутреннего круга
                    imgui.ColorConvertFloat4ToU32(innerColor),
                    32
                )
                
                -- Текст статуса справа от индикатора
                local statusIndicatorText = settings.isClicking[0] and 
                    u8"Кликер активен" or 
                    u8"Кликер неактивен"
                
                imgui.SetCursorPos(imgui.ImVec2(centerX + radius + 20, centerY - 20))
                imgui.TextColored(
                    settings.isClicking[0] and imgui.ImVec4(0.2, 0.8, 0.2, 1.0) or imgui.ImVec4(0.8, 0.2, 0.2, 1.0),
                    statusIndicatorText
                )
                
                -- Время до следующего клика
                local timeText
                if settings.isClicking[0] then
                    timeText = string.format(u8"До следующего клика: %s", self:_formatTime(settings.currentTime))
                    
                    -- Если установлен таймер автоматической остановки
                    if settings.timerEndTime and settings.timerEndTime > 0 then
                        local remainingSeconds = math.max(0, settings.timerEndTime - os.time())
                        local minutes = math.floor(remainingSeconds / 60)
                        local seconds = remainingSeconds % 60
                        
                        -- Добавляем информацию о времени до остановки
                        imgui.SetCursorPos(imgui.ImVec2(centerX + radius + 20, centerY + 25))
                        
                        -- Изменяем цвет в зависимости от оставшегося времени
                        local timerColor
                        if remainingSeconds < 30 then
                            -- Красный для последних 30 секунд
                            timerColor = imgui.ImVec4(0.9, 0.3, 0.3, 1.0)
                        elseif remainingSeconds < 60 then
                            -- Оранжевый для последней минуты
                            timerColor = imgui.ImVec4(0.9, 0.5, 0.2, 1.0)
                        else
                            -- Обычный желтый
                            timerColor = imgui.ImVec4(0.9, 0.7, 0.3, 1.0)
                        end
                        
                        imgui.TextColored(
                            timerColor,
                            string.format(u8"Автостоп через: %02d:%02d", minutes, seconds)
                        )
                        
                        -- Добавляем кнопку для отмены таймера
                        imgui.SetCursorPos(imgui.ImVec2(centerX + radius + 20, centerY + 45))
                        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.7, 0.3, 0.3, 0.8))
                        imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.8, 0.4, 0.4, 0.9))
                        imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.9, 0.5, 0.5, 1.0))
                        
                        if imgui.Button(u8"Отменить автостоп", imgui.ImVec2(150, 20)) then
                            settings.timerEndTime = 0
                            changed = true
                            
                            -- Сохраняем изменения через render, если доступно
                            if self.dependencies and self.dependencies.render then
                                self.dependencies.render.storage:save_to_file(self.dependencies.render.ConfigName, true, 2)
                            end
                        end
                        
                        -- Подсказка при наведении на кнопку отмены таймера
                        if imgui.IsItemHovered() then
                            imgui.BeginTooltip()
                            imgui.PushTextWrapPos(300)
                            imgui.TextColored(imgui.ImVec4(1, 0.5, 0.5, 1.0), u8"Отменить автоматическую остановку")
                            imgui.TextColored(imgui.ImVec4(0.8, 0.8, 0.8, 1.0), u8"Кликер продолжит работать без ограничения по времени")
                            imgui.PopTextWrapPos()
                            imgui.EndTooltip()
                        end
                        
                        imgui.PopStyleColor(3)
                    end
                else
                    timeText = u8"Ожидание запуска..."
                end
                
                imgui.SetCursorPos(imgui.ImVec2(centerX + radius + 20, centerY + 5))
                imgui.TextColored(self.colors.textDim, timeText)
                
                imgui.PopStyleColor() -- ChildBg
            
            imgui.EndChild()
            
            imgui.Spacing()
            imgui.Spacing()
            
            -- Разделитель
            pos = imgui.GetCursorScreenPos()
            lineStart = imgui.ImVec2(pos.x + 10, pos.y)
            lineEnd = imgui.ImVec2(pos.x + windowWidth - 20, pos.y)
            drawList:AddLine(lineStart, lineEnd, imgui.ColorConvertFloat4ToU32(self.colors.textDim), 1.0)
            
            imgui.Spacing()
            imgui.Spacing()
            
            -- Кнопка включения/выключения кликера
            local buttonWidth = windowWidth - 40
            imgui.SetCursorPosX(20)
            
            local buttonColor = settings.isClicking[0] and 
                imgui.ImVec4(0.8, 0.2, 0.2, 1.0) or 
                self.colors.accent
            
            local buttonText = settings.isClicking[0] and u8"Остановить кликер" or u8"Запустить кликер"
            
            -- Анимация для основной кнопки
            local mainButtonPulseSpeed = 2.0 -- Скорость пульсации
            local mainButtonPulseAmount = 0.03 -- Амплитуда пульсации (3%)
            local mainButtonPulseFactor = math.sin(os.clock() * mainButtonPulseSpeed) * mainButtonPulseAmount + 1.0
            
            -- Эффект наведения для основной кнопки
            local isMainButtonHovered = imgui.IsMouseHoveringRect(
                imgui.ImVec2(imgui.GetCursorScreenPos().x, imgui.GetCursorScreenPos().y),
                imgui.ImVec2(
                    imgui.GetCursorScreenPos().x + buttonWidth,
                    imgui.GetCursorScreenPos().y + 40
                )
            )
            
            -- Размер кнопки с учетом анимации
            local mainButtonSize = imgui.ImVec2(
                buttonWidth * (isMainButtonHovered and mainButtonPulseFactor or 1.0),
                40 * (isMainButtonHovered and mainButtonPulseFactor or 1.0)
            )
            
            -- Центрирование кнопки с учетом анимации
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
                    -- Останавливаем кликер
                    if self.dependencies and self.dependencies.render then
                        self.dependencies.render:StopClicker()
                    else
                        settings.isClicking[0] = false
                    end
                else
                    -- Запускаем кликер
                    settings.isClicking[0] = true
                end
                changed = true
            end
            
            -- Подсказка при наведении на основную кнопку
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.PushTextWrapPos(300)
                if settings.isClicking[0] then
                    imgui.TextColored(imgui.ImVec4(1, 0.5, 0.5, 1.0), u8"Остановить работу кликера")
                    imgui.TextColored(imgui.ImVec4(0.8, 0.8, 0.8, 1.0), u8"Прекращает автоматические клики и сбрасывает таймер автостопа")
                else
                    imgui.TextColored(imgui.ImVec4(0.5, 1, 0.5, 1.0), u8"Запустить работу кликера")
                    imgui.TextColored(imgui.ImVec4(0.8, 0.8, 0.8, 1.0), u8"Начинает автоматические клики с заданными параметрами")
                end
                imgui.PopTextWrapPos()
                imgui.EndTooltip()
            end
            
            imgui.PopStyleColor(3)
            
            -- Возвращаем конфиг, если были изменения
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

