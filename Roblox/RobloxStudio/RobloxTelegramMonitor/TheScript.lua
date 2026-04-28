--[[
    ================================================================
    [ SCRIPT INFORMATION ]
    Project: Custom Script
    Author: OYB
    YouTube: https://www.youtube.com/@OYBloxYT
    
    [ TERMS AND CONDITIONS ]
    - You ARE allowed to use and modify this script for your own games.
    - You ARE NOT allowed to re-upload, redistribute, or claim 
      ownership of this script.
    - Removing or altering these credits is strictly prohibited.
    
    Copyright (c) 2026 OYB. All rights reserved.
    ================================================================
]]

print("Running OYB Script - Subscribe at youtube.com/@OYBOfficial")

-- CONFIGURATION
local TELEGRAM_BOT_TOKEN = "Token" 
local TELEGRAM_USER_ID = "Id" 
local DATASTORE_NAME = "OYB_PlayerData" -- Do not change this 

-- SERVICES
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local MemoryStoreService = game:GetService("MemoryStoreService")

local PlayerDataStore = DataStoreService:GetDataStore(DATASTORE_NAME)
local LeaderboardStore = DataStoreService:GetOrderedDataStore(DATASTORE_NAME .. "_LB")
local BotSettingsStore = DataStoreService:GetDataStore(DATASTORE_NAME .. "_Settings")
local GlobalServersMap = MemoryStoreService:GetSortedMap("OYB_LiveServers_Map")

-- INTERNAL VARIABLES
local BaseUrl = "https://api.telegram.org/bot" .. TELEGRAM_BOT_TOKEN .. "/"
local LastUpdateId = 0
local ActiveMsgId = nil
local CurrentState = "MAIN" 
local CurrentPage = 1
local TargetServerIndex = 1
local ItemsPerPage = 10
local SessionData = {}
local ServerStartTime = os.time()
local MyServerId = game.JobId
if MyServerId == "" then MyServerId = HttpService:GenerateGUID(false) end 

-- BOT SETTINGS (Will be loaded from DataStore)
local BotSettings = {
	Lang = "EN",
	JoinAlerts = true,
	LeaveAlerts = false
}

