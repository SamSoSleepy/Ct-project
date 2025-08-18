--[[
Luna Roblox GUI (Template คล้ายสไตล์ GUI ทั่วไปในคลิป)
- หน้าต่างหลัก: หัวข้อ + ปุ่มย่อ/ปิด + ลากได้ + ขยาย/ย่อด้วยมุมขวาล่าง
- แท็บ: Main / Automation / Items
- คอนโทรล: Toggle, Slider, Button, Search + รายการแบบเลื่อน
- ปุ่มลัด: กด P เพื่อเปิด/ปิด GUI
- สถานะมุมขวาล่าง: "ทำงานอยู่" / "หยุด"
- จำค่าการตั้งค่าไว้ใน getgenv() ระหว่างการใช้งานเกมเดียวกัน

วิธีใช้:
1) คัดลอกสคริปต์นี้ทั้งไฟล์ไปรันด้วย Luna/Executor หรือใน LocalScript (ปรับ parent เป็น PlayerGui หากใช้ใน Studio)
2) แก้ไขโค้ดในส่วน "-- TODO: ใส่ลอจิกของคุณ" ให้ทำงานตามต้องการ

หมายเหตุ:
- สคริปต์พยายามใช้สไตล์สมัยใหม่ (มุมโค้ง, เงา, ไอคอนข้อความ)
- รองรับ syn.protect_gui(), gethui() เพื่อความเข้ากันได้ของ executor หลายเจ้า
]]

local Services = setmetatable({}, {__index=function(_,k) return game:GetService(k) end})
local Players = Services.Players
local TweenService = Services.TweenService
local UserInputService = Services.UserInputService
local RunService = Services.RunService

local LP = Players.LocalPlayer
local Mouse = LP and LP:GetMouse()

-- ===================== Config & State =====================
local CFG = getgenv and getgenv() or _G
CFG.LUNA_GUI_CFG = CFG.LUNA_GUI_CFG or {
    open = true,
    mainPos = UDim2.new(0.5, -260, 0.5, -180),
    windowSize = Vector2.new(520, 360),
    toggles = {},
    loopDelay = 0.25,
}

local THEME = {
    bg = Color3.fromRGB(18, 18, 20),
    bg2 = Color3.fromRGB(26, 26, 28),
    header = Color3.fromRGB(34, 34, 38),
    accent = Color3.fromRGB(90, 110, 255),
    stroke = Color3.fromRGB(60, 60, 65),
    text = Color3.fromRGB(235, 235, 240),
    subtext = Color3.fromRGB(170, 170, 180),
    good = Color3.fromRGB(40, 200, 120),
    bad = Color3.fromRGB(230, 70, 90),
}

-- ===================== Gui Root =====================
local function getGuiRoot()
    local root = (gethui and gethui()) or (LP and LP:FindFirstChildOfClass("PlayerGui")) or Services.CoreGui
    return root
end

local function protect(gui)
    if syn and syn.protect_gui then pcall(syn.protect_gui, gui) end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LunaGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
protect(ScreenGui)
ScreenGui.Parent = getGuiRoot()

-- ===================== Helpers =====================
local function mk(inst, props, children)
    local obj = Instance.new(inst)
    for k,v in pairs(props or {}) do obj[k] = v end
    for _,ch in ipairs(children or {}) do ch.Parent = obj end
    return obj
end

local function uiCorner(r)
    return mk("UICorner", {CornerRadius = UDim.new(0, r or 12)})
end

local function uiStroke(thick, color)
    return mk("UIStroke", {Thickness = thick or 1, Color = color or THEME.stroke, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
end

local function tween(o, t, data)
    TweenService:Create(o, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), data):Play()
end

local function makeShadow(parent)
    local sh = mk("ImageLabel", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5028857084",
        ImageColor3 = Color3.new(0,0,0),
        ImageTransparency = 0.3,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(24,24,276,276),
        Size = UDim2.fromScale(1,1),
        ZIndex = 0,
    })
    sh.Parent = parent
    return sh
end

-- ===================== Main Window =====================
local Main = mk("Frame", {
    Name = "Window",
    AnchorPoint = Vector2.new(0,0),
    Size = UDim2.fromOffset(CFG.LUNA_GUI_CFG.windowSize.X, CFG.LUNA_GUI_CFG.windowSize.Y),
    Position = CFG.LUNA_GUI_CFG.mainPos,
    BackgroundColor3 = THEME.bg,
    BorderSizePixel = 0,
})
uiCorner(16).Parent = Main
uiStroke(1).Parent = Main
makeShadow(Main)
Main.Parent = ScreenGui

