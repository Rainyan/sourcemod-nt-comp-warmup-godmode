#pragma semicolon 1

#include <sourcemod>

#include <nt_competitive_natives>

#define PLUGIN_VERSION "0.1.1"

static bool is_godmode_enabled = false;

public Plugin myinfo = {
	name = "NT Comp Warmup God Mode",
	description = "Make players invulnerable when a competitive game isn't live, or is paused.",
	author = "Rain",
	version = PLUGIN_VERSION,
	url = "https://github.com/Rainyan/sourcemod-nt-comp-warmup-godmode"
};

public void OnPluginStart()
{
	if (!HookEventEx("player_spawn", Event_PlayerSpawn, EventHookMode_Post))
	{
		SetFailState("Failed to hook event");
	}

	Timer_CheckIfLive(INVALID_HANDLE);
	SetGodModeAll();
	CreateTimer(5.0, Timer_CheckIfLive, _, TIMER_REPEAT);
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (client != 0)
	{
		// Godmode flag gets reset on (re)spawn, so re-apply it here
		SetGodMode(client);
	}
}

public Action Timer_CheckIfLive(Handle timer)
{
	bool should_enable_godmode = (!Competitive_IsLive()) || Competitive_IsPaused();

	// If state hasn't changed, we don't need to do this
	if (is_godmode_enabled != should_enable_godmode)
	{
		is_godmode_enabled = should_enable_godmode;
		SetGodModeAll();
	}

	return Plugin_Continue;
}

void SetGodMode(int client)
{
	if (is_godmode_enabled)
	{
		SetEntityFlags(client, GetEntityFlags(client) | FL_GODMODE);
	}
	else
	{
		SetEntityFlags(client, GetEntityFlags(client) & ~FL_GODMODE);
	}
}

void SetGodModeAll()
{
	for (int client = 1; client <= MaxClients; ++client)
	{
		if (IsClientInGame(client))
		{
			SetGodMode(client);
		}
	}
}