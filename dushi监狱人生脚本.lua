--!nolint
--[[
    dushi监狱人生脚本 · 卡密验证
    ------------------------------------------------------------------
    脚本最前面执行：
      1. 读本地已保存的卡密（NLUI/dushi_key.txt）
      2. 命中就直接放行，不弹窗
      3. 否则弹出输入框，输对才继续；输错给提示，可重试
      4. 关闭弹窗 = 放弃加载（脚本中止）
    卡密表在 KEYS 里，可随时增删。
]]
local KEYS = {
    ["dushi1145"] = true,
}
local KEY_FILE = "NLUI/dushi_key.txt"

local function readSaved()
    if not (isfile and readfile) then return nil end
    local ok, data = pcall(function()
        if not isfile(KEY_FILE) then return nil end
        return readfile(KEY_FILE)
    end)
    if ok and type(data) == "string" then
        return (data:gsub("%s+", ""))
    end
    return nil
end

local function saveKey(key)
    if not (writefile and makefolder) then return end
    pcall(function()
        if isfolder and not isfolder("NLUI") then makefolder("NLUI") end
        writefile(KEY_FILE, key)
    end)
end

--- 弹出卡密输入框，阻塞直到验证通过或用户放弃
--- @return boolean ok
local function promptKey()
    local Players = game:GetService("Players")
    local LP = Players.LocalPlayer
    local host
    pcall(function() host = gethui and gethui() end)
    if not host then
        local ok = pcall(function() host = game:GetService("CoreGui") end)
        if not ok or not host then host = LP and LP:FindFirstChild("PlayerGui") end
    end
    if not host then return false end

    local gui = Instance.new("ScreenGui")
    gui.Name = "dushi_keygate"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 100000
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() gui.Parent = host end)
    if not gui.Parent then return false end

    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.fromOffset(392, 208)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundColor3 = Color3.fromRGB(9, 10, 14)
    shadow.BorderSizePixel = 0
    shadow.Parent = gui
    local sc = Instance.new("UICorner")
    sc.CornerRadius = UDim.new(0, 12)
    sc.Parent = shadow
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(34, 37, 46)
    stroke.Thickness = 1
    stroke.Parent = shadow

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 0, 26)
    title.Position = UDim2.fromOffset(20, 20)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextColor3 = Color3.fromRGB(236, 239, 246)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "dushi 监狱人生 · 卡密验证"
    title.Parent = shadow

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -40, 0, 18)
    sub.Position = UDim2.fromOffset(20, 48)
    sub.BackgroundTransparency = 1
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 12
    sub.TextColor3 = Color3.fromRGB(138, 143, 156)
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.Text = "请输入卡密后点击验证"
    sub.Parent = shadow

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -40, 0, 36)
    box.Position = UDim2.fromOffset(20, 78)
    box.BackgroundColor3 = Color3.fromRGB(21, 23, 30)
    box.BorderSizePixel = 0
    box.Font = Enum.Font.Code
    box.TextSize = 14
    box.TextColor3 = Color3.fromRGB(230, 233, 240)
    box.PlaceholderText = "卡密"
    box.PlaceholderColor3 = Color3.fromRGB(96, 101, 114)
    box.ClearTextOnFocus = false
    box.Text = ""
    box.Parent = shadow
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 8)
    bc.Parent = box
    local bs = Instance.new("UIStroke")
    bs.Color = Color3.fromRGB(38, 41, 52)
    bs.Thickness = 1
    bs.Parent = box

    local hint = Instance.new("TextLabel")
    hint.Size = UDim2.new(1, -40, 0, 16)
    hint.Position = UDim2.fromOffset(20, 120)
    hint.BackgroundTransparency = 1
    hint.Font = Enum.Font.Gotham
    hint.TextSize = 12
    hint.TextColor3 = Color3.fromRGB(240, 110, 120)
    hint.TextXAlignment = Enum.TextXAlignment.Left
    hint.Text = ""
    hint.Parent = shadow

    local verify = Instance.new("TextButton")
    verify.Size = UDim2.fromOffset(150, 34)
    verify.Position = UDim2.fromOffset(20, 148)
    verify.BackgroundColor3 = Color3.fromRGB(92, 128, 255)
    verify.BorderSizePixel = 0
    verify.Font = Enum.Font.GothamBold
    verify.TextSize = 14
    verify.TextColor3 = Color3.fromRGB(255, 255, 255)
    verify.Text = "验证"
    verify.Parent = shadow
    local vc = Instance.new("UICorner")
    vc.CornerRadius = UDim.new(0, 8)
    vc.Parent = verify

    local quit = Instance.new("TextButton")
    quit.Size = UDim2.fromOffset(150, 34)
    quit.Position = UDim2.fromOffset(222, 148)
    quit.BackgroundColor3 = Color3.fromRGB(26, 29, 38)
    quit.BorderSizePixel = 0
    quit.Font = Enum.Font.GothamBold
    quit.TextSize = 14
    quit.TextColor3 = Color3.fromRGB(190, 194, 204)
    quit.Text = "退出"
    quit.Parent = shadow
    local qc = Instance.new("UICorner")
    qc.CornerRadius = UDim.new(0, 8)
    qc.Parent = quit

    local approved, closed = false, false
    local function tryVerify()
        local entered = (box.Text or ""):gsub("%s+", "")
        if entered == "" then
            hint.Text = "请输入卡密"
            return
        end
        if KEYS[entered] then
            approved = true
            saveKey(entered)
        else
            hint.Text = "卡密错误"
            box.Text = ""
        end
    end

    verify.MouseButton1Click:Connect(tryVerify)
    box.FocusLost:Connect(function(enterPressed)
        if enterPressed then tryVerify() end
    end)
    quit.MouseButton1Click:Connect(function()
        closed = true
    end)

    task.spawn(function()
        box:CaptureFocus()
    end)

    while not approved and not closed do
        task.wait(0.1)
    end

    pcall(function() gui:Destroy() end)
    return approved
end

local saved = readSaved()
local ok
if saved and KEYS[saved] then
    ok = true
else
    ok = promptKey()
end

if not ok then
    error("[dushi] 卡密验证未通过，已停止加载", 0)
end


-- ============================================================
-- dushi监狱人生脚本（NL UI + YZ HUB 功能）
-- ============================================================
--!nolint
Players      = game:GetService("Players")
UserInput    = game:GetService("UserInputService")
TweenService = game:GetService("TweenService")
LocalPlayer  = Players.LocalPlayer
userName = LocalPlayer.DisplayName
if not userName or userName == "" then userName = LocalPlayer.Name end
AVATAR_URL = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=150&h=150"
function addAvatar(parent, x, y, size)
	local img = Instance.new("ImageLabel")
	img.Size = UDim2.fromOffset(size, size)
	img.Position = UDim2.fromOffset(x, y)
	img.BackgroundTransparency = 1
	img.Image = AVATAR_URL
	img.ZIndex = 5
	img.Parent = parent
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(1, 0)
	c.Parent = img
	return img
end
-- 重复注入清理：执行器的 gethui() 容器不在 CoreGui/PlayerGui 下，
-- 只扫 CoreGui 会残留旧菜单，导致第二次注入后堆叠。
pcall(function()
	local parents, seen = {}, {}
	local function add(p)
		if p and not seen[p] then
			seen[p] = true
			parents[#parents + 1] = p
		end
	end
	pcall(function() add(gethui and gethui()) end)
	pcall(function() add(game:GetService("CoreGui")) end)
	pcall(function() add(LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")) end)
	for _, parent in ipairs(parents) do
		for _, child in ipairs(parent:GetChildren()) do
			if child:IsA("ScreenGui")
				and (child.Name == "NeverloseUI" or child.Name == "NeverloseMenu" or child.Name == "NLUI_PL_ESP") then
				pcall(function() child:Destroy() end)
			end
		end
	end
end)
P = {
	shell        = Color3.fromRGB(10, 11, 15),
	sidebar      = Color3.fromRGB(13, 14, 19),
	toolbar      = Color3.fromRGB(9, 10, 14),
	card         = Color3.fromRGB(16, 17, 22),
	control      = Color3.fromRGB(23, 25, 32),
	controlHover = Color3.fromRGB(29, 32, 41),
	selected     = Color3.fromRGB(26, 29, 37),
	track        = Color3.fromRGB(31, 34, 42),
	border       = Color3.fromRGB(29, 31, 38),
	divider      = Color3.fromRGB(23, 25, 32),
	line         = Color3.fromRGB(22, 24, 31),
	text         = Color3.fromRGB(198, 201, 210),
	textTitle    = Color3.fromRGB(236, 238, 243),
	textMuted    = Color3.fromRGB(140, 145, 158),
	textFaint    = Color3.fromRGB(92, 97, 110),
	textDisabled = Color3.fromRGB(86, 90, 101),
	navIdle      = Color3.fromRGB(146, 150, 161),
	navIcon      = Color3.fromRGB(134, 139, 150),
	accent       = Color3.fromRGB(92, 128, 255),
	accentBright = Color3.fromRGB(118, 152, 255),
	accentBlue   = Color3.fromRGB(120, 190, 255),
	toggleOff    = Color3.fromRGB(27, 30, 38),
	toggleKnob   = Color3.fromRGB(126, 133, 146),
	toggleKnobOn = Color3.fromRGB(246, 248, 252),
	thumb        = Color3.fromRGB(247, 248, 252),
	chipTeal     = Color3.fromRGB(115, 214, 210),
	avatarA      = Color3.fromRGB(96, 74, 168),
	avatarB      = Color3.fromRGB(38, 56, 96),
	gunLight     = Color3.fromRGB(218, 220, 218),
	gunDark      = Color3.fromRGB(104, 111, 118),
	healthRed    = Color3.fromRGB(255, 112, 135),
	healthYellow = Color3.fromRGB(253, 213, 90),
}
W, H = 750, 756
MENU_DROP = 46
SHELL_W, SHELL_H = 748, 576
LANG = "en"
ZH = {
	Rage = "狂暴", Legit = "合法", Visuals = "视觉", Players = "玩家",
	World = "世界", Inventory = "库存", Miscellaneous = "杂项",
	AIMBOT = "瞄准", COMMON = "通用",
	MAIN = "主要", OTHER = "其他", SELECTION = "选择", ["ANTI-AIM"] = "反瞄准",
	TRIGGERBOT = "扳机", ENEMY = "敌人", ["ENEMY MODEL"] = "敌人模型",
	VIEW = "视图", HUD = "抬头显示", ["WORLD ESP"] = "世界透视",
	MOVEMENT = "移动", FEATURES = "功能",
	Enabled = "启用", ["Silent Aim"] = "静默瞄准", ["Automatic Fire"] = "自动开火",
	["Aim Through Walls"] = "穿墙瞄准", ["Refine Shot"] = "细化射击",
	["Field of View"] = "视野", History = "历史", ["Delay Shot"] = "延迟射击",
	["Remove Spread"] = "去除散布", ["Duck Peek Assist"] = "蹲点辅助",
	["Quick Peek Assist"] = "快速探头辅助", ["Double Tap"] = "双发",
	Prefer = "优先", Hitboxes = "命中框", ["Hit Chance"] = "命中率",
	["Min Damage"] = "最小伤害", ["Quick Stop"] = "急停", ["Quick Scope"] = "快速开镜",
	["Suppress Breathing Animations"] = "抑制呼吸动画", ["Leg Movement"] = "腿部动作",
	Pitch = "俯仰", Yaw = "偏航", ["Mouse Override"] = "鼠标覆盖",
	Activation = "激活方式", Conditions = "条件", Smoothing = "平滑",
	["Reaction Time"] = "反应时间", ["Recoil Control"] = "后坐力控制",
	["Burst Time"] = "连发时间", Visualize = "可视化",
	["Automatic Weapons"] = "自动武器", ["Standalone Recoil Control"] = "独立后坐力控制",
	Randomize = "随机化",
	["Offscreen Arrow"] = "屏幕外箭头", Sounds = "声音", Player = "玩家",
	["Behind Walls"] = "墙后", ["On Shot"] = "开火时", Ragdolls = "布娃娃",
	["Soul Particles"] = "灵魂粒子", Glow = "发光",
	["View Options"] = "视图选项", ["Scope Options"] = "开镜选项",
	["Viewmodel Options"] = "持枪模型选项", ["Perspective Options"] = "视角选项",
	["Unlock Spectating"] = "解锁观战", ["Visual Recoil"] = "视觉后坐",
	Radar = "雷达", ["Scope Overlay"] = "开镜覆盖",
	["Inaccuracy Overlay"] = "不准度覆盖", ["Death Notices"] = "死亡提示",
	Scoreboard = "记分板", Crosshairs = "准星", Bomb = "炸弹", Weapons = "武器",
	Hostages = "人质", Grenades = "手雷", ["Grenade Trajectory"] = "手雷轨迹",
	["Grenade Proximity Warnings"] = "手雷接近警告", Windows = "窗口",
	Removals = "移除", Ambience = "环境", ["Hit Marker"] = "命中标记",
	["Bullet Tracers"] = "弹道", ["Bullet Impacts"] = "弹孔",
	["Bunny Hop"] = "连跳", ["Air Strafe"] = "空中加速", ["Jump Bug"] = "跳跃漏洞",
	["Standalone Quick Stop"] = "独立急停", ["Strafe Assist"] = "加速辅助",
	["Edge Jump"] = "边缘跳", ["Slow Walk"] = "慢走", ["Fast Ladder"] = "快速爬梯",
	["Quick Switch"] = "快速切换", ["Super Toss"] = "超级投掷", ["Knife Bot"] = "刀机器人",
	["Prevent AFK Kick"] = "防挂机踢出", ["Hit Sound"] = "命中音效",
	["Automatic Purchase"] = "自动购买",
	["Automatic Grenade Release"] = "自动投雷",
	["Auto-Accept Matchmaking"] = "自动接受匹配", ["Log Events"] = "记录事件",
	Language = "语言", ["Menu Scale"] = "菜单缩放", ["ESP Scale"] = "ESP 缩放",
	["Windows Scale"] = "窗口缩放", Units = "单位", Style = "风格",
	["Island"] = "灵动岛", Opacity = "透明度", Position = "位置", Size = "大小",
	Time = "显示时长", Shadow = "阴影强度", Color = "颜色",
	["Glow Color"] = "发光颜色", ["Glow As Shadow"] = "发光作阴影",
	["Side Line"] = "右侧竖线", Animated = "动态渐变", Features = "显示内容",
	Enabled = "开启",
	["Safe Mode"] = "安全模式", Synchronization = "同步", About = "关于", Chat = "聊天",
	Renew = "续费", Subscription = "订阅",
	["Available subscriptions"] = "可用订阅", Load = "加载",
	["Branch:"] = "分支：", ["Updated:"] = "更新：",
	["Valid Until:"] = "有效期至：", ["Last Launch:"] = "上次启动：",
	Community = "社区", ["API Documentation"] = "API 文档", Global = "全局",
	Site = "官网", Lifetime = "永久",
	["The game will start automatically"] = "游戏将自动启动",
}
do
	local extra = {
		["Prison"] = "监狱", ["PRISON LIFE"] = "监狱生活专用",
		["Scope"] = "适用范围", ["Enemies"] = "敌人", ["Everyone"] = "所有人",
		["Self"] = "自己", ["Glass"] = "玻璃", ["Solid"] = "实色",
		["Team Color"] = "队伍上色", ["Hide Accessories"] = "隐藏装饰",
		["Refresh"] = "刷新间隔", ["Enemy Color"] = "敌人颜色",
		["ESP Color"] = "ESP 颜色", ["Health Bar"] = "血条",
		["Max Distance"] = "最大距离", ["Text Size"] = "文字大小",
		["Speed Value"] = "速度值", ["No Clip"] = "穿墙",
		["Fullbright"] = "全亮", ["No Fog"] = "去雾",
		["Save Config"] = "保存配置", ["Prison Life"] = "监狱生活",
		["CHAMS"] = "人物上色", ["MOVEMENT"] = "移动",
		["WORLD / PLAYER"] = "世界 / 玩家",
	}
	for k, v in pairs(extra) do ZH[k] = v end
end

function T(s)
	if LANG == "zh" then
		return ZH[s] or s
	end
	return s
end
langLabels = {}
function langText(obj, key)
	langLabels[#langLabels + 1] = { obj = obj, key = key }
	obj.Text = T(key)
	return obj
end
function setLanguage(code)
	LANG = code
	for _, e in ipairs(langLabels) do
		if e.obj and e.obj.Parent then
			e.obj.Text = T(e.key)
		end
	end
end
function corner(obj, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = obj
	return c
end
function stroke(obj, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = obj
	return s
end
function mk(class, parent, x, y, w, h, color, transparency)
	local o = Instance.new(class)
	o.Position = UDim2.fromOffset(x, y)
	o.Size = UDim2.fromOffset(w, h)
	if o:IsA("GuiObject") then
		o.BorderSizePixel = 0
		if color then o.BackgroundColor3 = color end
		if transparency then o.BackgroundTransparency = transparency end
	end
	o.Parent = parent
	return o
end
function clampSafe(v, a, b)
	if a > b then a, b = b, a end
	return math.clamp(v, a, b)
end
function frame(parent, x, y, w, h, color, transparency, radius)
	local f = mk("Frame", parent, x, y, w, h, color or P.shell, transparency or 0)
	if radius then corner(f, radius) end
	return f
end
function softShadow(parent, x, y, w, h, radius, spread, strength, z)
	local holder = frame(parent, 0, 0, 0, 0, Color3.new(0, 0, 0), 1)
	holder.BackgroundTransparency = 1
	holder.ZIndex = z or 0
	local layers = 14
	for i = layers, 1, -1 do
		local t = i / layers
		local grow = spread * t
		local alpha = strength * (1 - t) ^ 2.1
		local layer = frame(
			holder,
			x - grow,
			y - grow + 7 * t,
			w + grow * 2,
			h + grow * 2,
			Color3.new(0, 0, 0),
			1 - alpha,
			radius + grow
		)
		layer.ZIndex = z or 0
	end
	return holder
end
function label(parent, x, y, w, h, text, size, color, font, alignX)
	local l = mk("TextLabel", parent, x, y, w, h)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextSize = size or 14
	l.TextColor3 = color or P.text
	l.Font = font or Enum.Font.GothamMedium
	l.TextXAlignment = alignX or Enum.TextXAlignment.Left
	l.TextYAlignment = Enum.TextYAlignment.Center
	l.TextTruncate = Enum.TextTruncate.AtEnd
	return l
end
function bar(parent, x, y, w, h, color, rotation, transparency)
	local f = frame(parent, x, y, w, h, color, transparency or 0)
	if rotation then f.Rotation = rotation end
	return f
end
function tw(obj, props, time, style, dir)
	local info = TweenInfo.new(time or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
	local t = TweenService:Create(obj, info, props)
	t:Play()
	return t
end
P.sliderColor = P.accent
accentWidgets = {}
sliderWidgets = {}
function applyAccent(c)
	P.accent = c
	P.accentBright = Color3.new(
		math.min(1, c.R * 1.12 + 0.03),
		math.min(1, c.G * 1.12 + 0.03),
		math.min(1, c.B * 1.12 + 0.03)
	)
	for _, w in ipairs(accentWidgets) do
		if w.track and w.isOn and w.isOn() then
			tw(w.track, { BackgroundColor3 = c }, 0.15)
		end
	end
end
function applySliderColor(c)
	P.sliderColor = c
	for _, f in ipairs(sliderWidgets) do
		if f and f.Parent then
			f.BackgroundColor3 = c
		end
	end
end
function ring(parent, x, y, size, color, thickness, transparency)
	local f = frame(parent, x, y, size, size, color, 1, size / 2)
	local s = stroke(f, color, thickness or 1, transparency or 0)
	return f, s
end
function dot(parent, x, y, size, color)
	return frame(parent, x, y, size, size, color, 0, size / 2)
end
function arm(parent, cx, cy, len, thick, angle, color, alpha)
	local f = frame(parent, cx - len / 2, cy - thick / 2, len, thick, color, alpha or 0, thick / 2)
	f.Rotation = angle
	return f
end
function vshape(parent, cx, cy, w, d, thick, color, alpha)
	local half = w / 2
	local len = math.sqrt(half * half + d * d)
	local ang = math.deg(math.atan2(d, half))
	arm(parent, cx - w / 4, cy, len, thick, ang, color, alpha)
	arm(parent, cx + w / 4, cy, len, thick, -ang, color, alpha)
end
LucideManager = { Module = nil, Loaded = false }
function loadLucide()
	if LucideManager.Loaded then
		return LucideManager.Module
	end
	local cachePath = "NLUI/lucide_module.lua"
	local content
	pcall(function()
		if isfile(cachePath) then
			local c = readfile(cachePath)
			if c and #c > 5000 then
				content = c
			end
		end
	end)
	if not content then
		local urls = {
			"https://cdn.jsdelivr.net/gh/WasKKal/Asset@latest/lucide/init.lua",
			"https://raw.githubusercontent.com/WasKKal/Asset/master/lucide/init.lua",
		}
		for _, url in ipairs(urls) do
			local ok2, res = pcall(function()
				return game:HttpGet(url)
			end)
			if ok2 and res and #res > 5000 then
				content = res
				pcall(function()
					if not isfolder("NLUI") then
						makefolder("NLUI")
					end
					writefile(cachePath, res)
				end)
				break
			end
		end
	end
	if not content then
		return nil
	end
	local fn = loadstring(content)
	if not fn then
		return nil
	end
	local ok2, module = pcall(fn)
	if not ok2 or type(module) ~= "table" or type(module.GetAsset) ~= "function" then
		return nil
	end
	LucideManager.Module = module
	LucideManager.Loaded = true
	return module
end
function getIconImage(name, sizePx, color)
	local lucide = loadLucide()
	if not lucide then
		return nil
	end
	local ok2, asset = pcall(function()
		return lucide.GetAsset(name)
	end)
	if not ok2 or not asset or not asset.Url or asset.Url == "" then
		return nil
	end
	local img = Instance.new("ImageLabel")
	img.Size = UDim2.fromOffset(sizePx or 20, sizePx or 20)
	img.BackgroundTransparency = 1
	img.Image = asset.Url
	img.ImageColor3 = color or Color3.fromRGB(230, 232, 240)
	img.ScaleType = Enum.ScaleType.Fit
	return img
end
Icons = {}
function iconFn(name)
	return function(p, c)
		local img = getIconImage(name, 13, c)
		if img then
			img.Size = UDim2.fromOffset(13, 13)
			img.Position = UDim2.fromOffset(0, 0)
			img.Parent = p
		end
	end
end
Icons.crosshair = iconFn("crosshair"); Icons.mouse = iconFn("mouse-pointer-2")
Icons.image = iconFn("image"); Icons.user = iconFn("user")
Icons.globe = iconFn("globe"); Icons.layers = iconFn("layers")
Icons.sliders = iconFn("sliders-horizontal"); Icons.save = iconFn("save")
Icons.list = iconFn("list"); Icons.chevron = iconFn("chevron-down")
Icons.search = iconFn("search"); Icons.text = iconFn("type")
Icons.eye = iconFn("eye"); Icons.window = iconFn("app-window")
Icons.ruler = iconFn("ruler"); Icons.brush = iconFn("paintbrush")
Icons.shield = iconFn("shield"); Icons.sync = iconFn("refresh-cw")
Icons.info = iconFn("info"); Icons.chat = iconFn("message-circle")
activePopup = nil
function closePopup()
	if not activePopup then return end
	local pop = activePopup.pop
	local scrim = activePopup.scrim
	local shadow = activePopup.shadow
	activePopup = nil
	if pop then
		tw(pop, { BackgroundTransparency = 1 }, 0.1)
		for _, d in ipairs(pop:GetDescendants()) do
			if d:IsA("TextLabel") then
				tw(d, { TextTransparency = 1 }, 0.1)
			elseif d:IsA("Frame") then
				tw(d, { BackgroundTransparency = 1 }, 0.1)
			end
		end
	end
	if shadow then
		tw(shadow, { BackgroundTransparency = 1 }, 0.1)
	end
	if scrim then scrim:Destroy() end
	task.delay(0.12, function()
		if pop and pop.Parent then pop:Destroy() end
		if shadow and shadow.Parent then shadow:Destroy() end
	end)
end
local canvas
local gui
local openLoader
function openDropdown(anchor, options, isMulti, mask, onPick, width, colors)
	closePopup()
	local host = (UI_EDIT_OPEN and gui) or canvas
	local scale = 1
	local baseX, baseY = 0, 0
	if host == canvas then
		local us = canvas:FindFirstChildOfClass("UIScale")
		scale = us and us.Scale or 1
		baseX, baseY = canvas.AbsolutePosition.X, canvas.AbsolutePosition.Y
	end
	local anchorAbs = anchor.AbsolutePosition
	local x = (anchorAbs.X - baseX) / scale
	local y = (anchorAbs.Y - baseY) / scale
	local w = width or anchor.AbsoluteSize.X / scale
	local anchorH = anchor.AbsoluteSize.Y / scale
	local rowH = 32
	local h = math.min(#options * rowH + 8, H - 80)
	local top = y + anchorH + 6
	if top + h > H - 10 then
		top = y - h - 6
	end
	x = clampSafe(x, 10, W - w - 10)
	top = clampSafe(top, 10, H - h - 10)
	local shadow = softShadow(canvas, x, top, w, h, 16, 16, 0.09, 40)
	local pop = mk("TextButton", canvas, x, top, w, h, Color3.fromRGB(20, 20, 29), 0.06)
	pop.AutoButtonColor = false
	pop.Text = ""
	corner(pop, 16)
	pop.ZIndex = 400
	stroke(pop, Color3.fromRGB(57, 61, 76), 1, 0.18)
	bar(pop, 16, 1, w - 32, 1, Color3.new(1, 1, 1), 0, 0.92)
	local scrim = mk("TextButton", host, 0, 0, host == gui and 4000 or W, host == gui and 2400 or H)
	scrim.BackgroundTransparency = 1
	scrim.Text = ""
	scrim.ZIndex = 399
	scrim.AutoButtonColor = false
	scrim.MouseButton1Click:Connect(closePopup)
	activePopup = { pop = pop, scrim = scrim, shadow = shadow }
	local rows = {}
	for i, opt in ipairs(options) do
		local ry = 4 + (i - 1) * rowH
		local btn = mk("TextButton", pop, 4, ry, w - 8, rowH)
		btn.BackgroundTransparency = 1
		btn.Text = ""
		btn.AutoButtonColor = false
		btn.ZIndex = 402
		local hl = frame(btn, 0, 0, w - 8, rowH, P.accent, 1, 10)
		hl.ZIndex = 42
		local function isSelected()
			if isMulti then return bit32.band(mask, bit32.lshift(1, i - 1)) ~= 0 end
			return mask == i
		end
		local mark = frame(btn, 12, rowH / 2 - 3, 12, 12, Color3.new(1, 1, 1), 1)
		mark.Visible = false
		mark.ZIndex = 43
		local m1 = bar(mark, 1, 3, 4, 1.6, Color3.fromRGB(230, 233, 241), 45)
		local m2 = bar(mark, 3.5, 6.5, 7, 1.6, Color3.fromRGB(230, 233, 241), -45)
		m1.ZIndex = 43; m2.ZIndex = 43
		m1.BackgroundTransparency = 1; m2.BackgroundTransparency = 1
		local textW = (colors and colors[i]) and (w - 70) or (w - 45)
		local text = label(btn, 33, 0, textW, rowH, opt, 14,
			Color3.fromRGB(232, 236, 245))
		text.ZIndex = 43
		local sw = nil
		if colors and colors[i] then
			sw = frame(btn, w - 44, rowH / 2 - 6, 16, 12, colors[i], 0, 4)
			sw.ZIndex = 43
			stroke(sw, Color3.new(1, 1, 1), 1, 0.82).ZIndex = 44
		end
		local function refresh()
			local sel = isSelected()
			m1.BackgroundTransparency = sel and 0 or 1
			m2.BackgroundTransparency = sel and 0 or 1
			text.TextColor3 = sel and Color3.fromRGB(236, 240, 249) or Color3.fromRGB(132, 137, 150)
			text.TextTransparency = sel and 0 or 0.12
			if sw then
				sw.BackgroundTransparency = sel and 0 or 0.42
			end
		end
		refresh()
		rows[i] = refresh
		btn.MouseEnter:Connect(function() tw(hl, { BackgroundTransparency = 0.9 }, 0.12) end)
		btn.MouseLeave:Connect(function() tw(hl, { BackgroundTransparency = 1 }, 0.12) end)
		btn.MouseButton1Click:Connect(function()
			if isMulti then
				mask = bit32.bxor(mask, bit32.lshift(1, i - 1))
				refresh()
				if onPick then onPick(mask) end
			else
				mask = i
				if onPick then onPick(i) end
				closePopup()
			end
		end)
	end
	pop.BackgroundTransparency = 1
	pop.Position = UDim2.fromOffset(x, top + 4)
	tw(pop, { BackgroundTransparency = 0.06, Position = UDim2.fromOffset(x, top) }, 0.14, Enum.EasingStyle.Cubic)
	return pop, function() for _, r in ipairs(rows) do r() end end
end
function openColorPicker(anchor, initial, onChange)
	closePopup()
	local scale = canvas:FindFirstChildOfClass("UIScale").Scale
	local ax = (anchor.AbsolutePosition.X - canvas.AbsolutePosition.X) / scale
	local ay = (anchor.AbsolutePosition.Y - canvas.AbsolutePosition.Y) / scale
	local pw, ph = 216, 200
	local px = math.clamp(ax - pw + 30, 10, W - pw - 10)
	local py = math.clamp(ay + 24, 10, H - ph - 10)
	local scrim = mk("TextButton", canvas, 0, 0, W, H)
	scrim.BackgroundTransparency = 1
	scrim.Text = ""
	scrim.ZIndex = 39
	scrim.AutoButtonColor = false
	scrim.MouseButton1Click:Connect(closePopup)
	local shadow = softShadow(canvas, px, py, pw, ph, 14, 16, 0.09, 40)
	local pop = mk("TextButton", canvas, px, py, pw, ph, Color3.fromRGB(20, 20, 29), 0.06)
	pop.AutoButtonColor = false
	pop.Text = ""
	corner(pop, 14)
	pop.ZIndex = 41
	stroke(pop, Color3.fromRGB(57, 61, 76), 1, 0.18)
	bar(pop, 16, 1, pw - 32, 1, Color3.new(1, 1, 1), 0, 0.92)
	activePopup = { pop = pop, scrim = scrim, shadow = shadow }
	local h, s, v = Color3.toHSV(initial or P.accent)
	local col = Color3.fromHSV(h, s, v)
	local paint
	local sv = frame(pop, 16, 12, 184, 86, Color3.fromHSV(h, 1, 1), 0, 6)
	local whiteOverlay = frame(sv, 0, 0, 184, 86, Color3.new(1, 1, 1), 0, 6)
	local wg = Instance.new("UIGradient")
	wg.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 1),
	})
	wg.Parent = whiteOverlay
	local blackOverlay = frame(sv, 0, 0, 184, 86, Color3.new(0, 0, 0), 0, 6)
	local bg = Instance.new("UIGradient")
	bg.Rotation = 90
	bg.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, 0),
	})
	bg.Parent = blackOverlay
	local svThumb = dot(sv, 0, 0, 10, Color3.new(1, 1, 1))
	stroke(svThumb, Color3.fromRGB(15, 15, 20), 1.5, 0.25)
	svThumb.ZIndex = 3
	local svHit = mk("TextButton", sv, 0, 0, 184, 86)
	svHit.BackgroundTransparency = 1
	svHit.Text = ""
	svHit.AutoButtonColor = false
	svHit.ZIndex = 4
	local hue = frame(pop, 16, 108, 184, 8, Color3.new(1, 1, 1), 0, 4)
	local hg = Instance.new("UIGradient")
	hg.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
		ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
		ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
		ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
	})
	hg.Parent = hue
	local hueThumb = frame(pop, 0, 106, 4, 12, Color3.new(1, 1, 1), 0, 2)
	hueThumb.ZIndex = 3
	stroke(hueThumb, Color3.fromRGB(15, 15, 20), 1, 0.3)
	local hueHit = mk("TextButton", pop, 16, 102, 184, 20)
	hueHit.BackgroundTransparency = 1
	hueHit.Text = ""
	hueHit.AutoButtonColor = false
	hueHit.ZIndex = 4
	local preview = frame(pop, 16, 126, 26, 26, col, 0, 6)
	stroke(preview, Color3.new(1, 1, 1), 1, 0.8)
	local hexText = label(pop, 50, 126, 120, 26, "", 13, Color3.fromRGB(210, 213, 222))
	local presets = {
		Color3.fromRGB(75, 126, 255),
		Color3.fromRGB(93, 220, 190),
		Color3.fromRGB(255, 96, 120),
		Color3.fromRGB(255, 176, 60),
		Color3.fromRGB(180, 120, 255),
		Color3.fromRGB(255, 255, 255),
		Color3.fromRGB(140, 146, 160),
		Color3.fromRGB(20, 20, 24),
	}
	for i, c in ipairs(presets) do
		local chip = mk("TextButton", pop, 16 + (i - 1) * 24, 160, 18, 18, c, 0)
		corner(chip, 4)
		chip.AutoButtonColor = false
		chip.Text = ""
		stroke(chip, Color3.new(1, 1, 1), 1, 0.85)
		chip.MouseButton1Click:Connect(function()
			h, s, v = Color3.toHSV(c)
			paint()
		end)
	end
	local function placeSV()
		svThumb.Position = UDim2.fromOffset(s * 184 - 5, (1 - v) * 86 - 5)
	end
	local function placeHue()
		hueThumb.Position = UDim2.fromOffset(16 + h * 184 - 2, 106)
	end
	paint = function()
		col = Color3.fromHSV(h, s, v)
		sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		preview.BackgroundColor3 = col
		hexText.Text = string.format("#%02X%02X%02X",
			math.floor(col.R * 255 + 0.5),
			math.floor(col.G * 255 + 0.5),
			math.floor(col.B * 255 + 0.5))
		placeSV()
		placeHue()
		if onChange then onChange(col) end
	end
	local function bindDrag(hit, apply)
		hit.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1
				and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end
			apply(input.Position)
			local conn
			conn = UserInput.InputChanged:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseMovement
					or i.UserInputType == Enum.UserInputType.Touch then
					apply(i.Position)
				end
			end)
			UserInput.InputEnded:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1
					or i.UserInputType == Enum.UserInputType.Touch then
					if conn then conn:Disconnect() end
				end
			end)
		end)
	end
	bindDrag(svHit, function(pos)
		s = math.clamp((pos.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
		v = 1 - math.clamp((pos.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
		paint()
	end)
	bindDrag(hueHit, function(pos)
		h = math.clamp((pos.X - hue.AbsolutePosition.X) / hue.AbsoluteSize.X, 0, 1)
		paint()
	end)
	paint()
	pop.BackgroundTransparency = 1
	pop.Position = UDim2.fromOffset(px, py + 4)
	tw(pop, { BackgroundTransparency = 0.06, Position = UDim2.fromOffset(px, py) }, 0.14, Enum.EasingStyle.Cubic)
end
function makeToggle(parent, x, y, on, callback, interactive)
	local track = frame(parent, x, y, 29, 18, P.toggleOff, 0, 9)
	local glow = nil
	local knob = dot(track, 2, 2, 14, P.toggleKnob)
	local value = on and true or false
	accentWidgets[#accentWidgets + 1] = {
		track = track,
		isOn = function() return value end,
	}
	local function render(animate)
		local time = animate and 0.16 or 0
		tw(track, { BackgroundColor3 = value and P.accent or P.toggleOff }, time, Enum.EasingStyle.Quad)
		tw(knob, {
			Position = UDim2.fromOffset(value and 13 or 2, 2),
			BackgroundColor3 = value and P.toggleKnobOn or P.toggleKnob,
		}, time, Enum.EasingStyle.Quad)
	end
	render(false)
	if interactive == false then
		return value
	end
	local hit = mk("TextButton", parent, x - 5, y - 6, 39, 30)
	hit.BackgroundTransparency = 1
	hit.Text = ""
	hit.AutoButtonColor = false
	if glow then
		hit.MouseEnter:Connect(function() tw(glow, { BackgroundTransparency = 0.82 }, 0.15) end)
		hit.MouseLeave:Connect(function() tw(glow, { BackgroundTransparency = 1 }, 0.15) end)
	end
	hit.MouseButton1Click:Connect(function()
		value = not value
		render(true)
		if callback then callback(value) end
	end)
	return value
end
function makeSelect(parent, x, y, w, text, options, isMulti, mask, callback)
	local box = mk("TextButton", parent, x, y, w, 23, P.control, 0)
	corner(box, 5)
	box.AutoButtonColor = false
	box.Text = ""
	local boxStroke = stroke(box, P.border, 1)
	local lbl = label(box, 9, 0, w - 26, 23, text, 14, P.textMuted)
	lbl.TextTruncate = Enum.TextTruncate.AtEnd
	box.MouseEnter:Connect(function()
		tw(box, { BackgroundColor3 = P.controlHover }, 0.12)
		tw(boxStroke, { Color = P.accent }, 0.12)
	end)
	box.MouseLeave:Connect(function()
		tw(box, { BackgroundColor3 = P.control }, 0.12)
		tw(boxStroke, { Color = P.border }, 0.12)
	end)
	box.MouseButton1Click:Connect(function()
		openDropdown(box, options, isMulti, mask, function(result)
			mask = result
			if isMulti then
				local parts = {}
				for i, opt in ipairs(options) do
					if bit32.band(mask, bit32.lshift(1, i - 1)) ~= 0 then
						parts[#parts + 1] = opt
					end
				end
				lbl.Text = #parts > 0 and table.concat(parts, ", ") or "Select"
			else
				lbl.Text = options[result]
			end
			if callback then callback(result) end
		end, w)
	end)
	return {
		setText = function(t) lbl.Text = t end,
	}
end
sliderChase = {}
game:GetService("RunService").RenderStepped:Connect(function(dt)
	for i = #sliderChase, 1, -1 do
		if not sliderChase[i](dt) then
			table.remove(sliderChase, i)
		end
	end
end)
function makeSlider(parent, x, y, amount, valueText, pillX, pillY, onChange, num)
	local function fmt(v)
		if not num then return valueText or "0%" end
		local dec = num.decimals or 0
		return string.format("%." .. dec .. "f", v) .. (num.suffix or "")
	end
	local value
	if num then
		value = math.clamp(num.value or num.min, num.min, num.max)
		amount = (value - num.min) / (num.max - num.min)
	end
	amount = math.clamp(amount or 0, 0, 1)
	local cur = amount
	local target = amount
	local lastMove = 0
	local dragging = false
	local chasing = false
	local track = frame(parent, x, y, 80, 3, P.track, 0, 2)
	local fill = frame(track, 0, 0, 80 * cur, 3, P.sliderColor, 0, 2)
	sliderWidgets[#sliderWidgets + 1] = fill
	local knob = dot(parent, x + 80 * cur - 5.5, y - 4, 11, P.thumb)
	local pill = mk("TextButton", parent, pillX, pillY, 42, 21, P.control, 0)
	corner(pill, 5)
	pill.AutoButtonColor = false
	pill.Text = ""
	local pillText = label(pill, 0, 0, 42, 21, num and fmt(value) or (valueText or "0%"),
		13, P.textMuted, nil, Enum.TextXAlignment.Center)
	local function render(rel)
		fill.Size = UDim2.fromOffset(80 * rel, 3)
		knob.Position = UDim2.fromOffset(x + 80 * rel - 5.5, y - 4)
	end
	local function step(dt)
		local elapsed = os.clock() - lastMove
		local speed
		if dragging then
			speed = 26
		elseif elapsed < 0.06 then
			speed = 24
		elseif elapsed < 0.16 then
			speed = 12
		else
			speed = 5
		end
		local k = 1 - math.exp(-speed * dt)
		cur = cur + (target - cur) * k
		if math.abs(target - cur) < 0.0008 then
			cur = target
			render(cur)
			chasing = false
			return false
		end
		render(cur)
		return true
	end
	local function startChase()
		if not chasing then
			chasing = true
			table.insert(sliderChase, step)
		end
	end
	local function setTarget(rel)
		target = math.clamp(rel, 0, 1)
		lastMove = os.clock()
		startChase()
	end
	local function setNumeric(v)
		if not num then return end
		local st = num.step or 1
		v = math.clamp(v, num.min, num.max)
		v = math.floor(v / st + 0.5) * st
		value = v
		pillText.Text = fmt(v)
		setTarget((v - num.min) / (num.max - num.min))
		if onChange then onChange(target) end
	end
	pill.MouseButton1Click:Connect(function()
		if not num then
			return
		end
		local box = mk("TextBox", parent, pillX, pillY, 42, 21, P.control, 0)
		corner(box, 5)
		box.Text = string.format("%." .. (num.decimals or 0) .. "f", value or num.min)
		box.TextColor3 = P.textMuted
		box.TextSize = 12
		box.Font = Enum.Font.Gotham
		box.TextXAlignment = Enum.TextXAlignment.Center
		box.ClearTextOnFocus = false
		box.ZIndex = (pill.ZIndex or 1) + 2
		box:CaptureFocus()
		pill.Visible = false
		local closed = false
		local function finish()
			if closed then
				return
			end
			closed = true
			local n = tonumber(box.Text)
			if n then
				setNumeric(n)
			end
			if box.Parent then
				box:Destroy()
			end
			pill.Visible = true
		end
		box.FocusLost:Connect(finish)
	end)
	local hit = mk("TextButton", parent, x - 10, y - 13, 100, 28)
	hit.ZIndex = 30
	hit.BackgroundTransparency = 1
	hit.Text = ""
	hit.AutoButtonColor = false
	hit.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			local function applyAt(absX)
				local rel = math.clamp((absX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
				if num then
					setNumeric(num.min + (num.max - num.min) * rel)
				else
					setTarget(rel)
					if onChange then onChange(rel) end
				end
			end
			applyAt(input.Position.X)
			local conn, endConn
			conn = UserInput.InputChanged:Connect(function(i)
				if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
					applyAt(i.Position.X)
				end
			end)
			endConn = UserInput.InputEnded:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
					dragging = false
					lastMove = os.clock()
					if conn then conn:Disconnect() end
					if endConn then endConn:Disconnect() end
				end
			end)
		end
	end)
	if num then
		local hovered = false
		pill.MouseEnter:Connect(function()
			hovered = true
			tw(pill, { BackgroundColor3 = P.controlHover }, 0.1)
		end)
		pill.MouseLeave:Connect(function()
			hovered = false
			tw(pill, { BackgroundColor3 = P.control }, 0.1)
		end)
		UserInput.InputChanged:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseWheel then return end
			if not hovered then return end
			setNumeric(value + input.Position.Z * (num.step or 1))
		end)
	end
	render(cur)
	return {
		setValue = function(v)
			cur = math.clamp(v, 0, 1)
			target = cur
			render(cur)
		end,
		setText = function(t) pillText.Text = t end,
	}
end
function makeColor(parent, x, y, color, on, callback, colorCallback)
	local sw = frame(parent, x, y, 15, 15, color, 0, 4)
	stroke(sw, Color3.new(1, 1, 1), 1, 0.8)
	local hit = mk("TextButton", parent, x - 3, y - 3, 21, 21)
	hit.BackgroundTransparency = 1
	hit.Text = ""
	hit.AutoButtonColor = false
	hit.MouseEnter:Connect(function()
		tw(sw, { Size = UDim2.fromOffset(17, 17), Position = UDim2.fromOffset(x - 1, y - 1) }, 0.1)
	end)
	hit.MouseLeave:Connect(function()
		tw(sw, { Size = UDim2.fromOffset(15, 15), Position = UDim2.fromOffset(x, y) }, 0.1)
	end)
	hit.MouseButton1Click:Connect(function()
		openColorPicker(hit, sw.BackgroundColor3, function(c)
			sw.BackgroundColor3 = c
			if colorCallback then colorCallback(c) end
		end)
	end)
	makeToggle(parent, x + 20, y - 2, on, callback)
	return sw
end
CHEVRON_OPTIONS = {
	["Pitch"] = { "Down", "Up", "Fake", "Off" },
	["Yaw"] = { "Static", "Jitter", "Spin", "Random" },
	["Mouse Override"] = { "Enabled", "Disabled" },
	["View Options"] = { "Field of View", "Viewmodel", "World", "Off" },
	["Scope Options"] = { "Static", "Dynamic", "Off" },
	["Viewmodel Options"] = { "Default", "Custom", "Off" },
	["Perspective Options"] = { "Thirdperson", "Firstperson" },
	["Death Notices"] = { "Chat", "Console", "Off" },
	["Scoreboard"] = { "Default", "Custom" },
	["Crosshairs"] = { "Static", "Dynamic", "Off" },
	["Bomb"] = { "Icon", "Name", "Distance" },
	["Weapons"] = { "Icon", "Name", "Ammo" },
	["Hostages"] = { "Icon", "Name" },
	["Grenades"] = { "Icon", "Name", "Timer" },
	["Windows"] = { "Radar", "Console", "Spectators" },
	["Removals"] = { "Smoke", "Flash", "Fog" },
	["Ambience"] = { "Custom", "Default" },
	["Hit Marker"] = { "Static", "Dynamic", "Off" },
	["Bullet Tracers"] = { "Line", "Beam", "Off" },
}
function makeChevron(parent, x, y, onOpen, labelText)
	local b = mk("TextButton", parent, x - 15, y - 8, 30, 24)
	b.BackgroundTransparency = 1
	b.Text = ""
	b.AutoButtonColor = false
	local c = frame(b, 5, 4, 20, 16, Color3.new(1, 1, 1), 1)
	vshape(c, 10, 6, 7, 4, 1.4, Color3.fromRGB(187, 190, 199))
	b.MouseEnter:Connect(function()
		tw(b, { BackgroundTransparency = 0.92 }, 0.12)
	end)
	b.MouseLeave:Connect(function()
		tw(b, { BackgroundTransparency = 1 }, 0.12)
	end)
	b.MouseButton1Click:Connect(function()
		if onOpen then
			onOpen()
			return
		end
		local opts = CHEVRON_OPTIONS[labelText] or { "Enabled", "Disabled" }
		local localized = {}
		for i, o in ipairs(opts) do
			localized[i] = T(o)
		end
		openDropdown(b, localized, false, 1, nil, 150)
	end)
	return b
end
function buildCard(parent, spec, page)
	local card = frame(parent, spec.x, spec.y, spec.w, spec.h, P.card, 0.35, 6)
	stroke(card, P.border, 1, 0.45)
	local titleLabel = label(parent, spec.x + 12, spec.y - 18, spec.w - 24, 14, "", 10, P.textFaint)
	langText(titleLabel, spec.title)
	for i, row in ipairs(spec.rows) do
		local ry = (i - 1) * 37
		if i > 1 then
			bar(card, 12, ry, spec.w - 24, 1, P.divider)
		end
		local isDisabled = row.kind == "disabled"
		local labelW
		if row.kind == "select" or row.kind == "multi" then
			labelW = spec.w - math.min(134, spec.w * 0.48) - 30
		elseif row.kind == "slider" then
			labelW = spec.w - 160
		elseif row.kind == "chevron" then
			labelW = spec.w - 45
		else
			labelW = spec.w - 58
		end
		local rowLabel = label(card, 13, ry, math.max(labelW, 40), 37, "", 14,
			isDisabled and P.textDisabled or P.text, Enum.Font.Gotham)
		langText(rowLabel, row.label)
		if row.kind == "toggle" then
			local baseCb = row.cb
			makeToggle(card, spec.w - 43, ry + 9, row.on, function(v)
				if baseCb then baseCb(v) end
				if islandPush and not spec.silent and ISL_CFG and ISL_CFG.enabled then
					islandPush(T(row.label), v and T("Enabled") or "Disabled", v)
				end
				if notify and not spec.silent then
					notify("模块", T(row.label) .. (v and " 已开启" or " 已关闭"), v)
				end
				if featureListSet and not spec.silent then
					featureListSet(T(row.label), v, tostring(spec.title) .. ":" .. row.label)
				end
			end)
			if row.sub and #row.sub > 0 then
				local dotsBtn = mk("TextButton", card, spec.w - 78, ry + 10, 26, 17)
				dotsBtn.BackgroundTransparency = 1
				dotsBtn.Text = ""
				dotsBtn.AutoButtonColor = false
				dotsBtn.ZIndex = 3
				for i = 0, 2 do
					dot(dotsBtn, 4 + i * 7, 7, 3, Color3.fromRGB(150, 155, 168)).ZIndex = 3
				end
				dotsBtn.MouseEnter:Connect(function()
					for _, c in ipairs(dotsBtn:GetChildren()) do
						if c:IsA("Frame") then
							tw(c, { BackgroundColor3 = P.accentBright }, 0.12)
						end
					end
				end)
				dotsBtn.MouseLeave:Connect(function()
					for _, c in ipairs(dotsBtn:GetChildren()) do
						if c:IsA("Frame") then
							tw(c, { BackgroundColor3 = Color3.fromRGB(150, 155, 168) }, 0.12)
						end
					end
				end)
				dotsBtn.MouseButton1Click:Connect(function()
					if openSubPanel then
						openSubPanel(dotsBtn, T(row.label), row.sub)
					end
				end)
			end
			local bindChip = label(card, spec.w - 112, ry + 11, 54, 15,
				BINDS[row.label] or "", 10, P.accentBright, nil, Enum.TextXAlignment.Right)
			local bindHit = mk("TextButton", card, 0, ry, spec.w - 60, 37)
			bindHit.BackgroundTransparency = 1
			bindHit.Text = ""
			bindHit.AutoButtonColor = false
			bindHit.MouseButton2Click:Connect(function()
				openRowMenu(bindHit, row.label, bindChip)
			end)
		elseif row.kind == "button" then
			local btn = mk("TextButton", card, 0, ry, spec.w, 37)
			btn.BackgroundTransparency = 1
			btn.Text = ""
			btn.AutoButtonColor = false
			local valLbl = label(card, spec.w - 132, ry, 96, 37, row.value or "", 13,
				P.textMuted, nil, Enum.TextXAlignment.Right)
			arm(card, spec.w - 25, ry + 15, 5, 1.4, 45, P.textFaint)
			arm(card, spec.w - 25, ry + 21, 5, 1.4, -45, P.textFaint)
			btn.MouseButton1Click:Connect(function()
				if row.cb then
					local nv = row.cb()
					if nv and valLbl then
						valLbl.Text = nv
					end
				end
			end)
		elseif row.kind == "disabled" then
			local dim = frame(card, spec.w - 43, ry + 9, 29, 18, P.toggleOff, 0.4, 9)
			dot(dim, 2, 2, 14, Color3.fromRGB(74, 79, 90))
		elseif row.kind == "select" or row.kind == "multi" then
			local cw = math.min(134, spec.w * 0.48)
	local mask = row.mask or 0
			if row.kind == "select" then
				mask = 1
				for i, opt in ipairs(row.options) do
					if opt == row.value then mask = i end
				end
			end
			local selectBase = row.cb
			makeSelect(card, spec.w - cw - 13, ry + 7, cw, row.value,
				row.options, row.kind == "multi", mask, function(r)
					if selectBase then selectBase(r) end
					if row.kind == "multi" then
					else
					end
				end)
		elseif row.kind == "slider" then
			local pillX = spec.w - 55
			makeSlider(card, spec.w - 145, ry + 18, row.amount, row.value,
				pillX, ry + 8, row.cb, row.num)
		elseif row.kind == "color" then
			makeColor(card, spec.w - 63, ry + 11, row.color or P.accent,
				row.on == true, row.cb, row.colorCallback)
		elseif row.kind == "chevron" then
			makeChevron(card, spec.w - 22, ry + 15, row.cb, row.label)
		end
	end
	return card
end
-- ============================================================
-- ENGINE：Prison Life 玩法层（ragebot / 上色 / ESP / 移动 / 世界）
-- 只新增，不改动下方原有 UI 的页面与布局
-- ============================================================
local NL_API = (function()
--!nolint
--[[
    Prison Life · Neverlose 适配层（引擎 v2）
    ------------------------------------------------------------------
    把 Neverlose 风格 UI 接到 Prison Life (placeId 155615604) 的真实玩法上。
    UI 只负责显示与交互；本文件持有全部功能状态、参数、按键与循环。

    区域：
      1. CFG     默认参数 + 存档/读档
      2. H       工具（角色、队伍、可见性、按键）
      3. Modules chams / esp / aim / trigger / movement / world / players / misc
      4. API     UI 桥（set/get/bind/save/load），全局暴露为 NLUI_PRISON
      5. Loop    单线程按需驱动
]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")

local LP = Players.LocalPlayer
local CFG_FILE = "NLUI/prison_cfg.lua"

-- 重复注入守卫：先停掉上一份引擎（断循环、还原上色、清 ESP），
-- 避免注入两次后出现两套循环与重叠的方框。
do
    local prev = getgenv().NLUI_PRISON
    if prev and type(prev.stop) == "function" then
        pcall(prev.stop)
    end
end

-- ======================================================================
-- 1. 参数
-- ======================================================================
local CFG = {
    version = 2,
    chams = {
        enabled = false,
        scope = "enemies",
        body = "solid",
        teamColor = true,
        enemy = Color3.fromRGB(255, 84, 112),
        team = Color3.fromRGB(120, 210, 255),
        opacity = 100,
        refresh = 1.0,
        hideAccessories = false,
        keepSelf = true,
        throughWalls = "glow",
        glow = true,
    },
    esp = {
        enabled = false,
        box = true,
        name = true,
        health = true,
        distance = true,
        tool = true,
        teamCheck = true,
        maxDistance = 800,
        color = Color3.fromRGB(255, 96, 96),
        opacity = 88,
        textSize = 13,
    },
    aim = {
        enabled = false,
        fov = 120,
        smooth = 35,
        hitbox = "Head",
        teamCheck = true,
        visibleOnly = false,
        method = "camera",
        maxDistance = 600,
        drawFov = true,
    },
    -- Ragebot（对应 UI 的 Rage 页）：瞬时锁定 + 自动开火，不是平滑自瞄
    rage = {
        enabled = false,
        silent = true,
        autofire = false,
        walls = true,
        fov = 180,
        hitchance = 100,
        prefer = "Damage",
        hitboxMask = 1,
        nospread = true,
        delayShot = "Damage",
        antiaim = false,
        maxDistance = 800,
        -- 攻击判定：只打处于敌对状态（可被伤害）的目标
        attackCheck = true,
        -- 发包模式：直接构造 ShootEvent 打向目标（不走鼠标/不开火）
        packet = true,
        fireDelay = 0.12,
        -- 把鼠标移到目标屏幕位置：游戏用鼠标位置做射线，不移动鼠标打不中
        lockMouse = true,
    },
    trigger = {
        enabled = false,
        hitbox = "Head",
        teamCheck = true,
        delay = 0.05,
        maxDistance = 300,
    },
    movement = {
        speed = false,
        speedValue = 32,
        jump = false,
        jumpValue = 85,
        noclip = false,
        bhop = false,
        slowWalk = false,
        slowWalkSpeed = 8,
        fastLadder = false,
    },
    world = {
        fullbright = false,
        noFog = false,
        noFlash = false,
        noSmoke = false,
        fov = 70,
    },
    players = {
        target = "None",
    },
    misc = {
        antiAfk = true,
        notifyMods = true,
    },
}

-- ---------- 存档 ----------
local function serialize(t, indent)
    indent = indent or "  "
    local out = { "{" }
    local keys = {}
    for k in pairs(t) do
        if type(k) == "string" then keys[#keys + 1] = k end
    end
    table.sort(keys)
    for _, k in ipairs(keys) do
        local v = t[k]
        local line
        if type(v) == "table" then
            line = indent .. "[" .. string.format("%q", k) .. "] = " .. serialize(v, indent .. "  ") .. ","
        elseif type(v) == "string" then
            line = indent .. "[" .. string.format("%q", k) .. "] = " .. string.format("%q", v) .. ","
        elseif type(v) == "Color3" then
            line = indent .. "[" .. string.format("%q", k) .. "] = Color3.fromRGB("
                .. math.floor(v.R * 255 + 0.5) .. "," .. math.floor(v.G * 255 + 0.5) .. ","
                .. math.floor(v.B * 255 + 0.5) .. "),"
        else
            line = indent .. "[" .. string.format("%q", k) .. "] = " .. tostring(v) .. ","
        end
        out[#out + 1] = line
    end
    out[#out + 1] = "}"
    return table.concat(out, "\n")
end

local function ensureFolder()
    if not (isfolder and makefolder) then return end
    pcall(function()
        if not isfolder("NLUI") then makefolder("NLUI") end
    end)
end

local function saveCfg()
    if not writefile then return false end
    ensureFolder()
    local ok = pcall(function()
        writefile(CFG_FILE, "-- Prison Life Neverlose config\nreturn " .. serialize(CFG, ""))
    end)
    return ok
end

local function loadCfg()
    if not (isfile and readfile) then return false end
    local ok, data = pcall(function()
        if not isfile(CFG_FILE) then return nil end
        return readfile(CFG_FILE)
    end)
    if not ok or type(data) ~= "string" or #data < 10 then return false end
    local fn = loadstring(data)
    if not fn then return false end
    local ok2, saved = pcall(fn)
    if not ok2 or type(saved) ~= "table" then return false end
    for section, values in pairs(saved) do
        if type(CFG[section]) == "table" and type(values) == "table" then
            for k, v in pairs(values) do
                local cur = CFG[section][k]
                if cur ~= nil and type(cur) == type(v) then
                    CFG[section][k] = v
                end
            end
        end
    end
    return true
end

-- ======================================================================
-- 2. 工具
-- ======================================================================
local H = {}
local R6_PARTS = {
    Head = true, Torso = true,
    ["Left Arm"] = true, ["Right Arm"] = true,
    ["Left Leg"] = true, ["Right Leg"] = true,
}

function H.char(pl)
    local c = pl and pl.Character
    if not c or not c.Parent then return nil end
    return c
end

function H.hum(char)
    return char and char:FindFirstChildOfClass("Humanoid") or nil
end

function H.root(char)
    return char and char:FindFirstChild("HumanoidRootPart") or nil
end

function H.alive(char)
    local h = H.hum(char)
    return h ~= nil and h.Health > 0
end

function H.isEnemy(pl)
    if pl == LP then return false end
    local mine = LP.Team
    if not mine then return true end
    return pl.Team ~= mine
end

function H.isTeammate(pl)
    if pl == LP then return false end
    return LP.Team ~= nil and pl.Team == LP.Team
end

function H.isVisible(part)
    if not part then return false end
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    local ignore = {}
    if LP.Character then ignore[#ignore + 1] = LP.Character end
    if Workspace.CurrentCamera then ignore[#ignore + 1] = Workspace.CurrentCamera end
    rp.FilterDescendantsInstances = ignore
    rp.IgnoreWater = true
    local origin = Workspace.CurrentCamera.CFrame.Position
    local result = Workspace:Raycast(origin, part.Position - origin, rp)
    if not result then return true end
    return result.Instance:IsDescendantOf(part.Parent)
end

function H.clamp(v, lo, hi) return math.clamp(v, lo, hi) end

function H.lerp(a, b, t) return a + (b - a) * t end

--- 攻击判定：监狱生活里角色要处于敌对状态才吃伤害。
--- 依据角色属性（实测存在）：
---   Hostile / PunchedSomeone / Trespassing / EquippedHostileTool
--- 任一为 true 即可攻击；全为 false 时打不掉血。
local HOSTILE_ATTRS = {
    "Hostile",
    "PunchedSomeone",
    "Trespassing",
    "EquippedHostileTool",
}

--- 该玩家当前是否可被伤害
--- @return boolean canDamage, string|nil reason
function H.hostile(pl)
    local char = H.char(pl)
    if not char then return false, nil end
    for _, name in ipairs(HOSTILE_ATTRS) do
        local ok, value = pcall(function() return char:GetAttribute(name) end)
        if ok and value == true then
            return true, name
        end
    end
    return false, nil
end

--- 读取 UI 绑定表（UI 全局 BINDS）
function H.bind(name)
    local ok, key = pcall(function()
        return BINDS and BINDS[name]
    end)
    if ok and key and key ~= "" then return key end
    return nil
end

function H.keyDown(name)
    local kc = name and Enum.KeyCode[name]
    if not kc then return false end
    return UserInputService:IsKeyDown(kc)
end

function H.screenCenter()
    local vp = Workspace.CurrentCamera.ViewportSize
    return Vector2.new(vp.X / 2, vp.Y / 2), vp
end

-- 相机/灯光原值
local savedLight = {}
function H.saveLight(key)
    if savedLight[key] == nil then savedLight[key] = Lighting[key] end
end
function H.restoreLight(key)
    if savedLight[key] ~= nil then
        Lighting[key] = savedLight[key]
        savedLight[key] = nil
    end
end

-- 自己的 ESP 容器
local espContainer
function H.espContainer()
    if espContainer and espContainer.Parent then return espContainer end
    local sg = Instance.new("ScreenGui")
    sg.Name = "NLUI_PL_ESP"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 998
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local parent
    pcall(function() parent = gethui and gethui() end)
    if not parent then
        local ok = pcall(function() parent = game:GetService("CoreGui") end)
        if not ok or not parent then parent = LP:FindFirstChild("PlayerGui") end
    end
    pcall(function() sg.Parent = parent end)
    if not sg.Parent then sg.Parent = LP:WaitForChild("PlayerGui") end
    espContainer = sg
    return sg
end

-- ======================================================================
-- 3. 模块
-- ======================================================================
local M = {}

-- ---------------------------------------------------------------- 3.1 上色
local Chams = { tracker = {}, lastScan = 0 }
M.chams = Chams

local function chamsColor(pl)
    if CFG.chams.teamColor and LP.Team and pl.Team == LP.Team then
        return CFG.chams.team
    end
    return CFG.chams.enemy
end

local function chamsParts(char)
    local parts = {}
    for _, inst in ipairs(char:GetChildren()) do
        if R6_PARTS[inst.Name] and (inst:IsA("BasePart") or inst:IsA("MeshPart")) then
            parts[#parts + 1] = inst
        end
    end
    return parts
end

function Chams.should(pl)
    if pl == LP and CFG.chams.keepSelf then return false end
    local alive = H.alive(H.char(pl))
    local scope = CFG.chams.scope
    if scope == "self" then return pl == LP and alive end
    if scope == "everyone" then return alive end
    return alive and H.isEnemy(pl)
end

function Chams.paint(pl)
    local char = H.char(pl)
    if not char then return end
    local parts = chamsParts(char)
    if #parts == 0 then return end
    local color = chamsColor(pl)
    local alpha = H.clamp(CFG.chams.opacity, 0, 100) / 100
    local style = CFG.chams.body
    local rec = Chams.tracker[pl]
    if not rec or rec.char ~= char then
        rec = { char = char, originals = {} }
        Chams.tracker[pl] = rec
    end
    for _, part in ipairs(parts) do
        if not rec.originals[part] then
            rec.originals[part] = {
                Material = part.Material,
                Color = part.Color,
                Transparency = part.Transparency,
            }
        end
        if style == "glow" then
            part.Material = Enum.Material.Neon
            part.Color = color
            part.Transparency = math.min(0.55, 1 - alpha)
        elseif style == "glass" then
            part.Material = Enum.Material.Glass
            part.Color = color
            part.Transparency = math.max(0.35, 1 - alpha)
        elseif style == "outline" then
            part.Material = Enum.Material.ForceField
            part.Color = color
            part.Transparency = 0.15
        else
            part.Material = Enum.Material.SmoothPlastic
            part.Color = color
            part.Transparency = 1 - alpha
        end
    end
    if CFG.chams.hideAccessories then
        for _, inst in ipairs(char:GetChildren()) do
            if inst:IsA("Accessory") or inst:IsA("Hat") then
                pcall(function() inst:Destroy() end)
            end
        end
    end
end

local function chamsRestore(pl)
    local rec = Chams.tracker[pl]
    if not rec then return end
    for part, orig in pairs(rec.originals) do
        if part and part.Parent then
            pcall(function()
                part.Material = orig.Material
                part.Color = orig.Color
                part.Transparency = orig.Transparency
            end)
        end
    end
    Chams.tracker[pl] = nil
end

function Chams.step()
    local now = os.clock()
    if now - Chams.lastScan < math.max(0.1, CFG.chams.refresh) then return end
    Chams.lastScan = now
    for _, pl in ipairs(Players:GetPlayers()) do
        if Chams.should(pl) then
            Chams.paint(pl)
        else
            chamsRestore(pl)
        end
    end
end

function Chams.stop()
    for pl in pairs(Chams.tracker) do chamsRestore(pl) end
    Chams.tracker = {}
end

function Chams.repaint()
    for pl in pairs(Chams.tracker) do chamsRestore(pl) end
    Chams.tracker = {}
    Chams.lastScan = 0
    if CFG.chams.enabled then Chams.step() end
end

-- ---------------------------------------------------------------- 3.2 ESP
local Esp = { boxes = {}, tracers = {} }
M.esp = Esp

local function espBox(pl)
    local sg = H.espContainer()
    local root = Instance.new("Frame")
    root.Name = "ESP_" .. pl.Name
    root.BackgroundTransparency = 1
    root.BorderSizePixel = 0
    root.Visible = false
    root.ZIndex = 2
    local holder = Instance.new("Frame")
    holder.BackgroundTransparency = 1
    holder.Size = UDim2.fromScale(1, 1)
    holder.Parent = root
    local st = Instance.new("UIStroke")
    st.Color = CFG.esp.color
    st.Thickness = 1
    st.Transparency = 1 - CFG.esp.opacity / 100
    st.Parent = holder
    local texts = {}
    local function mkText(name, yOff, size, color)
        local t = Instance.new("TextLabel")
        t.Name = name
        t.BackgroundTransparency = 1
        t.Font = Enum.Font.GothamMedium
        t.TextSize = size
        t.TextColor3 = color
        t.TextXAlignment = Enum.TextXAlignment.Center
        t.TextYAlignment = Enum.TextYAlignment.Center
        t.Size = UDim2.new(1, 0, 0, 14)
        t.Position = UDim2.fromOffset(0, yOff)
        t.Visible = false
        t.Parent = holder
        texts[name] = t
    end
    mkText("name", -17, CFG.esp.textSize, CFG.esp.color)
    mkText("tool", -32, CFG.esp.textSize - 2, Color3.fromRGB(205, 205, 212))
    mkText("dist", -46, CFG.esp.textSize - 2, Color3.fromRGB(175, 175, 185))
    local hbg = Instance.new("Frame")
    hbg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    hbg.BackgroundTransparency = 0.5
    hbg.BorderSizePixel = 0
    hbg.Size = UDim2.new(0, 2, 1, 0)
    hbg.Position = UDim2.fromOffset(-5, 0)
    hbg.Parent = holder
    local hfill = Instance.new("Frame")
    hfill.BackgroundColor3 = Color3.fromRGB(90, 220, 120)
    hfill.BorderSizePixel = 0
    hfill.Size = UDim2.new(1, 0, 1, 0)
    hfill.Parent = hbg
    root.Parent = sg
    return { root = root, stroke = st, texts = texts, hbg = hbg, hfill = hfill }
end

local function espDrop(pl)
    local b = Esp.boxes[pl]
    if b then
        pcall(function() b.root:Destroy() end)
        Esp.boxes[pl] = nil
    end
end

local function project(pos)
    local sp, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(pos)
    return Vector2.new(sp.X, sp.Y), onScreen and sp.Z > 0
end

function Esp.step()
    local cam = Workspace.CurrentCamera
    local myRoot = H.root(LP.Character)
    local origin = myRoot and myRoot.Position or cam.CFrame.Position
    for _, pl in ipairs(Players:GetPlayers()) do
        local char = H.char(pl)
        local root = H.root(char)
        local hum = H.hum(char)
        local show = char and root and hum and hum.Health > 0 and pl ~= LP
        if show and CFG.esp.teamCheck and not H.isEnemy(pl) then show = false end
        if show and (root.Position - origin).Magnitude > CFG.esp.maxDistance then show = false end
        if not show then
            local b = Esp.boxes[pl]
            if b then b.root.Visible = false end
        else
            local head = char:FindFirstChild("Head")
            local b = Esp.boxes[pl] or espBox(pl)
            Esp.boxes[pl] = b
            if head then
                local topScreen, topOn = project(head.Position + Vector3.new(0, head.Size.Y / 2, 0))
                local botScreen, botOn = project(root.Position - Vector3.new(0, root.Size.Y / 2, 0))
                local dist = (root.Position - origin).Magnitude
                if topOn and botOn then
                    local h = math.max(4, botScreen.Y - topScreen.Y)
                    local w = h * 0.55
                    b.root.Visible = CFG.esp.box
                    b.root.Position = UDim2.fromOffset(topScreen.X - w / 2, topScreen.Y)
                    b.root.Size = UDim2.fromOffset(w, h)
                    b.stroke.Color = CFG.esp.color
                    b.stroke.Transparency = 1 - CFG.esp.opacity / 100
                    local hp = H.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                    b.hbg.Visible = CFG.esp.health
                    b.hfill.Size = UDim2.new(1, 0, hp, 0)
                    b.hfill.BackgroundColor3 = Color3.fromRGB(
                        math.floor(255 * (1 - hp) + 90 * hp),
                        math.floor(220 * hp + 80 * (1 - hp)), 120)
                    b.texts.name.Visible = CFG.esp.name
                    local hostile, reason = H.hostile(pl)
                    b.texts.name.Text = pl.Name .. (hostile and "" or "  [safe]")
                    b.texts.name.TextColor3 = hostile and CFG.esp.color or Color3.fromRGB(150, 153, 163)
                    b.texts.name.TextSize = CFG.esp.textSize
                    b.texts.tool.Visible = CFG.esp.tool
                    local tool = char:FindFirstChildOfClass("Tool")
                    b.texts.tool.Text = tool and tool.Name or ""
                    b.texts.dist.Visible = CFG.esp.distance
                    b.texts.dist.Text = string.format("%dm", math.floor(dist))
                else
                    b.root.Visible = false
                end
            else
                b.root.Visible = false
            end
        end
    end
end

function Esp.stop()
    for pl in pairs(Esp.boxes) do espDrop(pl) end
    Esp.boxes = {}
    if espContainer then
        pcall(function() espContainer:Destroy() end)
        espContainer = nil
    end
end

-- ---------------------------------------------------------------- 3.3 FOV 圈
local FovCircle = { obj = nil }
function FovCircle.draw()
    local sg = H.espContainer()
    if not FovCircle.obj or not FovCircle.obj.Parent then
        local ring = Instance.new("Frame")
        ring.Name = "NLUI_FOV"
        ring.BackgroundTransparency = 1
        ring.BorderSizePixel = 0
        ring.AnchorPoint = Vector2.new(0.5, 0.5)
        ring.Position = UDim2.fromScale(0.5, 0.5)
        ring.ZIndex = 1
        local st = Instance.new("UIStroke")
        st.Thickness = 1
        st.Color = CFG.esp.color
        st.Transparency = 0.35
        st.Parent = ring
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = ring
        ring.Parent = sg
        FovCircle.obj = ring
    end
    local size = CFG.aim.fov * 2
    FovCircle.obj.Size = UDim2.fromOffset(size, size)
    FovCircle.obj.Visible = CFG.aim.enabled and CFG.aim.drawFov
    local st = FovCircle.obj:FindFirstChildOfClass("UIStroke")
    if st then st.Color = CFG.esp.color end
end

-- ---------------------------------------------------------------- 3.4 瞄准
local Aim = { target = nil }
M.aim = Aim

local function pickTarget(hitboxName, maxDist, teamCheck, visibleOnly)
    local cam = Workspace.CurrentCamera
    local center = H.screenCenter()
    local myRoot = H.root(LP.Character)
    local origin = myRoot and myRoot.Position or cam.CFrame.Position
    local best, bestScore = nil, math.huge
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LP then
            local char = H.char(pl)
            local root = H.root(char)
            local hum = H.hum(char)
            if root and hum and hum.Health > 0 then
                local allowed = true
                if teamCheck and not H.isEnemy(pl) then allowed = false end
                if allowed and (root.Position - origin).Magnitude > maxDist then allowed = false end
                local targetPart = char:FindFirstChild(hitboxName) or root
                if allowed and visibleOnly and not H.isVisible(targetPart) then allowed = false end
                if allowed then
                    local sp, onScreen = cam:WorldToViewportPoint(targetPart.Position)
                    if onScreen and sp.Z > 0 then
                        local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if d <= CFG.aim.fov and d < bestScore then
                            best, bestScore = { pl = pl, part = targetPart }, d
                        end
                    end
                end
            end
        end
    end
    return best
end

function Aim.step()
    if not CFG.aim.enabled then return end
    local bind = H.bind("Aim Key")
    if bind and not H.keyDown(bind) then return end
    local target = pickTarget(CFG.aim.hitbox, CFG.aim.maxDistance, CFG.aim.teamCheck, CFG.aim.visibleOnly)
    Aim.target = target
    if not target then return end
    local cam = Workspace.CurrentCamera
    local want = CFrame.new(cam.CFrame.Position, target.part.Position)
    if CFG.aim.method == "mouse" then
        local delta = want.LookVector - cam.CFrame.LookVector
        local factor = 1000 * (CFG.aim.smooth / 100)
        pcall(function() mousemoverel(delta.X * factor, delta.Y * factor) end)
    else
        cam.CFrame = cam.CFrame:Lerp(want, H.clamp(CFG.aim.smooth / 100, 0.02, 1))
    end
end

-- ---------------------------------------------------------------- 3.5 RAGEBOT
-- Rage 页对应 ragebot：命中框位掩码、瞬时锁定（silent）、自动开火、命中率。
-- 与 3.4 的平滑瞄（aim）是两套独立逻辑。
local Rage = { lastFire = 0, target = nil }
M.rage = Rage

-- 与 UI 的 Hitboxes 顺序一致：Head, Chest, Stomach, Arms, Legs, Feet
local RAGE_HITBOX_PARTS = {
    { "Head" },
    { "Torso" },
    { "Torso" },
    { "Left Arm", "Right Arm" },
    { "Left Leg", "Right Leg" },
    { "Left Leg", "Right Leg" },
}

local function rageTargetParts(char)
    local parts = {}
    for index, group in ipairs(RAGE_HITBOX_PARTS) do
        if bit32 and bit32.band(CFG.rage.hitboxMask, bit32.lshift(1, index - 1)) ~= 0 then
            for _, name in ipairs(group) do
                local part = char:FindFirstChild(name)
                if part then parts[#parts + 1] = part end
            end
        end
    end
    if #parts == 0 then
        local torso = char:FindFirstChild("Torso") or char:FindFirstChild("Head")
        if torso then parts[1] = torso end
    end
    return parts
end

local function ragePick()
    local cam = Workspace.CurrentCamera
    local center = H.screenCenter()
    local myRoot = H.root(LP.Character)
    local origin = myRoot and myRoot.Position or cam.CFrame.Position
    local best, bestScore = nil, math.huge
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LP then
            local char = H.char(pl)
            local root = H.root(char)
            local hum = H.hum(char)
            if root and hum and hum.Health > 0 and H.isEnemy(pl) then
                if (root.Position - origin).Magnitude <= CFG.rage.maxDistance then
                    local attackable = true
                    if CFG.rage.attackCheck then
                        attackable = H.hostile(pl)
                    end
                    for _, part in ipairs(attackable and rageTargetParts(char) or {}) do
                        if CFG.rage.walls or H.isVisible(part) then
                            local dirTo = (part.Position - cam.CFrame.Position)
                            local distTo = dirTo.Magnitude
                            if distTo > 0.1 then
                                -- 用相机夹角判 FOV（屏幕坐标会把身后的目标误判为不可见）
                                local cosA = dirTo.Unit:Dot(cam.CFrame.LookVector)
                                local ang = math.deg(math.acos(math.clamp(cosA, -1, 1)))
                                if ang <= CFG.rage.fov / 2 then
                                    local score = ang
                                    if CFG.rage.prefer == "Health" then
                                        score = hum.Health * 4 + ang / 10
                                    elseif CFG.rage.prefer == "Distance" then
                                        score = distTo
                                    end
                                    if score < bestScore then
                                        best, bestScore = { part = part, pl = pl, angle = ang, dist = distTo }, score
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

--- 远程对象会随对局重建，每次开火前动态定位并缓存
function Rage.findShootRemote()
    local cached = Rage._remote
    if cached and cached.Parent then return cached end
    local rs = game:GetService("ReplicatedStorage")
    local gr = rs:FindFirstChild("GunRemotes")
    local shoot = gr and gr:FindFirstChild("ShootEvent")
    if not shoot then
        for _, d in ipairs(rs:GetDescendants()) do
            if d:IsA("RemoteEvent") and d.Name == "ShootEvent" then
                shoot = d
                break
            end
        end
    end
    Rage._remote = shoot
    return shoot
end

--- 构造一枪的数据：{ { 起点, 命中点, 命中部件 } }
function Rage.payloadFor(target)
    local cam = Workspace.CurrentCamera
    return { { cam.CFrame.Position, target.part.Position, target.part } }
end

function Rage.step()
    if not CFG.rage.enabled then return end
    -- 命中率门限
    if CFG.rage.hitchance < 100 then
        if math.random(1, 100) > CFG.rage.hitchance then return end
    end
    local target = ragePick()
    Rage.target = target
    if not target then return end

    local cam = Workspace.CurrentCamera

    -- 发包：直接给 ShootEvent 送一枪，服务端收到后按命中点结算
    if CFG.rage.packet then
        if os.clock() - Rage.lastFire <= CFG.rage.fireDelay then return end
        Rage.lastFire = os.clock()
        local shoot = Rage.findShootRemote()
        if not shoot then return end
        pcall(function()
            shoot:FireServer(Rage.payloadFor(target))
        end)
        return
    end

    -- 瞬时锁定：直接把视角对准命中框（不做平滑，区别于平滑自瞄）
    if CFG.rage.silent then
        cam.CFrame = CFrame.new(cam.CFrame.Position, target.part.Position)
    end

    -- 鼠标锁定：游戏的开火射线取的是鼠标位置，必须把鼠标移到目标上
    if CFG.rage.lockMouse and mousemoveabs then
        local sp = cam:WorldToViewportPoint(target.part.Position)
        if sp.Z > 0 then
            pcall(function() mousemoveabs(sp.X, sp.Y) end)
        end
    end

    -- 自动开火：必须走真实点击通道。实测 tool:Activate() 不会发出 ShootEvent，
    -- 而 mouse1click / VirtualUser 点击能正常发枪（会带上锁定后的视角）。
    if CFG.rage.autofire and os.clock() - Rage.lastFire > CFG.rage.fireDelay then
        Rage.lastFire = os.clock()
        pcall(function()
            if mouse1click then
                mouse1click()
            elseif VirtualUser then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new())
            end
        end)
    end
end

-- ---------------------------------------------------------------- 3.6 扳机
local Trigger = { last = 0 }
M.trigger = Trigger
function Trigger.step()
    if not CFG.trigger.enabled then return end
    local bind = H.bind("Trigger Key")
    if bind and not H.keyDown(bind) then return end
    if os.clock() - Trigger.last < CFG.trigger.delay then return end
    local target = pickTarget(CFG.trigger.hitbox, CFG.trigger.maxDistance, CFG.trigger.teamCheck, false)
    if not target then return end
    Trigger.last = os.clock()
    pcall(function()
        if VirtualUser then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new())
        elseif mouse1click then
            mouse1click()
        end
    end)
end

-- ---------------------------------------------------------------- 3.6 移动
local Move = { noclipConn = nil }
M.movement = Move

function Move.step()
    local char = LP.Character
    local hum = H.hum(char)
    if not hum then return end
    local ws = hum:FindFirstChild("WalkSpeed")
    if CFG.movement.speed and ws then
        if ws.Value ~= CFG.movement.speedValue then ws.Value = CFG.movement.speedValue end
    end
    -- 慢走：按住绑定键（默认 Shift）时降速
    if CFG.movement.slowWalk and ws then
        local slowKey = H.bind("Slow Walk") or "LeftShift"
        if H.keyDown(slowKey) then
            ws.Value = CFG.movement.slowWalkSpeed
        elseif CFG.movement.speed then
            ws.Value = CFG.movement.speedValue
        else
            ws.Value = 16
        end
    end
    local jp = hum:FindFirstChild("JumpPower")
    if CFG.movement.jump and jp then
        if hum.UseJumpPower == false then hum.UseJumpPower = true end
        if jp.Value ~= CFG.movement.jumpValue then jp.Value = CFG.movement.jumpValue end
    end
    -- 连跳：按住空格且落地即起跳
    if CFG.movement.bhop and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        if not hum.Jumping then
            pcall(function() hum.Jump = true end)
        end
    end
end

function Move.start()
    if Move.noclipConn then return end
    Move.noclipConn = RunService.Stepped:Connect(function()
        if not CFG.movement.noclip then return end
        local char = LP.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
        end
    end)
end

function Move.stop()
    if Move.noclipConn then
        Move.noclipConn:Disconnect()
        Move.noclipConn = nil
    end
end

-- ---------------------------------------------------------------- 3.7 世界
local World = {}
M.world = World

function World.step()
    local cam = Workspace.CurrentCamera
    if cam and math.abs(cam.FieldOfView - CFG.world.fov) > 0.5 then
        cam.FieldOfView = CFG.world.fov
    end
    if CFG.world.fullbright then
        H.saveLight("Brightness"); H.saveLight("ClockTime")
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
    else
        H.restoreLight("Brightness"); H.restoreLight("ClockTime")
    end
    if CFG.world.noFog then
        H.saveLight("FogEnd"); H.saveLight("FogStart")
        Lighting.FogEnd = 1e9
        Lighting.FogStart = 1e9
    else
        H.restoreLight("FogEnd"); H.restoreLight("FogStart")
    end
end

function World.applyFlashAndSmoke()
    for _, inst in ipairs(Lighting:GetChildren()) do
        if inst.Name == "Flash" and inst:IsA("ColorCorrectionEffect") and CFG.world.noFlash then
            inst.Enabled = false
        end
    end
    local effects = Workspace:FindFirstChild("Effects")
    if effects then
        for _, inst in ipairs(effects:GetDescendants()) do
            if CFG.world.noSmoke and (inst:IsA("Smoke") or inst:IsA("Fire")) then
                inst.Enabled = false
            end
        end
    end
end

-- ---------------------------------------------------------------- 3.8 玩家
local Ply = {}
M.players = Ply

function Ply.names()
    local out = { "None" }
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LP then out[#out + 1] = pl.Name end
    end
    return out
end

function Ply.find(name)
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl.Name == name then return pl end
    end
    return nil
end

function Ply.teleport(name)
    local pl = Ply.find(name)
    local myRoot = H.root(LP.Character)
    local target = pl and H.root(H.char(pl))
    if not myRoot or not target then return false end
    myRoot.CFrame = target.CFrame * CFrame.new(0, 0, 3)
    return true
end

function Ply.look(name)
    local pl = Ply.find(name)
    local target = pl and H.root(H.char(pl))
    local cam = Workspace.CurrentCamera
    if not target or not cam then return false end
    cam.CFrame = CFrame.new(cam.CFrame.Position, target.Position)
    return true
end

function Ply.spectate(name)
    local pl = Ply.find(name)
    if not pl then return false end
    LP.CameraMode = Enum.CameraMode.Classic
    repeat task.wait(0.05) until Workspace.CurrentCamera.CameraSubject ~= nil
    Workspace.CurrentCamera.CameraSubject = H.hum(H.char(pl))
    return true
end

-- ---------------------------------------------------------------- 3.9 杂项
local Misc = { antiAfk = nil }
M.misc = Misc

function Misc.start()
    if Misc.antiAfk then return end
    Misc.antiAfk = LP.Idled:Connect(function()
        if not CFG.misc.antiAfk then return end
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
end

function Misc.stop()
    if Misc.antiAfk then
        Misc.antiAfk:Disconnect()
        Misc.antiAfk = nil
    end
end

-- ======================================================================
-- 4. API
-- ======================================================================
local API = {}
API.CFG = CFG
API.M = M
API.H = H

local listeners = {}
function API.onChange(fn)
    listeners[#listeners + 1] = fn
end

local function fire()
    for _, fn in ipairs(listeners) do pcall(fn) end
end

local function split(path)
    local section, key = tostring(path):match("^([%w_]+)%.([%w_]+)$")
    if not section or not key then return nil, nil end
    if type(CFG[section]) ~= "table" then return nil, nil end
    return CFG[section], key
end

function API.get(path)
    local section, key = split(path)
    if not section then return nil end
    return section[key]
end

function API.set(path, value)
    local section, key = split(path)
    if not section or section[key] == nil then return end
    section[key] = value
    if section == CFG.chams then Chams.repaint() end
    if section == CFG.aim then FovCircle.draw() end
    fire()
end

--- 按 UI 的 0..1 rel 写入数值字段
function API.setRel(path, rel, min, max, step)
    local v = min + H.clamp(rel, 0, 1) * (max - min)
    if step and step > 0 then v = math.floor(v / step + 0.5) * step end
    API.set(path, v)
    return v
end

API.save = saveCfg
API.load = loadCfg
API.teleport = Ply.teleport
API.look = Ply.look
API.spectate = Ply.spectate
API.playerNames = Ply.names
API.playerList = function()
    local out = {}
    for _, pl in ipairs(Players:GetPlayers()) do
        local hum = H.hum(H.char(pl))
        out[#out + 1] = {
            name = pl.Name,
            team = pl.Team and pl.Team.Name or "-",
            health = hum and math.floor(hum.Health) or 0,
            self = pl == LP,
        }
    end
    return out
end
API.repaintChams = Chams.repaint

-- ======================================================================
-- 5. 循环
-- ======================================================================
local loopConn
function API.start()
    if loopConn then return end
    loadCfg()
    Move.start()
    Misc.start()
    loopConn = RunService.RenderStepped:Connect(function()
        if CFG.chams.enabled then pcall(Chams.step) end
        if CFG.esp.enabled then pcall(Esp.step) end
        if CFG.aim.enabled then pcall(Aim.step) end
        if CFG.rage.enabled then pcall(Rage.step) end
        if CFG.trigger.enabled then pcall(Trigger.step) end
        pcall(Move.step)
        pcall(World.step)
        pcall(FovCircle.draw)
    end)
end

function API.stop()
    if loopConn then
        loopConn:Disconnect()
        loopConn = nil
    end
    for _, m in pairs(M) do
        if type(m) == "table" and m.stop then pcall(m.stop) end
    end
    for pl in pairs(Chams.tracker) do chamsRestore(pl) end
end

-- 角色重生后重新上色 + 清理残留
API.playerAddedConn = Players.PlayerAdded:Connect(function(pl)
    pl.CharacterAdded:Connect(function(char)
        task.wait(0.3)
        if CFG.chams.enabled and Chams.should(pl) then Chams.paint(pl) end
    end)
end)
for _, pl in ipairs(Players:GetPlayers()) do
    pcall(function()
        pl.CharacterAdded:Connect(function(char)
            task.wait(0.3)
            if CFG.chams.enabled and Chams.should(pl) then Chams.paint(pl) end
        end)
    end)
end

getgenv().NLUI_PRISON = API

return API

end)()
NL_API.load()

Pages = {}
NL_PAGES = Pages
Pages.Rage = {
	{ x = 167, y = 84, w = 281, h = 221, title = "MAIN", rows = {
		{ label = "Enabled", kind = "toggle", on = true },
		{ label = "Silent Aim", kind = "toggle", on = true, sub = {
			{ label = "Hitbox", kind = "select", value = "Head", options = { "Head", "Chest", "Stomach" } },
			{ label = "Smooth", kind = "slider", amount = 0.42, value = "42%",
				num = { min = 0, max = 100, value = 42, step = 1, decimals = 0, suffix = "%" } },
			{ label = "FOV", kind = "slider", amount = 0.32, value = "32%",
				num = { min = 1, max = 100, value = 32, step = 1, decimals = 0, suffix = "%" } },
			{ label = "Visible Check", kind = "toggle", on = true },
		} },
		{ label = "Automatic Fire", kind = "toggle", on = true },
		{ label = "Aim Through Walls", kind = "toggle", on = true, sub = {
			{ label = "穿透厚度", kind = "slider", amount = 0.25, value = "25",
				num = { min = 1, max = 50, value = 25, step = 1, decimals = 0, suffix = "cm" } },
			{ label = "自动墙体", kind = "toggle", on = false },
		} },
		{ label = "Refine Shot", kind = "select", value = "Latency", options = { "Latency", "Off", "Performance" } },
		{ label = "Field of View", kind = "slider", amount = 0.74, value = "180.0°",
			num = { min = 0, max = 180, value = 90, step = 1, decimals = 1, suffix = "°" } },
	} },
	{ x = 458, y = 84, w = 277, h = 221, title = "OTHER", rows = {
		{ label = "History", kind = "select", value = "Maximum", options = { "Maximum", "Minimum", "Off" } },
		{ label = "Delay Shot", kind = "select", value = "Damage", options = { "Damage", "Latency", "Off" } },
		{ label = "Remove Spread", kind = "select", value = "Full", options = { "Full", "Partial", "Off" } },
		{ label = "Duck Peek Assist", kind = "toggle", on = false },
		{ label = "Quick Peek Assist", kind = "toggle", on = false },
		{ label = "Double Tap", kind = "toggle", on = false },
	} },
	{ x = 167, y = 340, w = 281, h = 221, title = "SELECTION", rows = {
		{ label = "Prefer", kind = "select", value = "Damage", options = { "Damage", "Health", "Distance" } },
		{ label = "Hitboxes", kind = "multi", value = "Head, Chest, Stom", mask = 0x07,
			options = { "Head", "Chest", "Stomach", "Arms", "Legs", "Feet" } },
		{ label = "Hit Chance", kind = "slider", amount = 0.08, value = "0%",
			num = { min = 0, max = 100, value = 8, step = 1, decimals = 0, suffix = "%" } },
		{ label = "Min Damage", kind = "slider", amount = 0.86, value = "FL",
			num = { min = 0, max = 130, value = 112, step = 1, decimals = 0, suffix = "" } },
		{ label = "Quick Stop", kind = "toggle", on = false },
		{ label = "Quick Scope", kind = "toggle", on = false },
	} },
	{ x = 458, y = 340, w = 277, h = 221, title = "ANTI-AIM", rows = {
		{ label = "Enabled", kind = "toggle", on = true },
		{ label = "Suppress Breathing Animations", kind = "toggle", on = true },
		{ label = "Leg Movement", kind = "select", value = "Walking", options = { "Walking", "Running", "Static" } },
		{ label = "Pitch", kind = "chevron" },
		{ label = "Yaw", kind = "chevron" },
		{ label = "Mouse Override", kind = "chevron" },
	} },
}
Pages.Legit = {
	{ x = 167, y = 84, w = 281, h = 40, title = "MAIN", rows = {
		{ label = "Enabled", kind = "toggle", on = true },
	} },
	{ x = 167, y = 160, w = 281, h = 415, title = "AIMBOT", rows = {
		{ label = "Enabled", kind = "toggle", on = true },
		{ label = "Activation", kind = "select", value = "Assisted", options = { "Assisted", "Hold", "Toggle" } },
		{ label = "Conditions", kind = "multi", value = "Through Walls, Th", mask = 0x05,
			options = { "Through Walls", "Visible Only", "In Air", "On Ground" } },
		{ label = "Hitboxes", kind = "multi", value = "Head", mask = 0x01,
			options = { "Head", "Chest", "Stomach", "Arms", "Legs", "Feet" } },
		{ label = "Field of View", kind = "slider", amount = 0.14, value = "20u",
			num = { min = 0, max = 180, value = 20, step = 1, decimals = 0, suffix = "u" } },
		{ label = "Smoothing", kind = "slider", amount = 0.22, value = "50%",
			num = { min = 0, max = 100, value = 50, step = 1, decimals = 0, suffix = "%" } },
		{ label = "Reaction Time", kind = "slider", amount = 0.08, value = "0ms",
			num = { min = 0, max = 500, value = 0, step = 1, decimals = 0, suffix = "ms" } },
		{ label = "Min Damage", kind = "slider", amount = 0.68, value = "HP+1",
			num = { min = 0, max = 130, value = 101, step = 1, decimals = 0, suffix = "" } },
		{ label = "Recoil Control", kind = "toggle", on = false },
		{ label = "Quick Scope", kind = "toggle", on = false },
		{ label = "Quick Stop", kind = "toggle", on = false },
	} },
	{ x = 458, y = 84, w = 277, h = 297, title = "TRIGGERBOT", rows = {
		{ label = "Enabled", kind = "toggle", on = false },
		{ label = "Conditions", kind = "multi", value = "Through Walls, Th", mask = 0x05,
			options = { "Through Walls", "Visible Only", "In Air", "On Ground" } },
		{ label = "Hitboxes", kind = "multi", value = "Head, Chest, Stom", mask = 0x07,
			options = { "Head", "Chest", "Stomach", "Arms", "Legs", "Feet" } },
		{ label = "Hit Chance", kind = "slider", amount = 0.92, value = "Seed",
			num = { min = 0, max = 100, value = 92, step = 1, decimals = 0, suffix = "%" } },
		{ label = "Min Damage", kind = "slider", amount = 0.72, value = "HP+1",
			num = { min = 0, max = 130, value = 101, step = 1, decimals = 0, suffix = "" } },
		{ label = "Reaction Time", kind = "slider", amount = 0.08, value = "0ms",
			num = { min = 0, max = 300, value = 0, step = 1, decimals = 0, suffix = "ms" } },
		{ label = "Burst Time", kind = "slider", amount = 0.08, value = "50ms",
			num = { min = 0, max = 500, value = 50, step = 1, decimals = 0, suffix = "ms" } },
		{ label = "Quick Scope", kind = "toggle", on = false },
	} },
	{ x = 458, y = 413, w = 277, h = 148, title = "OTHER", rows = {
		{ label = "Visualize", kind = "toggle", on = false },
		{ label = "Automatic Weapons", kind = "toggle", on = false },
		{ label = "Standalone Recoil Control", kind = "toggle", on = false },
		{ label = "Randomize", kind = "select", value = "None", options = { "None", "Seed", "Random" } },
	} },
}
Pages.Players = {
	{ x = 177, y = 86, w = 300, h = 116, title = "ENEMY", rows = {
		{ label = "Enabled", kind = "toggle", on = true },
		{ label = "Offscreen Arrow", kind = "color", color = P.accent, on = true },
		{ label = "Sounds", kind = "color", color = P.accent, on = true },
	} },
	{ x = 177, y = 239, w = 300, h = 264, title = "ENEMY MODEL", rows = {
		{ label = "Player", kind = "select", value = "Water Flow", options = { "Water Flow", "Glass", "Solid" } },
		{ label = "Behind Walls", kind = "select", value = "Glow Outline", options = { "Glow Outline", "Solid", "Off" } },
		{ label = "On Shot", kind = "select", value = "Solid", options = { "Solid", "Glow", "Off" } },
		{ label = "History", kind = "select", value = "Solid", options = { "Solid", "Outline", "Off" } },
		{ label = "Ragdolls", kind = "disabled" },
		{ label = "Soul Particles", kind = "color", color = P.accent, on = true },
		{ label = "Glow", kind = "color", color = P.accent, on = true },
	} },
}
Pages.World = {
	{ x = 177, y = 84, w = 291, h = 221, title = "VIEW", rows = {
		{ label = "View Options", kind = "chevron" },
		{ label = "Scope Options", kind = "chevron" },
		{ label = "Viewmodel Options", kind = "chevron" },
		{ label = "Perspective Options", kind = "chevron" },
		{ label = "Unlock Spectating", kind = "select", value = "Perspective, Enem", options = { "Perspective", "Enemies", "All" } },
		{ label = "Visual Recoil", kind = "select", value = "No Shake, No Rec", options = { "No Shake", "No Recoil", "Off" } },
	} },
	{ x = 478, y = 84, w = 257, h = 221, title = "HUD", rows = {
		{ label = "Radar", kind = "select", value = "Reveal Enemies, R", options = { "Reveal Enemies", "Radar Only", "Off" } },
		{ label = "Scope Overlay", kind = "color", color = P.accent, on = true },
		{ label = "Inaccuracy Overlay", kind = "color", color = P.accent, on = true },
		{ label = "Death Notices", kind = "chevron" },
		{ label = "Scoreboard", kind = "chevron" },
		{ label = "Crosshairs", kind = "chevron" },
	} },
	{ x = 177, y = 350, w = 291, h = 221, title = "WORLD ESP", rows = {
		{ label = "Bomb", kind = "chevron" },
		{ label = "Weapons", kind = "chevron" },
		{ label = "Hostages", kind = "chevron" },
		{ label = "Grenades", kind = "chevron" },
		{ label = "Grenade Trajectory", kind = "toggle", on = true },
		{ label = "Grenade Proximity Warnings", kind = "toggle", on = true },
	} },
	{ x = 478, y = 350, w = 257, h = 221, title = "MISCELLANEOUS", rows = {
		{ label = "Windows", kind = "chevron" },
		{ label = "Removals", kind = "chevron" },
		{ label = "Ambience", kind = "chevron" },
		{ label = "Hit Marker", kind = "chevron" },
		{ label = "Bullet Tracers", kind = "chevron" },
		{ label = "Bullet Impacts", kind = "color", color = P.accent, on = true },
	} },
}
Pages.Miscellaneous = {
	{ x = 171, y = 80, w = 300, h = 304, title = "MOVEMENT", rows = {
		{ label = "Bunny Hop", kind = "toggle", on = true },
		{ label = "Air Strafe", kind = "toggle", on = true },
		{ label = "Jump Bug", kind = "toggle", on = true },
		{ label = "Standalone Quick Stop", kind = "toggle", on = true },
		{ label = "Strafe Assist", kind = "toggle", on = true },
		{ label = "Edge Jump", kind = "toggle", on = false },
		{ label = "Slow Walk", kind = "toggle", on = false },
		{ label = "Fast Ladder", kind = "toggle", on = true },
	} },
	{ x = 481, y = 80, w = 254, h = 304, title = "FEATURES", rows = {
		{ label = "Quick Switch", kind = "toggle", on = true },
		{ label = "Super Toss", kind = "toggle", on = false },
		{ label = "Prevent AFK Kick", kind = "toggle", on = true },
		{ label = "Hit Sound", kind = "toggle", on = true },
		{ label = "Automatic Purchase", kind = "toggle", on = false },
		{ label = "Automatic Grenade Release", kind = "toggle", on = true },
		{ label = "Auto-Accept Matchmaking", kind = "toggle", on = true },
		{ label = "Log Events", kind = "select", value = "Damage Dealt, Da", options = { "Damage Dealt", "Damage Taken", "All" } },
	} },
}
-- ============================================================
-- 新增页：Prison（承载其余参数）+ 原有控件的接线
-- ============================================================
-- Prison Life 附加页（不改动原有 Rage / Legit / Players / World / Inventory / Misc 布局）
-- 这里只承载「其余参数」：上色细节、ESP、移动、世界、玩家工具、配置
local API = NL_API
local CFG = API.CFG

local function rel(relValue, min, max, step)
	local v = min + math.clamp(relValue, 0, 1) * (max - min)
	if step and step > 0 then
		v = math.floor(v / step + 0.5) * step
	end
	return v
end

local function amountOf(value, min, max)
	return math.clamp((value - min) / (max - min), 0, 1)
end

-- 8 行 => 8*37+4 = 300
Pages.Prison = {
	{ x = 167, y = 84, w = 281, h = 300, title = "CHAMS", rows = {
		{ label = "Enabled", kind = "toggle", on = CFG.chams.enabled, cb = function(v)
			API.set("chams.enabled", v)
		end },
		{ label = "Scope", kind = "select", value = "Enemies", options = { "Enemies", "Everyone", "Self" },
			cb = function(i)
				API.set("chams.scope", ({ "enemies", "everyone", "self" })[i] or "enemies")
			end },
		{ label = "Style", kind = "select", value = "Solid", options = { "Solid", "Glass", "Glow" },
			cb = function(i)
				API.set("chams.body", ({ "solid", "glass", "glow" })[i] or "solid")
			end },
		{ label = "Team Color", kind = "toggle", on = CFG.chams.teamColor, cb = function(v)
			API.set("chams.teamColor", v)
		end },
		{ label = "Hide Accessories", kind = "toggle", on = CFG.chams.hideAccessories, cb = function(v)
			API.set("chams.hideAccessories", v)
		end },
		{ label = "Opacity", kind = "slider", amount = amountOf(CFG.chams.opacity, 0, 100),
			value = tostring(math.floor(CFG.chams.opacity)) .. "%",
			num = { min = 0, max = 100, value = CFG.chams.opacity, step = 1, decimals = 0, suffix = "%" },
			cb = function(r) API.setRel("chams.opacity", r, 0, 100, 1) end },
		{ label = "Refresh", kind = "slider", amount = amountOf(CFG.chams.refresh, 0.1, 3),
			value = string.format("%.1fs", CFG.chams.refresh),
			num = { min = 0.1, max = 3, value = CFG.chams.refresh, step = 0.1, decimals = 1, suffix = "s" },
			cb = function(r) API.set("chams.refresh", rel(r, 0.1, 3, 0.1)) end },
		{ label = "Enemy Color", kind = "color", color = CFG.chams.enemy, on = true,
			colorCallback = function(c) API.set("chams.enemy", c) end },
	} },
	{ x = 458, y = 84, w = 277, h = 300, title = "ESP", rows = {
		{ label = "Enabled", kind = "toggle", on = CFG.esp.enabled, cb = function(v)
			API.set("esp.enabled", v)
		end },
		{ label = "Box", kind = "toggle", on = CFG.esp.box, cb = function(v) API.set("esp.box", v) end },
		{ label = "Name", kind = "toggle", on = CFG.esp.name, cb = function(v) API.set("esp.name", v) end },
		{ label = "Health Bar", kind = "toggle", on = CFG.esp.health, cb = function(v) API.set("esp.health", v) end },
		{ label = "Distance", kind = "toggle", on = CFG.esp.distance, cb = function(v) API.set("esp.distance", v) end },
		{ label = "Max Distance", kind = "slider", amount = amountOf(CFG.esp.maxDistance, 50, 2000),
			value = tostring(math.floor(CFG.esp.maxDistance)),
			num = { min = 50, max = 2000, value = CFG.esp.maxDistance, step = 25, decimals = 0, suffix = "m" },
			cb = function(r) API.setRel("esp.maxDistance", r, 50, 2000, 25) end },
		{ label = "Opacity", kind = "slider", amount = amountOf(CFG.esp.opacity, 10, 100),
			value = tostring(math.floor(CFG.esp.opacity)) .. "%",
			num = { min = 10, max = 100, value = CFG.esp.opacity, step = 1, decimals = 0, suffix = "%" },
			cb = function(r) API.setRel("esp.opacity", r, 10, 100, 1) end },
		{ label = "ESP Color", kind = "color", color = CFG.esp.color, on = true,
			colorCallback = function(c) API.set("esp.color", c) end },
	} },
	{ x = 167, y = 416, w = 281, h = 152, title = "MOVEMENT", rows = {
		{ label = "Speed", kind = "toggle", on = CFG.movement.speed, cb = function(v)
			API.set("movement.speed", v)
		end },
		{ label = "Speed Value", kind = "slider", amount = amountOf(CFG.movement.speedValue, 16, 120),
			value = tostring(math.floor(CFG.movement.speedValue)),
			num = { min = 16, max = 120, value = CFG.movement.speedValue, step = 1, decimals = 0, suffix = "" },
			cb = function(r) API.setRel("movement.speedValue", r, 16, 120, 1) end },
		{ label = "Jump", kind = "toggle", on = CFG.movement.jump, cb = function(v)
			API.set("movement.jump", v)
		end },
		{ label = "No Clip", kind = "toggle", on = CFG.movement.noclip, cb = function(v)
			API.set("movement.noclip", v)
		end },
	} },
	{ x = 458, y = 416, w = 277, h = 189, title = "WORLD / PLAYER", rows = {
		{ label = "Fullbright", kind = "toggle", on = CFG.world.fullbright, cb = function(v)
			API.set("world.fullbright", v)
		end },
		{ label = "No Fog", kind = "toggle", on = CFG.world.noFog, cb = function(v)
			API.set("world.noFog", v)
		end },
		{ label = "Anti AFK", kind = "toggle", on = CFG.misc.antiAfk, cb = function(v)
			API.set("misc.antiAfk", v)
		end },
		{ label = "Attack Check", kind = "toggle", on = CFG.rage.attackCheck, cb = function(v)
			API.set("rage.attackCheck", v)
		end },
		{ label = "Save Config", kind = "button", value = "",
			cb = function() API.save() return "Saved" end },
	} },
}

-- 把你原有页面的控件接到 Prison Life 引擎上（不改布局、不删任何行）
-- 只在行上补 cb，UI 结构与文案保持原样。
local API = NL_API
local CFG = API.CFG

-- 在指定页面 / 卡片标题下找一行并挂回调
local function bind(pageKey, cardTitle, label, makeCb)
	for _, card in ipairs(Pages[pageKey] or {}) do
		if card.title == cardTitle then
			for _, row in ipairs(card.rows or {}) do
				if row.label == label then
					row.cb = makeCb(row)
					return true
				end
			end
		end
	end
	return false
end

-- ---------------------------------------------------------------- RAGE（ragebot）
bind("Rage", "MAIN", "Enabled", function()
	return function(v) API.set("rage.enabled", v) end
end)
bind("Rage", "MAIN", "Silent Aim", function()
	return function(v) API.set("rage.silent", v) end
end)
bind("Rage", "MAIN", "Automatic Fire", function()
	return function(v) API.set("rage.autofire", v) end
end)
bind("Rage", "MAIN", "Aim Through Walls", function()
	return function(v) API.set("rage.walls", v) end
end)
bind("Rage", "MAIN", "Field of View", function()
	return function(r) API.setRel("rage.fov", r, 0, 360, 1) end
end)
bind("Rage", "SELECTION", "Hitboxes", function()
	return function(mask) API.set("rage.hitboxMask", mask) end
end)
bind("Rage", "SELECTION", "Hit Chance", function()
	return function(r) API.setRel("rage.hitchance", r, 0, 100, 1) end
end)
bind("Rage", "SELECTION", "Prefer", function()
	return function(i)
		API.set("rage.prefer", ({ "Damage", "Health", "Distance" })[i] or "Damage")
	end
end)
bind("Rage", "OTHER", "Remove Spread", function()
	return function(i) API.set("rage.nospread", i ~= 3) end
end)
bind("Rage", "OTHER", "Delay Shot", function()
	return function(i)
		API.set("rage.delayShot", ({ "Damage", "Latency", "Off" })[i] or "Damage")
	end
end)
bind("Rage", "ANTI-AIM", "Enabled", function()
	return function(v) API.set("rage.antiaim", v) end
end)

-- ---------------------------------------------------------------- PLAYERS（人物上色）
bind("Players", "ENEMY", "Enabled", function()
	return function(v) API.set("chams.enabled", v) end
end)
bind("Players", "ENEMY MODEL", "Player", function()
	return function(i)
		-- Water Flow / Glass / Solid
		API.set("chams.body", ({ "glow", "glass", "solid" })[i] or "solid")
	end
end)
bind("Players", "ENEMY MODEL", "Behind Walls", function()
	return function(i)
		-- Glow Outline / Solid / Off
		API.set("chams.throughWalls", ({ "glow", "solid", "off" })[i] or "glow")
	end
end)
bind("Players", "ENEMY MODEL", "Glow", function()
	return function(v) API.set("chams.glow", v) end
end)
-- Glow 行的色块 -> 敌人颜色
for _, card in ipairs(Pages.Players or {}) do
	for _, row in ipairs(card.rows or {}) do
		if row.kind == "color" and row.label == "Glow" then
			row.colorCallback = function(c) API.set("chams.enemy", c) end
		end
		if row.kind == "color" and row.label == "Offscreen Arrow" then
			row.colorCallback = function(c) API.set("esp.color", c) end
		end
		if row.kind == "color" and row.label == "Soul Particles" then
			row.colorCallback = function(c) API.set("chams.team", c) end
		end
	end
end

-- ---------------------------------------------------------------- LEGIT（平滑自瞄 / 扳机）
bind("Legit", "AIMBOT", "Enabled", function()
	return function(v) API.set("aim.enabled", v) end
end)
bind("Legit", "AIMBOT", "Field of View", function()
	return function(r) API.setRel("aim.fov", r, 0, 360, 1) end
end)
bind("Legit", "AIMBOT", "Smoothing", function()
	return function(r) API.setRel("aim.smooth", r, 1, 100, 1) end
end)
bind("Legit", "AIMBOT", "Hitboxes", function()
	return function(mask)
		-- 取最先勾选的一项作为命中框
		local names = { "Head", "Torso", "Torso", "Left Arm", "Left Leg", "Left Leg" }
		for i = 1, 6 do
			if bit32 and bit32.band(mask, bit32.lshift(1, i - 1)) ~= 0 then
				API.set("aim.hitbox", names[i])
				return
			end
		end
	end
end)
bind("Legit", "TRIGGERBOT", "Enabled", function()
	return function(v) API.set("trigger.enabled", v) end
end)
bind("Legit", "TRIGGERBOT", "Hitboxes", function()
	return function(mask)
		local names = { "Head", "Torso", "Torso", "Left Arm", "Left Leg", "Left Leg" }
		for i = 1, 6 do
			if bit32 and bit32.band(mask, bit32.lshift(1, i - 1)) ~= 0 then
				API.set("trigger.hitbox", names[i])
				return
			end
		end
	end
end)
bind("Legit", "TRIGGERBOT", "Burst Time", function()
	return function(r) API.setRel("trigger.delay", r, 0, 0.5, 0.005) end
end)

-- ---------------------------------------------------------------- MISCELLANEOUS（移动 / 杂项）
bind("Miscellaneous", "MOVEMENT", "Bunny Hop", function()
	return function(v) API.set("movement.bhop", v) end
end)
bind("Miscellaneous", "MOVEMENT", "Slow Walk", function()
	return function(v) API.set("movement.slowWalk", v) end
end)
bind("Miscellaneous", "MOVEMENT", "Fast Ladder", function()
	return function(v) API.set("movement.fastLadder", v) end
end)
bind("Miscellaneous", "FEATURES", "Prevent AFK Kick", function()
	return function(v) API.set("misc.antiAfk", v) end
end)

-- ---------------------------------------------------------------- WORLD（去雾 / 全亮）
bind("World", "MISCELLANEOUS", "Removals", function()
	return function()
		API.set("world.noSmoke", true)
		API.set("world.noFog", true)
	end
end)
bind("World", "MISCELLANEOUS", "Ambience", function()
	return function()
		API.set("world.fullbright", true)
	end
end)

function soldier(parent, cx, cy)
	local dark = Color3.fromRGB(39, 49, 77)
	local edge = Color3.fromRGB(211, 220, 255)
	local blue = Color3.fromRGB(91, 133, 255)
	local head = dot(parent, cx - 22, cy - 142, 44, dark)
	stroke(head, edge, 2, 0.08)
	local body = frame(parent, cx - 28, cy - 96, 56, 71, dark, 0, 12)
	stroke(body, blue, 3, 0.18)
	local armL = bar(parent, cx - 30, cy - 80, 34, 12, dark, -50)
	armL.Size = UDim2.fromOffset(34, 12)
	corner(armL, 6)
	local armR = bar(parent, cx + 6, cy - 66, 34, 12, dark, 32)
	corner(armR, 6)
	corner(frame(parent, cx - 23, cy - 25, 19, 85, dark, 0, 8), 8)
	corner(frame(parent, cx + 4, cy - 25, 19, 85, dark, 0, 8), 8)
	local gun = bar(parent, cx - 55, cy - 45, 118, 6, edge, -6)
	gun.Size = UDim2.fromOffset(118, 6)
	frame(parent, cx + 30, cy - 58, 47, 9, blue, 0, 2)
	ring(parent, cx - 10, cy - 130, 20, blue, 2, 0.1)
	bar(parent, cx - 22, cy - 117, 44, 2.4, blue, 0, 0.1)
	bar(parent, cx - 35, cy + 61, 31, 3, edge, 0, 0.05)
	bar(parent, cx + 4, cy + 61, 31, 3, edge, 0, 0.05)
end
function buildPlayersPreview(parent)
	label(parent, 557, 75, 90, 16, "Enemies", 14, Color3.fromRGB(111, 167, 255))
	local u = frame(parent, 654, 76, 13, 13, Color3.new(1, 1, 1), 1)
	Icons.user(u, Color3.fromRGB(180, 184, 194))
	local l = frame(parent, 706, 76, 13, 13, Color3.new(1, 1, 1), 1)
	Icons.list(l, Color3.fromRGB(180, 184, 194))
	label(parent, 609, 112, 40, 12, "C4", 9, P.healthRed)
	label(parent, 596, 126, 80, 12, "Neverlose", 10, P.healthYellow)
	label(parent, 612, 139, 40, 12, "65%", 9, Color3.fromRGB(227, 231, 241))
	soldier(parent, 626, 438)
	bar(parent, 535, 495, 180, 4, P.track, 0, 0)
	bar(parent, 535, 495, 105, 4, P.accent, 0, 0)
end
function weaponCell(parent, x, y, w, h, kind, accent)
	local cell = frame(parent, x, y, w, h, Color3.fromRGB(24, 31, 45), 0.08, 9)
	stroke(cell, Color3.fromRGB(35, 45, 62), 1, 0)
	bar(cell, 0, h - 3, w, 3, accent, 0, 0)
	local s = math.min(w / 121, h / 91)
	local gun, shade = P.gunLight, P.gunDark
	if kind % 3 == 0 then
		frame(cell, 25 * s, 28 * s, 61 * s, 8 * s, gun, 0, 2 * s)
		frame(cell, 67 * s, 35 * s, 10 * s, 25 * s, shade, 0, 2 * s)
		frame(cell, 32 * s, 35 * s, 9 * s, 20 * s, gun, 0, 2 * s)
	elseif kind % 3 == 1 then
		bar(cell, 18 * s, 55 * s, 76 * s, 7 * s, gun, -16)
		frame(cell, 70 * s, 27 * s, 20 * s, 8 * s, shade, 0, 2 * s)
	else
		frame(cell, 16 * s, 32 * s, 80 * s, 7 * s, gun, 0, 2 * s)
		frame(cell, 30 * s, 39 * s, 12 * s, 22 * s, shade, 0, 2 * s)
		frame(cell, 67 * s, 39 * s, 10 * s, 18 * s, gun, 0, 2 * s)
	end
end
function buildInventory(parent)
	frame(parent, 159, 57, 588, 518, Color3.fromRGB(17, 27, 42), 0.39, 0)
	local chip = frame(parent, 185, 66, 101, 25, Color3.fromRGB(20, 34, 50), 0, 8)
	label(chip, 0, 0, 101, 25, "CT Loadout", 14, Color3.fromRGB(138, 192, 255), nil, Enum.TextXAlignment.Center)
	soldier(parent, 264, 388)
	local accents = {
		Color3.fromRGB(235, 237, 239),
		Color3.fromRGB(171, 70, 255),
		Color3.fromRGB(75, 116, 255),
		Color3.fromRGB(226, 43, 192),
		Color3.fromRGB(251, 65, 83),
		Color3.fromRGB(134, 72, 255),
	}
	for r = 0, 4 do
		for c = 0, 2 do
			weaponCell(parent, 390 + c * 116, 88 + r * 96, 108, 91,
				r * 3 + c, accents[(r + c) % 6 + 1])
		end
	end
	label(parent, 424, 67, 90, 16, "Pistols", 14, Color3.fromRGB(205, 209, 219))
	label(parent, 536, 67, 90, 16, "Mid-Tier", 14, Color3.fromRGB(205, 209, 219))
	label(parent, 655, 67, 90, 16, "Rifles", 14, Color3.fromRGB(205, 209, 219))
	for r = 0, 1 do
		for c = 0, 2 do
			weaponCell(parent, 171 + c * 65, 470 + r * 51, 55, 47,
				r * 3 + c, accents[(r + c + 2) % 6 + 1])
		end
	end
end
function makeGui()
	local sg = Instance.new("ScreenGui")
	sg.Name = "NeverloseUI"
	sg.ResetOnSpawn = false
	sg.IgnoreGuiInset = true
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	sg.DisplayOrder = 999
	local parent = nil
	pcall(function() parent = gethui and gethui() end)
	if not parent then
		local ok = pcall(function() parent = game:GetService("CoreGui") end)
		if not ok or not parent then parent = LocalPlayer:WaitForChild("PlayerGui") end
	end
	local attached = pcall(function() sg.Parent = parent end)
	if not attached then
		sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end
	return sg
end
gui = makeGui()
viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
function computeScale(vp)
	return math.clamp(math.min(vp.X / 820, vp.Y / 800), 0.42, 1.0)
end
uiScaleValue = computeScale(viewport)
canvas = frame(gui, 0, 0, W, H, P.shell, 1)
canvas.BackgroundTransparency = 1
canvas.ZIndex = 1
BINDS = {}
keybindPopup = nil
function closeKeybind()
	if keybindPopup then
		local p = keybindPopup
		keybindPopup = nil
		if p.scrim then p.scrim:Destroy() end
		if p.panel then p.panel:Destroy() end
	end
end
function openKeybindPopup(anchor, labelText, chip)
	closeKeybind()
	closePopup()
	local sc = canvas:FindFirstChildOfClass("UIScale").Scale
	local ax = (anchor.AbsolutePosition.X - canvas.AbsolutePosition.X) / sc
	local ay = (anchor.AbsolutePosition.Y - canvas.AbsolutePosition.Y) / sc
	local w, h = 216, 88
	local px = math.clamp(ax + 10, 10, W - w - 10)
	local py = math.clamp(ay + 4, 10, H - h - 10)
	local scrim = mk("TextButton", canvas, 0, 0, W, H)
	scrim.BackgroundTransparency = 1
	scrim.Text = ""
	scrim.AutoButtonColor = false
	scrim.ZIndex = 39
	scrim.MouseButton1Click:Connect(closeKeybind)
	local panel = mk("TextButton", canvas, px, py, w, h, Color3.fromRGB(20, 20, 29), 0.04)
	panel.AutoButtonColor = false
	panel.Text = ""
	corner(panel, 12)
	panel.ZIndex = 41
	stroke(panel, Color3.fromRGB(57, 61, 76), 1, 0.2)
	label(panel, 14, 10, w - 28, 18, T(labelText), 13, Color3.fromRGB(214, 217, 226))
	local keyText = label(panel, 14, 31, w - 28, 24, BINDS[labelText] or "None", 16,
		P.accentBright, Enum.Font.GothamBold)
	label(panel, 14, 61, w - 28, 16, "Press any key  ·  右键清除", 10,
		Color3.fromRGB(120, 124, 136))
	local function setBind(key)
		BINDS[labelText] = key
		keyText.Text = key or "None"
		if chip and chip.Parent then
			chip.Text = key or ""
		end
	end
	panel.MouseButton2Click:Connect(function()
		setBind(nil)
	end)
	keybindPopup = { panel = panel, scrim = scrim, setBind = setBind }
	panel.BackgroundTransparency = 1
	panel.Position = UDim2.fromOffset(px, py + 4)
	tw(panel, { BackgroundTransparency = 0.04, Position = UDim2.fromOffset(px, py) },
		0.14, Enum.EasingStyle.Cubic)
end
UserInput.InputBegan:Connect(function(input)
	if not keybindPopup then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		closeKeybind()
		return
	end
	if input.KeyCode ~= Enum.KeyCode.Unknown then
		if input.KeyCode == Enum.KeyCode.Backspace then
			keybindPopup.setBind(nil)
		else
			keybindPopup.setBind(input.KeyCode.Name)
		end
		closeKeybind()
	end
end)
rowMenu = nil
function closeRowMenu()
	if rowMenu then
		local m = rowMenu
		rowMenu = nil
		if m.scrim then m.scrim:Destroy() end
		if m.panel then m.panel:Destroy() end
	end
end
function openRowMenu(anchor, labelText, chip)
	closeRowMenu()
	closeKeybind()
	closePopup()
	local sc = canvas:FindFirstChildOfClass("UIScale").Scale
	local m = UserInput:GetMouseLocation()
	local ax = (m.X - canvas.AbsolutePosition.X) / sc
	local ay = (m.Y - canvas.AbsolutePosition.Y) / sc
	local w, rowH = 176, 32
	local h = rowH * 2 + 10
	local px = math.clamp(ax + 6, 8, W - w - 8)
	local py = math.clamp(ay + 6, 8, H - h - 8)
	local scrim = mk("TextButton", canvas, 0, 0, W, H)
	scrim.BackgroundTransparency = 1
	scrim.Text = ""
	scrim.AutoButtonColor = false
	scrim.ZIndex = 39
	scrim.MouseButton1Click:Connect(closeRowMenu)
	scrim.MouseButton2Click:Connect(closeRowMenu)
	local panel = mk("TextButton", canvas, px, py, w, h, Color3.fromRGB(19, 19, 27), 0.03)
	panel.AutoButtonColor = false
	panel.Text = ""
	corner(panel, 10)
	panel.ZIndex = 41
	stroke(panel, Color3.fromRGB(48, 51, 64), 1, 0.25)
	rowMenu = { panel = panel, scrim = scrim }
	local function addRow(index, text, color, drawIcon, onClick)
		local ry = 5 + (index - 1) * rowH
		local b = mk("TextButton", panel, 4, ry, w - 8, rowH)
		b.BackgroundTransparency = 1
		b.Text = ""
		b.AutoButtonColor = false
		b.ZIndex = 42
		local hl = frame(b, 0, 0, w - 8, rowH, Color3.new(1, 1, 1), 1, 7)
		hl.ZIndex = 41
		local iconBox = frame(b, 10, rowH / 2 - 6, 12, 12, Color3.new(1, 1, 1), 1)
		iconBox.ZIndex = 43
		drawIcon(iconBox, color)
		local txt = label(b, 32, 0, w - 44, rowH, text, 13, color)
		txt.ZIndex = 43
		b.MouseEnter:Connect(function()
			tw(hl, { BackgroundTransparency = 0.94 }, 0.1)
		end)
		b.MouseLeave:Connect(function()
			tw(hl, { BackgroundTransparency = 1 }, 0.1)
		end)
		b.MouseButton1Click:Connect(onClick)
	end
	local function iconPlus(parent, color)
		ring(parent, 1, 1, 10, color, 1.2)
		bar(parent, 5.6, 3, 1.2, 6, color)
		bar(parent, 3, 5.6, 6, 1.2, color)
	end
	local function iconReset(parent, color)
		ring(parent, 1, 1, 10, color, 1.2)
		arm(parent, 10.2, 2.2, 4, 1.4, -35, color)
		arm(parent, 10.2, 5, 4, 1.4, 35, color)
	end
	addRow(1, "New Hotkey", Color3.fromRGB(206, 209, 220), iconPlus, function()
		closeRowMenu()
		openHotkeyEditor(anchor, labelText, chip, px)
	end)
	addRow(2, "Reset", Color3.fromRGB(255, 108, 118), iconReset, function()
		BINDS[labelText] = nil
		if chip and chip.Parent then
			chip.Text = ""
		end
		closeRowMenu()
	end)
	panel.BackgroundTransparency = 1
	panel.Position = UDim2.fromOffset(px, py - 4)
	tw(panel, { BackgroundTransparency = 0.03, Position = UDim2.fromOffset(px, py) },
		0.12, Enum.EasingStyle.Cubic)
end
HOTKEYS = {}
hotkeyPanel = nil
function closeHotkeyEditor()
	if hotkeyPanel then
		local p = hotkeyPanel
		hotkeyPanel = nil
		if p.scrim then p.scrim:Destroy() end
		if p.panel then p.panel:Destroy() end
	end
end
HK_PINK = Color3.fromRGB(232, 121, 249)
HK_MODES = { "Toggle", "Hold", "Always" }
function openHotkeyEditor(anchor, labelText, chip, baseX)
	closeHotkeyEditor()
	closeRowMenu()
	local cfg = HOTKEYS[labelText]
	if not cfg then
		cfg = { mode = 1, enabled = false, visible = false }
		HOTKEYS[labelText] = cfg
	end
	local w, rowH = 236, 30
	local h = 38 + rowH * 4 + 10
	local px = math.clamp((baseX or 160) + 184, 8, W - w - 8)
	local py = math.clamp(anchor.AbsolutePosition.Y - canvas.AbsolutePosition.Y, 8, H - h - 8)
	local scrim = mk("TextButton", canvas, 0, 0, W, H)
	scrim.BackgroundTransparency = 1
	scrim.Text = ""
	scrim.AutoButtonColor = false
	scrim.ZIndex = 39
	scrim.MouseButton1Click:Connect(closeHotkeyEditor)
	local panel = mk("TextButton", canvas, px, py, w, h, Color3.fromRGB(19, 19, 27), 0.03)
	panel.AutoButtonColor = false
	panel.Text = ""
	corner(panel, 12)
	panel.ZIndex = 44
	stroke(panel, Color3.fromRGB(48, 51, 64), 1, 0.25)
	hotkeyPanel = { panel = panel, scrim = scrim }
	local head = mk("TextButton", panel, 0, 0, w, 38)
	head.BackgroundTransparency = 1
	head.Text = ""
	head.AutoButtonColor = false
	head.ZIndex = 45
	local headIcon = frame(head, 12, 13, 12, 12, Color3.new(1, 1, 1), 1)
	frame(headIcon, 0, 3, 12, 7, Color3.fromRGB(200, 203, 214), 0, 2)
	dot(headIcon, 3, 5, 1.4, Color3.fromRGB(19, 19, 27))
	dot(headIcon, 6, 5, 1.4, Color3.fromRGB(19, 19, 27))
	dot(headIcon, 9, 5, 1.4, Color3.fromRGB(19, 19, 27))
	label(head, 32, 0, 100, 38, "按键", 13, Color3.fromRGB(214, 217, 226))
	label(head, 96, 0, 96, 38, BINDS[labelText] or "None", 13,
		Color3.fromRGB(120, 124, 136), nil, Enum.TextXAlignment.Right)
	head.MouseEnter:Connect(function()
		tw(head, { BackgroundTransparency = 0.95 }, 0.1)
	end)
	head.MouseLeave:Connect(function()
		tw(head, { BackgroundTransparency = 1 }, 0.1)
	end)
	head.MouseButton1Click:Connect(function()
		closeHotkeyEditor()
		openKeybindPopup(anchor, labelText, chip)
	end)
	bar(panel, 10, 37, w - 20, 1, Color3.fromRGB(38, 41, 52))
	local function row(index, text, drawIcon)
		local ry = 42 + (index - 1) * rowH
		local r = mk("TextButton", panel, 4, ry, w - 8, rowH)
		r.BackgroundTransparency = 1
		r.Text = ""
		r.AutoButtonColor = false
		r.ZIndex = 45
		local ib = frame(r, 10, rowH / 2 - 6, 12, 12, Color3.new(1, 1, 1), 1)
		ib.ZIndex = 46
		drawIcon(ib)
		label(r, 32, 0, 110, rowH, text, 13, Color3.fromRGB(196, 199, 210)).ZIndex = 46
		return r
	end
	local modeRow = row(1, "模式", function(p)
		bar(p, 0, 2.5, 12, 1.4, Color3.fromRGB(178, 182, 194))
		bar(p, 0, 6.2, 12, 1.4, Color3.fromRGB(178, 182, 194), 0, 0.4)
		bar(p, 0, 9.9, 12, 1.4, Color3.fromRGB(178, 182, 194), 0, 0.4)
	end)
	modeRow.ZIndex = 45
	local pill = mk("TextButton", modeRow, w - 138, 4, 108, 22, HK_PINK, 0.82)
	corner(pill, 11)
	pill.AutoButtonColor = false
	pill.Text = ""
	pill.ZIndex = 46
	dot(pill, 8, 8, 6, HK_PINK)
	local pillText = label(pill, 19, 0, 82, 22, HK_MODES[cfg.mode], 12,
		Color3.fromRGB(248, 220, 255), Enum.Font.GothamBold)
	pillText.ZIndex = 47
	pill.MouseButton1Click:Connect(function()
		cfg.mode = cfg.mode % #HK_MODES + 1
		pillText.Text = HK_MODES[cfg.mode]
	end)
	local enRow = row(2, "已启用", function(p)
		ring(p, 1, 3, 8, Color3.fromRGB(178, 182, 194), 1.2)
		arm(p, 5, 7, 4, 1.2, 45, Color3.fromRGB(178, 182, 194))
	end)
	enRow.ZIndex = 45
	local visRow = row(3, "可见", function(p)
		local e = frame(p, 0, 3, 12, 6, Color3.fromRGB(178, 182, 194), 1, 3)
		stroke(e, Color3.fromRGB(178, 182, 194), 1.1)
		dot(p, 4.5, 4.5, 3, Color3.fromRGB(178, 182, 194))
	end)
	visRow.ZIndex = 45
	local function miniToggle(parent, y, on, cb)
		local track = frame(parent, w - 46, y, 29, 18, P.toggleOff, 0, 9)
		track.ZIndex = 46
		local knob = dot(track, on and 13 or 2, 2, 14, on and P.toggleKnobOn or P.toggleKnob)
		knob.ZIndex = 47
		local hit = mk("TextButton", parent, w - 60, y - 6, 46, 30)
		hit.BackgroundTransparency = 1
		hit.Text = ""
		hit.AutoButtonColor = false
		hit.ZIndex = 48
		local val = on
		hit.MouseButton1Click:Connect(function()
			val = not val
			tw(track, { BackgroundColor3 = val and P.accent or P.toggleOff }, 0.15)
			tw(knob, {
				Position = UDim2.fromOffset(val and 13 or 2, 2),
				BackgroundColor3 = val and P.toggleKnobOn or P.toggleKnob,
			}, 0.15)
			if cb then cb(val) end
		end)
	end
	miniToggle(enRow, 6, cfg.enabled, function(v)
		cfg.enabled = v
	end)
	miniToggle(visRow, 6, cfg.visible, function(v)
		cfg.visible = v
	end)
	local delRow = row(4, "删除", function(p)
		frame(p, 1, 2, 10, 9, Color3.fromRGB(255, 108, 118), 0, 1.5)
		bar(p, 0, 1, 12, 1.4, Color3.fromRGB(255, 108, 118))
		bar(p, 4.5, 0, 3, 1.4, Color3.fromRGB(255, 108, 118))
	end)
	delRow.ZIndex = 45
	local delText = delRow:FindFirstChildOfClass("TextLabel")
	if delText then
		delText.TextColor3 = Color3.fromRGB(255, 108, 118)
	end
	delRow.MouseButton1Click:Connect(function()
		BINDS[labelText] = nil
		HOTKEYS[labelText] = nil
		if chip and chip.Parent then
			chip.Text = ""
		end
		closeHotkeyEditor()
	end)
	panel.BackgroundTransparency = 1
	panel.Position = UDim2.fromOffset(px, py + 6)
	tw(panel, { BackgroundTransparency = 0.03, Position = UDim2.fromOffset(px, py) },
		0.14, Enum.EasingStyle.Cubic)
end
scaleObj = Instance.new("UIScale")
scaleObj.Scale = uiScaleValue
scaleObj.Parent = canvas
startX = math.floor((viewport.X - W * uiScaleValue) / 2)
startY = math.floor((viewport.Y - H * uiScaleValue) / 2) + MENU_DROP
canvas.Position = UDim2.fromOffset(startX, startY)
menuFade = Instance.new("CanvasGroup")
menuFade.Name = "MenuFade"
menuFade.Size = UDim2.new(1, 0, 1, 0)
menuFade.Position = UDim2.fromOffset(0, 0)
menuFade.BackgroundTransparency = 1
menuFade.GroupTransparency = 0
menuFade.ZIndex = 1
menuFade.Parent = gui
canvas.Parent = menuFade
menuZoom = 1
function menuScale()
	return uiScaleValue * menuZoom
end
function applyMenuZoom(z)
	menuZoom = math.clamp(tonumber(z) or 1, 0.6, 2)
	local vp = workspace.CurrentCamera.ViewportSize
	local fit = math.min(vp.X / W, vp.Y / H) * 0.96
	local s = math.clamp(uiScaleValue * menuZoom, 0.35, math.max(0.5, fit * 1.35))
	scaleObj.Scale = s
	startX = math.floor((vp.X - W * s) / 2)
	startY = math.floor((vp.Y - H * s) / 2) + MENU_DROP
	canvas.Position = UDim2.fromOffset(startX, startY)
end
shellShadow = softShadow(canvas, 0, 0, SHELL_W, SHELL_H, 14, 22, 0.06, 0)
shell = frame(canvas, 0, 0, SHELL_W, SHELL_H, P.shell, 0.13, 14)
shell.ClipsDescendants = true
stroke(shell, P.border, 1, 0.55)
resizeGrip = mk("TextButton", shell, SHELL_W - 40, SHELL_H - 40, 40, 40)
resizeGrip.BackgroundTransparency = 1
resizeGrip.Text = ""
resizeGrip.AutoButtonColor = false
resizeGrip.ZIndex = 9
gripLines = frame(resizeGrip, 15, 15, 16, 16, Color3.new(1, 1, 1), 1)
gripA = bar(gripLines, 2, 9, 11, 1.3, Color3.fromRGB(120, 124, 136), -45, 0.55)
gripB = bar(gripLines, 6, 9, 11, 1.3, Color3.fromRGB(120, 124, 136), -45, 0.55)
resizingUI = false
resizeToken = 0
resizeGrip.InputBegan:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1
		and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	resizeToken = resizeToken + 1
	local token = resizeToken
	local startPos = input.Position
	local startH = shell.Size.Y.Offset
	local startW = shell.Size.X.Offset
	local moved = false
	local moveConn, endConn
	moveConn = UserInput.InputChanged:Connect(function(i)
		if i.UserInputType ~= Enum.UserInputType.MouseMovement
			and i.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		if (i.Position - startPos).Magnitude > 4 then
			moved = true
		end
		if resizingUI then
			local dy = i.Position.Y - startPos.Y
			local z = math.clamp(1 + dy / 220, 0.6, 2)
			applyMenuZoom(z)
		end
	end)
	endConn = UserInput.InputEnded:Connect(function(i)
		if i.UserInputType ~= Enum.UserInputType.MouseButton1
			and i.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		resizeToken = resizeToken + 1
		resizingUI = false
		if moveConn then moveConn:Disconnect() end
		if endConn then endConn:Disconnect() end
		if shellShadow then
			shellShadow:Destroy()
		end
		if shell then
			shellShadow = softShadow(canvas, 0, 0, shell.Size.X.Offset, shell.Size.Y.Offset,
				14, 30, 0.075, 0)
		end
		tw(gripA, { BackgroundTransparency = 0.55 }, 0.15)
		tw(gripB, { BackgroundTransparency = 0.55 }, 0.15)
	end)
	task.delay(0.02, function()
		if token == resizeToken and not moved then
			resizingUI = true
			tw(gripA, { BackgroundTransparency = 0.12 }, 0.1)
			tw(gripB, { BackgroundTransparency = 0.12 }, 0.1)
		end
	end)
end)
resizeGrip.MouseEnter:Connect(function()
	tw(gripA, { BackgroundTransparency = 0.25 }, 0.12)
	tw(gripB, { BackgroundTransparency = 0.25 }, 0.12)
end)
resizeGrip.MouseLeave:Connect(function()
	if resizingUI then return end
	tw(gripA, { BackgroundTransparency = 0.55 }, 0.12)
	tw(gripB, { BackgroundTransparency = 0.55 }, 0.12)
end)
frame(shell, 0, 0, 158, SHELL_H, P.sidebar, 0.09, 14)
bar(shell, 145, 0, 13, SHELL_H, P.sidebar, 0, 0.09)
bar(shell, 157, 0, 1, SHELL_H, Color3.fromRGB(30, 33, 43), 0, 0)
logoBox = frame(shell, 15, 11, 30, 32, Color3.fromRGB(8, 8, 11), 0, 7)
label(logoBox, 1, 1, 30, 32, "NL", 16, Color3.fromRGB(96, 196, 236), Enum.Font.GothamBold, Enum.TextXAlignment.Center)
label(logoBox, 0, 0, 30, 32, "NL", 16, Color3.new(1, 1, 1), Enum.Font.GothamBold, Enum.TextXAlignment.Center)
label(shell, 53, 13, 100, 20, "Neverlose", 16, P.textTitle, Enum.Font.GothamBold)
serverSub = label(shell, 53, 33, 110, 12, "not connected", 9, Color3.fromRGB(91, 96, 108))
bar(shell, 10, 56, 137, 1, Color3.fromRGB(28, 31, 41))
langText(label(shell, 16, 60, 100, 14, "", 10, P.textFaint), "AIMBOT")
langText(label(shell, 16, 162, 100, 14, "", 10, P.textFaint), "COMMON")
navItems = {}
navOrder = {}
function makeNav(key, iconKind, text, y, indent)
	local p = frame(shell, 7 + (indent or 0), y, 140 - (indent or 0), 30, P.selected, 1, 6)
	local ic = frame(p, 10, 8, 13, 13, Color3.new(1, 1, 1), 1)
	Icons[iconKind](ic, P.navIcon)
	local tx = label(p, 31, 0, 140 - (indent or 0) - 34, 30, "", 15, P.navIdle)
	langText(tx, text)
	local item = {
		key = key, frame = p, icon = ic, text = tx,
		y = y, indent = indent or 0, active = false, hover = false,
		expanded = false, onClick = nil,
	}
	local function apply(animate)
		local target = (item.active and 1) or (item.hover and 0.48) or (item.expanded and 0.35) or 0
		local time = animate and 0.16 or 0
		tw(p, { BackgroundTransparency = 1 - target }, time)
		tw(ic, { BackgroundTransparency = 1 }, 0)
		for _, child in ipairs(ic:GetChildren()) do
			if child:IsA("Frame") then
				tw(child, { BackgroundColor3 = item.active and P.accentBright or P.navIcon }, time)
			elseif child:IsA("UIStroke") then
				tw(child, { Color = item.active and P.accentBright or P.navIcon }, time)
			end
		end
		tw(tx, { TextColor3 = item.active and P.textTitle or P.navIdle }, time)
	end
	item.apply = apply
	local hit = mk("TextButton", p, 0, 0, p.Size.X.Offset, 30)
	hit.BackgroundTransparency = 1
	hit.Text = ""
	hit.AutoButtonColor = false
	hit.MouseEnter:Connect(function() item.hover = true; apply(true) end)
	hit.MouseLeave:Connect(function() item.hover = false; apply(true) end)
	hit.MouseButton1Click:Connect(function() if item.onClick then item.onClick() end end)
	navItems[key] = item
	table.insert(navOrder, item)
	return item
end
subNav = Instance.new("CanvasGroup")
subNav.Name = "SubNav"
subNav.BackgroundTransparency = 1
subNav.Size = UDim2.fromOffset(158, SHELL_H)
subNav.Position = UDim2.fromOffset(0, 0)
subNav.GroupTransparency = 1
subNav.ZIndex = 4
subNav.Parent = shell
playersItem = makeNav("players", "user", "Players", 226, 14)
worldItem = makeNav("world", "globe", "World", 262, 14)
for _, it in ipairs({ playersItem, worldItem }) do
	it.frame.Parent = subNav
end
rageItem = makeNav("rage", "crosshair", "Rage", 84, 0)
legitItem = makeNav("legit", "mouse", "Legit", 120, 0)
visualsItem = makeNav("visuals", "image", "Visuals", 190, 0)
inventoryItem = makeNav("inventory", "layers", "Inventory", 226, 0)
miscItem = makeNav("miscellaneous", "sliders", "Miscellaneous", 262, 0)
langText(label(shell, 16, 300, 120, 14, "", 10, P.textFaint), "PRISON LIFE")
prisonItem = makeNav("prison", "shield", "Prison", 324, 0)
accountBtn = frame(shell, 7, 531, 140, 38, P.selected, 1, 6)
avatarBg = dot(accountBtn, 7, 5, 28, P.avatarA)
avatarGrad = Instance.new("UIGradient")
avatarGrad.Color = ColorSequence.new(P.avatarA, P.avatarB)
avatarGrad.Rotation = 45
avatarGrad.Parent = avatarBg
avatarIcon = frame(avatarBg, 7.5, 7.5, 13, 13, Color3.new(1, 1, 1), 1)
Icons.user(avatarIcon, Color3.fromRGB(222, 226, 240))
addAvatar(avatarBg, 0, 0, 28)
label(accountBtn, 43, 3, 90, 18, userName, 14, Color3.fromRGB(225, 227, 233))
label(accountBtn, 43, 20, 90, 14, "3 days left", 12, Color3.fromRGB(111, 116, 128))
vshape(accountBtn, 130, 19, 7, 4, 1.3, Color3.fromRGB(181, 185, 195))
toolbar = frame(shell, 158, 0, 590, 56, P.toolbar, 0.12)
do
	local tc = Instance.new("UICorner")
	tc.CornerRadius = UDim.new(0, 14)
	tc.TopLeftRadius = UDim.new(0, 0)
	tc.TopRightRadius = UDim.new(0, 14)
	tc.BottomLeftRadius = UDim.new(0, 0)
	tc.BottomRightRadius = UDim.new(0, 0)
	tc.Parent = toolbar
end
bar(shell, 158, 56, 590, 1, P.line)
CFG_NAME = "Default"
saveBtn = mk("TextButton", shell, 169, 14, 100, 30, P.card, 0)
corner(saveBtn, 6)
saveBtn.AutoButtonColor = false
saveBtn.Text = ""
stroke(saveBtn, Color3.fromRGB(28, 31, 41), 1)
do
	local si = frame(saveBtn, 10, 8, 13, 13, Color3.new(1, 1, 1), 1)
	Icons.save(si, Color3.fromRGB(194, 197, 206))
end
label(saveBtn, 30, 0, 64, 30, "保存", 13, Color3.fromRGB(184, 187, 197))
saveBtn.MouseButton1Click:Connect(function()
	if NL_SAVE_CONFIG then
		NL_SAVE_CONFIG()
	end
	if notify then
		notify("配置", "已保存当前预设", true)
	end
end)
saveBtn.MouseEnter:Connect(function()
	tw(saveBtn, { BackgroundColor3 = Color3.fromRGB(26, 29, 38) }, 0.12)
end)
saveBtn.MouseLeave:Connect(function()
	tw(saveBtn, { BackgroundColor3 = P.card }, 0.12)
end)
profileChip = mk("TextButton", shell, 277, 14, 166, 30, P.card, 0)
corner(profileChip, 6)
profileChip.AutoButtonColor = false
profileChip.Text = ""
stroke(profileChip, Color3.fromRGB(28, 31, 41), 1)
saveIcon = frame(profileChip, 12, 8, 13, 13, Color3.new(1, 1, 1), 1)
Icons.save(saveIcon, Color3.fromRGB(194, 197, 206))
profileText = label(profileChip, 48, 0, 100, 30, CFG_NAME, 14, Color3.fromRGB(184, 187, 197))
profileChip.MouseButton1Click:Connect(function()
	if riseShowPage then
		riseShowPage("presets")
	end
end)
function setCfgName(n)
	CFG_NAME = n or "Default"
	if profileText and profileText.Parent then
		profileText.Text = CFG_NAME
	end
end
searchBtn = mk("TextButton", shell, 705, 14, 30, 30)
searchBtn.BackgroundTransparency = 1
searchBtn.Text = ""
searchBtn.AutoButtonColor = false
searchIconFrame = frame(searchBtn, 8, 8, 13, 13, Color3.new(1, 1, 1), 1)
Icons.search(searchIconFrame, Color3.fromRGB(180, 184, 194))
searchBtn.MouseButton1Click:Connect(function()
	if openSearch then
		openSearch()
	end
end)
searchBtn.MouseEnter:Connect(function()
	for _, c in ipairs(searchIconFrame:GetChildren()) do
		if c:IsA("Frame") then tw(c, { BackgroundColor3 = P.accentBright }, 0.12) end
		if c:IsA("UIStroke") then tw(c, { Color = P.accentBright }, 0.12) end
	end
end)
searchBtn.MouseLeave:Connect(function()
	for _, c in ipairs(searchIconFrame:GetChildren()) do
		if c:IsA("Frame") then tw(c, { BackgroundColor3 = Color3.fromRGB(180, 184, 194) }, 0.12) end
		if c:IsA("UIStroke") then tw(c, { Color = Color3.fromRGB(180, 184, 194) }, 0.12) end
	end
end)
pageFrames = {}
currentPage = "rage"
pagesHolder = frame(shell, 0, 0, SHELL_W, SHELL_H, P.shell, 1)
pagesHolder.BackgroundTransparency = 1
pagesHolder.ZIndex = 2
function buildPage(key, builder)
	local group = Instance.new("CanvasGroup")
	group.Name = "Page_" .. key
	group.BackgroundTransparency = 1
	group.Size = UDim2.fromOffset(SHELL_W, SHELL_H)
	group.Position = UDim2.fromOffset(0, 0)
	group.Parent = pagesHolder
	group.Visible = false
	builder(group)
	pageFrames[key] = group
	return group
end
buildPage("rage", function(p)
	for _, card in ipairs(Pages.Rage) do buildCard(p, card) end
end)
buildPage("legit", function(p)
	for _, card in ipairs(Pages.Legit) do buildCard(p, card) end
end)
buildPage("players", function(p)
	for _, card in ipairs(Pages.Players) do buildCard(p, card) end
	buildPlayersPreview(p)
end)
buildPage("world", function(p)
	for _, card in ipairs(Pages.World) do buildCard(p, card) end
end)
buildPage("inventory", function(p)
	buildInventory(p)
end)
buildPage("miscellaneous", function(p)
	for _, card in ipairs(Pages.Miscellaneous) do buildCard(p, card) end
end)
buildPage("prison", function(p)
	for _, card in ipairs(Pages.Prison) do buildCard(p, card) end
end)
buildPage("presets", function(p)
	local REG = {}
	local selected = 1
	local renderRows, updateInfo, refreshPreset
	local rowBgAt, animateRow
	local CFG_FILE = "nl_presets.txt"
	local function saveCfg()
		if not writefile then
			return
		end
		local out = {}
		for _, r in ipairs(REG) do
			out[#out + 1] = (tostring(r.name):gsub("[\r\n]", " "))
		end
		pcall(writefile, CFG_FILE, table.concat(out, "\n"))
	end
	local function loadCfg()
		if not (isfile and readfile) then
			return
		end
		local ok, data = pcall(function()
			if not isfile(CFG_FILE) then
				return nil
			end
			return readfile(CFG_FILE)
		end)
		if not ok or type(data) ~= "string" or data == "" then
			return
		end
		local list = {}
		for line in data:gmatch("[^\n]+") do
			local n = line:match("^%s*(.-)%s*$")
			if n ~= "" then
				list[#list + 1] = { name = n }
			end
		end
		if #list > 0 then
			REG = list
			selected = 1
		end
	end
	function NL_SAVE_CONFIG()
		saveCfg()
		local cur = REG[selected]
		if cur and setCfgName then
			setCfgName(cur.name)
		end
	end
	loadCfg()
	frame(p, 168, 71, 14, 11, Color3.fromRGB(206, 160, 255), 0, 3)
	bar(p, 168, 70, 6, 3, Color3.fromRGB(206, 160, 255), 0, 0)
	label(p, 192, 64, 160, 24, "Presets", 17, Color3.fromRGB(240, 236, 245),
		Enum.Font.GothamBold)
	local defs = {
		{ x = 580, k = "plus" },
		{ x = 620, k = "minus" },
		{ x = 660, k = "load" },
	}
	for _, def in ipairs(defs) do
		local b = mk("TextButton", p, def.x, 62, 26, 26, Color3.new(1, 1, 1), 1)
		corner(b, 7)
		b.Text = ""
		b.AutoButtonColor = false
		local ic = frame(b, 7, 7, 12, 12, Color3.new(1, 1, 1), 1)
		if def.k == "minus" then
			bar(ic, 1, 6, 10, 1.4, Color3.fromRGB(180, 176, 190))
		elseif def.k == "plus" then
			bar(ic, 1, 6, 10, 1.4, Color3.fromRGB(180, 176, 190))
			bar(ic, 6, 1, 1.4, 10, Color3.fromRGB(180, 176, 190))
		elseif def.k == "down" then
			bar(ic, 6, 1, 1.4, 7, Color3.fromRGB(180, 176, 190))
			arm(ic, 4.2, 9, 5, 1.4, 45, Color3.fromRGB(180, 176, 190))
			arm(ic, 9.2, 9, 5, 1.4, -45, Color3.fromRGB(180, 176, 190))
		else
			corner(arm(ic, 3.5, 7, 4, 1.6, 45, Color3.fromRGB(120, 220, 150)), 1)
			corner(arm(ic, 8, 4, 7, 1.6, -45, Color3.fromRGB(120, 220, 150)), 1)
		end
		b.MouseEnter:Connect(function()
			tw(b, { BackgroundTransparency = 0.92 }, 0.12)
		end)
		b.MouseLeave:Connect(function()
			tw(b, { BackgroundTransparency = 1 }, 0.12)
		end)
		if def.k == "plus" then
			b.MouseButton1Click:Connect(function()
				local n = 1
				while true do
					local nm = "Unnamed " .. n
					local dup = false
					for _, r in ipairs(REG) do
						if r.name == nm then dup = true end
					end
					if not dup then
						table.insert(REG, { name = nm })
						break
					end
					n = n + 1
				end
				selected = #REG
				refreshPreset()
				saveCfg()
				if rowBgAt then
					animateRow(rowBgAt(selected), "load")
				end
				if setCfgName and REG[selected] then
					setCfgName(REG[selected].name)
				end
			end)
		elseif def.k == "load" then
			b.MouseButton1Click:Connect(function()
				local cur = REG[selected]
				if cur and islandCfgToast then
					islandCfgToast(cur.name, "已加载", "check")
					end
				if rowBgAt then
					animateRow(rowBgAt(selected), "load")
				end
			end)
		elseif def.k == "minus" then
			b.MouseButton1Click:Connect(function()
				if #REG == 0 then
					return
				end
				local gone = REG[selected]
				if gone and islandCfgToast then
					islandCfgToast(gone.name, "已删除", "trash")
					end
				if rowBgAt then
					animateRow(rowBgAt(selected), "delete")
				end
				task.delay(0.2, function()
					table.remove(REG, selected)
					selected = math.max(1, selected - 1)
					refreshPreset()
					saveCfg()
				end)
			end)
		else
			b.MouseButton1Click:Connect(function()
				if openLoader then openLoader() end
			end)
		end
	end
	local sBox = mk("TextButton", p, 168, 100, 564, 30, Color3.fromRGB(24, 24, 32), 0)
	corner(sBox, 8)
	sBox.AutoButtonColor = false
	sBox.Text = ""
	local sIcon = frame(sBox, 11, 9, 12, 12, Color3.new(1, 1, 1), 1)
	ring(sIcon, 0, 0, 9, Color3.fromRGB(140, 136, 150), 1.4)
	bar(sIcon, 8, 8, 4, 1.4, Color3.fromRGB(140, 136, 150), 45)
	local sInput = mk("TextBox", sBox, 32, 0, 520, 30)
	sInput.BackgroundTransparency = 1
	sInput.Text = ""
	sInput.PlaceholderText = "搜索"
	sInput.PlaceholderColor3 = Color3.fromRGB(120, 117, 130)
	sInput.TextColor3 = Color3.fromRGB(226, 222, 232)
	sInput.TextSize = 13
	sInput.Font = Enum.Font.Gotham
	sInput.TextXAlignment = Enum.TextXAlignment.Left
	sInput.ClearTextOnFocus = false
	local rowsHolder = frame(p, 168, 142, 172, 336, Color3.new(1, 1, 1), 1)
	rowsHolder.BackgroundTransparency = 1
	local rowRefs = {}
	rowBgAt = function(i)
		local r = rowRefs[i]
		return r and r.bg
	end
	animateRow = function(bg, mode)
		if not bg then
			return
		end
		for _, d in ipairs(bg:GetDescendants()) do
			if d:IsA("TextLabel") then
				tw(d, { TextTransparency = mode == "delete" and 1 or 0 }, 0.18)
			elseif d:IsA("Frame") then
				tw(d, { BackgroundTransparency = mode == "delete" and 1 or (d:GetAttribute("baseT") or 0) }, 0.18)
			end
		end
		if mode == "delete" then
			tw(bg, { BackgroundTransparency = 1 }, 0.18)
		else
			tw(bg, { BackgroundTransparency = 0.72 }, 0.12)
			task.delay(0.14, function()
				tw(bg, { BackgroundTransparency = 0.9 }, 0.28)
			end)
		end
	end
	renderRows = function()
		for _, r in ipairs(rowRefs) do
			if r.bg and r.bg.Parent then r.bg:Destroy() end
		end
		rowRefs = {}
		for i, preset in ipairs(REG) do
			local sel = (i == selected)
			local bg = mk("TextButton", rowsHolder, 0, (i - 1) * 50, 172, 44,
				Color3.new(1, 1, 1), sel and 0.9 or 1)
			corner(bg, 10)
			bg.AutoButtonColor = false
			bg.Text = ""
			local nameLbl = label(bg, 12, 0, 118, 44, preset.name, 14,
				sel and Color3.fromRGB(236, 233, 242) or Color3.fromRGB(150, 147, 160))
			bg.MouseEnter:Connect(function()
				if i ~= selected then
					tw(bg, { BackgroundTransparency = 0.95 }, 0.12)
				end
			end)
			bg.MouseLeave:Connect(function()
				if i ~= selected then
					tw(bg, { BackgroundTransparency = 1 }, 0.12)
				end
			end)
			bg.MouseButton1Click:Connect(function()
				selected = i
				renderRows()
				updateInfo()
			end)
			table.insert(rowRefs, { bg = bg, name = nameLbl })
		end
	end
	local info = frame(p, 352, 142, 372, 336, Color3.fromRGB(20, 19, 26), 0.1, 12)
	stroke(info, P.border, 1, 0.2)
	local infoTitle = label(info, 18, 16, 330, 26, "", 18,
		Color3.fromRGB(236, 233, 242), Enum.Font.GothamBold)
	label(info, 18, 48, 200, 18, "已启用模块", 12, Color3.fromRGB(140, 136, 150))
	local totalModules, enabledModules = 0, 0
	for _, page in pairs(Pages) do
		for _, card in ipairs(page) do
			for _, row in ipairs(card.rows) do
				if row.kind == "toggle" then
					totalModules = totalModules + 1
					if row.on then
						enabledModules = enabledModules + 1
					end
				end
			end
		end
	end
	local ratio = totalModules > 0 and (enabledModules / totalModules) or 0
	local statText = label(info, 18, 66, 330, 20,
		enabledModules .. " / " .. totalModules, 15,
		Color3.fromRGB(214, 210, 222), Enum.Font.GothamBold)
	frame(info, 18, 96, 330, 4, Color3.fromRGB(52, 50, 62), 0, 2)
	frame(info, 18, 96, 330 * ratio, 4, P.accent, 0, 2)
	local hkCount = 0
	for _ in pairs(BINDS) do
		hkCount = hkCount + 1
	end
	label(info, 18, 118, 180, 16, "快捷键", 12, Color3.fromRGB(140, 136, 150))
	label(info, 18, 136, 180, 20, tostring(hkCount), 15,
		Color3.fromRGB(214, 210, 222), Enum.Font.GothamBold)
	label(info, 18, 166, 180, 16, "主题", 12, Color3.fromRGB(140, 136, 150))
	label(info, 18, 184, 180, 20, "Blend", 15,
		Color3.fromRGB(214, 210, 222), Enum.Font.GothamBold)
	label(info, 18, 214, 180, 16, "版本", 12, Color3.fromRGB(140, 136, 150))
	label(info, 18, 232, 180, 20, "1.0", 15,
		Color3.fromRGB(214, 210, 222), Enum.Font.GothamBold)
	local function mkInfoBtn(x, text, bg, onClick)
		local b = mk("TextButton", info, x, 294, 108, 28, bg, 0.12)
		corner(b, 7)
		b.AutoButtonColor = false
		b.Text = ""
		label(b, 0, 0, 108, 28, text, 12, Color3.fromRGB(240, 236, 245),
			nil, Enum.TextXAlignment.Center)
		b.MouseEnter:Connect(function()
			tw(b, { BackgroundTransparency = 0.02 }, 0.12)
		end)
		b.MouseLeave:Connect(function()
			tw(b, { BackgroundTransparency = 0.12 }, 0.12)
		end)
		b.MouseButton1Click:Connect(onClick)
	end
	mkInfoBtn(18, "加载预设", P.accent, function()
		local cur = REG[selected]
		if cur and islandCfgToast then
			islandCfgToast(cur.name, "已更新", "check")
			end
		if rowBgAt then
			animateRow(rowBgAt(selected), "load")
		end
	end)
	mkInfoBtn(134, "更新 CFG", Color3.fromRGB(72, 118, 214), function()
		local cur = REG[selected]
		if cur and islandCfgToast then
			islandCfgToast(cur.name, "已加载", "check")
			end
		saveCfg()
	end)
	mkInfoBtn(250, "重命名", Color3.fromRGB(56, 60, 74), function()
		local cur = REG[selected]
		if not cur then
			return
		end
		local box = mk("TextBox", info, 18, 250, 330, 30, Color3.fromRGB(32, 32, 42), 0)
		corner(box, 7)
		box.Text = cur.name
		box.PlaceholderText = "预设名"
		box.TextColor3 = Color3.fromRGB(236, 233, 242)
		box.TextSize = 14
		box.Font = Enum.Font.Gotham
		box.TextXAlignment = Enum.TextXAlignment.Left
		box.ClearTextOnFocus = false
		box:CaptureFocus()
		local done = false
		local function commit()
			if done then
				return
			end
			done = true
			local txt = box.Text
			if txt and txt ~= "" then
				cur.name = txt
			end
			if box.Parent then
				box:Destroy()
			end
			if refreshPreset then
				refreshPreset()
			end
			saveCfg()
			if islandCfgToast then
				islandCfgToast(cur.name, "已重命名", "check")
			end
		end
		box.FocusLost:Connect(commit)
	end)
	updateInfo = function()
		local preset = REG[selected]
		infoTitle.Text = preset and preset.name or "Preset"
		statText.Text = enabledModules .. " / " .. totalModules
	end
	refreshPreset = function()
		renderRows()
		updateInfo()
	end
	renderRows()
	updateInfo()
end)
accountPopup = nil
accountUiHolder = nil
function closeAccount()
	if not accountPopup then return end
	if accountUiHolder then
		accountUiHolder:Destroy()
		accountUiHolder = nil
	end
	local p = accountPopup.panel
	local sh = accountPopup.shadow
	accountPopup = nil
	if p then
		tw(p, { BackgroundTransparency = 1 }, 0.12)
		for _, d in ipairs(p:GetDescendants()) do
			if d:IsA("TextLabel") then tw(d, { TextTransparency = 1 }, 0.12) end
			if d:IsA("Frame") then tw(d, { BackgroundTransparency = 1 }, 0.12) end
			if d:IsA("UIStroke") then tw(d, { Transparency = 1 }, 0.12) end
		end
	end
	if sh then tw(sh, { BackgroundTransparency = 1 }, 0.12) end
	task.delay(0.14, function()
		if p and p.Parent then p:Destroy() end
		if sh and sh.Parent then sh:Destroy() end
	end)
end
STYLE_ITEMS = {
	{ "Toggle Color", P.accent },
	{ "Slider Color", P.sliderColor },
	{ "Hit Marker", Color3.fromRGB(255, 255, 255) },
	{ "Kill Effect", Color3.fromRGB(255, 90, 90) },
	{ "Damage Log", Color3.fromRGB(255, 176, 60) },
	{ "Crosshair", Color3.fromRGB(120, 255, 160) },
}
ACCOUNT_ROWS = {
	{ "globe",  "Language",        "1" },
	{ "brush",  "Style",           nil },
	{ "window", "UI Edit",         "打开" },
}
rowOptions = {
	["Safe Mode"] = { "Automatic", "Manual", "Off" },
}
function openAccount()
	closeAccount()
	closePopup()
	local sh = softShadow(canvas, 151, 350, 215, 206, 14, 18, 0.1, 29)
	local panel = mk("TextButton", canvas, 151, 350, 215, 206, Color3.fromRGB(25, 25, 34), 0.01)
	panel.AutoButtonColor = false
	panel.Text = ""
	corner(panel, 14)
	panel.ZIndex = 30
	stroke(panel, Color3.fromRGB(37, 39, 50), 1, 0)
	local av = dot(panel, 19, 17, 39, P.avatarA)
	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new(P.avatarA, P.avatarB)
	grad.Rotation = 45
	grad.Parent = av
	local avIcon = frame(av, 13, 13, 13, 13, Color3.new(1, 1, 1), 1)
	Icons.user(avIcon, Color3.fromRGB(228, 231, 241))
	addAvatar(av, 0, 0, 39)
	label(panel, 67, 12, 135, 20, userName, 15, Color3.fromRGB(226, 228, 235))
	label(panel, 67, 31, 140, 18, "Till: July 16 2026", 14, Color3.fromRGB(187, 190, 201))
	label(panel, 67, 48, 90, 18, T("Renew"), 14, Color3.fromRGB(78, 129, 255))
	bar(panel, 14, 72, 187, 1, Color3.fromRGB(36, 38, 48))
	for i, row in ipairs(ACCOUNT_ROWS) do
		local y = 80 + (i - 1) * 31
		local ic = frame(panel, 21, y + 9, 13, 13, Color3.new(1, 1, 1), 1)
		local fn = Icons[row[1]]
		if fn then fn(ic, Color3.fromRGB(184, 187, 197)) end
		label(panel, 49, y, 108, 31, T(row[2]), 14, Color3.fromRGB(176, 179, 189))
		if row[2] == "Language" then
			local hl = frame(panel, 12, y, 191, 31, Color3.new(1, 1, 1), 1, 6)
			hl.ZIndex = 0
			local val = label(panel, 96, y, 91, 31, (LANG == "zh") and "中文" or "English",
				14, Color3.fromRGB(155, 159, 170), nil, Enum.TextXAlignment.Right)
			val.TextTruncate = Enum.TextTruncate.None
			local hit = mk("TextButton", panel, 12, y, 191, 31)
			hit.BackgroundTransparency = 1
			hit.Text = ""
			hit.AutoButtonColor = false
			hit.ZIndex = 6
			hit.MouseEnter:Connect(function() tw(hl, { BackgroundTransparency = 0.94 }, 0.1) end)
			hit.MouseLeave:Connect(function() tw(hl, { BackgroundTransparency = 1 }, 0.1) end)
			hit.MouseButton1Click:Connect(function()
				openDropdown(hit, { "English", "中文" }, false, (LANG == "zh") and 2 or 1, function(k)
					setLanguage(k == 2 and "zh" or "en")
					val.Text = (LANG == "zh") and "中文" or "English"
					closeAccount()
					openAccount()
				end, 120)
			end)
		elseif row[2] == "UI Edit" then
			local hitUI = mk("TextButton", panel, 12, y, 191, 31)
			hitUI.BackgroundTransparency = 1
			hitUI.Text = ""
			hitUI.AutoButtonColor = false
			hitUI.ZIndex = 6
			hitUI.MouseButton1Click:Connect(function()
				if openUIEdit then
					openUIEdit()
					if closeAccount then
						closeAccount()
					end
				end
			end)
		elseif row[3] and rowOptions[row[2]] then
			local opts = rowOptions[row[2]]
			local hl = frame(panel, 12, y, 191, 31, Color3.new(1, 1, 1), 1, 6)
			hl.ZIndex = 0
			local val = label(panel, 96, y, 91, 31, T(row[3]), 14,
				Color3.fromRGB(155, 159, 170), nil, Enum.TextXAlignment.Right)
			val.TextTruncate = Enum.TextTruncate.None
			local hit = mk("TextButton", panel, 12, y, 191, 31)
			hit.BackgroundTransparency = 1
			hit.Text = ""
			hit.AutoButtonColor = false
			hit.ZIndex = 6
			hit.MouseEnter:Connect(function() tw(hl, { BackgroundTransparency = 0.94 }, 0.1) end)
			hit.MouseLeave:Connect(function() tw(hl, { BackgroundTransparency = 1 }, 0.1) end)
			hit.MouseButton1Click:Connect(function()
				local idx = 1
				for k, o in ipairs(opts) do
					if o == row[3] then idx = k end
				end
				openDropdown(hit, opts, false, idx, function(k)
					row[3] = opts[k]
				if row[2] == "Menu Scale" then
					local z = (tonumber((opts[k]:gsub("%%", ""))) or 100) / 100
					if confirmZoom then
						confirmZoom(z)
					else
						applyMenuZoom(z)
					end
				end
					val.Text = T(opts[k])
				end, 130)
			end)
		elseif row[3] then
			local val = label(panel, 96, y, 91, 31, row[3], 14, Color3.fromRGB(155, 159, 170), nil, Enum.TextXAlignment.Right)
			val.TextTruncate = Enum.TextTruncate.None
		end
		if row[2] ~= "Style" and row[2] ~= "UI Edit" then
			vshape(panel, 198, y + 15, 6, 3.5, 1.2, Color3.fromRGB(159, 163, 174))
		end
	end
	local styleY = 80 + 1 * 31
	local styleChip = frame(panel, 180, styleY + 8, 15, 15, STYLE_ITEMS[1][2], 0, 4)
	local styleHit = mk("TextButton", panel, 174, styleY + 5, 34, 24)
	styleHit.BackgroundTransparency = 1
	styleHit.Text = ""
	styleHit.AutoButtonColor = false
	styleHit.ZIndex = 6
	local STYLE_KEYS = {
		{ "主题色", "accent" },
		{ "高亮色", "accentBright" },
		{ "正文文字", "text" },
		{ "标题文字", "textTitle" },
		{ "次要文字", "textMuted" },
		{ "卡片背景", "card" },
		{ "边框", "border" },
		{ "滑块颜色", "sliderColor" },
		{ "开关打开", "toggleKnobOn" },
	}
	local STYLE_NAMES = {}
	for _, k in ipairs(STYLE_KEYS) do
		STYLE_NAMES[#STYLE_NAMES + 1] = k[1]
	end
	styleHit.MouseButton1Click:Connect(function()
		local styleColors = {}
		for i, k in ipairs(STYLE_KEYS) do
			styleColors[i] = P[k[2]] or P.accent
		end
		openDropdown(styleHit, STYLE_NAMES, false, 1, function(idx)
			local key = STYLE_KEYS[idx] and STYLE_KEYS[idx][2]
			if not key then
				return
			end
			if P[key] == nil then
				P[key] = P.accent
			end
			task.defer(function()
				openColorPicker(styleHit, P[key], function(c)
					P[key] = c
					if applyAccent then
						applyAccent(P.accent)
					end
					if applySliderColor and P.sliderColor then
						applySliderColor(P.sliderColor)
					end
					styleChip.BackgroundColor3 = P[key]
				end)
			end)
		end, 150)
	end)
	panel.BackgroundTransparency = 1
	panel.Position = UDim2.fromOffset(151, 350)
	tw(panel, { BackgroundTransparency = 0.01, Position = UDim2.fromOffset(151, 350) }, 0.16, Enum.EasingStyle.Cubic)
	accountPopup = { panel = panel, shadow = sh }
end
accountHit = mk("TextButton", accountBtn, 0, 0, 140, 38)
accountHit.BackgroundTransparency = 1
accountHit.Text = ""
accountHit.AutoButtonColor = false
accountHit.ZIndex = 6
accountHit.MouseEnter:Connect(function()
	tw(accountBtn, { BackgroundTransparency = 0.08 }, 0.12)
end)
accountHit.MouseLeave:Connect(function()
	tw(accountBtn, { BackgroundTransparency = 1 }, 0.12)
end)
accountHit.MouseButton1Click:Connect(function()
	if accountPopup then closeAccount() else openAccount() end
end)
local setVisuals
function showPage(key)
	if currentPage == key then
		if pageFrames[key] then pageFrames[key].Visible = true end
		return
	end
	closePopup()
	closeAccount()
	local previous = pageFrames[currentPage]
	if previous then previous.Visible = false end
	local target = pageFrames[key]
	if not target then return end
	currentPage = key
	target.Visible = true
	target.GroupTransparency = 1
	target.Position = UDim2.fromOffset(9, 0)
	tw(target, { GroupTransparency = 0, Position = UDim2.fromOffset(0, 0) }, 0.22, Enum.EasingStyle.Cubic)
	local visualsOpen = (key == "players" or key == "world")
	visualsItem.active = false
	visualsItem.expanded = visualsOpen
	for _, it in ipairs(navOrder) do
		if it.key ~= "visuals" then
			it.active = (it.key == key)
		end
	end
	for _, it in ipairs(navOrder) do it.apply(true) end
	setVisuals(visualsOpen)
end
function riseShowPage(key)
	showPage(key)
end
setVisuals = function(open)
	local expand = open and 1 or 0
	if open then subNav.Visible = true end
	tw(subNav, { GroupTransparency = open and 0 or 1 }, 0.2, Enum.EasingStyle.Quad)
	if not open then
		task.delay(0.24, function()
			if subNav.GroupTransparency > 0.99 then subNav.Visible = false end
		end)
	end
	tw(inventoryItem.frame, { Position = UDim2.fromOffset(7, 226 + 72 * expand) }, 0.24, Enum.EasingStyle.Quad)
	tw(miscItem.frame, { Position = UDim2.fromOffset(7, 262 + 72 * expand) }, 0.24, Enum.EasingStyle.Quad)
end
rageItem.onClick = function() showPage("rage") end
legitItem.onClick = function() showPage("legit") end
visualsItem.onClick = function() showPage("players") end
playersItem.onClick = function() showPage("players") end
worldItem.onClick = function() showPage("world") end
inventoryItem.onClick = function() showPage("inventory") end
miscItem.onClick = function() showPage("miscellaneous") end
	prisonItem.onClick = function() showPage("prison") end
goToPage = function()
	local keys = { "rage", "legit", "players", "world", "inventory", "miscellaneous" }
	local labels = {
		T("Rage"), T("Legit"), T("Players"),
		T("World"), T("Inventory"), T("Miscellaneous"),
	}
	openDropdown(searchBtn, labels, false, 1, function(i)
		showPage(keys[i])
	end, 170)
end
pageFrames.rage.Visible = true
rageItem.active = true
rageItem.apply(false)
visualsItem.active = false
subNav.Visible = false
for _, it in ipairs(navOrder) do it.apply(false) end
function makeDraggable(handle, target)
	target = target or canvas
	local dragging = false
	local startMouse, startPos
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			startMouse = input.Position
			startPos = target.Position
			closePopup()
		end
	end)
	local goal = nil
	game:GetService("RunService").RenderStepped:Connect(function(dt)
		if not goal then
			return
		end
		local cur = target.Position
		local cx, cy = cur.X.Offset, cur.Y.Offset
		local k = math.clamp(dt * 16, 0, 1)
		local nx = cx + (goal.X - cx) * k
		local ny = cy + (goal.Y - cy) * k
		target.Position = UDim2.fromOffset(nx, ny)
		if math.abs(goal.X - nx) < 0.6 and math.abs(goal.Y - ny) < 0.6 then
			target.Position = UDim2.fromOffset(goal.X, goal.Y)
			if not dragging then
				goal = nil
			end
		end
	end)
	UserInput.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement
			and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		local delta = input.Position - startMouse
		local nx = startPos.X.Offset + delta.X
		local ny = startPos.Y.Offset + delta.Y
		local vp = workspace.CurrentCamera.ViewportSize
		local keep = 200
		local us = target:FindFirstChildOfClass("UIScale")
		local sc = (us and us.Scale) or uiScaleValue
		local tW = target.Size.X.Offset * sc
		nx = math.clamp(nx, keep - tW, vp.X - keep)
		ny = math.clamp(ny, 8, vp.Y - 60)
		goal = Vector2.new(nx, ny)
	end)
	UserInput.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end
dragArea = mk("TextButton", shell, 158, 0, 590, 56)
dragArea.BackgroundTransparency = 1
dragArea.Text = ""
dragArea.AutoButtonColor = false
dragArea.ZIndex = 0
makeDraggable(dragArea)
dragArea2 = mk("TextButton", shell, 0, 0, 158, 56)
dragArea2.BackgroundTransparency = 1
dragArea2.Text = ""
dragArea2.AutoButtonColor = false
dragArea2.ZIndex = 0
makeDraggable(dragArea2)
local playIntro
local enterMenu
local LC, loaderRoot, closeServerModal, CLOUD, SERVERS, httpGet, currentServer, injectRoot, lScale, loaderX, loaderY, loaderShadow, injectShadow, loaderCanvas, dashRoot, refreshCards
local playInject
LC = {
	bg        = Color3.fromRGB(2, 2, 3),
	card      = Color3.fromRGB(4, 9, 15),
	border    = Color3.fromRGB(17, 19, 23),
	accent    = Color3.fromRGB(93, 123, 200),
	button    = Color3.fromRGB(72, 118, 214),
	text      = Color3.fromRGB(255, 255, 255),
	muted     = Color3.fromRGB(153, 153, 153),
	dim       = Color3.fromRGB(178, 178, 178),
	link      = Color3.fromRGB(108, 132, 186),
	panel     = Color3.fromRGB(8, 11, 16),
	panelLine = Color3.fromRGB(28, 32, 40),
}
CLOUD = {
	manifest   = "",
	iconBase   = "",
	scriptBase = "",
}
SERVERS = {
	{
		id = "prison",
		name = "dushi监狱人生脚本",
		sub = "Prison Life · Place 155615604",
		status = "Lifetime",
		icon = "",
		script = "",
		active = true,
		branch = "Release",
		updated = "14.11.2026",
		changelog = {
			"- Ragebot（瞬时锁定 / 自动开火 / 命中率）",
			"- CHAMS 人物上色（Solid / Glass / Glow）",
			"- ESP 方框 / 名字 / 血条 / 距离",
			"- 移动（速度 / 跳跃 / 穿墙）",
			"- 视觉（全亮 / 去雾）",
		},
	},
}

httpGet = function(url)
	if not url or url == "" then return nil end
	local ok, res = pcall(function() return game:HttpGet(url) end)
	if ok and type(res) == "string" and #res > 0 then return res end
	return nil
end
function assetFromUrl(url, tag)
	if not url or url == "" then return nil end
	if url:match("^rbxassetid://") or url:match("^rbxasset://") then return url end
	local ok, res = pcall(function()
		local data = game:HttpGet(url)
		if not data or #data < 16 then return nil end
		local fname = "nl_" .. tostring(tag or "icon") .. ".png"
		writefile(fname, data)
		local fn = getcustomasset or getsynasset
		if not fn then return nil end
		return fn(fname)
	end)
	if ok then return res end
	return nil
end
function serverIconUrl(srv)
	if srv.icon and srv.icon ~= "" then return srv.icon end
	if CLOUD.iconBase ~= "" then return CLOUD.iconBase .. srv.id .. ".png" end
	return nil
end
function serverScriptUrl(srv)
	if srv.script and srv.script ~= "" then return srv.script end
	if CLOUD.scriptBase ~= "" then return CLOUD.scriptBase .. srv.id .. ".lua" end
	return nil
end
currentServer = nil
modalState = nil
injectRoot = nil
loaderRoot = Instance.new("Frame")
loaderRoot.Name = "NLLoader"
loaderRoot.BackgroundTransparency = 1
loaderRoot.Size = UDim2.fromOffset(516, 416)
loaderRoot.ZIndex = 6
loaderRoot.Parent = gui
lScale = Instance.new("UIScale")
lScale.Scale = uiScaleValue
lScale.Parent = loaderRoot
loaderX = math.floor((viewport.X - 516 * uiScaleValue) / 2)
loaderY = math.floor((viewport.Y - 416 * uiScaleValue) / 2)
loaderRoot.Position = UDim2.fromOffset(loaderX, loaderY)
loaderShadow = softShadow(loaderRoot, 8, 8, 500, 400, 15, 26, 0.09, 0)
injectShadow = nil
loaderMenu = nil
function closeLoaderMenu()
	if loaderMenu then
		local m = loaderMenu
		loaderMenu = nil
		m:Destroy()
	end
end
function openLoaderMenu(anchor, options, current, onPick)
	closeLoaderMenu()
	local sc = lScale.Scale
	local ax = (anchor.AbsolutePosition.X - loaderRoot.AbsolutePosition.X) / sc
	local ay = (anchor.AbsolutePosition.Y - loaderRoot.AbsolutePosition.Y) / sc
	local aw = anchor.AbsoluteSize.X / sc
	local ah = anchor.AbsoluteSize.Y / sc
	local w, h = 132, #options * 28 + 8
	local px = math.clamp(ax + aw - w, 4, 516 - w - 4)
	local py = ay - h - 6
	if py < 4 then
		py = ay + ah + 6
	end
	local scrim = mk("TextButton", loaderRoot, 0, 0, 516, 416)
	scrim.BackgroundTransparency = 1
	scrim.Text = ""
	scrim.AutoButtonColor = false
	scrim.ZIndex = 59
	scrim.MouseButton1Click:Connect(closeLoaderMenu)
	local pop = mk("TextButton", loaderRoot, px, py, w, h, Color3.fromRGB(20, 20, 29), 0.04)
	pop.AutoButtonColor = false
	pop.Text = ""
	corner(pop, 10)
	pop.ZIndex = 60
	stroke(pop, Color3.fromRGB(57, 61, 76), 1, 0.2)
	loaderMenu = pop
	for i, opt in ipairs(options) do
		local rowY = 4 + (i - 1) * 28
		local b = mk("TextButton", pop, 4, rowY, w - 8, 28)
		b.BackgroundTransparency = 1
		b.Text = ""
		b.AutoButtonColor = false
		b.ZIndex = 61
		local txt = label(b, 28, 0, w - 40, 28, opt, 13, Color3.fromRGB(214, 217, 226))
		txt.ZIndex = 61
		if i == current then
			arm(b, 12, 15, 4, 1.4, 45, LC.text)
			arm(b, 15, 17, 7, 1.4, -45, LC.text)
		end
		b.MouseEnter:Connect(function() tw(b, { BackgroundTransparency = 0.9 }, 0.1) end)
		b.MouseLeave:Connect(function() tw(b, { BackgroundTransparency = 1 }, 0.1) end)
		b.MouseButton1Click:Connect(function()
			closeLoaderMenu()
			if onPick then onPick(i) end
		end)
	end
end
loaderCanvas = frame(loaderRoot, 8, 8, 500, 400, LC.bg, 0, 15)
loaderCanvas.ZIndex = 1
loaderCanvas.ClipsDescendants = true
stroke(loaderCanvas, Color3.fromRGB(26, 28, 33), 1, 0.3)
dashRoot = Instance.new("CanvasGroup")
dashRoot.Name = "Dashboard"
dashRoot.Size = UDim2.fromOffset(500, 400)
dashRoot.Position = UDim2.fromOffset(0, 0)
dashRoot.BackgroundTransparency = 1
dashRoot.GroupTransparency = 1
dashRoot.ZIndex = 1
dashRoot.Parent = loaderCanvas
cardScroll = Instance.new("ScrollingFrame")
cardScroll.Position = UDim2.fromOffset(185, 100)
cardScroll.Size = UDim2.fromOffset(295, 292)
cardScroll.BackgroundTransparency = 1
cardScroll.BorderSizePixel = 0
cardScroll.ScrollBarThickness = 2
cardScroll.ScrollBarImageColor3 = Color3.fromRGB(70, 74, 88)
cardScroll.ScrollBarImageTransparency = 0.35
cardScroll.ScrollingDirection = Enum.ScrollingDirection.Y
cardScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
cardScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
cardScroll.ElasticBehavior = Enum.ElasticBehavior.Never
cardScroll.ZIndex = 2
cardScroll.Parent = dashRoot
label(dashRoot, 18, 12, 60, 34, "NL", 27, LC.accent, Enum.Font.GothamBold)
label(dashRoot, 20, 12, 60, 34, "NL", 27, LC.text, Enum.Font.GothamBold)
langText(label(dashRoot, 185, 17, 190, 24, "", 17, LC.text, Enum.Font.GothamBold), "Subscription")
langText(label(dashRoot, 185, 42, 190, 18, "", 12, LC.muted), "Available subscriptions")
loaderClose = mk("TextButton", dashRoot, 458, 16, 24, 24)
loaderClose.BackgroundTransparency = 1
loaderClose.Text = ""
loaderClose.AutoButtonColor = false
bar(loaderClose, 8, 11.2, 8, 1.6, Color3.fromRGB(190, 190, 198), 45)
bar(loaderClose, 8, 11.2, 8, 1.6, Color3.fromRGB(190, 190, 198), -45)
loaderClose.MouseEnter:Connect(function()
	tw(loaderClose, { BackgroundTransparency = 0.85 }, 0.12)
end)
loaderClose.MouseLeave:Connect(function()
	tw(loaderClose, { BackgroundTransparency = 1 }, 0.12)
end)
function closeLoaderWindow()
	local base = loaderRoot.Position
	tw(lScale, { Scale = uiScaleValue * 0.96 }, 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	tw(loaderRoot, { Position = base + UDim2.fromOffset(0, 8) }, 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	task.delay(0.13, function()
		loaderRoot.Position = base
		lScale.Scale = uiScaleValue
		loaderRoot.Visible = false
		if currentServer then
			canvas.Visible = true
		else
			gui.Enabled = false
		end
	end)
end
loaderClose.MouseButton1Click:Connect(closeLoaderWindow)
local miniPill
function setMinimized(min)
	if min then
		loaderRoot.Visible = false
		if not miniPill then
			miniPill = mk("TextButton", gui, 0, 0, 46, 46, LC.bg, 0.02)
			corner(miniPill, 12)
			stroke(miniPill, Color3.fromRGB(40, 44, 54), 1, 0.35)
			label(miniPill, 0, 0, 46, 46, "NL", 15, LC.text, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
			miniPill.ZIndex = 9
			miniPill.Position = UDim2.fromOffset(24, 24)
			miniPill.MouseButton1Click:Connect(function()
				setMinimized(false)
			end)
		end
		miniPill.Visible = true
	else
		if miniPill then
			miniPill.Visible = false
		end
		loaderRoot.Visible = true
	end
end
loaderMin = mk("TextButton", dashRoot, 432, 16, 24, 24)
loaderMin.BackgroundTransparency = 1
loaderMin.Text = ""
loaderMin.AutoButtonColor = false
bar(loaderMin, 8, 11.6, 8, 1.6, Color3.fromRGB(190, 190, 198))
loaderMin.MouseEnter:Connect(function()
	tw(loaderMin, { BackgroundTransparency = 0.85 }, 0.12)
end)
loaderMin.MouseLeave:Connect(function()
	tw(loaderMin, { BackgroundTransparency = 1 }, 0.12)
end)
loaderMin.MouseButton1Click:Connect(function()
	setMinimized(true)
end)
sideLinks = {
	{ "Site", "https://neverlose.cc/" },
	{ "Discord", "https://discord.gg/neverlose" },
	{ "Telegram", "https://t.me/neverlose" },
}
for i, link in ipairs(sideLinks) do
	local b = mk("TextButton", dashRoot, 20, 95 + (i - 1) * 35, 110, 22)
	b.BackgroundTransparency = 1
	b.Text = ""
	b.AutoButtonColor = false
	local l = label(b, 0, 0, 110, 22, link[1], 14, LC.dim)
	b.MouseEnter:Connect(function() tw(l, { TextColor3 = LC.text }, 0.12) end)
	b.MouseLeave:Connect(function() tw(l, { TextColor3 = LC.dim }, 0.12) end)
	b.MouseButton1Click:Connect(function()
		pcall(function() setclipboard(link[2]) end)
		l.Text = (LANG == "zh") and "已复制" or "Copied"
		task.delay(0.9, function()
			l.Text = link[1]
		end)
	end)
end
lav = dot(dashRoot, 20, 335, 40, P.avatarA)
lgrad = Instance.new("UIGradient")
lgrad.Color = ColorSequence.new(P.avatarA, P.avatarB)
lgrad.Rotation = 45
lgrad.Parent = lav
lavIcon = frame(lav, 13, 13, 14, 14, Color3.new(1, 1, 1), 1)
Icons.user(lavIcon, Color3.fromRGB(232, 234, 244))
addAvatar(lav, 0, 0, 40)
label(dashRoot, 70, 345, 120, 20, userName, 14, Color3.fromRGB(235, 235, 240))
cardList = {}
function applyServerIcon(srv, img, ph)
	local url = serverIconUrl(srv)
	if not url then return end
	task.spawn(function()
		local content = assetFromUrl(url, srv.id)
		if content and img and img.Parent then
			img.Image = content
			img.ImageTransparency = 0
			if ph and ph.Parent then ph.Visible = false end
		end
	end)
end
local openServerModalImpl
closeServerModal = function()
	if not modalState then return end
	local m = modalState
	modalState = nil
	if m.panel then
		tw(m.panel, { BackgroundTransparency = 1 }, 0.1)
		for _, d in ipairs(m.panel:GetDescendants()) do
			if d:IsA("TextLabel") then tw(d, { TextTransparency = 1 }, 0.1) end
			if d:IsA("Frame") then tw(d, { BackgroundTransparency = 1 }, 0.1) end
		end
	end
	if m.dim then tw(m.dim, { BackgroundTransparency = 1 }, 0.1) end
	task.delay(0.12, function()
		if m.panel and m.panel.Parent then m.panel:Destroy() end
		if m.dim and m.dim.Parent then m.dim:Destroy() end
	end)
end
function buildServerCard(srv, index)
	local w, h = 295, 80
	local x, y = 0, (index - 1) * 90
	local card = mk("TextButton", cardScroll, x, y, w, h, LC.card, 0)
	corner(card, 10)
	card.AutoButtonColor = false
	card.Text = ""
	local cardStroke = stroke(card, LC.border, 1.5)
	local textX = 15
	if not srv.active then
		local cx, cy = 19, 19
		local c3 = dot(card, cx - 7.5, cy - 7.5, 15, LC.accent)
		c3.BackgroundTransparency = 0.85
		local c2 = dot(card, cx - 5, cy - 5, 10, LC.accent)
		c2.BackgroundTransparency = 0.65
		local c1 = dot(card, cx - 3, cy - 3, 6, LC.accent)
		c1.BackgroundTransparency = 0.1
		textX = 27
	end
	label(card, textX, 8, w - 60, 22, srv.name, 15,
		srv.active and LC.text or LC.muted)
	label(card, 15, 38, w - 50, 18, T(srv.status or "Lifetime"), 13, LC.muted)
	local iconBox = frame(card, w - 30, 10, 20, 20, Color3.fromRGB(24, 28, 36), 0, 5)
	local ph = frame(iconBox, 0, 0, 20, 20, Color3.fromRGB(52, 64, 96), 0, 5)
	local phGrad = Instance.new("UIGradient")
	phGrad.Color = ColorSequence.new(Color3.fromRGB(86, 116, 190), Color3.fromRGB(34, 44, 66))
	phGrad.Rotation = 45
	phGrad.Parent = ph
	label(ph, 0, 0, 20, 20, srv.name:sub(1, 1):upper(), 11,
		Color3.fromRGB(228, 234, 248), Enum.Font.GothamBold, Enum.TextXAlignment.Center)
	local img = Instance.new("ImageLabel")
	img.Name = "Icon"
	img.Size = UDim2.fromOffset(20, 20)
	img.BackgroundTransparency = 1
	img.ImageTransparency = 1
	img.ScaleType = Enum.ScaleType.Crop
	img.Parent = iconBox
	corner(img, 5)
	applyServerIcon(srv, img, ph)
	card.MouseEnter:Connect(function()
		tw(card, { BackgroundColor3 = Color3.fromRGB(9, 15, 22) }, 0.12)
		tw(cardStroke, { Color = Color3.fromRGB(40, 45, 56) }, 0.12)
	end)
	card.MouseLeave:Connect(function()
		tw(card, { BackgroundColor3 = LC.card }, 0.12)
		tw(cardStroke, { Color = LC.border }, 0.12)
	end)
	card.MouseButton1Click:Connect(function()
		if openServerModalImpl then openServerModalImpl(srv) end
	end)
	table.insert(cardList, card)
end
refreshCards = function()
	for _, c in ipairs(cardList) do
		if c and c.Parent then c:Destroy() end
	end
	cardList = {}
	for i, srv in ipairs(SERVERS) do
		buildServerCard(srv, i)
	end
end
openServerModalImpl = function(srv)
	closeServerModal()
	local dim = mk("TextButton", dashRoot, 0, 0, 500, 400)
	dim.BackgroundColor3 = Color3.new(0, 0, 0)
	dim.BackgroundTransparency = 0.45
	dim.Text = ""
	dim.AutoButtonColor = false
	dim.ZIndex = 50
	dim.MouseButton1Click:Connect(closeServerModal)
	local panel = mk("TextButton", dashRoot, 25, 25, 450, 350, LC.panel, 0)
	panel.AutoButtonColor = false
	panel.Text = ""
	corner(panel, 10)
	panel.ClipsDescendants = true
	panel.ZIndex = 51
	local pStroke = stroke(panel, LC.panelLine, 1, 0.55)
	pStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local pScale = Instance.new("UIScale")
	pScale.Scale = 0.94
	pScale.Parent = panel
	panel.BackgroundTransparency = 1
	tw(pScale, { Scale = 1 }, 0.24, Enum.EasingStyle.Back)
	tw(panel, { BackgroundTransparency = 0 }, 0.2, Enum.EasingStyle.Quad)
	local iconBox = frame(panel, 18, 16, 34, 34, Color3.fromRGB(24, 28, 36), 0, 8)
	local ph = frame(iconBox, 0, 0, 34, 34, Color3.fromRGB(52, 64, 96), 0, 8)
	local phGrad = Instance.new("UIGradient")
	phGrad.Color = ColorSequence.new(Color3.fromRGB(86, 116, 190), Color3.fromRGB(34, 44, 66))
	phGrad.Rotation = 45
	phGrad.Parent = ph
	label(ph, 0, 0, 34, 34, srv.name:sub(1, 1):upper(), 17,
		Color3.fromRGB(228, 234, 248), Enum.Font.GothamBold, Enum.TextXAlignment.Center)
	local img = Instance.new("ImageLabel")
	img.Size = UDim2.fromOffset(34, 34)
	img.BackgroundTransparency = 1
	img.ImageTransparency = 1
	img.ScaleType = Enum.ScaleType.Crop
	img.Parent = iconBox
	corner(img, 8)
	applyServerIcon(srv, img, ph)
	label(panel, 64, 16, 330, 24, srv.name, 17, LC.text, Enum.Font.GothamBold)
	local closeX = mk("TextButton", panel, 412, 14, 22, 22)
	closeX.BackgroundTransparency = 1
	closeX.Text = ""
	closeX.AutoButtonColor = false
	bar(closeX, 7, 7, 8, 1.5, Color3.fromRGB(170, 174, 184), 45)
	bar(closeX, 7, 7, 8, 1.5, Color3.fromRGB(170, 174, 184), -45)
	closeX.MouseButton1Click:Connect(closeServerModal)
	local info = {
		{ "Branch:", srv.branch or "Release" },
		{ "Updated:", srv.updated or "-" },
		{ "Valid Until:", srv.status or "Lifetime" },
		{ "Last Launch:", "just now" },
	}
	for i, row in ipairs(info) do
		local ry = 78 + (i - 1) * 27
		label(panel, 18, ry, 92, 20, T(row[1]), 14, LC.muted)
		label(panel, 108, ry, 130, 20, row[2], 14, Color3.fromRGB(232, 233, 238))
	end
	local cl = table.concat(srv.changelog or { "- No changelog" }, "\n")
	local clText = label(panel, 250, 78, 182, 190, cl, 12, Color3.fromRGB(162, 166, 178))
	clText.TextWrapped = true
	clText.TextYAlignment = Enum.TextYAlignment.Top
	clText.TextTruncate = Enum.TextTruncate.None
	label(panel, 18, 306, 80, 22, T("Community"), 13, LC.link)
	label(panel, 98, 306, 130, 22, T("API Documentation"), 13, LC.link)
	local branches = { "Release", "Nightly", "Beta" }
	local branchIndex = 1
	for i, b in ipairs(branches) do
		if b == (srv.branch or "Release") then branchIndex = i end
	end
	local branchBtn = mk("TextButton", panel, 312, 303, 58, 26, Color3.fromRGB(22, 26, 34), 0)
	corner(branchBtn, 6)
	branchBtn.AutoButtonColor = false
	branchBtn.Text = ""
	local branchText = label(branchBtn, 0, 0, 58, 26, branches[branchIndex], 12,
		Color3.fromRGB(220, 221, 228), nil, Enum.TextXAlignment.Center)
	branchBtn.MouseButton1Click:Connect(function()
		openLoaderMenu(branchBtn, branches, branchIndex, function(i)
			branchIndex = i
			branchText.Text = branches[i]
			srv.branch = branches[i]
		end)
	end)
	local status = label(panel, 18, 330, 280, 14, "", 11, Color3.fromRGB(240, 110, 120))
	local loadBtn = mk("TextButton", panel, 376, 303, 56, 26, LC.button, 0)
	corner(loadBtn, 6)
	loadBtn.AutoButtonColor = false
	loadBtn.Text = ""
	label(loadBtn, 0, 0, 56, 26, T("Load"), 13, Color3.new(1, 1, 1), nil, Enum.TextXAlignment.Center)
	loadBtn.MouseEnter:Connect(function()
		tw(loadBtn, { BackgroundColor3 = Color3.fromRGB(86, 134, 232) }, 0.12)
	end)
	loadBtn.MouseLeave:Connect(function()
		tw(loadBtn, { BackgroundColor3 = LC.button }, 0.12)
	end)
	loadBtn.MouseButton1Click:Connect(function()
		local function go()
			local okCall, errCall = pcall(function()
				if type(playInject) == "function" then
					playInject(srv, function() enterMenu(srv) end)
				else
					error("playInject 未初始化")
				end
			end)
			if okCall then
				task.delay(4.5, function()
					if not canvas.Visible then enterMenu(srv) end
				end)
			else
				status.Text = "进入失败: " .. tostring(errCall)
				status.TextColor3 = Color3.fromRGB(240, 110, 120)
				warn("[NL] enter failed:", errCall)
				enterMenu(srv)
			end
		end
		local url = serverScriptUrl(srv)
		if not url then
			status.Text = "未配置脚本地址，直接进入"
			status.TextColor3 = Color3.fromRGB(230, 190, 110)
			go()
			return
		end
		status.Text = "正在下载脚本…"
		status.TextColor3 = Color3.fromRGB(170, 174, 186)
		task.spawn(function()
			local ok, err = pcall(function()
				local src = httpGet(url)
				if not src then error("下载失败") end
				local fn = loadstring or load
				local chunk = fn(src)
				if not chunk then error("编译失败") end
				chunk()
			end)
			if ok then
				status.Text = "已执行"
				status.TextColor3 = Color3.fromRGB(120, 210, 150)
				task.wait(0.2)
				go()
			else
				status.Text = "执行失败: " .. tostring(err)
				status.TextColor3 = Color3.fromRGB(240, 110, 120)
			end
		end)
	end)
	modalState = { panel = panel, dim = dim, status = status }
end
openLoader = function()
	if not (loaderRoot and loaderRoot.Parent and loaderShadow and loaderCanvas) then return end
	closePopup()
	closeAccount()
	if injectRoot then
		injectRoot:Destroy()
		injectRoot = nil
	end
	if injectShadow then
		injectShadow:Destroy()
		injectShadow = nil
	end
	loaderShadow.Visible = true
	loaderCanvas.Size = UDim2.fromOffset(500, 400)
	dashRoot.Visible = true
	if islandHideAll then
		islandHideAll()
	end
	if featureListShow then
		featureListShow(false)
holder.Visible = false
	end
	dashRoot.GroupTransparency = 0
	local vp = workspace.CurrentCamera.ViewportSize
	loaderRoot.Position = UDim2.fromOffset(
		math.floor((vp.X - 516 * uiScaleValue) / 2),
		math.floor((vp.Y - 416 * uiScaleValue) / 2)
	)
	loaderRoot.Visible = true
	canvas.Visible = false
	refreshCards()
end
refreshCards()
splashRoot = Instance.new("CanvasGroup")
splashRoot.Name = "NLSplash"
splashRoot.Size = UDim2.fromOffset(200, 200)
splashRoot.Position = UDim2.fromOffset(
	math.floor((viewport.X - 200 * uiScaleValue) / 2),
	math.floor((viewport.Y - 200 * uiScaleValue) / 2)
)
splashRoot.BackgroundColor3 = LC.bg
splashRoot.BackgroundTransparency = 0
splashRoot.BorderSizePixel = 0
splashRoot.ClipsDescendants = true
splashRoot.GroupTransparency = 1
splashRoot.ZIndex = 7
splashRoot.Visible = false
splashRoot.Parent = gui
corner(splashRoot, 15)
splashContent = frame(splashRoot, 0, 0, 200, 200, Color3.new(1, 1, 1), 1)
spinner = frame(splashContent, 68, 40, 64, 64, Color3.new(1, 1, 1), 1)
SEGS = 40
for i = 0, SEGS - 1 do
	local ang = math.rad(i * (360 / SEGS))
	local r = 25
	local segLen = 5
	local segThick = 1.8
	local cx = 32 + math.cos(ang) * r
	local cy = 32 + math.sin(ang) * r
	local seg = frame(spinner,
		cx - segLen / 2, cy - segThick / 2,
		segLen, segThick, LC.accent, 1, segThick / 2)
	seg.Rotation = math.deg(ang)
	seg.BackgroundTransparency = 0.05 + 0.9 * (i / SEGS)
end
label(splashContent, 0, 116, 200, 22, "Neverlose", 15,
	Color3.fromRGB(228, 231, 240), Enum.Font.GothamBold, Enum.TextXAlignment.Center)
label(splashContent, 0, 138, 200, 16, "loading", 11,
	Color3.fromRGB(118, 122, 132), nil, Enum.TextXAlignment.Center)
game:GetService("RunService").RenderStepped:Connect(function(dt)
	if splashRoot.Visible then
		spinner.Rotation = (spinner.Rotation + dt * 240) % 360
	end
end)
booted = false
function playBoot()
	if booted then return end
	booted = true
	loaderRoot.Visible = false
	splashRoot.Visible = true
	tw(splashRoot, { GroupTransparency = 0 }, 0.22)
	local vp = workspace.CurrentCamera.ViewportSize
	local cx, cy = vp.X / 2, vp.Y / 2
	task.delay(2.0, function()
		local tx = math.floor(cx - 250 * uiScaleValue)
		local ty = math.floor(cy - 200 * uiScaleValue)
		tw(splashContent, { Position = UDim2.fromOffset(150, 100) }, 0.32, Enum.EasingStyle.Quart)
		tw(splashRoot, {
			Size = UDim2.fromOffset(500, 400),
			Position = UDim2.fromOffset(tx, ty),
		}, 0.32, Enum.EasingStyle.Quart)
		task.delay(0.26, function()
			loaderRoot.Visible = true
			dashRoot.GroupTransparency = 1
			tw(dashRoot, { GroupTransparency = 0 }, 0.3, Enum.EasingStyle.Quad)
			tw(splashRoot, { GroupTransparency = 1 }, 0.26, Enum.EasingStyle.Quad)
		end)
		task.delay(0.55, function()
			splashRoot.Visible = false
		end)
	end)
end
function buildInjectPanel(srv)
	if injectRoot then
		injectRoot:Destroy()
		injectRoot = nil
	end
	local root = Instance.new("CanvasGroup")
	root.Name = "Inject"
	root.Size = UDim2.fromOffset(350, 200)
	root.Position = UDim2.fromOffset(0, 0)
	root.BackgroundTransparency = 1
	root.GroupTransparency = 1
	root.ZIndex = 5
	root.Parent = loaderCanvas
	injectRoot = root
	local sc = Instance.new("UIScale")
	sc.Scale = 0.96
	sc.Parent = root
	local box = frame(root, 153, 52, 44, 44, Color3.fromRGB(8, 27, 48), 0, 10)
	label(box, 1, 1, 44, 44, "NL", 18, Color3.fromRGB(96, 196, 236), Enum.Font.GothamBold, Enum.TextXAlignment.Center)
label(box, 0, 0, 44, 44, "NL", 18, Color3.new(1, 1, 1), Enum.Font.GothamBold, Enum.TextXAlignment.Center)
	local barW = 150
	local track = frame(root, (350 - barW) / 2, 110, barW, 3, Color3.new(1, 1, 1), 0.94, 1.5)
	local fill = frame(track, 0, 0, 0, 3, Color3.fromRGB(237, 143, 51), 0, 1.5)
	label(root, 0, 126, 350, 16, T("The game will start automatically"), 12,
		Color3.fromRGB(115, 115, 122), nil, Enum.TextXAlignment.Center)
	return root, fill, barW
end
playInject = function(srv, after)
	closeServerModal()
	tw(dashRoot, { GroupTransparency = 1 }, 0.2)
	loaderShadow.Visible = false
	task.delay(0.22, function()
		dashRoot.Visible = false
		local p = loaderRoot.Position
		tw(loaderRoot, {
			Position = UDim2.fromOffset(p.X.Offset + 75, p.Y.Offset + 100),
		}, 0.3, Enum.EasingStyle.Quart)
		tw(loaderCanvas, { Size = UDim2.fromOffset(350, 200) }, 0.3, Enum.EasingStyle.Quart)
		task.delay(0.31, function()
			if injectShadow then injectShadow:Destroy() end
			injectShadow = softShadow(loaderRoot, 8, 8, 350, 200, 15, 16, 0.1, 0)
			local root, fill, barW = buildInjectPanel(srv)
			tw(root, { GroupTransparency = 0 }, 0.3)
			local sc = root:FindFirstChildOfClass("UIScale")
			if sc then
				tw(sc, { Scale = 1 }, 0.3, Enum.EasingStyle.Quart)
			end
			task.delay(0.12, function()
				tw(fill, { Size = UDim2.fromOffset(barW, 3) }, 1.8, Enum.EasingStyle.Quart)
			end)
			task.delay(1.8 + 1.0, function()
					if after then after() end
			end)
		end)
	end)
end
loaderDrag = mk("TextButton", loaderCanvas, 0, 0, 500, 56)
loaderDrag.BackgroundTransparency = 1
loaderDrag.Text = ""
loaderDrag.AutoButtonColor = false
loaderDrag.ZIndex = 0
makeDraggable(loaderDrag, loaderRoot)
task.spawn(function()
	if CLOUD.manifest == "" then return end
	local raw = httpGet(CLOUD.manifest)
	if not raw then return end
	local ok, data = pcall(function()
		return game:GetService("HttpService"):JSONDecode(raw)
	end)
	if not ok or type(data) ~= "table" then return end
	for _, item in ipairs(data) do
		if type(item) == "table" and item.id then
			local found = nil
			for _, s in ipairs(SERVERS) do
				if s.id == item.id then found = s end
			end
			if found then
				found.name = item.name or found.name
				found.status = item.status or found.status
				found.icon = item.icon or found.icon
				found.script = item.script or found.script
				if item.active ~= nil then found.active = item.active end
			else
				table.insert(SERVERS, {
					id = item.id,
					name = item.name or item.id,
					status = item.status or "Lifetime",
					icon = item.icon or "",
					script = item.script or "",
					active = item.active ~= false,
					branch = "Release",
					updated = item.updated or "-",
					changelog = item.changelog or { "- " },
				})
			end
		end
	end
	refreshCards()
end)
opened = true
animId = 0
function setOpen(open)
	if open == opened then return end
	opened = open
	animId = animId + 1
	local id = animId
	closePopup()
	closeAccount()
	if open then
		canvas.Visible = true
		menuFade.GroupTransparency = 1
		tw(menuFade, { GroupTransparency = 0 }, 0.24, Enum.EasingStyle.Quad)
	else
		tw(menuFade, { GroupTransparency = 1 }, 0.34, Enum.EasingStyle.Quad)
		task.delay(0.36, function()
			if id == animId and not opened then
				canvas.Visible = false
				menuFade.GroupTransparency = 0
			end
		end)
	end
end
UserInput.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.Escape then
		closeServerModal()
		closePopup()
		closeAccount()
		if closeSearch then
			closeSearch()
		end
		if closeSubPanel then
			closeSubPanel()
		end
		if currentPage == "presets" and riseShowPage then
			riseShowPage("rage")
		end
		return
	end
	if loaderRoot.Visible or splashRoot.Visible then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		setOpen(not opened)
	end
end)
playIntro = function()
	local base = canvas.Position
	scaleObj.Scale = menuScale() * 0.94
	canvas.Position = base + UDim2.fromOffset(0, 14)
	tw(scaleObj, { Scale = menuScale() }, 0.3, Enum.EasingStyle.Quart)
	tw(canvas, { Position = base }, 0.3, Enum.EasingStyle.Quart)
end
enterMenu = function(srv)
	currentServer = srv
	if srv and srv.name then
		serverSub.Text = srv.name
	end
	if islandFaceID then
		islandFaceID(LocalPlayer.DisplayName)
	end
	loaderRoot.Visible = false
	canvas.Visible = true
	opened = true
	playIntro()
end
nlButton = mk("TextButton", gui, 0, 0, 48, 48, Color3.fromRGB(13, 15, 22), 0.03)
corner(nlButton, 13)
stroke(nlButton, Color3.fromRGB(44, 48, 58), 1, 0.35)
label(nlButton, 1, 1, 48, 48, "NL", 16, Color3.fromRGB(96, 196, 236), Enum.Font.GothamBold, Enum.TextXAlignment.Center)
label(nlButton, 0, 0, 48, 48, "NL", 16, Color3.new(1, 1, 1), Enum.Font.GothamBold, Enum.TextXAlignment.Center)
nlButton.ZIndex = 20
nlButton.Position = UDim2.fromOffset(18, math.floor(viewport.Y * 0.4))
function toggleUI()
	if splashRoot.Visible or loaderRoot.Visible then return end
	if canvas.Visible then
		setOpen(false)
	else
		opened = false
		canvas.Visible = true
		setOpen(true)
	end
end
nlButton.MouseEnter:Connect(function()
	tw(nlButton, { BackgroundColor3 = Color3.fromRGB(20, 24, 34) }, 0.12)
end)
nlButton.MouseLeave:Connect(function()
	tw(nlButton, { BackgroundColor3 = Color3.fromRGB(13, 15, 22) }, 0.12)
end)
nlButton.InputBegan:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1
		and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	local startPos = input.Position
	local origin = nlButton.Position
	local moved = false
	local moveConn, endConn
	moveConn = UserInput.InputChanged:Connect(function(i)
		if i.UserInputType ~= Enum.UserInputType.MouseMovement
			and i.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		local d = i.Position - startPos
		if d.Magnitude > 8 then
			moved = true
		end
		if moved then
			nlButton.Position = UDim2.fromOffset(origin.X.Offset + d.X, origin.Y.Offset + d.Y)
		end
	end)
	endConn = UserInput.InputEnded:Connect(function(i)
		if i.UserInputType ~= Enum.UserInputType.MouseButton1
			and i.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		if moveConn then moveConn:Disconnect() end
		if endConn then endConn:Disconnect() end
		if not moved then
			toggleUI()
		end
	end)
end)
nlHidden = nil
task.spawn(function()
	while true do
		local hide = splashRoot.Visible or loaderRoot.Visible
		if hide ~= nlHidden then
			nlHidden = hide
			nlButton.Visible = not hide
		end
		task.wait(0.12)
	end
end)
canvas.Visible = false
playBoot()
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	local vp = workspace.CurrentCamera.ViewportSize
	uiScaleValue = computeScale(vp)
	scaleObj.Scale = menuScale()
	lScale.Scale = uiScaleValue
	startX = math.floor((vp.X - W * menuScale()) / 2)
	startY = math.floor((vp.Y - H * menuScale()) / 2) + MENU_DROP
	canvas.Position = UDim2.fromOffset(startX, startY)
	loaderX = math.floor((vp.X - 516 * uiScaleValue) / 2)
	loaderY = math.floor((vp.Y - 416 * uiScaleValue) / 2)
	loaderRoot.Position = UDim2.fromOffset(loaderX, loaderY)
end)
do
overlay = nil
box = nil
function closeSearch()
	if overlay then
		overlay:Destroy()
		overlay = nil
	end
	if box then
		box:Destroy()
		box = nil
	end
	if saveBtn then
		saveBtn.Visible = true
	end
	if profileChip then
		profileChip.Visible = true
	end
end
function openSearch()
	if overlay then
		closeSearch()
		return
	end
	if saveBtn then
		saveBtn.Visible = false
	end
	if profileChip then
		profileChip.Visible = false
	end
	box = mk("TextBox", shell, 168, 12, 520, 32, P.card, 0)
	corner(box, 7)
	box.Text = ""
	box.PlaceholderText = "搜索功能…"
	box.PlaceholderColor3 = Color3.fromRGB(120, 124, 136)
	box.TextColor3 = Color3.fromRGB(226, 230, 240)
	box.TextSize = 14
	box.Font = Enum.Font.Gotham
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.ClearTextOnFocus = false
	box.ZIndex = 8
	box:CaptureFocus()
	overlay = frame(shell, 160, 56, 584, 400, P.shell, 0.02, 10)
	overlay.ZIndex = 7
	stroke(overlay, P.border, 1, 0.2)
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.fromOffset(576, 392)
	scroll.Position = UDim2.fromOffset(4, 4)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 3
	scroll.CanvasSize = UDim2.fromOffset(0, 0)
	scroll.ZIndex = 8
	scroll.Parent = overlay
	local function rebuildList(query)
		for _, c in ipairs(scroll:GetChildren()) do
			if c:IsA("Frame") or c:IsA("TextButton") then
				c:Destroy()
			end
		end
		scroll.CanvasSize = UDim2.fromOffset(0, 0)
		local q = string.lower(query or "")
		if q == "" then
			return
		end
		local yOff = 0
		local shown = 0
		for _, page in pairs(NL_PAGES or {}) do
			for _, card in ipairs(page) do
				for _, row in ipairs(card.rows) do
					local name = string.lower(tostring(T(row.label)))
					if string.find(name, q, 1, true) and shown < 14 then
						local ok = pcall(function()
							buildCard(scroll, {
								x = 8, y = yOff + 18, w = 556, h = 45,
								title = " ", rows = { row },
							}, page)
						end)
						if ok then
							yOff = yOff + 52
							shown = shown + 1
						end
					end
				end
			end
		end
		if shown == 0 then
			label(scroll, 0, 24, 556, 22, "没有匹配的功能", 13,
				Color3.fromRGB(120, 126, 140), nil, Enum.TextXAlignment.Center)
		end
		scroll.CanvasSize = UDim2.fromOffset(0, yOff + 20)
	end
	box:GetPropertyChangedSignal("Text"):Connect(function()
		rebuildList(box.Text)
	end)
	box.FocusLost:Connect(function()
	end)
end
end
do
do
oldIsland = gui:FindFirstChild("Island")
if oldIsland then oldIsland.Visible = false end
oldShadow = gui:FindFirstChild("IslandShadow")
if oldShadow then oldShadow.Visible = false end
ISL_CFG = ISL_CFG or { enabled = false, hold = 2.2 }
ISL_CFG.opacity = ISL_CFG.opacity or 1
ISL_V2 = { miniW = 148, miniH = 38, maxW = 320, top = 16, rowH = 26, pad = 8 }
ISL_hist = {}
pool = {}
ISL_avHidden = false
ISL_token = 0
ISL_expireAt = 0
ISL_pill = Instance.new("CanvasGroup")
ISL_pill.Name = "IslandV2"
ISL_pill.AnchorPoint = Vector2.new(0.5, 0)
ISL_pill.Position = UDim2.new(0.5, 0, 0, ISL_V2.top)
ISL_pill.Size = UDim2.fromOffset(ISL_V2.miniW, ISL_V2.miniH)
ISL_pill.BackgroundColor3 = Color3.fromRGB(7, 8, 12)
ISL_pill.BackgroundTransparency = 0.02
ISL_pill.BorderSizePixel = 0
ISL_pill.GroupTransparency = 1
ISL_pill.ClipsDescendants = true
ISL_pill.ZIndex = 40
ISL_pill.Parent = gui
corner(ISL_pill, 22)
pillStroke = Instance.new("UIStroke")
pillStroke.Color = Color3.new(1, 1, 1)
pillStroke.Thickness = 1
pillStroke.Transparency = 0.92
pillStroke.Parent = ISL_pill
ISL_shHolder = Instance.new("Frame")
ISL_shHolder.AnchorPoint = Vector2.new(0.5, 0)
ISL_shHolder.Position = UDim2.new(0.5, 0, 0, ISL_V2.top + 2)
ISL_shHolder.Size = UDim2.fromOffset(ISL_V2.miniW, ISL_V2.miniH)
ISL_shHolder.BackgroundTransparency = 1
ISL_shHolder.ZIndex = 39
ISL_shHolder.Parent = gui
ISL_shLayers = {}
for i = 1, 8 do
	pad = i * 2
	t = 0.62 + 0.047 * i
	layer = mk("Frame", ISL_shHolder, -pad, -pad + 2, 0, 0, Color3.new(0, 0, 0), t)
	layer.Size = UDim2.new(1, pad * 2, 1, pad * 2)
	layer.Position = UDim2.fromOffset(-pad, -pad + 2)
	layer.ZIndex = 39
	corner(layer, 22)
	ISL_shLayers[i] = { obj = layer, base = t }
end
ISL_mini = Instance.new("CanvasGroup")
ISL_mini.AnchorPoint = Vector2.new(0.5, 0.5)
ISL_mini.Position = UDim2.fromScale(0.5, 0.5)
ISL_mini.Size = UDim2.fromOffset(ISL_V2.miniW, ISL_V2.miniH)
ISL_mini.BackgroundTransparency = 1
ISL_mini.ZIndex = 2
ISL_mini.Parent = ISL_pill
ISL_mark = frame(ISL_mini, 10, 9, 20, 20, Color3.fromRGB(8, 8, 11), 0, 6)
label(ISL_mark, 0, 1, 20, 20, "NL", 10, Color3.fromRGB(96, 196, 236),
	Enum.Font.GothamBold, Enum.TextXAlignment.Center)
ISL_markNL = label(ISL_mark, 0, 0, 20, 20, "NL", 10, Color3.new(1, 1, 1),
	Enum.Font.GothamBold, Enum.TextXAlignment.Center)
ISL_markCheck = frame(ISL_mark, 0, 0, 20, 20, Color3.new(1, 1, 1), 1)
ISL_markCheck.Visible = false
corner(arm(ISL_markCheck, 7, 12, 6.5, 2.2, 45, Color3.new(1, 1, 1)), 1)
corner(arm(ISL_markCheck, 14, 7, 11, 2.2, -45, Color3.new(1, 1, 1)), 1)
ISL_markTrash = frame(ISL_mark, 0, 0, 20, 20, Color3.new(1, 1, 1), 1)
ISL_markTrash.Visible = false
corner(frame(ISL_markTrash, 5.5, 7.5, 9, 7.5, Color3.new(1, 1, 1), 0, 1.5), 1.5)
corner(bar(ISL_markTrash, 4.5, 5.5, 11, 1.6, Color3.new(1, 1, 1), 0, 0), 1)
corner(bar(ISL_markTrash, 8, 3.5, 4, 1.6, Color3.new(1, 1, 1), 0, 0), 1)
function ISL_miniIcon(kind)
	ISL_markNL.Visible = (kind == nil)
	ISL_markCheck.Visible = (kind == "check")
	ISL_markTrash.Visible = (kind == "trash")
	if kind == "check" then
		ISL_mark.BackgroundColor3 = Color3.fromRGB(24, 74, 44)
	elseif kind == "trash" then
		ISL_mark.BackgroundColor3 = Color3.fromRGB(78, 30, 34)
	else
		ISL_mark.BackgroundColor3 = Color3.fromRGB(8, 27, 48)
	end
end
ISL_miniTitle = label(ISL_mini, 38, 3, 96, 18, "Neverlose", 12,
	Color3.fromRGB(230, 233, 241), Enum.Font.GothamBold)
ISL_miniSub = label(ISL_mini, 38, 21, 96, 14, "已连接", 9, Color3.fromRGB(142, 148, 164))
dot(ISL_mini, 132, 17, 4, P.accent)
ISL_body = Instance.new("CanvasGroup")
ISL_body.AnchorPoint = Vector2.new(0.5, 0.5)
ISL_body.Position = UDim2.fromScale(0.5, 0.5)
ISL_body.Size = UDim2.fromOffset(ISL_V2.maxW, 60)
ISL_body.BackgroundTransparency = 1
ISL_body.GroupTransparency = 1
ISL_body.ZIndex = 3
ISL_body.Parent = ISL_pill
ISL_avHolder = Instance.new("CanvasGroup")
ISL_avHolder.Name = "IslandAvatar"
ISL_avHolder.Size = UDim2.fromOffset(34, 34)
ISL_avHolder.BackgroundTransparency = 1
ISL_avHolder.GroupTransparency = 1
ISL_avHolder.ZIndex = 40
ISL_avHolder.Parent = gui
avBg = frame(ISL_avHolder, 0, 0, 34, 34, Color3.fromRGB(9, 10, 15), 0, 99)
stroke(avBg, Color3.new(1, 1, 1), 1, 0.9)
avImg = Instance.new("ImageLabel")
avImg.Size = UDim2.fromOffset(30, 30)
avImg.Position = UDim2.fromOffset(2, 2)
avImg.BackgroundTransparency = 1
avImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=150&h=150"
avImg.ZIndex = 2
avImg.Parent = avBg
corner(avImg, 99)
avScale = Instance.new("UIScale")
avScale.Scale = 1
avScale.Parent = avBg
dot(ISL_avHolder, 24, 24, 7, Color3.fromRGB(9, 10, 15))
dot(ISL_avHolder, 25.5, 25.5, 3.5, P.accent)
function slotY(i)
	return ISL_V2.pad + (i - 1) * ISL_V2.rowH
end
function applyOpacity()
	op = ISL_CFG.opacity or 1
	op = math.clamp(op, 0.15, 1)
	ISL_pill.BackgroundTransparency = 1 - (0.98 * op)
	pillStroke.Transparency = 1 - (0.08 * op)
	for i = 1, #ISL_shLayers do
		ISL_shLayers[i].obj.BackgroundTransparency = 1 - ((1 - ISL_shLayers[i].base) * op)
	end
end
function islandSetOpacity(v)
	ISL_CFG.opacity = math.clamp(v, 0.15, 1)
	applyOpacity()
end
function makeRow(item, index)
	root = Instance.new("CanvasGroup")
	root.Size = UDim2.fromOffset(ISL_V2.maxW - ISL_V2.pad * 2, 22)
	root.Position = UDim2.fromOffset(ISL_V2.pad, slotY(index))
	root.BackgroundTransparency = 1
	root.GroupTransparency = 1
	root.ZIndex = 4
	root.Parent = ISL_body
	badge = frame(root, 0, 3, 16, 16,
		item.on and Color3.fromRGB(48, 176, 88) or Color3.fromRGB(214, 68, 78), 0.1, 5)
	okGroup = frame(badge, 0, 0, 16, 16, Color3.new(1, 1, 1), 1)
	okGroup.Visible = item.on
	for _, d in ipairs({
		{ 7.2, 10.2, 5.4, 1.9, 45 },
		{ 10.4, 8.4, 8, 1.9, -45 },
	}) do
		corner(bar(okGroup, d[1] - d[3] / 2, d[2] - d[4] / 2, d[3], d[4],
			Color3.new(1, 1, 1), d[5], 0), d[4] / 2)
	end
	xGroup = frame(badge, 0, 0, 16, 16, Color3.new(1, 1, 1), 1)
	xGroup.Visible = not item.on
	for _, ang in ipairs({ 45, -45 }) do
		corner(bar(xGroup, 4.6, 7.05, 6.8, 1.9, Color3.new(1, 1, 1), ang, 0), 0.95)
	end
	letter = { Text = "", Groups = { ok = okGroup, x = xGroup } }
	title = label(root, 24, 0, ISL_V2.maxW - 120, 22, item.title, 12,
		Color3.fromRGB(232, 235, 243))
	track = frame(root, ISL_V2.maxW - ISL_V2.pad * 2 - 36, 4, 26, 14,
		item.on and P.accent or Color3.fromRGB(52, 56, 66), 0, 7)
	knob = dot(track, item.on and 13 or 1, 1, 12,
		item.on and P.toggleKnobOn or P.toggleKnob)
	return {
		key = item.title, on = item.on,
		root = root, badge = badge, letter = letter, title = title,
		track = track, knob = knob,
	}
end
function setRowState(r, item, animate)
	if r.on ~= item.on then
		r.on = item.on
		time = animate and 0.18 or 0
		tw(r.track, { BackgroundColor3 = item.on and P.accent or Color3.fromRGB(52, 56, 66) }, time)
		tw(r.knob, {
			Position = UDim2.fromOffset(item.on and 13 or 1, 1),
			BackgroundColor3 = item.on and P.toggleKnobOn or P.toggleKnob,
		}, time, Enum.EasingStyle.Quad)
		tw(r.badge, {
			BackgroundColor3 = item.on and Color3.fromRGB(48, 176, 88) or Color3.fromRGB(214, 68, 78),
		}, time)
		r.letter.Groups.ok.Visible = item.on
		r.letter.Groups.x.Visible = not item.on
	end
	if r.key ~= item.title then
		r.key = item.title
		r.title.Text = item.title
		r.letter.Groups.ok.Visible = item.on
		r.letter.Groups.x.Visible = not item.on
	end
end
function ISL_resize(w, h, time)
	tw(ISL_pill, { Size = UDim2.fromOffset(w, h) }, time, Enum.EasingStyle.Quint)
	tw(ISL_shHolder, { Size = UDim2.fromOffset(w, h) }, time, Enum.EasingStyle.Quint)
end
function syncRows()
	wanted = math.min(#ISL_hist, 3)
	byKey = {}
	for _, r in ipairs(pool) do
		byKey[r.key] = r
	end
	nextPool = {}
	for i = 1, wanted do
		item = ISL_hist[i]
		r = byKey[item.title]
		if r then
			byKey[item.title] = nil
		else
			r = makeRow(item, i)
			r.root.Position = UDim2.fromOffset(ISL_V2.pad, slotY(i) - 14)
			tw(r.root, { Position = UDim2.fromOffset(ISL_V2.pad, slotY(i)) }, 0.26,
				Enum.EasingStyle.Quint)
			tw(r.root, { GroupTransparency = 0 }, 0.2)
		end
		setRowState(r, item, true)
		nextPool[i] = r
		if r.root.GroupTransparency > 0.5 then
			tw(r.root, { GroupTransparency = 0 }, 0.2)
		end
	end
	for i = 1, wanted do
		r = nextPool[i]
		if r then
			tw(r.root, { Position = UDim2.fromOffset(ISL_V2.pad, slotY(i)) }, 0.26,
				Enum.EasingStyle.Quint)
		end
	end
	for _, r in ipairs(pool) do
		keep = false
		for _, k in ipairs(nextPool) do
			if k == r then keep = true end
		end
		if not keep then
			tw(r.root, { GroupTransparency = 1 }, 0.16)
			task.delay(0.2, function()
				if r.root.Parent then r.root:Destroy() end
			end)
		end
	end
	pool = nextPool
	h = ISL_V2.pad * 2 + math.max(wanted, 1) * ISL_V2.rowH - 4
	ISL_body.Size = UDim2.fromOffset(ISL_V2.maxW, h)
	ISL_resize(ISL_V2.maxW, h + 14, 0.36)
end
function ISL_collapse()
	ISL_token = ISL_token + 1
	ISL_expireAt = 0
	if ISL_miniTitle.Text == "" then
		ISL_miniTitle.Text = LocalPlayer.DisplayName
		ISL_miniSub.Text = "欢迎使用 Neverlose"
	end
	tw(ISL_body, { GroupTransparency = 1 }, 0.12)
	tw(ISL_mini, { GroupTransparency = 0 }, 0.16)
	ISL_resize(ISL_V2.miniW, ISL_V2.miniH, 0.3)
end
function islandCfgToast(cfgName, status, kind)
	if ISL_CFG and ISL_CFG.enabled == false then
		return
	end
	ISL_expireAt = 0
	ISL_token = ISL_token + 1
	my = ISL_token
	ISL_miniIcon(kind)
	ISL_miniTitle.Text = cfgName or "Unnamed"
	ISL_miniSub.Text = status or ""
	task.delay(3.2, function()
		if my ~= ISL_token then
			return
		end
		ISL_miniIcon(nil)
		ISL_miniTitle.Text = LocalPlayer.DisplayName
		ISL_miniSub.Text = "欢迎使用 Neverlose"
	end)
	tw(ISL_body, { GroupTransparency = 1 }, 0.15)
	tw(ISL_mini, { GroupTransparency = 0 }, 0.2)
	tw(ISL_pill, { GroupTransparency = 0 }, 0.2)
	applyOpacity()
	ISL_resize(ISL_V2.miniW, ISL_V2.miniH, 0.3)
end
function islandPush(title, subtitle, on)
	if ISL_CFG and ISL_CFG.enabled == false then
		ISL_expireAt = 0
		tw(ISL_pill, { GroupTransparency = 1 }, 0.2)
		for i = 1, #ISL_shLayers do
			tw(ISL_shLayers[i].obj, { BackgroundTransparency = 1 }, 0.2)
		end
		return
	end
	if #ISL_hist > 0 and ISL_hist[1].title == title then
		ISL_hist[1].on = on == true
		ISL_hist[1].subtitle = subtitle
	else
		table.insert(ISL_hist, 1, { title = title, subtitle = subtitle, on = on == true })
		while #ISL_hist > 3 do
			table.remove(ISL_hist)
		end
	end
	ISL_token = ISL_token + 1
	syncRows()
	tw(ISL_pill, { GroupTransparency = 0 }, 0.18)
	applyOpacity()
	tw(ISL_mini, { GroupTransparency = 1 }, 0.1)
	tw(ISL_body, { GroupTransparency = 0 }, 0.16)
	holdTime = 2.2
	if ISL_CFG.hold then
		holdTime = ISL_CFG.hold
	end
	ISL_expireAt = os.clock() + holdTime
	tw(avScale, { Scale = 1.1 }, 0.08, Enum.EasingStyle.Quad)
	task.delay(0.1, function()
		tw(avScale, { Scale = 1 }, 0.26, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	end)
end
game:GetService("RunService").RenderStepped:Connect(function()
	w = ISL_pill.Size.X.Offset
	h = ISL_pill.Size.Y.Offset
	ISL_avHolder.Position = UDim2.new(0.5, w / 2 + 8, 0, ISL_V2.top + (h - 34) / 2)
	if not ISL_avHidden then
		ISL_avHolder.GroupTransparency = ISL_pill.GroupTransparency
	end
	if ISL_expireAt > 0 and os.clock() >= ISL_expireAt then
		ISL_collapse()
	end
end)
applyOpacity()
function islandHideAll()
	if ISL_pill then
		ISL_pill.Visible = false
		ISL_pill.GroupTransparency = 1
	end
	if ISL_shHolder then
		ISL_shHolder.Visible = false
	end
	if ISL_avHolder then
		ISL_avHolder.Visible = false
	end
end
function islandSetEnabled(v)
	ISL_CFG.enabled = v
	if v then
		if ISL_pill then
			ISL_pill.Visible = true
			ISL_pill.GroupTransparency = 0
		end
		if ISL_shHolder then
			ISL_shHolder.Visible = true
		end
		if ISL_avHolder then
			ISL_avHolder.Visible = true
		end
		if ISL_collapse then
			ISL_collapse()
		end
		return
	end
		if islandHideAll then islandHideAll() end
	if not v then
		tw(ISL_pill, { GroupTransparency = 1 }, 0.25)
		for i = 1, #ISL_shLayers do
			tw(ISL_shLayers[i].obj, { BackgroundTransparency = 1 }, 0.25)
		end
		tw(ISL_avHolder, { GroupTransparency = 1 }, 0.25)
	end
end
faceGroup = Instance.new("CanvasGroup")
faceGroup.AnchorPoint = Vector2.new(0.5, 0.5)
faceGroup.Position = UDim2.fromScale(0.5, 0.5)
faceGroup.Size = UDim2.fromOffset(140, 140)
faceGroup.BackgroundTransparency = 1
faceGroup.GroupTransparency = 1
faceGroup.ZIndex = 5
faceGroup.Parent = ISL_pill
faceScale = Instance.new("UIScale")
faceScale.Scale = 0.86
faceScale.Parent = faceGroup
fFace = frame(faceGroup, 0, 0, 140, 140, Color3.new(1, 1, 1), 1)
corner(bar(fFace, 52, 50, 3, 7, Color3.new(1, 1, 1), 0, 0.05), 2)
corner(bar(fFace, 85, 50, 3, 7, Color3.new(1, 1, 1), 0, 0.05), 2)
corner(bar(fFace, 59, 84, 22, 3, Color3.new(1, 1, 1), 0, 0.05), 2)
fScan = frame(faceGroup, 22, 24, 96, 2, Color3.new(1, 1, 1), 0.05, 1)
fOk = frame(faceGroup, 0, 0, 140, 140, Color3.new(1, 1, 1), 1)
fOk.Visible = false
arm(fOk, 56, 62, 15, 3.6, 42, Color3.new(1, 1, 1))
arm(fOk, 74, 50, 26, 3.6, -45, Color3.new(1, 1, 1))
fOkScale = Instance.new("UIScale")
fOkScale.Scale = 0.7
fOkScale.Parent = fOk
fName = label(faceGroup, 0, 92, 140, 16, "", 11,
	Color3.fromRGB(150, 156, 172), nil, Enum.TextXAlignment.Center)
fName.TextTransparency = 1
fWelcome = label(faceGroup, 0, 110, 140, 18, "欢迎使用 Neverlose！", 12,
	Color3.fromRGB(240, 243, 250), Enum.Font.GothamBold, Enum.TextXAlignment.Center)
fWelcome.TextTransparency = 1
ISL_pillCorner = ISL_pill:FindFirstChildOfClass("UICorner")
faceToken = 0
function islandFaceID(name)
	if ISL_pill then
		ISL_pill.Visible = true
		if ISL_shHolder then
			ISL_shHolder.Visible = true
			for i = 1, #ISL_shLayers do
				ISL_shLayers[i].obj.BackgroundTransparency = 0.9
			end
		end
	end
	faceToken = faceToken + 1
	my = faceToken
	ISL_expireAt = 0
	ISL_pill.GroupTransparency = 1
	ISL_avHidden = true
	ISL_avHolder.GroupTransparency = 1
	tw(ISL_pill, { GroupTransparency = 0 }, 0.25)
	applyOpacity()
	ISL_resize(140, 140, 0.4)
	if ISL_pillCorner then
		tw(ISL_pillCorner, { CornerRadius = UDim.new(0, 34) }, 0.4, Enum.EasingStyle.Quint)
	end
	tw(ISL_mini, { GroupTransparency = 1 }, 0.12)
	tw(ISL_body, { GroupTransparency = 1 }, 0.12)
	tw(faceGroup, { GroupTransparency = 0 }, 0.2)
	fOk.Visible = false
	fFace.Visible = true
	fScan.Visible = true
	fScan.BackgroundTransparency = 0.05
	fScan.Position = UDim2.fromOffset(22, 24)
	tw(fScan, { Position = UDim2.fromOffset(22, 114) }, 0.72, Enum.EasingStyle.Sine)
	task.delay(0.74, function()
		if my ~= faceToken then
			return
		end
		tw(fScan, { BackgroundTransparency = 1 }, 0.1)
		fFace.Visible = false
		fOk.Visible = true
		fOkScale.Scale = 0.7
		tw(fOkScale, { Scale = 1 }, 0.26, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	end)
	task.delay(1.05, function()
		if my ~= faceToken then
			return
		end
		fName.Text = name or LocalPlayer.DisplayName
		tw(fName, { TextTransparency = 0 }, 0.26)
	end)
	task.delay(1.28, function()
		if my ~= faceToken then
			return
		end
		tw(fWelcome, { TextTransparency = 0 }, 0.26)
	end)
	task.delay(2.7, function()
		if my ~= faceToken then
			return
		end
		tw(faceGroup, { GroupTransparency = 1 }, 0.22)
		tw(fName, { TextTransparency = 1 }, 0.2)
		tw(fWelcome, { TextTransparency = 1 }, 0.2)
		ISL_miniIcon(nil)
		ISL_miniTitle.Text = name or LocalPlayer.DisplayName
		ISL_miniSub.Text = "欢迎使用 Neverlose"
		tw(ISL_mini, { GroupTransparency = 0 }, 0.22)
		ISL_avHidden = false
		tw(ISL_avHolder, { GroupTransparency = 0 }, 0.22)
		if ISL_CFG and ISL_CFG.enabled == false then
			task.delay(0.8, function()
				if ISL_CFG.enabled == false and islandHideAll then
					islandHideAll()
				end
			end)
		end
		ISL_resize(ISL_V2.miniW, ISL_V2.miniH, 0.32)
		if ISL_pillCorner then
			tw(ISL_pillCorner, { CornerRadius = UDim.new(0, 22) }, 0.32, Enum.EasingStyle.Quint)
		end
	end)
end
task.delay(3.2, function()
	if splashRoot and splashRoot.Visible then
		return
	end
	if loaderRoot and loaderRoot.Visible then
		return
	end
	if injectRoot or (dashRoot and dashRoot.Visible) then
		return
	end
	islandPush("Neverlose", "Ready", true)
end)
end
do
TOAST_CFG = TOAST_CFG or { opacity = 0.92, hold = 2.6, pos = "left", scale = 1 }
toasts = {}
MAX_TOASTS = 4
CARD_W, CARD_H, GAP = 262, 62, 10
holderX = 18
function slotX(w, vpx)
	if (TOAST_CFG.pos or "left") == "right" then
		return (vpx or viewport.X) - 18 - w
	end
	return holderX
end
function applyScale(t)
	local k = TOAST_CFG.scale or 1
	local sc = t.root:FindFirstChildOfClass("UIScale")
	if sc then
		sc.Scale = k
	end
end
function layout()
	local k = TOAST_CFG.scale or 1
	local w = CARD_W * k
	local h = CARD_H * k
	local x = slotX(w, workspace.CurrentCamera.ViewportSize.X)
	for i, t in ipairs(toasts) do
		applyScale(t)
		local vy = workspace.CurrentCamera.ViewportSize.Y
	local targetY = vy - 24 - h - (i - 1) * (h + GAP)
		tw(t.root, { Position = UDim2.fromOffset(x, targetY) }, 0.22, Enum.EasingStyle.Quint)
	end
end
function toastRelayout()
	layout()
end
function removeToast(t)
	for i, v in ipairs(toasts) do
		if v == t then
			table.remove(toasts, i)
			break
		end
	end
	local k = TOAST_CFG.scale or 1
	local outEdge = ((TOAST_CFG.pos or "left") == "right") and 26 or -26
	tw(t.root, { GroupTransparency = 1 }, 0.2)
	tw(t.root, {
		Position = UDim2.fromOffset(slotX(CARD_W * k) + outEdge, t.root.Position.Y.Offset),
	}, 0.2)
	task.delay(0.24, function()
		if t.root.Parent then
			t.root:Destroy()
		end
	end)
	layout()
end
function toastSetOpacity(v)
	TOAST_CFG.opacity = v
	for _, t in ipairs(toasts) do
		if t.root and t.root.Parent then
			t.root.BackgroundTransparency = 1 - (0.94 * v)
		end
	end
end
function notify(title, subtitle, on)
	local root = Instance.new("CanvasGroup")
	local k0 = TOAST_CFG.scale or 1
	root.Size = UDim2.fromOffset(CARD_W, CARD_H)
	local edge = ((TOAST_CFG.pos or "left") == "right") and 26 or -26
	local vx = workspace.CurrentCamera.ViewportSize.X
	local vy2 = workspace.CurrentCamera.ViewportSize.Y
	root.Position = UDim2.fromOffset(slotX(CARD_W * k0, vx) + edge, vy2 - 24 - CARD_H * k0)
	root.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
	root.BackgroundTransparency = 1 - (0.94 * TOAST_CFG.opacity)
	root.GroupTransparency = 0
	root.ZIndex = 70
	root.Parent = gui
	corner(root, 12)
	local us = Instance.new("UIScale")
	us.Scale = k0
	us.Parent = root
	local strokeObj = Instance.new("UIStroke")
	strokeObj.Color = Color3.fromRGB(44, 48, 60)
	strokeObj.Thickness = 1
	strokeObj.Transparency = 0.25
	strokeObj.Parent = root
	local accentBar = frame(root, 0, 12, 3, CARD_H - 24,
		on and P.accent or Color3.fromRGB(230, 74, 86), 0, 2)
	accentBar.ZIndex = 71
	local circle = frame(root, 14, (CARD_H - 34) / 2, 34, 34,
		on and Color3.fromRGB(38, 62, 118) or Color3.fromRGB(76, 32, 38), 0, 99)
	circle.ZIndex = 71
	local icColor = on and Color3.fromRGB(150, 194, 255) or Color3.fromRGB(255, 138, 148)
	local function iconStroke(cx, cy, len, thick, angle)
		local b = bar(circle, cx - len / 2, cy - thick / 2, len, thick, icColor, angle, 0)
		corner(b, thick / 2)
		b.ZIndex = 73
		return b
	end
	if on then
		iconStroke(15.5, 21.5, 8, 2.6, 45)
		iconStroke(22, 18, 13, 2.6, -45)
	else
		iconStroke(17, 17, 13, 2.6, 45)
		iconStroke(17, 17, 13, 2.6, -45)
	end
	label(root, 60, 8, CARD_W - 74, 20, title or "模块", 15,
		Color3.fromRGB(232, 235, 243), Enum.Font.GothamBold).ZIndex = 71
	label(root, 60, 31, CARD_W - 74, 18, subtitle or "", 13,
		Color3.fromRGB(150, 155, 168)).ZIndex = 71
	table.insert(toasts, 1, { root = root })
	while #toasts > MAX_TOASTS do
		removeToast(toasts[#toasts])
	end
	layout()
	local vxf = workspace.CurrentCamera.ViewportSize.X
	tw(root, { Position = UDim2.fromOffset(slotX(CARD_W * k0, vxf), root.Position.Y.Offset) }, 0.26,
		Enum.EasingStyle.Quint)
	local me = toasts[1]
	task.delay(TOAST_CFG.hold or 2.6, function()
		removeToast(me)
	end)
end
end
end
function closeSubPanel()
	if subPanelRoot then
		subPanelRoot:Destroy()
		subPanelRoot = nil
	end
	if subPanelScrim then
		subPanelScrim:Destroy()
		subPanelScrim = nil
	end
end
function openSubPanel(anchor, title, subRows)
	closePopup()
	local sc = canvas:FindFirstChildOfClass("UIScale").Scale
	local ax = (anchor.AbsolutePosition.X - canvas.AbsolutePosition.X) / sc
	local ay = (anchor.AbsolutePosition.Y - canvas.AbsolutePosition.Y) / sc
	local w = 300
	local rowsH = #subRows * 37 + 8
	local h = rowsH + 26
	local x = math.clamp(ax - w - 12, 10, W - w - 10)
	local y = math.clamp(ay - 10, 10, H - h - 10)
	if closeSubPanel then
		closeSubPanel()
	end
	local scrim = mk("TextButton", canvas, 0, 0, W, H)
	scrim.BackgroundTransparency = 1
	scrim.Text = ""
	scrim.AutoButtonColor = false
	scrim.ZIndex = 38
	scrim.MouseButton1Click:Connect(function()
		if closeSubPanel then
			closeSubPanel()
		end
	end)
	local holder = frame(canvas, x, y, w, h, P.card, 0.02, 12)
	holder.ZIndex = 41
	stroke(holder, P.border, 1, 0.1)
	label(holder, 14, 8, w - 28, 16, title or "", 11, Color3.fromRGB(150, 156, 172))
	buildCard(holder, { x = 8, y = 26, w = w - 16, h = rowsH, title = " ", rows = subRows }, nil)
	subPanelRoot = holder
	subPanelScrim = scrim
	holder.BackgroundTransparency = 1
	holder.Position = UDim2.fromOffset(x + 6, y)
	tw(holder, { BackgroundTransparency = 0.02, Position = UDim2.fromOffset(x, y) }, 0.14,
		Enum.EasingStyle.Cubic)
end
do
FLIST = FLIST or {
	pos = 220,
	x = -18,
	size = 15,
	opacity = 1,
	shadow = 0.55,
	line = true,
	glowColor = nil,
	glowAsShadow = false,
	animated = true,
	enabled = true,
	title = false,
	anchor = "right",
	mode = "two",
	hue = 0.15,
	gapGlow = false,
	glowPow = 1,
	speed = 0.5,
	c1 = Color3.fromRGB(206, 140, 255),
	c2 = Color3.fromRGB(246, 140, 214),
}
NL_FEATURES = NL_FEATURES or {}
flHolder = Instance.new("Frame")
flHolder.Name = "FeatureList"
flHolder.AnchorPoint = Vector2.new(1, 0)
flHolder.Size = UDim2.fromOffset(360, 200)
flHolder.BackgroundTransparency = 1
flHolder.ZIndex = 60
flHolder.Parent = gui
flHolder.Position = UDim2.new(1, FLIST.x or -18, 0, FLIST.pos)
flHolder.Visible = true
function flLerp(a, b, t)
	return Color3.new(
		a.R + (b.R - a.R) * t,
		a.G + (b.G - a.G) * t,
		a.B + (b.B - a.B) * t
	)
end
function featureListRefresh()
	if not flHolder then
		return
	end
	for _, ch in ipairs(flHolder:GetChildren()) do
		if ch ~= flDragBtn and (ch:IsA("Frame") or ch:IsA("TextLabel")
			or ch:IsA("TextButton") or ch:IsA("CanvasGroup")) then
			ch:Destroy()
		end
	end
	flGrads = {}
	flRowCols = {}
	flGradBase = flGradBase or {}
	flPrevY = flPrevY or {}
	local arr, seen, seenName = {}, {}, {}
	for _, v in ipairs(NL_FEATURES) do
		local k = v.key or v.name
		if type(v.name) == "string" and v.name ~= "" and not seen[k] and not seenName[v.name] then
			seen[k] = true
			seenName[v.name] = true
			arr[#arr + 1] = v
		end
	end
	table.sort(arr, function(a, b)
		if #a.name == #b.name then
			return a.name < b.name
		end
		return #a.name > #b.name
	end)
	local size = math.clamp(FLIST.size or 15, 10, 24)
	local op = math.clamp(FLIST.opacity or 1, 0.2, 1)
	local lh = size + 10
	local n = #arr
	local totalH = 30 + math.max(n, 1) * lh
	flHolder.Size = UDim2.fromOffset(360, totalH)
	if (FLIST.anchor or "right") == "left" then
		FLIST.anchor = "right"
	end
	local anchor = FLIST.anchor or "right"
	if anchor == "free" then
		flHolder.Position = UDim2.new(1, FLIST.x or -18, 0, FLIST.pos or 220)
	else
		flHolder.Position = UDim2.new(1, -18, 0, 20)
	local csc = canvas and canvas:FindFirstChildOfClass("UIScale")
	if csc then
		local us2 = flHolder:FindFirstChildOfClass("UIScale")
		if not us2 then
			us2 = Instance.new("UIScale")
			us2.Parent = flHolder
		end
		us2.Scale = csc.Scale
	end
	end
	local leftMode = false
	local headerH = 30
	if FLIST.title == false then
		headerH = 0
	end
	local iconW = size + 5
	if FLIST.title == false then
		headerH = 0
	end
	local icon = frame(flHolder, 340 - iconW, 2, iconW, iconW, Color3.fromRGB(8, 8, 11), 0, 6)
	label(icon, 0, 1, iconW, iconW, "NL", math.max(8, size - 6), Color3.fromRGB(96, 196, 236),
		Enum.Font.GothamBold, Enum.TextXAlignment.Center)
	label(icon, 0, 0, iconW, iconW, "NL", math.max(8, size - 6), Color3.new(1, 1, 1),
		Enum.Font.GothamBold, Enum.TextXAlignment.Center)
	local title = label(flHolder, 0, 0, math.max(120, 332 - iconW - 10), 28, "Neverlose",
		math.max(9, size - 2), Color3.fromRGB(226, 229, 238), Enum.Font.GothamBold,
		Enum.TextXAlignment.Right)
	title.ZIndex = 61
	local titleVis = (FLIST.title ~= false)
	icon.Visible = titleVis
	title.Visible = titleVis
	if FLIST.line ~= false then
		local ln = frame(flHolder, 358, (FLIST.title == false and 0 or 30), 2,
			math.max(n, 1) * lh, FLIST.glowColor or FLIST.c1, 0, 1)
		ln.ZIndex = 59
	end
	for i = 1, n do
		local item = arr[i]
		local t = (n <= 1) and 0 or (i - 1) / (n - 1)
		local c1, c2
		if FLIST.mode == "solid" then
			c1 = FLIST.c1
			c2 = FLIST.c1
		elseif FLIST.mode == "rainbow" then
			c1 = Color3.fromHSV(0.62 + t * 0.45, 0.38, 1)
			c2 = Color3.fromHSV(0.62 + math.min(t * 0.45 + 0.08, 0.45), 0.38, 1)
		else
			c1 = flLerp(FLIST.c1, FLIST.c2, t)
			c2 = flLerp(FLIST.c1, FLIST.c2, math.min(t + 0.12, 1))
		end
		local fsz = size
		local function meas(sz)
			local ok, v = pcall(function()
				return game:GetService("TextService"):GetTextSize(item.name, sz,
					Enum.Font.GothamBold, Vector2.new(1200, 100)).X
			end)
			return (ok and v) or (#item.name * sz * 0.66)
		end
		local raw = meas(fsz)
		while raw > 320 and fsz > 10 do
			fsz = fsz - 1
			raw = meas(fsz)
		end
		local w = math.clamp(raw + 24, 90, 340)
		local y = (FLIST.title == false and 0 or 30) + (i - 1) * lh
		local px = leftMode and 0 or (358 - w)
		local rowKey = item.key or item.name
		local row = Instance.new("Frame")
		row.Name = "row_" .. tostring(i)
		row.Size = UDim2.fromOffset(360, lh)
		row.BackgroundTransparency = 1
		row.ZIndex = 62
		row.Parent = flHolder
		local oldY = flPrevY[rowKey]
		if oldY then
			row.Position = UDim2.fromOffset(0, oldY)
			tw(row, { Position = UDim2.fromOffset(0, y) }, 0.18, Enum.EasingStyle.Quad)
		else
			local side = leftMode and -46 or 46
			row.Position = UDim2.fromOffset(side, y)
			tw(row, { Position = UDim2.fromOffset(0, y) }, 0.26, Enum.EasingStyle.Quint)
		end
		flPrevY[rowKey] = y
		y = 0
		local plate = frame(row, px, y, w, lh, Color3.fromRGB(14, 12, 18),
			0.62 - 0.32 * op, 3)
		plate.ZIndex = 62
		local gMul = 1
		local onlyOuter = (not FLIST.gapGlow) and (i ~= 1) and (i ~= n)
		for gi = 1, 3 do
			local pad = gi * 2
			local gl = frame(row, px - pad, y - pad, w + pad * 2, lh + pad * 2, c1, 1, 3)
			gl.ZIndex = 60
			if onlyOuter then
				gl.Size = UDim2.fromOffset(w + pad * 2, lh - 2)
				gl.Position = UDim2.fromOffset(px - pad, 1)
			end
			gl.BackgroundTransparency = 1 - (math.clamp(FLIST.shadow or 0.55, 0, 1)
				* 0.30 * gMul * (1 - (gi - 1) * 0.22))
		end
		local txt = label(plate, 10, 0, w - 20, lh, item.name, fsz,
			Color3.new(1, 1, 1), Enum.Font.GothamBold,
			leftMode and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right)
		txt.ZIndex = 63
		txt.TextTransparency = 0
		local grad = Instance.new("UIGradient")
		grad.Color = ColorSequence.new(c1, c2)
		grad.Rotation = 0
		grad.Parent = txt
		flGrads[#flGrads + 1] = grad
		flRowCols[#flGrads] = { c1 = c1, c2 = c2 }
		grad:SetAttribute("h1", c1.R)
		flGradBase[grad] = { c1 = c1, c2 = c2 }
	end
	flHolder.Visible = FLIST.enabled and true or false
end
function featureListSet(name, on, key)
	if type(name) ~= "string" or name == "" then
		return
	end
	key = key or name
	local found
	for i, v in ipairs(NL_FEATURES) do
		if (v.key or v.name) == key then
			found = i
		end
	end
	if on and not found then
		NL_FEATURES[#NL_FEATURES + 1] = { name = name, key = key }
	elseif not on and found then
		table.remove(NL_FEATURES, found)
	else
		return
	end
	featureListRefresh()
end
function featureListShow(v)
	FLIST.enabled = v and true or false
	if flHolder then
		flHolder.Visible = FLIST.enabled
	end
end
do
	local btn = mk("TextButton", flHolder, 0, 0, 360, 200)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.ZIndex = 70
	flDragBtn = btn
	local dragging, sx, sy, ox, oy
	btn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			if (FLIST.anchor or "right") ~= "free" then
				return
			end
			dragging = true
			sx, sy = input.Position.X, input.Position.Y
			ox = flHolder.Position.X.Offset
			oy = flHolder.Position.Y.Offset
		end
	end)
	UserInput.InputChanged:Connect(function(input)
		if not dragging then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			local dx = input.Position.X - sx
			local dy = input.Position.Y - sy
			FLIST.pos = oy + dy
			FLIST.x = ox + dx
			flHolder.Position = UDim2.new(1, ox + dx, 0, oy + dy)
		end
	end)
	UserInput.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end
featureListRefresh()
game:GetService("RunService").RenderStepped:Connect(function(dt)
	if not (FLIST and FLIST.animated) or FLIST.mode ~= "rainbow" then
		return
	end
	local period = math.clamp(2.5 - (FLIST.speed or 0.5) * 2.0, 0.5, 2.5)
	flHue = ((flHue or 0) + dt / period) % 1
	for g, base in pairs(flGradBase or {}) do
		if g.Parent and base then
			local h1, s1, v1 = Color3.toHSV(base.c1)
			local h2, s2, v2 = Color3.toHSV(base.c2)
			g.Color = ColorSequence.new(
				Color3.fromHSV((h1 + flHue) % 1, s1, v1),
				Color3.fromHSV((h2 + flHue) % 1, s2, v2))
		end
	end
end)
task.spawn(function()
	while task.wait(0.5) do
		if flHolder then
			if flHolder.Parent ~= gui then
				flHolder.Parent = gui
			end
			if FLIST.enabled and not flHolder.Visible then
				flHolder.Visible = true
				warn("[NL] list restored (visibility)")
			end
			if flHolder.Position.X.Offset < -1000 then
				flHolder.Position = UDim2.new(1, FLIST.x or -18, 0, FLIST.pos or 220)
				warn("[NL] list restored (position)")
			end
		end
	end
end)
end
do
root = nil
function build()
	if root then
		root:Destroy()
		root = nil
	end
	root = Instance.new("CanvasGroup")
	UI_EDIT_ROOT = root
	UI_EDIT_PANEL = root
	root.Size = UDim2.fromOffset(560, 560)
	root.AnchorPoint = Vector2.new(0.5, 0.5)
	root.Position = UDim2.fromScale(0.5, 0.5)
	root.BackgroundColor3 = P.card
	root.BackgroundTransparency = 0.02
	root.ZIndex = 80
	root.Parent = gui
	corner(root, 16)
	local st = Instance.new("UIStroke")
	st.Color = P.border
	st.Thickness = 1
	st.Transparency = 0.15
	st.Parent = root
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, 0, 1, -64)
	scroll.Position = UDim2.fromOffset(0, 58)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 4
	scroll.ScrollBarImageColor3 = Color3.fromRGB(120, 126, 140)
	scroll.ScrollBarImageTransparency = 0.35
	scroll.CanvasSize = UDim2.fromOffset(0, 820)
	scroll.ScrollingEnabled = true
	scroll.ZIndex = 5
	scroll.Active = true
	scroll.Parent = root
	local logo = frame(root, 18, 16, 26, 26, Color3.fromRGB(8, 8, 11), 0, 7)
	label(logo, 1, 1, 26, 26, "NL", 11, Color3.fromRGB(96, 196, 236), Enum.Font.GothamBold, Enum.TextXAlignment.Center)
label(logo, 0, 0, 26, 26, "NL", 11, Color3.new(1, 1, 1), Enum.Font.GothamBold, Enum.TextXAlignment.Center)
	label(root, 54, 18, 200, 22, "UI EDIT", 16, Color3.fromRGB(236, 239, 246),
		Enum.Font.GothamBold)
	local dragBar = mk("TextButton", root, 0, 0, 356, 46)
	dragBar.BackgroundTransparency = 1
	dragBar.Text = ""
	dragBar.AutoButtonColor = false
	dragBar.ZIndex = 3
	local flDStart, flDOrigin
	dragBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			flDStart = input.Position
			flDOrigin = root.Position
		end
	end)
	UserInput.InputChanged:Connect(function(input)
		if not flDStart then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			local d = input.Position - flDStart
			root.Position = UDim2.fromOffset(flDOrigin.X.Offset + d.X, flDOrigin.Y.Offset + d.Y)
		end
	end)
	UserInput.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			flDStart = nil
		end
	end)
	local closeBtn = mk("TextButton", root, 522, 16, 24, 24)
	closeBtn.ZIndex = 200
	closeBtn.BackgroundTransparency = 1
	closeBtn.Text = ""
	closeBtn.AutoButtonColor = false
	for _, ang in ipairs({ 45, -45 }) do
		corner(bar(closeBtn, 5, 11, 14, 1.8, Color3.fromRGB(176, 180, 192), ang, 0), 0.9)
	end
	closeBtn.MouseButton1Click:Connect(function()
		if closeUIEdit then
			closeUIEdit()
		end
	end)
	buildCard(scroll, {
		x = 16, y = 8, w = 528, h = 82, title = "ISLAND", silent = true,
		rows = {
			{ label = "Island", kind = "toggle", on = (ISL_CFG and ISL_CFG.enabled) or false, cb = function(v)
				if islandSetEnabled then
					islandSetEnabled(v)
				end
			end },
			{ label = "Opacity", kind = "slider", amount = 0.94, value = "94%",
				num = { min = 30, max = 100, value = 94, step = 1, decimals = 0, suffix = "%" },
				cb = function(rel)
					if islandSetOpacity then
						islandSetOpacity(0.3 + rel * 0.7)
					end
				end },
		},
	}, nil)
	buildCard(scroll, {
		x = 16, y = 106, w = 528, h = 156, title = "NOTIFICATION", silent = true,
		rows = {
			{ label = "Position", kind = "button", value = ((TOAST_CFG and TOAST_CFG.pos == "right") and "右下" or "左下"),
				cb = function()
					if TOAST_CFG then
						TOAST_CFG.pos = (TOAST_CFG.pos == "right") and "left" or "right"
						if toastRelayout then
							toastRelayout()
						end
					end
					return ((TOAST_CFG and TOAST_CFG.pos == "right") and "右下" or "左下")
				end },
			{ label = "Size", kind = "slider", amount = 0.43, value = "100%",
				num = { min = 70, max = 140, value = 100, step = 1, decimals = 0, suffix = "%" },
				cb = function(rel)
					if TOAST_CFG then
						TOAST_CFG.scale = 0.7 + rel * 0.7
						if toastRelayout then
							toastRelayout()
						end
					end
				end },
			{ label = "Opacity", kind = "slider", amount = 0.88, value = "92%",
				num = { min = 30, max = 100, value = 92, step = 1, decimals = 0, suffix = "%" },
				cb = function(rel)
					if toastSetOpacity then
						toastSetOpacity(0.3 + rel * 0.7)
					end
				end },
			{ label = "Time", kind = "slider", amount = 0.32, value = "2.6s",
				num = { min = 1, max = 6, value = 2.6, step = 0.1, decimals = 1, suffix = "s" },
				cb = function(rel)
					if TOAST_CFG then
						TOAST_CFG.hold = 1 + rel * 5
					end
				end },
		},
	}, nil)
	buildCard(scroll, {
		x = 16, y = 276, w = 528, h = 267, title = "FEATURE LIST", silent = true,
		rows = {
			{ label = "Enabled", kind = "toggle", on = (FLIST and FLIST.enabled) or false, cb = function(v)
				if featureListShow then
					featureListShow(v)
				end
			end },
			{ label = "Title", kind = "toggle", on = (FLIST and FLIST.title) or false, cb = function(v)
				if FLIST then
					FLIST.title = v
					if featureListRefresh then
						featureListRefresh()
					end
				end
			end },
			{ label = "Position", kind = "button",
				value = (FLIST and FLIST.anchor == "free" and "自由") or "右上",
				cb = function()
					local cur = FLIST.anchor or "right"
					if cur == "free" then
						FLIST.anchor = "right"
					else
						FLIST.anchor = "free"
					end
					if featureListRefresh then
						featureListRefresh()
					end
					return (FLIST.anchor == "free" and "自由") or "右上"
				end },
			{ label = "Size", kind = "slider", amount = 0.36, value = "15",
				num = { min = 10, max = 24, value = 15, step = 1, decimals = 0, suffix = "" },
				cb = function(rel)
					if FLIST then
						FLIST.size = math.floor(10 + rel * 14 + 0.5)
						if featureListRefresh then
							featureListRefresh()
						end
					end
				end },
			{ label = "Opacity", kind = "slider", amount = 1, value = "100%",
				num = { min = 20, max = 100, value = 100, step = 1, decimals = 0, suffix = "%" },
				cb = function(rel)
					if FLIST then
						FLIST.opacity = 0.2 + rel * 0.8
						if featureListRefresh then
							featureListRefresh()
						end
					end
				end },
			{ label = "Shadow", kind = "slider", amount = 0.55, value = "55%",
				num = { min = 0, max = 100, value = 55, step = 1, decimals = 0, suffix = "%" },
				cb = function(rel)
					if FLIST then
						FLIST.shadow = rel
						if featureListRefresh then
							featureListRefresh()
						end
					end
				end },
			{ label = "Color", kind = "button", value = "双色",
				cb = function()
					if not FLIST then
						return "双色"
					end
					if FLIST.mode == "two" then
						FLIST.mode = "rainbow"
					elseif FLIST.mode == "rainbow" then
						FLIST.mode = "solid"
					else
						FLIST.mode = "two"
					end
					if featureListRefresh then
						featureListRefresh()
					end
					return (FLIST.mode == "two" and "双色") or (FLIST.mode == "rainbow" and "彩虹") or "单色"
				end },
			{ label = "Glow Color", kind = "button", value = "跟随渐变",
				cb = function()
					if not FLIST then
						return
					end
					openColorPicker(root, FLIST.glowColor or FLIST.c1, function(c)
						FLIST.glowColor = c
						if featureListRefresh then
							featureListRefresh()
						end
					end)
				end },
			{ label = "Glow As Shadow", kind = "toggle", on = false, cb = function(v)
				if FLIST then
					FLIST.glowAsShadow = v
					if featureListRefresh then
						featureListRefresh()
					end
				end
			end },
			{ label = "Side Line", kind = "toggle", on = true, cb = function(v)
				if FLIST then
					FLIST.line = v
					if featureListRefresh then
						featureListRefresh()
					end
				end
			end },
			{ label = "Speed", kind = "slider", amount = 0.5, value = "0.55s",
				num = { min = 1, max = 10, value = 5, step = 1, decimals = 0, suffix = "" },
				cb = function(rel)
					if FLIST then
						FLIST.speed = rel
					end
				end },
			{ label = "Gap Glow", kind = "toggle", on = false, cb = function(v)
				if FLIST then
					FLIST.gapGlow = v
					if featureListRefresh then
						featureListRefresh()
					end
				end
			end },
			{ label = "Animated", kind = "toggle", on = true, cb = function(v)
				if FLIST then
					FLIST.animated = v
				end
			end },
		},
	}, nil)
	local vp = workspace.CurrentCamera.ViewportSize
	local fitS = math.min(vp.X / 460, vp.Y / 800, 1)
	if fitS < 0.995 then
		local us = Instance.new("UIScale")
		us.Scale = fitS
		us.Parent = root
		root.Position = UDim2.fromOffset(
			math.max((vp.X - 420 * fitS) / 2, 8),
			math.max((vp.Y - 763 * fitS) / 2, 8))
	end
	local us = root:FindFirstChildOfClass("UIScale")
	if not us then
		us = Instance.new("UIScale")
		us.Parent = root
	end
	root.GroupTransparency = 1
	us.Scale = 0.86
	tw(us, { Scale = 1 }, 0.28, Enum.EasingStyle.Back)
	tw(root, { GroupTransparency = 0 }, 0.24, Enum.EasingStyle.Quad)
end
function openUIEdit()
	if closePopup then
		closePopup()
	end
	if closeSubPanel then
		closeSubPanel()
	end
	for _, ch in ipairs(canvas:GetChildren()) do
		if ch:IsA("TextButton") and ch.Size.X.Offset >= W - 2 and ch.BackgroundTransparency == 1 then
			ch:Destroy()
		end
	end
	UI_EDIT_OPEN = true
	if canvas then
		canvas.Visible = false
	end
	build()
end
function closeUIEdit()
	UI_EDIT_OPEN = nil
	local panel = UI_EDIT_PANEL
	UI_EDIT_PANEL = nil
	UI_EDIT_ROOT = nil
	if panel then
		local us = panel:FindFirstChildOfClass("UIScale")
		if us then
			tw(us, { Scale = 0.86 }, 0.22, Enum.EasingStyle.Quad)
		end
		tw(panel, { GroupTransparency = 1 }, 0.22, Enum.EasingStyle.Quad)
		task.delay(0.24, function()
			if panel then
				panel:Destroy()
			end
			if canvas then
				canvas.Visible = true
				if playIntro then
					playIntro()
				end
			end
		end)
	else
		if canvas then
			canvas.Visible = true
			if playIntro then
				playIntro()
			end
		end
	end
end
end
task.defer(function()
	if islandHideAll then
		islandHideAll()
	end
	if featureListShow then
		featureListShow(false)
	end
end)
function confirmZoom(z)
	local lay = mk("TextButton", gui, 0, 0, 4000, 2400)
	lay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	lay.BackgroundTransparency = 0.55
	lay.Text = ""
	lay.AutoButtonColor = false
	lay.ZIndex = 300
	local box = frame(lay, 0, 0, 380, 156, P.card, 0.03, 10)
	box.AnchorPoint = Vector2.new(0.5, 0.5)
	box.Position = UDim2.fromScale(0.5, 0.5)
	box.ZIndex = 301
	stroke(box, P.border, 1, 0.3)
	label(box, 20, 22, 340, 24, "确定要更改为此缩放吗？", 16, P.textTitle,
		Enum.Font.GothamBold, Enum.TextXAlignment.Center).ZIndex = 302
	label(box, 20, 52, 340, 40, "选\"否\"将恢复默认 100%\n（防止缩放过大后无法操作）", 13,
		P.textMuted, nil, Enum.TextXAlignment.Center).ZIndex = 302
	local function close()
		lay:Destroy()
	end
	local yes = mk("TextButton", box, 44, 104, 130, 34, P.accent, 0)
	yes.Text = ""
	yes.AutoButtonColor = false
	yes.ZIndex = 302
	corner(yes, 6)
	label(yes, 0, 0, 130, 34, "是", 14, Color3.new(1, 1, 1), Enum.Font.GothamBold,
		Enum.TextXAlignment.Center).ZIndex = 303
	yes.MouseButton1Click:Connect(function()
		applyMenuZoom(z)
		close()
	end)
	local no = mk("TextButton", box, 206, 104, 130, 34, P.control, 0)
	no.Text = ""
	no.AutoButtonColor = false
	no.ZIndex = 302
	corner(no, 6)
	label(no, 0, 0, 130, 34, "否", 14, P.text, Enum.Font.GothamBold,
		Enum.TextXAlignment.Center).ZIndex = 303
	no.MouseButton1Click:Connect(function()
		applyMenuZoom(1)
		close()
	end)
end
-- ============================================================
-- 启动引擎；预设保存时同步落盘引擎参数
-- ============================================================
NL_API.start()
do
	local origSave = NL_SAVE_CONFIG
	NL_SAVE_CONFIG = function()
		if origSave then pcall(origSave) end
		pcall(NL_API.save)
	end
end

-- UI 操作入口（便于外部调试与后续扩展）
do
	local hook = {
		showPage = showPage,
		riseShowPage = riseShowPage,
		toggleUI = toggleUI,
		notify = notify,
		setLanguage = setLanguage,
		openSearch = openSearch,
		openLoader = openLoader,
		closeLoaderWindow = closeLoaderWindow,
		enterMenu = enterMenu,
		setOpen = setOpen,
		canvas = canvas,
		pageFrames = pageFrames,
		getBind = function(name) return BINDS and BINDS[name] end,
		setBind = function(name, key) BINDS[name] = key return key end,
	}
	NL_API.UI = hook
	getgenv().NLUI_UI = hook
end


-- ============================================================
-- YZ HUB 功能搬运：Obsidian 兼容层（只登记控件，不建自己的窗口）
-- ============================================================

-- 安全等待：不在对局内时返回占位实例，避免整个脚本卡在 WaitForChild
function WX_SAFE_WAIT(parent, name, kind)
	local inst = parent:FindFirstChild(name)
	if inst then return inst end
	local ok, res = pcall(function() return parent:WaitForChild(name, 3) end)
	if ok and res then return res end
	local dummy = Instance.new(kind or 'Instance')
	dummy.Name = name
	pcall(function() dummy.Parent = parent end)
	return dummy
end
--!nolint
--[[
    Obsidian 兼容层（无界面注册器）
    ------------------------------------------------------------------
    YZ HUB 的功能代码是按 Obsidian 的 UI API 写的：
        local Toggle = Tab:AddToggle('Index', { Text=..., Default=..., Callback=... })
    这里把整套 API 换成「只登记、不渲染」的实现：
      * 控件照常创建，Value / Callback / OnChanged 行为与真库一致
      * 结构（Tab -> Groupbox -> 控件）记录到 WX_UI，交给 NL UI 渲染
    这样功能逻辑一行都不用改。
]]

local WX_UI = {
    tabs = {},
    byIndex = {},
}

local function newElement(kind, index, opts, group)
    local el = {
        Type = kind,
        Index = index,
        Text = opts.Text or opts.Name or tostring(index),
        Visible = true,
        Value = opts.Default,
        Min = opts.Min,
        Max = opts.Max,
        Rounding = opts.Rounding,
        Values = opts.Values,
        Multi = opts.Multi or false,
        Key = opts.Key or opts.DefaultKey,
        Mode = opts.Mode,
        Callback = opts.Callback,
        _changed = nil,
    }

    if kind == "slider" then
        el.Value = opts.Default or opts.Min or 0
    elseif kind == "toggle" then
        el.Value = opts.Default and true or false
    elseif kind == "colorpicker" then
        el.Value = opts.Default or Color3.fromRGB(255, 255, 255)
        el.Transparency = opts.Transparency or 0
    elseif kind == "keypicker" then
        el.Value = opts.Default or nil
        el.Mode = opts.Mode or "Toggle"
    elseif kind == "dropdown" then
        local first
        if type(opts.Values) == "table" then
            for _, v in ipairs(opts.Values) do first = first or v end
            if not first then
                for _, v in pairs(opts.Values) do first = first or v end
            end
        end
        el.Value = opts.Default ~= nil and opts.Default or first
        if el.Multi then el.Value = {} end
    end

    function el:GetValue()
        return self.Value
    end

    function el:SetValue(value, ignoreCallback)
        if self.Multi and self.Type == "dropdown" and type(value) == "table" then
            self.Value = {}
            for k, v in pairs(value) do self.Value[k] = v end
        else
            self.Value = value
        end
        if not ignoreCallback then
            if self.Callback then pcall(self.Callback, self.Value, self) end
            if self._changed then pcall(self._changed, self.Value, self) end
        end
    end

    function el:OnChanged(fn)
        self._changed = fn
    end

    function el:SetVisible(visible)
        self.Visible = visible and true or false
    end

    function el:SetText(text)
        self.Text = text
    end

    function el:SetColor(color)
        self.Value = color
        if self.Callback then pcall(self.Callback, color, self) end
    end

    function el:AddValue(value)
        if not self.Values then self.Values = {} end
        table.insert(self.Values, value)
    end

    function el:RemoveValue(value)
        if type(self.Values) ~= "table" then return end
        for i, v in ipairs(self.Values) do
            if v == value then
                table.remove(self.Values, i)
                return
            end
        end
    end

    function el:SetValues(values)
        self.Values = values
    end

    function el:GetValues()
        return self.Values
    end

    -- 未知方法一律当空操作，避免个别版本的方法差异中断整个功能加载
    return setmetatable(el, {
        __index = function(_, key)
            if type(key) == "string" and key:match("^[A-Z]") then
                return function() end
            end
            return nil
        end,
    })
end

local function newGroup(name)
    local group = {
        Name = name or "Group",
        controls = {},
    }

    local function add(kind, index, opts)
        if type(index) == "table" and opts == nil then
            opts, index = index, index.Index or index.Name or ("opt" .. (#group.controls + 1))
        end
        opts = opts or {}
        local el = newElement(kind, index, opts, group)
        group.controls[#group.controls + 1] = el
        if index then
            if kind == "toggle" then
                Toggles[index] = el
            elseif kind == "slider" or kind == "dropdown" or kind == "colorpicker" or kind == "keypicker" then
                Options[index] = el
            end
            WX_UI.byIndex[index] = el
        end
        return el
    end

    function group:AddToggle(index, opts) return add("toggle", index, opts) end
    function group:AddSlider(index, opts) return add("slider", index, opts) end
    function group:AddDropdown(index, opts) return add("dropdown", index, opts) end
    function group:AddButton(index, opts) return add("button", index, opts) end
    function group:AddColorPicker(index, opts) return add("colorpicker", index, opts) end
    function group:AddKeyPicker(index, opts) return add("keypicker", index, opts) end
    function group:AddLabel(text) return add("label", nil, { Text = type(text) == "table" and text.Text or text }) end
    function group:AddDivider() return add("divider", nil, {}) end
    function group:AddInput(index, opts) return add("input", index, opts) end
    function group:AddImage(index, opts) return add("image", index, opts) end
    function group:AddItem(index, opts) return add("item", index, opts) end
    function group:AddMobileShortcut(index, opts) return add("button", index, opts) end

    function group:AddDependencyBox()
        local dep = newGroup((name or "Group") .. " 依赖")
        function dep:SetupDependencies() end
        return dep
    end

    return setmetatable(group, {
        __index = function(_, key)
            if type(key) == "string" and key:match("^Add[A-Z]") then
                return function() return nil end
            end
            return nil
        end,
    })
end

local Library = {}
Library.Options = Options
Library.Toggles = Toggles
Library.Scheme = { AccentColor = Color3.fromRGB(120, 160, 255) }
Library.AccentColor = Library.Scheme.AccentColor
Library.Unloaded = false

-- 功能体把这些当成真实控件/实例用，这里给可用的占位实例
local function dummy(className, name)
    local inst = Instance.new(className)
    inst.Name = name
    return inst
end
Library.ScreenGui = dummy("ScreenGui", "NLUI_YZ_Dummy")
Library.BackgroundShade = dummy("Frame", "NLUI_YZ_Shade")
Library.KeybindFrame = dummy("Frame", "NLUI_YZ_Keybind")
Library.BackgroundImageLabel = dummy("TextLabel", "NLUI_YZ_BgImage")

-- 注意：功能体把 Library.IsMobile 当布尔值用（Default = Library.IsMobile）
do
    local uis = game:GetService("UserInputService")
    Library.IsMobile = (uis.TouchEnabled and not uis.MouseEnabled) and true or false
end

function Library:SetIconModule() end
function Library:Unload()
    self.Unloaded = true
end

function Library:CreateWindow(opts)
    local window = { Tabs = {}, Options = Options, Toggles = Toggles }
    function window:AddTab(info)
        local tab = {
            Name = info.Name or ("Tab" .. (#WX_UI.tabs + 1)),
            Icon = info.Icon,
            groups = {},
        }
        local function newGroupFor(name)
            local g = newGroup(name)
            tab.groups[#tab.groups + 1] = g
            return g
        end
        function tab:AddLeftGroupbox(name) return newGroupFor(name) end
        function tab:AddRightGroupbox(name) return newGroupFor(name) end
        function tab:AddLeftTabbox()
            local box = { tabs = {} }
            function box:AddTab(name)
                local g = newGroupFor(name)
                return g
            end
            return box
        end
        function tab:AddRightTabbox()
            local box = { tabs = {} }
            function box:AddTab(name)
                local g = newGroupFor(name)
                return g
            end
            return box
        end
        function tab:AddItem(index, opts)
            local g = newGroupFor(tostring(index or "item"))
            return g:AddItem(index, opts)
        end
        WX_UI.tabs[#WX_UI.tabs + 1] = tab
        window.Tabs[tab.Name] = tab
        return tab
    end
    return setmetatable(window, {
        __index = function(_, key)
            if type(key) == "string" and key:match("^[A-Z]") then
                return function() end
            end
            return nil
        end,
    })
end

function Library:Notify(opts)
    if WX_NOTIFY then
        pcall(WX_NOTIFY, type(opts) == "table" and (opts.Title or "") or tostring(opts),
            type(opts) == "table" and (opts.Text or opts.Description or "") or "")
    end
end

function Library:IsMobileMode()
    return Library.IsMobile
end

function Library:OnUnload(fn) self._unload = fn end
function Library:AddDraggableLabel(text)
    local label = { Text = text }
    function label:SetText(t) self.Text = t end
    function label:SetVisible() end
    function label:Remove() end
    return label
end
function Library:AddMobileShortcut() return { Remove = function() end } end

Library.KeybindFrame = nil
Library.ScreenGui = nil
Library.BackgroundShade = nil

ThemeManager = {}
function ThemeManager:SetFolder() end
function ThemeManager:ApplyToTab() end

SaveManager = {}
function SaveManager:SetFolder() end
function SaveManager:Folder() return nil end
function SaveManager:AutoloadLabel() return { SetText = function() end } end
function SaveManager:RefreshConfigList() end
function SaveManager:Save() end
function SaveManager:Load() end
function SaveManager:SetIgnoreIndexes() end

-- 版本差异兜底：未知的大写开头成员一律当空方法，避免个别 API 差异中断整个功能加载
local function permissive(tbl)
    return setmetatable(tbl, {
        __index = function(_, key)
            if type(key) == "string" and key:match("^[A-Z]") then
                return function() end
            end
            return nil
        end,
    })
end

permissive(Library)
permissive(ThemeManager)
permissive(SaveManager)

_G.WX_UI = WX_UI


-- ============================================================
-- YZ HUB 功能本体（原逻辑，一行未改，仅替换了 UI 库）
-- ============================================================
local WX_OK, WX_ERR = pcall(function()

-- 重复执行时先清掉旧界面，避免叠层
do
	local hosts = {}
	local ok, h = pcall(function() return gethui and gethui() end)
	if ok and h then hosts[#hosts + 1] = h end
	pcall(function()
		local lp = game:GetService('Players').LocalPlayer
		if lp then
			hosts[#hosts + 1] = lp:FindFirstChild('PlayerGui')
		end
	end)
	pcall(function() hosts[#hosts + 1] = game:GetService('CoreGui') end)
	for _, host in ipairs(hosts) do
		if host then
			local old
			pcall(function() old = host:FindFirstChild('Obsidian') end)
			if old then pcall(function() old:Destroy() end) end
		end
	end
end

local function __wxCompile(name, source)
	local fn, err = (loadstring or load)(source, '=' .. name)
	if not fn then error('[WX] ' .. name .. ' 载入失败：' .. tostring(err)) end
	local ok, res = pcall(fn)
	if not ok then error('[WX] ' .. name .. ' 执行失败：' .. tostring(res)) end
	return res
end

--==================== 桥接：脚本使用的全局表 ====================
Options = Library.Options
Toggles = Library.Toggles
Library.AccentColor = Library.Scheme.AccentColor

--==================== 兼容封装 ====================
-- Obsidian 的下拉框不支持 Default 字段，这里创建后补上默认值
local function WXDrop(parent, idx, info)
	local el = parent:AddDropdown(idx, info)
	if el and info and info.Default ~= nil then
		local def = info.Default
		if type(def) == 'number' then
			def = info.Values and info.Values[def]
		end
		if def ~= nil then
			pcall(function() el:SetValue(def) end)
		end
	end
	return el
end

-- 对外暴露调试句柄（方便其他脚本或排错时读取）
pcall(function()
	local g = getgenv and getgenv() or _G
	g.WX = {
		Library = Library,
		Options = Library.Options,
		Toggles = Library.Toggles,
		ThemeManager = ThemeManager,
		SaveManager = SaveManager,
	}
end)

-- 水印（库内实现已废弃且会每帧刷警告，这里换成静默版本）
do
	local wm
	local function ensure()
		if not wm then
			wm = Library:AddDraggableLabel('')
			wm:SetVisible(false)
		end
		return wm
	end
	function Library:SetWatermark(text)
		local label = ensure()
		local s = tostring(text or '')
		if label.__wxLast == s then return end
		label.__wxLast = s
		pcall(function() label:SetText(s) end)
	end
	function Library:SetWatermarkVisibility(visible)
		local label = ensure()
		pcall(function() label:SetVisible(visible and true or false) end)
	end
end

-- 界面库由本文件顶部内置提供（Library / ThemeManager / SaveManager）

local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')
local Debris = game:GetService('Debris')
local Teams = game:GetService('Teams')
local Workspace = game:GetService('Workspace')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local CollectionService = game:GetService('CollectionService')
local Lighting = game:GetService('Lighting')

local GunRemotes = WX_SAFE_WAIT(ReplicatedStorage, 'GunRemotes', 'Folder')
local ShootEvent = WX_SAFE_WAIT(GunRemotes, 'ShootEvent', 'RemoteEvent')
local FuncReload = WX_SAFE_WAIT(GunRemotes, 'FuncReload', 'RemoteFunction')

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ===== 移动端适配：设备检测 + 统一圆心 =====
-- 手机上 UserInputService:GetMouseLocation() 会跟随触摸点，
-- 拖动视角时 FOV 圈会跟着手指到处乱飘，这里统一用屏幕中心。
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

local function getAimCenter()
	if IS_MOBILE then
		local cam = workspace.CurrentCamera
		local vp = cam and cam.ViewportSize or Vector2.new(1920, 1080)
		return Vector2.new(vp.X / 2, vp.Y / 2)
	end
	return UserInputService:GetMouseLocation()
end

-- 通用飞行输入：兼容虚拟摇杆（手机）/ 键盘 / 手柄
local PlayerControls = nil
local function ensureControls()
    if PlayerControls then return PlayerControls end
    local ok, module = pcall(function()
        return require(LP:WaitForChild('PlayerScripts', 5):WaitForChild('PlayerModule', 5))
    end)
    if ok and module then
        local ok2, controls = pcall(function() return module:GetControls() end)
        if ok2 and controls then PlayerControls = controls end
    end
    return PlayerControls
end
task.spawn(ensureControls) -- 预热，避免第一次飞行时卡一下
local isAlive, getConfig, updateHudAmmo

local Window = Library:CreateWindow({
    Title = 'YZ HUB',
    Icon = "https://i.postimg.cc/3N0r5RR6/Screenshot-2026-10-25-01-54-08-59-9d26c6446fd7bb8e41d99b6262b17def.jpg",
    Center = true,
    AutoShow = true,
    Footer = 'YZ HUB',
    Size = UDim2.fromOffset(800, 620),
    Font = Enum.Font.Gotham,
    NotifySide = 'Right',
    ShowCustomCursor = false,
})

-- UI 置顶：把主界面显示层级拉到最高，永远盖在游戏 UI 和脚本内其它 HUD/ESP 之上
do
    local Gui = Library.ScreenGui
    if Gui then
        Gui.DisplayOrder = 10000000
        if Gui.ZIndexBehavior ~= Enum.ZIndexBehavior.Sibling then
            Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        end
    end
end

-- ====================== UI 背景图片 ======================
-- 图片直接内嵌在脚本里（base64，1100x580 JPEG，约 103KB）：不依赖图床和网络，国内环境也能稳定显示。
-- 流程：base64 解码 -> writefile 落盘 -> getcustomasset 转成游戏内资产 -> 铺到窗口底层。
-- 内嵌数据万一解码失败（个别执行器对超长字符串有限制），自动回退到网络图源。
do
    local BG_FILE = 'YZHUB/ui_background_v3.jpg'

    --[[ 1100x580 / JPEG 质量 72 ]]
    local BG_B64 = [====[
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
]====]

    -- 想用自己的图：把素材 ID（例如 1234567890）填到这里，优先级最高，不依赖执行器的文件功能
    local BG_ASSET_ID = ''

    -- 图源兜底：内嵌数据不可用时才联网（走图片代理，避免直连图床被拦）
    local BG_URLS = {
        'https://wsrv.nl/?url=i.postimg.cc/pXvYfvnW/zhe-feng-bi-zhi-er-ci-yuan-dong-man-ren-wu.jpg&w=1100&output=jpg',
        'https://i.postimg.cc/pXvYfvnW/zhe-feng-bi-zhi-er-ci-yuan-dong-man-ren-wu.jpg',
    }

    local B64_LOOKUP = {}
    do
        local Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
        for i = 1, #Chars do B64_LOOKUP[Chars:byte(i)] = i - 1 end
    end

    local function b64decode(str)
        str = str:gsub('%s', '')
        local out = {}
        local i, n = 1, #str
        while i + 3 <= n do
            local c1, c2, c3, c4 = str:byte(i, i + 3)
            local v1, v2 = B64_LOOKUP[c1], B64_LOOKUP[c2]
            if not v1 or not v2 then break end
            if c3 == 61 then
                out[#out + 1] = string.char(v1 * 4 + math.floor(v2 / 16))
                break
            end
            local v3 = B64_LOOKUP[c3]
            if not v3 then break end
            if c4 == 61 then
                out[#out + 1] = string.char(v1 * 4 + math.floor(v2 / 16), (v2 % 16) * 16 + math.floor(v3 / 4))
                break
            end
            local v4 = B64_LOOKUP[c4]
            if not v4 then break end
            out[#out + 1] = string.char(
                v1 * 4 + math.floor(v2 / 16),
                (v2 % 16) * 16 + math.floor(v3 / 4),
                (v3 % 4) * 64 + v4
            )
            i = i + 4
        end
        return table.concat(out)
    end

    -- 只认真正的图片文件头，JPEG 还要求结尾带 EOI：
    -- 截断的图写进缓存后能"转换成功"但永远显示不出来，必须先拦下来
    local EOI = string.char(255, 217)
    local function looksLikeImage(bytes)
        if type(bytes) ~= 'string' or #bytes < 2048 then return false end
        local b1, b2, b3, b4 = bytes:byte(1, 4)
        if b1 == 0xFF and b2 == 0xD8 then
            return string.find(bytes:sub(#bytes - 15), EOI, 1, true) ~= nil
        end
        if b1 == 0x89 and b2 == 0x50 and b3 == 0x4E and b4 == 0x47 then return true end  -- PNG
        if b1 == 0x52 and b2 == 0x49 and b3 == 0x46 and b4 == 0x46 then return true end  -- WEBP
        return false
    end

    local function httpGet(url)
        local ok, body = pcall(function() return game:HttpGet(url, true) end)
        if ok and type(body) == 'string' and #body > 2048 then return body end
        ok, body = pcall(function() return game:HttpGet(url) end)
        if ok and type(body) == 'string' and #body > 2048 then return body end
        return nil
    end

    -- 界面是否真的挂上了图：不能只看 pcall，返回 true 才算成功
    local function isApplied()
        local ok, state = pcall(function()
            local label = Library.BackgroundImageLabel
            if not label then return false end
            local image = label.Image
            return Library.HasBackgroundImage == true and type(image) == 'string' and #image > 0
        end)
        return ok and state == true
    end

    local function applyImage(value)
        if type(value) ~= 'string' or value == '' then return false end
        if not pcall(function() Window:SetBackgroundImage(value) end) then return false end
        return isApplied()
    end

    -- 二进制落盘 -> 转成游戏内可用资产；返回 asset 或 nil + 原因
    local function toAsset(bytes)
        if type(writefile) ~= 'function' then return nil, '执行器不支持 writefile' end

        local converter = getcustomasset or getsynasset or getasset
        if type(converter) ~= 'function' then return nil, '执行器不支持 getcustomasset' end

        if type(isfolder) == 'function' and type(makefolder) == 'function' and not isfolder('YZHUB') then
            pcall(makefolder, 'YZHUB')
        end

        local paths = { 'YZHUB/ui_background_v3.jpg', 'YZHUB_ui_bg_v3.jpg' }
        local lastReason = '背景图写入本地失败'

        for _, path in ipairs(paths) do
            if pcall(writefile, path, bytes) then
                local okAsset, asset = pcall(converter, path)
                if okAsset and type(asset) == 'string' and #asset > 0 then
                    return asset
                end
                lastReason = 'getcustomasset 转换失败'
            end
        end

        return nil, lastReason
    end

    local function applyBytes(bytes)
        local asset, reason = toAsset(bytes)
        if not asset then return false, reason end
        if applyImage(asset) then return true end
        return false, '挂到界面上失败（asset: ' .. tostring(asset) .. '）'
    end

    -- 终极兜底：没有可用图片时，给窗口加一层渐变，至少不是一片死黑
    local function buildFallbackBackdrop()
        pcall(function()
            local base = Library.BackgroundImageLabel and Library.BackgroundImageLabel.Parent
            if not base or base:FindFirstChild('YZHUB_BgGradient') then return end
            base.BackgroundColor3 = Color3.fromRGB(20, 18, 44)
            local gradient = Instance.new('UIGradient')
            gradient.Name = 'YZHUB_BgGradient'
            gradient.Rotation = 135
            gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(48, 30, 96)),
                ColorSequenceKeypoint.new(0.55, Color3.fromRGB(20, 18, 44)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(9, 9, 18)),
            })
            gradient.Parent = base
        end)
    end

    -- 网络图源的尝试时间戳：自动重试期间不重复拉同一个地址，避免狂刷请求
    local lastNetTry = 0

    -- 完整走一遍：素材 ID -> 内嵌数据 -> 网络图源
    local function loadBackground()
        if BG_ASSET_ID ~= '' then
            local id = tostring(BG_ASSET_ID)
            if not string.find(id, 'rbxassetid://', 1, true) then
                id = 'rbxassetid://' .. id
            end
            if applyImage(id) then return true end
            warn('[YZ HUB] 背景图素材 ID 无效：' .. id)
        end

        -- 1) 内嵌数据优先：不走网络
        local bytes = b64decode(BG_B64)
        if looksLikeImage(bytes) then
            local ok, reason = applyBytes(bytes)
            if ok then return true end
            warn('[YZ HUB] 背景图（内嵌）应用失败：' .. tostring(reason))
        else
            warn('[YZ HUB] 背景图内嵌数据异常（解码后 ' .. tostring(#bytes) .. ' 字节）')
        end

        -- 2) 回退：网络图源（15 秒内只拉一次，自动重试期间不反复请求）
        if tick() - lastNetTry > 15 then
            lastNetTry = tick()
            for _, url in ipairs(BG_URLS) do
                local body = httpGet(url)
                if looksLikeImage(body) then
                    local ok, reason = applyBytes(body)
                    if ok then return true end
                    warn('[YZ HUB] 背景图（网络）应用失败：' .. tostring(reason))
                else
                    warn('[YZ HUB] 背景图图源不可用：' .. url)
                end
            end
        end

        return false
    end

    -- 挂上之后再看一眼游戏有没有真的把图解码出来（执行器的 asset 有时 Roblox 读不了）
    local function auditLoaded()
        task.delay(3, function()
            local label = Library.BackgroundImageLabel
            if not label or label.Image == '' then return end
            local ok, loaded = pcall(function() return label.IsLoaded end)
            if ok and loaded == false then
                warn('[YZ HUB] 背景图已挂到界面上，但游戏没有解码成功（执行器返回的 asset 可能不被 Roblox 识别）')
            end
        end)
    end

    -- 统一入口：已经有图就跳过，没有才重新走一遍完整链路
    local function ensureBackground()
        if isApplied() then return true end
        if loadBackground() then
            auditLoaded()
            return true
        end
        return false
    end

    -- 手动重载入口（界面设置里的按钮，只是极端情况下的兜底，正常不需要点）
    _G.YZHUB_ReloadBackground = function()
        local ok = ensureBackground()
        if not ok then buildFallbackBackdrop() end
        return ok
    end

    -- 自动加载：一直重试到成功为止（最长约 40 秒），不需要手动点任何按钮。
    -- 手机执行器刚注入时文件系统 / 资产服务往往要几秒才就绪，一次性尝试很容易全部落空。
    task.spawn(function()
        local waited = 0
        while waited < 180 do
            if ensureBackground() then return end
            local step = (waited < 5) and 0.6 or ((waited < 60) and 2 or 5)
            task.wait(step)
            waited = waited + step
        end

        buildFallbackBackdrop()
        warn('[YZ HUB] 背景图加载失败：内嵌数据与全部网络图源都不可用，已切到渐变背景')
        pcall(function()
            Library:Notify({
                Title = '背景图未加载',
                Description = '执行器可能不支持 getcustomasset，已启用渐变背景；可在「界面设置」点「重新加载背景图」再试一次',
                Time = 8,
            })
        end)
    end)

    -- 额外补挂：菜单第一次打开 / 角色刷新（地图加载完）时，如果还没图就再试一次
    task.spawn(function()
        local label = Library.BackgroundImageLabel
        local holder = label and label.Parent
        if holder then
            pcall(function()
                holder:GetPropertyChangedSignal('Visible'):Connect(function()
                    if holder.Visible and not isApplied() then
                        task.spawn(ensureBackground)
                    end
                end)
            end)
        end

        if LP and LP.CharacterAdded then
            LP.CharacterAdded:Connect(function()
                task.wait(1.5)
                if not isApplied() then task.spawn(ensureBackground) end
            end)
        end
    end)
end

-- 启用 Lucide 图标（UI 库原有的图标源）：先读本地缓存，缓存坏了或没有就联网拉，多个地址依次尝试
do
    local CACHE = 'WX_lucide_icons.lua'
    local SOURCES = {
        'https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Icons.lua',
        'https://cdn.jsdelivr.net/gh/deividcomsono/Obsidian@main/Icons.lua',
        'https://raw.gitmirror.com/deividcomsono/Obsidian/main/Icons.lua',
    }

    -- 校验并加载：必须是能返回 { GetAsset = function } 的模块
    local function tryLoad(src)
        if type(src) ~= 'string' or #src < 100 then return nil end
        local fn = (loadstring or load)(src)
        if not fn then return nil end
        local ok, mod = pcall(fn)
        if ok and type(mod) == 'table' and type(mod.GetAsset) == 'function' then
            return mod
        end
        return nil
    end

    local mod

    -- 1) 本地缓存（缓存损坏时会自动走下面的联网重试）
    if isfile and isfile(CACHE) then
        local ok, data = pcall(readfile, CACHE)
        if ok then mod = tryLoad(data) end
    end

    -- 2) 联网拉取，逐个地址尝试，成功即写入缓存
    if not mod then
        for _, url in ipairs(SOURCES) do
            local ok, data = pcall(function() return game:HttpGet(url) end)
            if ok then
                mod = tryLoad(data)
                if mod then
                    if writefile then pcall(writefile, CACHE, data) end
                    break
                end
            end
        end
    end

    if mod then
        Library:SetIconModule(mod)
    else
        warn('[WX] Lucide 图标模块未加载，标签页图标回退为内置矢量图标')
    end
end
local Tabs = {
    Info            = Window:AddTab({ Name = '信息',     Icon = 'info' }),
    Combat          = Window:AddTab({ Name = '战斗',     Icon = 'sword' }),
    Visuals         = Window:AddTab({ Name = '视觉',     Icon = 'eye' }),
    Movement        = Window:AddTab({ Name = '移动',     Icon = 'move' }),
    Misc            = Window:AddTab({ Name = '杂项',     Icon = 'package' }),
    ['UI Settings'] = Window:AddTab({ Name = '界面设置', Icon = 'settings' }),
}

-- ====================== 信息页（第一个标签页，布局取自 Revenant 的信息主页） ======================
do
    local InfoTab = Tabs.Info
    local MarketplaceService = game:GetService('MarketplaceService')
    local TeleportService = game:GetService('TeleportService')
    local Stats = game:GetService('Stats')

    local function notify(msg)
        pcall(function()
            Library:Notify({ Title = '信息', Description = msg, Time = 2 })
        end)
    end

    -- 执行器名称
    local executorName = '未知'
    pcall(function()
        local name = identifyexecutor and identifyexecutor()
        if type(name) == 'string' and name ~= '' then
            executorName = name
        end
    end)

    -- 左侧：玩家
    local UserBox = InfoTab:AddLeftGroupbox('玩家', 'user')
    pcall(function()
        UserBox:AddImage('InfoAvatar', {
            Image = ('rbxthumb://type=AvatarHeadShot&id=%d&w=420&h=420'):format(LP.UserId),
            Height = 150,
            ScaleType = Enum.ScaleType.Crop,
        })
    end)
    UserBox:AddLabel('玩家: <b>' .. tostring(LP.DisplayName) .. '</b> (@' .. tostring(LP.Name) .. ')')
    UserBox:AddLabel('用户 ID: <b>' .. tostring(LP.UserId) .. '</b>')
    UserBox:AddLabel('执行器: <b>' .. executorName .. '</b>')
    UserBox:AddDivider()
    local sessionLabel = UserBox:AddLabel('本次会话: <b>00:00:00</b>')
    UserBox:AddDivider()
    UserBox:AddButton({
        Text = '复制用户名',
        Func = function()
            pcall(function() setclipboard(LP.Name) end)
            notify('用户名已复制')
        end,
    })
    UserBox:AddButton({
        Text = '复制主页链接',
        Func = function()
            pcall(function()
                setclipboard(('https://www.roblox.com/users/%d/profile'):format(LP.UserId))
            end)
            notify('主页链接已复制')
        end,
    })

    -- 左侧：关于
    local AboutBox = InfoTab:AddLeftGroupbox('关于', 'info')
    AboutBox:AddLabel('脚本: <b>YZ HUB 监狱人生</b>')
    AboutBox:AddLabel('作者: <b>y（QQ2071274105）</b>')
    AboutBox:AddLabel('UI: <b>Obsidian</b>')
    AboutBox:AddDivider()
    AboutBox:AddLabel('祝你游玩愉快😋😋😋', true)

    -- 右侧：会话信息
    local SessionBox = InfoTab:AddRightGroupbox('会话信息', 'server')
    local gameLabel = SessionBox:AddLabel('游戏: <b>加载中…</b>')
    local playersLabel = SessionBox:AddLabel('在线人数: <b>--</b>')
    local jobLabel = SessionBox:AddLabel('服务器 ID: <b>--</b>')
    local pingLabel = SessionBox:AddLabel('延迟: <b>-- ms</b>')
    SessionBox:AddButton({
        Text = '重新加入本服',
        Func = function()
            local ok = pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
            end)
            if not ok then
                notify('重进失败，请稍后再试')
            end
        end,
    })
    SessionBox:AddDivider({ Text = '通过服务器 ID 加入' })
    SessionBox:AddInput('InfoJoinJobId', {
        Text = '服务器 ID',
        Placeholder = '粘贴服务器 ID',
        Finished = true,
        Callback = function(text)
            if type(text) ~= 'string' or text == '' then return end
            local ok = pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, text, LP)
            end)
            notify(ok and '正在加入…' or '服务器 ID 无效')
        end,
    })

    -- 右侧：支持
    local SupportBox = InfoTab:AddRightGroupbox('支持', 'circle-help')
    SupportBox:AddLabel('遇到问题请去找作者反馈', true)
    SupportBox:AddDivider()
    SupportBox:AddButton({
        Text = '复制服务器 ID',
        Func = function()
            pcall(function() setclipboard(tostring(game.JobId)) end)
            notify('服务器 ID 已复制')
        end,
    })

    -- 游戏名（异步拉取，失败退回 PlaceId）
    task.spawn(function()
        local ok, info = pcall(function()
            return MarketplaceService:GetProductInfo(game.PlaceId, Enum.InfoType.Game)
        end)
        local text = (ok and type(info) == 'table' and info.Name) and ('游戏: <b>' .. tostring(info.Name) .. '</b>')
            or ('游戏: <b>PlaceId ' .. tostring(game.PlaceId) .. '</b>')
        pcall(function() gameLabel:SetText(text) end)
    end)

    -- 会话时长 / 在线人数 / 延迟 / 服务器 ID 定时刷新
    task.spawn(function()
        local started = tick()

        while not InfoTab.Destroyed do
            local elapsed = math.max(0, math.floor(tick() - started))
            pcall(function()
                sessionLabel:SetText(('本次会话: <b>%02d:%02d:%02d</b>'):format(elapsed // 3600, (elapsed % 3600) // 60, elapsed % 60))
            end)

            local count = 0
            pcall(function() count = #Players:GetPlayers() end)
            pcall(function() playersLabel:SetText('在线人数: <b>' .. tostring(count) .. '</b>') end)

            local ping
            pcall(function()
                ping = math.floor(Stats.Network.ServerStatsItem['Data Ping']:GetValue())
            end)
            if ping then
                pcall(function() pingLabel:SetText('延迟: <b>' .. tostring(ping) .. ' ms</b>') end)
            end

            local job = tostring(game.JobId)
            if #job > 12 then job = job:sub(1, 12) .. '…' end
            pcall(function() jobLabel:SetText('服务器 ID: <b>' .. job .. '</b>') end)

            task.wait(1)
        end
    end)
end

do

local CombatBox = Tabs.Combat:AddLeftTabbox()
local SA_Tab = CombatBox:AddTab('静默自瞄')
local Rage_Tab = CombatBox:AddTab('Rage')
local GunMods_Tab = CombatBox:AddTab('修改')
local Vis_Tab = CombatBox:AddTab('视野范围')

-- Silent Aim
Toggles.SilentAim = SA_Tab:AddToggle('SilentAim', { Text = '启用', Default = false })

-- Fix & enhance KeyPicker <-> Toggle synchronization (supports Toggle, Hold, Always modes)
do
    local baseAddons = getmetatable(Toggles.SilentAim)
    local funcs = baseAddons and baseAddons.__index
    if funcs and funcs.AddKeyPicker then
        local origAddKeyPicker = funcs.AddKeyPicker
        funcs.AddKeyPicker = function(self, Idx, Info)
            Info = Info or {}
            local parentToggle = (self.Type == 'Toggle') and self or nil

            -- Prevent Linoria from wiping Hold/Always modes from context menu
            Info.SyncToggleState = false

            local res = origAddKeyPicker(self, Idx, Info)

            local kp = Options[Idx]
            if kp and parentToggle then
                local syncing = false

                local oldUpdate = kp.Update
                kp.Update = function(kpSelf)
                    if oldUpdate then oldUpdate(kpSelf) end
                    if syncing then return end
                    local state = kp:GetState()
                    if parentToggle.Value ~= state then
                        syncing = true
                        parentToggle:SetValue(state)
                        syncing = false
                    end
                end

                if not parentToggle._keyPickerHooked then
                    parentToggle._keyPickerHooked = true
                    local oldToggleSet = parentToggle.SetValue
                    parentToggle.SetValue = function(toggleSelf, val)
                        oldToggleSet(toggleSelf, val)
                        if syncing then return end
                        syncing = true
                        for _, addon in ipairs(toggleSelf.Addons or {}) do
                            if addon.Type == 'KeyPicker' and addon.Mode == 'Toggle' and addon.Toggled ~= val then
                                addon.Toggled = val
                                if addon.Update then addon:Update() end
                            end
                        end
                        syncing = false
                    end
                end
            end
            return res
        end
    end
end

Toggles.SilentAim:AddKeyPicker('SilentAimBind', { Default = 'None', SyncToggleState = false, Modes = { 'Toggle', 'Hold', 'Always' }, Text = '静默自瞄' })
Options.AimPart = WXDrop(SA_Tab, 'AimPart', { Values = { 'Head', 'HumanoidRootPart', 'UpperTorso', 'LowerTorso' }, Default = 1, Multi = false, Text = '瞄准部位' })
Options.MaxDistance = SA_Tab:AddSlider('MaxDistance', { Text = '最大距离', Default = 1500, Min = 100, Max = 3000, Rounding = 1, Compact = false })
Options.FOVRadius = SA_Tab:AddSlider('FOVRadius', { Text = '视野半径', Default = 200, Min = 10, Max = 1000, Rounding = 1, Compact = false })
SA_Tab:AddDivider()
Toggles.SilentAim360 = SA_Tab:AddToggle('SilentAim360', { Text = '360° 模式', Default = false })
Toggles.SilentAimVisibleCheck = SA_Tab:AddToggle('SilentAimVisibleCheck', { Text = '可见性检测', Default = true })
Toggles.SilentAimTeamCheck = SA_Tab:AddToggle('SilentAimTeamCheck', { Text = '队友保护检测', Default = true })

-- Rage
Toggles.RageBot = Rage_Tab:AddToggle('RageBot', { Text = '启用', Default = false })
Toggles.RageBot:AddKeyPicker('RageBotBind', { Default = 'None', SyncToggleState = false, Modes = { 'Toggle', 'Hold', 'Always' }, Text = 'Ragebot' })
Rage_Tab:AddDivider()
Toggles.RageBotBrutal = Rage_Tab:AddToggle('RageBotBrutal', {
    Text = '暴力模式（超暴力）',
    Default = false,
    Tooltip = '锁定爆头 + 单包多发 + 同一帧清空全图目标，极其暴力'
})
local BrutalDep = Rage_Tab:AddDependencyBox()
BrutalDep:SetupDependencies({ { Toggles.RageBotBrutal, true } })
Options.RageBrutalDelay = BrutalDep:AddSlider('RageBrutalDelay', {
    Text = '清场间隔（秒）',
    Default = 0.01,
    Min = 0.001,
    Max = 0.05,
    Rounding = 3,
    Compact = false
})
Rage_Tab:AddDivider()
Toggles.RageMultiPacket = Rage_Tab:AddToggle('RageMultiPacket', {
    Text = '一包多发（通常不用开启）',
    Default = false,
    Tooltip = '不再重复 FireServer，而是把重复命中直接塞进同一个子弹包，服务端同一帧逐条结算'
})
local MultiPacketDep = Rage_Tab:AddDependencyBox()
MultiPacketDep:SetupDependencies({ { Toggles.RageMultiPacket, true } })
Options.RageMultiPacketCount = MultiPacketDep:AddSlider('RageMultiPacketCount', {
    Text = '单包命中次数',
    Default = 3,
    Min = 2,
    Max = 6,
    Rounding = 0,
    Compact = false
})
Rage_Tab:AddDivider()
Toggles.RageBotTargetInmatesAsCrim = Rage_Tab:AddToggle('RageBotTargetInmatesAsCrim', { Text = '攻击囚犯（视作罪犯）', Default = false })
Rage_Tab:AddDivider()
Toggles.RageBotAutoEquip = Rage_Tab:AddToggle('RageBotAutoEquip', { Text = '自动装备武器', Default = true })
Toggles.RageBotAutoWeapon = Rage_Tab:AddToggle('RageBotAutoWeapon', { Text = '自动拾取武器', Default = false })
Rage_Tab:AddDivider()
Toggles.RageBotShootThroughCars = Rage_Tab:AddToggle('RageBotShootThroughCars', { Text = '穿车射击', Default = true })
Options.RageBotCarPenetration = WXDrop(Rage_Tab, 'RageBotCarPenetration', { Text = '载具穿透模式', Values = { 'Windows & Non-Solid', 'All Car Parts' }, Default = 1 })
Toggles.RageBotDisableInVehicle = Rage_Tab:AddToggle('RageBotDisableInVehicle', { Text = '载具内禁用', Default = true })
Rage_Tab:AddDivider()
Toggles.AutoDetectCheaters = Rage_Tab:AddToggle('AutoDetectCheaters', { Text = '自动检测脚本', Default = false, Tooltip = '扫描玩家的加速、飞行、传送与虚空存活行为' })
Toggles.RageBotPrioritizeCheaters = Rage_Tab:AddToggle('RageBotPrioritizeCheaters', { Text = '优先攻击脚本', Default = false, Tooltip = '自动优先锁定已检测到的脚本' })
Toggles.CheaterNotify = Rage_Tab:AddToggle('CheaterNotify', { Text = '脚本提示', Default = false, Tooltip = '检测到脚本时在屏幕弹出提示' })
Rage_Tab:AddDivider()
Toggles.AntiAutoDodge = Rage_Tab:AddToggle('AntiAutoDodge', {
    Text = '反自动躲避',
    Default = false,
    Tooltip = '针对靠无敌帧 + 自动闪避的对手：无敌期间保持锁定但不开火，无敌一结束立刻补枪'
})
local AntiDodgeDep = Rage_Tab:AddDependencyBox()
AntiDodgeDep:SetupDependencies({ { Toggles.AntiAutoDodge, true } })
Options.AntiDodgeHoldMode = WXDrop(AntiDodgeDep, 'AntiDodgeHoldMode', {
    Text = '无敌期间', Default = 1,
    Values = { '停火等待（推荐）', '停火 + 后撤规避', '持续尝试（不停火）' }
})
Toggles.AntiDodgeDetect = AntiDodgeDep:AddToggle('AntiDodgeDetect', {
    Text = '自动标记躲避脚本',
    Default = true,
    Tooltip = '空枪 + 受击瞬间侧移/瞬移判定为自动躲避，标记后同步到「优先攻击脚本」和 ESP 的 [开了] 标记'
})
Toggles.AntiDodgeLead = AntiDodgeDep:AddToggle('AntiDodgeLead', {
    Text = '对躲避开提前量',
    Default = true,
    Tooltip = '被标记为自动躲避后按实测速度打提前量，避免他一直侧移吃不到枪；与 HvH 解析器同时开启时以解析器为准'
})
Options.AntiDodgeExtraFire = AntiDodgeDep:AddSlider('AntiDodgeExtraFire', {
    Text = '无敌结束补枪（发）',
    Default = 3, Min = 0, Max = 10, Rounding = 0, Compact = false
})
Options.AntiDodgeMaxHold = AntiDodgeDep:AddSlider('AntiDodgeMaxHold', {
    Text = '最长等待（秒）',
    Default = 4.5, Min = 1, Max = 15, Rounding = 1, Compact = false
})
Options.AntiDodgeAttackDelay = AntiDodgeDep:AddSlider('AntiDodgeAttackDelay', {
    Text = '无敌结束后延迟开火（秒）',
    Default = 0.03, Min = 0, Max = 0.6, Rounding = 2, Compact = false,
    Tooltip = '避免无敌最后一帧还没同步完就出包，导致伤害被吞'
})
Toggles.AntiDodgeNotify = AntiDodgeDep:AddToggle('AntiDodgeNotify', {
    Text = '状态提示',
    Default = true,
    Tooltip = '目标进入 / 退出无敌时在屏幕弹出提示'
})
_G.WXAntiDodgeLabel = Rage_Tab:AddLabel('反躲避：待机')
Rage_Tab:AddDivider()
Toggles.Resolver = Rage_Tab:AddToggle('Resolver', { Text = 'HvH 解析器', Default = false, Tooltip = '高级 HvH 解析器：反制反瞄准（自旋 / 抖动）、CFrame 位置失同步与假碰撞箱' })
Options.ResolverMode = WXDrop(Rage_Tab, 'ResolverMode', { Text = '解析模式', Values = { 'Adaptive Auto', 'Axis Pivot (Anti-Spin)', 'Velocity Prediction', 'Bruteforce' }, Default = 1 })
Toggles.ResolverLog = Rage_Tab:AddToggle('ResolverLog', { Text = '解析提示', Default = false, Tooltip = '检测到并解析敌方反瞄准时在屏幕提示' })

-- 手机端快捷按钮（Rage）
Rage_Tab:AddDivider()
Toggles.RageBotMobile = Rage_Tab:AddToggle('RageBotMobile', {
    Text = '手机快捷按钮',
    Default = Library.IsMobile,
    Tooltip = '开启后在屏幕上生成一个 Ragebot 开关按钮，可拖动摆放'
})
local RageMobileDep = Rage_Tab:AddDependencyBox()
RageMobileDep:SetupDependencies({ { Toggles.RageBotMobile, true } })
Toggles.RageBotMobileLock = RageMobileDep:AddToggle('RageBotMobileLock', {
    Text = '锁定快捷按钮',
    Default = false,
    Tooltip = '开启后按钮固定位置，无法拖动，只保留点击开关 Ragebot'
})

-- Gun Mods / Rapid Fire
GunMods_Tab:AddDivider()
Toggles.FireRateChanger = GunMods_Tab:AddToggle('FireRateChanger', { Text = '射速修改', Default = false })
Toggles.FireRateChanger:AddKeyPicker('FireRateBind', { Default = 'None', SyncToggleState = false, Modes = { 'Toggle', 'Hold', 'Always' }, Text = '射速修改' })
Options.FireRateMode = WXDrop(GunMods_Tab, 'FireRateMode', { Text = '模式', Values = { 'Multiplier', 'Custom Delay', 'Instant (0s)' }, Default = 1 })
Options.FireRateMultiplier = GunMods_Tab:AddSlider('FireRateMultiplier', { Text = '速度倍率', Default = 3, Min = 1.5, Max = 25, Rounding = 1, Compact = false })
Options.CustomFireRate = GunMods_Tab:AddSlider('CustomFireRate', { Text = '自定义延迟（秒）', Default = 0.02, Min = 0.001, Max = 0.5, Rounding = 3, Compact = false })
GunMods_Tab:AddDivider()
Toggles.AlwaysAutomatic = GunMods_Tab:AddToggle('AlwaysAutomatic', { Text = '始终全自动', Default = false })
Toggles.FireRateApplyManual = GunMods_Tab:AddToggle('FireRateApplyManual', { Text = '应用于手动射击', Default = true })
Toggles.FireRateApplyRage = GunMods_Tab:AddToggle('FireRateApplyRage', { Text = '应用于Ragebot', Default = true })


GunMods_Tab:AddDivider()
Toggles.VoidReload = GunMods_Tab:AddToggle('VoidReload', {
    Text = '虚空换弹（地下安全换弹）',
    Default = false,
    Tooltip = '换弹时传送到地下，换弹完成后返回，使敌人无法命中你'
})

Options.VoidReloadDepth = GunMods_Tab:AddSlider('VoidReloadDepth', {
    Text = '虚空换弹深度（Y）',
    Default = -70,
    Min = -400,
    Max = -20,
    Rounding = 0,
    Compact = false,
    Suffix = ' Y',
    AllowRightClickInput = true,
    Tooltip = '越深越安全但越容易触发坠落销毁；浅于地图底部（约 -40 ~ -90）最稳'
})

Toggles.VoidReloadGuard = GunMods_Tab:AddToggle('VoidReloadGuard', {
    Text = '防死亡保护（推荐开启）',
    Default = true,
    Tooltip = '定身 + 关闭角色触碰/碰撞 + 血量看护，避免传送进虚空时被销毁或击杀砖秒杀'
})

GunMods_Tab:AddDivider()
Toggles.DoubleTap = GunMods_Tab:AddToggle('DoubleTap', { Text = '双击连发', Default = false, Tooltip = '瞬间追加一次连发，造成双倍伤害' })
Toggles.DoubleTap:AddKeyPicker('DoubleTapBind', { Default = 'None', SyncToggleState = false, Modes = { 'Toggle', 'Hold', 'Always' }, Text = '双击连发' })

local DoubleTapDep = GunMods_Tab:AddDependencyBox()
DoubleTapDep:SetupDependencies({ { Toggles.DoubleTap, true } })

Options.DoubleTapWeapon = WXDrop(DoubleTapDep, 'DoubleTapWeapon', {
    Text = '武器',
    Values = { 'Remington 870 Only', 'All Guns' },
    Default = 1,
    Multi = false
})

Options.DoubleTapDelay = DoubleTapDep:AddSlider('DoubleTapDelay', {
    Text = '连发间隔（秒）',
    Default = 0.02,
    Min = 0.00,
    Max = 0.15,
    Rounding = 2,
    Compact = false
})

Toggles.DoubleTapManual = DoubleTapDep:AddToggle('DoubleTapManual', {
    Text = '应用于手动射击',
    Default = true
})
Toggles.DoubleTapRage = Toggles.DoubleTap

GunMods_Tab:AddDivider()
Toggles.ShieldBypass = GunMods_Tab:AddToggle('ShieldBypass', { Text = '穿透防暴盾', Default = false, Tooltip = '无视防暴盾碰撞，直接穿透命中目标' })
Toggles.ShieldBypassRiot = Toggles.ShieldBypass

-- ====================== 侦测包（Damage Probe） ======================
local Probe_Tab = CombatBox:AddTab('侦测包')
local ProbeLastLabel

local function isValidProbeTarget(p)
    if p == LP then return false end
    local char = p.Character
    if not char then return false end
    local hum = char:FindFirstChild('Humanoid')
    if not hum or hum.Health <= 0 then return false end
    return true
end

local function getProbeTarget()
    local sel = Options.ProbeTarget and Options.ProbeTarget.Value
    if sel and sel ~= '自动（最近敌人）' then
        local p = Players:FindFirstChild(sel)
        if p and isValidProbeTarget(p) then return p end
    end
    local myChar = LP.Character
    local myRoot = myChar and myChar:FindFirstChild('HumanoidRootPart')
    local myPos = myRoot and myRoot.Position
    local best, bestDist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if isValidProbeTarget(p) then
            local pc = p.Character
            local hrp = pc and pc:FindFirstChild('HumanoidRootPart')
            if hrp and myPos then
                local d = (hrp.Position - myPos).Magnitude
                if d < bestDist then bestDist = d; best = p end
            end
        end
    end
    return best, bestDist
end

-- 发送完整伤害包：近战直接伤害 + 射击完整子弹包（双通道，确保伤害送达）
local function sendFullDamagePacket(target, damage)
    local char = target and target.Character
    local hum = char and char:FindFirstChild('Humanoid')
    if not hum then return false end
    local part = char:FindFirstChild('Head') or char:FindFirstChild('HumanoidRootPart')
    if not part then return false end

    -- 通道 1：近战直接伤害（完整参数：目标 + 伤害 + 击退）
    local melee = ReplicatedStorage:FindFirstChild('meleeEvent')
        or (ReplicatedStorage:FindFirstChild('Remotes') and ReplicatedStorage.Remotes:FindFirstChild('meleeEvent'))
    if melee then
        pcall(function() melee:FireServer(target, damage, 1) end)
    end

    -- 通道 2：射击完整子弹包（起点 + 命中点 + 命中部位）
    local myChar = LP.Character
    local tool = myChar and myChar:FindFirstChildOfClass('Tool')
    local muzzle = tool and tool:FindFirstChild('Muzzle')
    local origin = muzzle and muzzle.Position
    if not origin then
        local head = myChar and myChar:FindFirstChild('Head')
        origin = head and head.Position
    end
    if origin then
        pcall(function()
            ShootEvent:FireServer({ { origin, part.Position, part } })
        end)
    end
    return true
end

local function runDamageProbe()
    local target = getProbeTarget()
    if not target then
        Library:Notify({ Title = '侦测包', Description = '未找到可用目标', Time = 4 })
        return
    end
    local char = target.Character
    local hum = char and char:FindFirstChild('Humanoid')
    if not hum then
        Library:Notify({ Title = '侦测包', Description = '目标无效', Time = 4 })
        return
    end

    local h0 = hum.Health
    local maxH = hum.MaxHealth
    local hasFF = char:FindFirstChildOfClass('ForceField') ~= nil
    local damage = (Options.ProbeDamage and Options.ProbeDamage.Value) or 100
    local count = (Options.ProbeCount and Options.ProbeCount.Value) or 1

    if ProbeLastLabel then
        ProbeLastLabel:SetText(string.format('侦测中… 目标 %s（%.0f HP）', target.Name, h0))
    end

    task.spawn(function()
        for _ = 1, count do
            if not hum.Parent or hum.Health <= 0 then break end
            sendFullDamagePacket(target, damage)
            task.wait(0.06)
        end
        task.wait(0.4)
        local h1 = hum.Health
        local delta = h0 - h1
        local status
        if h1 <= 0 then
            status = string.format('击杀成功：%s 已死亡（%.0f → 0）', target.Name, h0)
        elseif delta > 0 then
            status = string.format('命中：%s 掉血 %d（%.0f → %.0f / %.0f）', target.Name, math.floor(delta + 0.5), h0, h1, maxH)
        elseif hasFF then
            status = string.format('目标有 ForceField：伤害被吸收（%.0f 未变）', h0)
        else
            status = string.format('未掉血：%s 可能无敌/锁血/减伤/超范围（%.0f 未变）', target.Name, h0)
        end
        if ProbeLastLabel then
            ProbeLastLabel:SetText(status)
        end
        Library:Notify({ Title = '侦测包', Description = status, Time = 6 })
    end)
end

local function updateProbePlayers()
    if not Options.ProbeTarget then return end
    local names = { '自动（最近敌人）' }
    for _, p in Players:GetPlayers() do
        if p ~= LP then table.insert(names, p.Name) end
    end
    Options.ProbeTarget.Values = names
    if Options.ProbeTarget.SetValues then
        Options.ProbeTarget:SetValues(names)
    end
end

-- 侦测包 UI
Options.ProbeTarget = WXDrop(Probe_Tab, 'ProbeTarget', {
    Text = '侦测目标',
    Values = { '自动（最近敌人）' },
    Default = 1,
    Multi = false
})

Options.ProbeDamage = Probe_Tab:AddSlider('ProbeDamage', {
    Text = '伤害值（完整伤害包）',
    Default = 100,
    Min = 1,
    Max = 1000,
    Rounding = 0,
    Compact = false
})

Options.ProbeCount = Probe_Tab:AddSlider('ProbeCount', {
    Text = '发送次数',
    Default = 1,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Compact = false
})

Probe_Tab:AddDivider()
ProbeLastLabel = Probe_Tab:AddLabel('侦测结果：尚未侦测')
Probe_Tab:AddDivider()

Probe_Tab:AddButton({
    Text = '发送侦测包（发完整伤害 + 侦测）',
    Func = function()
        runDamageProbe()
    end
})

Players.PlayerAdded:Connect(updateProbePlayers)
Players.PlayerRemoving:Connect(updateProbePlayers)
task.spawn(function()
    task.wait(1)
    updateProbePlayers()
end)

-- Combat Visual
Toggles.FOVCircle = Vis_Tab:AddToggle('FOVCircle', { Text = '显示视野圈', Default = false })
Options.FOVRotSpeed = Vis_Tab:AddSlider('FOVRotSpeed', { Text = '旋转速度', Default = 0, Min = -5, Max = 5, Rounding = 1, Compact = false })
Options.FOVThickness = Vis_Tab:AddSlider('FOVThickness', { Text = '描边粗细', Default = 1.5, Min = 0.5, Max = 8, Rounding = 1, Compact = false })
Vis_Tab:AddLabel('描边')
do
    local L = Vis_Tab:AddLabel('颜色')
    L:AddColorPicker('FOVColor1', { Default = Color3.fromRGB(255, 255, 255), Title = '描边颜色 1' })
    L:AddColorPicker('FOVColor2', { Default = Color3.fromRGB(0, 170, 255), Title = '描边颜色 2' })
    L:AddColorPicker('FOVColor3', { Default = Color3.fromRGB(255, 0, 0), Title = '描边颜色 3' })
end
Vis_Tab:AddDivider()
Vis_Tab:AddLabel('填充')
Toggles.FOVFill = Vis_Tab:AddToggle('FOVFill', { Text = '启用填充', Default = false })
Options.FOVFillDensity = Vis_Tab:AddSlider('FOVFillDensity', { Text = '填充密度', Default = 0.85, Min = 0, Max = 1, Rounding = 2, Compact = false })
do
    local L = Vis_Tab:AddLabel('填充颜色')
    L:AddColorPicker('FOVFillColor1', { Default = Color3.fromRGB(255, 255, 255), Title = '填充颜色 1' })
    L:AddColorPicker('FOVFillColor2', { Default = Color3.fromRGB(0, 170, 255), Title = '填充颜色 2' })
    L:AddColorPicker('FOVFillColor3', { Default = Color3.fromRGB(255, 0, 0), Title = '填充颜色 3' })
end

-- Crosshair (right side, next to combat tabs)
local CrosshairBox = Tabs.Combat:AddRightTabbox()
local CH_Tab = CrosshairBox:AddTab('准星')
CH_Tab:AddDivider()
Toggles.CustomCrosshair = CH_Tab:AddToggle('CustomCrosshair', { Text = '自定义准星', Default = false })
Options.CrosshairLength = CH_Tab:AddSlider('CrosshairLength', { Text = '长度', Default = 10, Min = 2, Max = 40, Rounding = 0, Compact = false })
Options.CrosshairGap = CH_Tab:AddSlider('CrosshairGap', { Text = '间隙', Default = 4, Min = 0, Max = 30, Rounding = 0, Compact = false })
Options.CrosshairThickness = CH_Tab:AddSlider('CrosshairThickness', { Text = '粗细', Default = 2, Min = 1, Max = 8, Rounding = 0, Compact = false })
Options.CrosshairRotation = CH_Tab:AddSlider('CrosshairRotation', { Text = '旋转', Default = 0, Min = -180, Max = 180, Rounding = 1, Compact = false })
do
    local L = CH_Tab:AddLabel('颜色')
    L:AddColorPicker('CH1Color', { Default = Color3.fromRGB(255, 255, 255), Title = '线条 1' })
    L:AddColorPicker('CH2Color', { Default = Color3.fromRGB(255, 255, 255), Title = '线条 2' })
    L:AddColorPicker('CH3Color', { Default = Color3.fromRGB(255, 255, 255), Title = '线条 3' })
    L:AddColorPicker('CH4Color', { Default = Color3.fromRGB(255, 255, 255), Title = '线条 4' })
end

-- Hitmarkers Tab
local HM_Tab = CrosshairBox:AddTab('命中标记')
HM_Tab:AddDivider()
Toggles.Hitmarkers = HM_Tab:AddToggle('Hitmarkers', { Text = '启用', Default = false })
Options.HitmarkerMode = WXDrop(HM_Tab, 'HitmarkerMode', { Text = '模式', Default = 1, Values = { 'Weapon Crosshair', 'Screen Center', '3D Hit Position' } })
Options.HitmarkerAnimation = WXDrop(HM_Tab, 'HitmarkerAnimation', { Text = '动画', Default = 2, Values = { 'Static Fade', 'Expand & Fade', 'Bounce' } })
Options.HitmarkerSize = HM_Tab:AddSlider('HitmarkerSize', { Text = '线条长度', Default = 8, Min = 3, Max = 25, Rounding = 0, Compact = false })
Options.HitmarkerGap = HM_Tab:AddSlider('HitmarkerGap', { Text = '中心间隙', Default = 5, Min = 1, Max = 20, Rounding = 0, Compact = false })
Options.HitmarkerThickness = HM_Tab:AddSlider('HitmarkerThickness', { Text = '粗细', Default = 1.5, Min = 1, Max = 5, Rounding = 1, Compact = false })
Options.HitmarkerDuration = HM_Tab:AddSlider('HitmarkerDuration', { Text = '持续时间（秒）', Default = 0.35, Min = 0.1, Max = 1.0, Rounding = 2, Compact = false })
HM_Tab:AddDivider()
Toggles.HitmarkerCritColor = HM_Tab:AddToggle('HitmarkerCritColor', { Text = '爆头 / 暴击颜色', Default = true })
do
    local L = HM_Tab:AddLabel('颜色')
    L:AddColorPicker('HitmarkerColor', { Default = Color3.fromRGB(255, 255, 255), Title = '命中颜色' })
    L:AddColorPicker('HitmarkerCritCol', { Default = Color3.fromRGB(255, 45, 45), Title = '暴击颜色' })
    L:AddColorPicker('HitmarkerTaserCol', { Default = Color3.fromRGB(0, 230, 255), Title = '电击枪颜色' })
end
Toggles.HitmarkerRainbow = HM_Tab:AddToggle('HitmarkerRainbow', { Text = '彩虹', Default = false })

-- Hit Numbers Tab
local HN_Tab = CrosshairBox:AddTab('伤害数字')
HN_Tab:AddDivider()
Toggles.HitNumbers = HN_Tab:AddToggle('HitNumbers', { Text = '启用', Default = false })
Options.HitNumberAnimation = WXDrop(HN_Tab, 'HitNumberAnimation', { Text = '动画', Default = 1, Values = { 'Pop & Bounce', 'Float Up', 'Scatter (3D)', 'Rise & Fade' } })
Options.HitNumberSize = HN_Tab:AddSlider('HitNumberSize', { Text = '基础大小', Default = 18, Min = 12, Max = 32, Rounding = 0, Compact = false })
Options.HitNumberDuration = HN_Tab:AddSlider('HitNumberDuration', { Text = '持续时间（秒）', Default = 1.0, Min = 0.4, Max = 2.5, Rounding = 1, Compact = false })
Options.HitNumberFont = WXDrop(HN_Tab, 'HitNumberFont', { Text = '字体', Default = 2, Values = { 'UI', 'System', 'Plex', 'Monospace' } })
HN_Tab:AddDivider()
Toggles.HitNumberCritColor = HN_Tab:AddToggle('HitNumberCritColor', { Text = '爆头 / 暴击颜色', Default = true })
do
    local L = HN_Tab:AddLabel('颜色')
    L:AddColorPicker('HitNumberColor', { Default = Color3.fromRGB(255, 235, 100), Title = '命中颜色' })
    L:AddColorPicker('HitNumberCritCol', { Default = Color3.fromRGB(255, 50, 50), Title = '暴击颜色' })
    L:AddColorPicker('HitNumberTaserCol', { Default = Color3.fromRGB(0, 230, 255), Title = '电击枪颜色' })
end
Toggles.HitNumberRainbow = HN_Tab:AddToggle('HitNumberRainbow', { Text = '彩虹', Default = false })

-- Arrest Aura (right side)
local ArrestBox = Tabs.Combat:AddRightTabbox()
local AR_Tab = ArrestBox:AddTab('逮捕光环')
Toggles.ArrestAura = AR_Tab:AddToggle('ArrestAura', { Text = '逮捕光环', Default = false })
Toggles.ArrestAura:AddKeyPicker('ArrestAuraBind', { Default = 'None', SyncToggleState = false, Modes = { 'Toggle', 'Hold', 'Always' }, Text = '逮捕光环' })
AR_Tab:AddDivider()
Toggles.ArrestAuraRange = AR_Tab:AddToggle('ArrestAuraRange', { Text = '显示范围', Default = false })
Options.ArrestAuraThickness = AR_Tab:AddSlider('ArrestAuraThickness', { Text = '范围粗细', Default = 1.5, Min = 0.5, Max = 8, Rounding = 1, Compact = false })
do
    local L = AR_Tab:AddLabel('范围颜色')
    L:AddColorPicker('ArrestAuraColor1', { Default = Color3.fromRGB(255, 0, 0), Title = '范围颜色 1' })
    L:AddColorPicker('ArrestAuraColor2', { Default = Color3.fromRGB(255, 100, 0), Title = '范围颜色 2' })
    L:AddColorPicker('ArrestAuraColor3', { Default = Color3.fromRGB(255, 200, 0), Title = '范围颜色 3' })
end
AR_Tab:AddDivider()
Toggles.ArrestAuraFill = AR_Tab:AddToggle('ArrestAuraFill', { Text = '范围填充', Default = false })
Options.ArrestAuraFillDensity = AR_Tab:AddSlider('ArrestAuraFillDensity', { Text = '填充密度', Default = 0.85, Min = 0, Max = 1, Rounding = 2, Compact = false })
do
    local L = AR_Tab:AddLabel('填充颜色')
    L:AddColorPicker('ArrestAuraFillColor1', { Default = Color3.fromRGB(255, 0, 0), Title = '填充颜色 1' })
    L:AddColorPicker('ArrestAuraFillColor2', { Default = Color3.fromRGB(255, 100, 0), Title = '填充颜色 2' })
    L:AddColorPicker('ArrestAuraFillColor3', { Default = Color3.fromRGB(255, 200, 0), Title = '填充颜色 3' })
end

-- Void Aura Tab (HvH Edition)
local Void_Tab = ArrestBox:AddTab('虚空光环')

Toggles.VoidAura = Void_Tab:AddToggle('VoidAura', { Text = '虚空光环', Default = false })
Toggles.VoidAura:AddKeyPicker('VoidAuraBind', { Default = 'None', SyncToggleState = false, Modes = { 'Toggle', 'Hold', 'Always' }, Text = '虚空光环' })

local VoidDep = Void_Tab:AddDependencyBox()
VoidDep:SetupDependencies({ { Toggles.VoidAura, true } })

Options.VoidPositionType = WXDrop(VoidDep, 'VoidPositionType', {
    Values = {
        '3D Cyclone Orbit (HvH)',
        '3D Helix / Corkscrew (HvH)',
        'Spherical Chaos / Evasive',
        'Behind Target (Backstab Flank)',
        'Above Target (Sky Stomp)',
        'Jitter Random Flank',
        'Underground (Void Floor)',
        'Stay At Enable Position'
    },
    Default = 1,
    Multi = false,
    Text = '虚空位置'
})

Options.VoidStrikeMethod = WXDrop(VoidDep, 'VoidStrikeMethod', {
    Values = { 'Instant Teleport (0ms HvH Snap)', 'Smooth Ultra-Glide', 'Blink Flank (In & Out)' },
    Default = 1,
    Multi = false,
    Text = '打击方式'
})

Options.VoidTargetMode = WXDrop(VoidDep, 'VoidTargetMode', {
    Values = { 'Nearest Enemy', 'Lowest HP (Executer)', 'All Enemies (Carnage Cycle)', 'RageBot / Current', 'Selected Player' },
    Default = 1,
    Multi = false,
    Text = '目标模式'
})

Options.VoidSelectedPlayer = WXDrop(VoidDep, 'VoidSelectedPlayer', {
    Values = { 'None' },
    Default = 1,
    Multi = false,
    Text = '目标玩家'
})

Options.VoidAttackType = WXDrop(VoidDep, 'VoidAttackType', {
    Values = { 'Gun & Melee', 'Melee Only (Punch)', 'Gun Only' },
    Default = 1,
    Multi = false,
    Text = '攻击模式'
})

VoidDep:AddDivider()

Options.VoidDistance = VoidDep:AddSlider('VoidDistance', {
    Text = '偏移距离',
    Default = 4,
    Min = 1,
    Max = 25,
    Rounding = 0,
    Compact = false
})

Options.VoidHeight = VoidDep:AddSlider('VoidHeight', {
    Text = '高度 / 垂直偏移',
    Default = 2,
    Min = -15,
    Max = 50,
    Rounding = 0,
    Compact = false
})

Options.VoidOrbitSpeed = VoidDep:AddSlider('VoidOrbitSpeed', {
    Text = '环绕速度',
    Default = 16,
    Min = 4,
    Max = 60,
    Rounding = 0,
    Compact = false
})

Options.VoidAttackDelay = VoidDep:AddSlider('VoidAttackDelay', {
    Text = '攻击延迟（秒）',
    Default = 0.03,
    Min = 0.01,
    Max = 0.50,
    Rounding = 2,
    Compact = false
})

Options.VoidCycleDelay = VoidDep:AddSlider('VoidCycleDelay', {
    Text = '屠杀切换速度（秒）',
    Default = 0.12,
    Min = 0.02,
    Max = 0.80,
    Rounding = 2,
    Compact = false
})

VoidDep:AddDivider()

Toggles.VoidLoSSolver = VoidDep:AddToggle('VoidLoSSolver', {
    Text = '穿墙命中',
    Default = true,
    Tooltip = '敌人进入掩体时自动穿墙调整距离，确保愤怒机器人射线必定命中'
})

Toggles.VoidAuraReloadInVoid = VoidDep:AddToggle('VoidAuraReloadInVoid', {
    Text = '换弹时传送至虚空',
    Default = true,
    Tooltip = '虚空光环换弹期间传送到虚空深处'
})

Toggles.VoidAutoEquip = VoidDep:AddToggle('VoidAutoEquip', {
    Text = '自动装备最佳武器',
    Default = true
})

Toggles.VoidNoclip = VoidDep:AddToggle('VoidNoclip', {
    Text = '角色完全穿墙',
    Default = true
})

Toggles.VoidAntiTargetLock = VoidDep:AddToggle('VoidAntiTargetLock', {
    Text = '反瞄准预测失同步',
    Default = true,
    Tooltip = '快速微抖动位置，破坏敌方自瞄预测'
})

-- ====================== VISUALS ======================

-- Left Column 1: Player & Target ESP
local PlayersBox = Tabs.Visuals:AddLeftTabbox()
local ESP_Tab = PlayersBox:AddTab('透视')
local TargetESP_Tab = PlayersBox:AddTab('目标透视')

-- Left Column 2: Self & Character Models
local ModelBox = Tabs.Visuals:AddLeftTabbox()
local Chinahat_Tab = ModelBox:AddTab('头顶帽子')
local Viewmodel_Tab = ModelBox:AddTab('视角模型')
-- 【修复】原脚本里 Paint_Tab 从头到尾没有被创建过（是 nil），
-- 下面「上色」一节的 Paint_Tab:AddToggle 会直接抛 attempt to index nil，
-- 导致整段脚本中断、后面的功能全部加载不出来。这里补上这个 Tab。
local Paint_Tab = ModelBox:AddTab('上色')

-- Right Column 1: World & Visual Effects
local EffectsBox = Tabs.Visuals:AddRightTabbox()
local World_Tab = EffectsBox:AddTab('世界')
local Bullet_Tab = EffectsBox:AddTab('弹道')
local Particles_Tab = EffectsBox:AddTab('粒子')

-- Right Column 2: Interface & HUD
local HUDBox = Tabs.Visuals:AddRightTabbox()
local TargetHUD_Tab = HUDBox:AddTab('目标信息面板')
local Killfeed_Tab = HUDBox:AddTab('击杀提示')



-- --- 上色 ---
Toggles.Paint = Paint_Tab:AddToggle('Paint', {
	Text = '启用上色',
	Default = false,
	Tooltip = '给角色与手持武器换色（含配饰、衣物、身体色），纯本地渲染，仅自己可见'
})
Toggles.Paint:AddKeyPicker('PaintBind', { Default = 'None', SyncToggleState = false, Modes = { 'Toggle', 'Hold', 'Always' }, Text = '上色' })

local PaintDep = Paint_Tab:AddDependencyBox()
PaintDep:SetupDependencies({ { Toggles.Paint, true } })

PaintDep:AddLabel('身体颜色'):AddColorPicker('PaintBodyColor', { Default = Color3.fromRGB(0, 220, 255), Title = '身体颜色' })
PaintDep:AddLabel('武器颜色'):AddColorPicker('PaintWeaponColor', { Default = Color3.fromRGB(255, 255, 255), Title = '武器颜色' })

PaintDep:AddDivider('材质与表现')
Options.PaintMaterial = WXDrop(PaintDep, 'PaintMaterial', {
	Text = '材质',
	Default = 1,
	Values = { 'Neon', 'ForceField', 'SmoothPlastic', 'Metal', 'Glass', 'Ice', 'Foil', 'Granite' },
})
Options.PaintEmissive = PaintDep:AddSlider('PaintEmissive', { Text = '反光强度', Default = 0, Min = 0, Max = 1, Rounding = 2, Compact = false })
Toggles.PaintGradient = PaintDep:AddToggle('PaintGradient', { Text = '渐变（头亮脚暗）', Default = false })
Toggles.PaintRainbow = PaintDep:AddToggle('PaintRainbow', { Text = '彩虹流动', Default = false })
Toggles.PaintRemoveTextures = PaintDep:AddToggle('PaintRemoveTextures', { Text = '去除贴图（颜色更纯净）', Default = true })
Toggles.PaintHideClothing = PaintDep:AddToggle('PaintHideClothing', { Text = '隐藏衣物图层', Default = true, Tooltip = '临时隐藏衬衫/裤子贴图，避免盖住纯色效果（关闭后自动恢复）' })
Toggles.PaintRemoveMesh = PaintDep:AddToggle('PaintRemoveMesh', { Text = '移除 R6 皮肤网格', Default = true, Tooltip = 'R6 角色的皮肤贴图会盖住颜色，开启后才能全身纯色' })

PaintDep:AddDivider('角色透明')
Toggles.PaintTransparent = PaintDep:AddToggle('PaintTransparent', {
	Text = '角色半透明',
	Default = false,
	Tooltip = '开启后角色本体整体变透明，可与上色叠加'
})
Options.PaintAlpha = PaintDep:AddSlider('PaintAlpha', { Text = '透明程度', Default = 0.5, Min = 0.05, Max = 0.95, Rounding = 2, Compact = false })
Toggles.PaintAlphaWeapon = PaintDep:AddToggle('PaintAlphaWeapon', { Text = '武器也透明', Default = false })

PaintDep:AddDivider('作用对象')
Options.PaintRange = WXDrop(PaintDep, 'PaintRange', {
	Text = '上色范围',
	Default = 1,
	Values = { '仅自己', '自己 + 其他玩家', '全部角色' },
})
Options.PaintMaxDist = PaintDep:AddSlider('PaintMaxDist', { Text = '生效距离', Default = 200, Min = 30, Max = 600, Rounding = 0, Compact = false })


-- --- ESP ---
-- ESP
Toggles.ESP = ESP_Tab:AddToggle('ESP', { Text = '启用', Default = false })
ESP_Tab:AddDivider()

ESP_Tab:AddLabel('囚犯')
Toggles.ESPInmates = ESP_Tab:AddToggle('ESPInmates', { Text = '启用', Default = false })
Toggles.ESPInmates:AddColorPicker('ESPInmatesColor', { Default = Color3.fromRGB(0, 170, 255), Title = '囚犯颜色' })
Toggles.ESPInmatesRainbow = ESP_Tab:AddToggle('ESPInmatesRainbow', { Text = '彩虹', Default = false })

ESP_Tab:AddLabel('狱警')
Toggles.ESPGuards = ESP_Tab:AddToggle('ESPGuards', { Text = '启用', Default = false })
Toggles.ESPGuards:AddColorPicker('ESPGuardsColor', { Default = Color3.fromRGB(255, 50, 50), Title = '狱警颜色' })
Toggles.ESPGuardsRainbow = ESP_Tab:AddToggle('ESPGuardsRainbow', { Text = '彩虹', Default = false })

ESP_Tab:AddLabel('敌对')
Toggles.ESPHostile = ESP_Tab:AddToggle('ESPHostile', { Text = '启用', Default = false })
Toggles.ESPHostile:AddColorPicker('ESPHostileColor', { Default = Color3.fromRGB(255, 0, 0), Title = '敌对颜色' })
Toggles.ESPHostileRainbow = ESP_Tab:AddToggle('ESPHostileRainbow', { Text = '彩虹', Default = false })

ESP_Tab:AddLabel('罪犯')
Toggles.ESPCriminals = ESP_Tab:AddToggle('ESPCriminals', { Text = '启用', Default = false })
Toggles.ESPCriminals:AddColorPicker('ESPCriminalsColor', { Default = Color3.fromRGB(255, 170, 0), Title = '罪犯颜色' })
Toggles.ESPCriminalsRainbow = ESP_Tab:AddToggle('ESPCriminalsRainbow', { Text = '彩虹', Default = false })

ESP_Tab:AddDivider()
ESP_Tab:AddLabel('透视类型')
Toggles.ESPHighlight = ESP_Tab:AddToggle('ESPHighlight', { Text = '高亮', Default = false })
Toggles.ESPBox = ESP_Tab:AddToggle('ESPBox', { Text = '方框', Default = false })
Toggles.ESPName = ESP_Tab:AddToggle('ESPName', { Text = '名称', Default = false })
Toggles.ESPSkeleton = ESP_Tab:AddToggle('ESPSkeleton', { Text = '骨骼', Default = false })
Toggles.ESPHealthBar = ESP_Tab:AddToggle('ESPHealthBar', { Text = '血条', Default = false })
Toggles.ESPHPCounter = ESP_Tab:AddToggle('ESPHPCounter', { Text = '血量数值', Default = false })
Toggles.ESPWeapon = ESP_Tab:AddToggle('ESPWeapon', { Text = '武器', Default = false })
Toggles.ESPShield = ESP_Tab:AddToggle('ESPShield', { Text = '护盾', Default = false })
Toggles.ESPShield:AddColorPicker('ESPShieldColor', { Default = Color3.fromRGB(0, 180, 255), Title = '护盾颜色' })
Toggles.ESPShieldRainbow = ESP_Tab:AddToggle('ESPShieldRainbow', { Text = '护盾彩虹', Default = false })

Toggles.WeaponChams = ESP_Tab:AddToggle('WeaponChams', { Text = '武器透视材质', Default = false })
Options.WeaponChamsMaterial = WXDrop(ESP_Tab, 'WeaponChamsMaterial', { Text = '材质', Default = 1, Values = { 'Neon', 'ForceField', 'Glass', 'Ice', 'Metal', 'Cobblestone', 'Brick', 'DiamondPlate' } })
ESP_Tab:AddLabel('颜色'):AddColorPicker('WeaponChamsColor', { Default = Color3.fromRGB(0, 170, 255), Title = '透视材质颜色' })

-- --- Target ESP ---
Toggles.TargetESP = TargetESP_Tab:AddToggle('TargetESP', { Text = '启用', Default = false })
Toggles.TargetESP:AddColorPicker('TargetESPColor', { Default = Color3.fromRGB(255, 255, 255), Title = '目标透视颜色' })
Toggles.TargetESPRainbow = TargetESP_Tab:AddToggle('TargetESPRainbow', { Text = '彩虹', Default = false })

local TargetESPDep = TargetESP_Tab:AddDependencyBox()
TargetESPDep:SetupDependencies({ { Toggles.TargetESP, true } })

Options.TargetESPMode = WXDrop(TargetESPDep, 'TargetESPMode', {
    Values = { 'Client', 'Wexside', 'Призраки' },
    Default = 1,
    Multi = false,
    Text = '模式'
})

Options.TargetESPSpeed = TargetESPDep:AddSlider('TargetESPSpeed', { Text = '速度', Default = 3.0, Min = 0.7, Max = 9.0, Rounding = 1, Compact = false })
Options.TargetESPSize = TargetESPDep:AddSlider('TargetESPSize', { Text = '大小', Default = 70, Min = 10, Max = 140, Rounding = 0, Compact = false })
Options.TargetESPBrightness = TargetESPDep:AddSlider('TargetESPBrightness', { Text = '亮度', Default = 255, Min = 1, Max = 255, Rounding = 0, Compact = false })

TargetESPDep:AddDivider()
Toggles.TargetESPVisibleCheck = TargetESPDep:AddToggle('TargetESPVisibleCheck', { Text = '可见性检测', Default = false })

-- --- China Hat ---
-- China Hat
Toggles.ChinaHat = Chinahat_Tab:AddToggle('ChinaHat', { Text = '启用头顶帽子', Default = false, Tooltip = '在玩家头顶渲染帽子' })
Toggles.ChinaHat:AddKeyPicker('ChinaHatBind', { Default = 'None', SyncToggleState = false, Modes = { 'Toggle', 'Hold', 'Always' }, Text = '头顶帽子' })

local CHDep = Chinahat_Tab:AddDependencyBox()
CHDep:SetupDependencies({ { Toggles.ChinaHat, true } })

CHDep:AddDivider()
CHDep:AddLabel('通用与动画')
Toggles.ChinaHatSpin = CHDep:AddToggle('ChinaHatSpin', { Text = '自旋动画', Default = true })
Options.ChinaHatSpinSpeed = CHDep:AddSlider('ChinaHatSpinSpeed', { Text = '自旋速度', Default = 2, Min = 0.5, Max = 10, Rounding = 1, Compact = false })
Toggles.ChinaHatFollowHead = CHDep:AddToggle('ChinaHatFollowHead', { Text = '跟随头部倾斜', Default = true })
Toggles.ChinaHatOutline = CHDep:AddToggle('ChinaHatOutline', { Text = '边缘描边', Default = true })
Toggles.ChinaHatOutline:AddColorPicker('ChinaHatOutlineColor', { Default = Color3.fromRGB(255, 255, 255), Title = '描边颜色' })
Options.ChinaHatOutlineThick = CHDep:AddSlider('ChinaHatOutlineThick', { Text = '描边粗细', Default = 1.5, Min = 1, Max = 4, Rounding = 1, Compact = false })

CHDep:AddDivider()
CHDep:AddLabel('本地玩家（自己）')
Toggles.ChinaHatSelf = CHDep:AddToggle('ChinaHatSelf', { Text = '渲染到自己', Default = true, Tooltip = '第三人称下在自己头顶显示帽子' })
Toggles.ChinaHatSelf:AddColorPicker('ChinaHatColorSelf', { Default = Color3.fromRGB(100, 150, 200), Title = '自己帽子颜色' })
Toggles.ChinaHatRainbowSelf = CHDep:AddToggle('ChinaHatRainbowSelf', { Text = '彩虹颜色（自己）', Default = false })
Options.ChinaHatAlphaSelf = CHDep:AddSlider('ChinaHatAlphaSelf', { Text = '不透明度（自己）', Default = 0.65, Min = 0.1, Max = 1.0, Rounding = 2, Compact = false })
Options.ChinaHatRadiusSelf = CHDep:AddSlider('ChinaHatRadiusSelf', { Text = '半径 / 宽度（自己）', Default = 2.0, Min = 0.5, Max = 4.5, Rounding = 1, Compact = false })
Options.ChinaHatHeightSelf = CHDep:AddSlider('ChinaHatHeightSelf', { Text = '高度（自己）', Default = 0.8, Min = 0.2, Max = 3.0, Rounding = 1, Compact = false })
Options.ChinaHatOffsetSelf = CHDep:AddSlider('ChinaHatOffsetSelf', { Text = '高度偏移（自己）', Default = 0.15, Min = -0.5, Max = 1.5, Rounding = 2, Compact = false })

CHDep:AddDivider()
CHDep:AddLabel('其他玩家')
Toggles.ChinaHatOthers = CHDep:AddToggle('ChinaHatOthers', { Text = '渲染到其他玩家', Default = true, Tooltip = '在其他玩家头顶显示帽子' })
Toggles.ChinaHatOthers:AddColorPicker('ChinaHatColorOthers', { Default = Color3.fromRGB(200, 100, 150), Title = '他人帽子颜色' })
Toggles.ChinaHatTeamColor = CHDep:AddToggle('ChinaHatTeamColor', { Text = '使用队伍颜色（其他玩家）', Default = true })
Toggles.ChinaHatRainbowOthers = CHDep:AddToggle('ChinaHatRainbowOthers', { Text = '彩虹颜色（其他玩家）', Default = false })
Options.ChinaHatAlphaOthers = CHDep:AddSlider('ChinaHatAlphaOthers', { Text = '不透明度（其他玩家）', Default = 0.65, Min = 0.1, Max = 1.0, Rounding = 2, Compact = false })
Options.ChinaHatRadiusOthers = CHDep:AddSlider('ChinaHatRadiusOthers', { Text = '半径 / 宽度（其他玩家）', Default = 2.0, Min = 0.5, Max = 4.5, Rounding = 1, Compact = false })
Options.ChinaHatHeightOthers = CHDep:AddSlider('ChinaHatHeightOthers', { Text = '高度（其他玩家）', Default = 0.8, Min = 0.2, Max = 3.0, Rounding = 1, Compact = false })
Options.ChinaHatMaxDist = CHDep:AddSlider('ChinaHatMaxDist', { Text = '最大距离（其他玩家）', Default = 250, Min = 50, Max = 800, Rounding = 0, Compact = false })

-- --- Viewmodel ---
Toggles.CustomViewmodel = Viewmodel_Tab:AddToggle('CustomViewmodel', { Text = '自定义视角模型', Default = false })
local VMDep = Viewmodel_Tab:AddDependencyBox()
VMDep:SetupDependencies({ { Toggles.CustomViewmodel, true } })

Options.ViewmodelOffsetX = VMDep:AddSlider('ViewmodelOffsetX', { Text = 'X 偏移（左 / 右）', Default = 0, Min = -50, Max = 50, Rounding = 1, Compact = false })
Options.ViewmodelOffsetY = VMDep:AddSlider('ViewmodelOffsetY', { Text = 'Y 偏移（下 / 上）', Default = 0, Min = -50, Max = 50, Rounding = 1, Compact = false })
Options.ViewmodelOffsetZ = VMDep:AddSlider('ViewmodelOffsetZ', { Text = 'Z 偏移（后 / 前）', Default = 0, Min = -50, Max = 50, Rounding = 1, Compact = false })
VMDep:AddDivider()

Options.ViewmodelRotX = VMDep:AddSlider('ViewmodelRotX', { Text = '俯仰（X）', Default = 0, Min = -180, Max = 180, Rounding = 0, Compact = false })
Options.ViewmodelRotY = VMDep:AddSlider('ViewmodelRotY', { Text = '偏航（Y）', Default = 0, Min = -180, Max = 180, Rounding = 0, Compact = false })
Options.ViewmodelRotZ = VMDep:AddSlider('ViewmodelRotZ', { Text = '翻滚（Z）', Default = 0, Min = -180, Max = 180, Rounding = 0, Compact = false })
VMDep:AddDivider()

Toggles.ViewmodelSpin = VMDep:AddToggle('ViewmodelSpin', { Text = '武器自旋', Default = false })
Options.ViewmodelSpinSpeed = VMDep:AddSlider('ViewmodelSpinSpeed', { Text = '自旋速度', Default = 10, Min = 1, Max = 50, Rounding = 0, Compact = false })
Options.ViewmodelSpinAxis = WXDrop(VMDep, 'ViewmodelSpinAxis', { Values = { 'Y (Yaw)', 'X (Pitch)', 'Z (Roll)', 'All Axes' }, Default = 1, Multi = false, Text = '自旋轴' })
VMDep:AddDivider()

Toggles.ViewmodelShowArms = VMDep:AddToggle('ViewmodelShowArms', { Text = '第一人称显示手臂', Default = true })
Toggles.ViewmodelFirstPersonOnly = VMDep:AddToggle('ViewmodelFirstPersonOnly', { Text = '仅第一人称', Default = true })
VMDep:AddDivider()

VMDep:AddButton({
    Text = '重置视角模型',
    Func = function()
        if Options.ViewmodelOffsetX then Options.ViewmodelOffsetX:SetValue(0) end
        if Options.ViewmodelOffsetY then Options.ViewmodelOffsetY:SetValue(0) end
        if Options.ViewmodelOffsetZ then Options.ViewmodelOffsetZ:SetValue(0) end
        if Options.ViewmodelRotX then Options.ViewmodelRotX:SetValue(0) end
        if Options.ViewmodelRotY then Options.ViewmodelRotY:SetValue(0) end
        if Options.ViewmodelRotZ then Options.ViewmodelRotZ:SetValue(0) end
    end
})

-- --- World ---
-- World
Toggles.Ambience = World_Tab:AddToggle('Ambience', { Text = '自定义环境光', Default = false })
Toggles.Ambience:AddColorPicker('AmbienceColor', { Default = Color3.fromRGB(150, 150, 200), Title = '环境光颜色' })
Options.AmbienceBrightness = World_Tab:AddSlider('AmbienceBrightness', { Text = '亮度', Default = 2, Min = 0, Max = 5, Rounding = 1, Compact = false })
Toggles.AmbienceRainbow = World_Tab:AddToggle('AmbienceRainbow', { Text = '彩虹', Default = false })
World_Tab:AddDivider()
Toggles.CustomTime = World_Tab:AddToggle('CustomTime', { Text = '自定义时间', Default = false })
Options.CustomTimeValue = World_Tab:AddSlider('CustomTimeValue', { Text = '时间', Default = 12, Min = 0, Max = 24, Rounding = 1, Compact = false })
World_Tab:AddDivider()
World_Tab:AddLabel('拉伸分辨率')
Toggles.StretchResolution = World_Tab:AddToggle('StretchResolution', { Text = '拉伸分辨率', Default = false })
Toggles.StretchResolution:AddKeyPicker('StretchResolutionBind', { Default = 'None', SyncToggleState = true, Modes = { 'Toggle', 'Hold', 'Always' }, Text = '拉伸分辨率' })
Options.StretchResolutionValue = World_Tab:AddSlider('StretchResolutionValue', { Text = '分辨率（纵向拉伸）', Default = 0.80, Min = 0.10, Max = 2.00, Rounding = 2, Compact = false })

-- --- Bullet / Tracers ---
-- Bullet
Toggles.Tracers = Bullet_Tab:AddToggle('Tracers', { Text = '自定义弹道', Default = false })

local TracersDep = Bullet_Tab:AddDependencyBox()
TracersDep:SetupDependencies({ { Toggles.Tracers, true } })

TracersDep:AddDivider()
TracersDep:AddLabel('全局模式与风格')
Options.TracerMode = WXDrop(TracersDep, 'TracerMode', { Text = '弹道风格', Default = 1, Values = { 'Solid Beam', 'Laser Cylinder', 'Flying Bullet', 'Camera Facing Beam', 'Pulse Fade', '激光 Laser' } })
Options.TracerMaterial = WXDrop(TracersDep, 'TracerMaterial', { Text = '材质', Default = 1, Values = { 'Neon', 'ForceField', 'Glass', 'Ice', 'SmoothPlastic' } })
Options.TracerTransparency = TracersDep:AddSlider('TracerTransparency', { Text = '透明度', Default = 0.2, Min = 0, Max = 1, Rounding = 2, Compact = false })
Options.TracerColorMode = WXDrop(TracersDep, 'TracerColorMode', { Text = '颜色模式', Default = 1, Values = { 'Solid Color', 'Gradient (Muzzle -> Hit)' } })
Options.RainbowSpeed = TracersDep:AddSlider('RainbowSpeed', { Text = '彩虹速度', Default = 1, Min = 0.1, Max = 10, Rounding = 1, Compact = false })
Options.RainbowSpeed.Visible = false

TracersDep:AddDivider()
TracersDep:AddLabel('激光（风格选「激光 Laser」生效）')
TracersDep:AddLabel('激光颜色'):AddColorPicker('LaserColor', { Default = Color3.fromRGB(0, 255, 190), Title = '激光颜色' })
Options.LaserWidth = TracersDep:AddSlider('LaserWidth', { Text = '光柱宽度', Default = 0.22, Min = 0.05, Max = 1.2, Rounding = 2, Compact = false })
Options.LaserGlow = TracersDep:AddSlider('LaserGlow', { Text = '外层辉光', Default = 4.0, Min = 1, Max = 10, Rounding = 1, Compact = false })
Options.LaserLife = TracersDep:AddSlider('LaserLife', { Text = '余辉时长（秒）', Default = 0.22, Min = 0.05, Max = 1.2, Rounding = 2, Compact = false })
Options.LaserPulse = TracersDep:AddSlider('LaserPulse', { Text = '能量脉动', Default = 8, Min = 1, Max = 24, Rounding = 0, Compact = false })
Toggles.LaserCore = TracersDep:AddToggle('LaserCore', { Text = '白热核心', Default = true, Tooltip = '叠加一条极细的高亮核心，消除塑料感' })
Toggles.LaserFlicker = TracersDep:AddToggle('LaserFlicker', { Text = '能量抖动', Default = true, Tooltip = '模拟高压光束的细微抖动与闪烁' })
Toggles.LaserMuzzle = TracersDep:AddToggle('LaserMuzzle', { Text = '枪口闪光', Default = true })
Toggles.LaserRainbow = TracersDep:AddToggle('LaserRainbow', { Text = '彩虹激光', Default = false })
Toggles.LaserUseWeaponColor = TracersDep:AddToggle('LaserUseWeaponColor', { Text = '沿用武器弹道颜色', Default = false, Tooltip = '开启后激光使用上方各武器自己的弹道颜色，而不是激光颜色' })


TracersDep:AddDivider()
TracersDep:AddLabel('飞行子弹')
Options.FlyingBulletSpeed = TracersDep:AddSlider('FlyingBulletSpeed', { Text = '子弹速度', Default = 1200, Min = 200, Max = 4000, Rounding = 0, Compact = false })
Options.FlyingBulletLength = TracersDep:AddSlider('FlyingBulletLength', { Text = '子弹长度', Default = 4, Min = 1, Max = 20, Rounding = 1, Compact = false })

TracersDep:AddDivider()
TracersDep:AddLabel('命中特效与辉光')
Toggles.TracersImpact = TracersDep:AddToggle('TracersImpact', { Text = '命中火花', Default = true })
Options.TracerImpactSize = TracersDep:AddSlider('TracerImpactSize', { Text = '命中特效大小', Default = 0.8, Min = 0.2, Max = 3.0, Rounding = 2, Compact = false })
Toggles.TracersGlow = TracersDep:AddToggle('TracersGlow', { Text = '灯光辉光', Default = false })

local GlowDep = TracersDep:AddDependencyBox()
GlowDep:SetupDependencies({ { Toggles.TracersGlow, true } })
Options.TracerGlowRange = GlowDep:AddSlider('TracerGlowRange', { Text = '辉光范围', Default = 7, Min = 1, Max = 20, Rounding = 0, Compact = false })
Options.TracerGlowBrightness = GlowDep:AddSlider('TracerGlowBrightness', { Text = '辉光亮度', Default = 5, Min = 1, Max = 15, Rounding = 0, Compact = false })

TracersDep:AddDivider()
TracersDep:AddLabel('子弹全局')
Toggles.ShowBulletTracers = TracersDep:AddToggle('ShowBulletTracers', { Text = '子弹弹道', Default = true })
local BulletTracerDep = TracersDep:AddDependencyBox()
BulletTracerDep:SetupDependencies({ { Toggles.ShowBulletTracers, true } })
BulletTracerDep:AddLabel('颜色'):AddColorPicker('BulletColor', { Default = Color3.fromRGB(255, 255, 0), Title = '子弹颜色' })
Options.BulletThickness = BulletTracerDep:AddSlider('BulletThickness', { Text = '粗细', Default = 0.1, Min = 0.02, Max = 2, Rounding = 3, Compact = false })
Options.BulletLifetime = BulletTracerDep:AddSlider('BulletLifetime', { Text = '存在时间（秒）', Default = 0.3, Min = 0.01, Max = 5, Rounding = 2, Compact = false })
Toggles.BulletRainbow = BulletTracerDep:AddToggle('BulletRainbow', { Text = '彩虹', Default = false })
TracersDep:AddDivider()
TracersDep:AddLabel('狙击')
Toggles.ShowSniperTracers = TracersDep:AddToggle('ShowSniperTracers', { Text = '狙击弹道', Default = true })
local SniperTracerDep = TracersDep:AddDependencyBox()
SniperTracerDep:SetupDependencies({ { Toggles.ShowSniperTracers, true } })
SniperTracerDep:AddLabel('颜色'):AddColorPicker('SniperColor', { Default = Color3.fromRGB(190, 190, 190), Title = '狙击颜色' })
Options.SniperThickness = SniperTracerDep:AddSlider('SniperThickness', { Text = '粗细', Default = 0.17, Min = 0.02, Max = 2, Rounding = 3, Compact = false })
Options.SniperLifetime = SniperTracerDep:AddSlider('SniperLifetime', { Text = '存在时间（秒）', Default = 4, Min = 0.01, Max = 10, Rounding = 2, Compact = false })
Toggles.SniperRainbow = SniperTracerDep:AddToggle('SniperRainbow', { Text = '彩虹', Default = false })
TracersDep:AddDivider()
TracersDep:AddLabel('电击枪')
Toggles.ShowTaserTracers = TracersDep:AddToggle('ShowTaserTracers', { Text = '电击枪弹道', Default = true })
local TaserTracerDep = TracersDep:AddDependencyBox()
TaserTracerDep:SetupDependencies({ { Toggles.ShowTaserTracers, true } })
TaserTracerDep:AddLabel('颜色'):AddColorPicker('TaserColor', { Default = Color3.fromRGB(0, 234, 255), Title = '电击枪颜色' })
Options.TaserThickness = TaserTracerDep:AddSlider('TaserThickness', { Text = '粗细', Default = 0.2, Min = 0.02, Max = 2, Rounding = 3, Compact = false })
Options.TaserLifetime = TaserTracerDep:AddSlider('TaserLifetime', { Text = '存在时间（秒）', Default = 2, Min = 0.01, Max = 10, Rounding = 2, Compact = false })
Toggles.TaserRainbow = TaserTracerDep:AddToggle('TaserRainbow', { Text = '彩虹', Default = false })
TracersDep:AddDivider()
Toggles.TracersFilters = TracersDep:AddToggle('TracersFilters', { Text = '过滤', Default = false })

local FiltersDep = TracersDep:AddDependencyBox()
FiltersDep:SetupDependencies({ { Toggles.TracersFilters, true } })
Toggles.TracersTeammates = FiltersDep:AddToggle('TracersTeammates', { Text = '队友', Default = true })
Toggles.TracersGuards = FiltersDep:AddToggle('TracersGuards', { Text = '狱警', Default = true })
Toggles.TracersInmates = FiltersDep:AddToggle('TracersInmates', { Text = '囚犯', Default = true })
Toggles.TracersHostile = FiltersDep:AddToggle('TracersHostile', { Text = '敌对', Default = true })
Toggles.TracersCriminals = FiltersDep:AddToggle('TracersCriminals', { Text = '罪犯', Default = true })

local function updateRainbowSpeed()
    Options.RainbowSpeed.Visible = Toggles.BulletRainbow.Value or Toggles.SniperRainbow.Value or Toggles.TaserRainbow.Value
end
Toggles.BulletRainbow:OnChanged(updateRainbowSpeed)
Toggles.SniperRainbow:OnChanged(updateRainbowSpeed)
Toggles.TaserRainbow:OnChanged(updateRainbowSpeed)

-- --- Particles ---
Toggles.Particles = Particles_Tab:AddToggle('Particles', { Text = '启用', Default = false })
Toggles.Particles:AddColorPicker('ParticleColor', { Default = Color3.fromRGB(255, 100, 200), Title = '粒子颜色' })
Toggles.ParticleRainbow = Particles_Tab:AddToggle('ParticleRainbow', { Text = '彩虹', Default = false })

local ParticlesDep = Particles_Tab:AddDependencyBox()
ParticlesDep:SetupDependencies({ { Toggles.Particles, true } })

local particleStyleList = { 'Default', 'Bloom', 'Star', 'Heart', 'Dollar', 'Snow', 'Star 2', 'Kronex', 'Random' }
local particleModeList = { 'Normal', 'Bounce', 'Fountain', 'Vortex', 'Burst' }

Options.ParticleType = WXDrop(ParticlesDep, 'ParticleType', {
    Values = { 'Bloom', 'Star', 'Heart', 'Dollar', 'Snow', 'Star 2', 'Kronex', 'Random' },
    Default = 1,
    Multi = false,
    Text = '默认全局样式'
})

Options.ParticleSpawnEvents = WXDrop(ParticlesDep, 'ParticleSpawnEvents', {
    Values = { 'Attack', 'Totem', 'Move', 'Idle', 'Throw' },
    Default = { Attack = true, Totem = true, Move = true, Throw = true },
    Multi = true,
    Text = '事件触发时生成'
})

Options.ParticleSpeed = ParticlesDep:AddSlider('ParticleSpeed', { Text = '速度', Default = 1.5, Min = 0.1, Max = 5, Rounding = 1, Compact = false })
Options.ParticleSize = ParticlesDep:AddSlider('ParticleSize', { Text = '大小', Default = 1.2, Min = 0.2, Max = 5, Rounding = 1, Compact = false })

Toggles.ParticleRotation = ParticlesDep:AddToggle('ParticleRotation', { Text = '旋转', Default = true })
Toggles.ParticleGlow = ParticlesDep:AddToggle('ParticleGlow', { Text = '辉光效果', Default = true })
Toggles.ParticleThroughWalls = ParticlesDep:AddToggle('ParticleThroughWalls', { Text = '穿墙', Default = true })

-- Attack
ParticlesDep:AddDivider('Attack Action')
Options.AttackParticleStyle = WXDrop(ParticlesDep, 'AttackParticleStyle', { Values = particleStyleList, Default = 3, Text = '攻击风格' })
Options.AttackParticleMode = WXDrop(ParticlesDep, 'AttackParticleMode', { Values = particleModeList, Default = 2, Text = '攻击模式' })
Options.ParticleAttackCount = ParticlesDep:AddSlider('ParticleAttackCount', { Text = '攻击次数', Default = 15, Min = 3, Max = 40, Rounding = 0, Compact = false })
Toggles.AttackCustomColor = ParticlesDep:AddToggle('AttackCustomColor', { Text = '攻击自定义颜色', Default = false })
Toggles.AttackCustomColor:AddColorPicker('AttackColor', { Default = Color3.fromRGB(255, 70, 70), Title = '攻击颜色' })

-- Totem
ParticlesDep:AddDivider('Totem Action')
Options.TotemParticleStyle = WXDrop(ParticlesDep, 'TotemParticleStyle', { Values = particleStyleList, Default = 8, Text = '图腾风格' })
Options.TotemParticleMode = WXDrop(ParticlesDep, 'TotemParticleMode', { Values = particleModeList, Default = 3, Text = '图腾模式' })
Options.ParticleTotemCount = ParticlesDep:AddSlider('ParticleTotemCount', { Text = '图腾次数', Default = 18, Min = 4, Max = 40, Rounding = 0, Compact = false })
Toggles.TotemCustomColor = ParticlesDep:AddToggle('TotemCustomColor', { Text = '图腾自定义颜色', Default = false })
Toggles.TotemCustomColor:AddColorPicker('TotemColor', { Default = Color3.fromRGB(127, 221, 144), Title = '图腾颜色' })

-- Move
ParticlesDep:AddDivider('Move Action')
Options.MoveParticleStyle = WXDrop(ParticlesDep, 'MoveParticleStyle', { Values = particleStyleList, Default = 6, Text = '移动风格' })
Options.MoveParticleMode = WXDrop(ParticlesDep, 'MoveParticleMode', { Values = particleModeList, Default = 1, Text = '移动模式' })
Options.ParticleMoveCount = ParticlesDep:AddSlider('ParticleMoveCount', { Text = '移动次数', Default = 3, Min = 1, Max = 10, Rounding = 0, Compact = false })
Toggles.MoveCustomColor = ParticlesDep:AddToggle('MoveCustomColor', { Text = '移动自定义颜色', Default = false })
Toggles.MoveCustomColor:AddColorPicker('MoveColor', { Default = Color3.fromRGB(100, 200, 255), Title = '移动颜色' })

-- Idle
ParticlesDep:AddDivider('Idle Action')
Options.IdleParticleStyle = WXDrop(ParticlesDep, 'IdleParticleStyle', { Values = particleStyleList, Default = 4, Text = '待机风格' })
Options.IdleParticleMode = WXDrop(ParticlesDep, 'IdleParticleMode', { Values = particleModeList, Default = 4, Text = '待机模式' })
Options.ParticleIdleCount = ParticlesDep:AddSlider('ParticleIdleCount', { Text = '待机次数', Default = 3, Min = 1, Max = 15, Rounding = 0, Compact = false })
Options.ParticleIdleRange = ParticlesDep:AddSlider('ParticleIdleRange', { Text = '待机范围', Default = 16, Min = 4, Max = 32, Rounding = 0, Compact = false })
Toggles.IdleCustomColor = ParticlesDep:AddToggle('IdleCustomColor', { Text = '待机自定义颜色', Default = false })
Toggles.IdleCustomColor:AddColorPicker('IdleColor', { Default = Color3.fromRGB(255, 120, 220), Title = '待机颜色' })

-- Throw
ParticlesDep:AddDivider('Throw Action')
Options.ThrowParticleStyle = WXDrop(ParticlesDep, 'ThrowParticleStyle', { Values = particleStyleList, Default = 2, Text = '投掷风格' })
Options.ThrowParticleMode = WXDrop(ParticlesDep, 'ThrowParticleMode', { Values = particleModeList, Default = 1, Text = '投掷模式' })
Options.ParticleThrowCount = ParticlesDep:AddSlider('ParticleThrowCount', { Text = '投掷次数', Default = 4, Min = 1, Max = 12, Rounding = 0, Compact = false })
Toggles.ThrowCustomColor = ParticlesDep:AddToggle('ThrowCustomColor', { Text = '投掷自定义颜色', Default = false })
Toggles.ThrowCustomColor:AddColorPicker('ThrowColor', { Default = Color3.fromRGB(255, 210, 80), Title = '投掷颜色' })

-- --- Target HUD ---
Toggles.TargetHUD = TargetHUD_Tab:AddToggle('TargetHUD', { Text = '目标信息面板', Default = false })
Toggles.TargetHUD:AddKeyPicker('TargetHUDBind', { Default = 'None', SyncToggleState = false, Modes = { 'Toggle', 'Hold', 'Always' }, Text = '目标信息面板' })
TargetHUD_Tab:AddDivider()

Toggles.TargetHUDCustomColor = TargetHUD_Tab:AddToggle('TargetHUDCustomColor', { Text = '自定义强调色', Default = false })
Toggles.TargetHUDCustomColor:AddColorPicker('TargetHUDAccentColor', { Default = Color3.fromRGB(0, 170, 255), Title = '强调色' })

Options.TargetHUDStyle = WXDrop(TargetHUD_Tab, 'TargetHUDStyle', {
    Values = { 'Linoria Modern', 'Linoria Accent' },
    Default = 1,
    Multi = false,
    Text = '风格'
})

TargetHUD_Tab:AddDivider()
Toggles.TargetHUDShowAvatar = TargetHUD_Tab:AddToggle('TargetHUDShowAvatar', { Text = '显示头像', Default = true })
Toggles.TargetHUDShowChance = TargetHUD_Tab:AddToggle('TargetHUDShowChance', { Text = '显示击杀几率', Default = true })
Toggles.TargetHUDShowWeapon = TargetHUD_Tab:AddToggle('TargetHUDShowWeapon', { Text = '显示武器', Default = true })
Toggles.TargetHUDShowDistance = TargetHUD_Tab:AddToggle('TargetHUDShowDistance', { Text = '显示距离', Default = true })
TargetHUD_Tab:AddDivider()
TargetHUD_Tab:AddButton({
    Text = '重置位置',
    Func = function()
        if _G.BoarsResetTargetHUD then
            _G.BoarsResetTargetHUD()
        end
    end
})

-- --- Killfeed ---
Toggles.Killfeed = Killfeed_Tab:AddToggle('Killfeed', { Text = '击杀提示', Default = false })
Toggles.Killfeed:AddKeyPicker('KillfeedBind', { Default = 'None', SyncToggleState = false, Modes = { 'Toggle', 'Hold', 'Always' }, Text = '击杀提示' })

local KillfeedDep = Killfeed_Tab:AddDependencyBox()
KillfeedDep:SetupDependencies({ { Toggles.Killfeed, true } })

Toggles.KillfeedOnlyLocal = KillfeedDep:AddToggle('KillfeedOnlyLocal', {
    Text = '仅我的击杀',
    Default = false,
    Tooltip = '仅显示与你相关的击杀与死亡'
})

Toggles.KillfeedHighlightMine = KillfeedDep:AddToggle('KillfeedHighlightMine', {
    Text = '高亮我的击杀',
    Default = true,
    Tooltip = '用青色强调条与高亮名字标示你的击杀'
})

Toggles.KillfeedShowWeapon = KillfeedDep:AddToggle('KillfeedShowWeapon', {
    Text = '显示武器',
    Default = true
})

Toggles.KillfeedShowHeadshot = KillfeedDep:AddToggle('KillfeedShowHeadshot', {
    Text = '显示爆头图标',
    Default = true
})

Toggles.KillfeedShowDistance = KillfeedDep:AddToggle('KillfeedShowDistance', {
    Text = '显示距离',
    Default = true
})

Toggles.KillfeedShowHits = KillfeedDep:AddToggle('KillfeedShowHits', {
    Text = '命中播报',
    Default = true,
    Tooltip = '命中敌人（未击杀）时也推送一条播报，显示本次伤害'
})

Toggles.KillfeedMergeHits = KillfeedDep:AddToggle('KillfeedMergeHits', {
    Text = '连击合并',
    Default = true,
    Tooltip = '连续命中同一目标时合并成一条播报并累加伤害，避免刷屏'
})

KillfeedDep:AddDivider()

Options.KillfeedMaxItems = KillfeedDep:AddSlider('KillfeedMaxItems', {
    Text = '最大显示数',
    Default = 5,
    Min = 2,
    Max = 10,
    Rounding = 0,
    Compact = false
})

Options.KillfeedDuration = KillfeedDep:AddSlider('KillfeedDuration', {
    Text = '持续时间（秒）',
    Default = 5,
    Min = 2,
    Max = 12,
    Rounding = 1,
    Compact = false
})

Options.KillfeedScale = KillfeedDep:AddSlider('KillfeedScale', {
    Text = '界面缩放',
    Default = 0.78,
    Min = 0.5,
    Max = 1.2,
    Rounding = 2,
    Compact = false
})

KillfeedDep:AddDivider()

KillfeedDep:AddButton({
    Text = '测试击杀提示（预览）',
    Func = function()
        if _G.BoarsTestKillfeed then
            _G.BoarsTestKillfeed()
        end
    end
})

KillfeedDep:AddButton({
    Text = '测试命中播报（预览）',
    Func = function()
        if _G.BoarsTestHitfeed then
            _G.BoarsTestHitfeed()
        end
    end
})

-- ====================== MOVEMENT ======================

-- Left Column: Player Movement & Flight
local MoveBox = Tabs.Movement:AddLeftTabbox()
local Main_Tab = MoveBox:AddTab('移动')
local Fly_Tab = MoveBox:AddTab('玩家飞行')

-- Movement (On Foot)
Toggles.Noclip = Main_Tab:AddToggle('Noclip', { Text = '穿墙', Default = false })
Toggles.Noclip:AddKeyPicker('NoclipBind', { Default = 'None', SyncToggleState = false, Modes = { 'Toggle', 'Hold', 'Always' }, Text = '穿墙' })

-- 手机端快捷按钮（穿墙）
Main_Tab:AddDivider()
Toggles.NoclipMobile = Main_Tab:AddToggle('NoclipMobile', {
    Text = '手机快捷按钮',
    Default = Library.IsMobile,
    Tooltip = '开启后在屏幕上生成一个穿墙开关圆钮，可拖动摆放'
})
local NoclipMobileDep = Main_Tab:AddDependencyBox()
NoclipMobileDep:SetupDependencies({ { Toggles.NoclipMobile, true } })
Toggles.NoclipMobileLock = NoclipMobileDep:AddToggle('NoclipMobileLock', {
    Text = '锁定快捷按钮',
    Default = false,
    Tooltip = '开启后按钮固定位置，无法拖动，只保留点击开关穿墙'
})

Main_Tab:AddDivider()
Toggles.KillbrickBypass = Main_Tab:AddToggle('KillbrickBypass', { Text = '秒杀砖绕过', Default = false })
Toggles.KillbrickBypass:AddKeyPicker('KillbrickBypassBind', { Default = 'None', SyncToggleState = false, Modes = { 'Toggle', 'Hold', 'Always' }, Text = '秒杀砖绕过' })

local KillbrickDep = Main_Tab:AddDependencyBox()
KillbrickDep:SetupDependencies({ { Toggles.KillbrickBypass, true } })
Toggles.KillbrickRemoveBoundary = KillbrickDep:AddToggle('KillbrickRemoveBoundary', { Text = '移除地图边界', Default = true })
Toggles.KillbrickDisableTouch = KillbrickDep:AddToggle('KillbrickDisableTouch', { Text = '禁用触碰击杀装置', Default = true })
Toggles.KillbrickCharTouchProtect = KillbrickDep:AddToggle('KillbrickCharTouchProtect', { Text = '角色触碰保护', Default = false })

Main_Tab:AddDivider()
Toggles.InfiniteStamina = Main_Tab:AddToggle('InfiniteStamina', { Text = '无限体力', Default = false })

Main_Tab:AddDivider()
Toggles.AirStrafe = Main_Tab:AddToggle('AirStrafe', { Text = '空中平移', Default = false })
Toggles.AirStrafe:AddKeyPicker('AirStrafeBind', { Default = 'None', SyncToggleState = false, Modes = { 'Toggle', 'Hold', 'Always' }, Text = '空中平移' })

Main_Tab:AddDivider()
Toggles.SpeedRegions = Main_Tab:AddToggle('SpeedRegions', { Text = '人物加速', Default = false })
Toggles.SpeedRegions:AddKeyPicker('SpeedRegionsBind', { Default = 'None', SyncToggleState = false, Modes = { 'Toggle', 'Hold', 'Always' }, Text = '人物加速' })

Options.SpeedValue = Main_Tab:AddSlider('SpeedValue', {
    Text = '人物移速',
    Default = 100,
    Min = 16,
    Max = 300,
    Rounding = 0,
    Compact = false,
    Suffix = ' 格/秒',
    AllowRightClickInput = true,
    Tooltip = '拖动滑块调节移速；右键滑块可直接输入精确数值'
})
Options.JumpValue = Main_Tab:AddSlider('JumpValue', {
    Text = '跳跃高度',
    Default = 50,
    Min = 0,
    Max = 120,
    Rounding = 1,
    Compact = false,
    Suffix = ' 格',
    AllowRightClickInput = true,
    Tooltip = '配合人物加速使用；右键滑块可直接输入数值'
})
Toggles.SpeedZoneAuto = Main_Tab:AddToggle('SpeedZoneAuto', {
    Text = '按区域自动调速（原版逻辑）',
    Default = false,
    Tooltip = '开启后忽略上面的数值，按区域自动使用 80 / 70 / 100 移速；关闭后全图统一使用滑块数值'
})

-- 手机端快捷按钮（人物移速）
Main_Tab:AddDivider()
Toggles.SpeedRegionsMobile = Main_Tab:AddToggle('SpeedRegionsMobile', {
    Text = '手机快捷按钮',
    Default = Library.IsMobile,
    Tooltip = '开启后在屏幕上生成一个移速开关按钮，可拖动摆放'
})
local SpeedMobileDep = Main_Tab:AddDependencyBox()
SpeedMobileDep:SetupDependencies({ { Toggles.SpeedRegionsMobile, true } })
Toggles.SpeedRegionsMobileLock = SpeedMobileDep:AddToggle('SpeedRegionsMobileLock', {
    Text = '锁定快捷按钮',
    Default = false,
    Tooltip = '开启后按钮固定位置，无法拖动，只保留点击开关人物加速'
})

-- Player Fly (Flight) —— 简洁版
Toggles.PlayerFly = Fly_Tab:AddToggle('PlayerFly', { Text = '飞行', Default = false })
Toggles.PlayerFly:AddKeyPicker('PlayerFlyBind', { Default = 'None', SyncToggleState = false, Modes = { 'Toggle', 'Hold', 'Always' }, Text = '玩家飞行' })

local FlyDep = Fly_Tab:AddDependencyBox()
FlyDep:SetupDependencies({ { Toggles.PlayerFly, true } })

FlyDep:AddLabel('朝视角方向飞 · 松手原地悬停 · 飞行中无碰撞')
Options.PlayerFlySpeed = FlyDep:AddSlider('PlayerFlySpeed', {
    Text = '飞行速度',
    Default = 80,
    Min = 10,
    Max = 800,
    Rounding = 0,
    Compact = false,
    Suffix = ' 格/秒',
    AllowRightClickInput = true,
    Tooltip = '拖动滑块调节；右键滑块可直接输入精确数值'
})
Options.PlayerFlyMaxHeight = FlyDep:AddSlider('PlayerFlyMaxHeight', {
    Text = '最大飞行高度（0 = 不限）',
    Default = 80,
    Min = 0,
    Max = 1000,
    Rounding = 0,
    Compact = false,
    Suffix = ' 格',
    AllowRightClickInput = true,
    Tooltip = '相对起飞点的高度上限；右键滑块可直接输入数值'
})

FlyDep:AddDivider()
Toggles.PlayerFlySoftLand = FlyDep:AddToggle('PlayerFlySoftLand', {
    Text = '关闭时缓降落地',
    Default = true,
    Tooltip = '关掉飞行不再直接摔下去，先降到贴地再交还控制权'
})

FlyDep:AddDivider()
FlyDep:AddButton({ Text = '降落（关闭飞行）', Func = function() if Toggles.PlayerFly then Toggles.PlayerFly:SetValue(false) end end })
FlyDep:AddButton({ Text = '恢复默认（80 / 80）', Func = function()
    if Options.PlayerFlySpeed then Options.PlayerFlySpeed:SetValue(80) end
    if Options.PlayerFlyMaxHeight then Options.PlayerFlyMaxHeight:SetValue(80) end
end })

-- 手机端快捷按钮（飞行）
Fly_Tab:AddDivider()
Toggles.PlayerFlyMobile = Fly_Tab:AddToggle('PlayerFlyMobile', {
    Text = '手机快捷按钮',
    Default = Library.IsMobile,
    Tooltip = '开启后在屏幕上生成一个飞行开关按钮，可拖动摆放'
})
local FlyMobileDep = Fly_Tab:AddDependencyBox()
FlyMobileDep:SetupDependencies({ { Toggles.PlayerFlyMobile, true } })
Toggles.PlayerFlyMobileLock = FlyMobileDep:AddToggle('PlayerFlyMobileLock', {
    Text = '锁定快捷按钮',
    Default = false,
    Tooltip = '开启后按钮固定位置，无法拖动，只保留点击开关飞行'
})

-- Right Column: Combat Movement & Vehicles
local CombatMoveBox = Tabs.Movement:AddRightTabbox()
local AntiAim_Tab = CombatMoveBox:AddTab('反瞄准')
local Car_Tab = CombatMoveBox:AddTab('载具')

-- Anti-Aim
Toggles.AntiAim = AntiAim_Tab:AddToggle('AntiAim', { Text = '反瞄准', Default = false })
Toggles.AntiAim:AddKeyPicker('AntiAimBind', { Default = 'None', SyncToggleState = false, Modes = { 'Toggle', 'Hold', 'Always' }, Text = '反瞄准' })

local AntiAimDep = AntiAim_Tab:AddDependencyBox()
AntiAimDep:SetupDependencies({ { Toggles.AntiAim, true } })
Options.AntiAimMode = WXDrop(AntiAimDep, 'AntiAimMode', { Values = { 'Spin', 'Jitter' }, Default = 1, Multi = false, Text = '模式' })
Toggles.AntiAimDisableInVehicle = AntiAimDep:AddToggle('AntiAimDisableInVehicle', { Text = '载具内禁用', Default = true })
Options.SpinSpeed = AntiAimDep:AddSlider('SpinSpeed', { Text = '自旋速度', Default = 20, Min = 1, Max = 100, Rounding = 0, Compact = false })
Options.JitterRange = AntiAimDep:AddSlider('JitterRange', { Text = '抖动范围', Default = 30, Min = 5, Max = 90, Rounding = 0, Compact = false })

local function updateAntiAimUI()
    task.defer(function()
        local mode = Options.AntiAimMode.Value
        Options.SpinSpeed.Visible = (mode == 'Spin')
        Options.JitterRange.Visible = (mode == 'Jitter')
    end)
end
Options.AntiAimMode:OnChanged(updateAntiAimUI)
Toggles.AntiAim:OnChanged(updateAntiAimUI)
updateAntiAimUI()

-- Vehicle
Toggles.CarFly = Car_Tab:AddToggle('CarFly', { Text = '载具飞行', Default = false })
Toggles.CarFly:AddKeyPicker('CarFlyBind', { Default = 'None', SyncToggleState = false, Modes = { 'Toggle', 'Hold', 'Always' }, Text = '载具飞行' })
Car_Tab:AddDivider()
Options.CarFlySpeed = Car_Tab:AddSlider('CarFlySpeed', { Text = '飞行速度', Default = 100, Min = 20, Max = 300, Rounding = 0, Compact = false })
Options.CarFlyVertSpeed = Car_Tab:AddSlider('CarFlyVertSpeed', { Text = '垂直速度', Default = 50, Min = 10, Max = 150, Rounding = 0, Compact = false })
Options.CarFlyMode = WXDrop(Car_Tab, 'CarFlyMode', { Values = { 'Camera Relative', 'Flat / Level' }, Default = 1, Multi = false, Text = '飞行模式' })
Car_Tab:AddDivider()
Toggles.CarFlyNoclip = Car_Tab:AddToggle('CarFlyNoclip', { Text = '载具穿墙（可穿墙飞行）', Default = false })
end


-- ====================== LOGIC ======================

-- Noclip
do
    local noclipBypassed = false
    local function bypassNoclip()
        if noclipBypassed then return end
        local charCollision = ReplicatedStorage:FindFirstChild('Scripts') and ReplicatedStorage.Scripts:FindFirstChild('CharacterCollision')
        if charCollision then
            charCollision:Destroy()
        end
        local char = LP.Character
        if char then
            local head = char:FindFirstChild('Head')
            if head then
                for _, conn in getconnections(head:GetPropertyChangedSignal('CanCollide')) do
                    conn:Disable()
                end
            end
        end
        noclipBypassed = true
    end

    RunService.Stepped:Connect(function()
        if Toggles.Noclip.Value then
            bypassNoclip()
            local char = LP.Character
            if not char then return end
            for _, part in char:GetDescendants() do
                if part:IsA('BasePart') then
                    part.CanCollide = false
                end
            end
        end
    end)
end

-- Killbrick & Boundary Bypass (Anti-Death Barrier)
do
    local function neutralizePart(part)
        if not part or not part:IsA('BasePart') then return end
        pcall(function()
            part.CanTouch = false
            part.CanCollide = false
            part.CanQuery = false
            for _, child in ipairs(part:GetChildren()) do
                if child:IsA('TouchTransmitter') then
                    child:Destroy()
                end
            end
            part:Destroy()
        end)
    end

    local function clearBoundary()
        local boundary = Workspace:FindFirstChild('BOUNDARY')
        if boundary then
            pcall(function()
                for _, part in ipairs(boundary:GetChildren()) do
                    if part:IsA('BasePart') then
                        neutralizePart(part)
                    end
                end
                boundary:Destroy()
            end)
        end
    end

    local function scanAndNeutralize()
        if not (Toggles.KillbrickBypass and Toggles.KillbrickBypass.Value) then return end

        -- 1. Remove Workspace.BOUNDARY
        if not Toggles.KillbrickRemoveBoundary or Toggles.KillbrickRemoveBoundary.Value then
            clearBoundary()
        end

        -- 2. Neutralize any boundary/killbrick parts in Workspace
        if not Toggles.KillbrickDisableTouch or Toggles.KillbrickDisableTouch.Value then
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj.Name:lower() == 'boundary' then
                    pcall(function()
                        for _, p in ipairs(obj:GetChildren()) do
                            neutralizePart(p)
                        end
                        obj:Destroy()
                    end)
                elseif obj:IsA('BasePart') and (obj.Name:lower():find('boundary') or obj.Name:lower():find('killbrick')) then
                    neutralizePart(obj)
                end
            end
        end
    end

    -- Initial sweep on load
    clearBoundary()
    scanAndNeutralize()

    -- Toggle change handler
    if Toggles.KillbrickBypass then
        Toggles.KillbrickBypass:OnChanged(function()
            if Toggles.KillbrickBypass.Value then
                scanAndNeutralize()
            end
        end)
    end

    -- Watch for newly spawned / streaming boundary parts
    Workspace.ChildAdded:Connect(function(child)
        if Toggles.KillbrickBypass and Toggles.KillbrickBypass.Value then
            local low = child.Name:lower()
            if low == 'boundary' or low:find('killbrick') then
                task.defer(function()
                    if child and child.Parent then
                        pcall(function()
                            for _, p in ipairs(child:GetChildren()) do
                                neutralizePart(p)
                            end
                            child:Destroy()
                        end)
                    end
                end)
            end
        end
    end)

    -- Periodic background maintenance sweep
    task.spawn(function()
        while true do
            task.wait(2.5)
            if Toggles.KillbrickBypass and Toggles.KillbrickBypass.Value then
                pcall(scanAndNeutralize)
            end
        end
    end)

    -- Character Touch Protection (prevents touching hazards while moving/flying)
    RunService.Stepped:Connect(function()
        if not (Toggles.KillbrickBypass and Toggles.KillbrickBypass.Value) then return end
        if Toggles.KillbrickCharTouchProtect and Toggles.KillbrickCharTouchProtect.Value then
            local char = LP.Character
            if char then
                for _, part in ipairs(char:GetChildren()) do
                    if part:IsA('BasePart') and part.Name ~= 'HumanoidRootPart' then
                        part.CanTouch = false
                    end
                end
            end
        end
    end)
end

-- Vehicle Detection Helpers
local function getVehicleFromSeat(seat)
    if not seat then return nil end
    local carContainer = Workspace:FindFirstChild('CarContainer')
    if carContainer and seat:IsDescendantOf(carContainer) then
        local curr = seat
        while curr.Parent and curr.Parent ~= carContainer and curr.Parent ~= Workspace do
            curr = curr.Parent
        end
        return curr
    end
    local model = seat:FindFirstAncestorOfClass('Model')
    if model then
        if CollectionService:HasTag(model, 'Vehicle') or model.Name == 'Squad' or (carContainer and model:IsDescendantOf(carContainer)) then
            return model
        end
    end
    if seat:IsA('VehicleSeat') or seat:IsA('Seat') then
        return model or seat
    end
    return nil
end

local function isInVehicle(player)
    local char = player and player.Character
    if not char then return false, nil end
    local hum = char:FindFirstChildOfClass('Humanoid')
    local seat = hum and hum.SeatPart
    if seat then
        local vehicle = getVehicleFromSeat(seat)
        return true, vehicle or seat
    end
    return false, nil
end

-- Anti Aim
do
    local antiAngle = 0
    local antiJitterDir = 1
    RunService.RenderStepped:Connect(function(dt)
        if Toggles.AntiAim.Value then
            local disableInVehicle = (Toggles.AntiAimDisableInVehicle == nil) or Toggles.AntiAimDisableInVehicle.Value
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass('Humanoid')
            if disableInVehicle and (isInVehicle(LP) or (hum and hum.SeatPart)) then
                return
            end

            local root = char and char:FindFirstChild('HumanoidRootPart')
            if root then
                local mode = Options.AntiAimMode.Value
                if mode == 'Spin' then
                    antiAngle = (antiAngle + (Options.SpinSpeed.Value or 20) * 0.15) % 360
                    root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, math.rad(antiAngle), 0)
                elseif mode == 'Jitter' then
                    local range = Options.JitterRange.Value or 30
                    antiAngle = math.random(-range, range)
                    root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, math.rad(antiAngle), 0)
                end
            end
        end
    end)
end

-- Car Fly
do
    local carFlyActive = false
    local carFlyBV = nil
    local carFlyBG = nil
    local currentCarModel = nil
    local originalCanCollide = {}

    local function stopCarFly()
        if carFlyBV then
            pcall(function() carFlyBV:Destroy() end)
            carFlyBV = nil
        end
        if carFlyBG then
            pcall(function() carFlyBG:Destroy() end)
            carFlyBG = nil
        end
        if next(originalCanCollide) then
            for part, canCollide in pairs(originalCanCollide) do
                if part and part.Parent and part:IsA('BasePart') then
                    pcall(function() part.CanCollide = canCollide end)
                end
            end
            table.clear(originalCanCollide)
        end
        currentCarModel = nil
        carFlyActive = false
    end

    local function getFlyDirection(mode)
    if UserInputService:GetFocusedTextBox() then
        return Vector3.zero, 0
    end

    local camCF = Camera.CFrame
    local forward = camCF.LookVector
    local right   = camCF.RightVector

    -- 1) 优先读摇杆 / 键盘 / 手柄（手机关键）
    local moveX, moveZ = 0, 0
    local controls = ensureControls()
    if controls and controls.GetMoveVector then
        local ok, mv = pcall(controls.GetMoveVector, controls)
        if ok and mv then
            moveX = mv.X
            moveZ = mv.Z
        end
    end

    -- 2) 摇杆为空时回退到键盘
    if moveX == 0 and moveZ == 0 then
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveZ = moveZ - 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveZ = moveZ + 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveX = moveX + 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveX = moveX - 1 end
    end

    -- 3) 垂直输入
    local vertDir = 0
    if UserInputService.KeyboardEnabled then
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vertDir = vertDir + 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
            or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            vertDir = vertDir - 1
        end
    end
    if IS_MOBILE and vertDir == 0 then
        local pitch = forward.Y
        if math.abs(pitch) > 0.12 then vertDir = pitch * 2 end
    end

    -- 4) Flat 模式压平前/右向量
    if mode == 'Flat / Level' then
        forward = Vector3.new(forward.X, 0, forward.Z)
        if forward.Magnitude > 0.001 then forward = forward.Unit
        else forward = Vector3.new(0, 0, -1) end
        right = Vector3.new(right.X, 0, right.Z)
        if right.Magnitude > 0.001 then right = right.Unit end
    end

    -- 5) 合成方向（摇杆力度可微调速度）
    local hDir = (forward * (-moveZ)) + (right * moveX)
    local inputMag = Vector2.new(moveX, moveZ).Magnitude
    if hDir.Magnitude > 0.001 then
        hDir = hDir.Unit * math.min(1, inputMag)
    else
        hDir = Vector3.zero
    end

    return hDir, vertDir
end

    if Toggles.CarFly then
        Toggles.CarFly:OnChanged(function()
            if not Toggles.CarFly.Value then
                stopCarFly()
            end
        end)
    end

    RunService.RenderStepped:Connect(function()
        if not (Toggles.CarFly and Toggles.CarFly.Value) then
            if carFlyActive then
                stopCarFly()
            end
            return
        end

        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass('Humanoid')
        local seat = hum and hum.SeatPart

        if not seat or not seat.Parent then
            if carFlyActive then
                stopCarFly()
            end
            return
        end

        local rootPart = seat.AssemblyRootPart or seat
        local carModel = getVehicleFromSeat(seat) or (seat:IsA('Model') and seat or seat.Parent)

        if not carFlyBV or carFlyBV.Parent ~= rootPart then
            if carFlyBV then pcall(function() carFlyBV:Destroy() end) end
            carFlyBV = Instance.new('BodyVelocity')
            carFlyBV.Name = 'BoarsCarFlyVelocity'
            carFlyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            carFlyBV.Velocity = Vector3.zero
            carFlyBV.Parent = rootPart
        end

        if not carFlyBG or carFlyBG.Parent ~= rootPart then
            if carFlyBG then pcall(function() carFlyBG:Destroy() end) end
            carFlyBG = Instance.new('BodyGyro')
            carFlyBG.Name = 'BoarsCarFlyGyro'
            carFlyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            carFlyBG.P = 10000
            carFlyBG.D = 500
            carFlyBG.CFrame = rootPart.CFrame
            carFlyBG.Parent = rootPart
        end

        carFlyActive = true
        currentCarModel = carModel

        -- Vehicle Noclip (Fly through walls, fences and gates)
        if Toggles.CarFlyNoclip and Toggles.CarFlyNoclip.Value and carModel and carModel:IsA('Instance') then
            for _, part in ipairs(carModel:GetDescendants()) do
                if part:IsA('BasePart') and part ~= seat then
                    if originalCanCollide[part] == nil then
                        originalCanCollide[part] = part.CanCollide
                    end
                    part.CanCollide = false
                end
            end
        elseif next(originalCanCollide) and not (Toggles.CarFlyNoclip and Toggles.CarFlyNoclip.Value) then
            for part, canCollide in pairs(originalCanCollide) do
                if part and part.Parent and part:IsA('BasePart') then
                    pcall(function() part.CanCollide = canCollide end)
                end
            end
            table.clear(originalCanCollide)
        end

        local mode = (Options.CarFlyMode and Options.CarFlyMode.Value) or 'Camera Relative'
        local speed = (Options.CarFlySpeed and Options.CarFlySpeed.Value) or 100
        local vertSpeed = (Options.CarFlyVertSpeed and Options.CarFlyVertSpeed.Value) or 60

        local hDir, vertDir = getFlyDirection(mode)
        local camCF = Camera.CFrame

        if mode == 'Camera Relative' then
            carFlyBG.CFrame = camCF
        else
            local look = camCF.LookVector
            local flatLook = Vector3.new(look.X, 0, look.Z)
            if flatLook.Magnitude > 0.001 then
                carFlyBG.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + flatLook.Unit)
            end
        end

        local targetVelocity = (hDir * speed) + (Vector3.new(0, 1, 0) * (vertDir * vertSpeed))

        if targetVelocity.Magnitude > 0.1 then
            carFlyBV.Velocity = targetVelocity
        else
            carFlyBV.Velocity = Vector3.zero
            pcall(function()
                rootPart.AssemblyLinearVelocity = Vector3.zero
                rootPart.AssemblyAngularVelocity = Vector3.zero
            end)
        end
    end)
end

-- ====================== 玩家飞行（简洁版） ======================
-- 朝视角方向飞 / 松手锁高度悬停 / 无碰撞 / 强制直立 / 限高 / 关闭缓降
do
    local S = {
        active   = false,
        landing  = false,
        landTime = 0,
        char     = nil,
        hum      = nil,
        root     = nil,
        startY   = nil,
        lockY    = nil,
        autoRot  = nil,
        parts    = {},
        partConn = nil,
        lastScan = 0,
        moveSign = -1, -- 摇杆 Z 轴符号修正：标准 PlayerModule 前进时为 -1，取反后统一成「+Z = 前」
    }

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.IgnoreWater = true

    local function cam()
        return Workspace.CurrentCamera or Camera
    end

    local function getChar()
        local char = LP.Character
        if not char then return nil end
        return char, char:FindFirstChildOfClass('Humanoid'), char:FindFirstChild('HumanoidRootPart')
    end

    local function readSpeed()
        local v = tonumber(Options.PlayerFlySpeed and Options.PlayerFlySpeed.Value)
        if not v then v = 80 end
        return math.clamp(v, 10, 2000)
    end

    local function readMaxHeight()
        local v = tonumber(Options.PlayerFlyMaxHeight and Options.PlayerFlyMaxHeight.Value)
        if not v then v = 80 end
        return math.clamp(v, 0, 2000)
    end

    local function softLandEnabled()
        return Toggles.PlayerFlySoftLand == nil or Toggles.PlayerFlySoftLand.Value
    end

    -- 关掉全部碰撞，并记下原值，关闭飞行时逐个还原
    local function keepNoCollide(char)
        for _, d in ipairs(char:GetDescendants()) do
            if d:IsA('BasePart') then
                if S.parts[d] == nil then S.parts[d] = d.CanCollide end
                if d.CanCollide then
                    pcall(function() d.CanCollide = false end)
                end
            end
        end
    end

    local function groundDistance(char, root)
        rayParams.FilterDescendantsInstances = { char }
        local hit = Workspace:Raycast(root.Position, Vector3.new(0, -400, 0), rayParams)
        if hit then
            return (root.Position - hit.Position).Magnitude
        end
        return nil
    end

    -- 有没有移动输入：优先 Humanoid.MoveDirection（原逻辑），空了回退摇杆 / 键盘
    local function hasMoveInput(hum)
        if hum and hum.MoveDirection.Magnitude > 0.1 then return true end
        if UserInputService:GetFocusedTextBox() then return false end
        local controls = ensureControls and ensureControls()
        if controls and controls.GetMoveVector then
            local ok, mv = pcall(controls.GetMoveVector, controls)
            if ok and mv and mv.Magnitude > 0.1 then return true end
        end
        if UserInputService.KeyboardEnabled then
            local keys = {
                Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D,
                Enum.KeyCode.Up, Enum.KeyCode.Down, Enum.KeyCode.Left, Enum.KeyCode.Right
            }
            for _, key in ipairs(keys) do
                if UserInputService:IsKeyDown(key) then return true end
            end
        end
        return false
    end

    -- 摇杆前后方向修正
    -- PlayerModule:GetMoveVector() 的约定是「前进 = Z 为负、后退 = Z 为正」（和键盘 W/S 相反），
    -- 之前直接拿 mv.Z 当「前」用，所以往前推摇杆反而往后飞。
    -- 不同版本 PlayerModule 的符号不一定一致，这里用「角色真实移动方向」在起飞前校准一次。
    local function calibrateMoveSign(hum)
        local controls = ensureControls and ensureControls()
        if not (controls and controls.GetMoveVector) then return end
        if not hum or hum.Health <= 0 or hum.MoveDirection.Magnitude < 0.4 then return end

        local ok, mv = pcall(function() return controls:GetMoveVector() end)
        if not ok or typeof(mv) ~= 'Vector3' or math.abs(mv.Z) < 0.35 then return end

        local camera = cam()
        if not camera then return end

        -- 把真实移动方向转到相机局部空间：Z < 0 表示正在「向前」走
        local localDir = camera.CFrame:VectorToObjectSpace(hum.MoveDirection)
        if math.abs(localDir.Z) < 0.25 then return end

        -- 目标是让返回值「正 = 前进」：
        -- 标准约定前进时 mv.Z = -1，所以要乘 -1；若某环境前进时 mv.Z = +1（同号），就乘 +1
        local expect = (localDir.Z < 0) and -1 or 1
        S.moveSign = (mv.Z * expect > 0) and -1 or 1
    end

    -- 读取真实的移动方向（本地空间：X = 左右，Z = 前后），摇杆 / 键盘 / 手柄通用。
    -- 之前只判断「有没有输入」，方向永远取相机朝向，所以怎么按都是往前飞。
    local function readMoveInput()
        if UserInputService:GetFocusedTextBox() then return Vector3.zero end

        -- 1) 手机摇杆 / 手柄（ControlModule 返回的就是相机相对的移动向量）
        local controls = ensureControls and ensureControls()
        if controls and controls.GetMoveVector then
            local ok, mv = pcall(function() return controls:GetMoveVector() end)
            if ok and typeof(mv) == 'Vector3' and (math.abs(mv.X) + math.abs(mv.Z)) > 0.05 then
                -- Z 乘 moveSign 统一成「+Z = 前进」，避免前后颠倒
                return Vector3.new(mv.X, 0, mv.Z * (S.moveSign or -1))
            end
        end

        -- 2) 键盘：PlatformStand 下 Humanoid.MoveDirection 一直是 0，必须自己读键位
        local x, z = 0, 0
        if UserInputService.KeyboardEnabled then
            if UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.Up) then z = z + 1 end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.Down) then z = z - 1 end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) or UserInputService:IsKeyDown(Enum.KeyCode.Right) then x = x + 1 end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.Left) then x = x - 1 end
        end
        return Vector3.new(x, 0, z)
    end

    local function restore(char, hum)
        if S.partConn then
            pcall(function() S.partConn:Disconnect() end)
            S.partConn = nil
        end
        for part, orig in pairs(S.parts) do
            if part and part.Parent then
                pcall(function() part.CanCollide = orig end)
            end
        end
        S.parts = {}

        if S.root and S.root.Parent and S.autoRot ~= nil then
            pcall(function() S.root.AutoRotate = S.autoRot end)
        end
        S.autoRot = nil

        if hum and hum.Parent then
            pcall(function()
                hum.PlatformStand = false
                if hum.Health > 0 then
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end)
        end
    end

    -- 复活流程（原地复活）会短暂接管角色：这段时间不要起飞。
    -- 飞行会把 Humanoid 置成 PlatformStand 并关掉全部碰撞，若此时角色刚被传送回死亡点，
    -- 就会直接穿地掉进虚空 → 再死 → 再复活，形成「复活即死」的循环。
    -- 挂在 S 上而不是新增 local：主 chunk 的 local 数量本来就很紧。
    S.respawnBusy = function()
        return _G.WXRespawnBusy == true
    end

    -- 是否已经站稳（脚下不是空气），用于重生后延迟接管飞行
    S.readyForFly = function(char)
        if not char or not char.Parent then return false end
        local hum = char:FindFirstChildOfClass('Humanoid')
        local root = char:FindFirstChild('HumanoidRootPart')
        if not hum or not root or hum.Health <= 0 then return false end
        if hum.FloorMaterial ~= Enum.Material.Air then return true end
        -- 刚复活时常有一小段下坠，这里给 6 格容差
        local d = groundDistance(char, root)
        if d and d <= 6 then return true end
        return false
    end

    local function startFly()
        if S.active then return end
        if S.respawnBusy() then
            -- 复活流程结束后再试一次（只在开关仍打开、且次数不失控时）
            S.busyRetries = (S.busyRetries or 0) + 1
            if S.busyRetries <= 8 then
                task.delay(1, function()
                    if Toggles.PlayerFly and Toggles.PlayerFly.Value then
                        startFly()
                    end
                end)
            end
            return
        end
        S.busyRetries = 0
        local char, hum, root = getChar()
        if not char or not hum or not root or hum.Health <= 0 then return end

        -- 趁角色还在正常行走（MoveDirection 有效）时校准一次摇杆前后符号
        pcall(calibrateMoveSign, hum)

        S.active = true
        if not S.landing then
            S.parts = {}
        end
        S.landing = false
        S.char, S.hum, S.root = char, hum, root
        S.startY = root.Position.Y
        S.lockY = nil
        S.lastScan = 0

        S.autoRot = root.AutoRotate
        pcall(function() root.AutoRotate = false end)
        pcall(function() hum.PlatformStand = true end)
        keepNoCollide(char)

        if not S.partConn then
            S.partConn = char.DescendantAdded:Connect(function(d)
                if not S.active then return end
                if d:IsA('BasePart') then
                    if S.parts[d] == nil then S.parts[d] = d.CanCollide end
                    pcall(function() d.CanCollide = false end)
                end
            end)
        end
    end

    local function finishLanding()
        local char, hum = S.char, S.hum
        S.landing = false
        restore(char, hum)
    end

    local function stopFly(silent)
        if S.landing then return end
        local wasActive = S.active
        S.active = false
        if not wasActive then return end

        local char, hum, root = S.char, S.hum, S.root
        if not silent and softLandEnabled() and char and hum and root and root.Parent and hum.Health > 0 then
            local d = groundDistance(char, root)
            if d and d > 5.5 then
                S.landing = true
                S.landTime = tick()
                return
            end
        end
        restore(char, hum)
    end

    local function loop(dt)
        local char, hum, root = getChar()

        -- 关闭后的缓降阶段：保持无碰撞，垂直落到贴地再交还控制
        if S.landing then
            if not char or not hum or not root or hum.Health <= 0 then
                S.landing = false
                return
            end
            -- 角色换了（死亡重生 / 被服务器重载）：缓降对象已经不存在，立刻收手，
            -- 否则会把刚复活的新角色一路往下压，压穿地板掉进虚空
            if S.char and char ~= S.char then
                S.landing = false
                return
            end
            pcall(function() hum.PlatformStand = true end)
            local now = tick()
            if now - S.lastScan > 0.3 then
                S.lastScan = now
                keepNoCollide(char)
            end

            local d = groundDistance(char, root)
            -- 脚下 400 格内都没有地面 = 悬空 / 虚空：继续往下压只会撞上坠落销毁线秒死
            if not d then
                finishLanding()
                return
            end
            if d <= 5 or (tick() - S.landTime) > 8 then
                finishLanding()
                return
            end
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            root.CFrame = root.CFrame - Vector3.new(0, 26 * dt, 0)
            return
        end

        if not S.active then return end
        if not char or not hum or not root or hum.Health <= 0 or char ~= S.char then
            stopFly(true)
            return
        end

        -- 其它脚本可能把碰撞改回来，每 0.3 秒兜底扫一遍
        local now = tick()
        if now - S.lastScan > 0.3 then
            S.lastScan = now
            keepNoCollide(char)
        end

        pcall(function()
            if not hum.PlatformStand then hum.PlatformStand = true end
        end)

        local camera = cam()
        if not camera then return end
        local camCF = camera.CFrame
        local look = camCF.LookVector

        -- 真实方向输入：W 前 / S 后 / A 左 / D 右（摇杆按量程给速度）
        local mv = readMoveInput()
        local mag = math.min(mv.Magnitude, 1)

        if mag > 0.05 then
            -- 有方向输入：清掉悬停锁
            S.lockY = nil

            -- 前后沿视线（带俯仰，可爬升 / 下沉），左右严格贴水平面平移
            local dir = look * mv.Z
            local rightFlat = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z)
            if rightFlat.Magnitude > 0.001 then
                dir = dir + rightFlat.Unit * mv.X
            end

            local maxH = readMaxHeight()
            if maxH > 0 then
                local height = root.Position.Y - (S.startY or root.Position.Y)
                if height >= maxH and dir.Y > 0 then
                    dir = Vector3.new(dir.X, 0, dir.Z)
                end
            end

            if dir.Magnitude > 0.001 then
                root.CFrame = root.CFrame + dir.Unit * (readSpeed() * dt * mag)
            end
        else
            -- 无输入：锁住当前高度原地悬停
            if not S.lockY then S.lockY = root.Position.Y end
            root.CFrame = CFrame.new(root.Position.X, S.lockY, root.Position.Z)
        end

        -- 不许飞进引擎坠落销毁线：部件一被销毁就是秒死，叠加原地复活会变成死亡循环
        local fpdh = Workspace.FallenPartsDestroyHeight
        if fpdh and root.Position.Y < fpdh + 40 then
            root.CFrame = root.CFrame + Vector3.new(0, (fpdh + 40) - root.Position.Y, 0)
            S.lockY = root.Position.Y
        end

        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero

        -- 强制直立：机身朝向相机的水平方向
        local flat = Vector3.new(look.X, 0, look.Z)
        if flat.Magnitude > 0.1 then
            local pos = root.CFrame.Position
            root.CFrame = CFrame.lookAt(pos, pos + flat.Unit)
        end
    end

    local flyConn = RunService.RenderStepped:Connect(function(dt)
        local ok = pcall(loop, math.clamp(dt, 0.001, 0.1))
        if not ok and S.active then
            pcall(stopFly, true)
        end
    end)

    if Toggles.PlayerFly then
        Toggles.PlayerFly:OnChanged(function()
            if Toggles.PlayerFly.Value then
                startFly()
            else
                stopFly(false)
            end
        end)

        if Toggles.PlayerFly.Value then
            task.spawn(function()
                for _ = 1, 20 do
                    if not Toggles.PlayerFly.Value then return end
                    if S.active then return end
                    startFly()
                    if S.active then return end
                    task.wait(0.5)
                end
            end)
        end
    end

    LP.CharacterAdded:Connect(function(char)
        -- 先彻底停飞（包括缓降阶段，否则 stopFly 会因 S.landing 直接 return）
        S.landing = false
        pcall(stopFly, true)
        if Toggles.PlayerFly and Toggles.PlayerFly.Value then
            task.spawn(function()
                -- 等「原地复活」把角色放回死亡点并真正站稳，再接管飞行
                local deadline = tick() + 12
                while tick() < deadline do
                    if not (Toggles.PlayerFly and Toggles.PlayerFly.Value) then return end
                    if not S.respawnBusy() and S.readyForFly(char) then break end
                    task.wait(0.15)
                end
                task.wait(0.1)
                if Toggles.PlayerFly and Toggles.PlayerFly.Value and not S.active then
                    startFly()
                end
            end)
        end
    end)

    -- 对外控制口：原地复活在「重生接管」阶段要先彻底停飞，避免两套逻辑抢 CFrame / 抢碰撞
    _G.WXFlyCtl = {
        isOn = function()
            return S.active == true or S.landing == true
        end,
        forceStop = function()
            S.landing = false
            pcall(function() stopFly(true) end)
            S.active = false
            S.landing = false
            pcall(restore, S.char, S.hum)
            S.char, S.hum, S.root = nil, nil, nil
        end,
    }

    _G.BoarsCleanupFly = function()
        pcall(function() stopFly(true) end)
        S.landing = false
        S.active = false
        restore(S.char, S.hum)
        pcall(function() flyConn:Disconnect() end)
    end
end
-- Infinite Stamina
Toggles.InfiniteStamina:OnChanged(function()
    if Toggles.InfiniteStamina.Value then
        local char = LP.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                for _, conn in getconnections(hum:GetPropertyChangedSignal("Jump")) do
                    conn:Disable()
                end
            end
        end
    end
end)

LP.CharacterAdded:Connect(function(char)
    task.wait(1)
    if Toggles.InfiniteStamina.Value then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            for _, conn in getconnections(hum:GetPropertyChangedSignal("Jump")) do
                conn:Disable()
            end
        end
    end
end)

-- Air Strafe
do
    local airStrafeConn
    Toggles.AirStrafe:OnChanged(function()
        if Toggles.AirStrafe.Value then
            if airStrafeConn then return end
            airStrafeConn = RunService.RenderStepped:Connect(function()
                local char = LP.Character
                if not char then return end
                local hum = char:FindFirstChildOfClass("Humanoid")
                local root = char:FindFirstChild("HumanoidRootPart")
                if not hum or not root or hum.Health <= 0 then return end

                local state = hum:GetState()
                if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping then
                    local moveDir = hum.MoveDirection
                    if moveDir.Magnitude > 0.001 then
                        local vel = root.AssemblyLinearVelocity
                        local speed = hum.WalkSpeed * 1.0
                        root.AssemblyLinearVelocity = Vector3.new(moveDir.X * speed, vel.Y, moveDir.Z * speed)
                    end
                end
            end)
        else
            if airStrafeConn then
                airStrafeConn:Disconnect()
                airStrafeConn = nil
            end
        end
    end)
end

-- Speed Zones
do
local subRegions = {
    {cx=752.77,  cz=2571.80, hx=109.93/2, hz=13.60/2},
    {cx=701.15,  cz=2313.70, hx=69.10/2,  hz=163.00/2},
    {cx=917.30,  cz=2392.60, hx=107.00/2, hz=28.00/2},
    {cx=830.30,  cz=2242.55, hx=58.00/2,  hz=34.10/2},
    {cx=748.90,  cz=2340.60, hx=59.40/2,  hz=109.20/2},
    {cx=799.10,  cz=2299.00, hx=14.00/2,  hz=33.99/2},
    {cx=826.69,  cz=2338.60, hx=51.19/2,  hz=12.00/2},
    {cx=799.65,  cz=2269.23, hx=12.90/2,  hz=21.50/2},
    {cx=765.36,  cz=2247.57, hx=59.32/2,  hz=64.82/2},
    {cx=850.20,  cz=2571.80, hx=23.20/2,  hz=13.60/2},
    {cx=779.80,  cz=2479.80, hx=164.00/2, hz=170.40/2},
    {cx=983.35,  cz=2315.15, hx=31.10/2,  hz=58.90/2},
    {cx=916.50,  cz=2225.40, hx=99.00/2,  hz=38.00/2},
    {cx=889.80,  cz=2361.60, hx=220.00/2, hz=34.00/2},
    {cx=915.80,  cz=2456.60, hx=64.00/2,  hz=100.00/2},
    {cx=820.80,  cz=2386.60, hx=82.00/2,  hz=16.00/2},
    {cx=916.90,  cz=2294.50, hx=98.20/2,  hz=100.20/2},
    {cx=836.95,  cz=2296.10, hx=61.70/2,  hz=73.00/2},
    {cx=872.30,  cz=2463.60, hx=19.00/2,  hz=62.00/2},
    {cx=959.30,  cz=2463.60, hx=19.00/2,  hz=62.00/2},
}
local prison = {cx=773.62, cz=2327.43, hx=563.37/2, hz=540.30/2}

local function inBox(x, z, r)
    return math.abs(x - r.cx) <= r.hx and math.abs(z - r.cz) <= r.hz
end

local function isInSubRegion(x, z)
    for _, r in ipairs(subRegions) do
        if inBox(x, z, r) then return true end
    end
    return false
end

local speedConn
Toggles.SpeedRegions:OnChanged(function()
    if Toggles.SpeedRegions.Value then
        if speedConn then return end
        speedConn = RunService.RenderStepped:Connect(function()
            local char = LP.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            if not hum or not root or hum.Health <= 0 then return end

            local x, z = root.Position.X, root.Position.Z
            -- 滑块数值：每帧读取，拖动即时生效
            local speed = tonumber(Options.SpeedValue and Options.SpeedValue.Value) or 100
            local jump = tonumber(Options.JumpValue and Options.JumpValue.Value) or 7.2
            speed = math.clamp(speed, 16, 300)
            jump = math.clamp(jump, 0, 120)

            if Toggles.SpeedZoneAuto and Toggles.SpeedZoneAuto.Value then
                -- 原版逻辑：按区域自动分档
                if isInSubRegion(x, z) then
                    hum.WalkSpeed = 80
                    hum.JumpHeight = 7.2
                elseif inBox(x, z, prison) then
                    hum.WalkSpeed = 70
                    hum.JumpHeight = 25
                else
                    hum.WalkSpeed = 100
                    hum.JumpHeight = 50
                end
            else
                -- 滑块模式：全图统一使用「人物移速 / 跳跃高度」
                hum.WalkSpeed = speed
                if hum.JumpHeight ~= jump then
                    hum.JumpHeight = jump
                end
            end
        end)
    else
        if speedConn then
            speedConn:Disconnect()
            speedConn = nil
        end
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = 16
            hum.JumpHeight = 7.2
        end
    end
end)
end

-- Weapon Chams
do
    local chamsConn
    Toggles.WeaponChams:OnChanged(function()
        if chamsConn then chamsConn:Disconnect(); chamsConn = nil end
        if not Toggles.WeaponChams.Value then return end
        chamsConn = RunService.RenderStepped:Connect(function()
            local tool = LP.Character and LP.Character:FindFirstChildOfClass('Tool')
            if not tool then return end
            local matName = Options.WeaponChamsMaterial.Value
            local mat = Enum.Material[matName]
            local col = Options.WeaponChamsColor and Options.WeaponChamsColor.Value or Color3.fromRGB(0, 170, 255)

            for _, part in tool:GetDescendants() do
                if not part:IsA('BasePart') then continue end
                pcall(function()
                    part.Color = col
                    part.MaterialVariant = ""
                    part.Material = mat
                    part.Transparency = 0
                    part.Reflectance = 0
                    part.CastShadow = true
                    if part:IsA('MeshPart') then
                        part.TextureID = ""
                        part.RenderFidelity = Enum.RenderFidelity.Performance
                    end
                    for _, child in part:GetChildren() do
                        if child:IsA('SurfaceAppearance') or child:IsA('Texture') or child:IsA('Decal') then
                            child:Destroy()
                        elseif child:IsA('DataModelMesh') then
                            child.TextureId = ""
                        end
                    end
                end)
            end
        end)
    end)
end

-- Arrest Aura
local ArrestPlayer = ReplicatedStorage:WaitForChild('Remotes'):WaitForChild('ArrestPlayer')
local ARREST_RANGE = 7.5

local function isArrestable(player)
    if player.Team == Teams.Criminals then return true end
    if player.Team == Teams.Inmates then
        local char = player.Character
        if not char then return false end
        local attrs = char:GetAttributes()
        if attrs.Hostile and attrs.Tased then return true end
        if attrs.Trespassing then return true end
    end
    return false
end

local lastArrestTime = 0
local arrestConn = nil

-- Arrest range visual (segmented circle like FOV)
local AR_SEG = 60
local arLines = {}
local arTris = {}

for i = 1, AR_SEG do
    local l = Drawing.new('Line')
    l.Visible = false
    l.Thickness = 1.5
    l.ZIndex = 10
    arLines[i] = l

    local t = Drawing.new('Triangle')
    t.Visible = false
    t.Filled = true
    t.ZIndex = 5
    arTris[i] = t
end

local function lerpColor3(a, b, t)
    return Color3.new(a.R + (b.R - a.R) * t, a.G + (b.G - a.G) * t, a.B + (b.B - a.B) * t)
end

local function smoothstep(t)
    t = math.clamp(t, 0, 1)
    return t * t * (3 - 2 * t)
end

local function getARSegColor(i, c1, c2, c3)
    local p = (i - 1) / AR_SEG
    local scaled = p * 3
    local idx = math.floor(scaled)
    local frac = smoothstep(scaled - idx)
    local colors = {c1, c2, c3}
    return lerpColor3(colors[(idx % 3) + 1], colors[((idx + 1) % 3) + 1], frac)
end

local function getARFillSegColor(i, c1, c2, c3)
    local p = (i - 0.5) / AR_SEG
    local scaled = p * 3
    local idx = math.floor(scaled)
    local frac = smoothstep(scaled - idx)
    local colors = {c1, c2, c3}
    return lerpColor3(colors[(idx % 3) + 1], colors[((idx + 1) % 3) + 1], frac)
end

local function updateArrestRange()
    local root = LP.Character and LP.Character:FindFirstChild('HumanoidRootPart')
    if not root then
        for i = 1, AR_SEG do arLines[i].Visible = false; arTris[i].Visible = false end
        return
    end

    local rootPos = root.Position - Vector3.new(0, root.Size.Y / 2 + 0.1, 0)
    local cam = Camera

    local showOutline = Toggles.ArrestAuraRange.Value and Toggles.ArrestAura.Value
    local showFill = Toggles.ArrestAuraFill.Value and showOutline
    local thick = Options.ArrestAuraThickness.Value
    local c1, c2, c3 = Options.ArrestAuraColor1.Value, Options.ArrestAuraColor2.Value, Options.ArrestAuraColor3.Value
    local fc1, fc2, fc3 = Options.ArrestAuraFillColor1.Value, Options.ArrestAuraFillColor2.Value, Options.ArrestAuraFillColor3.Value
    local fillAlpha = 1 - Options.ArrestAuraFillDensity.Value

    local projected = {}
    for i = 1, AR_SEG do
        local angle = (i - 1) / AR_SEG * math.pi * 2
        local worldPt = rootPos + Vector3.new(math.cos(angle) * ARREST_RANGE, 0, math.sin(angle) * ARREST_RANGE)
        local screenPt = cam:WorldToViewportPoint(worldPt)
        projected[i] = Vector2.new(screenPt.X, screenPt.Y)
    end

    local center2D, centerVis = cam:WorldToViewportPoint(rootPos)
    if not centerVis then
        for i = 1, AR_SEG do arLines[i].Visible = false; arTris[i].Visible = false end
        return
    end

    local center = Vector2.new(center2D.X, center2D.Y)

    for i = 1, AR_SEG do
        local j = (i % AR_SEG) + 1

        local line = arLines[i]
        line.From = projected[i]
        line.To = projected[j]
        line.Color = getARSegColor(i, c1, c2, c3)
        line.Thickness = thick
        line.Visible = showOutline

        local tri = arTris[i]
        tri.PointA = center
        tri.PointB = projected[i]
        tri.PointC = projected[j]
        tri.Color = getARFillSegColor(i, fc1, fc2, fc3)
        tri.Transparency = fillAlpha
        tri.Visible = showFill
    end
end

Toggles.ArrestAura:OnChanged(function()
    if Toggles.ArrestAura.Value then
        if arrestConn then return end
        arrestConn = RunService.RenderStepped:Connect(function()
            if tick() - lastArrestTime < 7 then return end
            local root = LP.Character and LP.Character:FindFirstChild('HumanoidRootPart')
            if not root then return end
    local rootPos = root.Position - Vector3.new(0, root.Size.Y / 2 + 0.05, 0)
            local bestTarget, bestDist = nil, ARREST_RANGE
            for _, player in Players:GetPlayers() do
                if player == LP then continue end
                if not isArrestable(player) then continue end
                local char = player.Character
                local hrp = char and char:FindFirstChild('HumanoidRootPart')
                if hrp then
                    local dist = (hrp.Position - rootPos).Magnitude
                    if dist <= bestDist then
                        bestDist = dist
                        bestTarget = player
                    end
                end
            end
            if bestTarget then
                local ok = pcall(function()
                    return ArrestPlayer:InvokeServer(bestTarget, 1)
                end)
                if ok then
                    lastArrestTime = tick()
                end
            end
        end)
    else
        if arrestConn then
            arrestConn:Disconnect()
            arrestConn = nil
        end
        for i = 1, AR_SEG do arLines[i].Visible = false; arTris[i].Visible = false end
    end
end)


-- Vehicle & Penetration System
local wallParams = RaycastParams.new()
wallParams.FilterType = Enum.RaycastFilterType.Exclude

local function isVehiclePart(part)
    if not part then return false end
    local carContainer = Workspace:FindFirstChild('CarContainer')
    if carContainer and part:IsDescendantOf(carContainer) then
        return true
    end
    if part.CollisionGroup == 'Vehicles' or part.CollisionGroup == 'Wheels' then
        return true
    end
    local model = part:FindFirstAncestorOfClass('Model')
    if model and (CollectionService:HasTag(model, 'Vehicle') or model.Name == 'Squad') then
        return true
    end
    return false
end

local function isPenetrableVehiclePart(part, mode)
    if not isVehiclePart(part) then return false end
    if mode == 'All Car Parts' then return true end

    -- Mode 'Windows & Non-Solid':
    -- 1. Non-collidable parts (seats, interior, open cabin, sirens, decorations)
    if not part.CanCollide then return true end

    -- 2. Transparent parts (windows, windshield, rear glass)
    if part.Transparency > 0.1 then return true end

    -- 3. Seats & VehicleSeats
    if part:IsA('Seat') or part:IsA('VehicleSeat') then return true end

    -- 4. Glass material
    if part.Material == Enum.Material.Glass then return true end

    -- 5. Window / glass / windshield naming
    local name = part.Name:lower()
    if name:find('window') or name:find('glass') or name:find('windshield') or name:find('screen') then
        return true
    end

    return false
end

local function getNetworkPingSeconds()
    local ping = 0.07
    pcall(function()
        if LP.GetNetworkPing then
            local p = LP:GetNetworkPing()
            if p and p > 0 then
                ping = p
                return
            end
        end
        local stats = game:GetService('Stats')
        local item = stats and stats.Network and stats.Network.ServerStatsItem and stats.Network.ServerStatsItem['Data Ping']
        if item then
            ping = item:GetValue() / 1000
        end
    end)
    return math.clamp(ping, 0.02, 0.35)
end

local function getLagCompensatedOrigin()
    local char = LP.Character
    if not char then return Vector3.zero end
    local head = char:FindFirstChild('Head')
    local root = char:FindFirstChild('HumanoidRootPart')
    if not head and not root then return Vector3.zero end

    local basePos = head and head.Position or (root.Position + Vector3.new(0, 1.5, 0))
    if not root then return basePos end

    local vel = root.AssemblyLinearVelocity
    if vel.Magnitude < 2 then
        return basePos
    end

    local ping = getNetworkPingSeconds()
    -- Physics replication delay: half round-trip time + Roblox replication interpolation buffer (~35ms)
    local delay = (ping * 0.5) + 0.035
    local predictedServerPos = basePos - (vel * delay)

    -- Ensure predicted origin doesn't clip behind a solid wall
    local displacement = predictedServerPos - basePos
    if displacement.Magnitude > 0.1 then
        local exclude = { char }
        local _, myVeh = isInVehicle(LP)
        if myVeh then table.insert(exclude, myVeh) end
        wallParams.FilterDescendantsInstances = exclude
        local rayCheck = Workspace:Raycast(basePos, displacement, wallParams)
        if rayCheck then
            predictedServerPos = rayCheck.Position - displacement.Unit * 0.2
        end
    end

    return predictedServerPos
end

local function hasLineOfSight(from, to, targetPlayer)
    local targetChar = targetPlayer and targetPlayer.Character
    local targetInVeh, targetVeh = targetPlayer and isInVehicle(targetPlayer)
    local myInVeh, myVeh = isInVehicle(LP)

    local shootThroughCars = (Toggles.RageBotShootThroughCars == nil) or Toggles.RageBotShootThroughCars.Value
    local penMode = (Options.RageBotCarPenetration and Options.RageBotCarPenetration.Value) or 'Windows & Non-Solid'

    local excludeList = { LP.Character }
    if myVeh then
        table.insert(excludeList, myVeh)
    end
    if shootThroughCars and targetInVeh and targetVeh then
        table.insert(excludeList, targetVeh)
    end
    if targetChar and Toggles.ShieldBypass and Toggles.ShieldBypass.Value and (Toggles.ShieldBypassRiot == nil or Toggles.ShieldBypassRiot.Value) then
        local rsp = targetChar:FindFirstChild('RiotShieldPart')
        if rsp then table.insert(excludeList, rsp) end
        for _, item in ipairs(targetChar:GetChildren()) do
            if item:IsA('Tool') and string.find(string.lower(item.Name), 'shield') then
                table.insert(excludeList, item)
            end
        end
    end

    local pierces = 0
    local maxPierces = 10

    while pierces < maxPierces do
        local dir = to - from
        local dist = dir.Magnitude
        if dist < 0.2 then
            return true
        end

        wallParams.FilterDescendantsInstances = excludeList
        local result = Workspace:Raycast(from, dir, wallParams)
        if not result then
            return true
        end

        local hitPart = result.Instance

        -- Hit target character directly
        if targetChar and hitPart:IsDescendantOf(targetChar) then
            return true
        end

        -- Check if hit close to target and hit a player character
        local hitDist = (result.Position - to).Magnitude
        if hitDist < 3.5 then
            for _, p in Players:GetPlayers() do
                if p.Character and hitPart:IsDescendantOf(p.Character) then
                    if not targetPlayer or p == targetPlayer then
                        return true
                    end
                end
            end
        end

        -- Check if hit vehicle part that can be penetrated
        if shootThroughCars and isPenetrableVehiclePart(hitPart, penMode) then
            table.insert(excludeList, hitPart)
            if penMode == 'All Car Parts' then
                local vehicleModel = hitPart:FindFirstAncestorOfClass('Model')
                if vehicleModel and (vehicleModel.Name == 'Squad' or vehicleModel:IsDescendantOf(Workspace:FindFirstChild('CarContainer') or Workspace)) then
                    table.insert(excludeList, vehicleModel)
                end
            end
            pierces = pierces + 1
        else
            -- Hit an impenetrable obstacle (wall, terrain, or solid car part in strict mode)
            return false
        end
    end

    return false
end

local detectedCheaters = setmetatable({}, { __mode = 'k' })

local function FindNearestTarget()
    if not Toggles.SilentAim.Value and not Toggles.RageBot.Value and not (Toggles.TargetESP and Toggles.TargetESP.Value) then return nil end
    local root = LP.Character and LP.Character:FindFirstChild('HumanoidRootPart')
    if not root then return nil end

    local bestFOV = Options.FOVRadius.Value
local bestPart = nil
local aimPartName = Options.AimPart.Value
local mousePos = getAimCenter() -- 移动端用屏幕中心
local rootPos = root.Position

    local tool = LP.Character and LP.Character:FindFirstChildOfClass('Tool')
    local maxDist = (Toggles.RageBot.Value and tool and tool:GetAttribute('Range')) or Options.MaxDistance.Value

    local prioritizeCheaters = Toggles.RageBotPrioritizeCheaters and Toggles.RageBotPrioritizeCheaters.Value
    local bestCheaterPart, bestCheaterMetric = nil, math.huge

    for _, player in Players:GetPlayers() do
        if IsValidTarget(player) then
            local char = player.Character
            local inVeh = isInVehicle(player)
            local part = (inVeh and (char:FindFirstChild('Head') or char:FindFirstChild('HumanoidRootPart')))
                or char:FindFirstChild(aimPartName)
                or char:FindFirstChild('HumanoidRootPart')
            if part then
                local dist = (part.Position - rootPos).Magnitude
                if dist > maxDist then continue end
                if Toggles.SilentAimVisibleCheck.Value then
                    if not hasLineOfSight(Camera.CFrame.Position, part.Position, player) then
                        continue
                    end
                end
                local isCheater = prioritizeCheaters and (detectedCheaters[player] ~= nil)
                if Toggles.SilentAim360.Value or Toggles.RageBot.Value then
                    if isCheater and dist < bestCheaterMetric then
                        bestCheaterMetric = dist
                        bestCheaterPart = part
                    end
                    if dist < bestFOV then
                        bestFOV = dist
                        bestPart = part
                    end
                else
                    local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local fov = (Vector2.new(sp.X, sp.Y) - mousePos).Magnitude
                        if isCheater and fov < bestCheaterMetric then
                            bestCheaterMetric = fov
                            bestCheaterPart = part
                        end
                        if fov < bestFOV then
                            bestFOV = fov
                            bestPart = part
                        end
                    end
                end
            end
        end
    end
    if bestCheaterPart then
        return bestCheaterPart
    end
    return bestPart
end

-- ====================== HVH RESOLVER ENGINE ======================
local resolveTarget = nil

do
    local resolverData = setmetatable({}, { __mode = 'k' })

    -- Background tracker for players (velocity derivation & spin/jitter detection)
    RunService.Heartbeat:Connect(function()
        if not (Toggles.Resolver and Toggles.Resolver.Value) then return end
        local now = tick()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Parent == Players then
                local char = p.Character
                local hrp = char and char:FindFirstChild('HumanoidRootPart')
                local head = char and char:FindFirstChild('Head')

                if hrp and head and isAlive(p) then
                    local hrpPos = hrp.Position
                    local headPos = head.Position

                    local data = resolverData[p]
                    if not data or data.char ~= char then
                        data = {
                            char = char,
                            lastPos = hrpPos,
                            lastTick = now,
                            derivedVel = Vector3.zero,
                            lastHeadRel = Vector2.new(headPos.X - hrpPos.X, headPos.Z - hrpPos.Z),
                            lastAngle = math.atan2(headPos.Z - hrpPos.Z, headPos.X - hrpPos.X),
                            angularVelocity = 0,
                            isSpinbot = false,
                            isDesync = false,
                            missCount = 0,
                            hitCount = 0,
                            stage = 1,
                            lastShotTick = 0,
                            pendingHit = false,
                            statusText = 'Tracking',
                        }
                        resolverData[p] = data
                    else
                        local dt = now - data.lastTick
                        if dt >= 0.015 and dt <= 0.25 then
                            -- 1. True velocity derivation
                            local delta = hrpPos - data.lastPos
                            local instVel = delta / dt
                            data.derivedVel = data.derivedVel:Lerp(instVel, 0.4)

                            -- 2. Spinbot & Jitter Anti-Aim Detection
                            local headRel = Vector2.new(headPos.X - hrpPos.X, headPos.Z - hrpPos.Z)
                            local curAngle = math.atan2(headRel.Y, headRel.X)
                            local deltaAngle = curAngle - data.lastAngle
                            while deltaAngle > math.pi do deltaAngle = deltaAngle - (math.pi * 2) end
                            while deltaAngle < -math.pi do deltaAngle = deltaAngle + (math.pi * 2) end

                            local angSpeed = math.abs(deltaAngle) / dt
                            data.angularVelocity = (data.angularVelocity * 0.7) + (angSpeed * 0.3)

                            -- Over 3.5 rad/s indicates artificial spinbot/anti-aim
                            if data.angularVelocity > 3.5 then
                                data.isSpinbot = true
                            elseif data.angularVelocity < 1.0 then
                                data.isSpinbot = false
                            end

                            -- 3. CFrame / Void Desync check
                            local isUnderground = hrpPos.Y < -40
                            local isCheater = detectedCheaters and (detectedCheaters[p] ~= nil)
                            data.isDesync = isUnderground or isCheater

                            data.lastAngle = curAngle
                            data.lastHeadRel = headRel
                            data.lastPos = hrpPos
                            data.lastTick = now

                            -- 4. Check pending miss timeout (no hit registered after 0.35s)
                            if data.pendingHit and (now - data.lastShotTick) > 0.35 then
                                data.pendingHit = false
                                data.missCount = data.missCount + 1
                                data.stage = (data.stage % 4) + 1
                                data.statusText = string.format('暴力破解 [阶段 %d]', data.stage)
                            end
                        end
                    end
                end
            end
        end
    end)

    Players.PlayerRemoving:Connect(function(p)
        resolverData[p] = nil
    end)

    -- Hook confirmed hits from damage/hitmarkers to reward successful stage
    _G.BoarsResolverConfirmHit = function(targetPlayer)
        if targetPlayer and resolverData[targetPlayer] then
            local data = resolverData[targetPlayer]
            data.pendingHit = false
            data.hitCount = data.hitCount + 1
            data.missCount = 0
            data.statusText = '已解析 [确认命中]'
        end
    end

    resolveTarget = function(targetPlayer, targetPart, origin)
        if not (Toggles.Resolver and Toggles.Resolver.Value) then
            return targetPart.Position, targetPart
        end
        if not targetPlayer or not targetPlayer.Character or not targetPart then
            return targetPart and targetPart.Position or Vector3.zero, targetPart
        end

        local char = targetPlayer.Character
        local hrp = char:FindFirstChild('HumanoidRootPart')
        local head = char:FindFirstChild('Head')
        if not hrp then
            return targetPart.Position, targetPart
        end

        local data = resolverData[targetPlayer]
        if data then
            data.pendingHit = true
            data.lastShotTick = tick()
        end

        local mode = Options.ResolverMode and Options.ResolverMode.Value or 'Adaptive Auto'
        local ping = 0.05
        pcall(function()
            local pingVal = game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue()
            if pingVal and pingVal > 0 then
                ping = math.clamp(pingVal / 1000, 0.02, 0.3)
            end
        end)

        local resolvedPos = targetPart.Position
        local resolvedPart = targetPart

        local isSpin = data and (data.isSpinbot or data.angularVelocity > 3.0)

        -- 1. Axis Pivot Resolution (Anti-Spinbot)
        if mode == 'Axis Pivot (Anti-Spin)' or (mode == 'Adaptive Auto' and isSpin and (data and data.missCount or 0) == 0) then
            if targetPart.Name == 'Head' and hrp then
                resolvedPos = Vector3.new(hrp.Position.X, head and head.Position.Y or (hrp.Position.Y + 1.5), hrp.Position.Z)
                resolvedPart = targetPart
                if data then data.statusText = '已解析 [轴心旋转]' end
            else
                resolvedPos = hrp.Position
                resolvedPart = hrp
                if data then data.statusText = '已解析 [躯干中心]' end
            end

        -- 2. Velocity Prediction Resolution
        elseif mode == 'Velocity Prediction' then
            local vel = (data and data.derivedVel) or (hrp.AssemblyLinearVelocity or hrp.Velocity)
            if vel.Magnitude < 200 then
                resolvedPos = targetPart.Position + (vel * (ping + 0.03))
                resolvedPart = targetPart
                if data then data.statusText = '已解析 [速度外推]' end
            end

        -- 3. Bruteforce / Adaptive Cycle Resolution
        else
            local stage = (data and data.stage) or 1
            local missCount = (data and data.missCount) or 0

            if missCount > 0 or mode == 'Bruteforce' then
                if stage == 1 then
                    -- Stage 1: Absolute Center Mass (HRP)
                    resolvedPos = hrp.Position
                    resolvedPart = hrp
                    if data then data.statusText = '已解析 [暴力·躯干]' end
                elseif stage == 2 then
                    -- Stage 2: Head Axis Alignment
                    resolvedPos = Vector3.new(hrp.Position.X, head and head.Position.Y or (hrp.Position.Y + 1.5), hrp.Position.Z)
                    resolvedPart = head or hrp
                    if data then data.statusText = '已解析 [暴力·轴]' end
                elseif stage == 3 then
                    -- Stage 3: Inverted Yaw Projection (Anti-Backward / Anti-Fake)
                    if head then
                        local offset = head.Position - hrp.Position
                        resolvedPos = hrp.Position - Vector3.new(offset.X, -offset.Y, offset.Z)
                        resolvedPart = head
                    else
                        resolvedPos = hrp.Position
                        resolvedPart = hrp
                    end
                    if data then data.statusText = '已解析 [反向偏航]' end
                elseif stage == 4 then
                    -- Stage 4: Velocity Lead Clamped
                    local vel = (data and data.derivedVel) or Vector3.zero
                    resolvedPos = targetPart.Position + (vel * ping)
                    resolvedPart = targetPart
                    if data then data.statusText = '已解析 [提前量外推]' end
                end
            else
                -- Zero misses: smart default
                if isSpin then
                    resolvedPos = Vector3.new(hrp.Position.X, head and head.Position.Y or (hrp.Position.Y + 1.5), hrp.Position.Z)
                    resolvedPart = head or targetPart
                    if data then data.statusText = '已解析 [反自旋]' end
                elseif data and data.derivedVel.Magnitude > 12 then
                    resolvedPos = targetPart.Position + (data.derivedVel * (ping + 0.02))
                    resolvedPart = targetPart
                    if data then data.statusText = '已解析 [追踪中]' end
                else
                    resolvedPos = targetPart.Position
                    resolvedPart = targetPart
                end
            end
        end

        -- Line-of-sight safety check on resolved position
        if not hasLineOfSight(origin, resolvedPos, targetPlayer) then
            resolvedPos = targetPart.Position
            resolvedPart = targetPart
        end

        if data and Toggles.ResolverLog and Toggles.ResolverLog.Value then
            if (data.isSpinbot or (data.missCount or 0) > 0) and (tick() - (data.lastNotify or 0)) > 6 then
                data.lastNotify = tick()
                pcall(function()
                    Library:Notify(string.format('[解析] %s → %s', targetPlayer.DisplayName or targetPlayer.Name, data.statusText), 3)
                end)
            end
        end

        return resolvedPos, resolvedPart
    end
end

-- Custom Crosshair
local crosshairLines = {}
local crosshairAngles = { -90, 0, 90, 180 }
local CrosshairGui = LP.PlayerGui:WaitForChild("CrosshairGui")
local ScopeFrame = CrosshairGui.ScopeFrame
local DefaultCursor = ScopeFrame.Cursor
local hasGun = false

for i = 1, 4 do
    local l = Drawing.new('Line')
    l.Visible = false
    l.Thickness = 2
    l.ZIndex = 20
    crosshairLines[i] = l
end

local crosshairDot = Drawing.new('Circle')
crosshairDot.Filled = true
crosshairDot.Visible = false
crosshairDot.Radius = 2
crosshairDot.NumSides = 16
crosshairDot.ZIndex = 21

local crosshairRing = Drawing.new('Circle')
crosshairRing.Filled = false
crosshairRing.Visible = false
crosshairRing.Radius = 20
crosshairRing.Thickness = 1
crosshairRing.NumSides = 48
crosshairRing.Transparency = 0.4
crosshairRing.ZIndex = 19

local function updateCrosshair()
    local center = UserInputService:GetMouseLocation()
    local rot = math.rad(Options.CrosshairRotation.Value)
    local gap = Options.CrosshairGap.Value
    local len = Options.CrosshairLength.Value
    local thick = Options.CrosshairThickness.Value
    local vis = Toggles.CustomCrosshair.Value

    for i = 1, 4 do
        local angle = math.rad(crosshairAngles[i]) + rot
        local dx, dy = math.cos(angle), math.sin(angle)
        local line = crosshairLines[i]
        line.From = center + Vector2.new(dx, dy) * gap
        line.To = center + Vector2.new(dx, dy) * (gap + len)
        line.Color = Options['CH' .. i .. 'Color'].Value
        line.Thickness = thick
        line.Visible = vis
    end

    crosshairDot.Position = center
    crosshairDot.Color = Options.CH1Color.Value
    crosshairDot.Radius = math.clamp(thick * 0.7, 1, 4)
    crosshairDot.Visible = vis

    crosshairRing.Position = center
    crosshairRing.Radius = gap + len * 0.5
    crosshairRing.Color = Options.CH1Color.Value
    crosshairRing.Visible = vis
end

local function hideCrosshair()
    for i = 1, 4 do
        crosshairLines[i].Visible = false
    end
    crosshairDot.Visible = false
    crosshairRing.Visible = false
end

local function killDefaultCrosshair()
    pcall(function()
        ScopeFrame.Visible = false
        ScopeFrame.Size = UDim2.new(0, 0, 0, 0)
        DefaultCursor.Visible = false
        DefaultCursor.Size = UDim2.new(0, 0, 0, 0)
        for _, v in ScopeFrame:GetDescendants() do
            if v:IsA("GuiObject") then
                v.Visible = false
                v.Size = UDim2.new(0, 0, 0, 0)
            elseif v:IsA("ImageLabel") or v:IsA("Image") then
                v.Visible = false
            end
        end
    end)
end

local function onGunEquipped(tool)
    if not tool or not tool:IsA("Tool") then return end
    if tool:GetAttribute("ToolType") ~= "Gun" then
        hasGun = false
        if Toggles.CustomCrosshair.Value then hideCrosshair() end
        return
    end
    hasGun = true
end

local function onGunRemoved()
    hasGun = false
    if Toggles.CustomCrosshair.Value then hideCrosshair() end
end

local function hookCharacter(char)
    if not char then return end
    char.ChildAdded:Connect(function(child)
        if Toggles.CustomCrosshair.Value then onGunEquipped(child) end
    end)
    char.ChildRemoved:Connect(function(child)
        if Toggles.CustomCrosshair.Value then onGunRemoved() end
    end)
    local tool = char:FindFirstChildOfClass("Tool")
    if tool and Toggles.CustomCrosshair.Value then onGunEquipped(tool) end
end

if LP.Character then hookCharacter(LP.Character) end
LP.CharacterAdded:Connect(hookCharacter)

ScopeFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if Toggles.CustomCrosshair.Value then killDefaultCrosshair() end
end)
DefaultCursor:GetPropertyChangedSignal("Visible"):Connect(function()
    if Toggles.CustomCrosshair.Value then killDefaultCrosshair() end
end)
ScopeFrame.DescendantAdded:Connect(function()
    if Toggles.CustomCrosshair.Value then killDefaultCrosshair() end
end)

Toggles.CustomCrosshair:OnChanged(function()
    if Toggles.CustomCrosshair.Value then
        UserInputService.MouseIconEnabled = false
        killDefaultCrosshair()
    else
        hideCrosshair()
        if _G.BoarsCleanupInvisibleAndSit then pcall(_G.BoarsCleanupInvisibleAndSit) end
    UserInputService.MouseIconEnabled = true
    end
end)

-- FOV Circle (3-color segmented outline + fill)
local FOV_SEG = 72
local fovLines = {}
local fovTris = {}
local fovRotOffset = 0

for i = 1, FOV_SEG do
    local l = Drawing.new('Line')
    l.Visible = false
    l.Thickness = Options.FOVThickness.Value
    l.ZIndex = 10
    fovLines[i] = l

    local t = Drawing.new('Triangle')
    t.Visible = false
    t.Filled = true
    t.ZIndex = 5
    fovTris[i] = t
end

local function lerpColor3(a, b, t)
    return Color3.new(
        a.R + (b.R - a.R) * t,
        a.G + (b.G - a.G) * t,
        a.B + (b.B - a.B) * t
    )
end

local function smoothstep(t)
    t = math.clamp(t, 0, 1)
    return t * t * (3 - 2 * t)
end

local function getSegmentColor(i, c1, c2, c3)
    local p = (i - 1) / FOV_SEG
    local scaled = p * 3
    local idx = math.floor(scaled)
    local frac = smoothstep(scaled - idx)
    local colors = {c1, c2, c3}
    return lerpColor3(colors[(idx % 3) + 1], colors[((idx + 1) % 3) + 1], frac)
end

local function getFillSegmentColor(i, c1, c2, c3)
    local p = (i - 0.5) / FOV_SEG
    local scaled = p * 3
    local idx = math.floor(scaled)
    local frac = smoothstep(scaled - idx)
    local colors = {c1, c2, c3}
    return lerpColor3(colors[(idx % 3) + 1], colors[((idx + 1) % 3) + 1], frac)
end

local function updateFOVCircle()
    local mousePos = getAimCenter() -- 移动端用屏幕中心，避免跟随手指乱飘
    local radius = Options.FOVRadius.Value
    local thick = Options.FOVThickness.Value
    local c1, c2, c3 = Options.FOVColor1.Value, Options.FOVColor2.Value, Options.FOVColor3.Value
    local fc1, fc2, fc3 = Options.FOVFillColor1.Value, Options.FOVFillColor2.Value, Options.FOVFillColor3.Value
    local fillAlpha = 1 - Options.FOVFillDensity.Value
    local showOutline = Toggles.FOVCircle.Value
    local showFill = Toggles.FOVFill.Value and showOutline

    for i = 1, FOV_SEG do
        local a1 = (i - 1) / FOV_SEG * math.pi * 2 + fovRotOffset
        local a2 = i / FOV_SEG * math.pi * 2 + fovRotOffset
        local p1 = mousePos + Vector2.new(math.cos(a1), math.sin(a1)) * radius
        local p2 = mousePos + Vector2.new(math.cos(a2), math.sin(a2)) * radius

        local line = fovLines[i]
        line.From = p1
        line.To = p2
        line.Color = getSegmentColor(i, c1, c2, c3)
        line.Thickness = thick
        line.Visible = showOutline

        local tri = fovTris[i]
        tri.PointA = mousePos
        tri.PointB = p1
        tri.PointC = p2
        tri.Color = getFillSegmentColor(i, fc1, fc2, fc3)
        tri.Transparency = fillAlpha
        tri.Visible = showFill
    end
end

local function hideFOVCircle()
    for i = 1, FOV_SEG do
        fovLines[i].Visible = false
        fovTris[i].Visible = false
    end
end

Toggles.FOVCircle:OnChanged(function()
    if not Toggles.FOVCircle.Value then hideFOVCircle() end
end)
Toggles.FOVFill:OnChanged(function()
    if not Toggles.FOVFill.Value then
        for i = 1, FOV_SEG do fovTris[i].Visible = false end
    end
end)

local targetPartCache = nil
local rageTargetPart = nil

-- ====================== TARGET ESP SYSTEM (MINECRAFT STYLE) ======================
local function getCustomOrLocal(name, absPath, fallback)
    local result = nil
    if getcustomasset then
        pcall(function()
            if isfile and isfile(name) then
                result = getcustomasset(name)
            elseif absPath and isfile and isfile(absPath) then
                result = getcustomasset(absPath)
            end
        end)
    elseif getsynasset then
        pcall(function()
            if isfile and isfile(name) then
                result = getsynasset(name)
            end
        end)
    end
    return result or fallback
end

pcall(function()
    if isfile and not isfile('skull.png') and isfile('C:\\Users\\kapca\\Downloads\\skull.png') then
        writefile('skull.png', readfile('C:\\Users\\kapca\\Downloads\\skull.png'))
    end
    if isfile and not isfile('target.png') and isfile('C:\\Users\\kapca\\Downloads\\target.png') then
        writefile('target.png', readfile('C:\\Users\\kapca\\Downloads\\target.png'))
    end
end)

local skullAsset = getCustomOrLocal('skull.png', 'C:\\Users\\kapca\\Downloads\\skull.png', 'rbxasset://textures/ui/ErrorIcon.png')
local targetAsset = getCustomOrLocal('target.png', 'C:\\Users\\kapca\\Downloads\\target.png', 'rbxasset://textures/ui/VR/circleWhite.png')
local glowAsset = 'rbxasset://textures/glow.png'

local targetEspGui = Instance.new('ScreenGui')
targetEspGui.Name = 'BoarsTargetESP'
targetEspGui.ResetOnSpawn = false
targetEspGui.IgnoreGuiInset = true
targetEspGui.DisplayOrder = 9999

if gethui then
    targetEspGui.Parent = gethui()
elseif game:GetService('CoreGui'):FindFirstChild('RobloxGui') then
    targetEspGui.Parent = game:GetService('CoreGui')
else
    targetEspGui.Parent = LP:WaitForChild('PlayerGui')
end

-- Client mode image (target.png)
local targetClientImg = Instance.new('ImageLabel')
targetClientImg.Name = 'TargetClient'
targetClientImg.BackgroundTransparency = 1
targetClientImg.BorderSizePixel = 0
targetClientImg.AnchorPoint = Vector2.new(0.5, 0.5)
targetClientImg.Image = targetAsset
targetClientImg.Visible = false
targetClientImg.ZIndex = 50
targetClientImg.Parent = targetEspGui

-- Wexside mode image (skull.png)
local targetSkullImg = Instance.new('ImageLabel')
targetSkullImg.Name = 'TargetSkull'
targetSkullImg.BackgroundTransparency = 1
targetSkullImg.BorderSizePixel = 0
targetSkullImg.AnchorPoint = Vector2.new(0.5, 0.5)
targetSkullImg.Image = skullAsset
targetSkullImg.Visible = false
targetSkullImg.ZIndex = 50
targetSkullImg.Parent = targetEspGui

-- Ghosts mode labels pool (40 upper, 40 lower)
local GHOST_COUNT = 40
local ghostsUpper = {}
local ghostsLower = {}

for j = 1, GHOST_COUNT do
    local imgU = Instance.new('ImageLabel')
    imgU.Name = 'GhostUpper_' .. j
    imgU.BackgroundTransparency = 1
    imgU.BorderSizePixel = 0
    imgU.AnchorPoint = Vector2.new(0.5, 0.5)
    imgU.Image = glowAsset
    imgU.Visible = false
    imgU.ZIndex = 48
    imgU.Parent = targetEspGui
    table.insert(ghostsUpper, imgU)

    local imgL = Instance.new('ImageLabel')
    imgL.Name = 'GhostLower_' .. j
    imgL.BackgroundTransparency = 1
    imgL.BorderSizePixel = 0
    imgL.AnchorPoint = Vector2.new(0.5, 0.5)
    imgL.Image = glowAsset
    imgL.Visible = false
    imgL.ZIndex = 48
    imgL.Parent = targetEspGui
    table.insert(ghostsLower, imgL)
end

local function hideAllTargetESP()
    targetClientImg.Visible = false
    targetSkullImg.Visible = false
    for j = 1, GHOST_COUNT do
        ghostsUpper[j].Visible = false
        ghostsLower[j].Visible = false
    end
end

local function updateTargetESP(dt)
    if not Toggles.TargetESP or not Toggles.TargetESP.Value then
        hideAllTargetESP()
        return
    end

    local targetPart = (Toggles.RageBot and Toggles.RageBot.Value and rageTargetPart and rageTargetPart.Parent and rageTargetPart)
        or (targetPartCache and targetPartCache.Parent and targetPartCache)

    if not targetPart then
        hideAllTargetESP()
        return
    end

    local targetChar = targetPart.Parent
    if not targetChar then
        hideAllTargetESP()
        return
    end
    local targetHum = targetChar:FindFirstChildOfClass('Humanoid')
    if targetHum and targetHum.Health <= 0 then
        hideAllTargetESP()
        return
    end

    local rootPart = targetChar:FindFirstChild('HumanoidRootPart') or targetPart
    local targetCenterPos = rootPart.Position

    if Toggles.TargetESPVisibleCheck and Toggles.TargetESPVisibleCheck.Value then
        local tPlayer = Players:GetPlayerFromCharacter(targetChar)
        if not hasLineOfSight(Camera.CFrame.Position, targetCenterPos, tPlayer) then
            hideAllTargetESP()
            return
        end
    end

    local mode = Options.TargetESPMode and Options.TargetESPMode.Value or 'Client'
    local speed = Options.TargetESPSpeed and Options.TargetESPSpeed.Value or 3.0
    local baseSize = Options.TargetESPSize and Options.TargetESPSize.Value or 70
    local brightness = Options.TargetESPBrightness and Options.TargetESPBrightness.Value or 255
    local isRainbow = Toggles.TargetESPRainbow and Toggles.TargetESPRainbow.Value
    local baseCol = isRainbow and Color3.fromHSV((tick() * 0.5) % 1, 0.8, 1)
        or (Options.TargetESPColor and Options.TargetESPColor.Value or Color3.fromRGB(255, 255, 255))

    if mode == 'Client' then
        targetSkullImg.Visible = false
        for j = 1, GHOST_COUNT do
            ghostsUpper[j].Visible = false
            ghostsLower[j].Visible = false
        end

        local screenPos, onScreen = Camera:WorldToViewportPoint(targetCenterPos)
        if onScreen then
            local rotAngle = (math.sin(tick() * speed) * 360) % 360
            targetClientImg.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y)
            targetClientImg.Size = UDim2.new(0, baseSize, 0, baseSize)
            targetClientImg.Rotation = rotAngle
            targetClientImg.ImageColor3 = baseCol
            targetClientImg.ImageTransparency = 1 - (brightness / 255)
            targetClientImg.Visible = true
        else
            targetClientImg.Visible = false
        end

    elseif mode == 'Wexside' then
        targetClientImg.Visible = false
        for j = 1, GHOST_COUNT do
            ghostsUpper[j].Visible = false
            ghostsLower[j].Visible = false
        end

        local screenPos, onScreen = Camera:WorldToViewportPoint(targetCenterPos)
        if onScreen then
            targetSkullImg.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y)
            targetSkullImg.Size = UDim2.new(0, baseSize, 0, baseSize)
            targetSkullImg.Rotation = 0
            targetSkullImg.ImageColor3 = baseCol
            local alpha = (brightness / 255) * (150 / 255)
            targetSkullImg.ImageTransparency = 1 - alpha
            targetSkullImg.Visible = true
        else
            targetSkullImg.Visible = false
        end

    elseif mode == 'Призраки' then
        targetClientImg.Visible = false
        targetSkullImg.Visible = false

        local bodyPos = rootPart.Position + Vector3.new(0, 0.8, 0)
        local legPos = rootPart.Position - Vector3.new(0, 1.2, 0)
        local time = tick() * (speed * 2.5)
        local orbitRadius = 1.8

        for j = 0, GHOST_COUNT - 1 do
            local idx = j + 1
            local alpha = math.clamp((brightness - j * 5) / 255, 0, 1)
            if alpha <= 0.01 then
                ghostsUpper[idx].Visible = false
                ghostsLower[idx].Visible = false
            else
                local trailSize = math.max(4, baseSize * (1.0 - j * 0.02))
                local trailTime = time - j * 0.09
                local trailSin = math.sin(trailTime)
                local trailCos = math.cos(trailTime)
                local angleOffset = j * 7.2

                local col = isRainbow and Color3.fromHSV((tick() * 0.5 + j * 0.02) % 1, 0.85, 1) or baseCol

                -- Upper ghost
                local posUpper = bodyPos + Vector3.new(trailCos * orbitRadius, trailSin * 0.35, trailSin * orbitRadius)
                local spU, onScreenU = Camera:WorldToViewportPoint(posUpper)
                if onScreenU then
                    local gu = ghostsUpper[idx]
                    gu.Position = UDim2.new(0, spU.X, 0, spU.Y)
                    gu.Size = UDim2.new(0, trailSize, 0, trailSize)
                    gu.Rotation = (trailSin * 360 + angleOffset) % 360
                    gu.ImageColor3 = col
                    gu.ImageTransparency = 1 - alpha
                    gu.Visible = true
                else
                    ghostsUpper[idx].Visible = false
                end

                -- Lower ghost
                local posLower = legPos + Vector3.new(-trailCos * orbitRadius, trailSin * 0.35, -trailSin * orbitRadius)
                local spL, onScreenL = Camera:WorldToViewportPoint(posLower)
                if onScreenL then
                    local gl = ghostsLower[idx]
                    gl.Position = UDim2.new(0, spL.X, 0, spL.Y)
                    gl.Size = UDim2.new(0, trailSize, 0, trailSize)
                    gl.Rotation = (-trailSin * 360 + angleOffset) % 360
                    gl.ImageColor3 = col
                    gl.ImageTransparency = 1 - alpha
                    gl.Visible = true
                else
                    ghostsLower[idx].Visible = false
                end
            end
        end
    end
end

local rageIndicatorText = Drawing.new('Text')
rageIndicatorText.Size = 16
rageIndicatorText.Color = Color3.new(1, 1, 1)
rageIndicatorText.Center = true
rageIndicatorText.Outline = true
rageIndicatorText.OutlineColor = Color3.new(0, 0, 0)
rageIndicatorText.Font = 2
rageIndicatorText.Position = Vector2.new(0, 0)
rageIndicatorText.Visible = false
rageIndicatorText.ZIndex = 31

RunService.RenderStepped:Connect(function(dt)
    fovRotOffset = fovRotOffset + Options.FOVRotSpeed.Value * dt
    if Toggles.FOVCircle.Value then
        updateFOVCircle()
    end
    if Toggles.CustomCrosshair.Value then
        killDefaultCrosshair()
        if hasGun then
            updateCrosshair()
        end
    end
    if Toggles.ArrestAura.Value then
        updateArrestRange()
    end
    targetPartCache = (Toggles.SilentAim.Value or Toggles.RageBot.Value or (Toggles.TargetESP and Toggles.TargetESP.Value) or (Toggles.TargetHUD and Toggles.TargetHUD.Value)) and FindNearestTarget() or nil
    updateTargetESP(dt)

    if Toggles.RageBot.Value and rageIndicatorText then
        local mousePos = UserInputService:GetMouseLocation()
        rageIndicatorText.Position = Vector2.new(mousePos.X, mousePos.Y + 25)

        local tool = LP.Character and LP.Character:FindFirstChildOfClass('Tool')
        local isGun = tool and (
            tool:GetAttribute('ToolType') == 'Gun'
            or (gunConfigs and gunConfigs[tool.Name])
            or tool:FindFirstChild('Muzzle')
        )
        if tool and isGun then
            local ammo = tool:GetAttribute('Local_CurrentAmmo') or tool:GetAttribute('CurrentAmmo') or 0
            local isReloading = ((tool:GetAttribute('Local_ReloadSession') or 0) > 0) and (ammo <= 0)
            if isReloading then
                rageIndicatorText.Text = tool.Name .. "  换弹中…"
                rageIndicatorText.Color = Color3.fromRGB(255, 200, 50)
            else
                local cfg = gunConfigs and gunConfigs[tool.Name]
                local maxAmmo = tool:GetAttribute('MaxAmmo') or (cfg and cfg.maxAmmo) or 0
                local stored = tool:GetAttribute('StoredAmmo')
                if cfg and cfg.behavior == 'Sniper' and stored then
                    rageIndicatorText.Text = tool.Name .. "  " .. ammo .. " | " .. stored
                else
                    rageIndicatorText.Text = tool.Name .. "  " .. ammo .. " / " .. maxAmmo
                end
                if ammo <= 0 then
                    rageIndicatorText.Color = Color3.fromRGB(255, 70, 70)
                elseif ammo <= maxAmmo * 0.25 then
                    rageIndicatorText.Color = Color3.fromRGB(255, 200, 50)
                else
                    rageIndicatorText.Color = Color3.fromRGB(100, 255, 130)
                end
            end
        elseif tool then
            rageIndicatorText.Text = tool.Name
            rageIndicatorText.Color = Color3.fromRGB(180, 180, 180)
        else
            rageIndicatorText.Text = "无武器"
            rageIndicatorText.Color = Color3.fromRGB(120, 120, 120)
        end
    end
end)

-- ====================== PARTICLES SYSTEM (MINECRAFT STYLE) ======================
local spawnAttackParticles
local spawnTotemParticles
local spawnThrowParticles
local cleanupParticles

do
local particleTextures = {
    ['Bloom']   = 'rbxasset://textures/glow.png',
    ['Star']    = 'rbxasset://textures/sparkle.png',
    ['Heart']   = 'rbxasset://textures/ui/Moments/Reactions/heart-large.png',
    ['Dollar']  = 'rbxasset://textures/ui/RobuxIcon.png',
    ['Snow']    = 'rbxasset://textures/ui/VR/circleWhite.png',
    ['Star 2']  = 'rbxasset://textures/ui/PlayerList/StarIcon.png',
    ['Kronex']  = 'rbxasset://textures/ui/icon_placeowner.png',
}
local particleNamesList = { 'Bloom', 'Star', 'Heart', 'Dollar', 'Snow', 'Star 2', 'Kronex' }

local TOTEM_COLOR_GREEN = Color3.fromRGB(127, 221, 144)
local TOTEM_COLOR_YELLOW = Color3.fromRGB(221, 218, 127)

local particlesFolder = Workspace:FindFirstChild('KronexParticles')
if not particlesFolder then
    particlesFolder = Instance.new('Folder')
    particlesFolder.Name = 'KronexParticles'
    particlesFolder.Parent = Workspace
end

local activeParticles = {}
local particlePool = {}
local MAX_PARTICLES = 180

local function isParticleEventEnabled(eventName)
    if not Toggles.Particles or not Toggles.Particles.Value then return false end
    if not Options.ParticleSpawnEvents then return true end
    local val = Options.ParticleSpawnEvents.Value
    if type(val) == 'table' then
        if val[eventName] == true then return true end
        for k, v in pairs(val) do
            if v == eventName or k == eventName then return true end
        end
        local count = 0
        for _ in pairs(val) do count = count + 1 end
        if count == 0 then
            return eventName == 'Attack' or eventName == 'Totem' or eventName == 'Move' or eventName == 'Throw'
        end
        return false
    elseif type(val) == 'string' then
        return val == eventName or val == 'All'
    end
    return true
end

local function getParticleInstance()
    local p = table.remove(particlePool)
    if p and p.Part and p.Part.Parent then
        p.Part.Parent = particlesFolder
        p.Billboard.Enabled = true
        return p
    end

    local part = Instance.new('Part')
    part.Name = 'KParticle'
    part.Size = Vector3.new(0.1, 0.1, 0.1)
    part.Transparency = 1
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.Anchored = true
    part.CastShadow = false

    local bb = Instance.new('BillboardGui')
    bb.Name = 'ParticleGui'
    bb.Size = UDim2.new(2, 0, 2, 0)
    bb.AlwaysOnTop = true
    bb.LightInfluence = 0
    bb.ResetOnSpawn = false
    bb.Adornee = part
    bb.Parent = part

    local img = Instance.new('ImageLabel')
    img.Name = 'Icon'
    img.Size = UDim2.new(1, 0, 1, 0)
    img.BackgroundTransparency = 1
    img.ZIndex = 10
    img.Parent = bb

    part.Parent = particlesFolder
    return {
        Part = part,
        Billboard = bb,
        Image = img,
    }
end

local function releaseParticle(p)
    if not p then return end
    if p.Billboard then p.Billboard.Enabled = false end
    if p.Part then p.Part.Parent = nil end
    if #particlePool < MAX_PARTICLES then
        table.insert(particlePool, p)
    else
        if p.Part then p.Part:Destroy() end
    end
end

local function getSelectedParticleTexture(style)
    local mode = style or (Options.ParticleType and Options.ParticleType.Value)
    if not mode or mode == 'Default' then
        mode = Options.ParticleType and Options.ParticleType.Value or 'Bloom'
    end
    if mode == 'Random' then
        local rnd = particleNamesList[math.random(1, #particleNamesList)]
        return particleTextures[rnd] or particleTextures['Bloom']
    end
    return particleTextures[mode] or particleTextures['Bloom']
end

local function spawnCustomParticle(pos, vel, color, sizeMultiplier, lifetime, mode, style, centerPos)
    if not Toggles.Particles or not Toggles.Particles.Value then return end
    if #activeParticles >= MAX_PARTICLES then
        local oldest = table.remove(activeParticles, 1)
        if oldest then releaseParticle(oldest.Obj) end
    end

    local obj = getParticleInstance()
    obj.Image.Image = getSelectedParticleTexture(style)

    local mult = (sizeMultiplier or 1)
    local userSize = (Options.ParticleSize and Options.ParticleSize.Value or 1.2) * mult
    local studSize = math.max(0.4, userSize * 1.8)
    obj.Billboard.Size = UDim2.new(studSize, 0, studSize, 0)
    obj.Billboard.AlwaysOnTop = (Toggles.ParticleThroughWalls == nil or Toggles.ParticleThroughWalls.Value == true)
    obj.Billboard.LightInfluence = (Toggles.ParticleGlow and Toggles.ParticleGlow.Value) and 0 or 1
    local pColor = color or (Options.ParticleColor and Options.ParticleColor.Value) or Color3.fromRGB(255, 100, 200)
    obj.Image.ImageColor3 = pColor
    obj.Image.ImageTransparency = 0
    obj.Part.CFrame = CFrame.new(pos)

    local rotSpeed = (Toggles.ParticleRotation and Toggles.ParticleRotation.Value) and (math.random(-240, 240)) or 0
    local speedMult = (Options.ParticleSpeed and Options.ParticleSpeed.Value or 1.5)
    local pData = {
        Obj = obj,
        Pos = pos,
        Center = centerPos or pos,
        Mode = mode or 'Normal',
        Vel = vel * (speedMult * 10),
        Age = 0,
        Lifetime = lifetime or (math.random(60, 110) / 100),
        FadeIn = 0.08,
        FadeOutStart = (lifetime or 0.8) * 0.65,
        Rot = math.random(0, 360),
        RotSpeed = rotSpeed,
        Color = pColor,
        Seed = math.random(),
    }
    table.insert(activeParticles, pData)
end

spawnAttackParticles = function(targetPos)
    if not isParticleEventEnabled('Attack') then return end
    local count = Options.ParticleAttackCount and Options.ParticleAttackCount.Value or 15
    local style = Options.AttackParticleStyle and Options.AttackParticleStyle.Value or 'Star'
    local mode = Options.AttackParticleMode and Options.AttackParticleMode.Value or 'Bounce'
    local col = (Toggles.AttackCustomColor and Toggles.AttackCustomColor.Value and Options.AttackColor and Options.AttackColor.Value)
        or (Options.ParticleColor and Options.ParticleColor.Value)

    for _ = 1, count do
        local offset = Vector3.new((math.random() - 0.5) * 1.2, (math.random() - 0.5) * 1.5, (math.random() - 0.5) * 1.2)
        local vel
        if mode == 'Fountain' then
            vel = Vector3.new((math.random() - 0.5) * 2.2, math.random() * 3.5 + 3.0, (math.random() - 0.5) * 2.2)
        elseif mode == 'Vortex' then
            vel = Vector3.new((math.random() - 0.5) * 2.8, math.random() * 2.0 + 0.5, (math.random() - 0.5) * 2.8)
        elseif mode == 'Burst' then
            vel = Vector3.new((math.random() - 0.5) * 5.0, (math.random() - 0.5) * 5.0, (math.random() - 0.5) * 5.0)
        else -- Normal or Bounce
            vel = Vector3.new((math.random() - 0.5) * 3.2, (math.random() - 0.5) * 2.8 + 0.8, (math.random() - 0.5) * 3.2)
        end
        spawnCustomParticle(targetPos + offset, vel, col, 1.0, math.random(6, 12) / 10, mode, style, targetPos)
    end
end

spawnTotemParticles = function(targetPos)
    if not isParticleEventEnabled('Totem') then return end
    local count = Options.ParticleTotemCount and Options.ParticleTotemCount.Value or 18
    local style = Options.TotemParticleStyle and Options.TotemParticleStyle.Value or 'Kronex'
    local mode = Options.TotemParticleMode and Options.TotemParticleMode.Value or 'Fountain'
    local useCustomCol = Toggles.TotemCustomColor and Toggles.TotemCustomColor.Value

    for _ = 1, count do
        local col
        if useCustomCol and Options.TotemColor then
            col = Options.TotemColor.Value
        else
            col = (math.random() > 0.5) and TOTEM_COLOR_YELLOW or TOTEM_COLOR_GREEN
        end
        local offset = Vector3.new((math.random() - 0.5) * 1.2, (math.random() - 0.5) * 1.5 + 1.0, (math.random() - 0.5) * 1.2)
        local vel
        if mode == 'Fountain' then
            vel = Vector3.new((math.random() - 0.5) * 3.5, math.random() * 3.5 + 2.0, (math.random() - 0.5) * 3.5)
        elseif mode == 'Vortex' then
            vel = Vector3.new((math.random() - 0.5) * 3.0, math.random() * 2.5 + 1.0, (math.random() - 0.5) * 3.0)
        elseif mode == 'Burst' then
            vel = Vector3.new((math.random() - 0.5) * 5.5, (math.random() - 0.5) * 5.5 + 1.0, (math.random() - 0.5) * 5.5)
        else -- Normal or Bounce
            vel = Vector3.new((math.random() - 0.5) * 3.5, math.random() * 2.5 + 1.2, (math.random() - 0.5) * 3.5)
        end
        spawnCustomParticle(targetPos + offset, vel, col, 1.2, math.random(10, 18) / 10, mode, style, targetPos)
    end
end

spawnThrowParticles = function(p1, p2)
    if not isParticleEventEnabled('Throw') then return end
    local count = Options.ParticleThrowCount and Options.ParticleThrowCount.Value or 4
    local style = Options.ThrowParticleStyle and Options.ThrowParticleStyle.Value or 'Bloom'
    local mode = Options.ThrowParticleMode and Options.ThrowParticleMode.Value or 'Normal'
    local col = (Toggles.ThrowCustomColor and Toggles.ThrowCustomColor.Value and Options.ThrowColor and Options.ThrowColor.Value)
        or (Options.ParticleColor and Options.ParticleColor.Value)

    local dir = p2 - p1
    local dist = dir.Magnitude
    if dist < 1 then return end
    for i = 1, count do
        local frac = i / (count + 1)
        local pos = p1 + dir * frac + Vector3.new((math.random() - 0.5) * 0.5, (math.random() - 0.5) * 0.5, (math.random() - 0.5) * 0.5)
        local vel
        if mode == 'Vortex' then
            vel = Vector3.new((math.random() - 0.5) * 1.5, math.random() * 1.5, (math.random() - 0.5) * 1.5)
        elseif mode == 'Burst' then
            vel = Vector3.new((math.random() - 0.5) * 3.0, (math.random() - 0.5) * 3.0, (math.random() - 0.5) * 3.0)
        elseif mode == 'Fountain' then
            vel = Vector3.new((math.random() - 0.5) * 1.0, math.random() * 2.0 + 1.0, (math.random() - 0.5) * 1.0)
        else -- Normal or Bounce
            vel = Vector3.new((math.random() - 0.5) * 0.8, (math.random() - 0.5) * 0.8, (math.random() - 0.5) * 0.8)
        end
        spawnCustomParticle(pos, vel, col, 0.6, math.random(4, 8) / 10, mode, style, pos)
    end
end

local particleRayParams = RaycastParams.new()
particleRayParams.FilterType = Enum.RaycastFilterType.Exclude

local lastPlayerPos = nil
local lastMoveParticleTick = 0
local lastIdleParticleTick = 0

local function updateParticles(dt)
    if not Toggles.Particles or not Toggles.Particles.Value then
        if #activeParticles > 0 then
            for i = #activeParticles, 1, -1 do
                releaseParticle(activeParticles[i].Obj)
                table.remove(activeParticles, i)
            end
        end
        return
    end

    if LP.Character then
        particleRayParams.FilterDescendantsInstances = { LP.Character, particlesFolder }
    else
        particleRayParams.FilterDescendantsInstances = { particlesFolder }
    end

    local throughWalls = (Toggles.ParticleThroughWalls == nil or Toggles.ParticleThroughWalls.Value == true)
    local glow = Toggles.ParticleGlow and Toggles.ParticleGlow.Value
    local isRainbow = Toggles.ParticleRainbow and Toggles.ParticleRainbow.Value
    local mainColor = Options.ParticleColor and Options.ParticleColor.Value or Color3.fromRGB(255, 100, 200)

    for i = #activeParticles, 1, -1 do
        local p = activeParticles[i]
        p.Age = p.Age + dt
        if p.Age >= p.Lifetime then
            releaseParticle(p.Obj)
            table.remove(activeParticles, i)
        else
            local pMode = p.Mode or 'Normal'
            if pMode == 'Bounce' then
                local nextPos = p.Pos + p.Vel * dt
                local rayResult = Workspace:Raycast(p.Pos, p.Vel * dt, particleRayParams)
                if rayResult then
                    local normal = rayResult.Normal
                    p.Vel = (p.Vel - 2 * p.Vel:Dot(normal) * normal) * 0.65
                    p.Pos = rayResult.Position + normal * 0.08
                else
                    p.Pos = nextPos
                end
                p.Vel = p.Vel * (0.95 ^ (dt * 60)) - Vector3.new(0, 9.8 * 0.6 * dt, 0)

            elseif pMode == 'Fountain' then
                local nextPos = p.Pos + p.Vel * dt
                local rayResult = Workspace:Raycast(p.Pos, p.Vel * dt, particleRayParams)
                if rayResult then
                    local normal = rayResult.Normal
                    p.Vel = (p.Vel - 2 * p.Vel:Dot(normal) * normal) * 0.55
                    p.Pos = rayResult.Position + normal * 0.08
                else
                    p.Pos = nextPos
                end
                p.Vel = p.Vel * (0.96 ^ (dt * 60)) - Vector3.new(0, 12 * 0.5 * dt, 0)

            elseif pMode == 'Vortex' then
                local rel = p.Pos - (p.Center or p.Pos)
                local tangent = Vector3.new(-rel.Z, 0, rel.X)
                if tangent.Magnitude > 0.01 then
                    p.Vel = p.Vel + tangent.Unit * (18 * dt)
                end
                p.Pos = p.Pos + p.Vel * dt
                p.Vel = p.Vel * (0.96 ^ (dt * 60)) + Vector3.new(0, 1.5 * dt, 0)

            elseif pMode == 'Burst' then
                p.Pos = p.Pos + p.Vel * dt
                p.Vel = p.Vel * (0.89 ^ (dt * 60))

            else -- 'Normal'
                p.Pos = p.Pos + p.Vel * dt
                p.Vel = p.Vel * (0.94 ^ (dt * 60)) - Vector3.new(0, 2.0 * dt, 0)
            end

            p.Obj.Part.CFrame = CFrame.new(p.Pos)

            if p.RotSpeed ~= 0 then
                p.Rot = (p.Rot + p.RotSpeed * dt) % 360
                p.Obj.Image.Rotation = p.Rot
            end

            local alpha = 1
            if p.Age < p.FadeIn then
                alpha = p.Age / p.FadeIn
            elseif p.Age > p.FadeOutStart then
                alpha = math.clamp((p.Lifetime - p.Age) / (p.Lifetime - p.FadeOutStart), 0, 1)
            end
            p.Obj.Image.ImageTransparency = 1 - alpha

            if isRainbow then
                p.Obj.Image.ImageColor3 = Color3.fromHSV((tick() * 0.5 + p.Seed) % 1, 0.8, 1)
            else
                p.Obj.Image.ImageColor3 = p.Color or mainColor
            end

            p.Obj.Billboard.AlwaysOnTop = throughWalls
            p.Obj.Billboard.LightInfluence = glow and 0 or 1
        end
    end

    -- Move particles check
    if isParticleEventEnabled('Move') and LP.Character then
        local hrp = LP.Character:FindFirstChild('HumanoidRootPart')
        local hum = LP.Character:FindFirstChildOfClass('Humanoid')
        if hrp and hum and hum.Health > 0 then
            local curPos = hrp.Position
            if lastPlayerPos then
                local dist = (curPos - lastPlayerPos).Magnitude
                if dist > 0.05 and (tick() - lastMoveParticleTick > 0.05) then
                    lastMoveParticleTick = tick()
                    local moveCount = Options.ParticleMoveCount and Options.ParticleMoveCount.Value or 3
                    local style = Options.MoveParticleStyle and Options.MoveParticleStyle.Value or 'Snow'
                    local mode = Options.MoveParticleMode and Options.MoveParticleMode.Value or 'Normal'
                    local col = (Toggles.MoveCustomColor and Toggles.MoveCustomColor.Value and Options.MoveColor and Options.MoveColor.Value)
                        or (Options.ParticleColor and Options.ParticleColor.Value)

                    local moveDir = (curPos - lastPlayerPos).Unit
                    for _ = 1, moveCount do
                        local spawnPos = curPos - Vector3.new(0, 1.5, 0) + Vector3.new((math.random() - 0.5) * 1.0, (math.random() - 0.5) * 0.6, (math.random() - 0.5) * 1.0)
                        local vel
                        if mode == 'Vortex' then
                            vel = -moveDir * 1.2 + Vector3.new((math.random() - 0.5) * 2.0, math.random() * 1.5 + 0.5, (math.random() - 0.5) * 2.0)
                        elseif mode == 'Fountain' then
                            vel = -moveDir * 1.0 + Vector3.new((math.random() - 0.5) * 1.0, math.random() * 2.5 + 2.0, (math.random() - 0.5) * 1.0)
                        elseif mode == 'Burst' then
                            vel = -moveDir * 2.0 + Vector3.new((math.random() - 0.5) * 3.0, (math.random() - 0.5) * 2.0, (math.random() - 0.5) * 3.0)
                        else -- Normal or Bounce
                            vel = -moveDir * 1.8 + Vector3.new((math.random() - 0.5) * 1.2, math.random() * 0.8 + 0.4, (math.random() - 0.5) * 1.2)
                        end
                        spawnCustomParticle(spawnPos, vel, col, 0.8, math.random(6, 11) / 10, mode, style, curPos)
                    end
                end
            end
            lastPlayerPos = curPos
        end
    end

    -- Idle particles check
    if isParticleEventEnabled('Idle') and LP.Character then
        if tick() - lastIdleParticleTick > 0.35 then
            lastIdleParticleTick = tick()
            local hrp = LP.Character:FindFirstChild('HumanoidRootPart')
            local hum = LP.Character:FindFirstChildOfClass('Humanoid')
            if hrp and hum and hum.Health > 0 then
                local idleCount = Options.ParticleIdleCount and Options.ParticleIdleCount.Value or 3
                local range = Options.ParticleIdleRange and Options.ParticleIdleRange.Value or 12
                local style = Options.IdleParticleStyle and Options.IdleParticleStyle.Value or 'Heart'
                local mode = Options.IdleParticleMode and Options.IdleParticleMode.Value or 'Vortex'
                local col = (Toggles.IdleCustomColor and Toggles.IdleCustomColor.Value and Options.IdleColor and Options.IdleColor.Value)
                    or (Options.ParticleColor and Options.ParticleColor.Value)

                for _ = 1, idleCount do
                    local offsetX = (math.random() - 0.5) * range
                    local offsetZ = (math.random() - 0.5) * range
                    local offsetY = (math.random() - 0.5) * 4 + 0.5
                    local spawnPos = hrp.Position + Vector3.new(offsetX, offsetY, offsetZ)
                    local vel
                    if mode == 'Vortex' then
                        vel = Vector3.new((math.random() - 0.5) * 1.5, math.random() * 1.2 + 0.4, (math.random() - 0.5) * 1.5)
                    elseif mode == 'Fountain' then
                        vel = Vector3.new((math.random() - 0.5) * 0.8, math.random() * 2.5 + 1.5, (math.random() - 0.5) * 0.8)
                    elseif mode == 'Burst' then
                        vel = Vector3.new((math.random() - 0.5) * 2.5, (math.random() - 0.5) * 2.0, (math.random() - 0.5) * 2.5)
                    else -- Normal or Bounce
                        vel = Vector3.new((math.random() - 0.5) * 0.6, math.random() * 0.5 + 0.2, (math.random() - 0.5) * 0.6)
                    end
                    spawnCustomParticle(spawnPos, vel, col, 0.8, math.random(15, 25) / 10, mode, style, hrp.Position)
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(updateParticles)

-- Death / Totem listener
local function hookDeathForTotem(player)
    local function onChar(char)
        local hum = char:WaitForChild('Humanoid', 5)
        if hum then
            hum.Died:Connect(function()
                local hrp = char:FindFirstChild('HumanoidRootPart') or char:FindFirstChild('Head')
                if hrp then
                    local myHrp = LP.Character and LP.Character:FindFirstChild('HumanoidRootPart')
                    if myHrp and (hrp.Position - myHrp.Position).Magnitude < 250 then
                        spawnTotemParticles(hrp.Position)
                    end
                end
            end)
        end
    end
    if player.Character then onChar(player.Character) end
    player.CharacterAdded:Connect(onChar)
end

for _, pl in ipairs(Players:GetPlayers()) do
    if pl ~= LP then hookDeathForTotem(pl) end
end
Players.PlayerAdded:Connect(function(pl)
    if pl ~= LP then hookDeathForTotem(pl) end
end)

cleanupParticles = function()
    for _, p in ipairs(activeParticles) do
        if p.Obj and p.Obj.Part then p.Obj.Part:Destroy() end
    end
    activeParticles = {}
    for _, p in ipairs(particlePool) do
        if p.Part then p.Part:Destroy() end
    end
    particlePool = {}
    if particlesFolder then
        particlesFolder:Destroy()
        particlesFolder = nil
    end
end


end

-- Shot tracking for Real Hitsound & Hit Numbers Confirmation
local lastShotInfo = {
    targetPlayer = nil,
    targetChar = nil,
    targetPart = nil,
    hitPos = nil,
    tick = 0,
    toolName = nil,
    behavior = nil,
    recentAttacks = setmetatable({}, { __mode = 'k' }),
    lastAttackTick = 0,
}

lastShotInfo.recordAttack = function(player, hitPart, hitPos, weaponName)
    if not player or player == LP then return end
    local now = tick()
    lastShotInfo.recentAttacks[player] = {
        tick = now,
        part = hitPart,
        pos = hitPos,
        weapon = weaponName or 'Weapon'
    }
    lastShotInfo.lastAttackTick = now

    lastShotInfo.targetPlayer = player
    lastShotInfo.targetChar = player.Character
    lastShotInfo.targetPart = hitPart
    lastShotInfo.hitPos = hitPos or (hitPart and hitPart.Position)
    lastShotInfo.tick = now
    lastShotInfo.toolName = weaponName or 'Weapon'
    lastShotInfo.behavior = 'Standard'
end

-- Silent Aim & Hit Registration Hook
local isDoubleTapping = false
-- RageBot 自己发起的射击：置位期间钩子不再补发双击包，
-- 否则 rage 的每一发都会被钩子再复制一份（连上 fire() 内部的双击就是 3~4 倍重复包）
local isRageFiring = false
local oldNamecall
oldNamecall = hookmetamethod(game, '__namecall', function(self, ...)
    local method = getnamecallmethod()
    if (method == 'Kick' or method == 'kick') and (self == LP or self == Players.LocalPlayer) then
        return nil
    end

    -- 玩家自己按换弹键：补上「手动虚空换弹」
    if (method == 'InvokeServer' or method == 'FireServer') and self == FuncReload then
        if _G.BoarsManualVoidReload then
            pcall(_G.BoarsManualVoidReload)
        end
    end

    if method == 'FireServer' and self == ShootEvent then
        local now = tick()
        lastShotInfo.tick = now
        lastShotInfo.lastAttackTick = now
        local callArgs = { ... }
        local bullets = callArgs[1]
        if typeof(bullets) == 'table' then
            for _, bullet in pairs(bullets) do
                if typeof(bullet) == 'table' then
                    local hitPart = nil
                    local hitPos = nil
                    for _, val in pairs(bullet) do
                        if typeof(val) == 'Instance' and game.IsA(val, 'BasePart') then
                            hitPart = val
                        elseif typeof(val) == 'Vector3' then
                            hitPos = val
                        end
                    end
                    if hitPart then
                        local hitChar = hitPart.Parent
                        local targetPlayer = hitChar and Players.GetPlayerFromCharacter(Players, hitChar)
                        if not targetPlayer and hitChar and hitChar.Parent then
                            targetPlayer = Players.GetPlayerFromCharacter(Players, hitChar.Parent)
                        end
                        if targetPlayer and targetPlayer ~= LP then
                            local char = LP.Character
                            local tool = char and game.FindFirstChildOfClass(char, 'Tool')
                            local wName = tool and tool.Name or 'Gun'
                            if lastShotInfo.recordAttack then
                                lastShotInfo.recordAttack(targetPlayer, hitPart, hitPos or hitPart.Position, wName)
                            end
                        end
                    end
                end
            end
        end

        if not isRageFiring and not isDoubleTapping and Toggles.DoubleTap and Toggles.DoubleTap.Value and (Toggles.DoubleTapManual == nil or Toggles.DoubleTapManual.Value) then
            local char = LP.Character
            local tool = char and game.FindFirstChildOfClass(char, 'Tool')
            local isRemington = tool and tool.Name == 'Remington 870'
            local mode = Options.DoubleTapWeapon and Options.DoubleTapWeapon.Value or 'Remington 870 Only'
            if mode == 'All Guns' or isRemington then
                isDoubleTapping = true
                local argsCopy = { ... }
                local burstDelay = (Options.DoubleTapDelay and Options.DoubleTapDelay.Value) or 0.02
                task.delay(burstDelay, function()
                    pcall(function()
                        if tool and tool.Parent == char then
                            ShootEvent:FireServer(unpack(argsCopy))
                            local curAmmo = tool:GetAttribute('Local_CurrentAmmo')
                            if curAmmo and curAmmo > 0 then
                                if Toggles.NoReload and Toggles.NoReload.Value then
                                    local nrCfg = getConfig(tool)
                                    tool:SetAttribute('Local_CurrentAmmo', tool:GetAttribute('MaxAmmo') or (nrCfg and nrCfg.maxAmmo) or curAmmo)
                                else
                                    tool:SetAttribute('Local_CurrentAmmo', curAmmo - 1)
                                end
                                updateHudAmmo(tool, tool:GetAttribute('Local_CurrentAmmo') or curAmmo, getConfig(tool))
                            end
                        end
                    end)
                    isDoubleTapping = false
                end)
            end
        end
    end

    if method == 'FireServer' and typeof(self) == 'Instance' and (self.Name == 'meleeEvent' or self.Name == 'Punch') then
        local now = tick()
        lastShotInfo.tick = now
        lastShotInfo.lastAttackTick = now
        local callArgs = { ... }
        local target = callArgs[1]
        local targetPlayer = nil
        local hitPart = nil
        if typeof(target) == 'Instance' then
            if game.IsA(target, 'Player') then
                targetPlayer = target
                hitPart = target.Character and (game.FindFirstChild(target.Character, 'HumanoidRootPart') or game.FindFirstChild(target.Character, 'Head'))
            elseif game.IsA(target, 'Model') then
                targetPlayer = Players.GetPlayerFromCharacter(Players, target)
                hitPart = game.FindFirstChild(target, 'HumanoidRootPart') or game.FindFirstChild(target, 'Head')
            elseif game.IsA(target, 'BasePart') then
                targetPlayer = Players.GetPlayerFromCharacter(Players, target.Parent)
                if not targetPlayer and target.Parent and target.Parent.Parent then
                    targetPlayer = Players.GetPlayerFromCharacter(Players, target.Parent.Parent)
                end
                hitPart = target
            end
        end
        if targetPlayer and targetPlayer ~= LP then
            local char = LP.Character
            local tool = char and game.FindFirstChildOfClass(char, 'Tool')
            local wName = tool and tool.Name or 'Melee'
            if lastShotInfo.recordAttack then
                lastShotInfo.recordAttack(targetPlayer, hitPart, hitPart and hitPart.Position or Vector3.zero, wName)
            end
        end
    end

    if method == 'Raycast' and self == Workspace and Toggles.SilentAim.Value then
        local args = {...}
        local raycastParams = args[3]
        if raycastParams and typeof(raycastParams) == 'RaycastParams' and raycastParams.CollisionGroup == 'ClientBullet' then
            if targetPartCache then
                local targetPlayer = targetPartCache.Parent and Players.GetPlayerFromCharacter(Players, targetPartCache.Parent)
                local aimPos = targetPartCache.Position
                if resolveTarget and Toggles.Resolver and Toggles.Resolver.Value and targetPlayer then
                    aimPos, targetPartCache = resolveTarget(targetPlayer, targetPartCache, args[1])
                end
                local dir = (aimPos - args[1]).Unit * args[2].Magnitude
                local inVeh, veh = targetPlayer and isInVehicle(targetPlayer)
                local origFilter = raycastParams.FilterDescendantsInstances
                local newFilter = table.clone(origFilter)
                if inVeh and veh then
                    table.insert(newFilter, veh)
                end
                if Toggles.ShieldBypass and Toggles.ShieldBypass.Value and (Toggles.ShieldBypassRiot == nil or Toggles.ShieldBypassRiot.Value) and targetPartCache.Parent then
                    local rsp = game.FindFirstChild(targetPartCache.Parent, 'RiotShieldPart')
                    if rsp then table.insert(newFilter, rsp) end
                    for _, item in ipairs(game.GetChildren(targetPartCache.Parent)) do
                        if game.IsA(item, 'Tool') and string.find(string.lower(item.Name), 'shield') then
                            table.insert(newFilter, item)
                        end
                    end
                end
                raycastParams.FilterDescendantsInstances = newFilter
                if setnamecallmethod then setnamecallmethod('Raycast') end
                local result = oldNamecall(self, args[1], dir, raycastParams)
                raycastParams.FilterDescendantsInstances = origFilter
                if result then
                    if targetPlayer then
                        if lastShotInfo.recordAttack then
                            lastShotInfo.recordAttack(targetPlayer, targetPartCache, targetPartCache.Position, 'SilentAim')
                        else
                            lastShotInfo.targetPlayer = targetPlayer
                            lastShotInfo.targetChar = targetPartCache.Parent
                            lastShotInfo.targetPart = targetPartCache
                            lastShotInfo.hitPos = targetPartCache.Position
                            lastShotInfo.tick = tick()
                            lastShotInfo.toolName = 'SilentAim'
                            lastShotInfo.behavior = 'Standard'
                        end
                    end
                    spawnAttackParticles(targetPartCache.Position)
                    return result
                end
            end
        end
    end

    if setnamecallmethod then setnamecallmethod(method) end
    return oldNamecall(self, ...)
end)

pcall(function()
    hookfunction(LP.Kick, function() end)
end)

-- Tracers Override
local GunTracers = require(ReplicatedStorage.SharedModules.GunTracers)

local function isOurBullet(origin)
    local char = LP.Character
    if not char then return false end
    local root = char:FindFirstChild('HumanoidRootPart') or char:FindFirstChild('Head')
    return root and (origin - root.Position).Magnitude < 30
end

local function getShooterFromOrigin(origin)
    local best, bestDist = nil, 15
    for _, player in Players:GetPlayers() do
        if player == LP then continue end
        local char = player.Character
        if not char then continue end
        local root = char:FindFirstChild('HumanoidRootPart') or char:FindFirstChild('Head')
        if root then
            local d = (origin - root.Position).Magnitude
            if d < bestDist then
                bestDist = d
                best = player
            end
        end
    end
    return best
end

local function shouldShowTracer(origin)
    if isOurBullet(origin) then return true end
    if not Toggles.TracersFilters.Value then return true end
    local shooter = getShooterFromOrigin(origin)
    if not shooter or shooter == LP then return true end
    if shooter.Team == LP.Team then return Toggles.TracersTeammates.Value end
    if shooter.Team == Teams.Guards then return Toggles.TracersGuards.Value end
    local isHostile = shooter.Character and shooter.Character:GetAttribute('Hostile')
    if shooter.Team == Teams.Inmates and isHostile then
        return Toggles.TracersHostile.Value
    end
    if shooter.Team == Teams.Inmates then return Toggles.TracersInmates.Value end
    if shooter.Team == Teams.Criminals then return Toggles.TracersCriminals.Value end
    return true
end

local rainbowHue = 0

-- ====================== 激光弹道（真实光柱，多层光束 + 能量脉冲） ======================
local function makeLaserBeam(p1, p2, weaponColor)
	local cam = workspace.CurrentCamera
	if not cam then return end
	if (p2 - p1).Magnitude < 0.1 then return end

	local TweenService = game:GetService('TweenService')

	local function laserColorNow()
		if Toggles.LaserRainbow and Toggles.LaserRainbow.Value then
			return Color3.fromHSV((tick() * 0.26) % 1, 0.95, 1)
		end
		local opt = Options.LaserColor
		return (opt and opt.Value) or Color3.fromRGB(0, 255, 190)
	end

	local col
	if Toggles.LaserUseWeaponColor and Toggles.LaserUseWeaponColor.Value and weaponColor then
		col = weaponColor
	else
		col = laserColorNow()
	end

	local width = (Options.LaserWidth and Options.LaserWidth.Value) or 0.22
	local life = (Options.LaserLife and Options.LaserLife.Value) or 0.22
	local glowMul = (Options.LaserGlow and Options.LaserGlow.Value) or 4
	local pulseSpeed = (Options.LaserPulse and Options.LaserPulse.Value) or 8
	local coreOn = not (Toggles.LaserCore and Toggles.LaserCore.Value == false)
	local flicker = Toggles.LaserFlicker and Toggles.LaserFlicker.Value
	local muzzleOn = not (Toggles.LaserMuzzle and Toggles.LaserMuzzle.Value == false)

	local endpointA = Instance.new('Part')
	endpointA.Name = 'WXLaserAnchor'
	endpointA.Size = Vector3.new(0.05, 0.05, 0.05)
	endpointA.CFrame = CFrame.new(p1)
	endpointA.Anchored = true
	endpointA.CanCollide = false
	endpointA.CanQuery = false
	endpointA.CanTouch = false
	endpointA.CastShadow = false
	endpointA.Transparency = 1
	endpointA.Parent = cam

	local endpointB = endpointA:Clone()
	endpointB.CFrame = CFrame.new(p2)
	endpointB.Parent = cam

	local at0 = Instance.new('Attachment')
	at0.Parent = endpointA
	local at1 = Instance.new('Attachment')
	at1.Parent = endpointB

	local function newBeam(w, c, transparency)
		local bm = Instance.new('Beam')
		bm.Attachment0 = at0
		bm.Attachment1 = at1
		bm.Width0 = w
		bm.Width1 = w
		bm.FaceCamera = true
		bm.Segments = 1
		bm.LightInfluence = 0
		bm.LightEmission = 1
		bm.Color = ColorSequence.new(c)
		bm.Transparency = NumberSequence.new(transparency)
		bm.Parent = endpointA
		return bm
	end

	-- 外层霰光：极淡的宽光晕，负责“空气被点亮”的观感
	local halo = newBeam(width * glowMul * 2.4, col:Lerp(Color3.new(1, 1, 1), 0.15), 0.955)
	-- 中层光晕：主要辉光
	local glow = newBeam(width * glowMul, col, 0.82)
	-- 主光柱：本体
	local body = newBeam(width, col:Lerp(Color3.new(1, 1, 1), 0.12), 0.18)
	-- 白热带：极细的高亮核心，消除塑料感
	local core = coreOn and newBeam(width * 0.4, col:Lerp(Color3.new(1, 1, 1), 0.9), 0.02) or nil

	local light = Instance.new('PointLight')
	light.Color = col
	light.Brightness = 4
	light.Range = 16 + width * 12
	light.Shadows = false
	light.Parent = endpointA

	-- 枪口闪光
	if muzzleOn then
		local flash = Instance.new('Part')
		flash.Name = 'WXLaserFlash'
		flash.Shape = Enum.PartType.Ball
		flash.Material = Enum.Material.Neon
		flash.Anchored = true
		flash.CanCollide = false
		flash.CanQuery = false
		flash.CanTouch = false
		flash.CastShadow = false
		flash.Color = col:Lerp(Color3.new(1, 1, 1), 0.65)
		flash.Size = Vector3.new(1, 1, 1) * (0.35 + width * 2.2)
		flash.CFrame = CFrame.new(p1)
		flash.Transparency = 0.05
		flash.Parent = cam

		local fl = Instance.new('PointLight')
		fl.Color = col
		fl.Brightness = 8
		fl.Range = 18
		fl.Shadows = false
		fl.Parent = flash

		local flashTween = TweenService:Create(flash, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = flash.Size * 2.6,
			Transparency = 1,
		})
		flashTween:Play()
		for _, d in ipairs(flash:GetChildren()) do
			if d:IsA('PointLight') then
				TweenService:Create(d, TweenInfo.new(0.1), { Brightness = 0, Range = 0 }):Play()
			end
		end
		Debris:AddItem(flash, 0.25)
	end

	-- 能量脉冲：一道从枪口射向命中点的光弹，制造“发射”的瞬时感
	local bead = Instance.new('Part')
	bead.Name = 'WXLaserBead'
	bead.Shape = Enum.PartType.Ball
	bead.Material = Enum.Material.Neon
	bead.Anchored = true
	bead.CanCollide = false
	bead.CanQuery = false
	bead.CanTouch = false
	bead.CastShadow = false
	bead.Color = col:Lerp(Color3.new(1, 1, 1), 0.6)
	bead.Size = Vector3.new(1, 1, 1) * math.max(0.18, width * 1.5)
	bead.CFrame = CFrame.new(p1)
	bead.Transparency = 0.15
	bead.Parent = cam

	local travel = math.clamp((p2 - p1).Magnitude / 900, 0.02, 0.12)
	local beadTween = TweenService:Create(bead, TweenInfo.new(travel, Enum.EasingStyle.Linear), {
		CFrame = CFrame.new(p2),
		Transparency = 1,
	})
	beadTween:Play()
	Debris:AddItem(bead, travel + 0.1)

	-- 命中点：光斑 + 溅射
	local hit = Instance.new('Part')
	hit.Name = 'WXLaserHit'
	hit.Shape = Enum.PartType.Ball
	hit.Material = Enum.Material.Neon
	hit.Anchored = true
	hit.CanCollide = false
	hit.CanQuery = false
	hit.CanTouch = false
	hit.CastShadow = false
	hit.Color = col:Lerp(Color3.new(1, 1, 1), 0.35)
	hit.Size = Vector3.new(0.3, 0.3, 0.3)
	hit.CFrame = CFrame.new(p2)
	hit.Transparency = 0.1
	hit.Parent = cam

	local hitLight = Instance.new('PointLight')
	hitLight.Color = col
	hitLight.Brightness = 6
	hitLight.Range = 14
	hitLight.Shadows = false
	hitLight.Parent = hit

	local hitTween = TweenService:Create(hit, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(2.6, 2.6, 2.6) * math.max(0.5, width * 2),
		Transparency = 1,
	})
	hitTween:Play()
	TweenService:Create(hitLight, TweenInfo.new(0.22), { Brightness = 0, Range = 0 }):Play()
	Debris:AddItem(hit, 0.3)

	local t0 = tick()
	local conn
	conn = RunService.RenderStepped:Connect(function()
		local e = tick() - t0
		if e >= life or not endpointA.Parent or not endpointB.Parent then
			if conn then
				conn:Disconnect()
				conn = nil
			end
			if endpointA then endpointA:Destroy() end
			if endpointB then endpointB:Destroy() end
			return
		end

		local k = 1 - (e / life)                        -- 1 -> 0 衰减
		local shake = 1
		if flicker then
			shake = 1 + math.sin(e * pulseSpeed * 4.2) * 0.16 + (math.random() - 0.5) * 0.12
		else
			shake = 1 + math.sin(e * pulseSpeed) * 0.04
		end

		local w = width * shake
		body.Width0 = w
		body.Width1 = w * (0.55 + 0.45 * k)
		glow.Width0 = w * glowMul
		glow.Width1 = glow.Width0 * (0.6 + 0.4 * k)
		halo.Width0 = w * glowMul * 2.4
		halo.Width1 = halo.Width0 * (0.6 + 0.4 * k)
		if core then
			core.Width0 = w * 0.4
			core.Width1 = core.Width0 * (0.5 + 0.5 * k)
		end

		local fade = (1 - k) ^ 1.7
		local head = math.clamp(e / math.max(life, 0.001), 0, 1)

		body.Transparency = NumberSequence.new(0.15 + fade * 0.85)
		if core then core.Transparency = NumberSequence.new(0.02 + fade * 0.98) end

		glow.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.84),
			NumberSequenceKeypoint.new(math.clamp(head, 0.001, 0.999), 0.4),
			NumberSequenceKeypoint.new(1, 1),
		})
		halo.Transparency = NumberSequence.new(0.955 + fade * 0.045)

		light.Brightness = 4 * k
	end)
	Debris:AddItem(endpointA, life + 0.6)
	Debris:AddItem(endpointB, life + 0.6)
end


local function spawnImpactEffect(pos, color)
    if not (Toggles.TracersImpact and Toggles.TracersImpact.Value) then return end
    local sz = Options.TracerImpactSize and Options.TracerImpactSize.Value or 0.8
    local part = Instance.new('Part')
    part.Name = 'TracerImpact'
    part.Material = Enum.Material.Neon
    part.Shape = Enum.PartType.Ball
    part.Size = Vector3.new(sz, sz, sz)
    part.CFrame = CFrame.new(pos)
    part.Anchored = true
    part.CanCollide = false
    part.CanQuery = false
    part.CanTouch = false
    part.CastShadow = false
    part.Color = color
    part.Parent = workspace.CurrentCamera

    local TweenService = game:GetService('TweenService')
    local tw = TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(sz * 1.6, sz * 1.6, sz * 1.6),
        Transparency = 1
    })
    tw:Play()
    tw.Completed:Connect(function()
        part:Destroy()
    end)
    Debris:AddItem(part, 0.35)
end

local function makeTracer(p1, p2, color1, color2, thickness, lifetime)
    color2 = color2 or color1
    local mode = Options.TracerMode and Options.TracerMode.Value or 'Solid Beam'
    local matName = Options.TracerMaterial and Options.TracerMaterial.Value or 'Neon'
    local mat = Enum.Material[matName] or Enum.Material.Neon
    local trans = Options.TracerTransparency and Options.TracerTransparency.Value or 0.2
    local magn = (p1 - p2).Magnitude
    local mid = (p1 + p2) / 2
    local TweenService = game:GetService('TweenService')

    if mode == '激光 Laser' then
        makeLaserBeam(p1, p2, color2)
        return
    end

    spawnImpactEffect(p2, color2)

    if mode == 'Camera Facing Beam' then
        local p0 = Instance.new('Part')
        p0.Size = Vector3.zero
        p0.CFrame = CFrame.new(p1)
        p0.Anchored = true
        p0.CanCollide = false
        p0.Transparency = 1
        p0.Parent = workspace.CurrentCamera

        local p1part = Instance.new('Part')
        p1part.Size = Vector3.zero
        p1part.CFrame = CFrame.new(p2)
        p1part.Anchored = true
        p1part.CanCollide = false
        p1part.Transparency = 1
        p1part.Parent = workspace.CurrentCamera

        local a0 = Instance.new('Attachment', p0)
        local a1 = Instance.new('Attachment', p1part)

        local beam = Instance.new('Beam', p0)
        beam.Attachment0 = a0
        beam.Attachment1 = a1
        beam.Width0 = thickness
        beam.Width1 = thickness
        beam.FaceCamera = true
        beam.Color = ColorSequence.new(color1, color2)
        beam.Transparency = NumberSequence.new(trans)
        beam.LightInfluence = 0
        beam.LightEmission = 1

        local tw = TweenService:Create(beam, TweenInfo.new(lifetime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Width0 = 0,
            Width1 = 0,
            Transparency = NumberSequence.new(1)
        })
        tw:Play()
        tw.Completed:Connect(function()
            p0:Destroy()
            p1part:Destroy()
        end)
        Debris:AddItem(p0, lifetime + 0.15)
        Debris:AddItem(p1part, lifetime + 0.15)
        return
    end

    if mode == 'Flying Projectile' or mode == 'Flying Bullet' then
        local bLen = Options.FlyingBulletLength and Options.FlyingBulletLength.Value or 4
        local spd = Options.FlyingBulletSpeed and Options.FlyingBulletSpeed.Value or 1200
        local travelTime = math.clamp(magn / spd, 0.02, 1.5)

        local bullet = Instance.new('Part')
        bullet.Name = 'FlyingTracer'
        bullet.Material = mat
        bullet.Anchored = true
        bullet.CanCollide = false
        bullet.CanQuery = false
        bullet.CanTouch = false
        bullet.CastShadow = false
        bullet.Color = color1
        bullet.Transparency = trans
        bullet.Size = Vector3.new(thickness * 1.2, thickness * 1.2, math.min(bLen, magn))
        bullet.CFrame = CFrame.new(p1, p2)
        bullet.Parent = workspace.CurrentCamera

        local tw = TweenService:Create(bullet, TweenInfo.new(travelTime, Enum.EasingStyle.Linear), {
            CFrame = CFrame.new(p2, p2 + (p2 - p1).Unit)
        })
        tw:Play()
        tw.Completed:Connect(function()
            bullet:Destroy()
        end)
        Debris:AddItem(bullet, travelTime + 0.1)
        return
    end

    -- Part-based Tracers (Solid Beam, Laser Cylinder, Pulse Fade)
    local part = Instance.new('Part')
    part.Name = 'RayPart'
    part.Material = mat
    part.Anchored = true
    part.Transparency = trans
    part.CanCollide = false
    part.CanQuery = false
    part.CanTouch = false
    part.CastShadow = false
    part.Color = color1

    if mode == 'Laser Cylinder' then
        part.Shape = Enum.PartType.Cylinder
        part.Size = Vector3.new(magn, thickness, thickness)
        part.CFrame = CFrame.new(mid, p2) * CFrame.Angles(0, math.rad(90), 0)
    else
        part.Size = Vector3.new(thickness, thickness, magn)
        part.CFrame = CFrame.new(mid, p2)
    end

    local colorMode = Options.TracerColorMode and Options.TracerColorMode.Value or 'Solid Color'
    if colorMode == 'Gradient (Muzzle -> Hit)' and color1 ~= color2 then
        local gui = Instance.new('SurfaceGui', part)
        gui.Face = Enum.NormalId.Front
        gui.LightInfluence = 0
        gui.AlwaysOnTop = true
        local frame = Instance.new('Frame', gui)
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundColor3 = Color3.new(1, 1, 1)
        frame.BorderSizePixel = 0
        frame.BackgroundTransparency = trans
        local gradient = Instance.new('UIGradient', frame)
        gradient.Color = ColorSequence.new(color1, color2)

        local gui2 = Instance.new('SurfaceGui', part)
        gui2.Face = Enum.NormalId.Back
        gui2.LightInfluence = 0
        gui2.AlwaysOnTop = true
        local frame2 = Instance.new('Frame', gui2)
        frame2.Size = UDim2.new(1, 0, 1, 0)
        frame2.BackgroundColor3 = Color3.new(1, 1, 1)
        frame2.BorderSizePixel = 0
        frame2.BackgroundTransparency = trans
        local gradient2 = Instance.new('UIGradient', frame2)
        gradient2.Color = ColorSequence.new(color1, color2)
    end

    if Toggles.TracersGlow and Toggles.TracersGlow.Value then
        local light = Instance.new('SurfaceLight', part)
        light.Color = color1
        light.Range = Options.TracerGlowRange and Options.TracerGlowRange.Value or 7
        light.Face = Enum.NormalId.Bottom
        light.Brightness = Options.TracerGlowBrightness and Options.TracerGlowBrightness.Value or 5
        light.Angle = 180
    end

    if mode == 'Pulse Fade' then
        local tw = TweenService:Create(part, TweenInfo.new(lifetime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Transparency = 1,
            Size = part.Size + Vector3.new(thickness * 0.6, thickness * 0.6, 0)
        })
        tw:Play()
    end

    Debris:AddItem(part, lifetime)
    part.Parent = workspace.CurrentCamera
end

local function getColor(colorKey, rainbowKey)
    if Toggles[rainbowKey] and Toggles[rainbowKey].Value then
        local h1 = rainbowHue
        local h2 = (rainbowHue + 0.3) % 1
        return Color3.fromHSV(h1, 1, 1), Color3.fromHSV(h2, 1, 1)
    end
    local opt = Options[colorKey]
    local c = opt and opt.Value or Color3.new(1, 1, 1)
    return c, c
end

local oldCreateBullet = GunTracers.createBullet
local oldCreateSniper = GunTracers.createSniper
local oldCreateTaser = GunTracers.createTaser

GunTracers.createBullet = function(p1, p2)
    if isOurBullet(p1) then
        spawnThrowParticles(p1, p2)
        spawnAttackParticles(p2)
    end
    if Toggles.Tracers.Value and Toggles.ShowBulletTracers.Value then
        if shouldShowTracer(p1) then
            local c1, c2 = getColor('BulletColor', 'BulletRainbow')
            makeTracer(p1, p2, c1, c2, Options.BulletThickness.Value, Options.BulletLifetime.Value)
        end
        return
    end
    return oldCreateBullet(p1, p2)
end

GunTracers.createSniper = function(p1, p2)
    if isOurBullet(p1) then
        spawnThrowParticles(p1, p2)
        spawnAttackParticles(p2)
    end
    if Toggles.Tracers.Value and Toggles.ShowSniperTracers.Value then
        if shouldShowTracer(p1) then
            local c1, c2 = getColor('SniperColor', 'SniperRainbow')
            makeTracer(p1, p2, c1, c2, Options.SniperThickness.Value, Options.SniperLifetime.Value)
        end
        return
    end
    return oldCreateSniper(p1, p2)
end

GunTracers.createTaser = function(p1, p2)
    if isOurBullet(p1) then
        spawnThrowParticles(p1, p2)
        spawnAttackParticles(p2)
    end
    if Toggles.Tracers.Value and Toggles.ShowTaserTracers.Value then
        if shouldShowTracer(p1) then
            local c1, c2 = getColor('TaserColor', 'TaserRainbow')
            makeTracer(p1, p2, c1, c2, Options.TaserThickness.Value, Options.TaserLifetime.Value)
        end
        return
    end
    return oldCreateTaser(p1, p2)
end

-- Rage Bot (v2)
local rageBotRunning = false
local rageBotLastShot = 0

local calculateModifiedFireRate

do
    local originalFireRates = {
        ['AK-47']         = { fireRate = 0.1,   auto = true },
        ['M4A1']          = { fireRate = 0.09,  auto = true },
        ['FAL']           = { fireRate = 0.095, auto = true },
        ['MP5']           = { fireRate = 0.1,   auto = true },
        ['M9']            = { fireRate = 0.12,  auto = false },
        ['Revolver']      = { fireRate = 0.3,   auto = false },
        ['M700']          = { fireRate = 0.2,   auto = false },
        ['Remington 870'] = { fireRate = 0.7,   auto = false },
        ['Taser']         = { fireRate = 0.1,   auto = false },
    }

    calculateModifiedFireRate = function(toolName, baseRate)
        if not (Toggles.FireRateChanger and Toggles.FireRateChanger.Value) then
            return baseRate
        end
        if toolName == 'Remington 870' then
            return baseRate
        end
        local mode = Options.FireRateMode and Options.FireRateMode.Value or 'Multiplier'
        if mode == 'Instant (0s)' then
            return 0.001
        elseif mode == 'Custom Delay' then
            local customVal = Options.CustomFireRate and Options.CustomFireRate.Value or 0.02
            return math.max(0.001, customVal)
        elseif mode == 'Multiplier' then
            local mult = Options.FireRateMultiplier and Options.FireRateMultiplier.Value or 3
            mult = math.max(1, mult)
            return math.max(0.001, baseRate / mult)
        end
        return baseRate
    end

    local function patchToolFireRate(tool)
        if not tool or not tool:IsA('Tool') then return end
        local isGun = tool:GetAttribute('ToolType') == 'Gun' or originalFireRates[tool.Name]
        if not isGun then return end

        local orig = originalFireRates[tool.Name]
        local baseRate = orig and orig.fireRate or (tool:GetAttribute('FireRate') or 0.1)
        local baseAuto = orig and orig.auto or (tool:GetAttribute('AutoFire') ~= false)

        if tool.Name == 'Remington 870' then
            if orig then
                tool:SetAttribute('FireRate', orig.fireRate)
                tool:SetAttribute('AutoFire', orig.auto)
            end
            return
        end

        if Toggles.FireRateChanger and Toggles.FireRateChanger.Value and (Toggles.FireRateApplyManual == nil or Toggles.FireRateApplyManual.Value) then
            local newRate = calculateModifiedFireRate(tool.Name, baseRate)
            local forceAuto = Toggles.AlwaysAutomatic and Toggles.AlwaysAutomatic.Value
            tool:SetAttribute('FireRate', newRate)
            if forceAuto then
                tool:SetAttribute('AutoFire', true)
            end
        else
            if orig then
                tool:SetAttribute('FireRate', orig.fireRate)
                tool:SetAttribute('AutoFire', orig.auto)
            end
        end
    end

    local function updateGunControllerInternal()
        if not (getgc and getupvalues) then return end
        pcall(function()
            local isEnabled = Toggles.FireRateChanger and Toggles.FireRateChanger.Value and (Toggles.FireRateApplyManual == nil or Toggles.FireRateApplyManual.Value)
            local forceAuto = Toggles.AlwaysAutomatic and Toggles.AlwaysAutomatic.Value

            for _, obj in ipairs(getgc(true)) do
                if type(obj) == 'function' and (not isexecutorclosure or not isexecutorclosure(obj)) then
                    local uvs = getupvalues(obj)
                    for _, val in pairs(uvs) do
                        if type(val) == 'table' and rawget(val, 'FireRate') ~= nil then
                            local toolName = rawget(val, 'ToolName') or rawget(val, 'Name')
                            local orig = toolName and originalFireRates[toolName]
                            local baseRate = orig and orig.fireRate or 0.1
                            if toolName == 'Remington 870' then
                                if orig then
                                    val.FireRate = orig.fireRate
                                    val.AutoFire = orig.auto
                                end
                            elseif isEnabled then
                                val.FireRate = calculateModifiedFireRate(toolName, baseRate)
                                if forceAuto then
                                    val.AutoFire = true
                                end
                            else
                                if orig then
                                    val.FireRate = orig.fireRate
                                    val.AutoFire = orig.auto
                                end
                            end
                        end
                    end
                end
            end
        end)
    end

    local function updateAllGunsFireRate()
        local bp = LP:FindFirstChild('Backpack')
        if bp then
            for _, child in bp:GetChildren() do
                patchToolFireRate(child)
            end
        end
        local char = LP.Character
        if char then
            for _, child in char:GetChildren() do
                patchToolFireRate(child)
            end
        end
        updateGunControllerInternal()
    end

    Toggles.FireRateChanger:OnChanged(updateAllGunsFireRate)
    Options.FireRateMode:OnChanged(updateAllGunsFireRate)
    Options.FireRateMultiplier:OnChanged(updateAllGunsFireRate)
    Options.CustomFireRate:OnChanged(updateAllGunsFireRate)
    Toggles.AlwaysAutomatic:OnChanged(updateAllGunsFireRate)
    Toggles.FireRateApplyManual:OnChanged(updateAllGunsFireRate)

    local bp = LP:FindFirstChild('Backpack')
    if bp then
        bp.ChildAdded:Connect(patchToolFireRate)
    end
    if LP.Character then
        LP.Character.ChildAdded:Connect(patchToolFireRate)
    end
    LP.CharacterAdded:Connect(function(char)
        char.ChildAdded:Connect(patchToolFireRate)
        local newBp = LP:WaitForChild('Backpack', 5)
        if newBp then
            newBp.ChildAdded:Connect(patchToolFireRate)
        end
        task.delay(1, updateAllGunsFireRate)
    end)
end

local gunConfigs = {
    ['AK-47']        = { fireRate=0.1,  auto=true,  range=1100, reloadTime=2,   projectiles=1, behavior='Standard', maxAmmo=30 },
    ['M4A1']         = { fireRate=0.09, auto=true,  range=1100, reloadTime=2,   projectiles=1, behavior='Standard', maxAmmo=30 },
    ['FAL']          = { fireRate=0.095,auto=true,  range=1100, reloadTime=2,   projectiles=1, behavior='Standard', maxAmmo=20 },
    ['MP5']          = { fireRate=0.1,  auto=true,  range=1100, reloadTime=2,   projectiles=1, behavior='Standard', maxAmmo=30 },
    ['M9']           = { fireRate=0.12, auto=false, range=1500, reloadTime=2,   projectiles=1, behavior='Standard', maxAmmo=15 },
    ['Revolver']     = { fireRate=0.3,  auto=false, range=1500, reloadTime=3,   projectiles=1, behavior='Standard', maxAmmo=6 },
    ['M700']         = { fireRate=0.2,  auto=false, range=1300, reloadTime=3,   projectiles=1, behavior='Sniper',    chargeTime=0.3, storedAmmo=15, maxAmmo=1 },
    ['Remington 870']= { fireRate=0.7,  auto=false, range=350,  reloadTime=2.0, projectiles=5, behavior='Shotgun',  maxAmmo=6 },
    ['Taser']        = { fireRate=0.1,  auto=false, range=52,   reloadTime=3.4, projectiles=1, behavior='Taser',     chargeTime=0.15, maxAmmo=1 },
}

getConfig = function(tool)
    if not tool then return nil end
    local cfg = gunConfigs[tool.Name]
    if not cfg then
        cfg = {
            fireRate = tool:GetAttribute('FireRate') or 0.1,
            auto = tool:GetAttribute('AutoFire'),
            range = tool:GetAttribute('Range') or 1100,
            reloadTime = tool:GetAttribute('ReloadTime') or 2,
            projectiles = tool:GetAttribute('ProjectileCount') or 1,
            behavior = tool:GetAttribute('Behavior') or 'Standard',
            chargeTime = tool:GetAttribute('ChargeTime'),
            storedAmmo = tool:GetAttribute('MaxStoredAmmo') or tool:GetAttribute('StoredAmmo'),
            maxAmmo = tool:GetAttribute('MaxAmmo') or 30,
        }
        if cfg.auto == nil then cfg.auto = true end
    else
        if not cfg.maxAmmo then
            cfg.maxAmmo = tool:GetAttribute('MaxAmmo') or 30
        end
    end
    return cfg
end

local hitsoundIds = {
    ['Fatality'] = 115982072912004,
    ['Skeet'] = 83717596220569,
    ['Bell'] = 83641156499511,
    ['COD'] = 77082587278347,
    ['Metal'] = 2868331684,
    ['TF2 Critical'] = 6405267300,
    ['TF2'] = 118731928809041,
    ['Rust'] = 121566025787365,
    ['Neverlose'] = 2866718318,
    ['NL'] = 82938206376993,
}

local playHitsound = nil
local playKillsound = nil
do
    local lastHitsoundTick = 0
    local lastKillsoundTick = 0

    playHitsound = function(ignoreToggle)
        if not ignoreToggle and not (Toggles.Hitsound and Toggles.Hitsound.Value) then return end
        local sName = Options.HitsoundSelect and Options.HitsoundSelect.Value
        local id = hitsoundIds[sName]
        if id then
            local now = tick()
            if not ignoreToggle and (now - lastHitsoundTick) < 0.04 then return end
            lastHitsoundTick = now

            local vol = ((Options.HitsoundVolume and Options.HitsoundVolume.Value) or 60) / 100
            local snd = Instance.new('Sound')
            snd.Name = 'Hitsound'
            snd.SoundId = 'rbxassetid://' .. id
            snd.Volume = math.clamp(vol, 0.05, 1)
            snd.Parent = workspace
            snd:Play()
            Debris:AddItem(snd, 2)
        end
    end

    playKillsound = function(ignoreToggle)
        if not ignoreToggle and not (Toggles.Killsound and Toggles.Killsound.Value) then return end
        local sName = Options.KillsoundSelect and Options.KillsoundSelect.Value
        local id = hitsoundIds[sName]
        if id then
            local now = tick()
            if not ignoreToggle and (now - lastKillsoundTick) < 0.08 then return end
            lastKillsoundTick = now

            local vol = ((Options.KillsoundVolume and Options.KillsoundVolume.Value) or 80) / 100
            local snd = Instance.new('Sound')
            snd.Name = 'Killsound'
            snd.SoundId = 'rbxassetid://' .. id
            snd.Volume = math.clamp(vol, 0.05, 1)
            snd.Parent = workspace
            snd:Play()
            Debris:AddItem(snd, 2)
        end
    end
end

local function onDamageConfirmed(player)
    playHitsound()
end

-- ====================== HITMARKERS ======================
local spawnHitmarker = nil
local cleanupHitmarkers = nil

do
    local hitmarkerLines = {}
    for i = 1, 4 do
        local l = Drawing.new('Line')
        l.Visible = false
        l.Thickness = 1.5
        l.Transparency = 1
        l.Color = Color3.new(1, 1, 1)
        l.ZIndex = 50
        table.insert(hitmarkerLines, l)
    end

    local hmState = {
        active = false,
        startTime = 0,
        isCrit = false,
        isTaser = false,
        hitPos = nil,
    }

    spawnHitmarker = function(isCrit, isTaser, hitPos)
        if not (Toggles.Hitmarkers and Toggles.Hitmarkers.Value) then return end
        hmState.active = true
        hmState.startTime = tick()
        hmState.isCrit = isCrit
        hmState.isTaser = isTaser
        hmState.hitPos = hitPos or (Camera and Camera.CFrame.Position + Camera.CFrame.LookVector * 10)
    end

    local function hideHitmarker()
        for i = 1, 4 do
            hitmarkerLines[i].Visible = false
        end
    end

    local function updateHitmarkers()
        if not (Toggles.Hitmarkers and Toggles.Hitmarkers.Value) or not hmState.active then
            hideHitmarker()
            return
        end

        local dur = Options.HitmarkerDuration and Options.HitmarkerDuration.Value or 0.35
        local elapsed = tick() - hmState.startTime
        if elapsed >= dur then
            hmState.active = false
            hideHitmarker()
            return
        end

        local centerScreen
        local mode = Options.HitmarkerMode and Options.HitmarkerMode.Value or 'Weapon Crosshair'
        if mode == '3D Hit Position' and hmState.hitPos then
            local sp, onScreen = Camera:WorldToViewportPoint(hmState.hitPos)
            if not onScreen or sp.Z <= 0 then
                hideHitmarker()
                return
            end
            centerScreen = Vector2.new(sp.X, sp.Y)
        elseif mode == 'Screen Center' then
            centerScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        else -- 'Weapon Crosshair'
            local crosshairPos = nil
            pcall(function()
                if DefaultCursor and DefaultCursor.Visible and DefaultCursor.Parent and DefaultCursor.Parent.Visible then
                    local inset = game:GetService('GuiService'):GetGuiInset()
                    crosshairPos = DefaultCursor.AbsolutePosition + inset + (DefaultCursor.AbsoluteSize / 2)
                end
            end)
            centerScreen = crosshairPos or UserInputService:GetMouseLocation()
        end

        local progress = elapsed / dur
        local alpha = math.clamp(1 - progress, 0, 1)

        local anim = Options.HitmarkerAnimation and Options.HitmarkerAnimation.Value or 'Expand & Fade'
        local baseLen = Options.HitmarkerSize and Options.HitmarkerSize.Value or 8
        local baseGap = Options.HitmarkerGap and Options.HitmarkerGap.Value or 5
        local thick = Options.HitmarkerThickness and Options.HitmarkerThickness.Value or 1.5

        local curGap = baseGap
        local curLen = baseLen

        if anim == 'Expand & Fade' then
            curGap = baseGap + progress * 6
        elseif anim == 'Bounce' then
            local bounce = math.sin(progress * math.pi) * 4
            curGap = baseGap + bounce
            curLen = baseLen + bounce * 0.5
        end

        local col = Options.HitmarkerColor and Options.HitmarkerColor.Value or Color3.fromRGB(255, 255, 255)
        if hmState.isTaser then
            col = Options.HitmarkerTaserCol and Options.HitmarkerTaserCol.Value or Color3.fromRGB(0, 230, 255)
        elseif hmState.isCrit and (Toggles.HitmarkerCritColor == nil or Toggles.HitmarkerCritColor.Value) then
            col = Options.HitmarkerCritCol and Options.HitmarkerCritCol.Value or Color3.fromRGB(255, 45, 45)
        end

        if Toggles.HitmarkerRainbow and Toggles.HitmarkerRainbow.Value then
            col = Color3.fromHSV((tick() * 1.5) % 1, 0.9, 1)
        end

        local cx, cy = centerScreen.X, centerScreen.Y

        hitmarkerLines[1].From = Vector2.new(cx - curGap - curLen, cy - curGap - curLen)
        hitmarkerLines[1].To = Vector2.new(cx - curGap, cy - curGap)

        hitmarkerLines[2].From = Vector2.new(cx + curGap + curLen, cy - curGap - curLen)
        hitmarkerLines[2].To = Vector2.new(cx + curGap, cy - curGap)

        hitmarkerLines[3].From = Vector2.new(cx - curGap - curLen, cy + curGap + curLen)
        hitmarkerLines[3].To = Vector2.new(cx - curGap, cy + curGap)

        hitmarkerLines[4].From = Vector2.new(cx + curGap + curLen, cy + curGap + curLen)
        hitmarkerLines[4].To = Vector2.new(cx + curGap, cy + curGap)

        for i = 1, 4 do
            hitmarkerLines[i].Thickness = thick
            hitmarkerLines[i].Color = col
            hitmarkerLines[i].Transparency = alpha
            hitmarkerLines[i].Visible = true
        end
    end

    local hmConn = RunService.RenderStepped:Connect(updateHitmarkers)

    cleanupHitmarkers = function()
        if hmConn then
            hmConn:Disconnect()
            hmConn = nil
        end
        for i = 1, 4 do
            pcall(function() hitmarkerLines[i]:Remove() end)
        end
    end
end

-- ====================== HIT NUMBERS (DAMAGE INDICATORS) ======================
local activeHitNumbers = {}
local spawnHitNumber

do

local fontMap = {
    ['UI'] = 0,
    ['System'] = 1,
    ['Plex'] = 2,
    ['Monospace'] = 3,
}

local function getHitNumberSpawnPos(player, char)
    local hitPos = lastShotInfo.hitPos
    if hitPos and lastShotInfo.targetChar == char then
        return hitPos + Vector3.new((math.random() - 0.5) * 1.0, (math.random() - 0.5) * 0.6, (math.random() - 0.5) * 1.0)
    end
    local head = char and char:FindFirstChild('Head')
    local hrp = char and char:FindFirstChild('HumanoidRootPart')
    local base = head or hrp
    if base then
        return base.Position + Vector3.new((math.random() - 0.5) * 1.4, 1.2 + (math.random() - 0.5) * 0.5, (math.random() - 0.5) * 1.4)
    end
    return Vector3.zero
end

spawnHitNumber = function(player, value, isCrit, isTaser)
    if not Toggles.HitNumbers or not Toggles.HitNumbers.Value then return end
    local char = player and player.Character
    if not char then return end

    local spawnPos = getHitNumberSpawnPos(player, char)
    local text = tostring(value)
    if not isTaser and type(value) == 'number' then
        text = "-" .. tostring(value)
    end

    local drawing = Drawing.new('Text')
    drawing.Text = text
    drawing.Center = true
    drawing.Outline = true
    drawing.OutlineColor = Color3.new(0, 0, 0)
    local fontName = (Options.HitNumberFont and Options.HitNumberFont.Value) or 'Plex'
    drawing.Font = fontMap[fontName] or 2
    drawing.Visible = false
    drawing.ZIndex = 40

    local baseSize = (Options.HitNumberSize and Options.HitNumberSize.Value) or 18
    if isCrit then
        baseSize = baseSize * 1.3
    end

    local col = (Options.HitNumberColor and Options.HitNumberColor.Value) or Color3.fromRGB(255, 235, 100)
    if isTaser then
        col = (Options.HitNumberTaserCol and Options.HitNumberTaserCol.Value) or Color3.fromRGB(0, 230, 255)
    elseif isCrit and (not Toggles.HitNumberCritColor or Toggles.HitNumberCritColor.Value) then
        col = (Options.HitNumberCritCol and Options.HitNumberCritCol.Value) or Color3.fromRGB(255, 50, 50)
    end

    local animStyle = (Options.HitNumberAnimation and Options.HitNumberAnimation.Value) or 'Pop & Bounce'
    local duration = (Options.HitNumberDuration and Options.HitNumberDuration.Value) or 1.0

    local randAngle = math.random() * math.pi * 2
    local randSpread = math.random() * 2.5 + 1.2
    local vx = math.cos(randAngle) * randSpread
    local vz = math.sin(randAngle) * randSpread
    local vy = math.random() * 3 + 5.5

    local velocity = Vector3.new(vx, vy, vz)
    local gravity = Vector3.new(0, -13, 0)

    if animStyle == 'Scatter (3D)' then
        velocity = Vector3.new(math.cos(randAngle) * (randSpread + 3.5), vy + 2.5, math.sin(randAngle) * (randSpread + 3.5))
        gravity = Vector3.new(0, -17, 0)
    elseif animStyle == 'Float Up' then
        velocity = Vector3.new(vx * 0.25, 4.0, vz * 0.25)
        gravity = Vector3.zero
    elseif animStyle == 'Rise & Fade' then
        velocity = Vector3.new(0, 3.0, 0)
        gravity = Vector3.zero
    end

    table.insert(activeHitNumbers, {
        drawing = drawing,
        startPos = spawnPos,
        velocity = velocity,
        gravity = gravity,
        startTime = tick(),
        duration = duration,
        baseSize = baseSize,
        color = col,
        text = text,
        animStyle = animStyle,
        seed = math.random(),
    })
end

local function updateHitNumbers()
    if #activeHitNumbers == 0 then return end
    local now = tick()
    local cam = workspace.CurrentCamera
    if not cam then return end

    local i = 1
    while i <= #activeHitNumbers do
        local hn = activeHitNumbers[i]
        local elapsed = now - hn.startTime
        local progress = elapsed / hn.duration

        if progress >= 1 then
            pcall(function() hn.drawing:Remove() end)
            table.remove(activeHitNumbers, i)
        else
            local currentWorldPos = hn.startPos
            local animMode = hn.animStyle

            if animMode == 'Pop & Bounce' then
                local t = elapsed
                currentWorldPos = hn.startPos + hn.velocity * t + 0.5 * hn.gravity * (t * t)
            elseif animMode == 'Float Up' then
                local riseDist = 4.2 * (1 - math.exp(-2.5 * elapsed))
                currentWorldPos = hn.startPos + Vector3.new(hn.velocity.X * elapsed * 0.5, riseDist, hn.velocity.Z * elapsed * 0.5)
            elseif animMode == 'Scatter (3D)' then
                local t = elapsed
                currentWorldPos = hn.startPos + hn.velocity * t + 0.5 * hn.gravity * (t * t)
            else -- 'Rise & Fade'
                currentWorldPos = hn.startPos + Vector3.new(0, 2.5 * elapsed, 0)
            end

            local screenPos, onScreen = cam:WorldToViewportPoint(currentWorldPos)

            if onScreen and screenPos.Z > 0 then
                local currentSize = hn.baseSize
                if progress < 0.2 then
                    local p = progress / 0.2
                    currentSize = hn.baseSize * (1 + 0.45 * math.sin(p * math.pi))
                else
                    currentSize = hn.baseSize * (1 - (progress - 0.2) * 0.15)
                end

                local alpha = 1
                if progress > 0.55 then
                    alpha = math.clamp((1 - progress) / 0.45, 0, 1)
                end

                local col = hn.color
                if Toggles.HitNumberRainbow and Toggles.HitNumberRainbow.Value then
                    local hue = (tick() * 0.8 + hn.seed) % 1
                    col = Color3.fromHSV(hue, 0.85, 1)
                end

                hn.drawing.Text = hn.text
                hn.drawing.Size = math.max(10, math.floor(currentSize))
                hn.drawing.Position = Vector2.new(screenPos.X, screenPos.Y)
                hn.drawing.Color = col
                hn.drawing.Transparency = alpha
                hn.drawing.Visible = true
            else
                hn.drawing.Visible = false
            end

            i = i + 1
        end
    end
end

RunService.RenderStepped:Connect(updateHitNumbers)


end

-- Real hit confirmation: listen to all players' Humanoid.HealthChanged and Taser stun
local victimHealths = setmetatable({}, { __mode = 'k' })
local lastTaserHitNum = 0

local function hookDamageTracker(player)
    if player == LP then return end
    local function onChar(char)
        local hum = char:WaitForChild('Humanoid', 5)
        if not hum then return end
        victimHealths[hum] = hum.Health

        hum.HealthChanged:Connect(function(newHealth)
            local prevHealth = victimHealths[hum] or newHealth
            victimHealths[hum] = newHealth
            if newHealth < prevHealth then
                local now = tick()
                local attackData = lastShotInfo.recentAttacks and lastShotInfo.recentAttacks[player]
                local isOurHit = (attackData and (now - attackData.tick) <= 1.25)
                    or (lastShotInfo.targetPlayer == player and (now - lastShotInfo.tick) <= 1.25)
                    or ((now - (lastShotInfo.lastAttackTick or 0)) <= 0.65)

                if isOurHit then
                    if _G.WXAntiDodge then pcall(_G.WXAntiDodge.OnHit, player) end
                    if _G.BoarsResolverConfirmHit then pcall(_G.BoarsResolverConfirmHit, player) end
                    local isKill = (newHealth <= 0 and prevHealth > 0)
                    if isKill and Toggles.Killsound and Toggles.Killsound.Value then
                        if not hum:GetAttribute('KillSoundFired') then
                            hum:SetAttribute('KillSoundFired', true)
                            playKillsound()
                        end
                    else
                        onDamageConfirmed(player)
                    end

                    local dmg = math.round(prevHealth - newHealth)
                    if dmg <= 0 then dmg = 1 end
                    local hitPart = (attackData and attackData.part) or lastShotInfo.targetPart
                    local hitPos = (attackData and attackData.pos) or lastShotInfo.hitPos
                    local isHeadShot = (hitPart and hitPart.Name == 'Head')
                    local isHead = isHeadShot or isKill

                    if _G.BoarsAddKillfeed then
                        local dist = 0
                        local root = LP.Character and LP.Character:FindFirstChild('HumanoidRootPart')
                        local vRoot = char and char:FindFirstChild('HumanoidRootPart')
                        if root and vRoot then
                            dist = math.round((root.Position - vRoot.Position).Magnitude)
                        end
                        local wName = (attackData and attackData.weapon) or lastShotInfo.toolName or 'Gun'
                        if isKill then
                            if not hum:GetAttribute('KillfeedFired') then
                                hum:SetAttribute('KillfeedFired', true)
                                _G.BoarsAddKillfeed(LP, player, wName, isHeadShot, dist)
                            end
                        else
                            -- 命中播报：非致命命中同样推一条，带本次伤害
                            _G.BoarsAddKillfeed(LP, player, wName, isHeadShot, dist, { kind = 'hit', damage = dmg })
                        end
                    end

                    spawnHitNumber(player, dmg, isHead, false)
                    if spawnHitmarker then
                        spawnHitmarker(isHead, false, hitPos)
                    end
                end
            end
        end)

        hum.Died:Connect(function()
            local now = tick()
            local attackData = lastShotInfo.recentAttacks and lastShotInfo.recentAttacks[player]
            local isOurKill = (attackData and (now - attackData.tick) <= 1.5)
                or (lastShotInfo.targetPlayer == player and (now - lastShotInfo.tick) <= 1.5)
                or ((now - (lastShotInfo.lastAttackTick or 0)) <= 0.9)

            if isOurKill then
                if not hum:GetAttribute('KillSoundFired') then
                    hum:SetAttribute('KillSoundFired', true)
                    playKillsound()
                end
            end
        end)

        hum:GetPropertyChangedSignal('WalkSpeed'):Connect(function()
            if hum.WalkSpeed == 0 then
                local now = tick()
                if lastShotInfo.targetPlayer == player and lastShotInfo.behavior == 'Taser' and (now - lastShotInfo.tick) <= 0.65 then
                    onDamageConfirmed(player)
                    if (now - lastTaserHitNum) > 0.5 then
                        lastTaserHitNum = now
                        spawnHitNumber(player, '⚡ 被电击', false, true)
                    end
                    if spawnHitmarker then
                        spawnHitmarker(false, true, lastShotInfo.hitPos)
                    end
                end
            end
        end)

        local function checkTrack(track)
            if track.Animation and string.find(track.Animation.AnimationId, '287112271') then
                local now = tick()
                if lastShotInfo.targetPlayer == player and lastShotInfo.behavior == 'Taser' and (now - lastShotInfo.tick) <= 0.65 then
                    onDamageConfirmed(player)
                    if (now - lastTaserHitNum) > 0.5 then
                        lastTaserHitNum = now
                        spawnHitNumber(player, '⚡ 被电击', false, true)
                    end
                    if spawnHitmarker then
                        spawnHitmarker(false, true, lastShotInfo.hitPos)
                    end
                end
            end
        end

        local animator = hum:FindFirstChildOfClass('Animator')
        if animator then
            animator.AnimationPlayed:Connect(checkTrack)
        else
            hum.ChildAdded:Connect(function(c)
                if c:IsA('Animator') then
                    c.AnimationPlayed:Connect(checkTrack)
                end
            end)
        end
    end

    if player.Character then task.spawn(onChar, player.Character) end
    player.CharacterAdded:Connect(function(c) task.spawn(onChar, c) end)
end

for _, p in Players:GetPlayers() do hookDamageTracker(p) end
Players.PlayerAdded:Connect(hookDamageTracker)

isAlive = function(player)
    local char = player.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass('Humanoid')
    if not hum or hum.Health <= 0 then return false end
    if player ~= LP and char:FindFirstChildOfClass('ForceField') then
        return false
    end
    return true
end

-- Taser stun tracking (3.5s duration in Prison Life)
local tasedPlayers = setmetatable({}, { __mode = 'k' })

local function isPlayerTased(player)
    local t = tasedPlayers[player]
    if t and (tick() - t) < 3.5 then return true end
    local char = player.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass('Humanoid')
    if hum and (hum.WalkSpeed <= 1 or hum.PlatformStand) then return true end
    return false
end

-- Threat classification: Lethal threat vs Ordinary inmate
local function isLethalThreat(targetPlayer)
    if targetPlayer == LP then return false end
    if not isAlive(targetPlayer) then
        -- 反自动躲避：无敌目标仍算威胁（锁定但不开火），什么时候打交给开火门控
        local lockable = _G.WXAntiDodge and _G.WXAntiDodge.IsLockable and _G.WXAntiDodge.IsLockable(targetPlayer)
        if not lockable then return false end
    end
    if not isAlive(LP) then return false end

    -- 队伍检测：同队 / 同职务（含未同步的阵营）一律不视为可攻击目标
    if Toggles.RageTeamCheck and Toggles.RageTeamCheck.Value and WXTeam.IsTeammate(targetPlayer, true) then
        return false
    end

    local myTeam = LP.Team
    local theirTeam = targetPlayer.Team
    if myTeam == theirTeam then return false end

    if myTeam == Teams.Guards then
        if theirTeam == Teams.Criminals or (theirTeam and theirTeam.Name == 'Criminals') then
            return true
        end
        if theirTeam == Teams.Inmates and targetPlayer.Character and targetPlayer.Character:GetAttribute('Hostile') then
            return true
        end
        return false
    elseif myTeam == Teams.Criminals then
        if theirTeam == Teams.Guards then
            return true
        end
        if theirTeam == Teams.Inmates then
            local attackInmates = (Toggles.RageBotTargetInmatesAsCrim and Toggles.RageBotTargetInmatesAsCrim.Value)
            return attackInmates == true
        end
        return true
    else
        if theirTeam == Teams.Guards then
            return true
        end
        if theirTeam == Teams.Criminals then
            local attackCrims = (Toggles.RageBotTargetInmatesAsCrim and Toggles.RageBotTargetInmatesAsCrim.Value)
            return attackCrims == true
        end
        return true
    end
end

local knownGunNames = {
    ['AK-47']=true, ['M4A1']=true, ['MP5']=true, ['M9']=true,
    ['Revolver']=true, ['Remington 870']=true, ['M700']=true,
    ['FAL']=true, ['Taser']=true,
}

local function getInventoryGun(name)
    if LP.Character then
        local t = LP.Character:FindFirstChild(name)
        if t and t:IsA('Tool') then return t end
    end
    local bp = LP:FindFirstChildOfClass('Backpack') or LP:FindFirstChild('Backpack')
    if bp then
        local t = bp:FindFirstChild(name)
        if t and t:IsA('Tool') then return t end
    end
    return nil
end

local function canBeDamaged(targetPlayer)
    return isLethalThreat(targetPlayer)
end

-- Quick threat checks
local function findQuickLethalThreat()
    local root = LP.Character and LP.Character:FindFirstChild('HumanoidRootPart')
    if not root then return nil end
    local myPos = root.Position
    local origin = getLagCompensatedOrigin()
    for _, p in Players:GetPlayers() do
        if isLethalThreat(p) then
            local char = p.Character
            local hrp = char and char:FindFirstChild('HumanoidRootPart')
            local head = char and char:FindFirstChild('Head')
            if hrp then
                local dist = (hrp.Position - myPos).Magnitude
                if dist <= 1200 then
                    if hasLineOfSight(origin, hrp.Position, p) or (head and hasLineOfSight(origin, head.Position, p)) then
                        return p
                    end
                end
            end
        end
    end
    return nil
end

-- Auto Detect Cheaters Background Engine
do
    local playerTrack = {}
    local cheaterRayParams = RaycastParams.new()
    cheaterRayParams.FilterType = Enum.RaycastFilterType.Exclude
    cheaterRayParams.IgnoreWater = true

    task.spawn(function()
        while true do
            task.wait(0.25)
            if Toggles.AutoDetectCheaters and Toggles.AutoDetectCheaters.Value then
                local now = tick()
                local myChar = LP.Character
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LP and p.Parent == Players then
                        local char = p.Character
                        local hrp = char and char:FindFirstChild('HumanoidRootPart')
                        local hum = char and char:FindFirstChildOfClass('Humanoid')

                        if hrp and hum and hum.Health > 0 and isAlive(p) then
                            local inVeh = isInVehicle(p)
                            local pos = hrp.Position
                            local vel = hrp.AssemblyLinearVelocity or hrp.Velocity

                            local track = playerTrack[p]
                            if not track or track.char ~= char then
                                track = {
                                    char = char,
                                    lastPos = pos,
                                    lastTick = now,
                                    airTime = 0,
                                    speedStrikes = 0,
                                    lastNotify = 0,
                                    wasInVeh = inVeh,
                                }
                                playerTrack[p] = track
                            else
                                local dt = now - track.lastTick
                                if dt >= 0.15 and dt <= 1.5 then
                                    local flagReason = nil

                                    -- 1. Void / Underground godmode check
                                    if pos.Y < -65 then
                                        flagReason = '虚空 / 地下绕过'
                                    end

                                    -- 2. Teleportation check (instant distance skip)
                                    local totalDist = (pos - track.lastPos).Magnitude
                                    if not flagReason and not inVeh and not track.wasInVeh and pos.Y > -50 and track.lastPos.Y > -50 then
                                        if totalDist > 140 and dt <= 0.6 then
                                            flagReason = '瞬移'
                                        end
                                    end

                                    -- 3. Speedhack check (horizontal displacement speed > 110 studs/s)
                                    if not flagReason and not inVeh and not track.wasInVeh then
                                        local horizDist = Vector2.new(pos.X - track.lastPos.X, pos.Z - track.lastPos.Z).Magnitude
                                        local horizSpeed = horizDist / dt
                                        if horizSpeed > 110 then
                                            track.speedStrikes = track.speedStrikes + 1
                                            if track.speedStrikes >= 2 or horizSpeed > 160 then
                                                flagReason = '加速（' .. math.floor(horizSpeed) .. ' 格/秒）'
                                            end
                                        else
                                            track.speedStrikes = math.max(0, track.speedStrikes - 1)
                                        end
                                    end

                                    -- 4. Air Fly / Zero-G Hover check
                                    if not flagReason and not inVeh and pos.Y > -30 then
                                        local filterList = { char }
                                        if myChar then table.insert(filterList, myChar) end
                                        cheaterRayParams.FilterDescendantsInstances = filterList
                                        local groundRay = Workspace:Raycast(pos, Vector3.new(0, -32, 0), cheaterRayParams)
                                        if not groundRay then
                                            if vel.Y > -8 then
                                                track.airTime = track.airTime + dt
                                                if track.airTime >= 2.5 then
                                                    flagReason = '飞行 / 空中悬停'
                                                end
                                            else
                                                track.airTime = 0
                                            end
                                        else
                                            track.airTime = 0
                                        end
                                    else
                                        track.airTime = 0
                                    end

                                    -- Flagging and Notification
                                    if flagReason then
                                        local isNew = not detectedCheaters[p]
                                        detectedCheaters[p] = { reason = flagReason, time = now }
                                        if (isNew or (now - track.lastNotify) > 15) and Toggles.CheaterNotify and Toggles.CheaterNotify.Value then
                                            track.lastNotify = now
                                            pcall(function()
                                                Library:Notify(string.format('[检测到脚本] %s：%s', p.DisplayName or p.Name, flagReason), 5)
                                            end)
                                        end
                                    end
                                end

                                track.lastPos = pos
                                track.lastTick = now
                                track.wasInVeh = inVeh
                            end
                        end
                    end
                end
            end
        end
    end)

    Players.PlayerRemoving:Connect(function(p)
        detectedCheaters[p] = nil
        playerTrack[p] = nil
    end)

    if Toggles.AutoDetectCheaters then
        Toggles.AutoDetectCheaters:OnChanged(function()
            if not Toggles.AutoDetectCheaters.Value then
                table.clear(detectedCheaters)
            end
        end)
    end
end

local function findRageBotTargets(scanRange)
    local root = LP.Character and LP.Character:FindFirstChild('HumanoidRootPart')
    if not root then return nil, nil, nil end
    local myPos = root.Position
    local origin = getLagCompensatedOrigin()

    local prioritizeCheaters = Toggles.RageBotPrioritizeCheaters and Toggles.RageBotPrioritizeCheaters.Value
    local teamCheck = Toggles.RageTeamCheck and Toggles.RageTeamCheck.Value
    local bestCheater, bestCheaterDist, bestCheaterPart = nil, scanRange or 1500, nil
    local bestLethal, bestLethalDist, bestLethalPart = nil, scanRange or 1500, nil

    for _, player in Players:GetPlayers() do
        local char = player.Character
        if teamCheck and WXTeam.IsTeammate(player, true) then
            continue
        end
        if char and (isAlive(player) or (_G.WXAntiDodge and _G.WXAntiDodge.IsLockable and _G.WXAntiDodge.IsLockable(player))) then
            local hrp = char:FindFirstChild('HumanoidRootPart')
            local head = char:FindFirstChild('Head')
            if hrp then
                local dist = (hrp.Position - myPos).Magnitude
                local inVeh = isInVehicle(player)
                local hrpPos = hrp.Position
                local headPos = head and head.Position
                local targetPart = nil

                if inVeh then
                    if headPos and hasLineOfSight(origin, headPos, player) then
                        targetPart = head
                    elseif hasLineOfSight(origin, hrpPos, player) then
                        targetPart = hrp
                    end
                else
                    if hasLineOfSight(origin, hrpPos, player) then
                        targetPart = hrp
                    elseif headPos and hasLineOfSight(origin, headPos, player) then
                        targetPart = head
                    end
                end

                if targetPart then
                    local isLethal = isLethalThreat(player)
                    local isCheater = detectedCheaters[player] ~= nil

                    if prioritizeCheaters and isCheater and (isLethal or (player.Team ~= LP.Team and LP.Team ~= Teams.Guards)) then
                        if dist < bestCheaterDist then
                            bestCheaterDist = dist
                            bestCheater = player
                            bestCheaterPart = targetPart
                        end
                    end

                    if isLethal and dist < bestLethalDist then
                        bestLethalDist = dist
                        bestLethal = player
                        bestLethalPart = targetPart
                    end
                end
            end
        end
    end

    if bestCheater then
        return bestCheater, bestCheaterDist, bestCheaterPart
    end
    return bestLethal, bestLethalDist, bestLethalPart
end

-- 暴力模式：收集范围内所有可击杀目标（按距离排序，脚本优先）
local function findAllRageBotTargets(scanRange)
    local root = LP.Character and LP.Character:FindFirstChild('HumanoidRootPart')
    if not root then return {} end
    local myPos = root.Position
    local origin = getLagCompensatedOrigin()
    local prioritizeCheaters = Toggles.RageBotPrioritizeCheaters and Toggles.RageBotPrioritizeCheaters.Value
    local isBrutal = Toggles.RageBotBrutal and Toggles.RageBotBrutal.Value
    local teamCheck = Toggles.RageTeamCheck and Toggles.RageTeamCheck.Value
    local results = {}

    for _, player in Players:GetPlayers() do
        local char = player.Character
        if teamCheck and WXTeam.IsTeammate(player, true) then
            continue
        end
        if char and (isAlive(player) or (_G.WXAntiDodge and _G.WXAntiDodge.IsLockable and _G.WXAntiDodge.IsLockable(player))) then
            local hrp = char:FindFirstChild('HumanoidRootPart')
            local head = char:FindFirstChild('Head')
            if hrp then
                local dist = (hrp.Position - myPos).Magnitude
                if dist <= (scanRange or 1500) then
                    local inVeh = isInVehicle(player)
                    local hrpPos = hrp.Position
                    local headPos = head and head.Position
                    local targetPart = nil

                    if isBrutal then
                        -- 暴力模式：爆头优先
                        if headPos and hasLineOfSight(origin, headPos, player) then
                            targetPart = head
                        elseif hasLineOfSight(origin, hrpPos, player) then
                            targetPart = hrp
                        end
                    elseif inVeh then
                        if headPos and hasLineOfSight(origin, headPos, player) then
                            targetPart = head
                        elseif hasLineOfSight(origin, hrpPos, player) then
                            targetPart = hrp
                        end
                    else
                        if hasLineOfSight(origin, hrpPos, player) then
                            targetPart = hrp
                        elseif headPos and hasLineOfSight(origin, headPos, player) then
                            targetPart = head
                        end
                    end

                    if targetPart and (isLethalThreat(player) or (prioritizeCheaters and detectedCheaters[player] ~= nil)) then
                        table.insert(results, { player = player, dist = dist, part = targetPart })
                    end
                end
            end
        end
    end

    table.sort(results, function(a, b)
        if prioritizeCheaters then
            local ac = detectedCheaters[a.player] ~= nil
            local bc = detectedCheaters[b.player] ~= nil
            if ac ~= bc then return ac end
        end
        return a.dist < b.dist
    end)

    return results
end

local lastShotTick = 0

updateHudAmmo = function(tool, ammo, cfg)
    pcall(function()
        local hud = LP.PlayerGui and LP.PlayerGui:FindFirstChild('Home') and LP.PlayerGui.Home:FindFirstChild('hud')
        local gunFrame = hud and hud:FindFirstChild('BottomRightFrame') and hud.BottomRightFrame:FindFirstChild('GunFrame')
        local bulletsLabel = gunFrame and gunFrame:FindFirstChild('BulletsLabel')
        if bulletsLabel then
            if cfg and cfg.behavior == 'Sniper' then
                local stored = tool:GetAttribute('StoredAmmo') or 0
                bulletsLabel.Text = ammo .. " | " .. stored
            else
                local maxA = tool:GetAttribute('MaxAmmo') or (cfg and cfg.maxAmmo) or 0
                bulletsLabel.Text = ammo .. "/" .. maxA
            end
        end
    end)
end

-- ====================== 发包链路优化（Rage 命中一致性） ======================
-- 子弹包格式：ShootEvent:FireServer({ { origin, hitPos, hitPart }, ... })
-- 服务端在包到达时（约半个 RTT 之后）才结算，任何「开火瞬间快照」到那时都已过期。
-- 「打人有伤害有时没伤害」的四个根因：
--   1) 目标移动：hitPos 是旧快照，服务端结算时目标已走开 → 擦边/判空；
--   2) 自己移动：预测 origin 落进墙体，服务端从 origin 射线校验直接被挡；
--   3) 弹药失步：本地 Local_CurrentAmmo>0 但服务端 CurrentAmmo=0 → 整包静默丢弃；
--   4) 超速发包：同一把枪的包间隔小于服务端冷却 → 后续包排队/丢弃。
-- 注意：辅助对象全部挂 _G，不新增主 chunk local（避免 local 数量超限导致整个脚本编译失败）
_G.WXRagePacket = _G.WXRagePacket or {
    wallParams = RaycastParams.new(),          -- 预测点穿墙校验专用
    clock = setmetatable({}, { __mode = 'k' }), -- 每把枪的上次出包时间
}
_G.WXRagePacket.wallParams.FilterType = Enum.RaycastFilterType.Exclude
_G.WXRagePacket.wallParams.IgnoreWater = true

-- 目标部件的「服务端当前预测位置」：
-- 客户端观察值 + 速度 × 复制延迟（半 RTT + 复制插值缓冲），
-- 让包到达服务端时 hitPos 恰好追上目标的真实位置。
function _G.WXRagePacket.predictHitPos(part)
    local pos = part.Position
    local char = part.Parent
    local root = char and (char:FindFirstChild('HumanoidRootPart') or part)
    local vel = root and root.AssemblyLinearVelocity or Vector3.zero
    if vel.Magnitude < 1 then return pos end

    local delay = getNetworkPingSeconds() * 0.5 + 0.035
    local displacement = vel * delay
    if displacement.Magnitude > 6 then
        displacement = displacement.Unit * 6
    end
    local predicted = pos + displacement
    if displacement.Magnitude > 0.1 then
        -- 预测点不能穿过墙体：被挡就退回遮挡面前，保证服务端射线可达
        _G.WXRagePacket.wallParams.FilterDescendantsInstances = { char }
        local ok, hit = pcall(Workspace.Raycast, Workspace, pos, displacement, _G.WXRagePacket.wallParams)
        if ok and hit then
            predicted = hit.Position - displacement.Unit * 0.3
        end
    end
    return predicted
end

local function fire(tool, targetPart, cfg, instant)
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass('Humanoid')
    if (Toggles.RageBotDisableInVehicle == nil or Toggles.RageBotDisableInVehicle.Value) and (isInVehicle(LP) or (hum and hum.SeatPart)) then
        return false
    end

    local origin = getLagCompensatedOrigin()
    local muzzle = tool:FindFirstChild('Muzzle')
    local visualOrigin = muzzle and muzzle.Position or origin

    -- [弹药真相] 服务端 CurrentAmmo 才是结算依据；本地记数失步时整包都会被静默丢弃。
    -- 服务端没子弹 → 立刻停发并归零本地记数，让主循环下一轮直接走换弹。
    local serverAmmo = tool:GetAttribute('CurrentAmmo')
    if serverAmmo ~= nil and serverAmmo <= 0 then
        tool:SetAttribute('Local_CurrentAmmo', 0)
        updateHudAmmo(tool, 0, cfg)
        return false
    end

    local targetPos = targetPart.Position
    local targetPlayer = Players:GetPlayerFromCharacter(targetPart.Parent)

    if resolveTarget and Toggles.Resolver and Toggles.Resolver.Value and targetPlayer then
        targetPos, targetPart = resolveTarget(targetPlayer, targetPart, origin)
    end

    if not hasLineOfSight(origin, targetPos, targetPlayer) then
        if targetPlayer and targetPlayer.Character then
            local altPart = (targetPart.Name == 'Head') and targetPlayer.Character:FindFirstChild('HumanoidRootPart')
                or targetPlayer.Character:FindFirstChild('Head')
            if altPart and hasLineOfSight(origin, altPart.Position, targetPlayer) then
                targetPart = altPart
                targetPos = altPart.Position
            else
                return
            end
        else
            return
        end
    end

    -- 反自动躲避：被标记为自动躲避的目标按实测速度补提前量（视线判断用真实位置，只偏移命中点）
    if targetPlayer and _G.WXAntiDodge
        and not (Toggles.Resolver and Toggles.Resolver.Value) then
        local lead = _G.WXAntiDodge.GetLeadOffset(targetPlayer, getNetworkPingSeconds())
        if lead then targetPos = targetPos + lead end
    end

    local shootOrigin = origin

    -- ===== 单包多发 =====
    -- 旧逻辑：先发一次原包，再按毫秒间隔「重复 FireServer」若干次（多重发包），
    -- 双击连发再多发一次。服务端按到达顺序逐包处理，后发的包不是排队就是撞上
    -- 武器冷却 / 弹药校验被吞，命中率没提高，只把带宽和帧时间烧光了。
    -- 新逻辑：把需要重复的次数直接塞进同一个子弹表，一次 FireServer 全部送达，
    -- 服务端在同一帧内逐条射线结算，等于「一包多杀」，且没有包间延迟。
    local projectiles = cfg.projectiles or 1
    local extraBullets = 0
    if Toggles.RageMultiPacket and Toggles.RageMultiPacket.Value then
        extraBullets = extraBullets + math.floor((Options.RageMultiPacketCount and Options.RageMultiPacketCount.Value) or 3) - 1
    end
    if Toggles.DoubleTap and Toggles.DoubleTap.Value then
        local dtMode = (Options.DoubleTapWeapon and Options.DoubleTapWeapon.Value) or 'Remington 870 Only'
        if dtMode == 'All Guns' or (tool and tool.Name == 'Remington 870') then
            extraBullets = extraBullets + 1
        end
    end
    -- 反自动躲避：无敌刚结束的那一发直接打包补枪，一次 FireServer 全送出去
    if targetPlayer and _G.WXAntiDodge then
        local penalty = _G.WXAntiDodge.TakePenaltyShots(targetPlayer)
        if penalty > 0 then extraBullets = extraBullets + penalty end
    end
    -- 单包上限：超过 12 条射线服务端容易判定异常包直接丢弃，反而一发不中
    extraBullets = math.clamp(extraBullets, 0, math.max(0, 12 - projectiles))

    -- [发送前快照] 从选目标到真正出包之间目标随时可能移动；不刷新就发，
    -- 移动靶的 hitPos 永远落后服务端一个 RTT —— 这是命中时有时无的第一主因。
    if not targetPart or not targetPart.Parent then return false end
    if targetPlayer and not isAlive(targetPlayer) then return false end
    targetPos = _G.WXRagePacket.predictHitPos(targetPart)
    shootOrigin = getLagCompensatedOrigin()

    -- [节流防吞包] 同一把枪的出包间隔小于服务端冷却时，后续包会被排队或丢弃。
    -- 普通模式 fireRate 本身就是间隔；暴力模式保留 RageBrutalDelay 的节奏，
    -- 但叠加「ping 自适应最低间隔」（ping 越高自动放慢），宁可慢一点也不发空包。
    local minInterval = cfg.fireRate or 0.1
    if Toggles.RageBotBrutal and Toggles.RageBotBrutal.Value and Toggles.RageBot and Toggles.RageBot.Value then
        minInterval = (Options.RageBrutalDelay and Options.RageBrutalDelay.Value) or 0.01
        minInterval = math.max(minInterval, math.max(getNetworkPingSeconds() * 0.4, 0.03))
    end
    local waitMore = ((_G.WXRagePacket.clock[tool] or 0) + minInterval) - tick()
    if waitMore > 0 then
        task.wait(waitMore)
        -- 等待后所有快照再次过期：重刷一遍
        if not targetPart or not targetPart.Parent then return false end
        if targetPlayer and not isAlive(targetPlayer) then return false end
        targetPos = _G.WXRagePacket.predictHitPos(targetPart)
        shootOrigin = getLagCompensatedOrigin()
    end
    _G.WXRagePacket.clock[tool] = tick()

    -- [单包多发] 重复命中直接塞进同一个子弹表，一次 FireServer 全部送达。
    local t = {}
    for _ = 1, projectiles + extraBullets do
        t[#t + 1] = { shootOrigin, targetPos, targetPart }
    end

    isRageFiring = true
    pcall(function() ShootEvent:FireServer(t) end)
    isRageFiring = false
    -- 反躲避：记录这次出包，用于判定「空枪 / 受击瞬间位移」
    if targetPlayer and _G.WXAntiDodge then
        pcall(_G.WXAntiDodge.OnShot, targetPlayer)
    end
    -- 命中粒子已由下面的 GunTracers.createXxx 在 isOurBullet 分支内触发，
    -- 这里再调一次 = 每发凭空多生成一份粒子（默认 15 个 Part）

    -- 多重发包 / 双击连发已合并进上面的单包多发（见 t 的构建），
    -- 这里不再产生任何额外 FireServer，避免同一次射击发 2~4 个内容相同的包。


    -- Track shot for confirmed hit sound & hit numbers
    if lastShotInfo.recordAttack then
        lastShotInfo.recordAttack(targetPlayer, targetPart, targetPos, tool.Name)
        lastShotInfo.behavior = cfg.behavior
    else
        lastShotInfo.targetPlayer = targetPlayer
        lastShotInfo.targetChar = targetPart and targetPart.Parent
        lastShotInfo.targetPart = targetPart
        lastShotInfo.hitPos = targetPos
        lastShotInfo.tick = tick()
        lastShotInfo.toolName = tool.Name
        lastShotInfo.behavior = cfg.behavior
    end

    local curAmmo = tool:GetAttribute('Local_CurrentAmmo')
    if curAmmo == nil then
        curAmmo = tool:GetAttribute('CurrentAmmo') or tool:GetAttribute('MaxAmmo') or (cfg and cfg.maxAmmo) or 0
    end
    local newAmmo = math.max(0, curAmmo - 1)
    if Toggles.NoReload and Toggles.NoReload.Value then
        newAmmo = tool:GetAttribute('MaxAmmo') or (cfg and cfg.maxAmmo) or curAmmo
    end
    tool:SetAttribute('Local_CurrentAmmo', newAmmo)
    lastShotTick = tick()

    updateHudAmmo(tool, newAmmo, cfg)

    pcall(function()
        local handle = tool:FindFirstChild('Handle')
        if handle and handle:FindFirstChild('Flare') then
            handle.Flare.Enabled = true
            task.delay(0.05, function()
                if handle and handle:FindFirstChild('Flare') then
                    handle.Flare.Enabled = false
                end
            end)
        end
    end)

    if cfg.behavior == 'Sniper' then
        GunTracers.createSniper(visualOrigin, targetPos)
    elseif cfg.behavior == 'Taser' then
        GunTracers.createTaser(visualOrigin, targetPos)
    else
        GunTracers.createBullet(visualOrigin, targetPos)
    end

    local waitDelay = cfg.fireRate
    if Toggles.RageBotBrutal and Toggles.RageBotBrutal.Value and Toggles.RageBot and Toggles.RageBot.Value then
        waitDelay = 0.001
    elseif Toggles.FireRateChanger and Toggles.FireRateChanger.Value and (Toggles.FireRateApplyRage == nil or Toggles.FireRateApplyRage.Value) then
        waitDelay = calculateModifiedFireRate(tool.Name, cfg.fireRate)
    end
    -- instant = 暴力模式清场：这一发不占用帧时间，由外层循环统一控制节奏，
    -- 一次循环内把所有目标的包全部压在同一帧送出
    if instant ~= true then
        task.wait(waitDelay)
    end
    return true
end

-- ====================== 虚空安全保护（修复「虚空换弹直接死亡」） ======================
-- 死亡原因（客户端可解决的三种）：
--   1) 传送 Y 低于 Workspace.FallenPartsDestroyHeight 时，角色部件被引擎直接销毁 → 瞬间死亡；
--   2) 虚空底部有击杀砖 / 坠落判定，靠 Touched 触发；
--   3) 传送瞬间仍在自由落体，速度累积后被判定为坠落伤害。
-- 处理：深度自动钳制到销毁线以上、角色定身、关闭 CanTouch/CanCollide、并加血量看门狗。
-- 说明：挂到 _G 上，避免主 chunk 的 local 数量超限
_G.BoarsVoidGuard = {
    active = false,
    char = nil,
    hum = nil,
    root = nil,
    savedCF = nil,
    savedHealth = nil,
    savedMaxHealth = nil,
    savedAnchored = false,
    savedFpdh = nil,
    lastDepth = nil,
    diedInVoid = false,
    savedTouch = nil,
    savedCollide = nil,
    conn = nil,
}

do
    local G = _G.BoarsVoidGuard

    -- 引擎销毁线（FallenPartsDestroyHeight），读不到就用默认 -500
    local function destroyFloor()
        local fpdh = -500
        pcall(function() fpdh = tonumber(Workspace.FallenPartsDestroyHeight) or -500 end)
        return fpdh
    end

    -- 把用户设定的深度钳制到「安全区」：销毁线以上 70 格，且不低于 -400
    local clampNotified = false
    function G.safeY(y)
        local want = tonumber(y)
        if not want then want = -70 end
        local limit = math.max(destroyFloor() + 70, -400)
        if want < limit then
            want = limit
            if not clampNotified then
                clampNotified = true
                pcall(function()
                    Library:Notify({
                        Title = '虚空换弹',
                        Description = string.format('该地图的坠落销毁线较高，深度已自动限制到 %d Y', math.floor(want)),
                        Time = 6,
                    })
                end)
            end
        end
        return want
    end

    function G.enabled()
        return Toggles.VoidReloadGuard == nil or Toggles.VoidReloadGuard.Value
    end

    function G:begin(anchor)
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass('Humanoid')
        local root = char and char:FindFirstChild('HumanoidRootPart')
        if not char or not hum or not root or hum.Health <= 0 then return false end

        if self.active then
            if self.char ~= char then
                self:finish(false)
            else
                if anchor then pcall(function() root.Anchored = true end) end
                pcall(function() hum.PlatformStand = true end)
                return true
            end
        end

        self.active = true
        self.char, self.hum, self.root = char, hum, root
        self.savedCF = root.CFrame
        self.savedHealth = hum.Health
        self.savedMaxHealth = hum.MaxHealth
        self.savedAnchored = root.Anchored
        self.savedTouch = {}
        self.savedCollide = {}
        self.lastDepth = tonumber(Options.VoidReloadDepth and Options.VoidReloadDepth.Value) or -70

        -- 临时把本地「坠落销毁线」压到极低，避免引擎把角色部件直接删掉（删掉即判定死亡）
        self.savedFpdh = nil
        pcall(function()
            self.savedFpdh = Workspace.FallenPartsDestroyHeight
            Workspace.FallenPartsDestroyHeight = -100000
        end)

        -- 关掉触碰（击杀砖 Touched 不再触发）+ 碰撞（不会卡进地形）
        for _, d in ipairs(char:GetDescendants()) do
            if d:IsA('BasePart') then
                self.savedTouch[d] = d.CanTouch
                self.savedCollide[d] = d.CanCollide
                pcall(function() d.CanTouch = false end)
                pcall(function() d.CanCollide = false end)
            end
        end

        pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
        pcall(function() root.AssemblyAngularVelocity = Vector3.zero end)
        if anchor ~= false then pcall(function() root.Anchored = true end) end
        pcall(function() hum.PlatformStand = true end)
        pcall(function()
            if hum:GetState() ~= Enum.HumanoidStateType.Physics then
                hum:ChangeState(Enum.HumanoidStateType.Physics)
            end
        end)

        -- 血量看门狗：虚空期间掉血立即拉回，避免被地面击杀脚本偷血偷死
        if not self.conn then
            self.conn = RunService.Heartbeat:Connect(function()
                if not G.active then return end
                local h = G.hum
                if not h or not h.Parent then
                    pcall(function() G:finish(false) end)
                    return
                end
                if h.Health <= 0 then
                    G.diedInVoid = true
                    pcall(function() G:finish(true) end)
                    return
                end
                if G.savedMaxHealth and h.MaxHealth < G.savedMaxHealth - 0.01 then
                    pcall(function() h.MaxHealth = G.savedMaxHealth end)
                end
                if G.savedHealth and h.Health < G.savedHealth - 0.01 then
                    pcall(function() h.Health = G.savedHealth end)
                end
            end)
        end
        return true
    end

    function G:finish(restoreCF)
        if not self.active then return end
        local hum, root = self.hum, self.root
        self.active = false

        if self.conn then
            pcall(function() self.conn:Disconnect() end)
            self.conn = nil
        end

        if self.savedFpdh then
            pcall(function() Workspace.FallenPartsDestroyHeight = self.savedFpdh end)
            self.savedFpdh = nil
        end

        if self.savedTouch then
            for part, v in pairs(self.savedTouch) do
                if part and part.Parent then pcall(function() part.CanTouch = v end) end
            end
        end
        if self.savedCollide then
            for part, v in pairs(self.savedCollide) do
                if part and part.Parent then pcall(function() part.CanCollide = v end) end
            end
        end

        if root and root.Parent then
            if restoreCF and self.savedCF then
                pcall(function() root.CFrame = self.savedCF end)
            end
            pcall(function() root.Anchored = self.savedAnchored and true or false end)
            pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
            pcall(function() root.AssemblyAngularVelocity = Vector3.zero end)
        end

        if hum and hum.Parent and hum.Health > 0 then
            pcall(function()
                hum.PlatformStand = false
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end)
        end

        self.char, self.hum, self.root = nil, nil, nil
        self.savedCF, self.savedTouch, self.savedCollide = nil, nil, nil
    end

    -- 自适应：如果上一次虚空换弹把人送死了，下次自动调浅 30 格（最深到 -20）
    G.diedInVoid = false
    LP.CharacterAdded:Connect(function()
        task.delay(1, function()
            if not G.diedInVoid then return end
            G.diedInVoid = false
            local opt = Options.VoidReloadDepth
            if not opt then return end
            local cur = tonumber(opt.Value) or -70
            local nextY = math.min(cur + 30, -20)
            if nextY <= cur then return end
            opt:SetValue(nextY)
            pcall(function()
                Library:Notify({
                    Title = '虚空换弹',
                    Description = string.format('上次在虚空里死亡，深度已自动调浅到 %d Y', nextY),
                    Time = 6,
                })
            end)
        end)
    end)
end

local function doReload(tool, cfg)
    if not tool or not tool.Parent then return end
    if Toggles.NoReload and Toggles.NoReload.Value then
        pcall(function() FuncReload:InvokeServer() end)
        local nrMax = tool:GetAttribute('MaxAmmo') or (cfg and cfg.maxAmmo) or 0
        if nrMax and nrMax > 0 then
            tool:SetAttribute('Local_CurrentAmmo', nrMax)
        end
        tool:SetAttribute('Local_ReloadSession', 0)
        updateHudAmmo(tool, tool:GetAttribute('Local_CurrentAmmo') or nrMax, cfg)
        return
    end
    local maxAmmo = tool:GetAttribute('MaxAmmo') or (cfg and cfg.maxAmmo) or 0
    local curAmmo = tool:GetAttribute('Local_CurrentAmmo') or tool:GetAttribute('CurrentAmmo') or 0
    if curAmmo >= maxAmmo and curAmmo > 0 then
        tool:SetAttribute('Local_ReloadSession', 0)
        return
    end

    if (tool:GetAttribute('Local_ReloadSession') or 0) > 0 and curAmmo <= 0 then
        return
    end

    local reloadSession = tick()
    tool:SetAttribute('Local_ReloadSession', reloadSession)

    local isVoidReloadActive = (Toggles.VoidReload == nil or Toggles.VoidReload.Value)
    local char = LP.Character
    local root = char and char:FindFirstChild('HumanoidRootPart')
    local savedPreReloadCF = nil
    local reloadBV = nil

    if isVoidReloadActive and root and not (Toggles.VoidAura and Toggles.VoidAura.Value) then
        savedPreReloadCF = root.CFrame
        local voidY = _G.BoarsVoidGuard.safeY((Options.VoidReloadDepth and Options.VoidReloadDepth.Value) or -70)
        local voidCF = CFrame.new(savedPreReloadCF.X, voidY, savedPreReloadCF.Z)

        -- 先进入保护：定身 + 关触碰/碰撞 + 血量看护，再传送
        if _G.BoarsVoidGuard.enabled() then
            pcall(function() _G.BoarsVoidGuard:begin(true) end)
        end

        if not _G.BoarsVoidGuard.active then
            -- 保护不可用时退回原来的速度锁
            reloadBV = Instance.new('BodyVelocity')
            reloadBV.Name = 'CombatVoidReloadBV'
            reloadBV.MaxForce = Vector3.new(1e8, 1e8, 1e8)
            reloadBV.Velocity = Vector3.zero
            reloadBV.Parent = root
        end

        root.CFrame = voidCF
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end

    pcall(function()
        local hud = LP.PlayerGui and LP.PlayerGui:FindFirstChild('Home') and LP.PlayerGui.Home:FindFirstChild('hud')
        local gunFrame = hud and hud:FindFirstChild('BottomRightFrame') and hud.BottomRightFrame:FindFirstChild('GunFrame')
        local bulletsLabel = gunFrame and gunFrame:FindFirstChild('BulletsLabel')
        if bulletsLabel then bulletsLabel.Text = "..." end
    end)

    pcall(function()
        local handle = tool:FindFirstChild('Handle')
        local reloadSnd = handle and handle:FindFirstChild('ReloadSound')
        if reloadSnd then
            local clone = reloadSnd:Clone()
            clone.Parent = handle
            clone:Play()
            Debris:AddItem(clone, 5)
        end
    end)

    task.spawn(function()
        pcall(function() FuncReload:InvokeServer() end)
    end)

    local reloadDuration = cfg.reloadTime or tool:GetAttribute('ReloadTime') or 2
    if tool.Name == 'Remington 870' then
        reloadDuration = 2.0
    end

    local startTime = tick()
    while (tick() - startTime) < reloadDuration do
        if not tool or not tool.Parent or tool:GetAttribute('Local_ReloadSession') ~= reloadSession then
            break
        end
        local serverAmmo = tool:GetAttribute('CurrentAmmo')
        if serverAmmo and serverAmmo >= maxAmmo and serverAmmo > 0 then
            break
        end
        if isVoidReloadActive and root and root.Parent and savedPreReloadCF and not (Toggles.VoidAura and Toggles.VoidAura.Value) then
            local voidY = _G.BoarsVoidGuard.safeY((Options.VoidReloadDepth and Options.VoidReloadDepth.Value) or -70)
            root.CFrame = CFrame.new(savedPreReloadCF.X, voidY, savedPreReloadCF.Z)
            root.AssemblyLinearVelocity = Vector3.zero
            if _G.BoarsVoidGuard.active then
                pcall(function() root.Anchored = true end)
            end
        end
        task.wait(0.03)
    end

    if savedPreReloadCF and root and root.Parent and not (Toggles.VoidAura and Toggles.VoidAura.Value) then
        if _G.BoarsVoidGuard.active then
            -- 保护中：由保护模块统一还原位置、碰撞、触碰与站立状态
            pcall(function() _G.BoarsVoidGuard:finish(true) end)
        else
            root.CFrame = savedPreReloadCF
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
        if reloadBV and reloadBV.Parent then
            pcall(function() reloadBV:Destroy() end)
        end
    elseif savedPreReloadCF and _G.BoarsVoidGuard.active then
        pcall(function() _G.BoarsVoidGuard:finish(true) end)
    end

    if tool and tool.Parent and tool:GetAttribute('Local_ReloadSession') == reloadSession then
        if cfg.behavior == 'Sniper' then
            local stored = tool:GetAttribute('StoredAmmo') or 0
            if stored > 0 then
                tool:SetAttribute('Local_CurrentAmmo', 1)
                tool:SetAttribute('StoredAmmo', math.max(0, stored - 1))
            end
        else
            local sAmmo = tool:GetAttribute('CurrentAmmo')
            local finalAmmo = (sAmmo and sAmmo > 0) and sAmmo or maxAmmo
            tool:SetAttribute('Local_CurrentAmmo', finalAmmo)
        end
        tool:SetAttribute('Local_ReloadSession', 0)
        local cur = tool:GetAttribute('Local_CurrentAmmo') or maxAmmo
        updateHudAmmo(tool, cur, cfg)
    else
        pcall(function()
            if tool then tool:SetAttribute('Local_ReloadSession', 0) end
        end)
    end
end

-- ====================== 手动换弹 → 虚空换弹 ======================
-- 旧版虚空换弹只挂在脚本自己的换弹流程（Rage / 虚空光环）上，
-- 玩家自己按 R 换弹时根本不会触发，所以看起来「没效果」。
-- 这里独立监听玩家换弹：FuncReload 调用 / 弹匣打空 / HUD 换弹提示，
-- 换弹期间送进虚空，服务器弹药回满或超时后拉回原位。
do
    local VG = _G.BoarsVoidGuard
    local S = {
        active = false,
        tool = nil,
        startAt = 0,
        endAt = 0,
        lastAmmo = nil,
        savedCF = nil,
        savedAnchored = false,
        hudReloading = false,
        hudTimer = 0,
    }

    local function equippedGun()
        local char = LP.Character
        local tool = char and char:FindFirstChildOfClass('Tool')
        if not tool or not tool.Parent then return nil end
        if (gunConfigs and gunConfigs[tool.Name]) or tool:FindFirstChild('Muzzle') or tool:GetAttribute('ToolType') == 'Gun' then
            return tool
        end
        return nil
    end

    local function ammoNow(tool)
        local cur = tonumber(tool:GetAttribute('CurrentAmmo'))
        if cur == nil then cur = tonumber(tool:GetAttribute('Local_CurrentAmmo')) end
        local max = tonumber(tool:GetAttribute('MaxAmmo'))
        if not max and gunConfigs and gunConfigs[tool.Name] then
            max = gunConfigs[tool.Name].maxAmmo
        end
        return cur or 0, max or 0
    end

    local function reloadTimeOf(tool)
        local t = tonumber(tool:GetAttribute('ReloadTime'))
        if not t and gunConfigs and gunConfigs[tool.Name] then
            t = gunConfigs[tool.Name].reloadTime
        end
        if not t and tool.Name == 'Remington 870' then t = 2 end
        return math.clamp(t or 2, 0.4, 6)
    end

    local function stop()
        if not S.active then return end
        S.active = false
        S.tool = nil
        if VG.active then
            pcall(function() VG:finish(true) end)
        else
            local char = LP.Character
            local root = char and char:FindFirstChild('HumanoidRootPart')
            local hum = char and char:FindFirstChildOfClass('Humanoid')
            if root and root.Parent and S.savedCF then
                pcall(function()
                    root.CFrame = S.savedCF
                    root.Anchored = S.savedAnchored and true or false
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                end)
            end
            if hum and hum.Parent and hum.Health > 0 then
                pcall(function()
                    hum.PlatformStand = false
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                end)
            end
        end
        S.savedCF = nil
    end

    local function start(tool, holdTime)
        local char = LP.Character
        local root = char and char:FindFirstChild('HumanoidRootPart')
        if not root or not root.Parent then return end

        if S.active then
            if tool ~= S.tool then
                stop()
            else
                S.endAt = math.max(S.endAt, tick() + holdTime)
                return
            end
        end

        S.savedCF = root.CFrame
        S.savedAnchored = root.Anchored
        if VG.enabled() then
            pcall(function() VG:begin(true) end)
        end

        S.active = true
        S.tool = tool
        S.startAt = tick()
        S.endAt = tick() + holdTime

        local y = VG.safeY((Options.VoidReloadDepth and Options.VoidReloadDepth.Value) or -70)
        local base = S.savedCF
        pcall(function()
            root.CFrame = CFrame.new(base.X, y, base.Z)
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            root.Anchored = true
        end)
    end

    -- 给 __namecall 钩子调用：玩家自己发起的换弹（FuncReload:InvokeServer）
    _G.BoarsManualVoidReload = function()
        if not (Toggles.VoidReload and Toggles.VoidReload.Value) then return end
        if Toggles.NoReload and Toggles.NoReload.Value then return end
        if Toggles.VoidAura and Toggles.VoidAura.Value then return end

        local tool = equippedGun()
        if not tool then return end
        -- 脚本自己发起的换弹由 doReload 负责，这里不重复处理
        if (tonumber(tool:GetAttribute('Local_ReloadSession')) or 0) > 0 then return end

        start(tool, reloadTimeOf(tool) + 0.35)
    end

    RunService.Heartbeat:Connect(function()
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass('Humanoid')

        if not (Toggles.VoidReload and Toggles.VoidReload.Value)
            or (Toggles.VoidAura and Toggles.VoidAura.Value)
            or not char or not hum or hum.Health <= 0 then
            stop()
            S.lastAmmo = nil
            S.hudReloading = false
            return
        end

        local tool = equippedGun()
        if not tool then
            stop()
            S.lastAmmo = nil
            S.hudReloading = false
            return
        end

        local cur, max = ammoNow(tool)
        local session = tonumber(tool:GetAttribute('Local_ReloadSession')) or 0

        -- 脚本自己的换弹流程（Rage / 光环）：交给 doReload，避免两套逻辑打架
        if session > 0 then
            if S.active then stop() end
            S.lastAmmo = cur
            return
        end

        -- 每 0.2 秒读一次 HUD：换弹时弹药数会显示成 "..."
        S.hudTimer = S.hudTimer + 1
        if S.hudTimer >= 12 then
            S.hudTimer = 0
            S.hudReloading = false
            pcall(function()
                local hud = LP.PlayerGui and LP.PlayerGui:FindFirstChild('Home') and LP.PlayerGui.Home:FindFirstChild('hud')
                local gunFrame = hud and hud:FindFirstChild('BottomRightFrame') and hud.BottomRightFrame:FindFirstChild('GunFrame')
                local label = gunFrame and gunFrame:FindFirstChild('BulletsLabel')
                if label and typeof(label.Text) == 'string' and label.Text == '...' then
                    S.hudReloading = true
                end
            end)
        end

        -- 触发：弹匣刚打空 / HUD 显示换弹中（部分换弹不经过 FuncReload）
        if not S.active then
            local justEmptied = S.lastAmmo and S.lastAmmo > 0 and cur <= 0
            if justEmptied or S.hudReloading then
                start(tool, reloadTimeOf(tool) + 0.35)
            end
        end
        S.lastAmmo = cur

        if not S.active then return end

        if tool ~= S.tool then
            stop()
            return
        end

        -- 结束：弹药回满
        if max > 0 and cur >= max and (tick() - S.startAt) > 0.15 then
            stop()
            return
        end

        -- 超时：换弹还没完就续一小段（最多 10 秒），避免卡在虚空里
        if tick() > S.endAt then
            if (cur <= 0 or S.hudReloading) and (tick() - S.startAt) < 10 then
                S.endAt = tick() + 0.3
            else
                stop()
                return
            end
        end

        -- 悬停：每帧压回虚空深度，防止重力把人拽下去
        local root = char:FindFirstChild('HumanoidRootPart')
        if root and S.savedCF then
            local y = VG.safeY((Options.VoidReloadDepth and Options.VoidReloadDepth.Value) or -70)
            local base = S.savedCF
            pcall(function()
                root.CFrame = CFrame.new(base.X, y, base.Z)
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                root.Anchored = true
            end)
        end
    end)

    LP.CharacterRemoving:Connect(function()
        S.active = false
        S.tool = nil
        S.lastAmmo = nil
        S.savedCF = nil
        S.hudReloading = false
    end)
end

-- 无需换弹：后台持续补满服务器弹药，枪械永不断供
task.spawn(function()
    while true do
        task.wait(0.12)
        if not (Toggles.NoReload and Toggles.NoReload.Value) then continue end
        if not isAlive(LP) then continue end
        local chr = LP.Character
        local tool = chr and chr:FindFirstChildOfClass('Tool')
        if not tool then continue end
        local isGun = tool:GetAttribute('ToolType') == 'Gun' or (gunConfigs and gunConfigs[tool.Name]) or tool:FindFirstChild('Muzzle')
        if not isGun then continue end
        local cfg = getConfig(tool)
        local maxAmmo = tool:GetAttribute('MaxAmmo') or (cfg and cfg.maxAmmo) or 0
        if maxAmmo and maxAmmo > 0 then
            local serverAmmo = tool:GetAttribute('CurrentAmmo')
            if serverAmmo ~= nil and serverAmmo < maxAmmo then
                pcall(function() FuncReload:InvokeServer() end)
            end
            tool:SetAttribute('Local_CurrentAmmo', maxAmmo)
            tool:SetAttribute('Local_ReloadSession', 0)
        end
    end
end)



local function getAllInventoryGuns()
    local guns = {}
    local seen = {}
    if LP.Character then
        for _, item in LP.Character:GetChildren() do
            if item:IsA('Tool') and (knownGunNames[item.Name] or item:GetAttribute('ToolType') == 'Gun') then
                if not seen[item] then
                    seen[item] = true
                    table.insert(guns, { tool = item, equipped = true })
                end
            end
        end
    end
    local bp = LP:FindFirstChildOfClass('Backpack') or LP:FindFirstChild('Backpack')
    if bp then
        for _, item in bp:GetChildren() do
            if item:IsA('Tool') and (knownGunNames[item.Name] or item:GetAttribute('ToolType') == 'Gun') then
                if not seen[item] then
                    seen[item] = true
                    table.insert(guns, { tool = item, equipped = false })
                end
            end
        end
    end
    return guns
end

local function equipGun(tool)
    if not tool or not tool.Parent then return false end
    if tool.Parent == LP.Character then return true end
    local hum = LP.Character and LP.Character:FindFirstChildOfClass('Humanoid')
    if hum then
        hum:EquipTool(tool)
        return true
    end
    return false
end

local function unequipGuns()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass('Humanoid')
    if hum then
        hum:UnequipTools()
    end
end

local function scoreLethalGun(tool, dist, isCurrentlyEquipped)
    local cfg = getConfig(tool)
    if not cfg then return -100 end
    if tool.Name == 'Taser' then return -100 end
    if dist > (cfg.range or 1100) then return -100 end

    local curAmmo = tool:GetAttribute('Local_CurrentAmmo') or tool:GetAttribute('CurrentAmmo') or 0
    local isReloading = ((tool:GetAttribute('Local_ReloadSession') or 0) > 0) and (curAmmo <= 0)

    local score = 100

    -- Heavy penalty if out of ammo or reloading
    if curAmmo <= 0 or isReloading then
        score = score - 70
    end

    -- Distance matching
    if tool.Name == 'Remington 870' then
        if dist <= 65 then
            score = score + 90
        elseif dist <= 120 then
            score = score + 45
        elseif dist <= 250 then
            score = score + 10
        else
            score = score - 30
        end
    elseif tool.Name == 'AK-47' or tool.Name == 'M4A1' or tool.Name == 'FAL' or tool.Name == 'MP5' then
        score = score + 65
        if dist > 60 and dist <= 350 then
            score = score + 30
        end
    elseif tool.Name == 'M700' then
        if dist > 250 then
            score = score + 70
        else
            score = score + 15
        end
    elseif tool.Name == 'Revolver' then
        score = score + 35
    elseif tool.Name == 'M9' then
        score = score + 25
    else
        score = score + 20
    end

    if isCurrentlyEquipped and curAmmo > 0 then
        score = score + 15
    end

    return score
end

local function selectBestLethalGun(dist, currentTool)
    local allGuns = getAllInventoryGuns()
    local bestGun = nil
    local bestScore = -50

    for _, entry in ipairs(allGuns) do
        local tool = entry.tool
        local isEquipped = (tool == currentTool or entry.equipped)
        local score = scoreLethalGun(tool, dist, isEquipped)
        if score > bestScore then
            bestScore = score
            bestGun = tool
        end
    end

    return bestGun
end

local givePlayerWeapon = nil
local grabSpecificGuns = nil
local grabAllSelectedWeapons = nil
local isGunGiver = nil
local findNearestGun = nil

do
    local knownGunNamesLower = {}
    for k in pairs(knownGunNames) do
        knownGunNamesLower[string.lower(k)] = k
    end
    knownGunNamesLower['riot shield'] = 'Riot Shield'
    knownGunNamesLower['shield'] = 'Riot Shield'
    knownGunNamesLower['taser'] = 'Taser'

    isGunGiver = function(model)
        if not model then return false end
        if knownGunNames[model.Name] then return true end
        if model:GetAttribute('ToolType') == 'Gun' or model:GetAttribute('ToolName') then return true end
        if model:FindFirstChild('Muzzle') then return true end
        for _, child in ipairs(model:GetChildren()) do
            if child:IsA('Tool') and (child:GetAttribute('ToolType') == 'Gun' or knownGunNames[child.Name]) then
                return true
            end
        end
        return false
    end

    local function getGiverToolName(giver)
        if not giver then return nil end
        local attr = giver:GetAttribute('ToolName')
        if attr and attr ~= '' then return attr end

        local tool = giver:FindFirstChildOfClass('Tool')
        if tool then return tool.Name end

        local nameLower = string.lower(giver.Name)
        for kLower, origName in pairs(knownGunNamesLower) do
            if string.find(nameLower, kLower, 1, true) then
                return origName
            end
        end

        return giver.Name
    end

    local function getGiverTouchPart(giver)
        if not giver then return nil end
        if giver:IsA('BasePart') then return giver end
        local tg = giver:FindFirstChild('TouchGiver') or giver:FindFirstChild('ITEMPICKUP') or giver:FindFirstChild('Giver') or giver:FindFirstChild('Handle')
        if tg and tg:IsA('BasePart') then return tg end
        if giver.PrimaryPart and giver.PrimaryPart:IsA('BasePart') then return giver.PrimaryPart end
        for _, child in ipairs(giver:GetChildren()) do
            if child:IsA('BasePart') then return child end
        end
        return nil
    end

    local function getAllGivers()
        local list = {}
        local seen = {}

        local function addGiver(obj)
            if not obj or seen[obj] then return end
            seen[obj] = true
            table.insert(list, obj)
        end

        -- CollectionService tags
        pcall(function()
            for _, obj in ipairs(CollectionService:GetTagged('Giver')) do
                addGiver(obj)
            end
            for _, obj in ipairs(CollectionService:GetTagged('TouchGiver')) do
                addGiver(obj)
            end
        end)

        -- Workspace models
        pcall(function()
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj:IsA('Model') and (obj:FindFirstChild('TouchGiver') or obj:FindFirstChild('Giver') or isGunGiver(obj)) then
                    addGiver(obj)
                end
            end
        end)

        -- Classic Prison_ITEMS
        pcall(function()
            local pi = workspace:FindFirstChild('Prison_ITEMS')
            if pi then
                local g = pi:FindFirstChild('giver') or pi
                for _, obj in ipairs(g:GetChildren()) do
                    addGiver(obj)
                end
            end
        end)

        return list
    end

    local function playerHasWeapon(weaponName)
        local char = LP.Character
        if char and char:FindFirstChild(weaponName) then return true end
        local bp = LP:FindFirstChild('Backpack')
        if bp and bp:FindFirstChild(weaponName) then return true end
        return false
    end

    givePlayerWeapon = function(giver, useTeleport)
        if not giver then return false end
        local touchPart = getGiverTouchPart(giver)
        local root = LP.Character and LP.Character:FindFirstChild('HumanoidRootPart')

        -- 1. Try Remote: GiverPressed & InteractWithItem
        pcall(function()
            local remotes = ReplicatedStorage:FindFirstChild('Remotes')
            local gp = remotes and remotes:FindFirstChild('GiverPressed')
            if gp then
                gp:FireServer(giver)
            end
            local iwi = remotes and remotes:FindFirstChild('InteractWithItem')
            if iwi and touchPart then
                iwi:InvokeServer(touchPart)
            end
        end)

        -- 2. Try classic ItemHandler
        pcall(function()
            local ih = workspace:FindFirstChild('Remote') and workspace.Remote:FindFirstChild('ItemHandler')
            if ih and touchPart then
                ih:InvokeServer(touchPart)
            end
        end)

        -- 3. Try firetouchinterest (executor touch packet simulation - instant, no teleport)
        if firetouchinterest and root and touchPart then
            pcall(function()
                firetouchinterest(root, touchPart, 0)
                task.wait(0.01)
                firetouchinterest(root, touchPart, 1)
            end)
        end

        -- 4. Micro-teleport & return if requested
        if useTeleport and root and touchPart then
            pcall(function()
                local oldCF = root.CFrame
                root.CFrame = touchPart.CFrame + Vector3.new(0, 1.5, 0)
                task.wait(0.04)
                if firetouchinterest then
                    firetouchinterest(root, touchPart, 0)
                    firetouchinterest(root, touchPart, 1)
                end
                root.CFrame = oldCF
            end)
        end

        return true
    end

    findNearestGun = function()
        local root = LP.Character and LP.Character:FindFirstChild('HumanoidRootPart')
        if not root then return nil end
        local best, bestDist = nil, math.huge
        local givers = getAllGivers()
        for _, obj in ipairs(givers) do
            local tp = getGiverTouchPart(obj)
            if tp then
                local d = (tp.Position - root.Position).Magnitude
                if d < bestDist then
                    bestDist = d
                    best = obj
                end
            end
        end
        return best
    end

    grabSpecificGuns = function(gunNameList, force)
        local givers = getAllGivers()
        local useTeleport = Options.AutoGetWeaponMethod and Options.AutoGetWeaponMethod.Value == 'Teleport & Return'
        for _, giver in ipairs(givers) do
            local toolName = getGiverToolName(giver)
            if toolName then
                local shouldGrab = false
                for _, targetName in ipairs(gunNameList) do
                    if targetName == 'All Available' or string.lower(toolName) == string.lower(targetName) then
                        shouldGrab = true
                        break
                    end
                end
                if shouldGrab and (force or not playerHasWeapon(toolName)) then
                    givePlayerWeapon(giver, useTeleport)
                    task.wait(0.04)
                end
            end
        end
    end

    grabAllSelectedWeapons = function(force)
        local selected = (Options.AutoGetWeaponList and Options.AutoGetWeaponList.Value) or { ['All Available'] = true }
        local targets = {}
        if selected['All Available'] then
            table.insert(targets, 'All Available')
        else
            for name, isSel in pairs(selected) do
                if isSel then table.insert(targets, name) end
            end
        end
        if #targets > 0 then
            grabSpecificGuns(targets, force)
        end
    end

    -- Auto Get Weapons background task loop
    task.spawn(function()
        while true do
            task.wait(1.2)
            if Toggles.AutoGetWeapon and Toggles.AutoGetWeapon.Value and isAlive(LP) then
                pcall(function()
                    grabAllSelectedWeapons(false)
                end)
            end
        end
    end)

    -- Auto Get on Respawn
    LP.CharacterAdded:Connect(function()
        if Toggles.AutoGetOnSpawn and Toggles.AutoGetOnSpawn.Value then
            task.wait(0.8)
            pcall(function()
                grabAllSelectedWeapons(true)
            end)
        end
    end)
end

-- ====================== 免费枪械获取（服务器全图 · 传送拾取 · 传送回原点） ======================
-- 扫描服务器上所有「免费枪械」拾取点（giver / 地面掉落 / ProximityPrompt 等），
-- 逐个瞬移过去触发拾取，然后立刻瞬移回原点，全程不用手动跑图。
local FreeGunGrab = {
    Running = false,
    NextAuto = 0,
    StatusLabel = nil,
    LastFound = 0,
    LastTaken = 0,
}

do
    local function norm(s)
        return string.lower(tostring(s or ''))
    end

    -- 枪械关键词（1~3 位短词按整词匹配，避免误伤 breakable / snack 之类）
    local GUN_WORDS = {
        'ak', 'ak47', 'm4', 'm4a1', 'm16', 'm14', 'mp5', 'mp7', 'mp9', 'm9', 'm1911',
        'glock', 'deagle', 'revolver', 'python', 'remington', 'm700', 'fal', 'taser',
        'shotgun', 'spas', 'sniper', 'awp', 'mosin', 'rifle', 'pistol', 'smg', 'uzi',
        'p90', 'mac10', 'tec9', 'scar', 'lmg', 'm249', 'm60', 'minigun', 'launcher',
        'p250', 'cz75', 'ump', 'ump45', 'vector', 'g36', 'famas', 'aug', 'kar98',
        'winchester', 'sg553', 'ak74', 'pkm', 'm24', 'svd', 'dragunov', 'barrett',
        'awm', 'skorpion', 'firearm',
        '枪', '手枪', '步枪', '狙击', '霰弹', '冲锋枪', '机枪',
    }

    -- 明确不是枪械的拾取物，先排除再判断，避免抓到刀 / 手铐 / 钥匙卡
    local NOT_GUN_WORDS = {
        'knife', 'hammer', 'crowbar', 'bat', 'fist', 'handcuff', 'keycard', 'key',
        'donut', 'snack', 'cola', 'drink', 'medkit', 'bandage', 'wrench', 'screwdriver',
        'pickaxe', 'radio', 'camera', 'ticket', 'cash', 'money', 'armor', 'vest',
        'shield', 'hat', 'shirt', 'pants', 'tool', 'spray', 'food', 'water',
        '刀', '手铐', '钥匙', '食物',
    }

    local function isShortAscii(kw)
        return #kw <= 3 and kw:match('^[%a%d]+$') ~= nil
    end

    local function containsWord(padded, word)
        return string.find(padded, ' ' .. word .. ' ', 1, true) ~= nil
    end

    local function nameLooksGun(rawName)
        local n = norm(rawName)
        if n == '' then return false end
        local padded = ' ' .. (n:gsub('[^%w]+', ' ')) .. ' '
        for _, bad in ipairs(NOT_GUN_WORDS) do
            if isShortAscii(bad) then
                if containsWord(padded, bad) then return false end
            elseif string.find(n, bad, 1, true) then
                return false
            end
        end
        for _, kw in ipairs(GUN_WORDS) do
            if isShortAscii(kw) then
                if containsWord(padded, kw) then return true end
            elseif string.find(n, kw, 1, true) then
                return true
            end
        end
        return false
    end

    local TOUCH_PART_NAMES = {
        'TouchGiver', 'ITEMPICKUP', 'ItemPickup', 'Giver', 'Pickup', 'TouchPart',
        'InteractPart', 'ClickPart',
    }

    local function giverTouchPart(giver)
        if not giver then return nil end
        if giver:IsA('BasePart') then return giver end
        for _, nm in ipairs(TOUCH_PART_NAMES) do
            local p = giver:FindFirstChild(nm, true)
            if p and p:IsA('BasePart') then return p end
        end
        local handle = giver:FindFirstChild('Handle', true)
        if handle and handle:IsA('BasePart') then return handle end
        if giver.PrimaryPart and giver.PrimaryPart:IsA('BasePart') then
            return giver.PrimaryPart
        end
        for _, c in ipairs(giver:GetChildren()) do
            if c:IsA('BasePart') then return c end
        end
        return nil
    end

    local function giverToolName(giver)
        if not giver then return nil end
        local attrs = { 'ToolName', 'ItemName', 'WeaponName', 'GunName' }
        for _, a in ipairs(attrs) do
            local v = giver:GetAttribute(a)
            if type(v) == 'string' and v ~= '' then return v end
        end
        local tool = giver:FindFirstChildOfClass('Tool')
        if tool then return tool.Name end
        local child = giver:FindFirstChild('Tool')
        if child and child:IsA('Tool') then return child.Name end
        -- 模型本身叫 Giver / Item 之类的通用名时，从子对象（两层内）里找枪名
        if not nameLooksGun(giver.Name) then
            local function findGunNameIn(container, depth)
                if depth > 2 then return nil end
                for _, c in ipairs(container:GetChildren()) do
                    if (c:IsA('Model') or c:IsA('BasePart') or c:IsA('Tool')) and nameLooksGun(c.Name) then
                        return c.Name
                    end
                    local sub = findGunNameIn(c, depth + 1)
                    if sub then return sub end
                end
                return nil
            end
            local found = findGunNameIn(giver, 1)
            if found then return found end
        end
        return giver.Name
    end

    local PAID_ATTRS = {
        'Price', 'Cost', 'BuyPrice', 'PriceTag', 'RequirePurchase', 'RequiresPurchase',
        'Paid', 'IsShopItem', 'ShopPrice',
    }
    local PAID_PARENT_WORDS = { 'shop', 'store', 'buy', 'purchase', 'vending', 'cashier', 'market' }

    -- 是否是付费 / 商店枪械（只抓免费的）
    local function isPaidGiver(giver)
        for _, a in ipairs(PAID_ATTRS) do
            local v = giver:GetAttribute(a)
            if type(v) == 'number' and v > 0 then return true end
            if v == true then return true end
        end
        local p = giver.Parent
        for _ = 1, 5 do
            if not p or p == workspace then break end
            local n = norm(p.Name)
            for _, w in ipairs(PAID_PARENT_WORDS) do
                if string.find(n, w, 1, true) then return true end
            end
            p = p.Parent
        end
        return false
    end

    -- 排除玩家角色里拿着的枪（避免瞬移到别人身上去“抢”）
    local function insidePlayerCha(obj)
        local anc = obj
        for _ = 1, 6 do
            if not anc then return false end
            if anc:IsA('Player') then return true end
            local ok, plr = pcall(Players.GetPlayerFromCharacter, Players, anc)
            if ok and plr then return true end
            anc = anc.Parent
        end
        return false
    end

    -- 只看两层，避免全量子树遍历拖慢扫描
    local function hasPromptOrClick(obj)
        local found = false
        pcall(function()
            for _, c in ipairs(obj:GetChildren()) do
                if c:IsA('ProximityPrompt') or c:IsA('ClickDetector') then
                    found = true
                    return
                end
                for _, cc in ipairs(c:GetChildren()) do
                    if cc:IsA('ProximityPrompt') or cc:IsA('ClickDetector') then
                        found = true
                        return
                    end
                end
            end
        end)
        return found
    end

    local function hasDirectTouchPart(obj)
        for _, nm in ipairs(TOUCH_PART_NAMES) do
            if obj:FindFirstChild(nm) then return true end
        end
        return false
    end

    -- 扫描全图免费枪械点
    function FreeGunGrab.Scan()
        local list, seen = {}, {}
        local root = LP.Character and LP.Character:FindFirstChild('HumanoidRootPart')
        local originPos = root and root.Position or Vector3.new(0, 0, 0)
        local visited = 0

        local function add(obj, part, trusted)
            if not obj or seen[obj] then return end
            seen[obj] = true
            if insidePlayerCha(obj) then return end

            local name = giverToolName(obj)
            if not name or not nameLooksGun(name) then return end
            if isPaidGiver(obj) then return end

            if not trusted then
                local groundTool = obj:IsA('Tool') and obj.Parent
                    and (obj.Parent == workspace or obj.Parent:IsA('Folder'))
                if not (hasDirectTouchPart(obj) or hasPromptOrClick(obj) or groundTool) then
                    return
                end
            end

            part = part or giverTouchPart(obj)
            if not part or not part:IsA('BasePart') then return end

            list[#list + 1] = {
                obj = obj,
                part = part,
                name = name,
                key = norm(name):gsub('%s+', ''),
                dist = (part.Position - originPos).Magnitude,
            }
        end

        -- 1) CollectionService 标签
        for _, tag in ipairs({ 'Giver', 'TouchGiver', 'ItemGiver', 'WeaponGiver', 'Pickup' }) do
            pcall(function()
                for _, o in ipairs(CollectionService:GetTagged(tag)) do
                    add(o, nil, true)
                end
            end)
        end

        -- 2) 经典 Prison_ITEMS 拾取物
        pcall(function()
            local pi = workspace:FindFirstChild('Prison_ITEMS')
            if pi then
                for _, o in ipairs(pi:GetChildren()) do
                    add(o, nil, true)
                    for _, c in ipairs(o:GetChildren()) do
                        if c:IsA('Model') or c:IsA('Tool') then add(c, nil, true) end
                    end
                end
            end
        end)

        -- 3) 全图遍历（限深度与数量，避免卡顿）
        local function walk(node, depth)
            if depth > 6 or visited > 12000 then return end
            for _, c in ipairs(node:GetChildren()) do
                if (c:IsA('Model') or c:IsA('Folder')) and c ~= LP.Character then
                    visited = visited + 1
                    if visited > 12000 then return end
                    local directTouch = hasDirectTouchPart(c)
                    if directTouch then
                        add(c, nil, true)
                    elseif nameLooksGun(c.Name) then
                        add(c, nil, false)
                    end
                    walk(c, depth + 1)
                elseif c:IsA('Tool') then
                    add(c, nil, false)
                elseif c:IsA('BasePart') then
                    local nm = c.Name
                    if nm == 'TouchGiver' or nm == 'ITEMPICKUP' or nm == 'ItemPickup'
                        or nm == 'Pickup' or nm == 'InteractPart' then
                        add(c.Parent or c, c, true)
                    end
                end
            end
        end
        walk(workspace, 0)

        table.sort(list, function(a, b) return a.dist < b.dist end)
        FreeGunGrab.LastFound = #list
        return list
    end

    local function toolCount()
        local n = 0
        local char = LP.Character
        if char then
            for _, c in ipairs(char:GetChildren()) do
                if c:IsA('Tool') then n = n + 1 end
            end
        end
        local bp = LP:FindFirstChildOfClass('Backpack')
        if bp then
            for _, c in ipairs(bp:GetChildren()) do
                if c:IsA('Tool') then n = n + 1 end
            end
        end
        return n
    end

    local function hasToolNamed(name)
        local key = norm(name):gsub('%s+', '')
        if key == '' then return false end
        local function scan(container)
            if not container then return false end
            for _, c in ipairs(container:GetChildren()) do
                if c:IsA('Tool') then
                    local k = norm(c.Name):gsub('%s+', '')
                    if k == key or string.find(k, key, 1, true) or string.find(key, k, 1, true) then
                        return true
                    end
                end
            end
            return false
        end
        return scan(LP.Character) or scan(LP:FindFirstChildOfClass('Backpack'))
    end

    local function snapTo(root, cf)
        root.CFrame = cf
        pcall(function()
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end)
    end

    local function fireTouch(root, part)
        if not firetouchinterest then return end
        pcall(function()
            firetouchinterest(root, part, 0)
            task.wait(0.02)
            firetouchinterest(root, part, 1)
        end)
    end

    -- 依次触发所有已知的拾取方式：远程事件 / ProximityPrompt / ClickDetector / 触摸
    local function fireInteractions(giver, part, root)
        pcall(function()
            local remotes = ReplicatedStorage:FindFirstChild('Remotes')
            if remotes then
                local gp = remotes:FindFirstChild('GiverPressed')
                if gp then pcall(function() gp:FireServer(giver) end) end

                local iwi = remotes:FindFirstChild('InteractWithItem')
                if iwi then
                    -- InvokeServer 可能长时间无返回，放到独立线程里，避免卡住整个流程
                    task.spawn(function()
                        pcall(function() iwi:InvokeServer(part) end)
                    end)
                    task.spawn(function()
                        pcall(function() iwi:InvokeServer(giver) end)
                    end)
                end
            end
            local wsRemote = workspace:FindFirstChild('Remote')
            local ih = wsRemote and wsRemote:FindFirstChild('ItemHandler')
            if ih then
                task.spawn(function()
                    pcall(function() ih:InvokeServer(part) end)
                end)
            end
        end)
        pcall(function()
            local prompt = giver:FindFirstChildWhichIsA('ProximityPrompt', true)
                or (part and part:FindFirstChildWhichIsA('ProximityPrompt', true))
            if prompt and fireproximityprompt then
                fireproximityprompt(prompt)
            end
        end)
        pcall(function()
            local cd = giver:FindFirstChildWhichIsA('ClickDetector', true)
                or (part and part:FindFirstChildWhichIsA('ClickDetector', true))
            if cd and fireclickdetector then
                fireclickdetector(cd)
            end
        end)
        if root and part then
            fireTouch(root, part)
        end
    end

    function FreeGunGrab.SetStatus(text)
        local lb = FreeGunGrab.StatusLabel
        if lb then
            pcall(function() lb:SetText(text) end)
        end
    end

    function FreeGunGrab.Notify(text)
        pcall(function()
            Library:Notify({ Title = '获取枪械', Description = tostring(text), Time = 4 })
        end)
    end

    function FreeGunGrab.Stop()
        FreeGunGrab.Running = false
    end

    -- 单个枪械点：瞬移过去 → 触发拾取 → 瞬移回原点
    function FreeGunGrab.GrabOne(entry, origin, dwell, backHome)
        local char = LP.Character
        local root = char and char:FindFirstChild('HumanoidRootPart')
        if not root then return false end

        local before = toolCount()
        local pos = entry.part.Position
        snapTo(root, CFrame.lookAt(pos + Vector3.new(0, 0.5, 0), pos))
        task.wait(dwell)

        fireInteractions(entry.obj, entry.part, root)
        task.wait(dwell)

        local got = toolCount() > before or hasToolNamed(entry.name)
        if not got then
            -- 有些 giver 需要多停留一会才有反应，补一次
            fireInteractions(entry.obj, entry.part, root)
            task.wait(math.max(dwell, 0.08))
            got = toolCount() > before or hasToolNamed(entry.name)
        end

        if backHome and root.Parent then
            snapTo(root, origin)
        end
        return got
    end

    -- 获取全部（或指定 / 最近一把）
    -- opts.backHome   拾取后是否传送回原点（默认 true）
    -- opts.unique     每种枪只取一把（默认 true）
    -- opts.dwell      每个点停留时间，秒（默认 0.09）
    -- opts.only       只取指定枪名（'全部' 或 nil 表示不限）
    -- opts.limit      最多尝试多少个点
    -- opts.ignoreOwned 已拥有的枪也重新拿（默认跳过已拥有）
    function FreeGunGrab.GrabAll(opts)
        opts = opts or {}
        if FreeGunGrab.Running then
            return 0, 0
        end
        if not isAlive(LP) then
            FreeGunGrab.Notify('人物未存活，无法获取枪械')
            return 0, 0
        end

        local char = LP.Character
        local root = char and char:FindFirstChild('HumanoidRootPart')
        local hum = char and char:FindFirstChildOfClass('Humanoid')
        if not root then return 0, 0 end

        FreeGunGrab.Running = true
        FreeGunGrab.SetStatus('正在扫描全图枪械…')

        local origin = root.CFrame
        local originChar = char
        local backHome = opts.backHome ~= false
        local dwell = math.clamp(opts.dwell or 0.09, 0.02, 0.5)
        local unique = opts.unique ~= false
        local only = opts.only
        local limit = opts.limit
        local ignoreOwned = opts.ignoreOwned == true

        local taken, tried, found = 0, 0, 0
        local gotKeys = {}
        local ok, err = pcall(function()
            if hum and hum.Sit then
                pcall(function() hum.Sit = false end)
                task.wait(0.08)
            end

            local list = FreeGunGrab.Scan()
            found = #list
            if found == 0 then
                FreeGunGrab.SetStatus('全图没有找到枪械')
                return
            end

            FreeGunGrab.SetStatus(string.format('找到 %d 处枪械，开始传送获取…', found))

            for _, e in ipairs(list) do
                if not FreeGunGrab.Running then break end
                if not isAlive(LP) then break end
                if limit and tried >= limit then break end

                local skip = false
                if unique and gotKeys[e.key] then skip = true end
                if only and only ~= '' and only ~= '全部' then
                    if norm(only):gsub('%s+', '') ~= e.key then skip = true end
                end
                if (not skip) and (not ignoreOwned) and hasToolNamed(e.name) then skip = true end

                if not skip then
                    tried = tried + 1
                    local ok2, got = pcall(FreeGunGrab.GrabOne, e, origin, dwell, backHome)
                    if ok2 and got then
                        taken = taken + 1
                        gotKeys[e.key] = true
                    end
                    FreeGunGrab.SetStatus(string.format('获取中… 尝试 %d / %d，已获得 %d', tried, found, taken))
                end
            end
        end)

        -- 无论成功失败，最后一定回到原点（换人 / 死亡后不再往回拉）
        if backHome and LP.Character == originChar then
            local r = LP.Character and LP.Character:FindFirstChild('HumanoidRootPart')
            if r then pcall(snapTo, r, origin) end
        end
        pcall(function()
            if hum then
                hum.PlatformStand = false
                hum.Sit = false
            end
        end)

        FreeGunGrab.Running = false
        FreeGunGrab.LastTaken = taken

        if not ok then
            FreeGunGrab.SetStatus('获取中断：' .. tostring(err))
            FreeGunGrab.Notify('获取中断：' .. tostring(err))
            return taken, tried
        end

        if found == 0 then
            FreeGunGrab.Notify('全图没有找到枪械')
            return taken, tried
        end

        FreeGunGrab.SetStatus(string.format('完成：全图 %d 处，尝试 %d，获得 %d', found, tried, taken))
        if tried > 0 then
            FreeGunGrab.Notify(string.format('获取完成：尝试 %d 把，成功 %d 把，已传送回原点', tried, taken))
        else
            FreeGunGrab.Notify('没有需要获取的枪械（可能已经全部拥有）')
        end
        return taken, tried
    end

    -- 自动获取循环
    task.spawn(function()
        while true do
            task.wait(1)
            local toggle = Toggles.FreeGunAuto
            if toggle and toggle.Value and not FreeGunGrab.Running and isAlive(LP) then
                local interval = (Options.FreeGunAutoInterval and Options.FreeGunAutoInterval.Value) or 10
                if tick() >= FreeGunGrab.NextAuto then
                    FreeGunGrab.NextAuto = tick() + math.max(3, interval)
                    FreeGunGrab.GrabAll({
                        backHome = not (Options.FreeGunReturnHome and Options.FreeGunReturnHome.Value == false),
                        unique = not (Options.FreeGunUnique and Options.FreeGunUnique.Value == false),
                        dwell = ((Options.FreeGunDwell and Options.FreeGunDwell.Value) or 90) / 1000,
                    })
                end
            end
        end
    end)

    -- 对外暴露，方便排错 / 其它脚本调用
    pcall(function()
        local g = getgenv and getgenv() or _G
        if g and g.WX then
            g.WX.FreeGunGrab = FreeGunGrab
        end
    end)
end

-- ====================== 反自动躲避（Anti Auto Dodge） ======================
-- 对手开「无敌帧 + 自动闪避」脚本时，原来的链路有两处会直接放弃目标：
--   1) isAlive() 见到 ForceField 就返回 false，选目标阶段就把无敌玩家跳过去了；
--   2) 真锁上了也是贴脸空枪，伤害全被无敌吃掉。
-- 本引擎做三件事：
--   1) 识别无敌来源：ForceField / 角色或玩家属性 / 挂在角色下的常见无敌值；
--   2) 用「空枪 + 受击瞬间侧移 / 瞬移」识别自动躲避脚本，写进 detectedCheaters；
--   3) 无敌期间保持锁定但不开火（可选后撤规避），无敌一消失立刻补枪。
do
    local AntiDodge = {
        label = _G.WXAntiDodgeLabel,
        data = setmetatable({}, { __mode = 'k' }),
        evadeTarget = nil,
        lastStatus = 0,
        _lastText = nil,
    }
    _G.WXAntiDodge = AntiDodge

    local INV_KEYS = { 'invinc', 'invulner', 'godmode', 'god_mode', 'immortal', 'nodamage', 'no_damage', 'damageimmun', 'iframe', 'i_frame', 'immun' }
    local DODGE_KEYS = { 'dodge', 'evade', 'evasion', 'sidestep' }
    local MAX_SCORE = 24

    local function isOn()
        local t = Toggles.AntiAutoDodge
        return t ~= nil and t.Value == true
    end

    local function matchKey(name, keys)
        local ln = string.lower(tostring(name))
        for i = 1, #keys do
            if string.find(ln, keys[i], 1, true) then return true end
        end
        return false
    end

    local function truthy(v)
        if v == true then return true end
        if type(v) == 'number' then return v > 0 end
        return false
    end

    local function scanAttrs(obj, out)
        local ok, attrs = pcall(function() return obj:GetAttributes() end)
        if not ok or type(attrs) ~= 'table' then return end
        for k, v in pairs(attrs) do
            if matchKey(k, INV_KEYS) and truthy(v) then
                out.inv, out.invName = true, k
            elseif matchKey(k, DODGE_KEYS) and v == true then
                -- 闪避标记只认布尔 true；数字型多半是冷却计时，常驻 >0 会误报
                out.dodge = true
            end
        end
    end

    local function scanValues(container, out)
        if not container then return end
        local ok, kids = pcall(function() return container:GetChildren() end)
        if not ok or type(kids) ~= 'table' then return end
        for _, ch in ipairs(kids) do
            if ch:IsA('BoolValue') or ch:IsA('NumberValue') or ch:IsA('IntValue') or ch:IsA('StringValue') then
                if matchKey(ch.Name, INV_KEYS) and truthy(ch.Value) then
                    out.inv, out.invName = true, ch.Name
                elseif matchKey(ch.Name, DODGE_KEYS) and ch:IsA('BoolValue') and ch.Value then
                    out.dodge = true
                end
            end
        end
    end

    -- 返回 inv(boolean), invName(string), dodge(boolean)
    local function readMarkers(p, char)
        local out = { inv = false, invName = nil, dodge = false }
        if char then
            if char:FindFirstChildOfClass('ForceField') then
                return true, 'ForceField', false
            end
            scanAttrs(char, out)
            scanValues(char, out)
            if not out.dodge then
                local hum = char:FindFirstChildOfClass('Humanoid')
                if hum then scanValues(hum, out) end
            end
            if out.inv then return true, out.invName, out.dodge end
        end
        if p then scanAttrs(p, out) end
        return out.inv, out.invName, out.dodge
    end

    local function getState(p)
        local s = AntiDodge.data[p]
        if not s then
            s = {
                char = nil,
                invSince = 0, invReason = nil, wasInv = false,
                lastPos = nil, lastTick = 0, vel = nil,
                dodgeScore = 0, dodgeFlag = false,
                lastShotTick = 0, lastHitTick = 0,
                pendingShotTick = 0,
                justEndedInv = 0, penaltyShots = 0,
                lastNotify = 0,
            }
            AntiDodge.data[p] = s
        end
        return s
    end

    local function maxHold()
        return tonumber(Options.AntiDodgeMaxHold and Options.AntiDodgeMaxHold.Value) or 4.5
    end

    -- 无敌目标是否还值得继续锁着（超过最长等待就放掉，避免被无限无敌的挂机号拖住）
    function AntiDodge.IsLockable(p)
        if not isOn() or not p or p == LP then return false end
        local char = p.Character
        if not char then return false end
        local hum = char:FindFirstChildOfClass('Humanoid')
        if not hum or hum.Health <= 0 then return false end
        local inv = readMarkers(p, char)
        if not inv then return false end
        local s = AntiDodge.data[p]
        local since = (s and s.invSince and s.invSince > 0) and (tick() - s.invSince) or 0
        return since <= maxHold()
    end

    -- 是否应该暂停开火；第二个返回值是无敌已持续秒数
    function AntiDodge.ShouldHold(p)
        if not isOn() or not p then return false end
        local mode = (Options.AntiDodgeHoldMode and Options.AntiDodgeHoldMode.Value) or '停火等待（推荐）'
        if mode == '持续尝试（不停火）' then return false end
        local char = p.Character
        if not char then return false end
        local s = AntiDodge.data[p]
        local hasFF = char:FindFirstChildOfClass('ForceField') ~= nil
        -- 快速否定：既没力场、上一次采样也不是无敌，就不做完整扫描
        if not hasFF and not (s and s.wasInv) then return false end
        local hum = char:FindFirstChildOfClass('Humanoid')
        if not hum or hum.Health <= 0 then return false end
        local inv, name = readMarkers(p, char)
        if not inv then return false end
        local since = (s and s.invSince and s.invSince > 0) and (tick() - s.invSince) or 0
        if since > maxHold() then return false end
        if s then s.invReason = name or s.invReason end
        return true, since
    end

    -- 无敌刚结束时的一次性补枪发数（读完即清零）
    function AntiDodge.TakePenaltyShots(p)
        if not p then return 0 end
        local s = AntiDodge.data[p]
        if not s or (s.penaltyShots or 0) <= 0 then return 0 end
        if (tick() - (s.justEndedInv or 0)) > 0.8 then
            s.penaltyShots = 0
            return 0
        end
        local n = s.penaltyShots
        s.penaltyShots = 0
        return n
    end

    -- 被标记后的提前量：用实测速度外推一个 RTT + 少量提前，专治一直侧移躲枪
    function AntiDodge.GetLeadOffset(p, ping)
        if not isOn() or not p then return nil end
        local leadToggle = Toggles.AntiDodgeLead
        if leadToggle and leadToggle.Value == false then return nil end
        local s = AntiDodge.data[p]
        if not s or not s.dodgeFlag or not s.vel then return nil end
        local flat = Vector3.new(s.vel.X, 0, s.vel.Z)
        local speed = flat.Magnitude
        if speed < 8 or speed > 120 then return nil end
        local lead = math.clamp((ping or 0.06) + 0.05, 0.04, 0.15)
        return flat.Unit * math.min(speed * lead, 9)
    end

    function AntiDodge.OnShot(p)
        if not p or not isOn() then return end
        local s = AntiDodge.data[p]
        if not s then return end
        local now = tick()
        s.lastShotTick = now
        s.pendingShotTick = now
    end

    function AntiDodge.OnHit(p)
        local s = AntiDodge.data[p]
        if not s then return end
        s.lastHitTick = tick()
        s.pendingShotTick = 0
        s.dodgeScore = math.max(0, (s.dodgeScore or 0) - 3)
        if s.dodgeScore < 3 then s.dodgeFlag = false end
    end

    function AntiDodge.SetStatus(text)
        AntiDodge._lastText = text
        local lbl = AntiDodge.label
        if not lbl then return end
        local now = tick()
        if (now - (AntiDodge.lastStatus or 0)) < 0.15 then return end
        AntiDodge.lastStatus = now
        pcall(function() lbl:SetText(text) end)
    end

    -- 采样循环：无敌状态迁移 + 躲避特征打分
    task.spawn(function()
        while true do
            task.wait(0.08)
            if isOn() then
                local now = tick()
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LP then
                        local s = getState(p)
                        local char = p.Character
                        local hrp = char and char:FindFirstChild('HumanoidRootPart')
                        local hum = char and char:FindFirstChildOfClass('Humanoid')

                        if not char or not hrp or not hum or hum.Health <= 0 then
                            s.wasInv, s.invSince, s.char, s.lastPos = false, 0, char, nil
                            continue
                        end

                        if s.char ~= char then
                            s.char = char
                            s.lastPos = hrp.Position
                            s.lastTick = now
                            s.wasInv, s.invSince = false, 0
                            s.dodgeScore, s.dodgeFlag = 0, false
                            s.penaltyShots, s.justEndedInv = 0, 0
                        end

                        local inv, invName, dodgeMark = readMarkers(p, char)
                        local pos = hrp.Position
                        -- 车内目标本来就在高速移动，不能算闪避特征
                        local inVeh = false
                        pcall(function() inVeh = isInVehicle(p) == true end)

                        if inv then
                            if not s.wasInv then
                                s.invSince = now
                                s.invReason = invName
                                s.penaltyShots = 0
                                if Toggles.AntiDodgeNotify and Toggles.AntiDodgeNotify.Value and (now - (s.lastNotify or 0)) > 5 then
                                    s.lastNotify = now
                                    pcall(function()
                                        Library:Notify(string.format('[反躲避] %s 进入无敌（%s）→ 停火等待', p.DisplayName or p.Name, tostring(invName)), 3)
                                    end)
                                end
                            end
                            s.wasInv = true
                        elseif s.wasInv then
                            s.justEndedInv = now
                            s.penaltyShots = math.floor(tonumber(Options.AntiDodgeExtraFire and Options.AntiDodgeExtraFire.Value) or 3)
                            s.invReason = nil
                            if Toggles.AntiDodgeNotify and Toggles.AntiDodgeNotify.Value and (now - (s.lastNotify or 0)) > 3 then
                                s.lastNotify = now
                                pcall(function()
                                    Library:Notify(string.format('[反躲避] %s 无敌结束 → 立即补枪', p.DisplayName or p.Name), 2.5)
                                end)
                            end
                            s.wasInv = false
                        end

                        -- 空枪判定：出包后 0.45s 仍未掉血
                        if s.pendingShotTick > 0 and (now - s.pendingShotTick) > 0.45 then
                            s.pendingShotTick = 0
                            if not s.wasInv and not inVeh then
                                s.dodgeScore = math.min(MAX_SCORE, s.dodgeScore + 1)
                            end
                        end

                        -- 受击瞬间的侧移 / 瞬移 = 自动躲避脚本的核心特征
                        if s.lastPos then
                            local dt = now - s.lastTick
                            if dt > 0.02 then
                                local delta = pos - s.lastPos
                                local horiz = Vector2.new(delta.X, delta.Z).Magnitude
                                local speed = horiz / dt
                                local instVel = delta / dt
                                s.vel = s.vel and s.vel:Lerp(instVel, 0.45) or instVel
                                local sinceShot = now - (s.lastShotTick or 0)
                                if not inVeh and sinceShot < 0.32 then
                                    if horiz > 2.5 and speed > 55 then
                                        s.dodgeScore = math.min(MAX_SCORE, s.dodgeScore + 3)
                                    elseif horiz > 8 then
                                        s.dodgeScore = math.min(MAX_SCORE, s.dodgeScore + 2)
                                    end
                                end
                                s.lastPos, s.lastTick = pos, now
                            end
                        else
                            s.lastPos, s.lastTick = pos, now
                        end

                        -- 只有已经出现空枪 / 位移特征时，闪避标记才作为加权确认，避免常驻属性误报
                        if dodgeMark and s.dodgeScore >= 3 then
                            s.dodgeScore = math.min(MAX_SCORE, s.dodgeScore + 1)
                        end

                        if Toggles.AntiDodgeDetect == nil or Toggles.AntiDodgeDetect.Value then
                            if s.dodgeScore >= 6 and not s.dodgeFlag then
                                s.dodgeFlag = true
                                if detectedCheaters then
                                    local isNew = detectedCheaters[p] == nil
                                    detectedCheaters[p] = { reason = '自动躲避', time = now }
                                    if isNew and Toggles.CheaterNotify and Toggles.CheaterNotify.Value then
                                        pcall(function()
                                            Library:Notify(string.format('[检测到脚本] %s：自动躲避', p.DisplayName or p.Name), 4)
                                        end)
                                    end
                                end
                            end
                        else
                            s.dodgeFlag = false
                        end
                    end
                end
            else
                AntiDodge.evadeTarget = nil
            end
        end
    end)

    -- 「停火 + 后撤规避」：无敌期间往侧后方拉开，别站着挨打
    RunService.Heartbeat:Connect(function()
        if not isOn() then return end
        local mode = (Options.AntiDodgeHoldMode and Options.AntiDodgeHoldMode.Value) or ''
        if mode ~= '停火 + 后撤规避' then return end
        local p = AntiDodge.evadeTarget
        if not p then return end
        local myChar = LP.Character
        local myRoot = myChar and myChar:FindFirstChild('HumanoidRootPart')
        local myHum = myChar and myChar:FindFirstChildOfClass('Humanoid')
        local tChar = p.Character
        local tRoot = tChar and tChar:FindFirstChild('HumanoidRootPart')
        if not myRoot or not myHum or myHum.Health <= 0 or not tRoot then return end
        local away = myRoot.Position - tRoot.Position
        away = Vector3.new(away.X, 0, away.Z)
        if away.Magnitude < 1 then return end
        away = away.Unit
        local right = Vector3.new(-away.Z, 0, away.X)
        local dir = (away * 0.55 + right * 0.85)
        if dir.Magnitude > 0.01 then
            pcall(function() myHum:Move(dir.Unit, false) end)
        end
    end)
end

-- 目标扫描缓存：findAllRageBotTargets 会对每个玩家打 1~10 条 Raycast，
-- 100Hz 的循环里跑全图扫描，帧时间全花在选目标上。
-- fire() 里的 targetPos 是开火瞬间现取 targetPart.Position，所以缓存
-- 「打哪个部位」不影响命中，只需限制在 40ms 内复用。
local targetCache = { list = nil, at = 0, range = 0, brutal = false }

local function rageBotLoop()
    while Toggles.RageBot.Value do
        if not isAlive(LP) then
            task.wait(0.2)
            continue
        end

        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass('Humanoid')
        if (Toggles.RageBotDisableInVehicle == nil or Toggles.RageBotDisableInVehicle.Value) and (isInVehicle(LP) or (hum and hum.SeatPart)) then
            rageTargetPart = nil
            task.wait(0.2)
            continue
        end

        local curEquippedTool = LP.Character and LP.Character:FindFirstChildOfClass('Tool')
        local isHoldingGun = curEquippedTool and (knownGunNames[curEquippedTool.Name] or curEquippedTool:GetAttribute('ToolType') == 'Gun')

        local scanRange = 1500
        if not Toggles.RageBotAutoEquip.Value then
            if isHoldingGun then
                local c = getConfig(curEquippedTool)
                scanRange = (c and c.range) or 1100
            else
                scanRange = 0
            end
        end

        local targets = {}
        local brutalOn = Toggles.RageBotBrutal and Toggles.RageBotBrutal.Value
        local nowScan = tick()
        local cached = targetCache.list
        local cacheValid = cached
            and (nowScan - targetCache.at) < 0.04
            and targetCache.range == scanRange
            and targetCache.brutal == brutalOn
            and cached[1] and (isAlive(cached[1].player) or (_G.WXAntiDodge and _G.WXAntiDodge.IsLockable and _G.WXAntiDodge.IsLockable(cached[1].player)))

        if cacheValid then
            targets = cached
        else
            if brutalOn then
                targets = findAllRageBotTargets(scanRange)
            else
                local lethalTarget, lethalDist, lethalPart = findRageBotTargets(scanRange)
                if lethalTarget then
                    targets = { { player = lethalTarget, dist = lethalDist, part = lethalPart } }
                end
            end
            targetCache.list, targetCache.at = targets, nowScan
            targetCache.range, targetCache.brutal = scanRange, brutalOn
        end

        -- LETHAL THREAT (Criminal, Hostile Inmate, Enemy Guard)
        if #targets > 0 then
            local primary = targets[1]
            local primaryOk = primary and primary.player and primary.part and primary.part.Parent
                and (isAlive(primary.player) or (_G.WXAntiDodge and _G.WXAntiDodge.IsLockable and _G.WXAntiDodge.IsLockable(primary.player)))
            if not primaryOk then
                targetCache.at = 0
                task.wait(0.01)
                continue
            end

            -- 反自动躲避：目标在无敌帧里 → 保持锁定但一枪不打，无敌一消失立刻补枪
            if _G.WXAntiDodge then
                local hold, since = _G.WXAntiDodge.ShouldHold(primary.player)
                if hold then
                    _G.WXAntiDodge.evadeTarget = primary.player
                    _G.WXAntiDodge.SetStatus(string.format('反躲避：%s 无敌中 %.1fs · 停火等待', primary.player.Name, since or 0))
                    task.wait(0.02)
                    continue
                end

                _G.WXAntiDodge.evadeTarget = nil

                -- 无敌刚结束：按设置延迟一小段再出包，避免最后一帧同步没完被服务端吞掉
                local st = _G.WXAntiDodge.data[primary.player]
                if st and st.justEndedInv and st.justEndedInv > 0 then
                    local delay = tonumber(Options.AntiDodgeAttackDelay and Options.AntiDodgeAttackDelay.Value) or 0
                    if delay > 0 and (tick() - st.justEndedInv) < delay then
                        _G.WXAntiDodge.SetStatus(string.format('反躲避：%s 无敌结束 · 准备补枪', primary.player.Name))
                        task.wait(math.max(0.005, delay - (tick() - st.justEndedInv)))
                    end
                end
            end

            local activeGun = curEquippedTool
            if Toggles.RageBotAutoEquip.Value then
                local bestGun = selectBestLethalGun(primary.dist, curEquippedTool)
                if bestGun then
                    if curEquippedTool ~= bestGun then
                        equipGun(bestGun)
                        task.wait(0.04)
                        activeGun = bestGun
                    end
                end
            end

            if not activeGun or not activeGun.Parent or (not knownGunNames[activeGun.Name] and activeGun:GetAttribute('ToolType') ~= 'Gun') or activeGun.Name == 'Taser' then
                if Toggles.RageBotAutoWeapon.Value then
                    local gun = findNearestGun()
                    if gun then
                        givePlayerWeapon(gun, false)
                    end
                end
                task.wait(0.1)
                continue
            end

            local cfg = getConfig(activeGun)
            if not cfg then task.wait(0.05); continue end

            if primary.dist > (cfg.range or 1100) then
                task.wait(0.05)
                continue
            end

            local curAmmo = activeGun:GetAttribute('Local_CurrentAmmo') or activeGun:GetAttribute('CurrentAmmo') or 0
            if curAmmo > 0 and (activeGun:GetAttribute('Local_ReloadSession') or 0) > 0 then
                activeGun:SetAttribute('Local_ReloadSession', 0)
            end
            local isReloading = ((activeGun:GetAttribute('Local_ReloadSession') or 0) > 0) and (curAmmo <= 0)

            if isReloading then
                task.wait(0.05)
                continue
            end

            if curAmmo <= 0 then
                if Toggles.RageBotAutoEquip.Value then
                    local altGun = selectBestLethalGun(primary.dist, activeGun)
                    local altAmmo = altGun and (altGun:GetAttribute('Local_CurrentAmmo') or altGun:GetAttribute('CurrentAmmo') or 0)
                    if altGun and altGun ~= activeGun and altAmmo > 0 then
                        equipGun(altGun)
                        task.wait(0.04)
                        continue
                    end
                end
                task.spawn(doReload, activeGun, cfg)
                task.wait(0.05)
                continue
            end

            if cfg.chargeTime then
                local ct = cfg.chargeTime
                if Toggles.FireRateChanger and Toggles.FireRateChanger.Value and (Toggles.FireRateApplyRage == nil or Toggles.FireRateApplyRage.Value) then
                    ct = calculateModifiedFireRate(activeGun.Name, ct)
                end
                task.wait(ct)
            end

            rageTargetPart = primary.part
            local isBrutal = Toggles.RageBotBrutal and Toggles.RageBotBrutal.Value
            if isBrutal then
                -- 暴力清场：主目标 + 其余目标全部在同一帧内出包（fire 不再逐发等待），
                -- 一个循环只睡一次，循环频率由「连射间隔」决定
                fire(activeGun, primary.part, cfg, true)
                if #targets > 1 then
                    for i = 2, #targets do
                        local tp = targets[i]
                        if tp and tp.player and tp.part and tp.part.Parent and isAlive(tp.player) and tp.dist <= (cfg.range or 1100) then
                            rageTargetPart = tp.part
                            fire(activeGun, tp.part, cfg, true)
                        end
                    end
                end
                task.wait((Options.RageBrutalDelay and Options.RageBrutalDelay.Value) or 0.01)
            else
                fire(activeGun, primary.part, cfg)
                task.wait(0.01)
            end
            continue

        -- NO TARGETS FOUND
        else
            rageTargetPart = nil
            if _G.WXAntiDodge then
                _G.WXAntiDodge.evadeTarget = nil
                _G.WXAntiDodge.SetStatus('反躲避：无目标')
            end
            if not isHoldingGun and Toggles.RageBotAutoWeapon.Value then
                local gun = findNearestGun()
                if gun then
                    givePlayerWeapon(gun, false)
                end
            end
            task.wait(0.05)
            continue
        end
    end
    rageTargetPart = nil
    rageBotRunning = false
end

-- Ragebot Indicator
Toggles.RageBot:OnChanged(function()
    if Toggles.RageBot.Value and not rageBotRunning then
        rageBotRunning = true
        task.spawn(rageBotLoop)
    elseif not Toggles.RageBot.Value then
        targetCache.at = 0
    end
    rageIndicatorText.Visible = Toggles.RageBot.Value
end)

-- Tool ammo synchronization & tracking
local currentToolConnection = nil
local function hookToolAmmo(tool)
    if currentToolConnection then
        currentToolConnection:Disconnect()
        currentToolConnection = nil
    end
    if not tool or not tool:IsA('Tool') then return end

    local sAmmo = tool:GetAttribute('CurrentAmmo')
    if sAmmo ~= nil and tool:GetAttribute('Local_CurrentAmmo') == nil then
        tool:SetAttribute('Local_CurrentAmmo', sAmmo)
    end

    local conn = tool:GetAttributeChangedSignal('CurrentAmmo'):Connect(function()
        local serverAmmo = tool:GetAttribute('CurrentAmmo')
        if serverAmmo == nil then return end
        local localAmmo = tool:GetAttribute('Local_CurrentAmmo')
        if serverAmmo > 0 then
            tool:SetAttribute('Local_ReloadSession', 0)
        end
        if localAmmo == nil or serverAmmo <= localAmmo or serverAmmo > (localAmmo or 0) or (tick() - lastShotTick > 0.5) then
            tool:SetAttribute('Local_CurrentAmmo', serverAmmo)
            local cfg = getConfig(tool)
            updateHudAmmo(tool, serverAmmo, cfg)
        end
    end)
    currentToolConnection = conn
end

local function setupCharToolTracking(char)
    if not char then return end
    local curTool = char:FindFirstChildOfClass('Tool')
    if curTool then hookToolAmmo(curTool) end
    char.ChildAdded:Connect(function(child)
        if child:IsA('Tool') then hookToolAmmo(child) end
    end)
    char.ChildRemoved:Connect(function(child)
        if child:IsA('Tool') then
            if currentToolConnection then
                currentToolConnection:Disconnect()
                currentToolConnection = nil
            end
        end
    end)
end

if LP.Character then
    setupCharToolTracking(LP.Character)
end
LP.CharacterAdded:Connect(setupCharToolTracking)

-- ====================== VOID AURA (HVH EDITION) ======================
do
    local voidRunning = false
    local voidBV = nil
    local voidCycleIndex = 1
    local initialGroundCF = nil
    local orbitAngle = 0
    local lastAttackTick = 0
    local lastCycleTick = 0
    local lastMeleeTick = 0
    local blinkTimer = 0
    local blinkPhase = 'strike'
    local currentVoidTargetPlayer = nil
    local currentVoidTargetPart = nil
    local noclipParts = {}
    local voidHeartbeatConn = nil
    local voidSteppedConn = nil

    local function getMeleeRemote()
        return ReplicatedStorage:FindFirstChild('meleeEvent')
            or (ReplicatedStorage:FindFirstChild('Remotes') and ReplicatedStorage.Remotes:FindFirstChild('meleeEvent'))
    end

    local function cleanupVoidMovers()
        if voidBV then
            pcall(function() voidBV:Destroy() end)
            voidBV = nil
        end
    end

    local function ensureVoidBodyVelocity(root)
        if not root or not root.Parent then return end
        if not voidBV or voidBV.Parent ~= root then
            cleanupVoidMovers()
            local existing = root:FindFirstChild('VoidHoldBV')
            if existing and existing:IsA('BodyVelocity') then
                voidBV = existing
            else
                local bv = Instance.new('BodyVelocity')
                bv.Name = 'VoidHoldBV'
                bv.MaxForce = Vector3.new(1e8, 1e8, 1e8)
                bv.Velocity = Vector3.zero
                bv.Parent = root
                voidBV = bv
            end
        end
        if voidBV then
            voidBV.MaxForce = Vector3.new(1e8, 1e8, 1e8)
            voidBV.Velocity = Vector3.zero
        end
    end

    local function restoreVoidNoclip(char)
        if char then
            for part, origState in pairs(noclipParts) do
                if part and part.Parent and part:IsDescendantOf(char) then
                    pcall(function() part.CanCollide = origState end)
                end
            end
        end
        table.clear(noclipParts)
    end

    local function applyVoidNoclip(char)
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA('BasePart') then
                if noclipParts[part] == nil then
                    noclipParts[part] = part.CanCollide
                end
                part.CanCollide = false
            end
        end
    end

    local function autoEquipBestWeapon(char, hum)
        local bp = LP:FindFirstChild('Backpack')
        if not bp or not hum then return nil end

        local priority = { 'Remington 870', 'AK-47', 'M4A1', 'M9', 'Crude Knife', 'Hammer' }
        for _, gunName in ipairs(priority) do
            local item = bp:FindFirstChild(gunName)
            if item and item:IsA('Tool') then
                hum:EquipTool(item)
                return item
            end
        end

        for _, item in ipairs(bp:GetChildren()) do
            if item:IsA('Tool') then
                hum:EquipTool(item)
                return item
            end
        end
        return nil
    end

    -- 3D Flight Position Generator
    local function calculateHvHPosition(targetPart, posMode, dist, height, dt)
        local targetPos = targetPart.Position
        local targetCF = targetPart.CFrame
        local look = targetCF.LookVector
        local flatLook = Vector3.new(look.X, 0, look.Z)
        if flatLook.Magnitude > 0.001 then
            flatLook = flatLook.Unit
        else
            flatLook = Vector3.new(0, 0, -1)
        end
        local flatRight = Vector3.new(-flatLook.Z, 0, flatLook.X)

        local orbitSpeed = (Options.VoidOrbitSpeed and Options.VoidOrbitSpeed.Value) or 16
        orbitAngle = (orbitAngle + (dt * orbitSpeed)) % (math.pi * 2)

        if posMode == '3D Cyclone Orbit (HvH)' or posMode == 'Orbit / Cyclone (HvH)' then
            local waveY = math.sin(orbitAngle * 2.2) * 2.0
            local offset = Vector3.new(math.cos(orbitAngle) * dist, (height or 2) + waveY, math.sin(orbitAngle) * dist)
            return targetPos + offset

        elseif posMode == '3D Helix / Corkscrew (HvH)' then
            local vPhase = math.sin(orbitAngle * 1.8) * 3.5
            local rPhase = 1 + 0.2 * math.cos(orbitAngle * 2.6)
            local offset = Vector3.new(math.cos(orbitAngle) * (dist * rPhase), (height or 2) + vPhase, math.sin(orbitAngle) * (dist * rPhase))
            return targetPos + offset

        elseif posMode == 'Spherical Chaos / Evasive' then
            local pitch = math.sin(orbitAngle * 0.75) * 0.85
            local r = dist
            local x = r * math.cos(pitch) * math.cos(orbitAngle)
            local z = r * math.cos(pitch) * math.sin(orbitAngle)
            local y = (height or 1) + (r * math.sin(pitch))
            return targetPos + Vector3.new(x, y, z)

        elseif posMode == 'Behind Target (Backstab Flank)' or posMode == 'Behind Target (Backstab)' then
            local weave = math.sin(tick() * 5.5) * (dist * 0.45)
            local behindPos = targetPos - (flatLook * dist) + (flatRight * weave) + Vector3.new(0, height or 1, 0)
            return behindPos

        elseif posMode == 'Above Target (Sky Stomp)' then
            local wobbleX = math.cos(orbitAngle) * math.min(dist, 4)
            local wobbleZ = math.sin(orbitAngle) * math.min(dist, 4)
            local abovePos = targetPos + Vector3.new(wobbleX, math.max(5, height or 10), wobbleZ)
            return abovePos

        elseif posMode == 'Underground (Void Floor)' then
            local belowPos = targetPos - Vector3.new(0, math.max(2, math.abs(height or 7)), 0)
            return belowPos

        elseif posMode == 'Jitter Random Flank' then
            local ang = math.random() * math.pi * 2
            local rndDist = math.clamp(dist + math.random(-1, 1), 2, 20)
            local rndY = (height or 0) + math.random(-1, 2)
            local jitterPos = targetPos + Vector3.new(math.cos(ang) * rndDist, rndY, math.sin(ang) * rndDist)
            return jitterPos

        elseif posMode == 'Stay At Enable Position' then
            local safePos = (initialGroundCF and initialGroundCF.Position or targetPos) + Vector3.new(0, math.max(10, height or 25), 0)
            return safePos
        end

        local defaultOffset = Vector3.new(math.cos(orbitAngle) * dist, height or 2, math.sin(orbitAngle) * dist)
        return targetPos + defaultOffset
    end

    -- Wall LoS Solver for RageBot
    local function checkLoSToTarget(originPos, tPart, tPlayer)
        if hasLineOfSight(originPos, tPart.Position, tPlayer) then
            return true, tPart
        end
        if tPlayer and tPlayer.Character then
            local altPart = (tPart.Name == 'Head') and tPlayer.Character:FindFirstChild('HumanoidRootPart') or tPlayer.Character:FindFirstChild('Head')
            if altPart and hasLineOfSight(originPos, altPart.Position, tPlayer) then
                return true, altPart
            end
        end
        return false, tPart
    end

    local function solveLineOfSightPosition(targetPlayer, targetPart, candPos, baseDist, baseHeight)
        local targetPos = targetPart.Position
        local candHeadPos = candPos + Vector3.new(0, 1.5, 0)
        local losOk, validPart = checkLoSToTarget(candHeadPos, targetPart, targetPlayer)
        if losOk then
            return candPos, validPart
        end

        if Toggles.VoidLoSSolver and not Toggles.VoidLoSSolver.Value then
            return candPos, targetPart
        end

        -- Target is behind a wall or obstacle!
        -- 1. Try 8 radial angles around the target at baseDist
        local curAng = math.atan2(candPos.Z - targetPos.Z, candPos.X - targetPos.X)
        for i = 1, 7 do
            local sign = (i % 2 == 1) and 1 or -1
            local step = math.ceil(i / 2)
            local testAng = curAng + (sign * step * (math.pi / 4))
            local testPos = targetPos + Vector3.new(math.cos(testAng) * baseDist, baseHeight, math.sin(testAng) * baseDist)
            local testHead = testPos + Vector3.new(0, 1.5, 0)
            local ok, p = checkLoSToTarget(testHead, targetPart, targetPlayer)
            if ok then
                return testPos, p
            end
        end

        -- 2. Pull inward towards target to phase inside room/barrier
        local closeDistances = { 4.5, 3.2, 2.4, 1.8 }
        for _, d in ipairs(closeDistances) do
            if d < baseDist then
                local testPos = targetPos + Vector3.new(math.cos(curAng) * d, math.clamp(baseHeight, -0.2, 2.0), math.sin(curAng) * d)
                local testHead = testPos + Vector3.new(0, 1.5, 0)
                local ok, p = checkLoSToTarget(testHead, targetPart, targetPlayer)
                if ok then
                    return testPos, p
                end

                for i = 1, 7 do
                    local sign = (i % 2 == 1) and 1 or -1
                    local step = math.ceil(i / 2)
                    local testAng = curAng + (sign * step * (math.pi / 4))
                    local angPos = targetPos + Vector3.new(math.cos(testAng) * d, math.clamp(baseHeight, -0.2, 2.0), math.sin(testAng) * d)
                    local angHead = angPos + Vector3.new(0, 1.5, 0)
                    local aOk, aP = checkLoSToTarget(angHead, targetPart, targetPlayer)
                    if aOk then
                        return angPos, aP
                    end
                end
            end
        end

        -- 3. Point-blank fallbacks
        local tCF = targetPart.CFrame
        local flatLook = Vector3.new(tCF.LookVector.X, 0, tCF.LookVector.Z)
        if flatLook.Magnitude > 0.001 then flatLook = flatLook.Unit else flatLook = Vector3.new(0, 0, -1) end

        local pointBlankBehind = targetPos - (flatLook * 2.0) + Vector3.new(0, 0.5, 0)
        local ok1, p1 = checkLoSToTarget(pointBlankBehind + Vector3.new(0, 1.5, 0), targetPart, targetPlayer)
        if ok1 then return pointBlankBehind, p1 end

        local pointBlankAbove = targetPos + Vector3.new(0, 2.4, 0)
        local ok2, p2 = checkLoSToTarget(pointBlankAbove + Vector3.new(0, 1.5, 0), targetPart, targetPlayer)
        if ok2 then return pointBlankAbove, p2 end

        local pointBlankFront = targetPos + (flatLook * 2.0) + Vector3.new(0, 0.5, 0)
        local ok3, p3 = checkLoSToTarget(pointBlankFront + Vector3.new(0, 1.5, 0), targetPart, targetPlayer)
        if ok3 then return pointBlankFront, p3 end

        return pointBlankBehind, targetPart
    end

    local function snapToPosition(root, targetCF, method, dt)
        if not root or not root.Parent then return end

        local finalCF = targetCF
        if Toggles.VoidAntiTargetLock and Toggles.VoidAntiTargetLock.Value then
            local microJitter = Vector3.new(
                (math.random() - 0.5) * 0.45,
                (math.random() - 0.5) * 0.35,
                (math.random() - 0.5) * 0.45
            )
            finalCF = finalCF + microJitter
        end

        if method == 'Instant Teleport (0ms HvH Snap)' then
            root.CFrame = finalCF
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero

        elseif method == 'Smooth Ultra-Glide' then
            local curPos = root.Position
            local targetPos = finalCF.Position
            local delta = targetPos - curPos
            local dist = delta.Magnitude
            if dist <= 0.8 or dist > 180 then
                root.CFrame = finalCF
            else
                local glideSpeed = 380
                local step = math.min(dist, glideSpeed * (dt or 0.016))
                local newPos = curPos + (delta.Unit * step)
                root.CFrame = CFrame.lookAt(newPos, targetPos + finalCF.LookVector * 2)
            end
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero

        elseif method == 'Blink Flank (In & Out)' then
            blinkTimer = blinkTimer + (dt or 0.016)
            if blinkPhase == 'strike' then
                root.CFrame = finalCF
                if blinkTimer >= 0.08 then
                    blinkPhase = 'evade'
                    blinkTimer = 0
                end
            else
                local evadeCF = finalCF + Vector3.new(0, 28, 0)
                root.CFrame = evadeCF
                if blinkTimer >= 0.12 then
                    blinkPhase = 'strike'
                    blinkTimer = 0
                end
            end
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        else
            root.CFrame = finalCF
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
    end

    local function performHvHAttack(targetPlayer, targetPart)
        if not targetPlayer or not targetPart then return end
        if not IsValidTarget(targetPlayer) then return end

        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass('Humanoid')
        local root = char and char:FindFirstChild('HumanoidRootPart')
        if not char or not hum or hum.Health <= 0 or not root then return end

        local atkMode = (Options.VoidAttackType and Options.VoidAttackType.Value) or 'Gun & Melee'

        -- 1. Rapid Melee Punch (when within strike range)
        if atkMode == 'Gun & Melee' or atkMode == 'Melee Only (Punch)' then
            local myPos = root.Position
            local theirPos = targetPart.Position
            local dist = (myPos - theirPos).Magnitude

            if dist <= 9 and (tick() - lastMeleeTick >= 0.05) then
                lastMeleeTick = tick()
                local melee = getMeleeRemote()
                if melee then
                    pcall(function()
                        melee:FireServer(targetPlayer, 1, 1)
                    end)
                end
            end
        end

        -- 2. Gun Shot (Hitscan headshot with double tap and rapid fire integration)
        if atkMode == 'Gun & Melee' or atkMode == 'Gun Only' then
            local tool = char:FindFirstChildOfClass('Tool')
            if not tool and Toggles.VoidAutoEquip and Toggles.VoidAutoEquip.Value then
                tool = autoEquipBestWeapon(char, hum)
            end

            if tool and (gunConfigs[tool.Name] or tool:FindFirstChild('Muzzle')) then
                local cfg = getConfig(tool)
                if cfg then
                    local curAmmo = tool:GetAttribute('Local_CurrentAmmo') or tool:GetAttribute('CurrentAmmo') or 0
                    local isReloading = ((tool:GetAttribute('Local_ReloadSession') or 0) > 0) and (curAmmo <= 0)

                    if curAmmo <= 0 and not isReloading then
                        task.spawn(doReload, tool, cfg)
                    elseif not isReloading then
                        local minDelay = cfg.chargeTime or 0.12
                        if Toggles.FireRateChanger and Toggles.FireRateChanger.Value and (Toggles.FireRateApplyRage == nil or Toggles.FireRateApplyRage.Value) then
                            minDelay = calculateModifiedFireRate(tool.Name, minDelay)
                        end

                        if tick() - lastShotTick >= minDelay then
                            pcall(function()
                                fire(tool, targetPart, cfg)
                            end)
                        end
                    end
                end
            end
        end
    end

    local function getVoidTarget()
        local mode = (Options.VoidTargetMode and Options.VoidTargetMode.Value) or 'Nearest Enemy'
        local char = LP.Character
        local root = char and char:FindFirstChild('HumanoidRootPart')
        local myPos = root and root.Position or Vector3.zero

        if mode == 'Selected Player' then
            local selName = Options.VoidSelectedPlayer and Options.VoidSelectedPlayer.Value
            if selName and selName ~= 'None' then
                local p = Players:FindFirstChild(selName)
                if p and IsValidTarget(p) then
                    local pChar = p.Character
                    local part = pChar and (pChar:FindFirstChild('Head') or pChar:FindFirstChild('HumanoidRootPart'))
                    if part then return p, part end
                end
            end
            return nil, nil
        end

        if mode == 'Lowest HP (Executer)' then
            local bestP, bestPart, minHp = nil, nil, math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and IsValidTarget(p) then
                    local pChar = p.Character
                    local hum = pChar and pChar:FindFirstChildOfClass('Humanoid')
                    local part = pChar and (pChar:FindFirstChild('Head') or pChar:FindFirstChild('HumanoidRootPart'))
                    if hum and part and hum.Health > 0 then
                        if hum.Health < minHp then
                            minHp = hum.Health
                            bestP = p
                            bestPart = part
                        end
                    end
                end
            end
            return bestP, bestPart
        end

        if mode == 'All Enemies (Carnage Cycle)' then
            local validList = {}
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and IsValidTarget(p) then
                    local pChar = p.Character
                    local part = pChar and (pChar:FindFirstChild('Head') or pChar:FindFirstChild('HumanoidRootPart'))
                    if part then
                        table.insert(validList, { player = p, part = part })
                    end
                end
            end
            if #validList == 0 then return nil, nil end

            local cycleDelay = (Options.VoidCycleDelay and Options.VoidCycleDelay.Value) or 0.12
            if tick() - lastCycleTick >= cycleDelay then
                lastCycleTick = tick()
                voidCycleIndex = (voidCycleIndex % #validList) + 1
            end

            if voidCycleIndex > #validList then voidCycleIndex = 1 end
            local entry = validList[voidCycleIndex]
            if entry then
                return entry.player, entry.part
            end
            return nil, nil
        end

        if mode == 'RageBot / Current' then
            if rageTargetPart and rageTargetPart.Parent then
                local p = Players:GetPlayerFromCharacter(rageTargetPart.Parent)
                if p and IsValidTarget(p) then return p, rageTargetPart end
            end
            if targetPartCache and targetPartCache.Parent then
                local p = Players:GetPlayerFromCharacter(targetPartCache.Parent)
                if p and IsValidTarget(p) then return p, targetPartCache end
            end
            local near = FindNearestTarget()
            if near and near.Parent then
                local p = Players:GetPlayerFromCharacter(near.Parent)
                if p and IsValidTarget(p) then return p, near end
            end
        end

        -- Default: Nearest Enemy
        local bestP, bestPart, minDist = nil, nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and IsValidTarget(p) then
                local pChar = p.Character
                local part = pChar and (pChar:FindFirstChild('Head') or pChar:FindFirstChild('HumanoidRootPart'))
                if part then
                    local d = (part.Position - myPos).Magnitude
                    if d < minDist then
                        minDist = d
                        bestP = p
                        bestPart = part
                    end
                end
            end
        end
        return bestP, bestPart
    end

    -- Continuous 60 FPS Flight Loop (No task.wait stutters, no gravity fall)
    local function onVoidHeartbeat(dt)
        if not voidRunning or not (Toggles.VoidAura and Toggles.VoidAura.Value) then
            return
        end

        local char = LP.Character
        local root = char and char:FindFirstChild('HumanoidRootPart')
        local hum = char and char:FindFirstChildOfClass('Humanoid')

        if not root or not hum or hum.Health <= 0 then
            return
        end

        ensureVoidBodyVelocity(root)
        pcall(function() hum.PlatformStand = true end)
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero

        -- Void Reload Handler (teleports into void during weapon reload)
        local tool = char:FindFirstChildOfClass('Tool')
        local isReloading = false
        if tool then
            local session = tool:GetAttribute('Local_ReloadSession') or 0
            local curAmmo = tool:GetAttribute('Local_CurrentAmmo') or tool:GetAttribute('CurrentAmmo') or 0
            local maxAmmo = tool:GetAttribute('MaxAmmo') or 1
            if session > 0 and curAmmo < maxAmmo then
                isReloading = true
            end
        end

        local voidReloadEnabled = (Toggles.VoidReload == nil or Toggles.VoidReload.Value) and (Toggles.VoidAuraReloadInVoid == nil or Toggles.VoidAuraReloadInVoid.Value)
        if isReloading and voidReloadEnabled then
            local voidY = _G.BoarsVoidGuard.safeY((Options.VoidReloadDepth and Options.VoidReloadDepth.Value) or -70)
            local basePos = (currentVoidTargetPart and currentVoidTargetPart.Position) or (initialGroundCF and initialGroundCF.Position) or root.Position
            local voidCF = CFrame.new(basePos.X, voidY, basePos.Z)
            -- 不锚定（光环本身每帧重设 CFrame），只关触碰/碰撞并看护血量
            if _G.BoarsVoidGuard.enabled() then
                pcall(function() _G.BoarsVoidGuard:begin(false) end)
            end
            snapToPosition(root, voidCF, 'Instant Teleport (0ms HvH Snap)', dt)
            return
        end

        -- 换弹结束：撤销虚空保护，恢复触碰/碰撞与站立状态
        if _G.BoarsVoidGuard.active then
            pcall(function() _G.BoarsVoidGuard:finish(false) end)
            -- 若人还留在地下，先抬回地面附近，避免被坠落判定吃掉
            if root.Position.Y < -40 then
                local baseUp = initialGroundCF and initialGroundCF.Position or root.Position
                pcall(function()
                    root.CFrame = CFrame.new(baseUp.X, math.max(baseUp.Y + 30, 5), baseUp.Z)
                end)
            end
        end

        local targetPlayer, targetPart = getVoidTarget()
        currentVoidTargetPlayer = targetPlayer
        currentVoidTargetPart = targetPart

        local posMode = (Options.VoidPositionType and Options.VoidPositionType.Value) or '3D Cyclone Orbit (HvH)'
        local strikeMethod = (Options.VoidStrikeMethod and Options.VoidStrikeMethod.Value) or 'Instant Teleport (0ms HvH Snap)'
        local dist = (Options.VoidDistance and Options.VoidDistance.Value) or 4
        local height = (Options.VoidHeight and Options.VoidHeight.Value) or 2

        if targetPlayer and targetPart then
            -- 1. 3D Dynamic Flight Generator
            local idealPos = calculateHvHPosition(targetPart, posMode, dist, height, dt)

            -- 2. Wall LoS Solver (adjusts angle or breaches closer to ensure RageBot raycast hits)
            local finalPos, bestPart = solveLineOfSightPosition(targetPlayer, targetPart, idealPos, dist, height)
            currentVoidTargetPart = bestPart

            local targetCF = CFrame.lookAt(finalPos, targetPart.Position)
            snapToPosition(root, targetCF, strikeMethod, dt)
        else
            if initialGroundCF then
                local safeCF = initialGroundCF + Vector3.new(0, 30, 0)
                snapToPosition(root, safeCF, 'Instant Teleport (0ms HvH Snap)', dt)
            end
        end
    end

    -- Continuous Collision Bypass
    local function onVoidStepped()
        if voidRunning and Toggles.VoidNoclip and Toggles.VoidNoclip.Value then
            local char = LP.Character
            if char then
                applyVoidNoclip(char)
            end
        end
    end

    -- Dedicated Attack Loop (Decoupled from 60 FPS flight positioning)
    task.spawn(function()
        while true do
            local delayTime = (Options.VoidAttackDelay and Options.VoidAttackDelay.Value) or 0.03
            task.wait(math.clamp(delayTime, 0.01, 0.5))

            if not voidRunning or not (Toggles.VoidAura and Toggles.VoidAura.Value) then
                continue
            end

            if currentVoidTargetPlayer and currentVoidTargetPart then
                performHvHAttack(currentVoidTargetPlayer, currentVoidTargetPart)
            end
        end
    end)

    Toggles.VoidAura:OnChanged(function()
        if Toggles.VoidAura.Value then
            if voidRunning then return end
            voidRunning = true
            blinkTimer = 0
            blinkPhase = 'strike'
            local char = LP.Character
            local root = char and char:FindFirstChild('HumanoidRootPart')
            local hum = char and char:FindFirstChildOfClass('Humanoid')
            if root then
                initialGroundCF = root.CFrame
                ensureVoidBodyVelocity(root)
            end
            if hum then
                pcall(function() hum.PlatformStand = true end)
            end
            if char and Toggles.VoidNoclip and Toggles.VoidNoclip.Value then
                applyVoidNoclip(char)
            end

            if not voidHeartbeatConn then
                voidHeartbeatConn = RunService.Heartbeat:Connect(onVoidHeartbeat)
            end
            if not voidSteppedConn then
                voidSteppedConn = RunService.Stepped:Connect(onVoidStepped)
            end
        else
            voidRunning = false
            currentVoidTargetPlayer = nil
            currentVoidTargetPart = nil

            if voidHeartbeatConn then
                voidHeartbeatConn:Disconnect()
                voidHeartbeatConn = nil
            end
            if voidSteppedConn then
                voidSteppedConn:Disconnect()
                voidSteppedConn = nil
            end

            cleanupVoidMovers()
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass('Humanoid')
            local root = char and char:FindFirstChild('HumanoidRootPart')
            if hum then
                pcall(function()
                    hum.PlatformStand = false
                    hum:ChangeState(Enum.HumanoidStateType.Freefall)
                end)
            end
            if root and initialGroundCF then
                root.CFrame = initialGroundCF
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
            end
            restoreVoidNoclip(char)
            initialGroundCF = nil
        end
    end)

    LP.CharacterAdded:Connect(function(newChar)
        if voidRunning and Toggles.VoidAura and Toggles.VoidAura.Value then
            task.wait(0.1)
            local root = newChar:WaitForChild('HumanoidRootPart', 3)
            local hum = newChar:WaitForChild('Humanoid', 3)
            if root then
                ensureVoidBodyVelocity(root)
            end
            if hum then
                pcall(function() hum.PlatformStand = true end)
            end
            if Toggles.VoidNoclip and Toggles.VoidNoclip.Value then
                applyVoidNoclip(newChar)
            end
        end
    end)

    local function updateVoidPlayers()
        if not Options.VoidSelectedPlayer then return end
        local names = { 'None' }
        for _, p in Players:GetPlayers() do
            if p ~= LP then
                table.insert(names, p.Name)
            end
        end
        Options.VoidSelectedPlayer.Values = names
        if Options.VoidSelectedPlayer.SetValues then
            Options.VoidSelectedPlayer:SetValues(names)
        end
    end
    Players.PlayerAdded:Connect(updateVoidPlayers)
    Players.PlayerRemoving:Connect(updateVoidPlayers)
    task.spawn(function()
        task.wait(1)
        updateVoidPlayers()
    end)
end

-- ESP
local espObjects = {}
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "CustomESP"
ESPFolder.Parent = game:GetService("CoreGui")

local function getPlayerCategory(player)
    if not player or player == LP then return nil end
    if player.Team == Teams.Inmates and player:GetAttribute('Hostile') then
        return 'Hostile'
    elseif player.Team == Teams.Inmates then
        return 'Inmate'
    elseif player.Team == Teams.Guards then
        return 'Guard'
    elseif player.Team == Teams.Criminals then
        return 'Criminal'
    end
    return nil
end

local function espColorForCategory(cat)
    if cat == 'Inmate' then return Options.ESPInmatesColor.Value end
    if cat == 'Guard' then return Options.ESPGuardsColor.Value end
    if cat == 'Hostile' then return Options.ESPHostileColor.Value end
    if cat == 'Criminal' then return Options.ESPCriminalsColor.Value end
    return Color3.new(1, 1, 1)
end

local function rainbowToggleForCategory(cat)
    if cat == 'Inmate' then return Toggles.ESPInmatesRainbow.Value end
    if cat == 'Guard' then return Toggles.ESPGuardsRainbow.Value end
    if cat == 'Hostile' then return Toggles.ESPHostileRainbow.Value end
    if cat == 'Criminal' then return Toggles.ESPCriminalsRainbow.Value end
    return false
end

local function playerHasShield(player, char)
    if not char then return false end
    if char:FindFirstChildOfClass("ForceField") then
        return true
    end
    if char:FindFirstChild("RiotShieldPart") or char:FindFirstChild("Riot Shield") then
        return true
    end
    local bp = player and player:FindFirstChild("Backpack")
    if bp and bp:FindFirstChild("Riot Shield") then
        return true
    end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") and string.find(string.lower(child.Name), "shield") then
            return true
        end
    end
    return false
end

local function removeESP(player)
    local obj = espObjects[player]
    if obj then obj.cleanup() end
    espObjects[player] = nil
end

local function createESP(player)
    if espObjects[player] then return end
    local hl = nil
    local skeletonLines = {}
    local boxLines = {}
    local weaponText = nil
    local nameText = nil
    local hpCounter = nil
    local shieldText = nil

    local function makeLine()
        local l = Drawing.new("Line")
        l.Visible = false l.Color = Color3.new(1,1,1) l.Thickness = 1 l.Transparency = 1
        return l
    end

    local function worldToScreen(pos)
        local s, v = workspace.CurrentCamera:WorldToViewportPoint(pos)
        if v then return Vector2.new(s.X, s.Y) end
        return nil
    end

    local function getBoxBounds(char)
        local root = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        if not root or not head then return nil end
        local topLeft3D = root.Position + Vector3.new(-2, 3, 0)
        local topRight3D = root.Position + Vector3.new(2, 3, 0)
        local bottomLeft3D = root.Position + Vector3.new(-2, -3, 0)
        local bottomRight3D = root.Position + Vector3.new(2, -3, 0)
        local topScreen = worldToScreen(topLeft3D)
        local topRightScreen = worldToScreen(topRight3D)
        local bottomScreen = worldToScreen(bottomLeft3D)
        local bottomRightScreen = worldToScreen(bottomRight3D)
        if not topScreen or not topRightScreen or not bottomScreen or not bottomRightScreen then return nil end
        local minX = math.min(topScreen.X, topRightScreen.X, bottomScreen.X, bottomRightScreen.X)
        local maxX = math.max(topScreen.X, topRightScreen.X, bottomScreen.X, bottomRightScreen.X)
        local minY = math.min(topScreen.Y, topRightScreen.Y, bottomScreen.Y, bottomRightScreen.Y)
        local maxY = math.max(topScreen.Y, topRightScreen.Y, bottomScreen.Y, bottomRightScreen.Y)
        return Vector2.new(minX, minY), Vector2.new(maxX, maxY)
    end

    local function cleanupAll()
        if hl and hl.Parent then hl:Destroy() hl = nil end
        for _, l in pairs(skeletonLines) do pcall(function() l:Remove() end) end
        for _, l in pairs(boxLines) do pcall(function() l:Remove() end) end
        if weaponText then pcall(function() weaponText:Remove() end) weaponText = nil end
        if nameText then pcall(function() nameText:Remove() end) nameText = nil end
        if hpCounter then pcall(function() hpCounter:Remove() end) hpCounter = nil end
        if shieldText then pcall(function() shieldText:Remove() end) shieldText = nil end
        local obj = espObjects[player]
        if obj then
            if obj.healthBarBg then pcall(function() obj.healthBarBg:Remove() end) end
            if obj.healthBarFill then pcall(function() obj.healthBarFill:Remove() end) end
        end
        espObjects[player] = nil
    end

    espObjects[player] = {
        cleanup = cleanupAll,
        update = function()
            pcall(function()
                local char = player.Character
                if not char then cleanupAll() return end
                local hum = char:FindFirstChild("Humanoid")
                local root = char:FindFirstChild("HumanoidRootPart")
                local head = char:FindFirstChild("Head")
                if not hum or not root or not head or hum.Health <= 0 then cleanupAll() return end

                local cat = getPlayerCategory(player)
                local ec = espColorForCategory(cat)
                if not ec then ec = Color3.new(1,1,1) end
                if cat and rainbowToggleForCategory(cat) then ec = Color3.fromHSV(rainbowHue, 1, 1) end

                -- Highlight
                if Toggles.ESPHighlight.Value then
                    if not hl or not hl.Parent then
                        hl = Instance.new("Highlight") hl.FillTransparency = 0.6 hl.OutlineTransparency = 0
                        hl.FillColor = ec hl.OutlineColor = ec hl.Adornee = char hl.Parent = ESPFolder
                    end
                    hl.FillColor = ec hl.OutlineColor = ec
                elseif hl and hl.Parent then hl:Destroy() hl = nil end

                -- Box ESP
                if Toggles.ESPBox.Value then
                    local tl, br = getBoxBounds(char)
                    if tl and br then
                        if not boxLines[1] then for i = 1, 4 do boxLines[i] = makeLine() end end
                        boxLines[1].From = Vector2.new(tl.X, tl.Y) boxLines[1].To = Vector2.new(br.X, tl.Y) boxLines[1].Color = ec boxLines[1].Thickness = 1.5 boxLines[1].Visible = true
                        boxLines[2].From = Vector2.new(tl.X, br.Y) boxLines[2].To = Vector2.new(br.X, br.Y) boxLines[2].Color = ec boxLines[2].Thickness = 1.5 boxLines[2].Visible = true
                        boxLines[3].From = Vector2.new(tl.X, tl.Y) boxLines[3].To = Vector2.new(tl.X, br.Y) boxLines[3].Color = ec boxLines[3].Thickness = 1.5 boxLines[3].Visible = true
                        boxLines[4].From = Vector2.new(br.X, tl.Y) boxLines[4].To = Vector2.new(br.X, br.Y) boxLines[4].Color = ec boxLines[4].Thickness = 1.5 boxLines[4].Visible = true
                    else for _, l in pairs(boxLines) do l.Visible = false end end
                else for _, l in pairs(boxLines) do l.Visible = false end end

                -- Name ESP
                if Toggles.ESPName.Value then
                    local tl2, br2 = getBoxBounds(char)
                    if tl2 and br2 then
                        if not nameText then
                            nameText = Drawing.new("Text")
                            nameText.Size = 14 nameText.Center = true nameText.Outline = true nameText.Font = 2
                        end
                        nameText.Position = Vector2.new((tl2.X + br2.X) / 2, tl2.Y - 16)
                        nameText.Text = (detectedCheaters and detectedCheaters[player]) and ('[开了] ' .. player.Name) or player.Name
                        nameText.Color = ec
                        nameText.Visible = true
                    elseif nameText then nameText.Visible = false end
                elseif nameText then nameText.Visible = false end

                -- Skeleton ESP
                if Toggles.ESPSkeleton.Value then
                    local bones = {
                        {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
                        {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
                        {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
                        {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
                        {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
                    }
                    for i, pair in ipairs(bones) do
                        if not skeletonLines[i] then skeletonLines[i] = makeLine() end
                        local from = char:FindFirstChild(pair[1])
                        local to = char:FindFirstChild(pair[2])
                        if from and to then
                            local fs = worldToScreen(from.Position)
                            local ts = worldToScreen(to.Position)
                            if fs and ts then
                                skeletonLines[i].From = fs skeletonLines[i].To = ts
                                skeletonLines[i].Color = ec skeletonLines[i].Thickness = 1.5 skeletonLines[i].Visible = true
                            else skeletonLines[i].Visible = false end
                        else skeletonLines[i].Visible = false end
                    end
                else for _, l in pairs(skeletonLines) do l.Visible = false end end

                -- Health Bar
                if Toggles.ESPHealthBar.Value then
                    local tl2, br2 = getBoxBounds(char)
                    if tl2 and br2 then
                        local bw = 3
                        local bx = tl2.X - bw - 2
                        local bH = br2.Y - tl2.Y
                        if not espObjects[player].healthBarBg then
                            espObjects[player].healthBarBg = Drawing.new("Line")
                            espObjects[player].healthBarBg.ZIndex = 26
                        end
                        local bg = espObjects[player].healthBarBg
                        bg.From = Vector2.new(bx, tl2.Y)
                        bg.To = Vector2.new(bx, br2.Y)
                        bg.Color = Color3.new(0, 0, 0)
                        bg.Thickness = bw + 1
                        bg.Visible = true
                        local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                        if not espObjects[player].healthBarFill then
                            espObjects[player].healthBarFill = Drawing.new("Line")
                            espObjects[player].healthBarFill.ZIndex = 27
                        end
                        local fill = espObjects[player].healthBarFill
                        fill.From = Vector2.new(bx, br2.Y)
                        fill.To = Vector2.new(bx, br2.Y - bH * hp)
                        fill.Color = ec
                        fill.Thickness = bw
                        fill.Visible = true
                    else
                        if espObjects[player].healthBarBg then espObjects[player].healthBarBg.Visible = false end
                        if espObjects[player].healthBarFill then espObjects[player].healthBarFill.Visible = false end
                    end
                else
                    if espObjects[player] and espObjects[player].healthBarBg then espObjects[player].healthBarBg.Visible = false end
                    if espObjects[player] and espObjects[player].healthBarFill then espObjects[player].healthBarFill.Visible = false end
                end

                -- HP Counter
                if Toggles.ESPHPCounter.Value then
                    local tl2, br2 = getBoxBounds(char)
                    if tl2 and br2 then
                        if not hpCounter then
                            hpCounter = Drawing.new("Text")
                            hpCounter.Size = 12 hpCounter.Center = true hpCounter.Outline = true hpCounter.Font = 2
                        end
                        hpCounter.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
                        hpCounter.Position = Vector2.new(tl2.X - 25, (tl2.Y + br2.Y) / 2)
                        hpCounter.Color = ec
                        hpCounter.Visible = true
                    elseif hpCounter then hpCounter.Visible = false end
                elseif hpCounter then hpCounter.Visible = false end

                -- Weapon ESP
                if Toggles.ESPWeapon.Value then
                    local tl2, br2 = getBoxBounds(char)
                    if tl2 and br2 then
                        local tool = char:FindFirstChildOfClass("Tool")
                        local wName = tool and tool.Name or ""
                        if not weaponText then
                            weaponText = Drawing.new("Text")
                            weaponText.Size = 13 weaponText.Center = true weaponText.Outline = true weaponText.Font = 2
                        end
                        weaponText.Position = Vector2.new((tl2.X + br2.X) / 2, br2.Y + 5)
                        weaponText.Text = wName
                        weaponText.Color = ec
                        weaponText.Visible = wName ~= ""
                    elseif weaponText then weaponText.Visible = false end
                elseif weaponText then weaponText.Visible = false end

                -- Shield ESP
                if Toggles.ESPShield and Toggles.ESPShield.Value then
                    local hasShield = playerHasShield(player, char)
                    if hasShield then
                        local tl2, br2 = getBoxBounds(char)
                        if tl2 and br2 then
                            if not shieldText then
                                shieldText = Drawing.new("Text")
                                shieldText.Size = 13
                                shieldText.Center = false
                                shieldText.Outline = true
                                shieldText.Font = 2
                            end
                            local shieldCol = (Options.ESPShieldColor and Options.ESPShieldColor.Value) or Color3.fromRGB(0, 180, 255)
                            if Toggles.ESPShieldRainbow and Toggles.ESPShieldRainbow.Value then
                                shieldCol = Color3.fromHSV(rainbowHue, 1, 1)
                            end
                            shieldText.Position = Vector2.new(br2.X + 6, (tl2.Y + br2.Y) / 2 - 6)
                            shieldText.Text = "护盾"
                            shieldText.Color = shieldCol
                            shieldText.Visible = true
                        elseif shieldText then
                            shieldText.Visible = false
                        end
                    elseif shieldText then
                        shieldText.Visible = false
                    end
                elseif shieldText then
                    shieldText.Visible = false
                end
            end)
        end
    }
end

Players.PlayerRemoving:Connect(removeESP)

RunService.RenderStepped:Connect(function()
    if not Toggles.ESP.Value then
        local players = {}
        for player, _ in pairs(espObjects) do table.insert(players, player) end
        for _, player in ipairs(players) do removeESP(player) end
        for _, child in ESPFolder:GetChildren() do child:Destroy() end
        return
    end
    for _, player in Players:GetPlayers() do
        if player ~= LP then
            if not espObjects[player] then createESP(player) end
            if espObjects[player] then espObjects[player].update() end
        end
    end
end)



-- Ambience & Stretch Resolution
do
local origAmbient = Lighting.Ambient
local origBrightness = Lighting.Brightness
local origClockTime = Lighting.ClockTime

local ambienceHue = 0
RunService.RenderStepped:Connect(function()
    if Toggles.Ambience.Value then
        local ambColor = Options.AmbienceColor.Value
        if Toggles.AmbienceRainbow.Value then
            ambColor = Color3.fromHSV(ambienceHue, 1, 1)
        end
        Lighting.Ambient = ambColor
        Lighting.Brightness = Options.AmbienceBrightness.Value
        Lighting.OutdoorAmbient = ambColor
    else
        Lighting.Ambient = origAmbient
        Lighting.Brightness = origBrightness
    end
    if Toggles.CustomTime.Value then
        Lighting.ClockTime = Options.CustomTimeValue.Value
    else
        Lighting.ClockTime = origClockTime
    end
    ambienceHue = (ambienceHue + Options.RainbowSpeed.Value * 0.005) % 1
    rainbowHue = (rainbowHue + Options.RainbowSpeed.Value * 0.005) % 1
end)

-- Stretch Resolution（纵向拉伸分辨率）
-- 旧实现有两个坑：
--   1) 绑在 RenderStepped 上：早于 CameraScript / 自定义相机时，游戏每帧重设 CFrame
--      会把拉伸直接覆盖，于是出现「一帧拉伸、一帧原样」的闪烁；
--   2) 每帧都拿「当前 CFrame」右乘缩放矩阵：相机不被重设时（观战 / 固定镜头 / 载具），
--      缩放会一帧叠一帧，画面越来越扁，直到某次重设弹回原样再重新累积。
-- 新实现：
--   · 绑到 RenderPriority.Last - 1，等所有相机逻辑写完再施加，不会再被覆盖；
--   · 记住上一帧写回的值，发现相机还停在我们写的状态就先撤销上一帧缩放，
--     保证每帧只在「原始 CFrame」上乘一次，不累积；
--   · 关闭开关 / 换镜头时精确还原，不留斜相机。
do
    local BIND_NAME = 'WX_StretchResolution_7c1'
    local bound = false
    local lastWritten, lastOriginal, lastCam, lastScale = nil, nil, nil, 1

    local function scaleCF(s)
        return CFrame.new(0, 0, 0, 1, 0, 0, 0, s, 0, 0, 0, 1)
    end

    local function near(a, b)
        if not a or not b then return false end
        local ax, ay, az, a00, a01, a02, a10, a11, a12, a20, a21, a22 = a:GetComponents()
        local bx, by, bz, b00, b01, b02, b10, b11, b12, b20, b21, b22 = b:GetComponents()
        if math.abs(ax - bx) > 1e-3 or math.abs(ay - by) > 1e-3 or math.abs(az - bz) > 1e-3 then return false end
        return math.abs(a00 - b00) < 1e-3 and math.abs(a01 - b01) < 1e-3 and math.abs(a02 - b02) < 1e-3
            and math.abs(a10 - b10) < 1e-3 and math.abs(a11 - b11) < 1e-3 and math.abs(a12 - b12) < 1e-3
            and math.abs(a20 - b20) < 1e-3 and math.abs(a21 - b21) < 1e-3 and math.abs(a22 - b22) < 1e-3
    end

    local function restore()
        if lastCam and lastWritten and lastOriginal then
            pcall(function()
                -- 只有相机还停在我们写入的状态时才还原，避免覆盖别人刚写的相机
                if lastCam.Parent and near(lastCam.CFrame, lastWritten) then
                    lastCam.CFrame = lastOriginal
                end
            end)
        end
        lastWritten, lastOriginal, lastCam, lastScale = nil, nil, nil, 1
    end

    local function step()
        local cam = Workspace.CurrentCamera
        if not cam then return end

        if cam ~= lastCam then
            -- 重生 / 换视角 / 上载具：旧镜头状态全部作废
            lastWritten, lastOriginal = nil, nil
            lastCam, lastScale = cam, 1
        end

        local res = tonumber(Options.StretchResolutionValue and Options.StretchResolutionValue.Value) or 0.80
        res = math.clamp(res, 0.10, 2.00)

        local cur = cam.CFrame
        -- 相机这一帧没被外部更新 → 先撤掉自己上一帧的缩放，回到干净的 CFrame
        if lastWritten and near(cur, lastWritten) then
            cur = lastOriginal or cur
            if lastScale ~= 1 then
                cur = cur * scaleCF(1 / lastScale)
            end
        end

        lastOriginal, lastScale = cur, res

        if math.abs(res - 1) < 0.005 then
            if not near(cam.CFrame, cur) then cam.CFrame = cur end
            lastWritten = nil
            return
        end

        local stretched = cur * scaleCF(res)
        cam.CFrame = stretched
        lastWritten = stretched
    end

    local function refresh()
        if Toggles.StretchResolution.Value then
            if not bound then
                bound = true
                RunService:BindToRenderStep(BIND_NAME, Enum.RenderPriority.Last.Value - 1, step)
            end
        else
            if bound then
                bound = false
                pcall(function() RunService:UnbindFromRenderStep(BIND_NAME) end)
            end
            restore()
        end
    end

    Toggles.StretchResolution:OnChanged(refresh)
    task.defer(refresh)
end


end

do
-- ====================== MISC ======================
local SoundsGroup = Tabs.Misc:AddLeftGroupbox('音效')

Toggles.Hitsound = SoundsGroup:AddToggle('Hitsound', { Text = '命中音效', Default = false })
Options.HitsoundSelect = WXDrop(SoundsGroup, 'HitsoundSelect', { Text = '命中音效', Default = 5, Values = { 'Fatality', 'Skeet', 'Bell', 'COD', 'Metal', 'TF2 Critical', 'TF2', 'Rust', 'Neverlose', 'NL' } })
Options.HitsoundVolume = SoundsGroup:AddSlider('HitsoundVolume', { Text = '命中音效音量', Default = 60, Min = 1, Max = 100, Rounding = 0, Compact = false })
SoundsGroup:AddButton('试听命中音效', function()
    if playHitsound then playHitsound(true) end
end)

SoundsGroup:AddDivider()

Toggles.Killsound = SoundsGroup:AddToggle('Killsound', { Text = '击杀音效', Default = false })
Options.KillsoundSelect = WXDrop(SoundsGroup, 'KillsoundSelect', { Text = '击杀音效', Default = 1, Values = { 'Fatality', 'Skeet', 'Bell', 'COD', 'Metal', 'TF2 Critical', 'TF2', 'Rust', 'Neverlose', 'NL' } })
Options.KillsoundVolume = SoundsGroup:AddSlider('KillsoundVolume', { Text = '击杀音效音量', Default = 80, Min = 1, Max = 100, Rounding = 0, Compact = false })
SoundsGroup:AddButton('试听击杀音效', function()
    if playKillsound then playKillsound(true) end
end)

local MiscGroup = Tabs.Misc:AddLeftGroupbox('杂项')
Toggles.Invisible = MiscGroup:AddToggle('Invisible', { Text = '隐身', Default = false, Tooltip = '通过 CFrame 位置失同步让其他玩家看不到你' })
Toggles.Invisible:AddKeyPicker('InvisibleBind', { Default = 'None', SyncToggleState = false, Modes = { 'Toggle', 'Hold', 'Always' }, Text = '隐身' })

-- 手机端快捷按钮（隐身）
Toggles.InvisibleMobile = MiscGroup:AddToggle('InvisibleMobile', {
    Text = '手机快捷按钮',
    Default = Library.IsMobile,
    Tooltip = '开启后在屏幕上生成一个隐身开关圆钮，可拖动摆放'
})
local InvisibleMobileDep = MiscGroup:AddDependencyBox()
InvisibleMobileDep:SetupDependencies({ { Toggles.InvisibleMobile, true } })
Toggles.InvisibleMobileLock = InvisibleMobileDep:AddToggle('InvisibleMobileLock', {
    Text = '锁定快捷按钮',
    Default = false,
    Tooltip = '开启后按钮固定位置，无法拖动，只保留点击开关隐身'
})
Toggles.AntiInvisible = MiscGroup:AddToggle('AntiInvisible', { Text = '反隐身', Default = false, Tooltip = '通过压制失同步动画权重，识破隐身脚本' })
Toggles.AntiSit = MiscGroup:AddToggle('AntiSit', { Text = '防坐下', Default = false, Tooltip = '阻止坐在椅子/长椅上，同时保留载具座位可用' })

Toggles.AntiArrest = MiscGroup:AddToggle('AntiArrest', {
    Text = '反电击 / （防逮捕）',
    Default = false,
    Tooltip = '囚犯 / 罪犯身份下防止被警察点击逮捕、拷住和电击：即时关闭角色点击检测、秒拆手铐、解除麻痹并恢复移动'
})
local AntiArrestDep = MiscGroup:AddDependencyBox()
AntiArrestDep:SetupDependencies({ { Toggles.AntiArrest, true } })

Toggles.AntiArrestClick = AntiArrestDep:AddToggle('AntiArrestClick', {
    Text = '反点击（关闭角色点击检测）',
    Default = true,
    Tooltip = '把角色身上的 ClickDetector / ProximityPrompt 全部关掉，警察点不动你'
})

Toggles.AntiArrestTaser = AntiArrestDep:AddToggle('AntiArrestTaser', {
    Text = '反电击（解除麻痹）',
    Default = true,
    Tooltip = '被电击枪命中后立刻站起、恢复移动，不看电击动画'
})
Toggles.AntiArrestInmateOnly = AntiArrestDep:AddToggle('AntiArrestInmateOnly', {
    Text = '仅囚犯 / 罪犯生效',
    Default = true,
    Tooltip = '选择狱警身份时本功能自动不生效'
})

_G.WXAntiArrestUI = { Stats = { click = 0, cuff = 0, tase = 0, lastCuff = 0, lastBumpCuff = 0 } }
_G.WXAntiArrestUI.Label = MiscGroup:AddLabel('拦截统计：点击 0 / 手铐 0 / 电击 0')

-- ====================== 原地复活 ======================
MiscGroup:AddDivider()
Toggles.RespawnInPlace = MiscGroup:AddToggle('RespawnInPlace', {
    Text = '原地复活',
    Default = false,
    Tooltip = '死亡瞬间记录死亡坐标，重生后把角色传送回死亡位置，不再回到出生点'
})
Toggles.RespawnInPlace:AddKeyPicker('RespawnInPlaceBind', { Default = 'None', SyncToggleState = false, Modes = { 'Toggle', 'Hold', 'Always' }, Text = '原地复活' })

-- 同样不占 local：依赖框挂到全局表上
WXRespawnDep = MiscGroup:AddDependencyBox()
WXRespawnDep:SetupDependencies({ { Toggles.RespawnInPlace, true } })

Toggles.RespawnInstant = WXRespawnDep:AddToggle('RespawnInstant', {
    Text = '快速复活',
    Default = true,
    Tooltip = '死亡后自动尝试触发服务器的复活远程 / 重载角色，缩短等待；服务器没有对应事件时仍按默认时间复活'
})
Toggles.RespawnKeepRotation = WXRespawnDep:AddToggle('RespawnKeepRotation', {
    Text = '保留死亡朝向',
    Default = true,
    Tooltip = '复活后沿用死亡时的朝向，关闭则朝向交给服务器处理'
})
Options.RespawnHeightOffset = WXRespawnDep:AddSlider('RespawnHeightOffset', {
    Text = '复活高度偏移',
    Default = 3,
    Min = 0,
    Max = 12,
    Rounding = 0,
    Compact = false
})
_G.WXRespawnUI = {}
_G.WXRespawnUI.Status = WXRespawnDep:AddLabel('状态：等待死亡')

do
    (function()
        local STATE = { cf = nil, at = 0, usedRemote = false, restores = 0 }
        local lastGoodCF, lastGoodAt = nil, 0   -- 最后一个有效坐标（空中 / 地面都算）
        local safeCF, safeAt = nil, 0           -- 最后一个「踩在地上」的坐标，死亡点作废时兜底
        local deaths = {}                       -- 最近几次死亡的时间戳，用于熔断循环死亡
        local suspendUntil = 0                  -- 熔断后暂停原地复活的截止时间

        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.IgnoreWater = true

        local overlapParams = OverlapParams.new()
        overlapParams.FilterType = Enum.RaycastFilterType.Exclude

        -- 名字里带这些词的部件按「致死区」处理（击杀砖 / 岩浆 / 陷阱 / 销毁区）
        local HAZARD_WORDS = {
            'kill', 'dead', 'death', 'lava', 'void', 'spike', 'trap', 'damage',
            'hurt', 'acid', 'fire', 'burn', 'poison', 'destroy', 'suicide',
        }

        local function destroyFloor()
            local y = -500
            pcall(function() y = tonumber(Workspace.FallenPartsDestroyHeight) or -500 end)
            return y
        end

        local function isValidCF(cf)
            if typeof(cf) ~= 'CFrame' then return false end
            local p = cf.Position
            if p.X ~= p.X or p.Y ~= p.Y or p.Z ~= p.Z then return false end
            if math.abs(p.X) > 1000000 or math.abs(p.Z) > 1000000 then return false end
            -- 贴着坠落销毁线的点（掉出地图 / 虚空）复活过去只会再死一次
            if p.Y <= destroyFloor() + 20 then return false end
            return true
        end

        local function setStatus(text)
            local ui = _G.WXRespawnUI
            if ui and ui.Status then
                pcall(function() ui.Status:SetText(text) end)
            end
        end

        local function notify(title, desc)
            pcall(function()
                if Library and Library.Notify then
                    Library:Notify({ Title = title, Description = desc, Time = 6 })
                end
            end)
        end

        -- 复活接管标记：飞行模块看到它就暂缓起飞，避免两套逻辑同时改角色的 CFrame / 碰撞。
        -- token 用来作废旧定时器：否则上一次复活排的「自动解锁」会把新一次的标记清掉。
        local busyToken = 0
        local function setBusy(v, autoClear)
            busyToken = busyToken + 1
            local token = busyToken
            _G.WXRespawnBusy = v and true or false
            if v and autoClear then
                task.delay(autoClear, function()
                    if busyToken == token then
                        _G.WXRespawnBusy = false
                    end
                end)
            end
        end

        -- 从某点向下找「能站人的地面」；找不到就说明是悬空 / 虚空
        local function groundBelow(pos, char)
            local filter = {}
            if char then table.insert(filter, char) end
            rayParams.FilterDescendantsInstances = filter
            local origin = pos + Vector3.new(0, 3, 0)
            -- 装饰件 / 触发区大多不可碰撞，不能当落脚点，命中后接着往下找
            for _ = 1, 4 do
                local ok, hit = pcall(function()
                    return Workspace:Raycast(origin, Vector3.new(0, -600, 0), rayParams)
                end)
                if not ok or not hit then return nil end
                if hit.Normal.Y >= 0.5 and hit.Instance and hit.Instance.CanCollide then
                    return hit.Position
                end
                origin = hit.Position - Vector3.new(0, 0.5, 0)
            end
            return nil
        end

        -- 粗判致死区：击杀砖 / 岩浆 / 陷阱的命名基本都带关键字
        local function isHazard(pos, char)
            local filter = {}
            if char then table.insert(filter, char) end
            overlapParams.FilterDescendantsInstances = filter
            local ok, parts = pcall(function()
                return Workspace:GetPartBoundsInRadius(pos, 3.5, overlapParams)
            end)
            if not ok or not parts then return false end
            for _, part in ipairs(parts) do
                local n = string.lower(part.Name)
                for _, kw in ipairs(HAZARD_WORDS) do
                    if string.find(n, kw, 1, true) then return true end
                end
            end
            return false
        end

        -- 存活期间持续记录：一个是「最后有效点」，一个是「最后落地安全点」
        local function recordPos()
            local char = LP.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass('Humanoid')
            local root = char:FindFirstChild('HumanoidRootPart')
            if not hum or not root then return end
            if hum.Health <= 0 then return end
            local cf = root.CFrame
            if not isValidCF(cf) then return end
            lastGoodCF, lastGoodAt = cf, tick()

            -- 飞行时记下的是空中坐标，直接拿来复活等于把人扔回半空：
            -- 只有「站在地上」或「脚下 8 格内就是地面」才更新安全点
            if hum.FloorMaterial ~= Enum.Material.Air then
                safeCF, safeAt = cf, tick()
            else
                local g = groundBelow(cf.Position, char)
                if g and (cf.Position.Y - g.Y) <= 8 and not isHazard(g, char) then
                    safeCF, safeAt = cf, tick()
                end
            end
        end

        local acc = 0
        RunService.Heartbeat:Connect(function(dt)
            if not (Toggles.RespawnInPlace and Toggles.RespawnInPlace.Value) then return end
            acc = acc + dt
            if acc < 0.1 then return end
            acc = 0
            recordPos()
        end)

        -- 服务器复活远程：ReplicatedStorage 里名字带 respawn / revive / rebirth 的远程
        local remoteCache = nil
        local function collectRespawnRemotes()
            local list = {}
            local seen = {}
            local function scan(container, depth)
                if not container or depth > 4 then return end
                for _, obj in ipairs(container:GetChildren()) do
                    if obj:IsA('RemoteEvent') or obj:IsA('UnreliableRemoteEvent') or obj:IsA('RemoteFunction') then
                        local n = string.lower(obj.Name)
                        local looksLikeRespawn = string.find(n, 'respawn', 1, true)
                            or string.find(n, 'revive', 1, true)
                            or string.find(n, 'rebirth', 1, true)
                        -- 排除载具 / 枪械 / NPC 之类的同名远程，避免误触发
                        local blacklisted = string.find(n, 'vehicle', 1, true)
                            or string.find(n, 'gun', 1, true) or string.find(n, 'weapon', 1, true)
                            or string.find(n, 'item', 1, true) or string.find(n, 'npc', 1, true)
                            or string.find(n, 'bot', 1, true)
                        if looksLikeRespawn and not blacklisted then
                            if not seen[obj] then
                                seen[obj] = true
                                table.insert(list, obj)
                            end
                        end
                    elseif obj:IsA('Folder') or obj:IsA('Model') then
                        scan(obj, depth + 1)
                    end
                end
            end
            pcall(scan, ReplicatedStorage, 0)
            return list
        end

        local lastInstantAt = 0
        local function tryInstantRespawn()
            -- 全局节流：连续死亡时不要每次死亡都去轰一遍复活远程（每次轰都可能触发一次重生）
            if (tick() - lastInstantAt) < 2 then return end
            if not STATE.usedRemote then
                STATE.usedRemote = true
                lastInstantAt = tick()
                if not remoteCache or #remoteCache == 0 then
                    remoteCache = collectRespawnRemotes()
                end
                for _, remote in ipairs(remoteCache) do
                    if remote and remote.Parent then
                        task.spawn(function()
                            pcall(function()
                                if remote:IsA('RemoteFunction') then
                                    remote:InvokeServer()
                                else
                                    remote:FireServer()
                                end
                            end)
                        end)
                    end
                end
            end

            -- 远程无效时兜底：直接请求重载角色（同一次死亡只做一次，避免高频重生）
            task.wait(0.25)
            if not (Toggles.RespawnInPlace and Toggles.RespawnInPlace.Value) then return end
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass('Humanoid')
            if (not char) or (not hum) or hum.Health <= 0 then
                pcall(function() LP:LoadCharacter() end)
            end
        end

        -- 用死亡坐标 + 脚下地面，算出「能站住」的复活坐标
        local function buildCF(baseCF, groundPos)
            local offsetY = (Options.RespawnHeightOffset and Options.RespawnHeightOffset.Value) or 3
            offsetY = math.clamp(tonumber(offsetY) or 3, 0, 12)
            -- +3 是 HumanoidRootPart 站立时离地的高度，保证复活后是「站上去」而不是「卡在地里」
            local pos = groundPos + Vector3.new(0, offsetY + 3, 0)
            local rot = CFrame.new()
            if Toggles.RespawnKeepRotation == nil or Toggles.RespawnKeepRotation.Value then
                rot = baseCF - baseCF.Position
            end
            return CFrame.new(pos) * rot
        end

        local function resolveSpawnCF(baseCF, char)
            if not baseCF then return nil, '没有可用的死亡坐标' end
            local groundPos = groundBelow(baseCF.Position, char)
            if not groundPos then
                return nil, '死亡点在悬空 / 虚空，脚下没有地面'
            end
            if isHazard(groundPos, char) then
                return nil, '死亡点位于地图致死区'
            end
            return buildCF(baseCF, groundPos), nil
        end

        local function hookCharacter(char)
            local hum = char:WaitForChild('Humanoid', 10)
            if not hum then return end
            if hum.Health <= 0 then return end
            hum.Died:Connect(function()
                STATE.usedRemote = false
                if not (Toggles.RespawnInPlace and Toggles.RespawnInPlace.Value) then return end

                local now = tick()

                -- 熔断：20 秒内连续死 3 次，说明复活点本身就是死区（虚空 / 击杀砖 / 出界）。
                -- 继续原地复活只会「复活 → 秒死 → 复活」无限循环，这里直接改回默认出生点。
                local recent = {}
                for _, t in ipairs(deaths) do
                    if now - t <= 20 then table.insert(recent, t) end
                end
                table.insert(recent, now)
                deaths = recent
                if #deaths >= 3 then
                    deaths = {}
                    suspendUntil = now + 20
                    STATE.cf = nil
                    setBusy(false)
                    setStatus('状态：连续死亡，已暂停原地复活 20 秒')
                    notify('原地复活已暂停', '20 秒内连续死亡 3 次，本次改用正常出生点，避免无限循环')
                    if _G.WXFlyCtl and _G.WXFlyCtl.forceStop then pcall(_G.WXFlyCtl.forceStop) end
                    if Toggles.PlayerFly and Toggles.PlayerFly.Value then
                        pcall(function() Toggles.PlayerFly:SetValue(false) end)
                    end
                    return
                end

                -- 冻结飞行接管，直到复活动作做完（防止两边抢 CFrame / 碰撞）
                setBusy(true, 20)

                local root = char:FindFirstChild('HumanoidRootPart')
                local cf = nil
                if lastGoodCF and (tick() - lastGoodAt) < 5 then
                    cf = lastGoodCF
                elseif root and isValidCF(root.CFrame) then
                    cf = root.CFrame
                else
                    cf = lastGoodCF
                end

                -- 飞行中死亡时手上只有空中坐标：先用「脚下地面」验证，不行就退回最后落地位置
                local usable = cf and isValidCF(cf)
                if usable then
                    local g = groundBelow(cf.Position, char)
                    -- 悬停 / 站在击杀砖、岩浆、陷阱里死的：这个点本身就不能用
                    if (not g) or isHazard(g, char) or isHazard(cf.Position, char) then
                        usable = false
                    end
                end
                if not usable then
                    if safeCF and (tick() - safeAt) < 120 then
                        cf = safeCF
                        setStatus('状态：死亡点在悬空 / 虚空，改用最后落地位置')
                    else
                        STATE.cf = nil
                        setBusy(false)
                        setStatus('状态：死亡点无效（掉出地图），按默认出生点复活')
                        return
                    end
                end

                STATE.cf = cf
                STATE.at = tick()
                STATE.restores = 0
                if STATE.cf then
                    setStatus('状态：已记录死亡点，等待重生')
                end

                if Toggles.RespawnInstant and Toggles.RespawnInstant.Value then
                    task.spawn(tryInstantRespawn)
                end
            end)
        end

        local function restore(char)
            local cf = STATE.cf
            if not cf then
                setBusy(false)
                return
            end

            if not (Toggles.RespawnInPlace and Toggles.RespawnInPlace.Value) then
                STATE.cf = nil
                setBusy(false)
                return
            end
            if tick() < suspendUntil then
                STATE.cf = nil
                setBusy(false)
                setStatus('状态：原地复活暂停中，本次按正常出生点复活')
                return
            end
            if (tick() - STATE.at) > 15 or (STATE.restores or 0) >= 3 then
                STATE.cf = nil
                setBusy(false)
                return
            end
            STATE.restores = (STATE.restores or 0) + 1
            setBusy(true, 10)

            local hum = char and char:WaitForChild('Humanoid', 10)
            local root = char and char:WaitForChild('HumanoidRootPart', 10)
            if not hum or not root then
                setBusy(false)
                return
            end

            -- 关键一步：先彻底停飞、取消 PlatformStand。
            -- 飞行状态是「PlatformStand + 全部件无碰撞」，这时把角色 CFrame 回死亡点，
            -- 人会直接穿地掉进虚空 → 再死一次 → 再复活，就是无限死亡循环的源头。
            local wasFlying = _G.WXFlyCtl and _G.WXFlyCtl.isOn and _G.WXFlyCtl.isOn()
            if wasFlying and _G.WXFlyCtl.forceStop then
                pcall(_G.WXFlyCtl.forceStop)
            end
            pcall(function() hum.PlatformStand = false end)

            -- 死亡点本身必须是「脚下有地面、且不是致死区」的位置
            local target = resolveSpawnCF(cf, char)
            if not target and safeCF and (tick() - safeAt) < 120 then
                target = resolveSpawnCF(safeCF, char)
                if target then
                    setStatus('状态：死亡点不可用，改用最后落地位置')
                end
            end

            if not target then
                STATE.cf = nil
                setStatus('状态：死亡点不可用，按默认出生点复活')
                notify('原地复活', '死亡点位于虚空或致死区，本次已改用正常出生点')
                setBusy(false)
                return
            end

            -- 游戏常常在重生瞬间把角色 CFrame 回出生点，这里连续覆盖，约 1.5 秒后稳定
            for i = 1, 14 do
                if not char or not char.Parent then break end
                local h = char:FindFirstChildOfClass('Humanoid')
                local r = char:FindFirstChild('HumanoidRootPart')
                if not h or not r or h.Health <= 0 then break end
                pcall(function()
                    if h.PlatformStand then h.PlatformStand = false end
                    r.CFrame = target
                    r.AssemblyLinearVelocity = Vector3.zero
                    r.AssemblyAngularVelocity = Vector3.zero
                    -- 停飞后把根部件碰撞还回来，保证落点能站住
                    if wasFlying and not r.CanCollide then r.CanCollide = true end
                end)
                task.wait(i <= 5 and 0.05 or 0.15)
            end

            -- 落点复检：脚下还是没地面就不要再硬撑，避免下一次死亡继续同一个循环
            if char and char.Parent then
                local h = char:FindFirstChildOfClass('Humanoid')
                local r = char:FindFirstChild('HumanoidRootPart')
                if h and r and h.Health > 0 then
                    if groundBelow(r.Position, char) then
                        setStatus('状态：已回到死亡点')
                    else
                        STATE.cf = nil
                        setStatus('状态：落点悬空，已停止原地复活')
                    end
                end
            end

            task.delay(0.8, function() setBusy(false) end)
        end

        if LP.Character then
            task.spawn(hookCharacter, LP.Character)
        end
        LP.CharacterAdded:Connect(function(char)
            task.spawn(hookCharacter, char)
            task.spawn(restore, char)
        end)

        Toggles.RespawnInPlace:OnChanged(function()
            if Toggles.RespawnInPlace.Value then
                recordPos()
                setStatus(STATE.cf and '状态：已记录死亡点' or '状态：等待死亡')
            else
                STATE.cf = nil
                suspendUntil = 0
                deaths = {}
                setBusy(false)
                setStatus('状态：已关闭')
            end
        end)
    end)()
end

MiscGroup:AddDivider()
Toggles.FPSUnlocker = MiscGroup:AddToggle('FPSUnlocker', { Text = '帧率解锁', Default = false })
Options.FPSTarget = MiscGroup:AddSlider('FPSTarget', { Text = '帧率目标', Default = 240, Min = 240, Max = 1000, Rounding = 0, Compact = false })

Toggles.FPSUnlocker:OnChanged(function()
    if Toggles.FPSUnlocker.Value then
        setfpscap(Options.FPSTarget.Value)
    else
        setfpscap(60)
    end
end)

Options.FPSTarget:OnChanged(function()
    if Toggles.FPSUnlocker.Value then
        setfpscap(Options.FPSTarget.Value)
    end
end)

-- ====================== 获取枪械（服务器全部免费枪械 · 传送往返） ======================
local GunGrabGroup = Tabs.Misc:AddLeftGroupbox('获取枪械')

GunGrabGroup:AddDivider()

Options.FreeGunTarget = WXDrop(GunGrabGroup, 'FreeGunTarget', {
    Text = '获取枪械',
    Values = { '全部' },
    Default = 1,
    Multi = false
})

GunGrabGroup:AddButton({
    Text = '刷新枪械列表',
    Func = function()
        local list = FreeGunGrab.Scan()
        local values = { '全部' }
        local seen = { ['全部'] = true }
        for _, e in ipairs(list) do
            if not seen[e.name] then
                seen[e.name] = true
                values[#values + 1] = e.name
            end
        end
        pcall(function() Options.FreeGunTarget:SetValues(values) end)
        FreeGunGrab.SetStatus(string.format('扫描完成：全图 %d 处枪械', #list))
    end
})

GunGrabGroup:AddButton({
    Text = '获取指定枪械（使用前先刷新列表）',
    Func = function()
        local target = Options.FreeGunTarget and Options.FreeGunTarget.Value or '全部'
        task.spawn(function()
            FreeGunGrab.GrabAll({
                only = target,
                ignoreOwned = true,
                backHome = not (Options.FreeGunReturnHome and Options.FreeGunReturnHome.Value == false),
                unique = true,
                dwell = ((Options.FreeGunDwell and Options.FreeGunDwell.Value) or 90) / 1000,
            })
        end)
    end
})

GunGrabGroup:AddDivider()

Toggles.FreeGunUnique = GunGrabGroup:AddToggle('FreeGunUnique', {
    Text = '每种只取一把',
    Default = true,
    Tooltip = '关闭后会把全图同型号的枪械点全部拾取一遍'
})
Toggles.FreeGunReturnHome = GunGrabGroup:AddToggle('FreeGunReturnHome', {
    Text = '拾取后传送回原点',
    Default = true,
    Tooltip = '每拿到一把就立刻瞬移回出发位置；关掉则连续扫图，不再回原点'
})
Options.FreeGunDwell = GunGrabGroup:AddSlider('FreeGunDwell', {
    Text = '传送停留（毫秒）',
    Default = 90,
    Min = 20,
    Max = 400,
    Rounding = 0,
    Compact = false
})

FreeGunGrab.StatusLabel = GunGrabGroup:AddLabel('状态：尚未扫描')

    -- Tabs.Misc Right Tabbox (Roblox Optimizer)
    local OptimizerBox = Tabs.Misc:AddRightTabbox()
    local OptTab = OptimizerBox:AddTab('性能优化')

    Toggles.Optimizer = OptTab:AddToggle('Optimizer', { Text = '启用性能优化', Default = false, Tooltip = '通过削减高消耗画面与特效提升帧率' })

    local OptDep = OptTab:AddDependencyBox()
    OptDep:SetupDependencies({ { Toggles.Optimizer, true } })

    Options.OptimizerPreset = WXDrop(OptDep, 'OptimizerPreset', {
        Values = { 'Max FPS (Potato)', 'Balanced Boost', 'Custom' },
        Default = 2,
        Multi = false,
        Text = '预设'
    })

    OptDep:AddDivider()

    Toggles.OptGlobalShadows = OptDep:AddToggle('OptGlobalShadows', { Text = '禁用全局阴影', Default = true })
    Toggles.OptSmoothMaterials = OptDep:AddToggle('OptSmoothMaterials', { Text = '平滑材质（塑料）', Default = true, Tooltip = '将高消耗表面材质替换为光滑塑料' })
    Toggles.OptRemoveTextures = OptDep:AddToggle('OptRemoveTextures', { Text = '禁用贴花与纹理', Default = false, Tooltip = '使贴花与纹理不可见' })
    Toggles.OptDisableParticles = OptDep:AddToggle('OptDisableParticles', { Text = '禁用粒子与特效', Default = true, Tooltip = '关闭粒子发射器、烟雾、火焰、拖尾与光束' })
    Toggles.OptDisablePostEffects = OptDep:AddToggle('OptDisablePostEffects', { Text = '禁用后期特效（模糊 / 泛光）', Default = true, Tooltip = '关闭模糊、泛光、阳光射线与大气效果' })
    Toggles.OptLowTerrain = OptDep:AddToggle('OptLowTerrain', { Text = '低质量地形 / 水面', Default = true, Tooltip = '关闭水面波纹、反射与草地' })
    Toggles.OptOptimizeNew = OptDep:AddToggle('OptOptimizeNew', { Text = '自动优化新对象', Default = true, Tooltip = '对新生成的对象自动应用优化' })

    OptDep:AddDivider()

    OptDep:AddButton({
        Text = '强制优化场景',
        Func = function()
            if _G.BoarsForceOptimize then
                _G.BoarsForceOptimize()
            end
        end
    })

    OptDep:AddButton({
        Text = '恢复原始画质',
        Func = function()
            if _G.BoarsRestoreGraphics then
                _G.BoarsRestoreGraphics()
            end
        end
    })

-- ====================== INVISIBLE, ANTI-INVISIBLE & ANTI-SIT ======================
do
    -- ============ INVISIBLE (A2Flacko Precision Method) ============
    local InvisibleRealCFrame = nil
    local InvisibleAnimationTrack = nil
    local InvisibleRenderKey = "BoarsInvisibleRender"
    local InvisibleOriginalTransparency = {}
    local InvisibleOriginalCanCollide = {}

    local function loadInvisibleAnimation(character)
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return nil end
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if not animator then return nil end
        local isR15 = humanoid.RigType == Enum.HumanoidRigType.R15
        local animation = Instance.new("Animation")
        animation.AnimationId = isR15 and "rbxassetid://18665825805" or "rbxassetid://215384594"
        local track = animator:LoadAnimation(animation)
        track.Priority = Enum.AnimationPriority.Action4
        track:Play(0, 0.001, 0)
        animation:Destroy()
        task.delay(0, function()
            if track and track.IsPlaying then
                track.TimePosition = isR15 and 1.95 or 0.4
            end
        end)
        return track
    end

    local function stopInvisible()
        pcall(function()
            RunService:UnbindFromRenderStep(InvisibleRenderKey)
        end)
        if InvisibleAnimationTrack then
            pcall(function()
                InvisibleAnimationTrack:Stop()
                InvisibleAnimationTrack:Destroy()
            end)
            InvisibleAnimationTrack = nil
        end
        local character = LP.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if rootPart and InvisibleRealCFrame then
            rootPart.CFrame = InvisibleRealCFrame
            local currentVelocity = rootPart.AssemblyLinearVelocity or rootPart.Velocity
            pcall(function()
                rootPart.AssemblyLinearVelocity = Vector3.new(currentVelocity.X, 0, currentVelocity.Z)
            end)
        end
        InvisibleRealCFrame = nil

        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part ~= rootPart then
                    if InvisibleOriginalTransparency[part] ~= nil then
                        part.Transparency = InvisibleOriginalTransparency[part]
                    end
                    if InvisibleOriginalCanCollide[part] ~= nil then
                        part.CanCollide = InvisibleOriginalCanCollide[part]
                    end
                end
            end
            if rootPart then
                rootPart.Transparency = 1
            end
        end
        table.clear(InvisibleOriginalTransparency)
        table.clear(InvisibleOriginalCanCollide)
    end

    local function startInvisible()
        local character = LP.Character
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not rootPart then return end

        InvisibleAnimationTrack = loadInvisibleAnimation(character)
        InvisibleRealCFrame = nil

        table.clear(InvisibleOriginalTransparency)
        table.clear(InvisibleOriginalCanCollide)
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part ~= rootPart then
                InvisibleOriginalTransparency[part] = part.Transparency
                InvisibleOriginalCanCollide[part] = part.CanCollide
                part.Transparency = 0.5
                part.CanCollide = false
            end
        end
        rootPart.Transparency = 1

        pcall(function()
            RunService:UnbindFromRenderStep(InvisibleRenderKey)
        end)

        RunService:BindToRenderStep(InvisibleRenderKey, Enum.RenderPriority.Camera.Value - 1, function()
            if Toggles.Invisible and Toggles.Invisible.Value and InvisibleRealCFrame and rootPart.Parent then
                rootPart.CFrame = InvisibleRealCFrame
                if InvisibleAnimationTrack then
                    InvisibleAnimationTrack:AdjustWeight(0.001)
                end
            end
        end)
    end

    RunService.Heartbeat:Connect(function()
        if not (Toggles.Invisible and Toggles.Invisible.Value) then return end
        local character = LP.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not rootPart then return end

        local isR15 = humanoid.RigType == Enum.HumanoidRigType.R15
        local dropOffset = humanoid.HipHeight + (rootPart.Size.Y / 2) - 1
        InvisibleRealCFrame = rootPart.CFrame
        rootPart.CFrame = (rootPart.CFrame - Vector3.new(0, dropOffset, 0)) * CFrame.Angles(math.rad(isR15 and 180 or 90), 0, 0)
        local currentVelocity = rootPart.AssemblyLinearVelocity or rootPart.Velocity
        pcall(function()
            rootPart.AssemblyLinearVelocity = Vector3.new(currentVelocity.X, 0, currentVelocity.Z)
        end)
        if InvisibleAnimationTrack then
            InvisibleAnimationTrack:AdjustWeight(100)
        end
    end)

    LP.CharacterAdded:Connect(function(character)
        if Toggles.Invisible and Toggles.Invisible.Value then
            task.wait(0.5)
            startInvisible()
        end
    end)

    Toggles.Invisible:OnChanged(function()
        if Toggles.Invisible.Value then
            startInvisible()
        else
            stopInvisible()
        end
    end)

    getgenv().SetInvisibleEnabled = function(v)
        if Toggles.Invisible then
            Toggles.Invisible:SetValue(v == true)
        end
    end

    -- ============ ANTI INVISIBLE ============
    local AntiInvisibleThreads = {}
    local AntiInvisibleConnections = {}
    local AntiInvisibleWhitelist = {
        ["http://www.roblox.com/asset/?id=125750702"] = true,
        ["http://www.roblox.com/asset/?id=128777973"] = true,
        ["http://www.roblox.com/asset/?id=128853357"] = true,
        ["http://www.roblox.com/asset/?id=129423030"] = true,
        ["http://www.roblox.com/asset/?id=129423131"] = true,
        ["http://www.roblox.com/asset/?id=129967390"] = true,
        ["http://www.roblox.com/asset/?id=129967478"] = true,
        ["http://www.roblox.com/asset/?id=178130996"] = true,
        ["http://www.roblox.com/asset/?id=180426354"] = true,
        ["http://www.roblox.com/asset/?id=180435571"] = true,
        ["http://www.roblox.com/asset/?id=180435792"] = true,
        ["http://www.roblox.com/asset/?id=180436148"] = true,
        ["http://www.roblox.com/asset/?id=180436334"] = true,
        ["http://www.roblox.com/asset/?id=182393478"] = true,
        ["http://www.roblox.com/asset/?id=182435998"] = true,
        ["http://www.roblox.com/asset/?id=182436842"] = true,
        ["http://www.roblox.com/asset/?id=182436935"] = true,
        ["http://www.roblox.com/asset/?id=182491037"] = true,
        ["http://www.roblox.com/asset/?id=182491065"] = true,
        ["http://www.roblox.com/asset/?id=182491248"] = true,
        ["http://www.roblox.com/asset/?id=182491277"] = true,
        ["http://www.roblox.com/asset/?id=182491368"] = true,
        ["http://www.roblox.com/asset/?id=182491423"] = true,
        ["rbxassetid://279227693"] = true,
        ["rbxassetid://279229192"] = true,
        ["rbxassetid://287112271"] = true,
        ["rbxassetid://388723916"] = true,
        ["rbxassetid://388726667"] = true,
        ["rbxassetid://389472570"] = true,
        ["rbxassetid://405194080"] = true,
        ["rbxassetid://405212265"] = true,
        ["rbxassetid://481088553"] = true,
        ["rbxassetid://481089053"] = true,
        ["rbxassetid://484200742"] = true,
        ["rbxassetid://484926359"] = true,
        ["rbxassetid://83690472549256"] = true,
        ["rbxassetid://107176344504758"] = true,
        ["rbxassetid://111090572475133"] = true,
        ["rbxassetid://113267949064300"] = true,
        ["rbxassetid://131326339350805"] = true,
    }

    pcall(function()
        for _, animation in ipairs(ReplicatedStorage:GetDescendants()) do
            if animation:IsA("Animation") then
                AntiInvisibleWhitelist[animation.AnimationId] = true
            end
        end
    end)

    local function watchAnimationTrack(track)
        local animationId = track.Animation and track.Animation.AnimationId
        if not animationId then return end
        local isExploitAnim = (animationId == "rbxassetid://18665825805" or animationId == "rbxassetid://215384594")
        if not isExploitAnim and AntiInvisibleWhitelist[animationId] then return end

        if AntiInvisibleThreads[track] then
            task.cancel(AntiInvisibleThreads[track])
        end
        AntiInvisibleThreads[track] = task.spawn(function()
            repeat
                track:AdjustWeight(0, 0)
                task.wait()
            until not (track.IsPlaying and Toggles.AntiInvisible and Toggles.AntiInvisible.Value)
            AntiInvisibleThreads[track] = nil
        end)
    end

    local function hookCharacterAnimations(character)
        local humanoid = character:WaitForChild("Humanoid", 5)
        if not humanoid then return end
        local animator = humanoid:WaitForChild("Animator", 5)
        if not animator then return end

        local connection = animator.AnimationPlayed:Connect(function(track)
            if Toggles.AntiInvisible and Toggles.AntiInvisible.Value then
                watchAnimationTrack(track)
            end
        end)
        AntiInvisibleConnections[character] = connection

        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            if Toggles.AntiInvisible and Toggles.AntiInvisible.Value then
                watchAnimationTrack(track)
            end
        end
    end

    local function hookPlayerAnimations(plr)
        if plr == LP then return end
        if plr.Character then
            task.spawn(hookCharacterAnimations, plr.Character)
        end
        plr.CharacterAdded:Connect(function(character)
            task.spawn(hookCharacterAnimations, character)
        end)
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        hookPlayerAnimations(plr)
    end
    Players.PlayerAdded:Connect(hookPlayerAnimations)

    Toggles.AntiInvisible:OnChanged(function()
        if Toggles.AntiInvisible.Value then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LP and plr.Character then
                    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                    local anim = hum and hum:FindFirstChildOfClass("Animator")
                    if anim then
                        for _, track in ipairs(anim:GetPlayingAnimationTracks()) do
                            watchAnimationTrack(track)
                        end
                    end
                end
            end
        end
    end)

    getgenv().SetAntiInvisibleEnabled = function(v)
        if Toggles.AntiInvisible then
            Toggles.AntiInvisible:SetValue(v == true)
        end
    end

    -- ============ ANTI SIT ============
    local antiSitConnections = {}

    local function disconnectAntiSit()
        for _, connection in ipairs(antiSitConnections) do
            pcall(function() connection:Disconnect() end)
        end
        table.clear(antiSitConnections)
    end

    local function hookAntiSit(char)
        disconnectAntiSit()
        if not char then return end

        local humanoid = char:WaitForChild("Humanoid", 5)
        if not humanoid then return end

        local conn = humanoid.Seated:Connect(function(active, seatPart)
            if not (Toggles.AntiSit and Toggles.AntiSit.Value) then return end
            if active and seatPart and not seatPart:IsA("VehicleSeat") then
                humanoid.Jump = true
                humanoid.Sit = false
            end
        end)
        table.insert(antiSitConnections, conn)

        local propConn = humanoid:GetPropertyChangedSignal("Sit"):Connect(function()
            if not (Toggles.AntiSit and Toggles.AntiSit.Value) then return end
            if humanoid.Sit and humanoid.SeatPart and not humanoid.SeatPart:IsA("VehicleSeat") then
                humanoid.Jump = true
                humanoid.Sit = false
            end
        end)
        table.insert(antiSitConnections, propConn)
    end

    if LP.Character then
        hookAntiSit(LP.Character)
    end
    LP.CharacterAdded:Connect(hookAntiSit)

    Toggles.AntiSit:OnChanged(function()
        if Toggles.AntiSit.Value and LP.Character then
            local hum = LP.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Sit and hum.SeatPart and not hum.SeatPart:IsA("VehicleSeat") then
                hum.Jump = true
                hum.Sit = false
            end
        end
    end)

    getgenv().SetAntiSitEnabled = function(v)
        if Toggles.AntiSit then
            Toggles.AntiSit:SetValue(v == true)
        end
    end

    _G.BoarsCleanupInvisibleAndSit = function()
        pcall(stopInvisible)
        disconnectAntiSit()
        for _, thread in pairs(AntiInvisibleThreads) do
            pcall(function() task.cancel(thread) end)
        end
        for _, conn in pairs(AntiInvisibleConnections) do
            pcall(function() conn:Disconnect() end)
        end
    end
end


-- ====================== 反点击 / 反手铐 / 反电击（囚犯防逮捕） ======================
-- 囚犯（或罪犯）身份下，防止被狱警点击逮捕：
--   1) 反点击：角色上的 ClickDetector / ProximityPrompt 一律关掉，警察点不动
--   2) 反手铐：手铐 / 拘束物一出现就本地拆掉，并恢复移速跳跃
--   3) 反电击：被电击枪命中后立刻站起、解除麻痹，并回退位置打断拖拽
do
    local CUFF_WORDS = {
        'cuff', 'handcuff', 'restraint', 'ziptie', 'zip tie', 'shackle', 'arrest',
        '手铐', '铐', '拘束', '束缚',
    }
    local CLEAR_ATTRS = { 'Cuffed', 'Handcuffed', 'IsCuffed', 'Tased' }

    local function lower(s)
        return string.lower(tostring(s or ''))
    end

    local function master()
        return Toggles.AntiArrest and Toggles.AntiArrest.Value == true
    end

    local function sub(name, fallback)
        local t = Toggles[name]
        if not t then return fallback end
        return t.Value ~= false
    end

    local function isGuardTeam()
        local t = LP.Team
        if not t then return false end
        if Teams and Teams.Guards and t == Teams.Guards then return true end
        local n = lower(t.Name)
        if n == 'guards' or n == 'guard' or n == 'police' or n == 'cops' or n == 'cop' then return true end
        if string.find(n, '狱警', 1, true) or string.find(n, '警察', 1, true) then return true end
        return false
    end

    -- 主开关 + 「仅囚犯」判断
    local function allowed()
        if not master() then return false end
        if sub('AntiArrestInmateOnly', true) and isGuardTeam() then return false end
        return true
    end

    local function isCuffLike(obj)
        local n = lower(obj.Name)
        for _, w in ipairs(CUFF_WORDS) do
            if string.find(n, w, 1, true) then return true end
        end
        return false
    end

    local function bump(key)
        local ui = _G.WXAntiArrestUI
        if not ui then return end
        local st = ui.Stats
        if key == 'cuff' then
            -- 手铐通常是模型 + 多个部件一起出现，1 秒内只记一次
            local now = tick()
            if now - (st.lastBumpCuff or 0) < 1 then return end
            st.lastBumpCuff = now
        end
        st[key] = (st[key] or 0) + 1
        st.click = st.click or 0
        st.cuff = st.cuff or 0
        st.tase = st.tase or 0
        if ui.Label then
            pcall(function()
                ui.Label:SetText(string.format('拦截统计：点击 %d / 手铐 %d / 电击 %d', st.click, st.cuff, st.tase))
            end)
        end
    end

    -- ===== 基础状态记录 =====
    local lastSpeed = 16
    local lastJumpPower = 50
    local lastJumpHeight = 7.2

    local function updateBaseline(hum)
        if hum.WalkSpeed > 8 then lastSpeed = hum.WalkSpeed end
        local jp = hum.JumpPower
        if jp and jp > 1 then lastJumpPower = jp end
        local jh = hum.JumpHeight
        if jh and jh > 1 then lastJumpHeight = jh end
    end

    local safeCF = nil
    local safeTick = 0
    local lastCuffTick = 0
    local lastEscape = 0

    local function snap(root, cf)
        root.CFrame = cf
        pcall(function()
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end)
    end

    local function recordSafe(root, hum)
        if not root then return end
        if hum and hum.Sit and hum.SeatPart and hum.SeatPart:IsA('VehicleSeat') then return end
        if tick() - lastCuffTick < 3 then return end -- 刚被拷 / 刚被传走，不要把监狱坐标记成安全点
        local now = tick()
        if now - safeTick < 0.25 then return end
        safeTick = now
        safeCF = root.CFrame
    end

    -- ===== 恢复移动 / 解除麻痹 =====
    local function restoreMovement(hum, char, forceSpeed)
        if not hum or hum.Health <= 0 then return end
        local flying = Toggles.PlayerFly and Toggles.PlayerFly.Value
        if not flying then
            pcall(function() hum.PlatformStand = false end)
            local ok, state = pcall(function() return hum:GetState() end)
            if ok and (state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.FallingDown) then
                pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
            end
        end
        if forceSpeed or hum.WalkSpeed <= 1 then
            pcall(function() hum.WalkSpeed = lastSpeed end)
        end
        pcall(function()
            if hum.UseJumpPower then
                if hum.JumpPower < 1 then hum.JumpPower = lastJumpPower end
            else
                if hum.JumpHeight < 1 then hum.JumpHeight = lastJumpHeight end
            end
        end)
        if hum.Sit and hum.SeatPart and not hum.SeatPart:IsA('VehicleSeat') then
            pcall(function() hum.Jump = true end)
            pcall(function() hum.Sit = false end)
        end
        if char then
            pcall(function()
                for _, a in ipairs(CLEAR_ATTRS) do
                    if char:GetAttribute(a) == true then char:SetAttribute(a, false) end
                end
            end)
        end
    end

    -- ===== 反点击：关掉角色身上的点击 / 交互提示 =====
    local function killClicks(char)
        local n = 0
        for _, d in ipairs(char:GetDescendants()) do
            if d:IsA('ClickDetector') then
                if d.MaxActivationDistance ~= 0 then
                    pcall(function() d.MaxActivationDistance = 0 end)
                    n = n + 1
                end
            elseif d:IsA('ProximityPrompt') then
                if d.Enabled then
                    pcall(function() d.Enabled = false end)
                    n = n + 1
                end
            end
        end
        return n
    end

    -- ===== 反手铐：拆掉手铐与拘束物 =====
    local function killCuffs(char)
        local n = 0
        for _, d in ipairs(char:GetDescendants()) do
            if isCuffLike(d) and (d:IsA('Tool') or d:IsA('Model') or d:IsA('BasePart')
                or d:IsA('Accessory') or d:IsA('Weld') or d:IsA('WeldConstraint')
                or d:IsA('AlignPosition') or d:IsA('AlignOrientation') or d:IsA('RopeConstraint')) then
                pcall(function() d:Destroy() end)
                n = n + 1
            end
        end
        return n
    end

    -- ===== 新加入的角色对象立刻处理（手铐一出现就拆，不等循环） =====
    local charConn = nil

    local function attach(char)
        if charConn then
            pcall(function() charConn:Disconnect() end)
            charConn = nil
        end
        if not char then return end

        charConn = char.DescendantAdded:Connect(function(d)
            if not allowed() then return end
            local antiClick = sub('AntiArrestClick', true)
            local antiCuff = sub('AntiArrestCuff', true)
            if antiClick and d:IsA('ClickDetector') then
                pcall(function() d.MaxActivationDistance = 0 end)
                bump('click')
            elseif antiClick and d:IsA('ProximityPrompt') then
                pcall(function() d.Enabled = false end)
                bump('click')
            elseif antiCuff and isCuffLike(d) then
                pcall(function() d:Destroy() end)
                lastCuffTick = tick()
                bump('cuff')
            end
        end)
    end

    if LP.Character then attach(LP.Character) end
    LP.CharacterAdded:Connect(function(char)
        task.wait(0.2)
        attach(char)
    end)

    -- ===== 主循环 =====
    local acc = 0
    local wasStunned = false
    local lastClickClean = 0

    RunService.Heartbeat:Connect(function(dt)
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass('Humanoid')
        local root = char and char:FindFirstChild('HumanoidRootPart')

        if char and hum and hum.Health > 0 then
            updateBaseline(hum)
            if allowed() then recordSafe(root, hum) end
        end

        acc = acc + dt
        if acc < 0.05 then return end
        acc = 0

        if not allowed() then
            wasStunned = false
            return
        end
        if not char or not hum or not root or hum.Health <= 0 then
            wasStunned = false
            return
        end

        -- 反点击：0.25 秒兜底扫一遍，防止新加的点击器漏掉
        if sub('AntiArrestClick', true) and tick() - lastClickClean > 0.25 then
            lastClickClean = tick()
            local n = killClicks(char)
            if n > 0 then bump('click') end
        end

        -- 反手铐
        local cuffs = 0
        if sub('AntiArrestCuff', true) then
            cuffs = killCuffs(char)
            if cuffs > 0 then
                lastCuffTick = tick()
                bump('cuff')
                restoreMovement(hum, char, true)
            end
        end

        -- 被拷 / 被标记：回退到 1 秒前的位置，打断拖拽
        local cuffEvidence = cuffs > 0
        if sub('AntiArrestCuff', true) then
            if char:GetAttribute('Cuffed') == true or char:GetAttribute('Handcuffed') == true then
                cuffEvidence = true
            end
        end
        if cuffEvidence then lastCuffTick = tick() end

        if sub('AntiArrestEscape', true) and safeCF
            and (tick() - lastCuffTick) <= 2.5
            and (tick() - lastEscape) > 1.0
            and (safeCF.Position - root.Position).Magnitude > 4 then
            lastEscape = tick()
            pcall(snap, root, safeCF)
            restoreMovement(hum, char, true)
        end

        -- 反电击：麻痹 / 被电 / 速度被清零
        if sub('AntiArrestTaser', true) then
            local ok, state = pcall(function() return hum:GetState() end)
            local stunned = hum.PlatformStand
                or hum.WalkSpeed <= 1
                or (ok and (state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.FallingDown))
                or char:GetAttribute('Tased') == true

            local flying = Toggles.PlayerFly and Toggles.PlayerFly.Value
            local inVehicleSeat = hum.Sit and hum.SeatPart and hum.SeatPart:IsA('VehicleSeat')

            if stunned and not flying and not inVehicleSeat then
                if not wasStunned then bump('tase') end
                wasStunned = true
                restoreMovement(hum, char, true)
            else
                wasStunned = false
            end
        end
    end)

    pcall(function()
        local g = getgenv and getgenv() or _G
        if g then
            g.SetAntiArrestEnabled = function(v)
                if Toggles.AntiArrest then
                    Toggles.AntiArrest:SetValue(v == true)
                end
            end
        end
    end)
end

-- UI Settings
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('菜单')
MenuGroup:AddButton('卸载脚本', function() Library:Unload() end)
MenuGroup:AddButton('重新加载背景图（备用）', function()
    local reload = _G.YZHUB_ReloadBackground
    if type(reload) ~= 'function' then
        Library:Notify('背景图模块未就绪', 3)
        return
    end
    local ok = reload()
    Library:Notify(ok and '背景图已重新加载' or '背景图仍不可用，已保留渐变背景', 4)
end)
MenuGroup:AddLabel('菜单按键'):AddKeyPicker('MenuKeybind', { Default = 'RightShift', NoUI = false, Text = '菜单按键' })

-- 背景图不透明度（0% 等于关闭背景图）：文字被背景压住时把它调低
Options.BgOpacity = MenuGroup:AddSlider('BgOpacity', {
    Text = '背景图不透明度',
    Default = 85,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Suffix = ' %',
    Compact = false,
    AllowRightClickInput = true,
    Tooltip = '0% 关闭背景图；觉得文字看不清就往下调，觉得背景图太淡就往上调',
    Callback = function(v)
        local img = Library.BackgroundImageLabel
        local n = tonumber(v) or 85
        if math.clamp then n = math.clamp(n, 0, 100) else n = math.max(0, math.min(100, n)) end
        if img then
            img.ImageTransparency = 1 - (n / 100)
        end
        -- 压暗层跟着不透明度走：0% 时完全不加暗，100% 时保持约 45% 压暗
        local shade = Library.BackgroundShade
        if shade then
            shade.BackgroundTransparency = 1 - (0.55 * (n / 100))
        end
    end,
})


Library.ToggleKeybind = Options.MenuKeybind

pcall(function()
    if Library.KeybindFrame then
        Library.KeybindFrame.Visible = false
    end
end)
Library:SetWatermarkVisibility(true)

local FrameTimer = tick()
local FrameCounter = 0
local FPS = 60

RunService.RenderStepped:Connect(function()
    FrameCounter += 1
    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter
        FrameTimer = tick()
        FrameCounter = 0
    end
    pcall(function()
        Library:SetWatermark(('BY：y｜YZ | %s 帧 | %s 毫秒'):format(
            math.floor(FPS),
            math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
        ))
    end)
end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

ThemeManager:SetFolder('WX')
SaveManager:SetFolder('YZ HUB/监狱人生')

-- Custom Config Section
local ConfigBox = Tabs['UI Settings']:AddRightGroupbox('配置')
ConfigBox:AddInput('SaveManager_ConfigName', { Text = '配置名称' })
WXDrop(ConfigBox, 'SaveManager_ConfigList', { Text = '配置列表', Values = SaveManager:RefreshConfigList(), AllowNull = true })
ConfigBox:AddDivider()

ConfigBox:AddButton('创建配置', function()
    local name = Options.SaveManager_ConfigName.Value
    if name:gsub(' ', '') == '' then return Library:Notify('配置名称无效', 2) end
    local ok, err = SaveManager:Save(name)
    if not ok then return Library:Notify('失败：' .. err, 2) end
    Library:Notify('已创建配置「' .. name .. '」')
    Options.SaveManager_ConfigList:SetValues(SaveManager:RefreshConfigList())
    Options.SaveManager_ConfigList:SetValue(nil)
end):AddButton('加载配置', function()
    local name = Options.SaveManager_ConfigList.Value
    local ok, err = SaveManager:Load(name)
    if not ok then return Library:Notify('失败：' .. err, 2) end
    Library:Notify('已加载配置「' .. name .. '」')
end)

ConfigBox:AddButton({
    Text = '覆盖配置',
    DoubleClick = true,
    Func = function()
        local name = Options.SaveManager_ConfigList.Value
        if not name then return Library:Notify('请先选择配置', 2) end
        local ok, err = SaveManager:Save(name)
        if not ok then return Library:Notify('失败：' .. err, 2) end
        Library:Notify('已覆盖配置「' .. name .. '」')
    end
})

ConfigBox:AddButton('刷新列表', function()
    Options.SaveManager_ConfigList:SetValues(SaveManager:RefreshConfigList())
    Options.SaveManager_ConfigList:SetValue(nil)
end)

ConfigBox:AddButton('设为自动加载', function()
    local name = Options.SaveManager_ConfigList.Value
    if not name then return Library:Notify('请先选择配置', 2) end
    pcall(function() if makefolder then pcall(makefolder, SaveManager.Folder .. '/settings') end end)
    writefile(SaveManager.Folder .. '/settings/autoload.txt', name)
    SaveManager.AutoloadLabel:SetText('自动加载：' .. name)
    Library:Notify('已将「' .. name .. '」设为自动加载')
end)

SaveManager.AutoloadLabel = ConfigBox:AddLabel('自动加载：无', true)
if isfile(SaveManager.Folder .. '/settings/autoload.txt') then
    local name = readfile(SaveManager.Folder .. '/settings/autoload.txt')
    SaveManager.AutoloadLabel:SetText('自动加载：' .. name)
end

SaveManager:SetIgnoreIndexes({ 'SaveManager_ConfigList', 'SaveManager_ConfigName' })

ThemeManager:ApplyToTab(Tabs['UI Settings'])
end


-- Target HUD (Linoria Style)
do
    local hudGui = Instance.new('ScreenGui')
    hudGui.Name = 'BoarsTargetHUD'
    hudGui.ResetOnSpawn = false
    hudGui.DisplayOrder = 9500
    hudGui.IgnoreGuiInset = true

    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(hudGui)
            hudGui.Parent = game:GetService('CoreGui')
        elseif gethui then
            hudGui.Parent = gethui()
        else
            hudGui.Parent = game:GetService('CoreGui')
        end
    end)
    if not hudGui.Parent then
        pcall(function() hudGui.Parent = LP:WaitForChild('PlayerGui') end)
    end

    local defaultPos = UDim2.new(0.5, -135, 0.68, 0)
    local hudContainer
    local isCanvasGroup = false
    pcall(function()
        hudContainer = Instance.new('CanvasGroup')
        isCanvasGroup = true
    end)
    if not hudContainer then
        hudContainer = Instance.new('Frame')
        isCanvasGroup = false
    end

    hudContainer.Name = 'HUDContainer'
    hudContainer.Size = UDim2.new(0, 270, 0, 88)
    hudContainer.Position = defaultPos
    hudContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    hudContainer.BorderColor3 = Color3.fromRGB(45, 45, 45)
    hudContainer.BorderSizePixel = 1
    hudContainer.Visible = false
    hudContainer.Parent = hudGui

    _G.BoarsResetTargetHUD = function()
        if hudContainer then
            hudContainer.Position = defaultPos
        end
    end

    -- Outer 1px black border for Linoria dual-border aesthetic
    local outerBorder = Instance.new('UIStroke')
    outerBorder.Color = Color3.fromRGB(10, 10, 10)
    outerBorder.Thickness = 1
    outerBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    outerBorder.Parent = hudContainer

    -- Top Accent Bar (Signature Linoria 2px bar)
    local accentBar = Instance.new('Frame')
    accentBar.Name = 'AccentBar'
    accentBar.Size = UDim2.new(1, 0, 0, 2)
    accentBar.Position = UDim2.new(0, 0, 0, 0)
    accentBar.BorderSizePixel = 0
    accentBar.BackgroundColor3 = Library.AccentColor or Color3.fromRGB(0, 170, 255)
    accentBar.Parent = hudContainer

    -- Top Header Row
    local headerTitle = Instance.new('TextLabel')
    headerTitle.Name = 'HeaderTitle'
    headerTitle.Size = UDim2.new(0.5, 0, 0, 14)
    headerTitle.Position = UDim2.new(0, 6, 0, 4)
    headerTitle.BackgroundTransparency = 1
    headerTitle.Font = Enum.Font.Code
    headerTitle.TextSize = 10
    headerTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
    headerTitle.TextXAlignment = Enum.TextXAlignment.Left
    headerTitle.Text = '目标信息'
    headerTitle.Parent = hudContainer

    local distLabel = Instance.new('TextLabel')
    distLabel.Name = 'DistLabel'
    distLabel.Size = UDim2.new(0.5, -12, 0, 14)
    distLabel.Position = UDim2.new(0.5, 0, 0, 4)
    distLabel.BackgroundTransparency = 1
    distLabel.Font = Enum.Font.Code
    distLabel.TextSize = 10
    distLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    distLabel.TextXAlignment = Enum.TextXAlignment.Right
    distLabel.Text = ''
    distLabel.Parent = hudContainer

    -- Avatar Box
    local avatarFrame = Instance.new('Frame')
    avatarFrame.Name = 'AvatarFrame'
    avatarFrame.Size = UDim2.new(0, 52, 0, 52)
    avatarFrame.Position = UDim2.new(0, 6, 0, 22)
    avatarFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    avatarFrame.BorderColor3 = Color3.fromRGB(40, 40, 40)
    avatarFrame.BorderSizePixel = 1
    avatarFrame.Parent = hudContainer

    local avatarImg = Instance.new('ImageLabel')
    avatarImg.Name = 'AvatarImg'
    avatarImg.Size = UDim2.new(1, -2, 1, -2)
    avatarImg.Position = UDim2.new(0, 1, 0, 1)
    avatarImg.BackgroundTransparency = 1
    avatarImg.BorderSizePixel = 0
    avatarImg.Image = 'rbxasset://textures/ui/GuiImagePlaceholder.png'
    avatarImg.ScaleType = Enum.ScaleType.Fit
    avatarImg.Parent = avatarFrame

    -- Info Container (right of avatar)
    local infoContainer = Instance.new('Frame')
    infoContainer.Name = 'InfoContainer'
    infoContainer.Size = UDim2.new(1, -70, 0, 60)
    infoContainer.Position = UDim2.new(0, 64, 0, 20)
    infoContainer.BackgroundTransparency = 1
    infoContainer.BorderSizePixel = 0
    infoContainer.Parent = hudContainer

    -- Row 1: Target Name & Team Badge
    local nameLabel = Instance.new('TextLabel')
    nameLabel.Name = 'NameLabel'
    nameLabel.Size = UDim2.new(1, -60, 0, 15)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.Code
    nameLabel.TextSize = 12
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Text = '目标'
    nameLabel.Parent = infoContainer

    local teamBadge = Instance.new('TextLabel')
    teamBadge.Name = 'TeamBadge'
    teamBadge.Size = UDim2.new(0, 58, 0, 15)
    teamBadge.Position = UDim2.new(1, -58, 0, 0)
    teamBadge.BackgroundTransparency = 1
    teamBadge.Font = Enum.Font.Code
    teamBadge.TextSize = 10
    teamBadge.TextColor3 = Color3.fromRGB(200, 200, 200)
    teamBadge.TextXAlignment = Enum.TextXAlignment.Right
    teamBadge.Text = ''
    teamBadge.Parent = infoContainer

    -- Row 2: Weapon
    local weaponLabel = Instance.new('TextLabel')
    weaponLabel.Name = 'WeaponLabel'
    weaponLabel.Size = UDim2.new(1, 0, 0, 14)
    weaponLabel.Position = UDim2.new(0, 0, 0, 15)
    weaponLabel.BackgroundTransparency = 1
    weaponLabel.Font = Enum.Font.Code
    weaponLabel.TextSize = 10
    weaponLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    weaponLabel.TextXAlignment = Enum.TextXAlignment.Left
    weaponLabel.TextTruncate = Enum.TextTruncate.AtEnd
    weaponLabel.Text = '武器：无'
    weaponLabel.Parent = infoContainer

    -- Row 3: Health Bar Background & Fill
    local hpBarBack = Instance.new('Frame')
    hpBarBack.Name = 'HPBarBack'
    hpBarBack.Size = UDim2.new(1, 0, 0, 6)
    hpBarBack.Position = UDim2.new(0, 0, 0, 31)
    hpBarBack.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    hpBarBack.BorderColor3 = Color3.fromRGB(38, 38, 38)
    hpBarBack.BorderSizePixel = 1
    hpBarBack.Parent = infoContainer

    local hpBarFill = Instance.new('Frame')
    hpBarFill.Name = 'HPBarFill'
    hpBarFill.Size = UDim2.new(1, 0, 1, 0)
    hpBarFill.BorderSizePixel = 0
    hpBarFill.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    hpBarFill.Parent = hpBarBack

    -- Row 4: Health Text & Kill Chance
    local hpText = Instance.new('TextLabel')
    hpText.Name = 'HPText'
    hpText.Size = UDim2.new(0.55, 0, 0, 14)
    hpText.Position = UDim2.new(0, 0, 0, 39)
    hpText.BackgroundTransparency = 1
    hpText.Font = Enum.Font.Code
    hpText.TextSize = 10
    hpText.TextColor3 = Color3.fromRGB(210, 210, 210)
    hpText.TextXAlignment = Enum.TextXAlignment.Left
    hpText.Text = '100 / 100 生命'
    hpText.Parent = infoContainer

    local killChanceLabel = Instance.new('TextLabel')
    killChanceLabel.Name = 'KillChanceLabel'
    killChanceLabel.Size = UDim2.new(0.45, 0, 0, 14)
    killChanceLabel.Position = UDim2.new(0.55, 0, 0, 39)
    killChanceLabel.BackgroundTransparency = 1
    killChanceLabel.Font = Enum.Font.Code
    killChanceLabel.TextSize = 10
    killChanceLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
    killChanceLabel.TextXAlignment = Enum.TextXAlignment.Right
    killChanceLabel.Text = '命中率：95%'
    killChanceLabel.Parent = infoContainer

    -- Draggable Controller
    local isDragging = false
    local dragStartPos = nil
    local dragStartFramePos = nil

    hudContainer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStartPos = input.Position
            dragStartFramePos = hudContainer.Position
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStartPos
            hudContainer.Position = UDim2.new(
                dragStartFramePos.X.Scale,
                dragStartFramePos.X.Offset + delta.X,
                dragStartFramePos.Y.Scale,
                dragStartFramePos.Y.Offset + delta.Y
            )
        end
    end)

    -- Avatar Thumbnail Cache
    local avatarCache = {}
    local currentAvatarId = nil

    local function updateAvatar(userId)
        if currentAvatarId == userId then return end
        currentAvatarId = userId
        if avatarCache[userId] then
            avatarImg.Image = avatarCache[userId]
            return
        end
        avatarImg.Image = 'rbxasset://textures/ui/GuiImagePlaceholder.png'
        task.spawn(function()
            local success, result = pcall(function()
                return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            end)
            if success and result then
                avatarCache[userId] = result
                if currentAvatarId == userId then
                    avatarImg.Image = result
                end
            end
        end)
    end

    -- Tactical Kill Chance Calculator
    local function calculateKillChance(targetPlayer, targetChar)
        if not targetPlayer or not targetChar then return 0 end
        local targetHum = targetChar:FindFirstChildOfClass('Humanoid')
        if not targetHum or targetHum.Health <= 0 then return 0 end

        local myChar = LP.Character
        local myHum = myChar and myChar:FindFirstChildOfClass('Humanoid')
        if not myHum or myHum.Health <= 0 then return 0 end

        -- Target stunned on floor = guaranteed kill
        if isPlayerTased and isPlayerTased(targetPlayer) then
            return 100
        end

        local hpPercent = math.clamp(targetHum.Health / math.max(targetHum.MaxHealth, 100), 0, 1)
        local hpScore = (1 - hpPercent) * 45

        local myHpPercent = math.clamp(myHum.Health / math.max(myHum.MaxHealth, 100), 0, 1)
        local myHpScore = myHpPercent * 15

        local myTool = myChar:FindFirstChildOfClass('Tool')
        local myToolName = myTool and myTool.Name
        local myGunScore = 5
        if myToolName then
            if myToolName == 'Remington 870' or myToolName == 'FAL' or myToolName == 'AK-47' or myToolName == 'M4A1' then
                myGunScore = 25
            elseif myToolName == 'M9' or myToolName == 'Taser' then
                myGunScore = 18
            elseif (knownGunNames and knownGunNames[myToolName]) or myTool:GetAttribute('ToolType') == 'Gun' then
                myGunScore = 20
            end
        end

        local targetTool = targetChar:FindFirstChildOfClass('Tool')
        local targetToolName = targetTool and targetTool.Name
        local targetThreatScore = 0
        if not targetToolName or targetToolName == 'Fists' or targetToolName == 'Handcuffs' or targetToolName == 'Snack' then
            targetThreatScore = 15
        elseif targetToolName == 'Remington 870' or targetToolName == 'FAL' then
            targetThreatScore = -10
        elseif targetToolName == 'AK-47' or targetToolName == 'M4A1' then
            targetThreatScore = -5
        end

        local statusScore = 0
        if playerHasShield and playerHasShield(targetPlayer, targetChar) then
            statusScore = statusScore - 15
        end

        local myHrp = myChar:FindFirstChild('HumanoidRootPart')
        local targetHrp = targetChar:FindFirstChild('HumanoidRootPart')
        local distScore = 5
        if myHrp and targetHrp then
            local dist = (myHrp.Position - targetHrp.Position).Magnitude
            if dist < 40 then
                distScore = 10
            elseif dist < 150 then
                distScore = 7
            elseif dist < 400 then
                distScore = 4
            else
                distScore = 1
            end
        end

        local baseScore = 20
        local totalChance = math.floor(baseScore + hpScore + myHpScore + myGunScore + targetThreatScore + statusScore + distScore)
        return math.clamp(totalChance, 5, 99)
    end

    -- Main Update Loop
    local lastTargetPlayer = nil
    local lastTargetTime = 0
    local displayTarget = nil
    local currentHPDisplay = 100
    local currentAlpha = 0

    local hudConn = RunService.RenderStepped:Connect(function(dt)
        if not (Toggles.TargetHUD and Toggles.TargetHUD.Value) then
            hudContainer.Visible = false
            currentAlpha = 0
            return
        end

        -- 1. Identify active target
        local activeTarget = nil
        if rageTargetPart and rageTargetPart.Parent then
            activeTarget = Players:GetPlayerFromCharacter(rageTargetPart.Parent)
        end
        if not activeTarget and targetPartCache and targetPartCache.Parent then
            activeTarget = Players:GetPlayerFromCharacter(targetPartCache.Parent)
        end
        if not activeTarget and lastShotInfo.targetPlayer and (tick() - (lastShotInfo.tick or 0) < 2.2) then
            local char = lastShotInfo.targetPlayer.Character
            local hum = char and char:FindFirstChildOfClass('Humanoid')
            if hum and hum.Health > 0 then
                activeTarget = lastShotInfo.targetPlayer
            end
        end
        if not activeTarget then
            local nearest = FindNearestTarget()
            if nearest and nearest.Parent then
                activeTarget = Players:GetPlayerFromCharacter(nearest.Parent)
            end
        end

        if activeTarget and activeTarget.Character and activeTarget.Character:FindFirstChildOfClass('Humanoid') and activeTarget.Character:FindFirstChildOfClass('Humanoid').Health > 0 then
            displayTarget = activeTarget
            lastTargetTime = tick()
        end

        local timeSinceTarget = tick() - lastTargetTime
        local shouldShow = displayTarget and (timeSinceTarget < 1.8)

        if shouldShow then
            currentAlpha = math.clamp(currentAlpha + dt * 7, 0, 1)
        else
            currentAlpha = math.clamp(currentAlpha - dt * 4, 0, 1)
        end

        if currentAlpha <= 0.01 then
            hudContainer.Visible = false
            return
        else
            hudContainer.Visible = true
        end

        if isCanvasGroup then
            hudContainer.GroupTransparency = 1 - currentAlpha
        end

        -- Accent Color
        local accentCol = (Toggles.TargetHUDCustomColor and Toggles.TargetHUDCustomColor.Value and Options.TargetHUDAccentColor and Options.TargetHUDAccentColor.Value)
            or Library.AccentColor
            or Color3.fromRGB(0, 170, 255)
        accentBar.BackgroundColor3 = accentCol

        if not displayTarget or not displayTarget.Parent then return end
        local char = displayTarget.Character
        local hum = char and char:FindFirstChildOfClass('Humanoid')
        if not hum then return end

        -- Avatar
        if Toggles.TargetHUDShowAvatar and Toggles.TargetHUDShowAvatar.Value then
            avatarFrame.Visible = true
            infoContainer.Position = UDim2.new(0, 64, 0, 20)
            infoContainer.Size = UDim2.new(1, -70, 0, 60)
            updateAvatar(displayTarget.UserId)
        else
            avatarFrame.Visible = false
            infoContainer.Position = UDim2.new(0, 8, 0, 20)
            infoContainer.Size = UDim2.new(1, -16, 0, 60)
        end

        -- Name & Team
        nameLabel.Text = displayTarget.DisplayName or displayTarget.Name
        local team = displayTarget.Team
        local teamName = team and team.Name or 'None'
        local teamCol = Color3.fromRGB(200, 200, 200)
        if team == Teams:FindFirstChild('Criminals') then
            teamCol = Color3.fromRGB(255, 65, 65)
            teamName = 'CRIM'
        elseif team == Teams:FindFirstChild('Inmates') then
            teamCol = Color3.fromRGB(255, 175, 20)
            teamName = 'INMATE'
        elseif team == Teams:FindFirstChild('Guards') then
            teamCol = Color3.fromRGB(0, 160, 255)
            teamName = 'GUARD'
        end
        teamBadge.Text = '[' .. teamName .. ']'
        teamBadge.TextColor3 = teamCol

        -- Weapon
        if Toggles.TargetHUDShowWeapon and Toggles.TargetHUDShowWeapon.Value then
            weaponLabel.Visible = true
            local tool = char:FindFirstChildOfClass('Tool')
            local toolName = tool and tool.Name or 'None'
            local ammoStr = ''
            if tool then
                local ammo = tool:GetAttribute('Local_CurrentAmmo') or tool:GetAttribute('CurrentAmmo')
                if ammo then
                    ammoStr = string.format(' [%d]', ammo)
                end
            end
            weaponLabel.Text = '武器：' .. toolName .. ammoStr
        else
            weaponLabel.Visible = false
        end

        -- Health Bar & Numbers
        local maxHp = math.max(hum.MaxHealth, 100)
        local realHp = math.clamp(hum.Health, 0, maxHp)
        currentHPDisplay = currentHPDisplay + (realHp - currentHPDisplay) * math.clamp(dt * 12, 0, 1)
        local hpRatio = math.clamp(currentHPDisplay / maxHp, 0, 1)

        hpBarFill.Size = UDim2.new(hpRatio, 0, 1, 0)
        local hpColor
        if hpRatio > 0.5 then
            local t = (hpRatio - 0.5) * 2
            hpColor = Color3.fromRGB(240, 200, 50):Lerp(Color3.fromRGB(46, 204, 113), t)
        else
            local t = hpRatio * 2
            hpColor = Color3.fromRGB(230, 50, 50):Lerp(Color3.fromRGB(240, 200, 50), t)
        end

        if Options.TargetHUDStyle and Options.TargetHUDStyle.Value == 'Linoria Accent' then
            hpBarFill.BackgroundColor3 = accentCol
        else
            hpBarFill.BackgroundColor3 = hpColor
        end

        hpText.Text = string.format('%d / %d 生命', math.floor(realHp + 0.5), math.floor(maxHp))

        -- Kill Chance
        if Toggles.TargetHUDShowChance and Toggles.TargetHUDShowChance.Value then
            killChanceLabel.Visible = true
            local chance = calculateKillChance(displayTarget, char)
            killChanceLabel.Text = string.format('命中率：%d%%', chance)
            if chance >= 70 then
                killChanceLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
            elseif chance >= 40 then
                killChanceLabel.TextColor3 = Color3.fromRGB(240, 200, 50)
            else
                killChanceLabel.TextColor3 = Color3.fromRGB(230, 50, 50)
            end
        else
            killChanceLabel.Visible = false
        end

        -- Distance
        if Toggles.TargetHUDShowDistance and Toggles.TargetHUDShowDistance.Value then
            distLabel.Visible = true
            local myRoot = LP.Character and LP.Character:FindFirstChild('HumanoidRootPart')
            local targetRoot = char:FindFirstChild('HumanoidRootPart')
            if myRoot and targetRoot then
                local dist = math.floor((myRoot.Position - targetRoot.Position).Magnitude)
                distLabel.Text = dist .. ' studs'
            else
                distLabel.Text = ''
            end
        else
            distLabel.Visible = false
        end
    end)

    _G.BoarsCleanupTargetHUD = function()
        if hudConn then
            hudConn:Disconnect()
            hudConn = nil
        end
        if hudGui then
            pcall(function() hudGui:Destroy() end)
        end
    end
end

-- ====================== KILLFEED ======================
do
    local TweenService = game:GetService('TweenService')
    local feedGui = Instance.new('ScreenGui')
    feedGui.Name = 'BoarsKillfeed'
    feedGui.ResetOnSpawn = false
    feedGui.DisplayOrder = 9600
    feedGui.IgnoreGuiInset = true

    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(feedGui)
            feedGui.Parent = game:GetService('CoreGui')
        elseif gethui then
            feedGui.Parent = gethui()
        else
            feedGui.Parent = game:GetService('CoreGui')
        end
    end)
    if not feedGui.Parent then
        pcall(function() feedGui.Parent = LP:WaitForChild('PlayerGui') end)
    end

    local feedContainer = Instance.new('Frame')
    feedContainer.Name = 'FeedContainer'
    -- 锚点固定在右上角，配合 UIScale 缩放时右下角不会跑位
    feedContainer.AnchorPoint = Vector2.new(1, 0)
    feedContainer.Size = UDim2.new(0, 340, 0, 380)
    feedContainer.Position = UDim2.new(1, -12, 0, 30)
    feedContainer.BackgroundTransparency = 1
    feedContainer.ClipsDescendants = false
    feedContainer.Parent = feedGui

    -- 整体缩放（默认比原版小一圈，可在"界面缩放"里调）
    local feedScale = Instance.new('UIScale')
    feedScale.Name = 'FeedScale'
    feedScale.Scale = (Options.KillfeedScale and Options.KillfeedScale.Value) or 0.78
    feedScale.Parent = feedContainer

    if Options.KillfeedScale then
        Options.KillfeedScale:OnChanged(function()
            local s = Options.KillfeedScale.Value or 0.78
            feedScale.Scale = math.clamp(s, 0.5, 1.2)
        end)
    end

    local listLayout = Instance.new('UIListLayout')
    listLayout.Name = 'Layout'
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    listLayout.Padding = UDim.new(0, 5)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = feedContainer

    local activeEntries = {}
    local entryOrder = 0

    -- 统一青色主题（低饱和、无渐变、无发光，避免塑料感）
    local THEME = {
        accent    = Color3.fromRGB(0, 214, 232),
        accentDim = Color3.fromRGB(0, 126, 140),
        surface   = Color3.fromRGB(9, 12, 14),
        killer    = Color3.fromRGB(236, 242, 244),
        victim    = Color3.fromRGB(140, 150, 156),
        meta      = Color3.fromRGB(102, 112, 118),
        hairline  = Color3.fromRGB(32, 38, 42),
    }

    local function trimName(name, maxLen)
        if not name then return '未知' end
        if #name > (maxLen or 12) then
            return string.sub(name, 1, maxLen or 12) .. '..'
        end
        return name
    end

    local function formatWeaponName(weapon)
        if not weapon or weapon == '' or weapon == 'Gun' or weapon == 'Combat' then
            return nil
        end
        return weapon
    end

    -- 命中播报：每个受击者最近一条命中条目（用于连击合并）
    local hitEntryByVictim = setmetatable({}, { __mode = 'k' })

    -- 统一到期淡出（token 机制：合并续期后旧计时直接作废）
    local function scheduleExpire(entryData, duration)
        local token = (entryData.token or 0) + 1
        entryData.token = token
        local entry = entryData.frame
        task.delay(duration, function()
            if entryData.token ~= token then return end
            if not (entry and entry.Parent) then return end
            local fadeOutInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            TweenService:Create(entry, fadeOutInfo, { BackgroundTransparency = 1 }):Play()
            local accent = entry:FindFirstChild('Accent')
            if accent then
                TweenService:Create(accent, fadeOutInfo, { BackgroundTransparency = 1 }):Play()
            end
            for _, child in ipairs(entry:GetChildren()) do
                if child:IsA('TextLabel') then
                    TweenService:Create(child, fadeOutInfo, { TextTransparency = 1 }):Play()
                end
            end
            task.wait(0.32)
            for idx, item in ipairs(activeEntries) do
                if item == entryData then
                    table.remove(activeEntries, idx)
                    break
                end
            end
            if entryData.victim and hitEntryByVictim[entryData.victim] == entryData then
                hitEntryByVictim[entryData.victim] = nil
            end
            if entry and entry.Parent then
                entry:Destroy()
            end
        end)
    end

    -- extra.kind = 'hit' 时表示"命中播报"（extra.damage 为本次伤害）
    local function pushKillfeedEntry(killer, victim, weaponName, isHeadshot, distanceStuds, extra)
        if not (Toggles.Killfeed and Toggles.Killfeed.Value) then return end

        local isHit = (extra ~= nil and extra.kind == 'hit')
        local hitDamage = (extra and tonumber(extra.damage)) or 0

        if isHit then
            -- 命中播报开关
            if Toggles.KillfeedShowHits and Toggles.KillfeedShowHits.Value == false then return end
            -- 命中播报只播报自己的命中
            if killer ~= LP then return end
        end

        local isMyKill = (killer == LP)
        local isMyDeath = (victim == LP)

        if Toggles.KillfeedOnlyLocal and Toggles.KillfeedOnlyLocal.Value then
            if not isMyKill and not isMyDeath then
                return
            end
        end

        local maxItems = (Options.KillfeedMaxItems and Options.KillfeedMaxItems.Value) or 5
        local duration = (Options.KillfeedDuration and Options.KillfeedDuration.Value) or 5

        -- 连击合并：同一目标短时间内的连续命中累加到同一条
        if isHit and (Toggles.KillfeedMergeHits == nil or Toggles.KillfeedMergeHits.Value) then
            local prev = hitEntryByVictim[victim]
            if prev and prev.frame and prev.frame.Parent
                and prev.damageLabel and prev.damageLabel.Parent
                and (tick() - (prev.lastTick or 0)) <= 1.5 then
                prev.damage = (prev.damage or 0) + (hitDamage > 0 and hitDamage or 0)
                prev.lastTick = tick()
                prev.damageLabel.Text = '-' .. math.floor(prev.damage + 0.5)
                scheduleExpire(prev, duration)
                return
            end
        end

        -- Remove oldest if limit reached
        while #activeEntries >= maxItems do
            local oldest = table.remove(activeEntries, 1)
            if oldest and oldest.frame and oldest.frame.Parent then
                oldest.frame:Destroy()
            end
        end

        entryOrder = entryOrder + 1

        local entry = Instance.new('Frame')
        entry.Name = 'Entry_' .. entryOrder
        entry.LayoutOrder = entryOrder
        entry.AutomaticSize = Enum.AutomaticSize.X
        entry.Size = UDim2.new(0, 0, 0, 24)
        entry.BackgroundColor3 = THEME.surface
        entry.BackgroundTransparency = 1
        entry.BorderSizePixel = 0

        local corner = Instance.new('UICorner')
        corner.CornerRadius = UDim.new(0, 2)
        corner.Parent = entry

        local padding = Instance.new('UIPadding')
        padding.PaddingLeft = UDim.new(0, 0)
        padding.PaddingRight = UDim.new(0, 10)
        padding.Parent = entry

        local hLayout = Instance.new('UIListLayout')
        hLayout.FillDirection = Enum.FillDirection.Horizontal
        hLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        hLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        hLayout.Padding = UDim.new(0, 6)
        hLayout.SortOrder = Enum.SortOrder.LayoutOrder
        hLayout.Parent = entry

        local highlightMine = (Toggles.KillfeedHighlightMine == nil or Toggles.KillfeedHighlightMine.Value)
        local showAccent = isMyKill and highlightMine
        -- 命中条用更淡的强调条，和击杀区分开
        local accentAlpha = showAccent and 0.05 or (isHit and 0.6 or 1)

        -- 左侧 2px 强调条：只在"自己的击杀"出现，代替原来的彩色描边
        local accentBar = Instance.new('Frame')
        accentBar.Name = 'Accent'
        accentBar.LayoutOrder = 0
        accentBar.Size = UDim2.new(0, 2, 1, 0)
        accentBar.BackgroundColor3 = (isHit and not showAccent) and THEME.accentDim or THEME.accent
        accentBar.BackgroundTransparency = 1
        accentBar.BorderSizePixel = 0
        accentBar.Parent = entry

        local labelOrder = 0

        -- 1. 击杀者
        labelOrder = labelOrder + 1
        local killerLabel = Instance.new('TextLabel')
        killerLabel.Name = 'Killer'
        killerLabel.LayoutOrder = labelOrder
        killerLabel.AutomaticSize = Enum.AutomaticSize.XY
        killerLabel.BackgroundTransparency = 1
        killerLabel.Font = Enum.Font.GothamMedium
        killerLabel.TextSize = 13
        killerLabel.Text = (killer and trimName(killer.DisplayName or killer.Name, 12)) or '未知'
        killerLabel.TextColor3 = showAccent and THEME.accent or THEME.killer
        killerLabel.TextTransparency = 1
        killerLabel.Parent = entry

        -- 2. 武器（无方括号，低对比度辅助信息）
        local weaponText = formatWeaponName(weaponName)
        if weaponText and (Toggles.KillfeedShowWeapon == nil or Toggles.KillfeedShowWeapon.Value) then
            labelOrder = labelOrder + 1
            local wepLabel = Instance.new('TextLabel')
            wepLabel.Name = 'Weapon'
            wepLabel.LayoutOrder = labelOrder
            wepLabel.AutomaticSize = Enum.AutomaticSize.XY
            wepLabel.BackgroundTransparency = 1
            wepLabel.Font = Enum.Font.Gotham
            wepLabel.TextSize = 11
            wepLabel.Text = weaponText
            wepLabel.TextColor3 = THEME.meta
            wepLabel.TextTransparency = 1
            wepLabel.Parent = entry
        end

        -- 3. 爆头标记（等宽小标，替代 emoji）
        if isHeadshot and (Toggles.KillfeedShowHeadshot == nil or Toggles.KillfeedShowHeadshot.Value) then
            labelOrder = labelOrder + 1
            local hsLabel = Instance.new('TextLabel')
            hsLabel.Name = 'Headshot'
            hsLabel.LayoutOrder = labelOrder
            hsLabel.AutomaticSize = Enum.AutomaticSize.XY
            hsLabel.BackgroundTransparency = 1
            hsLabel.Font = Enum.Font.Code
            hsLabel.TextSize = 9
            hsLabel.Text = 'HS'
            hsLabel.TextColor3 = THEME.accent
            hsLabel.TextTransparency = 1
            hsLabel.Parent = entry
        end

        -- 4. 受击者
        labelOrder = labelOrder + 1
        local victimLabel = Instance.new('TextLabel')
        victimLabel.Name = 'Victim'
        victimLabel.LayoutOrder = labelOrder
        victimLabel.AutomaticSize = Enum.AutomaticSize.XY
        victimLabel.BackgroundTransparency = 1
        victimLabel.Font = Enum.Font.GothamMedium
        victimLabel.TextSize = 13
        victimLabel.Text = (victim and trimName(victim.DisplayName or victim.Name, 12)) or '未知'
        victimLabel.TextColor3 = isMyDeath and THEME.accent or THEME.victim
        victimLabel.TextTransparency = 1
        victimLabel.Parent = entry

        -- 4.5 伤害（仅命中播报，等宽数字，带负号）
        local damageLabel
        if isHit and hitDamage > 0 then
            labelOrder = labelOrder + 1
            damageLabel = Instance.new('TextLabel')
            damageLabel.Name = 'Damage'
            damageLabel.LayoutOrder = labelOrder
            damageLabel.AutomaticSize = Enum.AutomaticSize.XY
            damageLabel.BackgroundTransparency = 1
            damageLabel.Font = Enum.Font.Code
            damageLabel.TextSize = 11
            damageLabel.Text = '-' .. math.floor(hitDamage + 0.5)
            damageLabel.TextColor3 = THEME.accent
            damageLabel.TextTransparency = 1
            damageLabel.Parent = entry
        end

        -- 5. 距离（等宽尾注）
        if distanceStuds and distanceStuds > 0 and (Toggles.KillfeedShowDistance and Toggles.KillfeedShowDistance.Value) then
            labelOrder = labelOrder + 1
            local distLabel = Instance.new('TextLabel')
            distLabel.Name = 'Distance'
            distLabel.LayoutOrder = labelOrder
            distLabel.AutomaticSize = Enum.AutomaticSize.XY
            distLabel.BackgroundTransparency = 1
            distLabel.Font = Enum.Font.Code
            distLabel.TextSize = 10
            distLabel.Text = math.round(distanceStuds * 0.28) .. 'm'
            distLabel.TextColor3 = THEME.meta
            distLabel.TextTransparency = 1
            distLabel.Parent = entry
        end

        entry.Parent = feedContainer

        local entryData = {
            frame = entry,
            created = tick(),
            victim = victim,
            isHit = isHit,
            damage = isHit and hitDamage or nil,
            damageLabel = damageLabel,
            lastTick = tick(),
        }
        table.insert(activeEntries, entryData)

        if isHit and victim then
            hitEntryByVictim[victim] = entryData
        end

        -- 入场：厚度淡入，强调条由 0 拉出，短促不拖沓
        local fadeInInfo = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(entry, fadeInInfo, { BackgroundTransparency = isHit and 0.46 or 0.34 }):Play()
        if accentAlpha < 1 then
            TweenService:Create(accentBar, fadeInInfo, { BackgroundTransparency = accentAlpha }):Play()
        end
        for _, child in ipairs(entry:GetChildren()) do
            if child:IsA('TextLabel') then
                TweenService:Create(child, fadeInInfo, { TextTransparency = 0 }):Play()
            end
        end

        -- Auto Expire
        scheduleExpire(entryData, duration)
    end

    _G.BoarsAddKillfeed = function(killer, victim, weapon, isHead, dist, extra)
        pcall(function()
            pushKillfeedEntry(killer, victim, weapon, isHead, dist, extra)
        end)
    end

    _G.BoarsTestKillfeed = function()
        local testGuns = { 'M4A1', 'Remington 870', 'AK-47', 'M9', 'Taser' }
        local randomGun = testGuns[math.random(1, #testGuns)]
        local randomDist = math.random(15, 120)
        local isHead = (math.random(1, 2) == 1)

        local otherPlayers = {}
        for _, p in Players:GetPlayers() do
            if p ~= LP then table.insert(otherPlayers, p) end
        end
        local mockVictim = (#otherPlayers > 0 and otherPlayers[math.random(1, #otherPlayers)])
        pushKillfeedEntry(LP, mockVictim, randomGun, isHead, randomDist)
    end

    _G.BoarsTestHitfeed = function()
        local testGuns = { 'M4A1', 'Remington 870', 'AK-47', 'M9' }
        local randomGun = testGuns[math.random(1, #testGuns)]
        local randomDist = math.random(15, 120)

        local otherPlayers = {}
        for _, p in Players:GetPlayers() do
            if p ~= LP then table.insert(otherPlayers, p) end
        end
        local mockVictim = (#otherPlayers > 0 and otherPlayers[math.random(1, #otherPlayers)])

        -- 连打三发：开了"连击合并"会累加成一条，关闭则出现三条
        for i = 1, 3 do
            pushKillfeedEntry(LP, mockVictim, randomGun, false, randomDist, {
                kind = 'hit',
                damage = math.random(18, 34)
            })
        end
    end

    _G.BoarsCleanupKillfeed = function()
        if feedGui then
            pcall(function() feedGui:Destroy() end)
        end
    end
end

-- ====================== CUSTOM VIEWMODEL & SPIN ======================
do
    local origC0Map = setmetatable({}, { __mode = 'k' })
    local spinAngle = 0
    local vmConn = nil

    local function restoreViewmodel()
        for grip, c0 in pairs(origC0Map) do
            if grip and grip.Parent then
                pcall(function() grip.C0 = c0 end)
            end
        end
    end

    if Toggles.CustomViewmodel then
        Toggles.CustomViewmodel:OnChanged(function()
            if not Toggles.CustomViewmodel.Value then
                restoreViewmodel()
            end
        end)
    end

    LP.CharacterAdded:Connect(function()
        table.clear(origC0Map)
        spinAngle = 0
    end)

    local lastVMTick = tick()
    vmConn = RunService.RenderStepped:Connect(function()
        local now = tick()
        local dt = math.clamp(now - lastVMTick, 0.001, 0.1)
        lastVMTick = now

        if not (Toggles.CustomViewmodel and Toggles.CustomViewmodel.Value) then
            return
        end

        local char = LP.Character
        if not char then return end

        local isFirstPerson = false
        local head = char:FindFirstChild('Head')
        if head and Camera then
            isFirstPerson = (Camera.CFrame.Position - head.Position).Magnitude < 1.5
        end
        if LP.CameraMode == Enum.CameraMode.LockFirstPerson then
            isFirstPerson = true
        end

        if Toggles.ViewmodelFirstPersonOnly and Toggles.ViewmodelFirstPersonOnly.Value and not isFirstPerson then
            restoreViewmodel()
            return
        end

        local rightArm = char:FindFirstChild('Right Arm')
        local leftArm = char:FindFirstChild('Left Arm')

        -- Show arms in first person if enabled
        if isFirstPerson and Toggles.ViewmodelShowArms and Toggles.ViewmodelShowArms.Value then
            pcall(function()
                if rightArm then rightArm.LocalTransparencyModifier = 0 end
                if leftArm then leftArm.LocalTransparencyModifier = 0 end
            end)
        end

        local rightGrip = rightArm and rightArm:FindFirstChild('RightGrip')
        if not rightGrip then return end

        if not origC0Map[rightGrip] then
            origC0Map[rightGrip] = rightGrip.C0
        end

        local origC0 = origC0Map[rightGrip]
        if not origC0 then return end

        local offX = ((Options.ViewmodelOffsetX and Options.ViewmodelOffsetX.Value) or 0) / 20
        local offY = ((Options.ViewmodelOffsetY and Options.ViewmodelOffsetY.Value) or 0) / 20
        local offZ = ((Options.ViewmodelOffsetZ and Options.ViewmodelOffsetZ.Value) or 0) / 20

        local rotX = math.rad((Options.ViewmodelRotX and Options.ViewmodelRotX.Value) or 0)
        local rotY = math.rad((Options.ViewmodelRotY and Options.ViewmodelRotY.Value) or 0)
        local rotZ = math.rad((Options.ViewmodelRotZ and Options.ViewmodelRotZ.Value) or 0)

        if Toggles.ViewmodelSpin and Toggles.ViewmodelSpin.Value then
            local spd = ((Options.ViewmodelSpinSpeed and Options.ViewmodelSpinSpeed.Value) or 10) * 15
            spinAngle = (spinAngle + spd * dt) % 360
            local rad = math.rad(spinAngle)
            local axis = (Options.ViewmodelSpinAxis and Options.ViewmodelSpinAxis.Value) or 'Y (Yaw)'
            if axis == 'Y (Yaw)' then
                rotY = rotY + rad
            elseif axis == 'X (Pitch)' then
                rotX = rotX + rad
            elseif axis == 'Z (Roll)' then
                rotZ = rotZ + rad
            elseif axis == 'All Axes' then
                rotX = rotX + rad
                rotY = rotY + rad * 0.7
                rotZ = rotZ + rad * 1.3
            end
        end

        -- Compute delta in Camera space and map into Right Arm object space
        local camCF = Camera.CFrame
        local deltaWorld = (camCF.RightVector * offX) + (camCF.UpVector * offY) + (camCF.LookVector * offZ)
        local armOffset = rightArm.CFrame:VectorToObjectSpace(deltaWorld)

        local rotCF = CFrame.Angles(rotX, rotY, rotZ)

        pcall(function()
            rightGrip.C0 = CFrame.new(origC0.Position + armOffset) * origC0.Rotation * rotCF
        end)
    end)

    _G.BoarsCleanupViewmodel = function()
        if vmConn then
            vmConn:Disconnect()
            vmConn = nil
        end
        restoreViewmodel()
    end
end

-- ====================== ROBLOX OPTIMIZER ======================
do
    local origPartProps = setmetatable({}, { __mode = 'k' })
    local origTextureProps = setmetatable({}, { __mode = 'k' })
    local origEffectProps = setmetatable({}, { __mode = 'k' })
    local origPostFXProps = setmetatable({}, { __mode = 'k' })
    local origLighting = {
        GlobalShadows = nil
    }
    local origTerrain = {
        WaterWaveSize = nil,
        WaterWaveSpeed = nil,
        WaterReflectance = nil,
        Decoration = nil
    }

    local descendantConn = nil
    local lightingConn = nil
    local isOptimizingBatch = false

    local function isCharacterOrTool(inst)
        local cur = inst
        while cur and cur ~= Workspace and cur ~= game do
            if cur:IsA('Model') then
                if cur:FindFirstChildOfClass('Humanoid') then
                    return true
                end
            end
            if cur:IsA('Tool') or cur:IsA('Accoutrement') then
                return true
            end
            cur = cur.Parent
        end
        if Workspace.CurrentCamera and inst:IsDescendantOf(Workspace.CurrentCamera) then
            return true
        end
        return false
    end

    local function optimizeInstance(inst)
        if not inst or not inst.Parent then return end
        if isCharacterOrTool(inst) then return end

        if inst:IsA('BasePart') then
            if not origPartProps[inst] then
                origPartProps[inst] = {
                    Material = inst.Material,
                    Reflectance = inst.Reflectance,
                    CastShadow = inst.CastShadow
                }
            end
            if Toggles.OptGlobalShadows and Toggles.OptGlobalShadows.Value then
                inst.CastShadow = false
            end
            if Toggles.OptSmoothMaterials and Toggles.OptSmoothMaterials.Value then
                inst.Material = Enum.Material.SmoothPlastic
                inst.Reflectance = 0
            end
        elseif inst:IsA('Decal') or inst:IsA('Texture') then
            if not origTextureProps[inst] then
                origTextureProps[inst] = {
                    Transparency = inst.Transparency
                }
            end
            if Toggles.OptRemoveTextures and Toggles.OptRemoveTextures.Value then
                inst.Transparency = 1
            end
        elseif inst:IsA('ParticleEmitter') or inst:IsA('Smoke') or inst:IsA('Fire') or inst:IsA('Sparkles') or inst:IsA('Trail') or inst:IsA('Beam') then
            if not origEffectProps[inst] then
                origEffectProps[inst] = {
                    Enabled = inst.Enabled
                }
            end
            if Toggles.OptDisableParticles and Toggles.OptDisableParticles.Value then
                inst.Enabled = false
            end
        elseif inst:IsA('Light') then
            if not origEffectProps[inst] then
                origEffectProps[inst] = {
                    Shadows = inst.Shadows
                }
            end
            if Toggles.OptGlobalShadows and Toggles.OptGlobalShadows.Value then
                inst.Shadows = false
            end
        end
    end

    local function optimizeLighting()
        if origLighting.GlobalShadows == nil then
            origLighting.GlobalShadows = Lighting.GlobalShadows
        end
        if Toggles.OptGlobalShadows and Toggles.OptGlobalShadows.Value then
            pcall(function() Lighting.GlobalShadows = false end)
        else
            if origLighting.GlobalShadows ~= nil then
                pcall(function() Lighting.GlobalShadows = origLighting.GlobalShadows end)
            end
        end

        if Toggles.OptDisablePostEffects and Toggles.OptDisablePostEffects.Value then
            local function checkFX(parent)
                for _, child in ipairs(parent:GetChildren()) do
                    if child:IsA('PostEffect') or child:IsA('Atmosphere') or child:IsA('BloomEffect') or child:IsA('BlurEffect') or child:IsA('SunRaysEffect') or child:IsA('ColorCorrectionEffect') or child:IsA('DepthOfFieldEffect') then
                        if origPostFXProps[child] == nil then
                            origPostFXProps[child] = child.Enabled
                        end
                        pcall(function() child.Enabled = false end)
                    end
                end
            end
            checkFX(Lighting)
            if Workspace.CurrentCamera then
                checkFX(Workspace.CurrentCamera)
            end
        end
    end

    local function optimizeTerrain()
        local terrain = Workspace.Terrain
        if not terrain then return end
        if origTerrain.WaterWaveSize == nil then
            pcall(function()
                origTerrain.WaterWaveSize = terrain.WaterWaveSize
                origTerrain.WaterWaveSpeed = terrain.WaterWaveSpeed
                origTerrain.WaterReflectance = terrain.WaterReflectance
                origTerrain.Decoration = terrain.Decoration
            end)
        end
        if Toggles.OptLowTerrain and Toggles.OptLowTerrain.Value then
            pcall(function()
                terrain.WaterWaveSize = 0
                terrain.WaterWaveSpeed = 0
                terrain.WaterReflectance = 0
                terrain.Decoration = false
            end)
        end
    end

    local function optimizeAllAsync()
        if isOptimizingBatch then return end
        isOptimizingBatch = true
        optimizeLighting()
        optimizeTerrain()
        local descs = Workspace:GetDescendants()
        local batchSize = 1000
        for i = 1, #descs do
            if not Toggles.Optimizer or not Toggles.Optimizer.Value then
                break
            end
            local d = descs[i]
            pcall(optimizeInstance, d)
            if i % batchSize == 0 then
                task.wait()
            end
        end
        isOptimizingBatch = false
    end

    local function restoreAll()
        isOptimizingBatch = false

        if origLighting.GlobalShadows ~= nil then
            pcall(function() Lighting.GlobalShadows = origLighting.GlobalShadows end)
            origLighting.GlobalShadows = nil
        end

        local terrain = Workspace.Terrain
        if terrain and origTerrain.WaterWaveSize ~= nil then
            pcall(function()
                terrain.WaterWaveSize = origTerrain.WaterWaveSize or 0.15
                terrain.WaterWaveSpeed = origTerrain.WaterWaveSpeed or 10
                terrain.WaterReflectance = origTerrain.WaterReflectance or 1
                terrain.Decoration = (origTerrain.Decoration ~= nil) and origTerrain.Decoration or true
            end)
            origTerrain.WaterWaveSize = nil
            origTerrain.WaterWaveSpeed = nil
            origTerrain.WaterReflectance = nil
            origTerrain.Decoration = nil
        end

        for fx, origEnabled in pairs(origPostFXProps) do
            pcall(function()
                if fx and fx.Parent then
                    fx.Enabled = origEnabled
                end
            end)
        end
        table.clear(origPostFXProps)

        for part, props in pairs(origPartProps) do
            pcall(function()
                if part and part.Parent then
                    if props.Material ~= nil then part.Material = props.Material end
                    if props.Reflectance ~= nil then part.Reflectance = props.Reflectance end
                    if props.CastShadow ~= nil then part.CastShadow = props.CastShadow end
                end
            end)
        end
        table.clear(origPartProps)

        for tex, props in pairs(origTextureProps) do
            pcall(function()
                if tex and tex.Parent then
                    if props.Transparency ~= nil then tex.Transparency = props.Transparency end
                end
            end)
        end
        table.clear(origTextureProps)

        for eff, props in pairs(origEffectProps) do
            pcall(function()
                if eff and eff.Parent then
                    if props.Enabled ~= nil then eff.Enabled = props.Enabled end
                    if props.Shadows ~= nil then eff.Shadows = props.Shadows end
                end
            end)
        end
        table.clear(origEffectProps)
    end

    local function startListening()
        if not descendantConn then
            descendantConn = Workspace.DescendantAdded:Connect(function(desc)
                if Toggles.Optimizer and Toggles.Optimizer.Value and Toggles.OptOptimizeNew and Toggles.OptOptimizeNew.Value then
                    task.defer(function()
                        pcall(optimizeInstance, desc)
                    end)
                end
            end)
        end
        if not lightingConn then
            lightingConn = Lighting.ChildAdded:Connect(function(child)
                if Toggles.Optimizer and Toggles.Optimizer.Value and Toggles.OptDisablePostEffects and Toggles.OptDisablePostEffects.Value then
                    task.defer(function()
                        if child:IsA('PostEffect') or child:IsA('Atmosphere') or child:IsA('BloomEffect') or child:IsA('BlurEffect') or child:IsA('SunRaysEffect') or child:IsA('ColorCorrectionEffect') or child:IsA('DepthOfFieldEffect') then
                            if origPostFXProps[child] == nil then
                                origPostFXProps[child] = child.Enabled
                            end
                            pcall(function() child.Enabled = false end)
                        end
                    end)
                end
            end)
        end
    end

    local function stopListening()
        if descendantConn then
            descendantConn:Disconnect()
            descendantConn = nil
        end
        if lightingConn then
            lightingConn:Disconnect()
            lightingConn = nil
        end
    end

    if Toggles.Optimizer then
        Toggles.Optimizer:OnChanged(function()
            if Toggles.Optimizer.Value then
                startListening()
                task.spawn(optimizeAllAsync)
                pcall(function() Library:Notify('性能优化：已开启', 2) end)
            else
                stopListening()
                restoreAll()
                pcall(function() Library:Notify('性能优化：已关闭（画质已恢复）', 2) end)
            end
        end)
    end

    if Options.OptimizerPreset then
        Options.OptimizerPreset:OnChanged(function()
            local p = Options.OptimizerPreset.Value
            if p == 'Max FPS (Potato)' then
                if Toggles.OptGlobalShadows then Toggles.OptGlobalShadows:SetValue(true) end
                if Toggles.OptSmoothMaterials then Toggles.OptSmoothMaterials:SetValue(true) end
                if Toggles.OptRemoveTextures then Toggles.OptRemoveTextures:SetValue(true) end
                if Toggles.OptDisableParticles then Toggles.OptDisableParticles:SetValue(true) end
                if Toggles.OptDisablePostEffects then Toggles.OptDisablePostEffects:SetValue(true) end
                if Toggles.OptLowTerrain then Toggles.OptLowTerrain:SetValue(true) end
                if Toggles.OptOptimizeNew then Toggles.OptOptimizeNew:SetValue(true) end
            elseif p == 'Balanced Boost' then
                if Toggles.OptGlobalShadows then Toggles.OptGlobalShadows:SetValue(true) end
                if Toggles.OptSmoothMaterials then Toggles.OptSmoothMaterials:SetValue(true) end
                if Toggles.OptRemoveTextures then Toggles.OptRemoveTextures:SetValue(false) end
                if Toggles.OptDisableParticles then Toggles.OptDisableParticles:SetValue(true) end
                if Toggles.OptDisablePostEffects then Toggles.OptDisablePostEffects:SetValue(true) end
                if Toggles.OptLowTerrain then Toggles.OptLowTerrain:SetValue(true) end
                if Toggles.OptOptimizeNew then Toggles.OptOptimizeNew:SetValue(true) end
            end
            if Toggles.Optimizer and Toggles.Optimizer.Value then
                task.spawn(optimizeAllAsync)
            end
        end)
    end

    local function onSubToggleChanged()
        if Toggles.Optimizer and Toggles.Optimizer.Value then
            task.spawn(optimizeAllAsync)
        end
    end

    if Toggles.OptGlobalShadows then Toggles.OptGlobalShadows:OnChanged(onSubToggleChanged) end
    if Toggles.OptSmoothMaterials then Toggles.OptSmoothMaterials:OnChanged(onSubToggleChanged) end
    if Toggles.OptRemoveTextures then Toggles.OptRemoveTextures:OnChanged(onSubToggleChanged) end
    if Toggles.OptDisableParticles then Toggles.OptDisableParticles:OnChanged(onSubToggleChanged) end
    if Toggles.OptDisablePostEffects then Toggles.OptDisablePostEffects:OnChanged(onSubToggleChanged) end
    if Toggles.OptLowTerrain then Toggles.OptLowTerrain:OnChanged(onSubToggleChanged) end

    _G.BoarsForceOptimize = function()
        task.spawn(optimizeAllAsync)
        pcall(function() Library:Notify('场景优化完成', 2) end)
    end

    _G.BoarsRestoreGraphics = function()
        restoreAll()
        if Toggles.Optimizer and Toggles.Optimizer.Value then
            Toggles.Optimizer:SetValue(false)
        end
        pcall(function() Library:Notify('画质已完全恢复', 2) end)
    end

    _G.BoarsCleanupOptimizer = function()
        stopListening()
        restoreAll()
    end
end


-- ====================== 角色 / 武器上色模块 ======================
-- 覆盖范围：身体所有部件 + 配饰 + 手持武器 + BodyColors + 衣物图层 + CharacterMesh
-- 支持：整只角色半透明（含武器），关闭时完整还原
do
	local originals = setmetatable({}, { __mode = 'k' })
	local hiddenDecoration = setmetatable({}, { __mode = 'k' })
	local clothingSaved = setmetatable({}, { __mode = 'k' })
	local bodyColorSaved = setmetatable({}, { __mode = 'k' })
	local meshSaved = setmetatable({}, { __mode = 'k' })
	local running = false

	local BC_FIELDS = {
		'HeadColor3', 'TorsoColor3', 'LeftArmColor3', 'RightArmColor3',
		'LeftLegColor3', 'RightLegColor3',
	}

	local function scaleColor(c, k)
		return Color3.new(math.min(1, c.R * k), math.min(1, c.G * k), math.min(1, c.B * k))
	end

	local function restorePart(part, data)
		pcall(function()
			part.Color = data.Color
			part.Material = data.Material
			part.Reflectance = data.Reflectance
			part.Transparency = data.Tr
			if data.MaterialVariant ~= nil then part.MaterialVariant = data.MaterialVariant end
			if data.TextureID ~= nil and part:IsA('MeshPart') then part.TextureID = data.TextureID end
		end)
	end

	-- 摘掉贴在部件上的贴图 / 表面外观，纯色才能透出来
	local function hideDecoration(part)
		if hiddenDecoration[part] then return end
		local rec = {}
		hiddenDecoration[part] = rec
		for _, d in ipairs(part:GetChildren()) do
			local isDeco = d:IsA('SurfaceAppearance') or d:IsA('Texture')
			if d:IsA('Decal') and d.Name ~= 'Face' then isDeco = true end
			if isDeco then
				rec[#rec + 1] = { obj = d, parent = part }
				pcall(function() d.Parent = nil end)
			elseif d:IsA('SpecialMesh') then
				-- 网格自带的贴图会盖住颜色，只清贴图、保留形状
				local ok, tex = pcall(function() return d.TextureId end)
				if ok and tex ~= '' and tex ~= nil then
					rec[#rec + 1] = { obj = d, prop = 'TextureId', old = tex }
					pcall(function() d.TextureId = '' end)
				end
			end
		end
	end

	local function restoreDecoration(part)
		local rec = hiddenDecoration[part]
		if not rec then return end
		for _, item in ipairs(rec) do
			if item.prop then
				pcall(function() item.obj[item.prop] = item.old end)
			else
				pcall(function() item.obj.Parent = item.parent end)
			end
		end
		hiddenDecoration[part] = nil
	end

	-- 衬衫 / 裤子图层
	local function hideClothing(char)
		for _, d in ipairs(char:GetChildren()) do
			if d:IsA('Clothing') then
				if clothingSaved[d] == nil then clothingSaved[d] = d.Template end
				pcall(function() d.Template = '' end)
			end
		end
	end

	local function restoreClothing()
		for obj, tpl in pairs(clothingSaved) do
			pcall(function() obj.Template = tpl end)
		end
		table.clear(clothingSaved)
	end

	-- R6 的皮肤贴图（CharacterMesh）会盖住颜色，必须摘掉
	local function hideMeshes(char)
		for _, d in ipairs(char:GetChildren()) do
			if d:IsA('CharacterMesh') then
				if meshSaved[d] == nil then meshSaved[d] = char end
				pcall(function() d.Parent = nil end)
			end
		end
	end

	local function restoreMeshes()
		for obj, char in pairs(meshSaved) do
			pcall(function() obj.Parent = char end)
		end
		table.clear(meshSaved)
	end

	-- R6 的颜色由 BodyColors 驱动，不处理会被 Humanoid 每帧刷回去
	local BC_HEIGHT = {
		HeadColor3 = 0.95, TorsoColor3 = 0.6,
		LeftArmColor3 = 0.5, RightArmColor3 = 0.5,
		LeftLegColor3 = 0.1, RightLegColor3 = 0.1,
	}

	local function paintBodyColors(char, opts)
		local bc = char:FindFirstChildOfClass('BodyColors')
		if not bc then return end
		if not bodyColorSaved[bc] then
			local rec = {}
			for _, f in ipairs(BC_FIELDS) do
				pcall(function() rec[f] = bc[f] end)
			end
			bodyColorSaved[bc] = rec
		end

		local base = opts.bodyCol
		for f, k in pairs(BC_HEIGHT) do
			local col = base
			if opts.rainbow then
				col = Color3.fromHSV((os.clock() * 0.18 + k * 0.35) % 1, 0.85, 1)
			elseif opts.gradient then
				col = base:Lerp(scaleColor(base, 0.35), k * 0.85)
			end
			pcall(function() bc[f] = col end)
		end
	end

	local function restoreBodyColors()
		for bc, rec in pairs(bodyColorSaved) do
			for f, v in pairs(rec) do
				pcall(function() bc[f] = v end)
			end
		end
		table.clear(bodyColorSaved)
	end

	local function getTargets()
		local list = {}
		local range = Options.PaintRange and Options.PaintRange.Value or '仅自己'
		local selfChar = LP.Character
		if selfChar then list[#list + 1] = selfChar end
		if range == '仅自己' then return list end

		local cam = workspace.CurrentCamera
		local camPos = cam and cam.CFrame.Position or Vector3.zero
		local maxDist = Options.PaintMaxDist and Options.PaintMaxDist.Value or 200
		local seen = {}

		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LP then
				local c = plr.Character
				if c then
					local root = c:FindFirstChild('HumanoidRootPart')
					if root and (root.Position - camPos).Magnitude <= maxDist then
						seen[c] = true
						list[#list + 1] = c
					end
				end
			end
		end

		if range == '全部角色' then
			local count = 0
			for _, c in ipairs(workspace:GetChildren()) do
				if count >= 10 then break end
				if c:IsA('Model') and not seen[c] and not Players:GetPlayerFromCharacter(c) then
					local hum = c:FindFirstChildOfClass('Humanoid')
					local root = c:FindFirstChild('HumanoidRootPart')
					if hum and root and (root.Position - camPos).Magnitude <= maxDist then
						list[#list + 1] = c
						count = count + 1
					end
				end
			end
		end
		return list
	end

	local function paintChar(char, opts)
		local hum = char:FindFirstChildOfClass('Humanoid')
		if not hum then return end

		local ok, boxCF, boxSize = pcall(function() return char:GetBoundingBox() end)
		local minY, height
		if ok and boxCF then
			minY = boxCF.Position.Y - boxSize.Y * 0.5
			height = math.max(1, boxSize.Y)
		else
			local root = char:FindFirstChild('HumanoidRootPart')
			minY = root and (root.Position.Y - 3) or 0
			height = 6
		end

		local now = os.clock()
		local chamsOn = Toggles.WeaponChams and Toggles.WeaponChams.Value
		local parts = char:GetDescendants()

		for _, d in ipairs(parts) do
			local isWeapon = d:FindFirstAncestorOfClass('Tool') ~= nil
			-- 武器透视材质开启时交给原模块处理，避免两边每帧抢同一批部件
			if d:IsA('BasePart') and d.Name ~= 'WXFX' and not (isWeapon and chamsOn) then
				local tr = d.Transparency

				-- 记录原始状态（只记一次）
				if not originals[d] then
					originals[d] = {
						Color = d.Color,
						Material = d.Material,
						Reflectance = d.Reflectance,
						Tr = tr,
						MaterialVariant = d.MaterialVariant,
						TextureID = d:IsA('MeshPart') and d.TextureID or nil,
					}
				end

				local base = isWeapon and opts.weaponCol or opts.bodyCol
				local t = math.clamp((d.Position.Y - minY) / height, 0, 1)
				local col = base
				if isWeapon then
					col = opts.weaponCol
				elseif opts.rainbow then
					col = Color3.fromHSV((now * 0.18 + t * 0.35) % 1, 0.85, 1)
				elseif opts.gradient then
					col = base:Lerp(scaleColor(base, 0.35), t * 0.85)
				end

				local origTr = originals[d].Tr
				if tr < 1 then
					pcall(function()
						d.Color = col
						d.Material = opts.mat
						d.Reflectance = opts.emissive
						if d:IsA('MeshPart') then
							d.TextureID = ''
							d.MaterialVariant = ''
						end
					end)

					if opts.hideTex then
						hideDecoration(d)
					elseif hiddenDecoration[d] then
						restoreDecoration(d)
					end

					-- 半透明：以最初记录的原值为基准，关闭后能准确还原
					local nt = origTr
					if opts.alphaOn and not (isWeapon and not opts.alphaWeapon) then
						nt = opts.alphaVal
					end
					if math.abs(d.Transparency - nt) > 0.005 then
						d.Transparency = nt
					end
				end
			end
		end

		-- BodyColors 同步，R6 才不会闪回
		paintBodyColors(char, opts)
		if opts.hideCloth then
			hideClothing(char)
		end
		if opts.hideMesh then
			hideMeshes(char)
		end
	end

	local function runOnce()
		local matName = Options.PaintMaterial and Options.PaintMaterial.Value or 'Neon'
		local mat = Enum.Material[matName] or Enum.Material.Neon
		local bodyCol = Options.PaintBodyColor and Options.PaintBodyColor.Value or Color3.fromRGB(0, 220, 255)
		local weaponCol = Options.PaintWeaponColor and Options.PaintWeaponColor.Value or Color3.fromRGB(255, 255, 255)

		local opts = {
			mat = mat,
			emissive = Options.PaintEmissive and Options.PaintEmissive.Value or 0,
			bodyCol = bodyCol,
			weaponCol = weaponCol,
			gradient = Toggles.PaintGradient and Toggles.PaintGradient.Value or false,
			rainbow = Toggles.PaintRainbow and Toggles.PaintRainbow.Value or false,
			hideTex = Toggles.PaintRemoveTextures and Toggles.PaintRemoveTextures.Value or false,
			hideCloth = Toggles.PaintHideClothing and Toggles.PaintHideClothing.Value or false,
			hideMesh = Toggles.PaintRemoveMesh and Toggles.PaintRemoveMesh.Value or false,
			alphaOn = Toggles.PaintTransparent and Toggles.PaintTransparent.Value or false,
			alphaWeapon = Toggles.PaintAlphaWeapon and Toggles.PaintAlphaWeapon.Value or false,
			alphaVal = Options.PaintAlpha and Options.PaintAlpha.Value or 0.5,
		}

		for _, char in ipairs(getTargets()) do
			local ok, err = pcall(paintChar, char, opts)
			if not ok then
				warn('[WX] 上色失败：' .. tostring(err))
			end
		end

		if not opts.hideCloth then restoreClothing() end
		if not opts.hideMesh then restoreMeshes() end
	end

	local function startPaint()
		if running then return end
		running = true
		task.spawn(function()
			while running do
				local ok, err = pcall(runOnce)
				if not ok then
					warn('[WX] 上色循环异常：' .. tostring(err))
					running = false
					break
				end
				task.wait(0.12)
			end
		end)
	end

	local function stopPaint()
		running = false
		task.wait(0.05)
		for part, data in pairs(originals) do
			restorePart(part, data)
		end
		table.clear(originals)
		for part in pairs(hiddenDecoration) do
			restoreDecoration(part)
		end
		restoreClothing()
		restoreMeshes()
		restoreBodyColors()
	end

	if Toggles.Paint then
		Toggles.Paint:OnChanged(function(v)
			if v then
				startPaint()
			else
				task.spawn(stopPaint)
			end
		end)
	end
end

-- ====================== CHINAHAT MODULE ======================
do
    local NUM_SEGMENTS = 24
    local MAX_OTHER_HATS = 10
    local projectedBuffer = table.create(NUM_SEGMENTS)

    local function createHatDrawings(numSegments)
        local tris = table.create(numSegments)
        local lines = table.create(numSegments)
        for i = 1, numSegments do
            local t = Drawing.new('Triangle')
            t.Visible = false
            t.Filled = true
            t.Thickness = 1
            t.ZIndex = 8
            tris[i] = t

            local l = Drawing.new('Line')
            l.Visible = false
            l.Thickness = 1.5
            l.ZIndex = 9
            lines[i] = l
        end
        return { tris = tris, lines = lines, count = numSegments }
    end

    local function destroyHatDrawings(hat)
        if not hat then return end
        for _, t in ipairs(hat.tris) do
            pcall(function() t:Remove() end)
        end
        for _, l in ipairs(hat.lines) do
            pcall(function() l:Remove() end)
        end
        hat.tris = {}
        hat.lines = {}
    end

    local function hideHat(hat)
        if not hat then return end
        for i = 1, hat.count do
            if hat.tris[i].Visible then hat.tris[i].Visible = false end
            if hat.lines[i].Visible then hat.lines[i].Visible = false end
        end
    end

    local function renderHat(hat, head, cfg, spinAngle)
        if not head or not head.Parent then
            hideHat(hat)
            return
        end

        local headPos = head.Position
        local headScreen, headVis = Camera:WorldToViewportPoint(headPos)
        if not headVis or headScreen.Z <= 1 then
            hideHat(hat)
            return
        end

        local radius = cfg.radius or 2.0
        local height = cfg.height or 0.8
        local color = cfg.color or Color3.fromRGB(100, 150, 200)
        local alpha = cfg.alpha or 0.65
        local showOutline = cfg.showOutline ~= false
        local outlineColor = cfg.outlineColor or Color3.fromRGB(255, 255, 255)
        local outlineThick = cfg.outlineThickness or 1.5

        local headSizeY = (head.Size and head.Size.Y) or 2
        local yOffset = (headSizeY * 0.5) + (cfg.yOffset or 0.15)

        local baseCF
        if cfg.followHead then
            baseCF = head.CFrame * CFrame.new(0, yOffset, 0)
        else
            baseCF = CFrame.new(headPos + Vector3.new(0, yOffset, 0))
        end

        if spinAngle and spinAngle ~= 0 then
            baseCF = baseCF * CFrame.Angles(0, spinAngle, 0)
        end

        local apexPos = baseCF:PointToWorldSpace(Vector3.new(0, height, 0))
        local apexScreen, apexVis = Camera:WorldToViewportPoint(apexPos)
        if not apexVis or apexScreen.Z <= 0.5 then
            hideHat(hat)
            return
        end

        local apex2D = Vector2.new(apexScreen.X, apexScreen.Y)
        local numSeg = hat.count

        for i = 1, numSeg do
            local angle = (i - 1) / numSeg * (2 * math.pi)
            local localPt = Vector3.new(radius * math.cos(angle), 0, radius * math.sin(angle))
            local worldPt = baseCF:PointToWorldSpace(localPt)
            local screenPt, vis = Camera:WorldToViewportPoint(worldPt)
            if not vis or screenPt.Z <= 0.5 then
                hideHat(hat)
                return
            end
            projectedBuffer[i] = Vector2.new(screenPt.X, screenPt.Y)
        end

        for i = 1, numSeg do
            local nextI = (i % numSeg) + 1
            local p1 = projectedBuffer[i]
            local p2 = projectedBuffer[nextI]

            local tri = hat.tris[i]
            tri.PointA = apex2D
            tri.PointB = p1
            tri.PointC = p2
            tri.Color = color
            tri.Transparency = alpha
            tri.Visible = true

            local line = hat.lines[i]
            if showOutline then
                line.From = p1
                line.To = p2
                line.Color = outlineColor
                line.Thickness = outlineThick
                line.Transparency = 1
                line.Visible = true
            else
                line.Visible = false
            end
        end
    end

    local selfHat = createHatDrawings(NUM_SEGMENTS)
    local otherHatsPool = table.create(MAX_OTHER_HATS)
    for i = 1, MAX_OTHER_HATS do
        otherHatsPool[i] = createHatDrawings(NUM_SEGMENTS)
    end

    local chinahatConn = nil

    local function onRenderChinahat()
        if not Toggles.ChinaHat or not Toggles.ChinaHat.Value then
            hideHat(selfHat)
            for i = 1, MAX_OTHER_HATS do
                hideHat(otherHatsPool[i])
            end
            return
        end

        local rainbowColor = Color3.fromHSV((tick() * 0.25) % 1, 0.75, 1)
        local spinAngle = 0
        if Toggles.ChinaHatSpin and Toggles.ChinaHatSpin.Value then
            local speed = (Options.ChinaHatSpinSpeed and Options.ChinaHatSpinSpeed.Value) or 2
            spinAngle = (tick() * speed) % (2 * math.pi)
        end

        local followHead = Toggles.ChinaHatFollowHead and Toggles.ChinaHatFollowHead.Value
        local showOutline = Toggles.ChinaHatOutline and Toggles.ChinaHatOutline.Value
        local outlineColor = (Options.ChinaHatOutlineColor and Options.ChinaHatOutlineColor.Value) or Color3.fromRGB(255, 255, 255)
        local outlineThick = (Options.ChinaHatOutlineThick and Options.ChinaHatOutlineThick.Value) or 1.5

        -- Render on Self
        if Toggles.ChinaHatSelf and Toggles.ChinaHatSelf.Value then
            local char = LP.Character
            local head = char and char:FindFirstChild('Head')
            local hum = char and char:FindFirstChildOfClass('Humanoid')

            local isFirstPerson = false
            if head then
                local camPos = Camera.CFrame.Position
                if (camPos - head.Position).Magnitude < 1.5 then
                    isFirstPerson = true
                elseif (Camera.Focus.Position - camPos).Magnitude < 0.6 then
                    isFirstPerson = true
                elseif LP.CameraMode == Enum.CameraMode.LockFirstPerson then
                    isFirstPerson = true
                end
            end

            if head and hum and hum.Health > 0 and not isFirstPerson then
                local selfColor = (Toggles.ChinaHatRainbowSelf and Toggles.ChinaHatRainbowSelf.Value) and rainbowColor or ((Options.ChinaHatColorSelf and Options.ChinaHatColorSelf.Value) or Color3.fromRGB(100, 150, 200))
                local selfCfg = {
                    radius = (Options.ChinaHatRadiusSelf and Options.ChinaHatRadiusSelf.Value) or 2.0,
                    height = (Options.ChinaHatHeightSelf and Options.ChinaHatHeightSelf.Value) or 0.8,
                    yOffset = (Options.ChinaHatOffsetSelf and Options.ChinaHatOffsetSelf.Value) or 0.15,
                    color = selfColor,
                    alpha = (Options.ChinaHatAlphaSelf and Options.ChinaHatAlphaSelf.Value) or 0.65,
                    followHead = followHead,
                    showOutline = showOutline,
                    outlineColor = outlineColor,
                    outlineThickness = outlineThick
                }
                renderHat(selfHat, head, selfCfg, spinAngle)
            else
                hideHat(selfHat)
            end
        else
            hideHat(selfHat)
        end

        -- Render on Others
        if Toggles.ChinaHatOthers and Toggles.ChinaHatOthers.Value then
            local maxDist = (Options.ChinaHatMaxDist and Options.ChinaHatMaxDist.Value) or 250
            local camPos = Camera.CFrame.Position
            local nearby = {}

            for _, player in ipairs(Players:GetPlayers()) do
                if player == LP then continue end
                local char = player.Character
                local head = char and char:FindFirstChild('Head')
                local hum = char and char:FindFirstChildOfClass('Humanoid')
                if head and hum and hum.Health > 0 then
                    local dist = (camPos - head.Position).Magnitude
                    if dist <= maxDist then
                        local _, vis = Camera:WorldToViewportPoint(head.Position)
                        if vis then
                            table.insert(nearby, { player = player, head = head, dist = dist })
                        end
                    end
                end
            end

            table.sort(nearby, function(a, b) return a.dist < b.dist end)

            local othersRadius = (Options.ChinaHatRadiusOthers and Options.ChinaHatRadiusOthers.Value) or 2.0
            local othersHeight = (Options.ChinaHatHeightOthers and Options.ChinaHatHeightOthers.Value) or 0.8
            local othersAlpha = (Options.ChinaHatAlphaOthers and Options.ChinaHatAlphaOthers.Value) or 0.65
            local useTeam = Toggles.ChinaHatTeamColor and Toggles.ChinaHatTeamColor.Value
            local useRainbow = Toggles.ChinaHatRainbowOthers and Toggles.ChinaHatRainbowOthers.Value
            local fallbackColor = (Options.ChinaHatColorOthers and Options.ChinaHatColorOthers.Value) or Color3.fromRGB(200, 100, 150)

            for slot = 1, MAX_OTHER_HATS do
                local entry = nearby[slot]
                if entry then
                    local pColor = fallbackColor
                    if useRainbow then
                        pColor = rainbowColor
                    elseif useTeam and entry.player.TeamColor then
                        pColor = entry.player.TeamColor.Color
                    end

                    local oCfg = {
                        radius = othersRadius,
                        height = othersHeight,
                        yOffset = 0.15,
                        color = pColor,
                        alpha = othersAlpha,
                        followHead = followHead,
                        showOutline = showOutline,
                        outlineColor = outlineColor,
                        outlineThickness = outlineThick
                    }
                    renderHat(otherHatsPool[slot], entry.head, oCfg, spinAngle)
                else
                    hideHat(otherHatsPool[slot])
                end
            end
        else
            for i = 1, MAX_OTHER_HATS do
                hideHat(otherHatsPool[i])
            end
        end
    end

    chinahatConn = RunService.RenderStepped:Connect(onRenderChinahat)

    _G.BoarsCleanupChinahat = function()
        if chinahatConn then
            chinahatConn:Disconnect()
            chinahatConn = nil
        end
        destroyHatDrawings(selfHat)
        for i = 1, MAX_OTHER_HATS do
            destroyHatDrawings(otherHatsPool[i])
        end
    end
end


Library:OnUnload(function()
    Library.Unloaded = true
    if _G.BoarsCleanupChinahat then pcall(_G.BoarsCleanupChinahat) end
    if _G.BoarsCleanupOptimizer then pcall(_G.BoarsCleanupOptimizer) end
    if _G.BoarsCleanupTargetHUD then pcall(_G.BoarsCleanupTargetHUD) end
    if _G.BoarsCleanupKillfeed then pcall(_G.BoarsCleanupKillfeed) end
    if _G.BoarsCleanupViewmodel then pcall(_G.BoarsCleanupViewmodel) end
    if _G.BoarsCleanupFly then pcall(_G.BoarsCleanupFly) end
    for i = 1, FOV_SEG do
        fovLines[i]:Remove()
        fovTris[i]:Remove()
    end
    for i = 1, 4 do
        crosshairLines[i]:Remove()
    end
    for i = 1, AR_SEG do
        arLines[i]:Remove()
        arTris[i]:Remove()
    end
    for _, obj in pairs(espObjects) do
        if obj.cleanup then pcall(obj.cleanup) end
    end
    for k in pairs(espObjects) do espObjects[k] = nil end
    if ESPFolder then for _, child in ESPFolder:GetChildren() do child:Destroy() end end
    crosshairDot:Remove()
    crosshairRing:Remove()
    if rageIndicatorText then rageIndicatorText:Remove() end
    if cleanupParticles then pcall(cleanupParticles) end
    if cleanupHitmarkers then pcall(cleanupHitmarkers) end
    if targetEspGui then pcall(function() targetEspGui:Destroy() end) end
    if activeHitNumbers then
        for _, hn in ipairs(activeHitNumbers) do
            pcall(function() hn.drawing:Remove() end)
        end
        activeHitNumbers = {}
    end
    UserInputService.MouseIconEnabled = true
end)

-- 把窗口对象也挂到调试句柄
pcall(function()
	local g = getgenv and getgenv() or _G
	if g.WX then g.WX.Window = Window end
end)

--==================== 手机端快捷按钮（Rage / 飞行 / 移速） ====================
do
	-- 覆盖 Toggle.Changed（库只支持单回调），保留原有回调后再接我们的同步逻辑
	local function HookChanged(Toggle, Func)
		if not Toggle then return end

		local Prev = Toggle.Changed

		Toggle.Changed = function(Value)
			if Prev then pcall(Prev, Value) end
			pcall(Func, Value)
		end
	end

	local function CreateShortcut(Config)
		local Show = Config.Show
		local Lock = Config.Lock
		local Target = Config.Toggle

		if not Target or not Show then return end

		local Button

		local function State()
			return Target.Value and '开' or '关'
		end

		local function Sync()
			if not Button then return end

			Button:SetState(State())
			Button:SetActive(Target.Value and true or false)
			Button:SetLocked(Lock and Lock.Value or false)
		end

		local function Ensure()
			if not Button then
				if not Show.Value then return end

				Button = Library:AddMobileShortcut({
					Text = Config.Label,
					State = State(),
					Index = Config.Index,
					Locked = Lock and Lock.Value or false,
					Callback = function()
						Target:SetValue(not Target.Value)
					end,
				})
			end

			Button:SetVisible(Show.Value and true or false)
			Sync()
		end

		HookChanged(Target, Sync)
		HookChanged(Show, Ensure)
		HookChanged(Lock, Sync)

		Ensure()
	end

	CreateShortcut({
		Label = 'Rage',
		Index = 1,
		Toggle = Toggles.RageBot,
		Show = Toggles.RageBotMobile,
		Lock = Toggles.RageBotMobileLock,
	})

	CreateShortcut({
		Label = 'Fly',
		Index = 2,
		Toggle = Toggles.PlayerFly,
		Show = Toggles.PlayerFlyMobile,
		Lock = Toggles.PlayerFlyMobileLock,
	})

	CreateShortcut({
		Label = '移速',
		Index = 3,
		Toggle = Toggles.SpeedRegions,
		Show = Toggles.SpeedRegionsMobile,
		Lock = Toggles.SpeedRegionsMobileLock,
	})

	CreateShortcut({
		Label = '穿墙',
		Index = 4,
		Toggle = Toggles.Noclip,
		Show = Toggles.NoclipMobile,
		Lock = Toggles.NoclipMobileLock,
	})

	CreateShortcut({
		Label = '隐身',
		Index = 5,
		Toggle = Toggles.Invisible,
		Show = Toggles.InvisibleMobile,
		Lock = Toggles.InvisibleMobileLock,
	})
end

--==================== 显示层汉化：下拉选项等 ====================
do
	local CN = {
		['---'] = '未选择',
		['3D Cyclone Orbit (HvH)'] = '3D 旋风环绕（HvH）',
		['3D Helix / Corkscrew (HvH)'] = '3D 螺旋 / 麻花（HvH）',
		['3D Hit Position'] = '3D 命中位置',
		['Above Target (Sky Stomp)'] = '目标上方（天降打击）',
		['Accent color'] = '强调色',
		['Adaptive Auto'] = '自适应自动',
		['All Available'] = '全部可用武器',
		['All Axes'] = '全部轴',
		['All Car Parts'] = '全部车辆部件',
		['All Enemies (Carnage Cycle)'] = '全部敌人（屠杀循环）',
		['All Guns'] = '全部枪械',
		['Always'] = '常开',
		['Attack'] = '攻击',
		['Attack Action'] = '攻击动作',
		['Axis Pivot (Anti-Spin)'] = '轴心旋转（反自旋）',
		['BBot'] = 'BBot 主题',
		['Background Image'] = '背景图片',
		['Background color'] = '背景色',
		['Backspace'] = '退格',
		['Balanced Boost'] = '均衡加速',
		['Behind Target (Backstab Flank)'] = '目标身后（背刺包抄）',
		['Behind Target (Backstab)'] = '目标身后（背刺）',
		['Bell'] = '铃铛',
		['Blink Flank (In & Out)'] = '闪现包抄（进出自如）',
		['Bloom'] = '泛光',
		['Bounce'] = '弹跳',
		['Brick'] = '砖块',
		['Bruteforce'] = '暴力破解',
		['Burst'] = '迸发',
		['COD'] = '使命召唤',
		['Camera Facing Beam'] = '朝向镜头光束',
		['Camera Relative'] = '相对镜头',
		['CapsLock'] = '大写锁定',
		['Circle'] = '圆环',
		['Client'] = '本地',
		['Cobblestone'] = '鹅卵石',
		['Copy Hex'] = '复制色值',
		['Copy RGB'] = '复制 RGB',
		['Copy color'] = '复制颜色',
		['Create theme'] = '新建主题',
		['Crude Knife'] = '粗糙短刀',
		['Current default theme: none'] = '当前默认主题：无',
		['Custom'] = '自定义',
		['Custom Delay'] = '自定义延迟',
		['Custom theme name'] = '自定义主题名',
		['Custom themes'] = '自定义主题',
		['Default'] = '默认',
		['Delete'] = 'Delete',
		['Delete theme'] = '删除主题',
		['DiamondPlate'] = '花纹钢板',
		['Dollar'] = '金钱',
		['Dracula'] = '德古拉',
		['End'] = 'End',
		['Escape'] = 'Esc',
		['Expand & Fade'] = '扩散淡出',
		['Export current theme'] = '导出当前主题',
		['Fantasy'] = '幻梦',
		['Fatality'] = '致命一击',
		['Fire'] = '火焰',
		['Fists'] = '拳头',
		['Flare'] = '耀斑',
		['Flat / Level'] = '水平 / 平面',
		['Float Up'] = '上浮',
		['Flying Bullet'] = '飞行子弹',
		['Flying Projectile'] = '飞行弹丸',
		['Flying Tracer'] = '飞行曳光',
		['Font Face'] = '字体',
		['Font color'] = '文字颜色',
		['ForceField'] = '力场',
		['Fountain'] = '喷泉',
		['Glass'] = '玻璃',
		['Gradient (Muzzle -> Hit)'] = '渐变（枪口 → 命中点）',
		['Gun & Melee'] = '枪械与近战',
		['Gun Only'] = '仅枪械',
		['Handcuffs'] = '手铐',
		['Head'] = '头部',
		['Headshot'] = '爆头',
		['Heart'] = '心脏',
		['Hold'] = '长按',
		['Home'] = 'Home',
		['HumanoidRootPart'] = '躯干中心',
		['Ice'] = '冰',
		['Idle'] = '待机',
		['Idle Action'] = '待机动作',
		['Import theme'] = '导入主题',
		['Insert'] = 'Insert',
		['Instant (0s)'] = '瞬发（0 秒）',
		['Instant Teleport (0ms HvH Snap)'] = '瞬间传送（0ms HvH 吸附）',
		['Jester'] = '小丑',
		['Jitter'] = '抖动',
		['Jitter Random Flank'] = '抖动随机包抄',
		['Keybinds'] = '按键列表',
		['Killer'] = '击杀者',
		['Kronex'] = '克洛尼克斯',
		['Laser Cylinder'] = '激光柱',
		['Left Arm'] = '左臂',
		['LeftAlt'] = '左 Alt',
		['LeftControl'] = '左 Ctrl',
		['LeftShift'] = '左 Shift',
		['Line'] = '线条',
		['Linoria Accent'] = 'Linoria 强调色',
		['Linoria Modern'] = 'Linoria 现代',
		['Load theme'] = '加载主题',
		['LowerTorso'] = '下半身',
		['Lowest HP (Executer)'] = '血量最低（处决者）',
		['Main color'] = '主色',
		['Max FPS (Potato)'] = '极限帧率（土豆模式）',
		['Melee'] = '近战',
		['Melee Only (Punch)'] = '仅近战（拳击）',
		['Metal'] = '金属',
		['Mint'] = '薄荷',
		['Monospace'] = '等宽字体',
		['Move'] = '移动',
		['Move Action'] = '移动动作',
		['Multiplier'] = '倍率',
		['Nearest Enemy'] = '最近敌人',
		['Neverlose'] = '永不失败',
		['NL'] = NL,
		['Neon'] = '霓虹',
		['None'] = '无',
		['Nord'] = '北境',
		['Normal'] = '正常',
		['Orbit / Cyclone (HvH)'] = '环绕 / 旋风（HvH）',
		['Outline color'] = '描边色',
		['Overwrite theme'] = '覆盖主题',
		['PageDown'] = 'PageDown',
		['PageUp'] = 'PageUp',
		['Paste color'] = '粘贴颜色',
		['Plex'] = 'Plex 字体',
		['Pop & Bounce'] = '弹出弹跳',
		['Pulse Fade'] = '脉冲淡出',
		['Quartz'] = '石英',
		['RageBot / Current'] = '狂暴 / 当前目标',
		['Random'] = '随机',
		['Refresh list'] = '刷新列表',
		['Remington 870 Only'] = '仅雷明顿 870',
		['Remove'] = '移除',
		['Reset default'] = '重置默认',
		['Revolver'] = '左轮手枪',
		['Right Arm'] = '右臂',
		['RightAlt'] = '右 Alt',
		['RightControl'] = '右 Ctrl',
		['RightShift'] = '右 Shift',
		['Riot Shield'] = '防暴盾',
		['Rise & Fade'] = '上升淡出',
		['Rust'] = '锈蚀',
		['Scatter (3D)'] = '散开（3D）',
		['Screen Center'] = '屏幕中心',
		['Selected Player'] = '指定玩家',
		['Set as default'] = '设为默认',
		['Shotgun'] = '霰弹枪',
		['Skeet'] = '飞碟',
		['Smoke'] = '烟雾',
		['Smooth Ultra-Glide'] = '平滑滑行',
		['SmoothPlastic'] = '光滑塑料',
		['Snack'] = '零食',
		['Sniper'] = '狙击枪',
		['Snow'] = '雪',
		['Solid Beam'] = '实心光束',
		['Solid Color'] = '纯色',
		['Space'] = '空格',
		['Sparkles'] = '闪光',
		['Spherical Chaos / Evasive'] = '球形混乱 / 闪避',
		['Spin'] = '自旋',
		['Standard'] = '标准',
		['Star'] = '星形',
		['Star 2'] = '星形 2',
		['Static Fade'] = '静态淡出',
		['Stay At Enable Position'] = '停留在开启位置',
		['System'] = '系统',
		['TF2'] = '军团要塞 2',
		['TF2 Critical'] = 'TF2 暴击',
		['Tab'] = 'Tab',
		['Taser'] = '电击枪',
		['Teleport & Return'] = '传送后返回',
		['Theme JSON'] = '主题 JSON',
		['Theme list'] = '主题列表',
		['Themes'] = '主题',
		['Throw'] = '投掷',
		['Throw Action'] = '投掷动作',
		['Toggle'] = '切换',
		['Tokyo Night'] = '东京之夜',
		['Totem'] = '图腾',
		['Totem Action'] = '图腾动作',
		['Triangle'] = '三角',
		['UI'] = '界面',
		['UI Settings'] = '界面设置',
		['Underground (Void Floor)'] = '地下（虚空地面）',
		['Unknown'] = '未知',
		['UpperTorso'] = '上半身',
		['Velocity Prediction'] = '速度预测',
		['Victim'] = '受害者',
		['Visible Keybinds'] = '显示按键列表',
		['Vortex'] = '漩涡',
		['Weapon Crosshair'] = '武器准星',
		['Wexside'] = '幽灵（Wexside）',
		['Windows & Non-Solid'] = '车窗与非实体',
		['X (Pitch)'] = 'X（俯仰）',
		['Y (Yaw)'] = 'Y（偏航）',
		['Z (Roll)'] = 'Z（翻滚）',
		['Призраки'] = '幽灵',
	}

	-- 下拉显示超 25 字符会被库截断成 “前 22 字...”，这里补一份截断索引
	do
		local add = {}
		for k, v in pairs(CN) do
			if #k > 25 then
				add[k:sub(1, 22) .. '...'] = v
			end
		end
		for k, v in pairs(add) do CN[k] = v end
	end

	local function localize(text)
		if type(text) ~= 'string' or text == '' then return text end
		local hit = CN[text]
		if hit then return hit end
		local out = text
		out = out:gsub('%[None%]', '[无]')
		out = out:gsub('%(%s*Toggle%s*%)', '(切换)')
		out = out:gsub('%(%s*Hold%s*%)', '(长按)')
		out = out:gsub('%(%s*Always%s*%)', '(常开)')
		out = out:gsub('^Contrast check: good', '对比度检查：良好')
		out = out:gsub('^Contrast check: bad', '对比度检查：偏低')
		if out ~= text then return out end
		if text:find(', ', 1, true) then
			local parts = {}
			for seg in string.gmatch(text .. ', ', '([^,]+), ?') do
				local s = seg:match('^%s*(.-)%s*$')
				if s and s ~= '' then
					parts[#parts + 1] = CN[s] or s
				end
			end
			if #parts > 0 then
				local joined = table.concat(parts, ', ')
				if joined ~= text then return joined end
			end
		end
		return text
	end

	local function hook(obj)
		if not (obj:IsA('TextLabel') or obj:IsA('TextButton') or obj:IsA('TextBox')) then return end
		local now = localize(obj.Text)
		if now ~= obj.Text then obj.Text = now end
		obj:GetPropertyChangedSignal('Text'):Connect(function()
			local t = localize(obj.Text)
			if t ~= obj.Text then obj.Text = t end
		end)
		if obj:IsA('TextBox') then
			local ph = localize(obj.PlaceholderText)
			if ph ~= obj.PlaceholderText then obj.PlaceholderText = ph end
			obj:GetPropertyChangedSignal('PlaceholderText'):Connect(function()
				local t = localize(obj.PlaceholderText)
				if t ~= obj.PlaceholderText then obj.PlaceholderText = t end
			end)
		end
	end

	local gui = Library.ScreenGui
	if gui then
		for _, d in ipairs(gui:GetDescendants()) do
			pcall(hook, d)
		end
		gui.DescendantAdded:Connect(function(d)
			task.defer(function() pcall(hook, d) end)
		end)
	end
end

end)

if not WX_OK then
	print('[WX] 加载出错：' .. tostring(WX_ERR))
	pcall(function()
		local lp = game:GetService('Players').LocalPlayer
		local host = (lp and lp:FindFirstChild('PlayerGui')) or game:GetService('CoreGui')
		local gui = Instance.new('ScreenGui')
		gui.Name = 'WXHUB_Error'
		gui.ResetOnSpawn = false
		gui.DisplayOrder = 100000
		local box = Instance.new('TextLabel')
		box.Size = UDim2.new(0, 580, 0, 120)
		box.Position = UDim2.new(0.5, -290, 0, 110)
		box.BackgroundColor3 = Color3.fromRGB(28, 18, 22)
		box.BorderSizePixel = 0
		box.TextColor3 = Color3.fromRGB(255, 120, 120)
		box.Font = Enum.Font.Code
		box.TextSize = 12
		box.TextWrapped = true
		box.Text = 'YZ监狱人生 加载出错（请把这段发给作者）:\n' .. tostring(WX_ERR)
		box.Parent = gui
		gui.Parent = host
	end)
end


-- ============================================================
-- 把登记到的功能渲染进 NL UI
-- ============================================================
--!nolint
--[[
    YZ HUB 功能 → NL UI 渲染器
    ------------------------------------------------------------------
    读取 Obsidian 兼容层登记下来的结构（WX_UI.tabs），
    把每个 Tab 变成一个 NL UI 页面（带滚动），每个 Groupbox 变成一张卡片，
    控件变成对应行：
        toggle  -> 开关
        slider  -> 滑块
        dropdown-> 下拉（多选自动识别）
        color   -> 颜色行
        button  -> 按钮
        label   -> 说明行
    回调直接写回登记时的元素，功能逻辑与 YZ HUB 原版一致。
]]
local WX_UI = _G.WX_UI
if not WX_UI then
    warn("[NLUI] 没有找到 WX_UI，YZ 功能未加载")
    return
end

local PAGE_X = 175
local PAGE_W = 548
local ROW_H = 37
local CARD_GAP = 16
local TOP = 18

local function asOptionList(values)
    local list = {}
    if type(values) ~= "table" then return list end
    for _, v in ipairs(values) do list[#list + 1] = tostring(v) end
    if #list > 0 then return list end
    local keys = {}
    for k in pairs(values) do keys[#keys + 1] = k end
    table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
    for _, k in ipairs(keys) do list[#list + 1] = tostring(values[k]) end
    return list
end

local function formatValue(el, v)
    local dec = el.Rounding and el.Rounding < 1 and 1 or 0
    return string.format("%." .. dec .. "f", v)
end

-- 把一个登记控件翻译成 buildCard 的一行
local function rowFor(el)
    if el.Type == "toggle" then
        return {
            label = el.Text,
            kind = "toggle",
            on = el.Value and true or false,
            cb = function(v) el:SetValue(v) end,
        }
    elseif el.Type == "slider" then
        local min = el.Min or 0
        local max = el.Max or 100
        if max <= min then max = min + 1 end
        local step = el.Rounding or 1
        local amount = math.clamp(((el.Value or min) - min) / (max - min), 0, 1)
        return {
            label = el.Text,
            kind = "slider",
            amount = amount,
            value = formatValue(el, el.Value or min),
            num = {
                min = min, max = max,
                value = el.Value or min,
                step = step,
                decimals = step < 1 and 1 or 0,
                suffix = "",
            },
            cb = function(rel)
                local v = min + math.clamp(rel, 0, 1) * (max - min)
                if step > 0 then v = math.floor(v / step + 0.5) * step end
                el:SetValue(v)
            end,
        }
    elseif el.Type == "dropdown" then
        local options = asOptionList(el.Values)
        if #options == 0 then
            return { label = el.Text, kind = "disabled" }
        end
        if el.Multi then
            local mask = 0
            local current = el.Value
            for i, opt in ipairs(options) do
                local picked = false
                if type(current) == "table" then
                    for _, v in pairs(current) do
                        if tostring(v) == opt then picked = true break end
                    end
                end
                if picked then mask = mask + 2 ^ (i - 1) end
            end
            return {
                label = el.Text,
                kind = "multi",
                value = "",
                options = options,
                mask = mask,
                cb = function(newMask)
                    local picked = {}
                    for i, opt in ipairs(options) do
                        if bit32.band(newMask, bit32.lshift(1, i - 1)) ~= 0 then
                            picked[#picked + 1] = opt
                        end
                    end
                    el:SetValue(picked)
                end,
            }
        end
        local index = 1
        for i, opt in ipairs(options) do
            if tostring(el.Value) == opt then index = i break end
        end
        return {
            label = el.Text,
            kind = "select",
            value = options[index],
            options = options,
            cb = function(i)
                local opt = options[i]
                if opt == nil then return end
                -- 值表是字符串映射时还原原始值
                local raw = opt
                if type(el.Values) == "table" then
                    for _, v in pairs(el.Values) do
                        if tostring(v) == opt then raw = v break end
                    end
                end
                el:SetValue(raw)
            end,
        }
    elseif el.Type == "colorpicker" then
        return {
            label = el.Text,
            kind = "color",
            color = el.Value or Color3.fromRGB(255, 255, 255),
            on = true,
            cb = function() end,
            colorCallback = function(c) el:SetValue(c) end,
        }
    elseif el.Type == "button" then
        return {
            label = el.Text,
            kind = "button",
            value = "",
            cb = function()
                if el.Callback then pcall(el.Callback, el) end
                return "OK"
            end,
        }
    elseif el.Type == "keypicker" then
        return {
            label = el.Text,
            kind = "button",
            value = tostring(el.Value or "-"),
            cb = function()
                return tostring(el.Value or "-")
            end,
        }
    elseif el.Type == "label" then
        return { label = tostring(el.Text or ""), kind = "disabled" }
    end
    return nil
end

local function buildYzPage(tab, index)
    local key = "yz" .. index
    local page = buildPage(key, function(p)
        local scroll = Instance.new("ScrollingFrame")
        scroll.Name = "YZScroll"
        scroll.Size = UDim2.fromOffset(748, 576)
        scroll.Position = UDim2.fromOffset(0, 0)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 3
        scroll.ScrollBarImageColor3 = Color3.fromRGB(96, 102, 118)
        scroll.ScrollBarImageTransparency = 0.35
        scroll.ScrollingDirection = Enum.ScrollingDirection.Y
        scroll.CanvasSize = UDim2.fromOffset(0, 0)
        scroll.ClipsDescendants = true
        scroll.ZIndex = 2
        scroll.Parent = p

        local y = TOP
        local cards = 0
        for _, group in ipairs(tab.groups) do
            local rows = {}
            for _, el in ipairs(group.controls) do
                local row = rowFor(el)
                if row then rows[#rows + 1] = row end
            end
            if #rows > 0 then
                local height = #rows * ROW_H + 4
                buildCard(scroll, {
                    x = PAGE_X,
                    y = y,
                    w = PAGE_W,
                    h = height,
                    title = group.Name,
                    silent = true,
                    rows = rows,
                }, nil)
                y = y + height + CARD_GAP
                cards = cards + 1
            end
        end
        if cards == 0 then
            label(scroll, PAGE_X, TOP, PAGE_W, 24, "（此页暂无控件）", 13,
                Color3.fromRGB(150, 155, 168))
        end
        scroll.CanvasSize = UDim2.fromOffset(0, y + 24)
    end)
    return page, key
end

local yzBase = 356
local yzStep = 28
local created = {}
local shown = 0
for i, tab in ipairs(WX_UI.tabs) do
    -- 跳过没有任何控件的 Tab（如纯信息页），避免占侧边栏位置
    local controlCount = 0
    for _, group in ipairs(tab.groups) do
        controlCount = controlCount + #group.controls
    end
    if controlCount > 0 then
        shown = shown + 1
        local page, key = buildYzPage(tab, i)
        local nav = makeNav(key, "layers", tab.Name, yzBase + (shown - 1) * yzStep, 0)
        nav.onClick = function() showPage(key) end
        created[#created + 1] = key
    end
end

-- 给新页面补上下方向键翻页顺序与语言表
if type(navOrder) == "table" then
    for _, key in ipairs(created) do
        local item = navItems[key]
        if item and not table.find(navOrder, item) then
            table.insert(navOrder, item)
        end
    end
end

print(string.format("[NLUI] YZ HUB 已接入：%d 个页面 / %d 个 Tab", #created, #WX_UI.tabs))

return gui