local Header = mk("Frame", {
    Name = "Header",
    Size = UDim2.new(1,0,0,44),
    BackgroundColor3 = THEME.header,
    BorderSizePixel = 0,
})
uiCorner(16).Parent = Header
Header.Parent = Main

local Title = mk("TextLabel", {
    Name = "Title",
    Size = UDim2.new(1,-130,1,0),
    Position = UDim2.new(0,16,0,0),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamSemibold,
    Text = "Luna GUI",
    TextSize = 18,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextColor3 = THEME.text,
})
Title.Parent = Header

local BtnBar = mk("Frame", {
    Name = "BtnBar",
    AnchorPoint = Vector2.new(1,0),
    Position = UDim2.new(1,-8,0,6),
    Size = UDim2.fromOffset(120, 32),
    BackgroundTransparency = 1,
})
BtnBar.Parent = Header

local function mkHeaderButton(txt)
    local b = mk("TextButton", {
        AutoButtonColor = false,
        Size = UDim2.fromOffset(36,32),
        BackgroundColor3 = THEME.bg2,
        Text = txt,
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
        TextColor3 = THEME.text,
    })
    uiCorner(10).Parent = b
    uiStroke(1).Parent = b
    b.MouseEnter:Connect(function() tween(b,0.15,{BackgroundColor3 = THEME.header}) end)
    b.MouseLeave:Connect(function() tween(b,0.15,{BackgroundColor3 = THEME.bg2}) end)
    return b
end

local MinBtn = mkHeaderButton("–")
MinBtn.Parent = BtnBar
MinBtn.Position = UDim2.fromOffset(0,0)

local CloseBtn = mkHeaderButton("×")
CloseBtn.Parent = BtnBar
CloseBtn.Position = UDim2.fromOffset(42,0)

local HideBtn = mkHeaderButton("☰")
HideBtn.Parent = BtnBar
HideBtn.Position = UDim2.fromOffset(84,0)

local TabBar = mk("Frame", {
    Name = "TabBar",
    Size = UDim2.new(1, -24, 0, 36),
    Position = UDim2.new(0,12,0,52),
    BackgroundColor3 = THEME.bg2,
    BorderSizePixel = 0,
})
uiCorner(12).Parent = TabBar
uiStroke(1).Parent = TabBar
TabBar.Parent = Main

local Content = mk("Frame", {
    Name = "Content",
    Size = UDim2.new(1, -24, 1, -52-12-16),
    Position = UDim2.new(0,12,0,52+36+12),
    BackgroundColor3 = THEME.bg,
    BorderSizePixel = 0,
    ClipsDescendants = true,
})
uiCorner(12).Parent = Content
uiStroke(1).Parent = Content
Content.Parent = Main

-- Resize handle (bottom-right)
local Resize = mk("Frame", {Name="Resize", AnchorPoint=Vector2.new(1,1), Position=UDim2.new(1,-6,1,-6), Size=UDim2.fromOffset(16,16), BackgroundColor3=THEME.bg2, BorderSizePixel=0})
uiCorner(4).Parent = Resize
uiStroke(1).Parent = Resize
Resize.Parent = Main

-- ===================== Dragging / Resizing =====================
local dragging, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local resizing, rStart, startSize
Resize.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = true
        rStart = input.Position
        startSize = Main.AbsoluteSize
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then resizing = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - rStart
        local newW = math.clamp(startSize.X + delta.X, 420, 920)
        local newH = math.clamp(startSize.Y + delta.Y, 300, 720)
        Main.Size = UDim2.fromOffset(newW, newH)
    end
end)

-- Save position/size periodically
RunService.RenderStepped:Connect(function()
    CFG.LUNA_GUI_CFG.mainPos = Main.Position
    CFG.LUNA_GUI_CFG.windowSize = Main.AbsoluteSize
end)

-- ===================== Tabs =====================
local function mkTab(name)
    local btn = mk("TextButton", {
        Name = name.."TabBtn",
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(120, 36),
        Font = Enum.Font.Gotham,
        Text = name,
        TextSize = 14,
        TextColor3 = THEME.subtext,
        AutoButtonColor = false,
    })
    local underline = mk("Frame", {Size = UDim2.new(0,0,0,2), Position = UDim2.new(0.5,0,1,-2), AnchorPoint = Vector2.new(0.5,1), BackgroundColor3 = THEME.accent, BorderSizePixel = 0})
    underline.Parent = btn

    local page = mk("Frame", {Name = name.."Page", Visible = false, BackgroundTransparency = 1, Size = UDim2.fromScale(1,1)})
    page.Parent = Content

    return btn, underline, page
end