-- TRANSLATIONS
local Lang = {
	EN = {
		MainTitle = "🚀 OYB Hub Dashboard", ChooseOption = "Choose a menu to view:",
		PlayersMenu = "👥 Players", PlayersTitle = "👥 All Players (Online & Offline)",
		ServersMenu = "🖥️ Servers", Uptime = "Uptime", Server = "Server",
		AlertsMenu = "🔔 Alerts", AlertsTitle = "🔔 Alerts Settings",
		JoinAlertsOn = "🔕 Enable Join Alerts", JoinAlertsOff = "🔔 Disable Join Alerts",
		LeaveAlertsOn = "🔕 Enable Leave Alerts", LeaveAlertsOff = "🔔 Disable Leave Alerts",
		Refresh = "🔄 Refresh", Language = "🌐 Language",
		Page = "Page", NoPlayers = "No players found.",
		Online = "Online", Offline = "Offline", Playtime = "Playtime", SessionTime = "Session Time", 
		LastSeen = "Last Seen", Search = "🔍 Search", Back = "🔙 Back",
		Next = "Next ➡️", Prev = "⬅️ Prev",
		ServersTitle = "🖥️ Active Servers", ViewPlayers = "View Players",
		SearchPrompt = "*🔍 Search System*\nType the exact Username or DisplayName.", Cancel = "🔙 Cancel",
		Found = "✅ Player Found!", NotFound = "❌ Player not found.", Name = "Name", Status = "Status",
		JoinAlert = "🔔 *New Player Joined*", LeaveAlert = "🚪 *Player Left*", Date = "Date", Time = "Time",
		EmptyAlert = "⚠️ *Game Empty*\nThe last player left the game. The bot is offline until someone joins.",
		SelectLang = "🌐 Select your language:"
	},
	AR = {
		MainTitle = "🚀 لوحة تحكم OYB Hub", ChooseOption = "اختر القائمة:",
		PlayersMenu = "👥 اللاعبين", PlayersTitle = "👥 جميع اللاعبين (متصل وغير متصل)",
		ServersMenu = "🖥️ السيرفرات المتصلة", Uptime = "مدة التشغيل", Server = "سيرفر",
		AlertsMenu = "🔔 الإشعارات", AlertsTitle = "🔔 إعدادات الإشعارات",
		JoinAlertsOn = "🔕 تفعيل إشعارات الدخول", JoinAlertsOff = "🔔 إيقاف إشعارات الدخول",
		LeaveAlertsOn = "🔕 تفعيل إشعارات الخروج", LeaveAlertsOff = "🔔 إيقاف إشعارات الخروج",
		Refresh = "🔄 تحديث", Language = "🌐 اللغة",
		Page = "الصفحة", NoPlayers = "لا يوجد بيانات لاعبين.",
		Online = "متصل", Offline = "غير متصل", Playtime = "وقت اللعب", SessionTime = "وقت الجلسة", 
		LastSeen = "آخر ظهور", Search = "🔍 بحث", Back = "🔙 رجوع",
		Next = "التالي ➡️", Prev = "⬅️ السابق",
		ServersTitle = "🖥️ السيرفرات النشطة", ViewPlayers = "عرض اللاعبين",
		SearchPrompt = "*🔍 نظام البحث*\nاكتب اسم اللاعب (الأساسي أو المستعار) بدقة.", Cancel = "🔙 إلغاء",
		Found = "✅ تم العثور على اللاعب!", NotFound = "❌ اللاعب غير موجود.", Name = "الاسم", Status = "الحالة",
		JoinAlert = "🔔 *دخول لاعب جديد*", LeaveAlert = "🚪 *خروج لاعب*", Date = "التاريخ", Time = "الوقت",
		EmptyAlert = "⚠️ *الماب فارغ*\nخرج آخر لاعب. البوت متوقف حتى دخول لاعب جديد.",
		SelectLang = "🌐 اختر لغتك:"
	},
	FR = {
		MainTitle = "🚀 Tableau de bord OYB", ChooseOption = "Choisissez un menu:",
		PlayersMenu = "👥 Joueurs", PlayersTitle = "👥 Tous les Joueurs",
		ServersMenu = "🖥️ Serveurs", Uptime = "En ligne", Server = "Serveur",
		AlertsMenu = "🔔 Alertes", AlertsTitle = "🔔 Paramètres d'alerte",
		JoinAlertsOn = "🔕 Activer Alertes d'arrivée", JoinAlertsOff = "🔔 Désactiver Alertes d'arrivée",
		LeaveAlertsOn = "🔕 Activer Alertes de départ", LeaveAlertsOff = "🔔 Désactiver Alertes de départ",
		Refresh = "🔄 Actualiser", Language = "🌐 Langue",
		Page = "Page", NoPlayers = "Aucun joueur trouvé.",
		Online = "En ligne", Offline = "Hors ligne", Playtime = "Temps de jeu", SessionTime = "Temps de session", 
		LastSeen = "Dernière connexion", Search = "🔍 Rechercher", Back = "🔙 Retour",
		Next = "Suivant ➡️", Prev = "⬅️ Précédent",
		ServersTitle = "🖥️ Serveurs Actifs", ViewPlayers = "Voir Joueurs",
		SearchPrompt = "*🔍 Recherche*\nTapez le nom exact.", Cancel = "🔙 Annuler",
		Found = "✅ Joueur trouvé!", NotFound = "❌ Joueur introuvable.", Name = "Nom", Status = "Statut",
		JoinAlert = "🔔 *Nouveau Joueur*", LeaveAlert = "🚪 *Joueur Parti*", Date = "Date", Time = "Heure",
		EmptyAlert = "⚠️ *Jeu Vide*\nLe dernier joueur est parti. Bot hors ligne.",
		SelectLang = "🌐 Choisissez votre langue:"
	},
	DE = {
		MainTitle = "🚀 OYB Hub Dashboard", ChooseOption = "Wähle ein Menü:",
		PlayersMenu = "👥 Spieler", PlayersTitle = "👥 Alle Spieler",
		ServersMenu = "🖥️ Server", Uptime = "Laufzeit", Server = "Server",
		AlertsMenu = "🔔 Alarme", AlertsTitle = "🔔 Alarmeinstellungen",
		JoinAlertsOn = "🔕 Beitrittsalarme aktivieren", JoinAlertsOff = "🔔 Beitrittsalarme deaktivieren",
		LeaveAlertsOn = "🔕 Verlassensalarme aktivieren", LeaveAlertsOff = "🔔 Verlassensalarme deaktivieren",
		Refresh = "🔄 Aktualisieren", Language = "🌐 Sprache",
		Page = "Seite", NoPlayers = "Keine Spieler gefunden.",
		Online = "Online", Offline = "Offline", Playtime = "Spielzeit", SessionTime = "Sitzungszeit", 
		LastSeen = "Zuletzt gesehen", Search = "🔍 Suchen", Back = "🔙 Zurück",
		Next = "Weiter ➡️", Prev = "⬅️ Zurück",
		ServersTitle = "🖥️ Aktive Server", ViewPlayers = "Spieler Ansehen",
		SearchPrompt = "*🔍 Suche*\nGib den genauen Namen ein.", Cancel = "🔙 Abbrechen",
		Found = "✅ Spieler gefunden!", NotFound = "❌ Spieler nicht gefunden.", Name = "Name", Status = "Status",
		JoinAlert = "🔔 *Neuer Spieler*", LeaveAlert = "🚪 *Spieler hat verlassen*", Date = "Datum", Time = "Zeit",
		EmptyAlert = "⚠️ *Spiel Leer*\nLetzter Spieler hat verlassen. Bot ist offline.",
		SelectLang = "🌐 Wähle deine Sprache:"
	},
	KO = {
		MainTitle = "🚀 OYB 허브 대시보드", ChooseOption = "메뉴를 선택하세요:",
		PlayersMenu = "👥 플레이어", PlayersTitle = "👥 모든 플레이어",
		ServersMenu = "🖥️ 서버", Uptime = "가동 시간", Server = "서버",
		AlertsMenu = "🔔 알림", AlertsTitle = "🔔 알림 설정",
		JoinAlertsOn = "🔕 입장 알림 켜기", JoinAlertsOff = "🔔 입장 알림 끄기",
		LeaveAlertsOn = "🔕 퇴장 알림 켜기", LeaveAlertsOff = "🔔 퇴장 알림 끄기",
		Refresh = "🔄 새로고침", Language = "🌐 언어",
		Page = "페이지", NoPlayers = "플레이어가 없습니다.",
		Online = "온라인", Offline = "오프라인", Playtime = "플레이 시간", SessionTime = "세션 시간", 
		LastSeen = "마지막 접속", Search = "🔍 검색", Back = "🔙 뒤로",
		Next = "다음 ➡️", Prev = "⬅️ 이전",
		ServersTitle = "🖥️ 활성 서버", ViewPlayers = "플레이어 보기",
		SearchPrompt = "*🔍 검색*\n정확한 사용자 이름을 입력하세요.", Cancel = "🔙 취소",
		Found = "✅ 플레이어 찾음!", NotFound = "❌ 찾을 수 없음.", Name = "이름", Status = "상태",
		JoinAlert = "🔔 *새 플레이어 접속*", LeaveAlert = "🚪 *플레이어 퇴장*", Date = "날짜", Time = "시간",
		EmptyAlert = "⚠️ *게임 비어있음*\n마지막 플레이어가 떠났습니다. 봇 오프라인.",
		SelectLang = "🌐 언어를 선택하세요:"
	}
}

