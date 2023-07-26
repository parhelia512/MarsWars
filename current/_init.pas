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

   _GfxColors;
   _MakeScreen;
   _LoadingScreen(c_yellow);
   _LoadGraphics(true);
   _LoadingScreen(c_aqua);
   _cmp_Init;

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

      if(s='test' )then TestMode:=1;
      if(s='testD')then TestMode:=2;
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

   {$IFDEF _FULLGAME}

   cfg_read;

   saveload_CalcSaveSize;
   replay_CalcHeaderSize;

   if not(InitVideo)then exit;
   if not(InitSound)then exit;

   InitRX2Y;
   lng_eng;
   SwitchLanguage;
   InitUIDDataCL;
   InitMIDDataCL;
   MakeUnitIcons;

   {$ENDIF}

   if not(InitNET)then exit;

   Map_randommap;
   GameDefaultAll;

   NEW(_event);

   GameCycle:=true;

   {$IFNDEF _FULLGAME}
   Dedicated_Init;
   {$ENDIF}
end;
