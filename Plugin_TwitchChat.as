#name "Twitch Chat Bot"
#author "bmx22c"
#category "Streaming"

#include "Time.as"
#include "Formatting.as"
#include "../Twitch/Structures.as"
#include "../Twitch/Functions.as"
int g_pluginId;

[Setting category="Commands" name="Enable map command"]
bool Setting_MapCommand;

[Setting category="Commands" name="Enable server command"]
bool Setting_ServerCommand;

[Setting category="Commands" name="Enable personnal best command"]
bool Setting_PbCommand;

[Setting category="Commands" name="Enable URL command"]
bool Setting_LinkCommand;

[Setting category="Commands" name="Command prefix" description="[/@.] doesn't work"]
string Setting_ChatCommandPrefix;

[Setting category="Commands" name="Map command (without prefix)"]
string Setting_ChatCommandMap;

[Setting category="Commands" name="Server command (without prefix)"]
string Setting_ChatCommandServer;

[Setting category="Commands" name="Personnal best command (without prefix)"]
string Setting_ChatCommandPersonnalBest;

[Setting category="Commands" name="URL command (without prefix)"]
string Setting_ChatCommandURL;

[Setting category="Strings" name="Current map" description="{name} {author}"]
string Setting_StringCurrentMap;

[Setting category="Strings" name="Current server" description="{name} {nbr_player} {max_player}"]
string Setting_StringCurrentServer;

[Setting category="Strings" name="Current personnal best time" description="{pb}"]
string Setting_StringCurrentPersonnalBest;

[Setting category="Strings" name="Current map URL" description="{url}"]
string Setting_StringCurrentURL;

[Setting category="Strings" name="Not in a map"]
string Setting_StringNoCurrentMap;

[Setting category="Strings" name="Not in a server"]
string Setting_StringNoCurrentServer;

[Setting category="Strings" name="No personnal best time"]
string Setting_StringNoCurrentPersonnalBest;

string mapId = "";

CTrackMania@ g_app;
CGameCtnChallenge@ GetCurrentMap()
{
#if MP41 || TMNEXT
	return g_app.RootMap;
#else
	return g_app.Challenge;
#endif
}

void Main() {
	@g_app = cast<CTrackMania>(GetApp());

	while (!Twitch_ChannelsJoined()) yield();
	while (true) {
		if (g_pluginId == 0) g_pluginId = Twitch_Register(TwitchMessageType::ChatMessage);
		array<TwitchMessage@> newMessages = Twitch_Fetch(g_pluginId);
		for (uint i = 0; i < newMessages.Length; i++) {
			if(Setting_ChatCommandPrefix != ""){
				if (newMessages[i].m_text.StartsWith(Setting_ChatCommandPrefix)) {
					HandleCommand(Setting_ChatCommandPrefix, newMessages[i].m_text);
				}
			}
			print(newMessages[i].m_username + " said: " + newMessages[i].m_text);
		}
		yield();
	}
}

void HandleCommand(string prefix, string message)
{
	if (Setting_ChatCommandMap != "" && message == prefix+Setting_ChatCommandMap && Setting_MapCommand) {
		auto currentMap = GetCurrentMap();
		if (currentMap !is null) {
			string tmp = Setting_StringCurrentMap;
			tmp = Replace("\\{map\\}", StripFormatCodes(currentMap.MapName), tmp);
			tmp = Replace("\\{author\\}", StripFormatCodes(currentMap.AuthorNickName), tmp);

			Twitch_SendMessage('bmx22c', tmp);
		} else {
			string tmp = Setting_StringNoCurrentMap;
			Twitch_SendMessage('bmx22c', tmp);
		}

	} else if (Setting_ChatCommandServer != "" && message == prefix+Setting_ChatCommandServer && Setting_ServerCommand) {
		auto serverInfo = cast<CGameCtnNetServerInfo>(g_app.Network.ServerInfo);
		if (serverInfo.ServerLogin != "") {
			int numPlayers = g_app.ChatManagerScript.CurrentServerPlayerCount - 1;
			int maxPlayers = g_app.ChatManagerScript.CurrentServerPlayerCountMax;

			string tmp = Setting_StringCurrentServer;
			tmp = Replace("\\{name\\}", StripFormatCodes(serverInfo.ServerName), tmp);
			tmp = Replace("\\{nbr_player\\}", "" + (numPlayers - 1), tmp);
			tmp = Replace("\\{max_player\\}", "" + maxPlayers, tmp);

			Twitch_SendMessage('bmx22c', tmp);
		} else {
			string tmp = Setting_StringNoCurrentServer;
			Twitch_SendMessage('bmx22c', tmp);
		}

	} else if (Setting_ChatCommandPersonnalBest != "" && message == prefix+Setting_ChatCommandPersonnalBest && Setting_PbCommand) {
		auto currentMap = GetCurrentMap();
		if (currentMap !is null) {
			auto network = cast<CTrackManiaNetwork>(@g_app.Network);
			auto userInfo = cast<CTrackManiaPlayerInfo>(network.PlayerInfo);
			auto userId = userInfo.Id;
			string UIDMap = currentMap.MapInfo.MapUid;

			print("" + UIDMap);
			
			auto temps = cast<CTrackManiaMenus@>(g_app.MenuManager).MenuCustom_CurrentManiaApp.ScoreMgr.Map_GetRecord_v2(userId, UIDMap, "PersonalBest", "", "TimeAttack", "");
			print("" + Time::Format(temps));
			print("" + temps);
			if(temps != 4294967295 && temps != 0){
				string tmp = Setting_StringCurrentPersonnalBest;
				tmp = Replace("\\{pb\\}", StripFormatCodes(Time::Format(temps)), tmp);

				Twitch_SendMessage('bmx22c', tmp);
			} else {
				string tmp = Setting_StringNoCurrentPersonnalBest;
				Twitch_SendMessage('bmx22c', tmp);
			}
		} else {
			string tmp = Setting_StringNoCurrentMap;

			Twitch_SendMessage('bmx22c', tmp);
		}
	}  else if (Setting_ChatCommandURL != "" && message == prefix+Setting_ChatCommandURL && Setting_LinkCommand) {
		auto currentMap = GetCurrentMap();
		if (currentMap !is null) {
			string UIDMap = currentMap.MapInfo.MapUid;

			string tmp = Setting_StringCurrentURL;
			tmp = Replace("\\{url\\}", "https://trackmania.io/#/leaderboard/"+UIDMap, tmp);

			Twitch_SendMessage('bmx22c', tmp);
		} else {
			string tmp = Setting_StringNoCurrentMap;

			Twitch_SendMessage('bmx22c', tmp);
		}
	} 
}


string Replace(string search, string replace, string subject)
{
	return Regex::Replace(subject, search, replace);
}