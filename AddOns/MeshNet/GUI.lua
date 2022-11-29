BINDING_HEADER_MESHNETBAR = 'Mesh Net'
BINDING_HEADER_CONNECTING_TWO_POLYGONS = 'Connecting two polygons'
BINDING_HEADER_CONNECTING_TWO_POLYGONS_WITH_POINT_SPECIFICATION = 'Connecting two polygons with point specification'
BINDING_HEADER_REMOVE_OFF_MESH_CONNECTION = 'Remove off-mesh connection'
BINDING_NAME_MESHNETBARBUTTON1 = 'Toggle mesh net'
BINDING_NAME_MESHNETBARBUTTON2 = 'Set first polygon'
BINDING_NAME_MESHNETBARBUTTON3 = 'Set second polygon'
BINDING_NAME_MESHNETBARBUTTON4 = 'Connect bidirectionally'
BINDING_NAME_MESHNETBARBUTTON5 = 'Connect first polygon with second polygon one way'
BINDING_NAME_MESHNETBARBUTTON6 = 'Set first point'
BINDING_NAME_MESHNETBARBUTTON7 = 'Set second point'
BINDING_NAME_MESHNETBARBUTTON8 = 'Connect bidirectionally'
BINDING_NAME_MESHNETBARBUTTON9 = 'Connect first polygon with second polygon one way'
BINDING_NAME_MESHNETBARBUTTON10 = 'Remove closest off-mesh connection'

local numberOfButtons = 2
local maximumNumberOfStackedButtons = 4
local buttonWidth = 40
local buttonHeight = 40
local buttonMargin = 6

local actionBar = CreateFrame('Frame', 'MeshNetBar', UIParent)
actionBar:SetPoint('CENTER', UIParent, 'CENTER', 100, 100)
actionBar:SetWidth(numberOfButtons * buttonWidth + (numberOfButtons - 1) * buttonMargin)
actionBar:SetHeight(maximumNumberOfStackedButtons * buttonHeight + (maximumNumberOfStackedButtons - 1) * buttonMargin)
actionBar:Show()

function createButton(id, macroText, tooltipText, postClick)
  local button = CreateFrame('CheckButton', 'MeshNetBarButton' .. id, actionBar, 'ActionButtonTemplate')
  button.buttonType = 'MESHNETBARBUTTON'
  button:SetID(id)
  button:SetAttribute('id', id)
  button:RegisterForClicks('AnyUp')
  if button.UpdateHotkeys then
    button:UpdateHotkeys(button.buttonType)
  elseif _G.ActionButton_UpdateHotkeys then
    ActionButton_UpdateHotkeys(button, button.buttonType)
  end
  button:SetAttribute('type', 'macro')
  button:SetAttribute('macrotext', macroText)
  button:SetPoint('CENTER', actionBar, 'LEFT', 0, 0)
  button:SetScript('OnClick', function (self, button)
    SecureActionButton_OnClick(self, button)
  end)

  button:SetScript('PostClick', function (self, button, down)
    if postClick then
      postClick(self, button, down)
    else
      self:SetChecked(false)
    end
  end)

  button.icon:SetTexture(134400)
  button.icon:Show()

  button:SetScript('OnEnter', function (self)
    GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
    GameTooltip:SetText(tooltipText)
  end)

  button:SetScript('OnLeave', function ()
    GameTooltip:Hide()
  end)

  button:Show()
  return button
end

local function createTooltipText(header, name)
  if header then
    return header .. ': ' .. string.lower(string.sub(name, 1, 1)) .. string.sub(name, 2)
  else
    return name
  end
end

local button1 = createButton(1, '/script MeshNet.toggleMeshVisualization()', createTooltipText(nil, BINDING_NAME_MESHNETBARBUTTON1), Function.noOperation)
button1:SetPoint('BOTTOMLEFT', 0, 0)

local button2 = createButton(2, '/script MeshNet.setFirstOffMeshConnectionPolygon()', createTooltipText(BINDING_HEADER_CONNECTING_TWO_POLYGONS, BINDING_NAME_MESHNETBARBUTTON2), function (self)
  --self:SetChecked(Boolean.toBoolean(MeshNet.firstOffMeshConnectionPolygon))
end)
button2:SetPoint('LEFT', button1, 'RIGHT', 6, 0)

