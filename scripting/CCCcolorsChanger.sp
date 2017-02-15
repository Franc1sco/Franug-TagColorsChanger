#pragma semicolon 1
#include <sourcemod>
#include <sdktools>

#include <ccc>
#include <clientprefs>

#define PLUGIN "1.1"

#define MAX_SPRAYS 60

new String:path_decals[PLATFORM_MAX_PATH];
Handle sColor1 = INVALID_HANDLE;
Handle sColor2 = INVALID_HANDLE;
Handle sColor3 = INVALID_HANDLE;

new String:colors[3][MAXPLAYERS+1][64];

enum Listado
{
	String:Nombre[32],
	String:color[32]
}

new g_sprays[MAX_SPRAYS][Listado];
new g_sprayCount = 0;

public Plugin:myinfo =
{
	name = "SM CCC Colors Changer",
	author = "Franc1sco franug",
	description = "",
	version = PLUGIN,
	url = "http://steamcommunity.com/id/franug"
};

public OnPluginStart()
{
	RegConsoleCmd("sm_colors", mainmenu);
	
	sColor1 = RegClientCookie("sColor1", "", CookieAccess_Protected);
	sColor2 = RegClientCookie("sColor2", "", CookieAccess_Protected);
	sColor3 = RegClientCookie("sColor3", "", CookieAccess_Protected);
}

public OnMapStart()
{
	BuildPath(Path_SM, path_decals, sizeof(path_decals), "configs/franug_tagcolors.cfg");
	ReadDecals();
}

public OnClientCookiesCached(client)
{
	GetClientCookie(client, sColor1, colors[0][client], 64); 
	GetClientCookie(client, sColor2, colors[1][client], 64); 
	GetClientCookie(client, sColor3, colors[2][client], 64); 
	
	
	if(strlen(colors[0][client]) > 1 || strlen(colors[1][client]) > 1 || strlen(colors[2][client]) > 1)
	{
		CreateTimer(5.0, Timer_Advertise,GetClientUserId(client));
	}
}

public Action:Timer_Advertise(Handle:timer, any:userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0 || !IsClientInGame(client))return;
	
	if(strlen(colors[0][client]) > 1) CCC_SetColorString(client, CCC_TagColor, colors[0][client]);
	if(strlen(colors[1][client]) > 1) CCC_SetColorString(client, CCC_ChatColor, colors[1][client]);
	if(strlen(colors[2][client]) > 1) CCC_SetColorString(client, CCC_NameColor, colors[2][client]);
}

public Action:mainmenu(client, args)
{
	new Handle:menu = CreateMenu(DIDMenuHandler3);
	SetMenuTitle(menu, "Choose your Tag Color");
	AddMenuItem(menu, "0", "Tag Colors");
	AddMenuItem(menu, "1", "Text Colors");
	AddMenuItem(menu, "2", "Name Colors");
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 0);	
}

public DIDMenuHandler3(Handle:menu, MenuAction:action, client, itemNum) 
{
	if ( action == MenuAction_Select ) 
	{
		decl String:info[4];
		
		GetMenuItem(menu, itemNum, info, sizeof(info));
		int g_color = StringToInt(info);
		
		if(g_color == 0)
		{
			colors3(client, 0);
		}
		if(g_color == 1)
		{
			colors1(client, 0);
		}
		if(g_color == 2)
		{
			colors2(client, 0);
		}
		
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

public Action:colors3(client, args)
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
		int g_color = StringToInt(info);
		
		if(g_color == 0) 
		{
			SetClientCookie(client, sColor1, "");
			CCC_ResetColor(client, CCC_TagColor);
		}
		else 
		{
			SetClientCookie(client, sColor1, g_sprays[g_color][color]);
			CCC_SetColorString(client, CCC_TagColor, g_sprays[g_color][color]);
		}
		
		PrintToChat(client, " \x01You have choosen\x03 %s \x01as your tag color!",g_sprays[g_color][Nombre]);
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

public Action:colors1(client, args)
{	
	new Handle:menu = CreateMenu(DIDMenuHandler1);
	SetMenuTitle(menu, "Choose your Chat Color");
	decl String:item[4];
	AddMenuItem(menu, "0", "Default color");
	for (new i=1; i<g_sprayCount; ++i) {
		Format(item, 4, "%i", i);
		AddMenuItem(menu, item, g_sprays[i][Nombre]);
	}
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 0);
}

public DIDMenuHandler1(Handle:menu, MenuAction:action, client, itemNum) 
{
	if ( action == MenuAction_Select ) 
	{
		decl String:info[4];
		
		GetMenuItem(menu, itemNum, info, sizeof(info));
		int g_color = StringToInt(info);
		
		if(g_color == 0)
		{
			SetClientCookie(client, sColor2, "");
			CCC_ResetColor(client, CCC_ChatColor);
		}
		else 
		{
			SetClientCookie(client, sColor2, g_sprays[g_color][color]);
			CCC_SetColorString(client, CCC_ChatColor, g_sprays[g_color][color]);
		}
		PrintToChat(client, " \x01You have choosen\x03 %s \x01as your chat color!",g_sprays[g_color][Nombre]);
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

public Action:colors2(client, args)
{	
	new Handle:menu = CreateMenu(DIDMenuHandler2);
	SetMenuTitle(menu, "Choose your Name Color");
	decl String:item[4];
	AddMenuItem(menu, "0", "Default color");
	for (new i=1; i<g_sprayCount; ++i) {
		Format(item, 4, "%i", i);
		AddMenuItem(menu, item, g_sprays[i][Nombre]);
	}
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 0);
}

public DIDMenuHandler2(Handle:menu, MenuAction:action, client, itemNum) 
{
	if ( action == MenuAction_Select ) 
	{
		decl String:info[4];
		
		GetMenuItem(menu, itemNum, info, sizeof(info));
		int g_color = StringToInt(info);
		
		if(g_color == 0)
		{
			SetClientCookie(client, sColor3, "");
			CCC_ResetColor(client, CCC_NameColor);
		}
		else
		{
			SetClientCookie(client, sColor3, g_sprays[g_color][color]);
			CCC_SetColorString(client, CCC_NameColor, g_sprays[g_color][color]);
		}
		PrintToChat(client, " \x01You have choosen\x03 %s \x01as your name color!",g_sprays[g_color][Nombre]);
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