-- UTILITIES
local function FormatT(sec) return string.format("%dh %dm", math.floor(sec/3600), math.floor((sec%3600)/60)) end
local function FormatUptime(sec) 
	local d = math.floor(sec/86400)
	local h = math.floor((sec%86400)/3600)
	local m = math.floor((sec%3600)/60)
	if d > 0 then return string.format("%dd %dh", d, h) else return string.format("%dh %dm", h, m) end
end

-- DATASTORE FUNCTIONS
local function LoadData(player)
	local data
	local s, e = pcall(function() data = PlayerDataStore:GetAsync(tostring(player.UserId)) end)
	if s and not data then data = {TotalPlaytime = 0} end
	return data
end

local function SaveData(player, data)
	pcall(function() 
		PlayerDataStore:SetAsync(tostring(player.UserId), data) 
		LeaderboardStore:SetAsync(tostring(player.UserId), math.floor(data.TotalPlaytime))
	end)
end

local function UpdatePlaytime(player)
	if SessionData[player.UserId] then
		SessionData[player.UserId].TotalPlaytime = SessionData[player.UserId].InitPlaytime + (os.time() - SessionData[player.UserId].JoinTime)
	end
end

-- SETTINGS FUNCTIONS
local function LoadBotSettings()
	local s, data = pcall(function() return BotSettingsStore:GetAsync("GlobalSettings") end)
	if s and data then
		BotSettings.Lang = data.Lang or "EN"
		BotSettings.JoinAlerts = data.JoinAlerts ~= false 
		BotSettings.LeaveAlerts = data.LeaveAlerts == true 
	end
end

