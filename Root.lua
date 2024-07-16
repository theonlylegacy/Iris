local Types = loadstring(game:HttpGet("https://raw.githubusercontent.com/theonlylegacy/Iris/main/Types.lua"))()

return function(Iris: Types.Internal, widgets: Types.WidgetUtility)
    local NumNonWindowChildren: number = 0

    --stylua: ignore
    Iris.WidgetConstructor("Root", {
        hasState = false,
        hasChildren = true,
        Args = {},
        Events = {},
        Generate = function(_thisWidget: Types.Widget)
            local Root: Folder = Instance.new("Folder")
            Root.Name = "Iris_Root"

            local PseudoWindowScreenGui
            if Iris._config.UseScreenGUIs then
                PseudoWindowScreenGui = Instance.new("ScreenGui")
                PseudoWindowScreenGui.ResetOnSpawn = false
                PseudoWindowScreenGui.DisplayOrder = Iris._config.DisplayOrderOffset
                PseudoWindowScreenGui.IgnoreGuiInset = Iris._config.IgnoreGuiInset
            else
                PseudoWindowScreenGui = Instance.new("Frame")
                PseudoWindowScreenGui.AnchorPoint = Vector2.new(0.5, 0.5)
                PseudoWindowScreenGui.Position = UDim2.new(0.5, 0, 0.5, 0)
                PseudoWindowScreenGui.Size = UDim2.new(1, 0, 1, 0)
                PseudoWindowScreenGui.BackgroundTransparency = 1
                PseudoWindowScreenGui.ZIndex = Iris._config.DisplayOrderOffset
            end
            PseudoWindowScreenGui.Name = "PseudoWindowScreenGui"
            PseudoWindowScreenGui.Parent = Root

            local PopupScreenGui
            if Iris._config.UseScreenGUIs then
                PopupScreenGui = Instance.new("ScreenGui")
                PopupScreenGui.ResetOnSpawn = false
                PopupScreenGui.DisplayOrder = Iris._config.DisplayOrderOffset + 1024 -- room for 1024 regular windows before overlap
                PopupScreenGui.IgnoreGuiInset = Iris._config.IgnoreGuiInset
            else
                PopupScreenGui = Instance.new("Frame")
                PopupScreenGui.AnchorPoint = Vector2.new(0.5, 0.5)
                PopupScreenGui.Position = UDim2.new(0.5, 0, 0.5, 0)
                PopupScreenGui.Size = UDim2.new(1, 0, 1, 0)
                PopupScreenGui.BackgroundTransparency = 1
                PopupScreenGui.ZIndex = Iris._config.DisplayOrderOffset + 1024
            end
            PopupScreenGui.Name = "PopupScreenGui"
            PopupScreenGui.Parent = Root

            local TooltipContainer: Frame = Instance.new("Frame")
            TooltipContainer.Name = "TooltipContainer"
            TooltipContainer.AutomaticSize = Enum.AutomaticSize.XY
            TooltipContainer.Size = UDim2.fromOffset(0, 0)
            TooltipContainer.BackgroundTransparency = 1
            TooltipContainer.BorderSizePixel = 0

            widgets.UIListLayout(TooltipContainer, Enum.FillDirection.Vertical, UDim.new(0, Iris._config.PopupBorderSize))

            TooltipContainer.Parent = PopupScreenGui

            local MenuBarContainer: Frame = Instance.new("Frame")
            MenuBarContainer.Name = "MenuBarContainer"
            MenuBarContainer.AutomaticSize = Enum.AutomaticSize.Y
            MenuBarContainer.Size = UDim2.fromScale(1, 0)
            MenuBarContainer.BackgroundTransparency = 1
            MenuBarContainer.BorderSizePixel = 0

            MenuBarContainer.Parent = PopupScreenGui

            local PseudoWindow: Frame = Instance.new("Frame")
            PseudoWindow.Name = "PseudoWindow"
            PseudoWindow.Size = UDim2.new(0, 0, 0, 0)
            PseudoWindow.Position = UDim2.fromOffset(0, 22)
            PseudoWindow.AutomaticSize = Enum.AutomaticSize.XY
            PseudoWindow.BackgroundTransparency = Iris._config.WindowBgTransparency
            PseudoWindow.BackgroundColor3 = Iris._config.WindowBgColor
            PseudoWindow.BorderSizePixel = Iris._config.WindowBorderSize
            PseudoWindow.BorderColor3 = Iris._config.BorderColor

            PseudoWindow.Selectable = false
            PseudoWindow.SelectionGroup = true
            PseudoWindow.SelectionBehaviorUp = Enum.SelectionBehavior.Stop
            PseudoWindow.SelectionBehaviorDown = Enum.SelectionBehavior.Stop
            PseudoWindow.SelectionBehaviorLeft = Enum.SelectionBehavior.Stop
            PseudoWindow.SelectionBehaviorRight = Enum.SelectionBehavior.Stop

            PseudoWindow.Visible = false

            widgets.UIPadding(PseudoWindow, Iris._config.WindowPadding)
            widgets.UIListLayout(PseudoWindow, Enum.FillDirection.Vertical, UDim.new(0, Iris._config.ItemSpacing.Y))

            PseudoWindow.Parent = PseudoWindowScreenGui

            return Root
        end,
        Update = function(thisWidget: Types.Widget)
            if NumNonWindowChildren > 0 then
                local Root = thisWidget.Instance :: any
                local PseudoWindowScreenGui = Root.PseudoWindowScreenGui :: any
                local PseudoWindow: Frame = PseudoWindowScreenGui.PseudoWindow
                PseudoWindow.Visible = true
            end
        end,
        Discard = function(thisWidget: Types.Widget)
            NumNonWindowChildren = 0
            thisWidget.Instance:Destroy()
        end,
        ChildAdded = function(thisWidget: Types.Widget, childWidget: Types.Widget)
            local Root = thisWidget.Instance :: any

            if childWidget.type == "Window" then
                return thisWidget.Instance
            elseif childWidget.type == "Tooltip" then
                return Root.PopupScreenGui.TooltipContainer
            elseif childWidget.type == "MenuBar" then
                return Root.PopupScreenGui.MenuBarContainer
            else
                local PseudoWindowScreenGui = Root.PseudoWindowScreenGui :: any
                local PseudoWindow: Frame = PseudoWindowScreenGui.PseudoWindow

                NumNonWindowChildren += 1
                PseudoWindow.Visible = true

                return PseudoWindow
            end
        end,
        ChildDiscarded = function(thisWidget: Types.Widget, childWidget: Types.Widget)
            if childWidget.type ~= "Window" and childWidget.type ~= "Tooltip" and childWidget.type ~= "MenuBar" then
                NumNonWindowChildren -= 1
                if NumNonWindowChildren == 0 then
                    local Root = thisWidget.Instance :: any
                    local PseudoWindowScreenGui = Root.PseudoWindowScreenGui :: any
                    local PseudoWindow: Frame = PseudoWindowScreenGui.PseudoWindow
                    PseudoWindow.Visible = false
                end
            end
        end,
    } :: Types.WidgetClass)
end
