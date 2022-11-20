program T3D_RTS;

{$DEFINE _FULLGAME}
//{$UNDEF _FULLGAME}

{$IFDEF _FULLGAME}   // FULL GAME
  {$APPTYPE CONSOLE}
  //{$APPTYPE GUI}
{$ELSE}              // DED SERVER
  {$APPTYPE CONSOLE}
{$ENDIF}

uses SysUtils, SDL, SDL_Net
{$IFDEF _FULLGAME}
,crt, SDL_Image, SDL_Gfx, openal, _sound_OGGLoader;
{$ELSE}
,crt;
{$ENDIF}


{$include _const.pas}
{$include _type.pas}
{$include _var.pas}

{$include _common.pas}
     {$IFDEF _FULLGAME}
        {$include _sounds.pas}
     {$ENDIF}
{$include _net_com.pas}
{$include _units_uid.pas}
     {$IFDEF _FULLGAME}
        {$include _units_cl.pas}
        {$include _lang.pas}
        {$include _config.pas}
        {$include _units_spr.pas}
        {$include _draw_com.pas}
        {$include _draw_menu.pas}
        {$include _draw_ui.pas}
        {$include _draw_game.pas}
        {$include _draw_objs_units.pas}
        {$include _draw_objs_map.pas}
        {$include _effects.pas}
        {$include _draw.pas}
        {$include _loadgfx.pas}
     {$ENDIF}
{$include _path.pas}
{$include _map.pas}
{$Include _missiles.pas}
{$include _units_common.pas}
{$include _units.pas}
{$include _ai.pas}
{$include _unit_client.pas}
     {$IFDEF _FULLGAME}
        {$include _campaings.pas}
     {$ENDIF}
{$include _game.pas}
     {$IFDEF _FULLGAME}
        {$Include _saveload.pas}
        {$include _menu.pas}
        {$include _input.pas}
     {$ENDIF}
{$include _init.pas}

{$R *.res}

{var __i,__u : cardinal;
function cf2(c:pcardinal;f:cardinal):boolean;  // check flag
 begin cf2:=(c^ and f)>0;end;
function cf3(c,f:cardinal):boolean;  // check flag
 begin cf3:=(c and f)>0;end;  }

begin
  { ///
   readln;
   writeln('start');

   delay(1000);

   for __u:=1 to 10 do
   begin
      fps_cs:=SDL_GetTicks;

      for __i:=0 to 100000000 do
       // if((__i and ureq_energy)>0)then continue;
       //if(cf2(@__i,ureq_energy))then continue;
       //if(cf3(__i,ureq_energy))then continue; 380-390
       if(cf(@__i,@ureq_energy))then continue; 360

      fps_cs:=SDL_GetTicks-fps_cs;

      writeln(fps_cs);
   end;

   readln;
   halt;  }

   InitGame;

   while (_CYCLE) do
   begin
      fps_cs:=SDL_GetTicks;

      {$IFDEF _FULLGAME}
      InputGame;
      CodeGame;
      if(r_draw)then DrawGame;
      {$ELSE}
      while (SDL_PollEvent(_EVENT)>0) do
       CASE (_EVENT^.type_) OF
       SDL_QUITEV  : break;
       end;
      CodeGame;
      {$ENDIF}

      fps_ns:=SDL_GetTicks-fps_cs;
      {$IFDEF _FULLGAME}
      if(_fsttime)
      then continue
      else
      {$ENDIF}
        if(fps_ns>=fr_mpt)
        then fps_tt:=1
        else fps_tt:=fr_mpt-fps_ns;

      SDL_Delay(fps_tt);
   end;

   {$IFDEF _FULLGAME}
   net_disconnect;
   cfg_write;
   {$ENDIF}
end.

