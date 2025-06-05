local _, MilaUI = ...
local lerp = MilaUI.lerp
local CLASS_ICONS = MilaUI.CLASS_ICONS
local windowsList = {}
local hasBeenLoaded = false
local moveDistance, heroFrameX, heroFrameY, heroFrameLeft, heroFrameTop, heroFrameNormalScale, heroFrameEffectiveScale = 0, 0, 0, 0, 0, 1, 0
local animations = MilaUI.animations

local function AddToAnimation(name, from, to, start, duration, method, easeing, onCompleteCallback, doCompleteOnOverider)
    local newAnimation = true
    if animations[name] then
        newAnimation = (animations[name].start + animations[name].duration) > GetTime()
    end
    if not doCompleteOnOverider then
        newAnimation = true
    end

    if not newAnimation then
        animations[name].duration = duration
        animations[name].to = to
        animations[name].progress = 0
        animations[name].method = method
        animations[name].completed = false
        animations[name].easeing = easeing
        animations[name].onCompleteCallback = onCompleteCallback
    else
        animations[name] = {}
        animations[name].start = start
        animations[name].duration = duration
        animations[name].from = from
        animations[name].to = to
        animations[name].progress = 0
        animations[name].method = method
        animations[name].completed = false
        animations[name].easeing = easeing
        animations[name].onCompleteCallback = onCompleteCallback
    end
end
MilaUI.AddToAnimation = AddToAnimation

local function TriggerButtonHoverAnimation(self, hover, to, duration)
    local name = self.animationName or (self.GetName and self:GetName()) or tostring(self)
    hover:SetAlpha(1)
    duration = duration or min(1, self:GetWidth() * 0.002)
    AddToAnimation(
        name,
        self.animationValue or 0,
        (to or 1),
        GetTime(),
        duration,
        function(p)
            local w = self:GetWidth()
            local lerp = GW.lerp(0, w + (w * 0.5), p)
            local lerp2 = min(1, max(0.4, GW.lerp(0.4, 1, p)))
            local stripAmount = 1 - max(0, (lerp / w) - 1)
            if self.limitHoverStripAmount then
                stripAmount = max(self.limitHoverStripAmount, stripAmount)
            end

            hover:SetPoint("RIGHT", self, "LEFT", min(w, lerp) , 0)
            hover:SetVertexColor(hover.r or 1, hover.g or 1, hover.b or 1, lerp2)
            hover:SetTexCoord(0, stripAmount, 0, 1)
        end
    )
end
MilaUI.TriggerButtonHoverAnimation = TriggerButtonHoverAnimation

local function SetClassIcon(self, class)
    if class == nil then
        class = 0
    end
    local tex = CLASS_ICONS[class]

    self:SetTexCoord(tex.l, tex.r, tex.t, tex.b)
end
MilaUI.SetClassIcon = SetClassIcon

function GwStandardButton_OnEnter(self)
    if not self.hover or (self.IsEnabled and not self:IsEnabled()) then
        return
    end
    self.animationValue = self.hover.skipHover and 1 or 0

    TriggerButtonHoverAnimation(self, self.hover)
end

function GwStandardButton_OnLeave(self)
    if not self.hover or (self.IsEnabled and not self:IsEnabled()) then
        return
    end
    if self.hover.skipHover then return end
    self.hover:SetAlpha(1)
    self.animationValue = 1

    TriggerButtonHoverAnimation(self, self.hover, 0, 0.1)
end