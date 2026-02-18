local addonName, CUI = ...

CUI.Chat = {}
local Chat = CUI.Chat

local function StyleChatBox(i)
    _G["ChatFrame"..i.."EditBoxLeft"]:Hide()
    _G["ChatFrame"..i.."EditBoxRight"]:Hide()
    _G["ChatFrame"..i.."EditBoxMid"]:Hide()

    _G["ChatFrame"..i.."EditBoxFocusLeft"]:SetTexture(nil)
    _G["ChatFrame"..i.."EditBoxFocusRight"]:SetTexture(nil)
    _G["ChatFrame"..i.."EditBoxFocusMid"]:SetTexture(nil)

    _G["ChatFrame"..i.."ButtonFrame"]:Hide()
    _G["ChatFrame"..i]:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", 12, "")
    _G["ChatFrame"..i.."EditBox"]:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", 12, "")
    _G["ChatFrame"..i.."EditBoxHeader"]:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", 12, "")

    local chatTab = _G["ChatFrame"..i.."Tab"]
    chatTab.HighlightLeft:SetTexture(nil)
    chatTab.HighlightMiddle:SetTexture(nil)
    chatTab.HighlightRight:SetTexture(nil)
    chatTab.ActiveLeft:SetAlpha(0)
    chatTab.ActiveMiddle:SetAlpha(0)
    chatTab.ActiveRight:SetAlpha(0)
    chatTab.Left:Hide()
    chatTab.Middle:Hide()
    chatTab.Right:Hide()
    chatTab.noMouseAlpha = 0
end

function Chat.Load()
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("CHAT_MSG_WHISPER")
    frame:SetScript("OnEvent", function(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p)
        for i=NUM_CHAT_WINDOWS+1, NUM_CHAT_WINDOWS+10 do
            local chatTab = _G["ChatFrame"..i.."Tab"]
            if chatTab and not chatTab.Styled then
                chatTab.Styled = true
                StyleChatBox(i)
            end
        end
    end)

    QuickJoinToastButton:Hide()

	CHAT_TAB_SHOW_DELAY = 0
	CHAT_TAB_HIDE_DELAY = 0
	CHAT_FRAME_FADE_TIME = 0.2
	CHAT_FRAME_FADE_OUT_TIME = 0.2
	CHAT_FRAME_BUTTON_FRAME_MIN_ALPHA = 0
	CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0
	CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0
    CHAT_FRAME_DEFAULT_FONT_SIZE = 12

    for i = 1, NUM_CHAT_WINDOWS do
        StyleChatBox(i)
	end

    FCF_FadeOutChatFrame(ChatFrame1)
end