local TabList = mk("UIListLayout", {Padding = UDim.new(0,8), FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Left, SortOrder = Enum.SortOrder.LayoutOrder})
TabList.Parent = TabBar
TabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    -- center tabs if space remains
end)

local tabs = {}
local function addTab(name)
    local btn, under, page = mkTab(name)
    btn.Parent = TabBar
    tabs[name] = {btn=btn, under=under, page=page}
    return tabs[name]
end

local function selectTab(name)
    for n,t in pairs(tabs) do
        local active = (n==name)
        t.page.Visible = active
        tween(t.btn, 0.15, {TextColor3 = active and THEME.text or THEME.subtext})
        tween(t.under, 0.2, {Size = active and UDim2.new(0,80,0,2) or UDim2.new(0,0,0,2)})
    end
end

addTab("Main")
addTab("Automation")
addTab("Items")

for _,t in pairs(tabs) do
    t.btn.MouseButton1Click:Connect(function()
        selectTab(t.btn.Name:gsub("TabBtn$",""))
    end)
end

selectTab("Main")

-- ===================== Controls (builders) =====================
local function addSection(parent, titleText)
    local sec = mk("Frame", {BackgroundColor3=THEME.bg2, BorderSizePixel=0, Size=UDim2.new(1,-24,0,56)})
    uiCorner(12).Parent = sec
    uiStroke(1).Parent = sec
    sec.Parent = parent

    local label = mk("TextLabel", {BackgroundTransparency=1, Position=UDim2.new(0,16,0,0), Size=UDim2.new(1,-32,1,0), Font=Enum.Font.GothamSemibold, Text=titleText, TextSize=16, TextXAlignment=Enum.TextXAlignment.Left, TextColor3=THEME.text})
    label.Parent = sec

    return sec
end

local function addList(parent)
    local holder = mk("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,1,0)})
    holder.Parent = parent

    local search = mk("TextBox", {PlaceholderText="ค้นหา...", ClearTextOnFocus=false, Size=UDim2.new(1,0,0,32), BackgroundColor3=THEME.bg2, BorderSizePixel=0, Font=Enum.Font.Gotham, Text="", TextSize=14, TextColor3=THEME.text})
    uiCorner(10).Parent = search
    uiStroke(1).Parent = search
    search.Parent = holder

    local list = mk("ScrollingFrame", {Position=UDim2.new(0,0,0,40), Size=UDim2.new(1,0,1,-44), CanvasSize=UDim2.fromOffset(0,0), ScrollBarThickness=6, BackgroundColor3=THEME.bg2, BorderSizePixel=0})
    uiCorner(12).Parent = list
    uiStroke(1).Parent = list
    list.Parent = holder

    local layout = mk("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,6)})
    layout.Parent = list

    local function refreshCanvas()
        list.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 12)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refreshCanvas)

    local items = {}
    local function addItem(text)
        if text == "" then return end
        local row = mk("TextButton", {AutoButtonColor=false, Size=UDim2.new(1,-12,0,34), BackgroundColor3=THEME.bg, Text=text, Font=Enum.Font.Gotham, TextSize=14, TextColor3=THEME.text})
        uiCorner(8).Parent = row
        uiStroke(1).Parent = row
        row.Parent = list
        row.MouseEnter:Connect(function() tween(row,0.1,{BackgroundColor3=THEME.header}) end)
        row.MouseLeave:Connect(function() tween(row,0.1,{BackgroundColor3=THEME.bg}) end)
        table.insert(items, row)
    end

    local function filter()
        local q = string.lower(search.Text)
        for _,r in ipairs(items) do
            local show = q=="" or string.find(string.lower(r.Text), q, 1, true)
            r.Visible = not not show
        end
        refreshCanvas()
    end

    search:GetPropertyChangedSignal("Text"):Connect(filter)

    return {
        add = addItem,
        filter = filter,
        frame = holder,
    }
end