local function SaveBotSettings()
	pcall(function() BotSettingsStore:SetAsync("GlobalSettings", BotSettings) end)
	pcall(function() GlobalServersMap:SetAsync("BOT_SETTINGS", HttpService:JSONEncode(BotSettings), 86400) end)
end

-- CROSS-SERVER MEMORY STORE LOGIC
-- تم إضافة متغير (ignoreUserId) لتجاهل اللاعب اللي بيطلع فوراً من الحسبة
local function SyncServerData(ignoreUserId)
	local myPlayers = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p.UserId ~= ignoreUserId then
			UpdatePlaytime(p)
			table.insert(myPlayers, {
				UserId = p.UserId,
				Name = p.Name, 
				DisplayName = p.DisplayName, 
				TotalPlaytime = SessionData[p.UserId] and SessionData[p.UserId].TotalPlaytime or 0,
				SessionTime = SessionData[p.UserId] and (os.time() - SessionData[p.UserId].JoinTime) or 0
			})
		end
	end

	local payload = HttpService:JSONEncode({StartTime = ServerStartTime, Players = myPlayers})
	pcall(function() GlobalServersMap:SetAsync(MyServerId, payload, 30) end) 
end

local function AmIMaster()
	local s, master = pcall(function() return GlobalServersMap:GetAsync("MASTER_NODE") end)
	if not s or master == nil or master == MyServerId then
		pcall(function() GlobalServersMap:SetAsync("MASTER_NODE", MyServerId, 10) end)
		return true
	end
	return false
end

local function GetGlobalServers()
	local servers = {}
	local s, data = pcall(function() return GlobalServersMap:GetRangeAsync(Enum.SortDirection.Ascending, 100) end)
	if s and data then
		for _, entry in ipairs(data) do
			if entry.key ~= "MASTER_NODE" and entry.key ~= "BOT_SETTINGS" and entry.key ~= "GAME_ACTIVE" and entry.key ~= "EMPTY_SENT" then
				local success, sData = pcall(function() return HttpService:JSONDecode(entry.value) end)
				if success and type(sData) == "table" and sData.Players then
					table.insert(servers, {JobId = entry.key, StartTime = sData.StartTime, Players = sData.Players})
				end
			end
		end
	end
	table.sort(servers, function(a, b) return a.StartTime < b.StartTime end)
	for i, s in ipairs(servers) do s.Index = i end
	return servers
end

-- TELEGRAM API FUNCTIONS
local function TReq(method, payload)
	local s, r = pcall(function() return HttpService:PostAsync(BaseUrl..method, HttpService:JSONEncode(payload), Enum.HttpContentType.ApplicationJson, false) end)
	return s and HttpService:JSONDecode(r) or nil
end

local function SendMsg(text, markup) return TReq("sendMessage", {chat_id=TELEGRAM_USER_ID, text=text, parse_mode="Markdown", reply_markup=markup}) end
local function EditMsg(id, text, markup) return TReq("editMessageText", {chat_id=TELEGRAM_USER_ID, message_id=id, text=text, parse_mode="Markdown", reply_markup=markup}) end
local function DeleteMsg(id) return TReq("deleteMessage", {chat_id=TELEGRAM_USER_ID, message_id=id}) end
local function AnsQuery(id) TReq("answerCallbackQuery", {callback_query_id=id}) end

