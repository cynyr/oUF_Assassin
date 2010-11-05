--[[

 This Addon will provide a display for units HP%, shows mut icon for >35%
 and BS icon for below.
 Movement is provided by oUF_MovableFrames.

 TODO Remove dep on oUF.
--]]

local minalpha = 0
local maxalpha = 1
local height = 40
local width = height
local font = "Fonts\\FRIZQT__.TTF"

local backdrop_bs = {
	--bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
    bgFile = [=[Interface\Icons\Ability_BackStab]=],
	insets = {top = -1, bottom = -1, left = -1, right = -1}
}

local backdrop_mut = {
    bgFile = [=[Interface\Icons\Ability_Rogue_ShadowStrikes]=],
	insets = {top = -1, bottom = -1, left = -1, right = -1}
}

local function postUpdateHealth(health, unit, min, max)
    --test unit helath and change the background.
    local hpp = UnitHealth(unit)/UnitHealthMax(unit)
    local pframe = health:GetParent()
    if (hpp <= .35) then
        pframe:SetBackdrop(backdrop_bs)
    else
        pframe:SetBackdrop(backdrop_mut)
    end
end

local function nameChange(self, event, unit)
    reaction = UnitReaction(unit, "player");
    if (reaction <= 4 and not UnitIsDead(unit) and InCombatLockdown()) then
        self:Show()
    else
        self:Hide()
    end
    postUpdateHealth(self.Health, unit, 0, 0)
end

local function style(self, unit, isSingle)
    --The forth arg controls Alpha, thats handy to know.
    self:SetBackdropColor(0, 0, 0, 0)
    self:SetBackdrop(backdrop_mut)
    self:SetAttribute('initial-height', height)
    self:SetAttribute('initial-width', width)
    self:Show()

    local Health = CreateFrame("StatusBar",nil,self)
    --makes the bar invisable, but yet allows me to hook 
    Health:SetStatusBarColor(0,0,0,0)
    Health:SetHeight(0)
    Health.frequentUpdates = true
    self.Health = Health
    local HealthBackground = Health:CreateTexture(nil, "BORDER")
    --make the background match self
	HealthBackground:SetAllPoints(self)
	HealthBackground:SetTexture(0, 0, 0, 0)
	Health.bg = HealthBackground
    Health.PostUpdate = postUpdateHealth

    if(isSingle) then
        self:SetSize(width, height)
    end
    self:RegisterEvent('UNIT_NAME_UPDATE', nameChange)
    table.insert(self.__elements,nameChange)
end

local UnitSpecific = {
    player = function(self, ...)
        style(self, ...)
    end,
    target = function(self, ...)
        style(self, ...)
    end,
}

oUF:RegisterStyle('oUF_Assassin', style)
oUF:SetActiveStyle('oUF_Assassin')
oUF:Spawn('target', "oUF_Assassin"):SetPoint('CENTER', UIParent, 0,0)
