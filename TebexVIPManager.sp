#include <sourcemod>
#include <ripext>

#pragma newdecls required
#pragma semicolon 1

HTTPClient g_TebexAPI;

public Plugin myinfo = 
{
	name = "",
	author = "Natanel 'LuqS'",
	description = "",
	version = "1.0.0",
	url = "https://steamcommunity.com/id/luqsgood || Discord: LuqS#6505"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    if (GetEngineVersion() != Engine_CSGO)
    {
        strcopy(error, err_max, "This plugin was made for use with CS:GO only.");
        return APLRes_Failure;
    }
    
    return APLRes_Success;
}

public void OnPluginStart()
{
	 g_TebexAPI = new HTTPClient("https://plugin.tebex.io/");
	 
	 // Set secret.
	 g_TebexAPI.SetHeader("X-Tebex-Secret", ">>>>>>>>>>>>>>>>>YOURAPIKEYGOESHERE<<<<<<<<<<<<<<<<<<");
}

public void OnClientAuthorized(int client, const char[] auth)
{
	if (IsFakeClient(client))
	{
		return;
	}
	
	char endpoint[255];
	
	if (!GetClientAuthId(client, AuthId_SteamID64, endpoint, sizeof(endpoint)))
	{
		LogError("Failed to get %N steamid.", client);
		return;
	}
	
	Format(endpoint, sizeof(endpoint), "player/%s/packages", endpoint);
	
	g_TebexAPI.Get(endpoint, TebexAPI_ClientPackagesResponse, GetClientUserId(client));
}

void TebexAPI_ClientPackagesResponse(HTTPResponse response, any value, const char[] error)
{
	if (error[0] || response.Status != HTTPStatus_OK)
	{
		LogError("[TebexAPI_ClientPackagesResponse] Error: %s (response: %d)", error, response);
		return;
	}

	int client = GetClientOfUserId(value);
	if (!client)
	{
		return;
	}

	JSONArray packages_arr = view_as<JSONArray>(response.Data);
	
	if (packages_arr.Length)
	{
		AddUserFlags(client, Admin_Custom1);
	}
}