-- MENU BUILDERS
local function B_Main()
	local t = Lang[BotSettings.Lang]
	local gServers = GetGlobalServers()
	local tPlayers = 0
	for _, s in ipairs(gServers) do tPlayers = tPlayers + #s.Players end

	local kb = {inline_keyboard={
		{{text=t.ServersMenu.." ("..#gServers..")", callback_data="SERVERS"}},
		{{text=t.PlayersMenu.." ("..tPlayers.." "..t.Online..")", callback_data="PLAYERS"}},
		{{text=t.AlertsMenu, callback_data="ALERTS_MENU"}, {text=t.Language, callback_data="LANG"}},
		{{text=t.Refresh, callback_data="REFRESH"}}
	}}
	return "*"..t.MainTitle.."*\n\n"..t.ChooseOption, kb
end

local function B_Alerts()
	local t = Lang[BotSettings.Lang]
	local joinBtn = BotSettings.JoinAlerts and t.JoinAlertsOff or t.JoinAlertsOn
	local leaveBtn = BotSettings.LeaveAlerts and t.LeaveAlertsOff or t.LeaveAlertsOn

	local kb = {inline_keyboard={
		{{text=joinBtn, callback_data="TOGGLE_JOIN"}},
		{{text=leaveBtn, callback_data="TOGGLE_LEAVE"}},
		{{text=t.Back, callback_data="MAIN"}}
	}}
	return "*"..t.AlertsTitle.."*", kb
end

local function B_Servers(page)
	local t, gServers = Lang[BotSettings.Lang], GetGlobalServers()
	local maxP = math.max(1, math.ceil(#gServers/ItemsPerPage))
	page = math.clamp(page, 1, maxP)

	local txt = "*"..t.ServersTitle.."*\n"..t.Page..": "..page.."/"..maxP.."\n\n"
	local kb = {inline_keyboard={}}

	for i=(page-1)*ItemsPerPage+1, math.min(page*ItemsPerPage, #gServers) do
		local s = gServers[i]
		txt = txt.."🖥️ *"..t.Server.." "..s.Index.."*\n   └ 🟢 "..#s.Players.." "..t.Online.."\n   └ ⏱️ "..t.Uptime..": "..FormatUptime(os.time() - s.StartTime).."\n\n"
		table.insert(kb.inline_keyboard, {{text="🔍 "..t.ViewPlayers.." ("..t.Server.." "..s.Index..")", callback_data="V_SRV_"..s.Index}})
	end

	local nav = {}
	if page>1 then table.insert(nav, {text=t.Prev, callback_data="SRV_P_"..(page-1)}) end
	if page<maxP then table.insert(nav, {text=t.Next, callback_data="SRV_P_"..(page+1)}) end
	if #nav>0 then table.insert(kb.inline_keyboard, nav) end
	table.insert(kb.inline_keyboard, {{text=t.Refresh, callback_data="SRV_P_"..page}, {text=t.Back, callback_data="MAIN"}})
	return txt, kb
end

local function B_Players(page, filterServerIndex)
	local t = Lang[BotSettings.Lang]
	local gServers = GetGlobalServers()

	if filterServerIndex then
		local srvPlayers = {}
		for _, s in ipairs(gServers) do
			if s.Index == filterServerIndex then
				for _, p in ipairs(s.Players) do
					table.insert(srvPlayers, {Name = p.Name, DisplayName = p.DisplayName, SessionTime = p.SessionTime})
				end
			end
		end

		local maxP = math.max(1, math.ceil(#srvPlayers/ItemsPerPage))
		page = math.clamp(page, 1, maxP)

		local txt = "*🟢 "..t.Server.." "..filterServerIndex.." Players*\n"..t.Page..": "..page.."/"..maxP.."\n\n"
		if #srvPlayers == 0 then txt = txt..t.NoPlayers else
			for i=(page-1)*ItemsPerPage+1, math.min(page*ItemsPerPage, #srvPlayers) do
				local p = srvPlayers[i]
				local displayName = p.DisplayName or p.Name
				txt = txt.."👤 *"..displayName.."* (@"..p.Name..")\n   └ ⏱️ "..t.SessionTime..": "..FormatT(p.SessionTime).."\n"
			end
		end

		local kb = {inline_keyboard={}}
		local nav = {}
		local cbPrefix = "PLY_F_"..filterServerIndex.."_"
		if page>1 then table.insert(nav, {text=t.Prev, callback_data=cbPrefix..(page-1)}) end
		if page<maxP then table.insert(nav, {text=t.Next, callback_data=cbPrefix..(page+1)}) end
		if #nav>0 then table.insert(kb.inline_keyboard, nav) end
		table.insert(kb.inline_keyboard, {{text=t.Search, callback_data="SEARCH"}})
		table.insert(kb.inline_keyboard, {{text=t.Refresh, callback_data=cbPrefix..page}, {text=t.Back, callback_data="SERVERS"}})
		return txt, kb
	end

	local onlineMap = {}
	local combinedList = {}

	for _, s in ipairs(gServers) do
		for _, p in ipairs(s.Players) do
			onlineMap[tostring(p.UserId)] = true
			table.insert(combinedList, {
				UserId = p.UserId, Name = p.Name, DisplayName = p.DisplayName, 
				Playtime = p.TotalPlaytime, IsOnline = true, SrvIndex = s.Index
			})
		end
	end
	table.sort(combinedList, function(a, b) return a.Playtime > b.Playtime end)

	local s_lb, pages = pcall(function() return LeaderboardStore:GetSortedAsync(false, 100) end)
	if s_lb and pages then
		local items = pages:GetCurrentPage()
		for _, item in ipairs(items) do
			if not onlineMap[tostring(item.key)] then
				table.insert(combinedList, {
					UserId = item.key, Playtime = item.value, IsOnline = false
				})
			end
		end
	end

	local maxP = math.max(1, math.ceil(#combinedList/ItemsPerPage))
	page = math.clamp(page, 1, maxP)

	local txt = "*"..t.PlayersTitle.."*\n"..t.Page..": "..page.."/"..maxP.."\n\n"

	if #combinedList == 0 then txt = txt..t.NoPlayers else
		for i=(page-1)*ItemsPerPage+1, math.min(page*ItemsPerPage, #combinedList) do
			local p = combinedList[i]
			if p.IsOnline then
				local dName = p.DisplayName or p.Name
				txt = txt.."👤 *"..dName.."* (@"..p.Name..") | 🟢 "..t.Online.." (🖥️ "..p.SrvIndex..")\n   └ "..t.Playtime..": "..FormatT(p.Playtime).."\n"
			else
				local pData
				pcall(function() pData = PlayerDataStore:GetAsync(tostring(p.UserId)) end)
				local dName = pData and (pData.DisplayName or pData.Name) or "Unknown"
				local uName = pData and pData.Name or "Unknown"
				local lastSeen = pData and pData.LastSeen or 0

				txt = txt.."👤 *"..dName.."* (@"..uName..") | ⚫ "..t.Offline.."\n   └ "..t.Playtime..": "..FormatT(p.Playtime).."\n   └ 📅 "..t.LastSeen..": "..os.date("%Y-%m-%d %H:%M", lastSeen).."\n"
			end
		end
	end

	local kb = {inline_keyboard={}}
	local nav = {}
	if page>1 then table.insert(nav, {text=t.Prev, callback_data="PLY_P_"..(page-1)}) end
	if page<maxP then table.insert(nav, {text=t.Next, callback_data="PLY_P_"..(page+1)}) end
	if #nav>0 then table.insert(kb.inline_keyboard, nav) end
	table.insert(kb.inline_keyboard, {{text=t.Search, callback_data="SEARCH"}})
	table.insert(kb.inline_keyboard, {{text=t.Refresh, callback_data="PLY_P_"..page}, {text=t.Back, callback_data="MAIN"}})
	return txt, kb
end

local function B_Lang()
	local t = Lang[BotSettings.Lang]
	local kb = {inline_keyboard={
		{{text="🇬🇧 English", callback_data="SETLANG_EN"}, {text="🇸🇦 العربية", callback_data="SETLANG_AR"}},
		{{text="🇰🇷 한국어", callback_data="SETLANG_KO"}, {text="🇫🇷 Français", callback_data="SETLANG_FR"}},
		{{text="🇩🇪 Deutsch", callback_data="SETLANG_DE"}},
		{{text=t.Back, callback_data="MAIN"}}
	}}
	return "*"..t.SelectLang.."*", kb
end

-- PROCESS UPDATES (ONLY RUNS ON MASTER NODE)
local function MasterTasks()
	if not AmIMaster() then return end

	-- Auto-Start functionality: Check if game just woke up
	local s_active, isActive = pcall(function() return GlobalServersMap:GetAsync("GAME_ACTIVE") end)
	pcall(function() GlobalServersMap:SetAsync("GAME_ACTIVE", true, 30) end)

	if s_active and not isActive then
		-- Sends the Main Menu automatically on boot
		local txt, kb = B_Main()
		local sm = SendMsg(txt, kb)
		if sm and sm.result then ActiveMsgId = sm.result.message_id end
	end

	-- Poll Telegram for interactions
	local r = TReq("getUpdates", {offset=LastUpdateId+1, timeout=5})
	if r and r.ok and r.result then
		for _, u in ipairs(r.result) do
			LastUpdateId = u.update_id
			local t = Lang[BotSettings.Lang]

			if u.callback_query then
				local cb = u.callback_query.data
				if not ActiveMsgId then ActiveMsgId = u.callback_query.message.message_id end
				local txt, kb = "", {}

				if cb=="MAIN" or cb=="REFRESH" then CurrentState="MAIN"; txt, kb = B_Main()
				elseif cb=="LANG" then CurrentState="LANG"; txt, kb = B_Lang()
				elseif string.sub(cb,1,8)=="SETLANG_" then 
					BotSettings.Lang=string.sub(cb,9); SaveBotSettings(); txt, kb = B_Main()
				elseif cb=="ALERTS_MENU" then CurrentState="ALERTS"; txt, kb = B_Alerts()
				elseif cb=="TOGGLE_JOIN" then 
					BotSettings.JoinAlerts = not BotSettings.JoinAlerts; SaveBotSettings(); txt, kb = B_Alerts()
				elseif cb=="TOGGLE_LEAVE" then 
					BotSettings.LeaveAlerts = not BotSettings.LeaveAlerts; SaveBotSettings(); txt, kb = B_Alerts()
				elseif cb=="SERVERS" then CurrentState="SRV"; CurrentPage=1; txt, kb = B_Servers(1)
				elseif string.sub(cb,1,6)=="SRV_P_" then CurrentPage=tonumber(string.sub(cb,7)) or 1; txt, kb = B_Servers(CurrentPage)
				elseif string.sub(cb,1,6)=="V_SRV_" then TargetServerIndex=tonumber(string.sub(cb,7)); CurrentState="PLY_F"; CurrentPage=1; txt, kb = B_Players(1, TargetServerIndex)
				elseif string.sub(cb,1,6)=="PLY_F_" then
					local parts = string.split(cb, "_")
					TargetServerIndex = tonumber(parts[3])
					CurrentPage = tonumber(parts[4]) or 1
					txt, kb = B_Players(CurrentPage, TargetServerIndex)
				elseif cb=="PLAYERS" then CurrentState="PLY"; CurrentPage=1; txt, kb = B_Players(1)
				elseif string.sub(cb,1,6)=="PLY_P_" then CurrentPage=tonumber(string.sub(cb,7)) or 1; txt, kb = B_Players(CurrentPage)
				elseif cb=="SEARCH" then
					CurrentState="SEARCH"; txt = t.SearchPrompt
					kb = {inline_keyboard={{{text=t.Cancel, callback_data="MAIN"}}}}
				end

				if txt~="" then EditMsg(ActiveMsgId, txt, kb) end
				AnsQuery(u.callback_query.id)

			elseif u.message and u.message.text then
				if CurrentState == "SEARCH" then
					local searchName = string.lower(u.message.text)
					local gServers = GetGlobalServers()
					local foundPlayer, foundSrv = nil, nil

					for _, s in ipairs(gServers) do
						for _, p in ipairs(s.Players) do
							if string.lower(p.Name) == searchName or string.lower(p.DisplayName or "") == searchName then 
								foundPlayer = {Name = p.Name, DisplayName = p.DisplayName, Playtime = p.TotalPlaytime, IsOnline = true}
								foundSrv = s.Index
								break 
							end
						end
						if foundPlayer then break end
					end

					if not foundPlayer then
						local searchId = nil
						pcall(function() searchId = Players:GetUserIdFromNameAsync(u.message.text) end)
						if searchId then
							local pData
							pcall(function() pData = PlayerDataStore:GetAsync(tostring(searchId)) end)
							if pData then
								foundPlayer = {
									Name = pData.Name, DisplayName = pData.DisplayName,
									Playtime = pData.TotalPlaytime, IsOnline = false, LastSeen = pData.LastSeen
								}
							end
						end
					end

					local rep = ""
					if foundPlayer then
						local displayName = foundPlayer.DisplayName or foundPlayer.Name
						if foundPlayer.IsOnline then
							rep = t.Found.."\n\n👤 "..t.Name..": *"..displayName.."* (@"..foundPlayer.Name..")\n"..t.Status..": 🟢 "..t.Online.." (🖥️ "..t.Server.." "..foundSrv..")\n"..t.Playtime..": "..FormatT(foundPlayer.Playtime)
						else
							rep = t.Found.."\n\n👤 "..t.Name..": *"..displayName.."* (@"..foundPlayer.Name..")\n"..t.Status..": ⚫ "..t.Offline.."\n"..t.Playtime..": "..FormatT(foundPlayer.Playtime).."\n📅 "..t.LastSeen..": "..os.date("%Y-%m-%d %H:%M", foundPlayer.LastSeen)
						end
					else 
						rep = t.NotFound 
					end

					local kb = {inline_keyboard={{{text=t.Back, callback_data="MAIN"}}}}
					if ActiveMsgId then EditMsg(ActiveMsgId, rep, kb) else
						local sm = SendMsg(rep, kb)
						if sm and sm.result then ActiveMsgId = sm.result.message_id end
					end
					CurrentState = "MAIN"
				elseif u.message.text == "/start" then
					local txt, kb = B_Main()
					local sm = SendMsg(txt, kb)
					if sm and sm.result then ActiveMsgId = sm.result.message_id end
				end
			end
		end
	end
end

-- INITIALIZATION
LoadBotSettings()

-- EVENTS
local function OnPlayerAdded(p)
	task.spawn(function()
		-- مضاد الجلتشات: حذف رسالة الإغلاق لو انرسلت بالغلط
		pcall(function()
			local emptyMsgId = GlobalServersMap:GetAsync("LAST_EMPTY_MSG_ID")
			if emptyMsgId then
				DeleteMsg(emptyMsgId)
				GlobalServersMap:RemoveAsync("LAST_EMPTY_MSG_ID")
				GlobalServersMap:RemoveAsync("EMPTY_SENT_LOCK")
			end
		end)

		local data = LoadData(p)
		if not p:IsDescendantOf(Players) then return end 

		SessionData[p.UserId] = {JoinTime=os.time(), InitPlaytime=data.TotalPlaytime, TotalPlaytime=data.TotalPlaytime}
		SyncServerData()

		if BotSettings.JoinAlerts then 
			local t = Lang[BotSettings.Lang]
			local displayName = p.DisplayName or p.Name
			SendMsg(t.JoinAlert.."\n\n👤 *"..displayName.."* (@"..p.Name..")\n📅 "..t.Date..": "..os.date("%Y-%m-%d").."\n⏰ "..t.Time..": "..os.date("%H:%M:%S"), nil)
		end

		if AmIMaster() and ActiveMsgId and CurrentState == "PLY" then EditMsg(ActiveMsgId, B_Players(CurrentPage)) end
	end)
end

Players.PlayerAdded:Connect(OnPlayerAdded)

-- Catch any players already in the server when script boots!
for _, p in ipairs(Players:GetPlayers()) do
	OnPlayerAdded(p)
end

Players.PlayerRemoving:Connect(function(p)
	local leavingUserId = p.UserId
	if SessionData[leavingUserId] then
		UpdatePlaytime(p)
		local data = LoadData(p)
		if data then 
			data.TotalPlaytime = SessionData[leavingUserId].TotalPlaytime
			data.Name = p.Name
			data.DisplayName = p.DisplayName
			data.LastSeen = os.time()
			SaveData(p, data) 
		end

		if BotSettings.LeaveAlerts then
			local t = Lang[BotSettings.Lang]
			local displayName = p.DisplayName or p.Name
			SendMsg(t.LeaveAlert.."\n\n👤 *"..displayName.."* (@"..p.Name..")\n⏱️ "..t.SessionTime..": "..FormatT(os.time() - SessionData[leavingUserId].JoinTime).."\n📅 "..t.Date..": "..os.date("%Y-%m-%d").."\n⏰ "..t.Time..": "..os.date("%H:%M:%S"), nil)
		end

		SessionData[leavingUserId] = nil
	end
	SyncServerData(leavingUserId)

	task.spawn(function()
		task.wait(2) -- انتظار للتأكد من عدم دخول لاعب جديد (مضاد الجلتشات)

		local activeServers = GetGlobalServers()
		local globalPlayersCount = 0
		for _, s in ipairs(activeServers) do
			globalPlayersCount = globalPlayersCount + #s.Players
		end

		if globalPlayersCount == 0 then
			local s_lock, hasLocked = pcall(function() return GlobalServersMap:GetAsync("EMPTY_SENT_LOCK") end)
			if not hasLocked then
				pcall(function() GlobalServersMap:SetAsync("EMPTY_SENT_LOCK", true, 60) end)
				local sm = SendMsg(Lang[BotSettings.Lang].EmptyAlert, nil)
				if sm and sm.result and sm.result.message_id then
					pcall(function() GlobalServersMap:SetAsync("LAST_EMPTY_MSG_ID", sm.result.message_id, 86400) end)
				end
			end
		end

		if AmIMaster() and ActiveMsgId and CurrentState == "PLY" then
			task.wait(1) EditMsg(ActiveMsgId, B_Players(CurrentPage))
		end
	end)
end)

-- LOOP
task.spawn(function()
	while task.wait(5) do 
		pcall(function() 
			local sData = GlobalServersMap:GetAsync("BOT_SETTINGS")
			if sData then BotSettings = HttpService:JSONDecode(sData) end
		end)

		pcall(SyncServerData) 
		pcall(MasterTasks)    
	end
end)

-- ضمان إبقاء السيرفر شغال لثواني وقت إغلاقه لإرسال رسالة الإغلاق بأمان
game:BindToClose(function()
	task.wait(3)
end)