local button3 = createButton(3, '/script MeshNet.setSecondOffMeshConnectionPolygon()', createTooltipText(BINDING_HEADER_CONNECTING_TWO_POLYGONS, BINDING_NAME_MESHNETBARBUTTON3), function (self)
  --self:SetChecked(Boolean.toBoolean(MeshNet.secondOffMeshConnectionPolygon))
end)
button3:SetPoint('TOPLEFT', button2, 'BOTTOMLEFT', 0, -6)

local button4 = createButton(4, '/script MeshNet.connectPolygons(true)', createTooltipText(BINDING_HEADER_CONNECTING_TWO_POLYGONS, BINDING_NAME_MESHNETBARBUTTON4))
button4:SetPoint('TOPLEFT', button3, 'BOTTOMLEFT', 0, -6)

local button5 = createButton(5, '/script MeshNet.connectPolygons(false)', createTooltipText(BINDING_HEADER_CONNECTING_TWO_POLYGONS, BINDING_NAME_MESHNETBARBUTTON5))
button5:SetPoint('TOPLEFT', button4, 'BOTTOMLEFT', 0, -6)

local button6 = createButton(6, '/script MeshNet.setFirstOffMeshConnectionPoint()', createTooltipText(BINDING_HEADER_CONNECTING_TWO_POLYGONS_WITH_POINT_SPECIFICATION, BINDING_NAME_MESHNETBARBUTTON6))
button6:SetPoint('LEFT', button2, 'RIGHT', 6, 0)

local button7 = createButton(7, '/script MeshNet.setSecondOffMeshConnectionPoint()', createTooltipText(BINDING_HEADER_CONNECTING_TWO_POLYGONS_WITH_POINT_SPECIFICATION, BINDING_NAME_MESHNETBARBUTTON7))
button7:SetPoint('TOPLEFT', button6, 'BOTTOMLEFT', 0, -6)

local button8 = createButton(8, '/script MeshNet.saveOffMeshConnection(true)', createTooltipText(BINDING_HEADER_CONNECTING_TWO_POLYGONS_WITH_POINT_SPECIFICATION, BINDING_NAME_MESHNETBARBUTTON8))
button8:SetPoint('TOPLEFT', button7, 'BOTTOMLEFT', 0, -6)

local button9 = createButton(9, '/script MeshNet.saveOffMeshConnection(false)', createTooltipText(BINDING_HEADER_CONNECTING_TWO_POLYGONS_WITH_POINT_SPECIFICATION, BINDING_NAME_MESHNETBARBUTTON9))
button9:SetPoint('TOPLEFT', button8, 'BOTTOMLEFT', 0, -6)

local button10 = createButton(10, '/script MeshNet.removeClosestOffMeshConnection()', createTooltipText(nil, BINDING_NAME_MESHNETBARBUTTON10))
button10:SetPoint('LEFT', button6, 'RIGHT', 6, 0)

MeshNet.onMeshVisualizationToggled(function ()
  button1:SetChecked(MeshNet.isMeshVisualizationEnabled())
end)

MeshNet.onFirstOffMeshConnectionPolygonSet(function ()
  button2:SetChecked(Boolean.toBoolean(MeshNet.firstOffMeshConnectionPolygon))
end)

print('button')

function meshNetBarButtonDown(bar, id)
  local button = _G[bar .. 'Button' .. id]
  if button:GetButtonState() == 'NORMAL' then
    button:SetButtonState('PUSHED')
  end
  if GetCVarBool('ActionButtonUseKeyDown') then
    SecureActionButton_OnClick(button, 'LeftButton')
  end
end

function meshNetBarButtonUp(bar, id)
  local button = _G[bar .. 'Button' .. id]
  if button:GetButtonState() == 'PUSHED' then
    button:SetButtonState('NORMAL')
    if not GetCVarBool('ActionButtonUseKeyDown') then
      SecureActionButton_OnClick(button, 'LeftButton')
    end
  end
end
