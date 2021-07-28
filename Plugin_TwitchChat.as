#name "Twitch Chat Bot"
#author "bmx22c"
#category "Streaming"

#include "TwitchChat.as"
#include "Time.as"
#include "Formatting.as"

[Setting category="Parameters" name="Twitch OAuth Token" password]
string Setting_TwitchToken;

[Setting category="Parameters" name="Twitch Nickname" description="Lowercase."]
string Setting_TwitchNickname;

[Setting category="Parameters" name="Twitch Channel" description="Lowercase and including the # sign, for example: #missterious"]
string Setting_TwitchChannel;

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

class ChatMessage
{
	string m_username;
	string m_text;
}

string Replace(string search, string replace, string subject)
{
	return Regex::Replace(subject, search, replace);
}

array<ChatMessage@> g_chatMessages;

CGameCtnChallenge@ GetCurrentMap()
{
#if MP41 || TMNEXT
	return g_app.RootMap;
#else
	return g_app.Challenge;
#endif
}

class ChatCallbacks : Twitch::ICallbacks
{
	void HandleCommand(string prefix, ChatMessage@ msg)
	{
		if (msg.m_text == prefix+Setting_ChatCommandMap && Setting_MapCommand) {
			auto currentMap = GetCurrentMap();
			if (currentMap !is null) {
				string tmp = Setting_StringCurrentMap;
				tmp = Replace("\\{map\\}", StripFormatCodes(currentMap.MapName), tmp);
				tmp = Replace("\\{author\\}", StripFormatCodes(currentMap.AuthorNickName), tmp);

				Twitch::SendMessage(tmp);
				// Twitch::SendMessage("⏩ Map actuelle: " + StripFormatCodes(currentMap.MapName) + " par " + StripFormatCodes(currentMap.AuthorNickName));
			} else {
				string tmp = Setting_StringNoCurrentMap;
				Twitch::SendMessage(tmp);
				// Twitch::SendMessage("❌ Je ne joue actuellement sur aucune map.");
			}

		} else if (msg.m_text == prefix+Setting_ChatCommandServer && Setting_ServerCommand) {
			auto serverInfo = cast<CGameCtnNetServerInfo>(g_app.Network.ServerInfo);
			if (serverInfo.ServerLogin != "") {
				int numPlayers = g_app.ChatManagerScript.CurrentServerPlayerCount - 1;
				int maxPlayers = g_app.ChatManagerScript.CurrentServerPlayerCountMax;

				string tmp = Setting_StringCurrentServer;
				tmp = Replace("\\{name\\}", StripFormatCodes(serverInfo.ServerName), tmp);
				tmp = Replace("\\{nbr_player\\}", "" + (numPlayers - 1), tmp);
				tmp = Replace("\\{max_player\\}", "" + maxPlayers, tmp);

				Twitch::SendMessage(tmp);
				// Twitch::SendMessage("⏩ Serveur actuel: \"" + StripFormatCodes(serverInfo.ServerName) + "\" (" + (numPlayers - 1) + " / " + maxPlayers + ")");
			} else {
				string tmp = Setting_StringNoCurrentServer;
				Twitch::SendMessage(tmp);
				// Twitch::SendMessage("❌ Je ne joue actuellement sur aucun serveur.");
			}

		} else if (msg.m_text == prefix+Setting_ChatCommandPersonnalBest && Setting_PbCommand) {
			auto currentMap = GetCurrentMap();
			if (currentMap !is null) {
				auto network = cast<CTrackManiaNetwork>(@g_app.Network);
				auto userInfo = cast<CTrackManiaPlayerInfo>(network.PlayerInfo);
				auto userId = userInfo.Id;
				string UIDMap = currentMap.MapInfo.MapUid;

				// print("" + userId);
				print("" + UIDMap);
				
				// auto temps = g_app.PlaygroundScript.ScoreMgr.Map_GetRecord_v2(userId, UIDMap, "PersonalBest", "", "TimeAttack", "");
				auto temps = cast<CTrackManiaMenus@>(g_app.MenuManager).MenuCustom_CurrentManiaApp.ScoreMgr.Map_GetRecord_v2(userId, UIDMap, "PersonalBest", "", "TimeAttack", "");
				print("" + Time::Format(temps));
				print("" + temps);
				if(temps != 4294967295 && temps != 0){
					string tmp = Setting_StringCurrentPersonnalBest;
					tmp = Replace("\\{pb\\}", StripFormatCodes(Time::Format(temps)), tmp);

					Twitch::SendMessage(tmp);
					// Twitch::SendMessage("⏩ Meilleur temps actuel: " + StripFormatCodes(Time::Format(temps)));
				} else {
					string tmp = Setting_StringNoCurrentPersonnalBest;
					Twitch::SendMessage(tmp);
					// Twitch::SendMessage("❌ Je n'ai pas encore fait de temps.");
				}
			} else {
				string tmp = Setting_StringNoCurrentMap;

				Twitch::SendMessage(tmp);
				// Twitch::SendMessage("❌ Je ne joue actuellement sur aucune map.");
			}
		}  else if (msg.m_text == prefix+Setting_ChatCommandURL && Setting_LinkCommand) {
			auto currentMap = GetCurrentMap();
			if (currentMap !is null) {
				string UIDMap = currentMap.MapInfo.MapUid;

				string tmp = Setting_StringCurrentURL;
				tmp = Replace("\\{url\\}", "https://trackmania.io/#/leaderboard/"+UIDMap, tmp);

				Twitch::SendMessage(tmp);
				// Twitch::SendMessage("⏩ Lien de la map: https://trackmania.io/#/leaderboard/"+UIDMap);
			} else {
				string tmp = Setting_StringNoCurrentMap;

				Twitch::SendMessage(tmp);
				// Twitch::SendMessage("❌ Je ne joue actuellement sur aucune map.");
			}
		} 
	}

	void OnMessage(IRC::Message@ msg)
	{
		auto newMessage = ChatMessage();

		newMessage.m_text = msg.m_params[1];

		newMessage.m_username = msg.m_prefix.m_origin;

		if(Setting_ChatCommandPrefix != ""){
			if (newMessage.m_text.StartsWith(Setting_ChatCommandPrefix)) {
				HandleCommand(Setting_ChatCommandPrefix, newMessage);
			}
			// if (newMessage.m_text.StartsWith("!")) {
			// 	HandleCommand(newMessage);
			// }
		}

		print("Twitch chat: " + newMessage.m_username + ": " + newMessage.m_text);
	}
}

ChatCallbacks@ g_chatCallbacks;

void Main()
{
	@g_app = cast<CTrackMania>(GetApp());
	
	if (Setting_TwitchToken == "") {
		print("No Twitch token set. Set one in the settings and reload scripts!");
		return;
	}

	if (Setting_TwitchNickname == "") {
		print("No Twitch nickname set. Set one in the settings and reload scripts!");
		return;
	}

	if (Setting_TwitchChannel == "") {
		print("No Twitch channel set. Set one in the settings and reload scripts!");
		return;
	}

	@g_chatCallbacks = ChatCallbacks();

	print("Connecting to Twitch chat...");

	if (!Twitch::Connect(g_chatCallbacks)) {
		return;
	}

	print("Connected to Twitch chat!");

	Twitch::Login(Setting_TwitchToken, Setting_TwitchNickname, Setting_TwitchChannel);

	while (true) {
		Twitch::Update();
		yield();
	}
}