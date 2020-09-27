#include <sourcemod>
#include <sdktools>
#include <basecomm>

#pragma semicolon 1
#pragma newdecls required

public Plugin MyInfo = { 
	name = "Info after death", 
	author = "-_- (Karol Skupień)", 
	description = "Info after death",
	version = "1.0", 
	url = "https://github.com/Qesik" 
};

ConVar g_cTime;
ConVar g_cAllowMuted;

public void OnPluginStart(/*void*/) {
	LoadTranslations("t_infoafterdeath.phrases");
	g_cTime = CreateConVar("iad_time", "5.0", "Time until muted", _, true, 0.5, true, 20.0);
	g_cAllowMuted = CreateConVar("iad_allow_muted", "0", "Allow muted players?", _, true, 0.0, true, 1.0);
	AutoExecConfig(true, "InfoAfterDeath");

	HookEvent("player_death", ev_PlayerDeath);
}
/*
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*/
public Action ev_PlayerDeath(Event eEvent, const char[] sName, bool bDontBroadcast) {
	int iVictim = GetClientOfUserId(eEvent.GetInt("userid"));
	if ( !IsValidClient(iVictim) )
		return Plugin_Continue;

	if ( !g_cAllowMuted.BoolValue && BaseComm_IsClientMuted(iVictim) )
		return Plugin_Continue;

	SetClientListeningFlags(iVictim, VOICE_TEAM);
	CreateTimer(g_cTime.FloatValue, Timer_Muted, GetClientUserId(iVictim), TIMER_FLAG_NO_MAPCHANGE);
	PrintToChat(iVictim, "%T", "c_death_info", iVictim, g_cTime.FloatValue);
	return Plugin_Continue;
}

public Action Timer_Muted(Handle hTimer, const int iClientID) {
	int iClient = GetClientOfUserId(iClientID);
	if ( !IsValidClient(iClient) )
		return Plugin_Continue;
		
	SetClientListeningFlags(iClient, (BaseComm_IsClientMuted(iClient)) ? VOICE_MUTED : VOICE_NORMAL);
	return Plugin_Continue;
}
/*
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*/
bool IsValidClient(int iClient) {
	return iClient > 0 && iClient <= MaxClients && IsClientConnected(iClient) && IsClientInGame(iClient) && !IsFakeClient(iClient);
}