local function addToggle(parent, label, key, default, onChanged)
    CFG.LUNA_GUI_CFG.toggles[key] = (CFG.LUNA_GUI_CFG.toggles[key] ~= nil) and CFG.LUNA_GUI_CFG.toggles[key] or default

    local row = mk("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,40)})
    row.Parent = parent

    local txt = mk("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(1,-80,1,0), Position=UDim2.new(0,0,0,0), Font=Enum.Font.Gotham, Text=label, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, TextColor3=THEME.text})
    txt.Parent = row

    local btn = mk("TextButton", {AutoButtonColor=false, AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,-4,0.5,0), Size=UDim2.fromOffset(64,28), BackgroundColor3=THEME.bad, Text="",})
    uiCorner(14).Parent = btn
    uiStroke(1).Parent = btn
    btn.Parent = row

    local knob = mk("Frame", {Size=UDim2.fromOffset(24,24), Position=UDim2.new(0,2,0.5,-12), AnchorPoint=Vector2.new(0,0.5), BackgroundColor3=Color3.fromRGB(255,255,255), BorderSizePixel=0})
    uiCorner(12).Parent = knob
    knob.Parent = btn

    local function apply(v)
        tween(btn,0.2,{BackgroundColor3 = v and THEME.good or THEME.bad})
        tween(knob,0.2,{Position = v and UDim2.new(1,-26,0.5,-12) or UDim2.new(0,2,0.5,-12)})
        if onChanged then task.spawn(onChanged, v) end
    end

    btn.MouseButton1Click:Connect(function()
        CFG.LUNA_GUI_CFG.toggles[key] = not CFG.LUNA_GUI_CFG.toggles[key]
        apply(CFG.LUNA_GUI_CFG.toggles[key])
    end)

    apply(CFG.LUNA_GUI_CFG.toggles[key])
    return function() return CFG.LUNA_GUI_CFG.toggles[key] end
end

local function addSlider(parent, label, min, max, default, onChanged)
    CFG.LUNA_GUI_CFG.loopDelay = CFG.LUNA_GUI_CFG.loopDelay or default

    local col = mk("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,48)})
    col.Parent = parent

    local txt = mk("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,18), Font=Enum.Font.Gotham, Text=string.format("%s (%.2fs)", label, default), TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, TextColor3=THEME.text})
    txt.Parent = col

    local bar = mk("Frame", {Position=UDim2.new(0,0,0,22), Size=UDim2.new(1,0,0,10), BackgroundColor3=THEME.bg2, BorderSizePixel=0})
    uiCorner(6).Parent = bar
    uiStroke(1).Parent = bar
    bar.Parent = col

    local fill = mk("Frame", {Size=UDim2.new(0,0,1,0), BackgroundColor3=THEME.accent, BorderSizePixel=0})
    uiCorner(6).Parent = fill
    fill.Parent = bar

    local dragging = false
    local function setFromX(x)
        local rel = math.clamp((x - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
        local val = min + (max - min) * rel
        val = math.floor(val*100)/100
        CFG.LUNA_GUI_CFG.loopDelay = val
        txt.Text = string.format("%s (%.2fs)", label, val)
        fill.Size = UDim2.new(rel,0,1,0)
        if onChanged then onChanged(val) end
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            setFromX(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            setFromX(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    -- init
    local initRel = (default - min) / (max - min)
    fill.Size = UDim2.new(initRel,0,1,0)

    return function() return CFG.LUNA_GUI_CFG.loopDelay end
end

-- ===================== Pages Content =====================
-- Main Page
local MainPage = tabs.Main.page
local MainLayout = mk("UIListLayout", {Padding = UDim.new(0,12)})
MainLayout.Parent = MainPage

local secMain = addSection(MainPage, "ควบคุมหลัก (Main Controls)")
secMain.Size = UDim2.new(1,0,0,160)

local colMain = mk("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,-32,1,-20), Position=UDim2.new(0,16,0,10)})
colMain.Parent = secMain
local listMain = mk("UIListLayout", {Padding = UDim.new(0,8)})
listMain.Parent = colMain

local isRunning = false
local function onToggleRun(v)
    isRunning = v
end

local getRun = addToggle(colMain, "ทำงาน (Start / Stop)", "run", false, onToggleRun)
local getDelay = addSlider(colMain, "หน่วงเวลาลูป (Loop Delay)", 0.05, 2.0, CFG.LUNA_GUI_CFG.loopDelay or 0.25, function(val) end)

local btnAction = mk("TextButton", {Size=UDim2.new(1,0,0,40), BackgroundColor3=THEME.accent, AutoButtonColor=false, Text="สั่งทำงานครั้งเดียว (Run Once)", Font=Enum.Font.GothamSemibold, TextSize=14, TextColor3=Color3.new(1,1,1)})
uiCorner(10).Parent = btnAction
uiStroke(1, Color3.fromRGB(80,80,255)).Parent = btnAction
btnAction.Parent = colMain

btnAction.MouseButton1Click:Connect(function()
    -- TODO: ใส่ลอจิกของคุณแบบครั้งเดียว
    -- ตัวอย่าง: print("Run once")
    pcall(function() Services.StarterGui:SetCore("SendNotification", {Title="Luna", Text="Run once", Duration=2}) end)
end)

-- Automation Page
local AutoPage = tabs.Automation.page
local AutoLayout = mk("UIListLayout", {Padding = UDim.new(0,12)})
AutoLayout.Parent = AutoPage

local secAuto = addSection(AutoPage, "Automation / รายการเป้าหมาย")
secAuto.Size = UDim2.new(1,0,1,-12)

local listAuto = addList(mk("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,-32,1,-20), Position=UDim2.new(0,16,0,10), Parent = secAuto}))

-- ตัวอย่างเติมรายการ (แก้เป็นดึงศัตรู/ไอเท็มจริง ๆ ได้)
for i=1,25 do listAuto.add("Target #"..i) end

-- Items Page
local ItemsPage = tabs.Items.page
local ItemsLayout = mk("UIListLayout", {Padding = UDim.new(0,12)})
ItemsLayout.Parent = ItemsPage

local secItems = addSection(ItemsPage, "ตัวอย่างปุ่มไอเท็ม (Sample)")
secItems.Size = UDim2.new(1,0,0,100)

local rowItems = mk("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,-32,1,-20), Position=UDim2.new(0,16,0,10)})
rowItems.Parent = secItems
local hl = mk("UIListLayout", {Padding = UDim.new(0,8)})
hl.Parent = rowItems

for i=1,3 do
    local b = mk("TextButton", {Size=UDim2.new(1,0,0,36), BackgroundColor3=THEME.bg, AutoButtonColor=false, Text="Use Item #"..i, Font=Enum.Font.Gotham, TextSize=14, TextColor3=THEME.text})
    uiCorner(8).Parent = b
    uiStroke(1).Parent = b
    b.Parent = rowItems
    b.MouseButton1Click:Connect(function()
        -- TODO: ใส่ลอจิกกดใช้ไอเท็ม
        print("Use Item", i)
    end)
end

-- ===================== Status Pill (bottom-right) =====================
local Status = mk("TextLabel", {AnchorPoint=Vector2.new(1,1), Position=UDim2.new(1,-16,1,-16), Size=UDim2.fromOffset(140,34), BackgroundColor3=THEME.bad, Text="หยุด", Font=Enum.Font.GothamSemibold, TextSize=14, TextColor3=Color3.new(1,1,1), TextXAlignment = Enum.TextXAlignment.Center})
uiCorner(12).Parent = Status
uiStroke(1).Parent = Status
Status.Parent = ScreenGui

-- keybind P toggle + sound
local sound = Instance.new("Sound")
.soundId = "rbxassetid://6568398699"
sound.SoundId = "rbxassetid://6568398699"
sound.Volume = 0.5
sound.Parent = ScreenGui

local function setOpen(state)
    CFG.LUNA_GUI_CFG.open = state
    Main.Visible = state
    TabBar.Visible = state
    Content.Visible = state
    Status.Visible = true
    sound:Play()
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.P then
        setOpen(not Main.Visible)
    end
end)

MinBtn.MouseButton1Click:Connect(function() tween(Main,0.2,{Size = UDim2.fromOffset(Main.AbsoluteSize.X, 60)}) end)
HideBtn.MouseButton1Click:Connect(function() setOpen(not Main.Visible) end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- ===================== Main Loop (ตัวอย่าง) =====================
-- ปรับใช้ร่วมกับ toggle/slider ด้านบน
local runningThread
local function stopLoop()
    isRunning = false
    if runningThread then runningThread:Disconnect() runningThread = nil end
    Status.Text = "หยุด"
    Status.BackgroundColor3 = THEME.bad
end

local function startLoop()
    if runningThread then runningThread:Disconnect() runningThread = nil end
    isRunning = true
    Status.Text = "ทำงานอยู่"
    Status.BackgroundColor3 = THEME.good

    runningThread = RunService.Heartbeat:Connect(function()
        -- ใช้ Heartbeat แทน while true do wait() เพื่อไม่บล็อกเธรด
    end)

    task.spawn(function()
        while isRunning do
            -- TODO: ใส่ลอจิกของคุณในลูปหลักที่นี่
            -- ตัวอย่าง: print("loop tick")
            task.wait(CFG.LUNA_GUI_CFG.loopDelay)
        end
    end)
end

-- ติดตามการเปลี่ยนค่า toggle run
local lastRun = getRun()
RunService.RenderStepped:Connect(function()
    local nowRun = CFG.LUNA_GUI_CFG.toggles["run"]
    if nowRun ~= lastRun then
        lastRun = nowRun
        if nowRun then startLoop() else stopLoop() end
    end
end)

-- init state
setOpen(CFG.LUNA_GUI_CFG.open)
if CFG.LUNA_GUI_CFG.toggles["run"] then startLoop() else stopLoop() end
