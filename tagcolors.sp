#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <clientprefs>
#include <ccc>

#define PLUGIN "1.0"

#define MAX_SPRAYS 60

new g_sprayElegido[MAXPLAYERS + 1];
new String:path_decals[PLATFORM_MAX_PATH];

new Handle:c_GameSprays = INVALID_HANDLE;

enum Listado
{
	String:Nombre[32],
	String:color[32]
}

new g_sprays[MAX_SPRAYS][Listado];
new g_sprayCount = 0;

public Plugin:myinfo =
{
	name = "SM Tag Colors",
	author = "Franc1sco franug",
	description = "",
	version = PLUGIN,
	url = "http://steamcommunity.com/id/franug"
};

public OnPluginStart()
{
	RegConsoleCmd("sm_colors", colors);
}

public OnPluginEnd()
{
	for(new client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			OnClientDisconnect(client);
		}
	}
}

public OnClientCookiesCached(client)
{
	new String:SprayString[12];
	GetClientCookie(client, c_GameSprays, SprayString, sizeof(SprayString));
	g_sprayElegido[client]  = StringToInt(SprayString);
}

public OnClientDisconnect(client)
{
	if(AreClientCookiesCached(client))
	{
		new String:SprayString[12];
		Format(SprayString, sizeof(SprayString), "%i", g_sprayElegido[client]);
		SetClientCookie(client, c_GameSprays, SprayString);
	}
}

public OnMapStart()
{
	BuildPath(Path_SM, path_decals, sizeof(path_decals), "configs/franug_tagcolors.cfg");
	ReadDecals();
}

public Action:colors(client, args)
{	
	new Handle:menu = CreateMenu(DIDMenuHandler);
	SetMenuTitle(menu, "Choose your Tag Color");
	decl String:item[4];
	AddMenuItem(menu, "0", "Default color");
	for (new i=1; i<g_sprayCount; ++i) {
		Format(item, 4, "%i", i);
		AddMenuItem(menu, item, g_sprays[i][Nombre]);
	}
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 0);
}

public DIDMenuHandler(Handle:menu, MenuAction:action, client, itemNum) 
{
	if ( action == MenuAction_Select ) 
	{
		decl String:info[4];
		
		GetMenuItem(menu, itemNum, info, sizeof(info));
		g_sprayElegido[client] = StringToInt(info);
		
		if(g_sprayElegido[client] == 0) CCC_ResetColor(client, CCC_TagColor);
		else CCC_SetColor(client, CCC_TagColor, g_sprays[g_sprayElegido[client]][color], false);
		
		PrintToChat(client, " \x01You have choosen\x03 %s \x01as your tag color!",g_sprays[g_sprayElegido[client]][Nombre]);
	}
	else if (action == MenuAction_Cancel) 
	{ 
		PrintToServer("Client %d's menu was cancelled.  Reason: %d", client, itemNum); 
	} 
		
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

ReadDecals() {

	decl Handle:kv;
	g_sprayCount = 1;
	

	kv = CreateKeyValues("Colors");
	FileToKeyValues(kv, path_decals);

	if (!KvGotoFirstSubKey(kv)) {

		SetFailState("CFG File not found: %s", path_decals);
		CloseHandle(kv);
	}
	do {

		KvGetSectionName(kv, g_sprays[g_sprayCount][Nombre], 32);

		KvGetString(kv, "color", g_sprays[g_sprayCount][color], 32);
		
		g_sprayCount++;
	} while (KvGotoNextKey(kv));
	CloseHandle(kv);
	
	for (new i=g_sprayCount; i<MAX_SPRAYS; ++i) 
	{
		g_sprays[i][color] = 0;
	}
}