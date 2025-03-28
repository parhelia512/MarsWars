{$IFDEF _FULLGAME}

function InitVideo:boolean;
begin
   InitVideo:=false;

   if(SDL_Init(SDL_INIT_VIDEO)<>0)then begin WriteSDLError; exit; end;

   NEW(r_RECT);

   SDL_putenv('SDL_VIDEO_WINDOW_POS');
   SDL_putenv('SDL_VIDEO_CENTERED=1');
   SDL_ShowCursor(0);
   SDL_enableUNICODE(1);

   SDL_WM_SetCaption(@str_wcaption[1], nil );

   gfx_InitColors;
   draw_set_FontSize1(10);
   vid_MakeScreen;
   gfx_LoadGraphics(true);

   InitVideo:=true;
end;

procedure StartParams;
var t,i:integer;
    s:string;
begin
   t:=ParamCount;
   for i:=1 to t do
   begin
      s:=ParamStr(i);

      if(s='test' )then test_mode:=1;
      {$IFDEF DTEST}
      if(s='testD')then test_mode:=2;
      {$ENDIF}
   end;
end;

{$ELSE}

procedure StartParams;
var t:integer;
begin
   t:=ParamCount;
   net_port:=10666;
   if(t>0)then
   begin
      net_port:=s2w(ParamStr(1));
      if(net_port=0)then net_port:=10666;
   end;
end;

{$ENDIF}



procedure InitGame;
begin
   GameCycle:=false;

   fr_init;

   StartParams;
   randomize;

   GameObjectsInit;
   InitGamePresets;

   {$IFDEF _FULLGAME}

   cfg_read;

   if not(InitVideo)then exit;
   if not(InitSound)then exit;

   DrawLoadingScreen(str_loading_ini,c_red);

   saveload_MakeSaveData;
   replay_MakeReplayHeaderData;
   menu_ReBuild;
   InitRX2Y;
   language_ENG;
   language_Switch;
   InitUIDDataCL;
   missile_InitCLData;
   MakeUnitIcons;
   FillChar(ui_dPlayer,SizeOf(ui_dPlayer),0);

   {$ENDIF}

   if not(InitNET)then exit;

   Map_randommap;
   GameDefaultAll;

   NEW(sys_EVENT);

   GameCycle:=true;

   {$IFNDEF _FULLGAME}
   Dedicated_Init;
   {$ELSE}
   campaings_InitData;
   {$ENDIF}
end;
