if getgenv().ConsoleUI then ConsoleUI:Destroy() end
local CoreGui = game:GetService("CoreGui")
local LogService = game:GetService("LogService")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomConsoleGUI"
screenGui.Parent = CoreGui

getgenv().ConsoleUI = screenGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.5, 0, 0.7, 0)
frame.Position = UDim2.new(0, 0, 0, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.5
frame.BorderSizePixel = 2
frame.Visible = true
frame.Active = true
frame.Draggable = false 
frame.Parent = screenGui

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
titleBar.Parent = frame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.Text = "Console Log"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 18
titleLabel.TextXAlignment = Enum.TextXAlignment.Center
titleLabel.Parent = titleBar

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, -60)
scrollFrame.Position = UDim2.new(0, 0, 0, 30)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.BackgroundTransparency = 1
scrollFrame.Parent = frame

local clearButton = Instance.new("TextButton")
clearButton.Size = UDim2.new(1, 0, 0, 30)
clearButton.Position = UDim2.new(0, 0, 1, -30)
clearButton.Text = "Clear"
clearButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
clearButton.Parent = frame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(0.01, 0, 0.01, 0)
toggleButton.Text = "☰"
toggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
toggleButton.Parent = screenGui

toggleButton.Active = true
toggleButton.Draggable = true

toggleButton.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollFrame

getgenv().lineNum = 0
local function addLog(text, messageType)
    lineNum = lineNum + 1

    -- Create new label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 20)
    label.Text = string.format(' [%d]: %s', lineNum, text)
    label.BackgroundTransparency = 1
    label.AutomaticSize = Enum.AutomaticSize.Y
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.Font = Enum.Font.Code
    label.TextScaled = false
    label.TextSize = 13
    
    -- Color based on message type
    if messageType == Enum.MessageType.MessageError then
        label.TextColor3 = Color3.fromRGB(255, 50, 50)
    elseif messageType == Enum.MessageType.MessageWarning then
        label.TextColor3 = Color3.fromRGB(255, 200, 0)
    elseif messageType == Enum.MessageType.MessageInfo then
        label.TextColor3 = Color3.fromRGB(50, 150, 255)
    else
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
    
    label.Parent = scrollFrame

    -- Ensure a UIListLayout exists
    if not scrollFrame:FindFirstChild("UIListLayout") then
        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = scrollFrame
    end

    -- Delete the oldest message if there are more than 100 logs
   --[[ if #scrollFrame:GetChildren() > 101 then
        for _, child in ipairs(scrollFrame:GetChildren()) do
            if child:IsA("TextLabel") then
                child:Destroy()
                break -- Only delete the first one
            end
        end
    end]]
    
    -- Update canvas size and scroll to bottom
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, scrollFrame.UIListLayout.AbsoluteContentSize.Y)
    scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.AbsoluteCanvasSize.Y)
end

local function clearLog()
    lineNum = 0
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end 
    end
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
end

clearButton.MouseButton1Click:Connect(clearLog)

LogService.MessageOut:Connect(function(message, messageType)
    addLog(message, messageType)
end)

local function MakeDraggable(topbarobject, object)
  local UserInputService = game.UserInputService
  local TweenService = game.TweenService
  local Dragging = nil
  local DragInput = nil
  local DragStart = nil
  local StartPosition = nil

  local function clampPosition(position)
      local screenSize = screenGui.AbsoluteSize
      local guiSize = object.AbsoluteSize
      
      local minX, minY = 0, 0
      local maxX = screenSize.X - guiSize.X
      local maxY = screenSize.Y - guiSize.Y
      
      return Vector2.new(math.clamp(position.X, minX, maxX or 1), math.clamp(position.Y, minY, maxY or 1))
  end

  local function Update(input)
    local Delta = input.Position - DragStart
    local pos =
    UDim2.new(
      StartPosition.X.Scale,
      StartPosition.X.Offset + Delta.X,
      StartPosition.Y.Scale,
      StartPosition.Y.Offset + Delta.Y
    )
    local clampedPos = clampPosition(Vector2.new(pos.X.Offset, pos.Y.Offset))
    local Tween = TweenService:Create(object, TweenInfo.new(0.1), {Position = UDim2.new(0, clampedPos.X, 0, clampedPos.Y)})
    Tween:Play()
  end

  topbarobject.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
      Dragging = true
      DragStart = input.Position
      StartPosition = object.Position

      input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
          Dragging = false
        end
      end)
    end
  end)

  topbarobject.InputChanged:Connect(function(input)
    if
      input.UserInputType == Enum.UserInputType.MouseMovement or
      input.UserInputType == Enum.UserInputType.Touch
    then
      DragInput = input
    end
  end)

  UserInputService.InputChanged:Connect(function(input)
    if input == DragInput and Dragging then
      Update(input)
    end
  end)
end

MakeDraggable(titleBar,frame)
