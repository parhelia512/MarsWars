
function l2s(limit:longint):shortstring; // limit 2 string
var fr:integer;
begin
   fr:=limit mod MinUnitLimit;
   case fr of
   0  : l2s:=i2s(limit div MinUnitLimit);
   50 : l2s:=i2s(limit div MinUnitLimit)+'.5';
   25 : l2s:=i2s(limit div MinUnitLimit)+'.25';
   75 : l2s:=i2s(limit div MinUnitLimit)+'.75';
   else l2s:=i2s(limit div MinUnitLimit)+'.'+i2s(fr);
   end;
end;

function GetKeyName(k:cardinal):shortstring;
begin
   case k of
SDL_BUTTON_left     : GetKeyName:='Mouse left button';
SDL_BUTTON_right    : GetKeyName:='Mouse right button';
SDL_BUTTON_middle   : GetKeyName:='Mouse middle button';
SDL_BUTTON_WHEELUP  : GetKeyName:='Mouse wheel up';
SDL_BUTTON_WHEELDOWN: GetKeyName:='Mouse wheel down';
SDLK_LCtrl,
SDLK_RCtrl          : GetKeyName:='Ctrl';
SDLK_LAlt,
SDLK_RAlt           : GetKeyName:='Alt';
SDLK_LShift,
SDLK_RShift         : GetKeyName:='Shift';
   else GetKeyName  :=UpperCase(SDL_GetKeyName(k));
   end
end;



function _gHK(ucl:byte):shortstring;  // hotkey units&upgrades tab
begin
   _gHK:='';
   if(ucl<=_mhkeys)then
    if(_hotkey1[ucl]>0)then
    begin
       if(_hotkey2[ucl]>0)then
       _gHK:=     tc_lime+GetKeyName(_hotkey2[ucl])+tc_default+'+';
       _gHK:=_gHK+tc_lime+GetKeyName(_hotkey1[ucl])+tc_default;
    end;
end;

function _gHKA(ucl:byte):shortstring;  // hotkey actions tab
begin
   _gHKA:='';
   if(ucl<=_mhkeys)then
    if(_hotkeyA[ucl]>0)then
    begin
       if(_hotkeyA2[ucl]>0)then
       _gHKA:=      tc_lime+GetKeyName(_hotkeyA2[ucl])+tc_default+'+';
       _gHKA:=_gHKA+tc_lime+GetKeyName(_hotkeyA [ucl])+tc_default;
    end;
end;
function _gHKR(ucl:byte):shortstring;  // hotkey replays tab
begin
   _gHKR:='';
   if(ucl<=_mhkeys)then
    if(_hotkeyR[ucl]>0)then
     _gHKR:=tc_lime+GetKeyName(_hotkeyR [ucl])+tc_default;
end;

procedure _mkHStrACT(ucl:byte;hint:shortstring);
var hk:shortstring;
begin
   if(ucl<=_mhkeys)then
   begin
      hk:=_gHKA(ucl);
      if(length(hk)>0)
      then str_hint_a[ucl]:=hint+' ('+hk+')'
      else str_hint_a[ucl]:=hint;
   end;
end;

procedure _mkHStrREQ(ucl:byte;hint:shortstring;noHK:boolean);
var hk:shortstring;
begin
   if(ucl<=_mhkeys)then
   begin
      if(noHK)
      then hk:=''
      else hk:=_gHKR(ucl);
      if(length(hk)>0)
      then str_hint_r[ucl]:=hint+' ('+hk+')'
      else str_hint_r[ucl]:=hint;
   end;
end;

procedure _mkHStrUid(uid:byte;NAME,DESCR:shortstring);
begin
   with _uids[uid] do
   begin
      un_txt_name  :=NAME;
      un_txt_udescr:=DESCR;
   end;
end;

procedure _mkHStrUpid(upid:byte;NAME,DESCR:shortstring);
begin
   with _upids[upid] do
   begin
      _up_name :=NAME;
      _up_descr:=DESCR;
   end;
end;

procedure _ADDSTRC(s:pshortstring;ad:shortstring);
begin
   if(length(s^)=0)
   then s^:=ad
   else s^:=s^+',' +ad;
end;
procedure _ADDSTRD(s:pshortstring;ad:shortstring);
begin
   if(length(s^)=0)
   then s^:=ad
   else s^:=s^+'. ' +ad;
end;
procedure _ADDSTRS(s:pshortstring;ad:shortstring);
begin
   if(length(s^)=0)
   then s^:=ad
   else s^:=s^+'/' +ad;
end;


function findprd(uid:byte):shortstring;
var i:byte;
   up,
   bp: shortstring;
begin
   up:='';
   bp:='';
   findprd:='';
   for i:=0 to 255 do
   begin
      if(uid in _uids[i].ups_units  )then _ADDSTRC(@up,_uids[i].un_txt_name);
      if(uid in _uids[i].ups_builder)then _ADDSTRC(@bp,_uids[i].un_txt_name);
   end;

   if(length(up)>0)then _ADDSTRC(@findprd,up);
   if(length(bp)>0)then _ADDSTRC(@findprd,bp);
end;

function _makeAttributeStr(pu:PTUnit;auid:byte):shortstring;
begin
   if(pu=nil)then
   begin
      pu:=@_units[0];
      with pu^ do
      begin
         uidi:=auid;
         playeri:=0;
         player :=@_players[playeri];
      end;
      _unit_apUID(pu);
   end;
   _makeAttributeStr:='';
   with pu^  do
   with uid^ do
   begin
      if(uidi in T2)
      then _ADDSTRC(@_makeAttributeStr,'T2')
      else
      if(uidi in T3)
      then _ADDSTRC(@_makeAttributeStr,'T3')
      else _ADDSTRC(@_makeAttributeStr,'T1');

      if(_ukbuilding)
      then _ADDSTRC(@_makeAttributeStr,str_attr_building)
      else _ADDSTRC(@_makeAttributeStr,str_attr_unit    );
      if(_ukmech)
      then _ADDSTRC(@_makeAttributeStr,str_attr_mech    )
      else _ADDSTRC(@_makeAttributeStr,str_attr_bio     );
      if(_uklight)
      then _ADDSTRC(@_makeAttributeStr,str_attr_light   )
      else _ADDSTRC(@_makeAttributeStr,str_attr_nlight  );
      if(ukfly)
      then _ADDSTRC(@_makeAttributeStr,str_attr_fly     )
      else
        if(ukfloater)
        then _ADDSTRC(@_makeAttributeStr,str_attr_floater)
        else _ADDSTRC(@_makeAttributeStr,str_attr_ground );
      if(level>0)
      then _ADDSTRC(@_makeAttributeStr,str_attr_level+b2s(level+1));
      if(buff[ub_Detect]>0)
      then _ADDSTRC(@_makeAttributeStr,str_attr_detector);
      if(buff[ub_Invuln]>0)
      then _ADDSTRC(@_makeAttributeStr,str_attr_invuln)
      else
        if(buff[ub_Pain]>0)
        then _ADDSTRC(@_makeAttributeStr,str_attr_stuned);

      _makeAttributeStr:='['+_makeAttributeStr+']';
   end;
end;

function _MakeDefaultDescription(uid:byte;basedesc:shortstring):shortstring;
begin
   _MakeDefaultDescription:=basedesc;
    with _uids[uid] do
    begin
       if(_isbuilder    )then _ADDSTRD(@_MakeDefaultDescription,str_Builder);
       if(_isbarrack    )then _ADDSTRD(@_MakeDefaultDescription,str_Barrack);
       if(_issmith      )then _ADDSTRD(@_MakeDefaultDescription,str_Smith  );
       if(_genergy    >0)then _ADDSTRD(@_MakeDefaultDescription,str_IncEnergyLevel+' (+'+i2s(_genergy)+')');
       if(_rebuild_uid>0)then
        if(_rebuild_level=0)
        then _ADDSTRD(@_MakeDefaultDescription,str_CanRebuildTo+_uids[_rebuild_uid].un_txt_name)
        else _ADDSTRD(@_MakeDefaultDescription,str_CanRebuildTo+_uids[_rebuild_uid].un_txt_name+'('+str_attr_level+b2s(_rebuild_level+1)+')');

       if(length(_MakeDefaultDescription)>0)then _MakeDefaultDescription+='.';
    end;
end;

function _makeUpgrBaseHint(upid,curlvl:byte):shortstring;
var HK,
    ENRG,
    TIME,
    INFO:shortstring;
   l:byte;
begin
  with _upids[upid] do
  begin
     HK  :=_gHK(_up_btni);
     ENRG:='';
     TIME:='';
     INFO:='';

     if(curlvl>_up_max)then curlvl:=_up_max;

     HK:=_gHK(_up_btni);
     if(_up_renerg>0)then
       if(_up_max>1)and(not _up_mfrg)
       then ENRG:=tc_aqua+i2s(_upid_energy(upid,curlvl))+tc_default
       else ENRG:=tc_aqua+i2s(_upid_energy(upid,1     ))+tc_default;
     if(_up_time  >0)then
       if(_up_max>1)and(not _up_mfrg)
       then TIME:=tc_white+i2s(_upid_time(upid,curlvl) div fr_fps1)+tc_default
       else TIME:=tc_white+i2s(_upid_time(upid,1     ) div fr_fps1)+tc_default;

     if(length(HK  )>0)then _ADDSTRC(@INFO,HK  );
     if(length(ENRG)>0)then _ADDSTRC(@INFO,ENRG);
     if(length(TIME)>0)then _ADDSTRC(@INFO,TIME);
     _ADDSTRC(@INFO,tc_orange+'x'+i2s(_up_max)+tc_default);
     if(_up_max>1)and(_up_mfrg)then _ADDSTRC(@INFO,tc_red+'*'+tc_default);

     _makeUpgrBaseHint:=_up_name+' ('+INFO+')'+tc_nl1+_up_descr;
  end;
end;

procedure _makeHints;
var
uid         :byte;
ENRG,HK,PROD,LMT,INFO,
TIME,REQ    :shortstring;
begin
   // units
   for uid:=0 to 255 do
   with _uids[uid] do
   begin
      REQ :='';
      PROD:='';
      ENRG:='';
      TIME:='';
      LMT :='';
      INFO:='';

      if(_ucl>=23)then
      begin
         un_txt_uihint1:=un_txt_name+tc_nl1+un_txt_fdescr+tc_nl1;
         un_txt_uihint2:='';
      end
      else
      begin
         HK:=_gHK(_ucl);
         if(_renergy>0)then ENRG:=tc_aqua +i2s(_renergy)+tc_default;
         if(_btime  >0)then TIME:=tc_white+i2s(_btime  )+tc_default;
         LMT:=tc_orange+l2s(_limituse)+tc_default;

         PROD:=findprd(uid);
         if(_ruid1>0)then if(_ruid1n<=1)then _ADDSTRC(@REQ,_uids [_ruid1].un_txt_name) else _ADDSTRC(@REQ,_uids [_ruid1].un_txt_name+'(x'+b2s(_ruid1n)+')');
         if(_ruid2>0)then if(_ruid2n<=1)then _ADDSTRC(@REQ,_uids [_ruid2].un_txt_name) else _ADDSTRC(@REQ,_uids [_ruid2].un_txt_name+'(x'+b2s(_ruid2n)+')');
         if(_ruid3>0)then if(_ruid3n<=1)then _ADDSTRC(@REQ,_uids [_ruid3].un_txt_name) else _ADDSTRC(@REQ,_uids [_ruid3].un_txt_name+'(x'+b2s(_ruid3n)+')');
         if(_rupgr>0)then if(_rupgrl<=1)then _ADDSTRC(@REQ,_upids[_rupgr]._up_name   ) else _ADDSTRC(@REQ,_upids[_rupgr]._up_name   +'(x'+b2s(_rupgrl)+')');

         if(length(HK  )>0)then _ADDSTRC(@INFO,HK  );
         if(length(ENRG)>0)then _ADDSTRC(@INFO,ENRG);
         if(length(LMT )>0)then _ADDSTRC(@INFO,LMT );
         if(length(TIME)>0)then _ADDSTRC(@INFO,TIME);

         un_txt_fdescr:=_MakeDefaultDescription(uid,un_txt_udescr);

         un_txt_uihint1:=un_txt_name+' ('+INFO+')'+tc_nl1+_makeAttributeStr(nil,uid)+tc_nl1+un_txt_fdescr;
         un_txt_uihint2:='';
         if(length(REQ )>0)then un_txt_uihint2+=tc_yellow+str_req+tc_default+REQ+tc_nl1 else un_txt_uihint2+=tc_nl1;
         if(length(PROD)>0)then
          if(_ukbuilding)
          then un_txt_uihint2+=str_bprod+PROD
          else un_txt_uihint2+=str_uprod+PROD;
      end;
   end;

   // upgrades
   for uid:=0 to 255 do
   with _upids[uid] do
   begin
      REQ  :='';

      if(_up_ruid  >0)then _ADDSTRC(@REQ,_uids [_up_ruid ].un_txt_name);
      if(_up_rupgr >0)then _ADDSTRC(@REQ,_upids[_up_rupgr]._up_name   );

      _up_hint2:='';
      if(length(REQ)>0)then _up_hint2+=tc_yellow+str_req+tc_default+REQ;
   end;
end;

procedure lng_eng;
var t: shortstring;
begin
   str_MMap              := 'MAP';
   str_MPlayers          := 'PLAYERS';
   str_MObjectives       := 'OBJECTIVES';
   str_menu_s1[ms1_sett] := 'SETTINGS';
   str_menu_s1[ms1_svld] := 'SAVE/LOAD';
   str_menu_s1[ms1_reps] := 'REPLAYS';
   str_menu_s2[ms2_camp] := 'CAMPAIGNS';
   str_menu_s2[ms2_scir] := 'SKIRMISH';
   str_menu_s2[ms2_mult] := 'MULTIPLAYER';
   str_menu_s3[ms3_game] := 'GAME';
   str_menu_s3[ms3_vido] := 'VIDEO';
   str_menu_s3[ms3_sond] := 'SOUND';
   str_reset[false]      := 'START';
   str_reset[true ]      := 'RESET';
   str_exit[false]       := 'EXIT';
   str_exit[true]        := 'BACK';
   str_m_liq             := 'Lakes: ';
   str_m_siz             := 'Size: ';
   str_m_obs             := 'Obstacles: ';
   str_m_sym             := 'Symmetric: ';
   str_map               := 'Map';
   str_players           := 'Players';
   str_mrandom           := 'Random map';
   str_musicvol          := 'Music volume';
   str_soundvol          := 'Sound volume';
   str_scrollspd         := 'Scroll speed';
   str_mousescrl         := 'Mouse scroll';
   str_fullscreen        := 'Windowed:';
   str_plname            := 'Player name';
   str_lng[true]         := 'RUS';
   str_lng[false]        := 'ENG';
   str_maction           := 'Right click action';
   str_maction2[true ]   := tc_lime  +'move'  +tc_default;
   str_maction2[false]   := tc_lime  +'move'  +tc_default+'+'+tc_red+'attack'+tc_default;
   str_race[r_random]    := tc_white +'RANDOM'+tc_default;
   str_race[r_hell  ]    := tc_orange+'HELL'  +tc_default;
   str_race[r_uac   ]    := tc_lime  +'UAC'   +tc_default;
   str_win               := 'VICTORY!';
   str_lose              := 'DEFEAT!';
   str_gsunknown         := 'Unknown status!';
   str_pause             := 'Pause';
   str_gsaved            := 'Game saved';
   str_repend            := 'Replay ended!';
   str_save              := 'Save';
   str_load              := 'Load';
   str_delete            := 'Delete';
   str_svld_errors_file  := 'File not'+tc_nl3+'exists!';
   str_svld_errors_open  := 'Can`t open'+tc_nl3+'file!';
   str_svld_errors_wdata := 'Wrong file'+tc_nl3+'size!';
   str_svld_errors_wver  := 'Wrong version!';
   str_time              := 'Time: ';
   str_menu              := 'Menu';
   str_player_def        := ' was terminated!';
   str_inv_time          := 'Wave #';
   str_inv_ml            := 'Monsters limit: ';
   str_play              := 'Play';
   str_replay            := 'RECORD';
   str_replay_name       := 'Replay name:';
   str_cmpdif            := 'Difficulty: ';
   str_waitsv            := 'Awaiting server...';
   str_goptions          := 'GAME OPTIONS';
   str_server            := 'SERVER';
   str_client            := 'CLIENT';
   str_chat              := 'CHAT';
   str_chat_all          := 'ALL:';
   str_chat_allies       := 'ALLIES:';
   str_randoms           := 'Random skirmish';
   str_apply             := 'apply';
   str_plout             := ' left the game';
   str_aislots           := 'Fill empty slots:';
   str_resol             := 'Resolution';
   str_language          := 'UI language';
   str_req               := 'Requirements: ';
   str_orders            := 'Unit groups: ';
   str_all               := 'All';
   str_uprod             := tc_lime+'Produced by: '   +tc_default;
   str_bprod             := tc_lime+'Constructed by: '+tc_default;
   str_ColoredShadow     := 'Colored shadows';
   str_kothtime          := 'Center capture time: ';
   str_deadobservers     := 'Observer mode after lose:';

   str_Builder           := 'Builder';
   str_Barrack           := 'Unit production';
   str_Smith             := 'Researches and upgrades facility';
   str_IncEnergyLevel    := 'Increase energy level';
   str_CanRebuildTo      := 'Can be rebuilded to ';

   str_cant_build        := 'Can`t build here';
   str_need_energy       := 'Need more energy';
   str_cant_prod         := 'Can`t production this';
   str_check_reqs        := 'Check requirements';
   str_cant_execute      := 'Can`t execute order';
   str_advanced          := 'Advanced ';
   str_unit_advanced     := 'Unit promoted';
   str_upgrade_complete  := 'Upgrade complete';
   str_building_complete := 'Construction complete';
   str_unit_complete     := 'Unit ready';
   str_unit_attacked     := 'Unit is under attack';
   str_base_attacked     := 'Base is under attack';
   str_allies_attacked   := 'Our allies is under attack';
   str_maxlimit_reached  := 'Maximum army limit reached';
   str_need_more_builders:= 'Need more builders';
   str_production_busy   := 'All production is busy';
   str_cant_advanced     := 'Impassible to rebuild/advance';
   str_NeedMoreProd      := 'Nowhere to produce that';
   str_MaximumReached    := 'Maximum reached';

   str_attr_unit         := tc_gray  +'unit'        +tc_default;
   str_attr_building     := tc_red   +'building'    +tc_default;
   str_attr_mech         := tc_blue  +'mechanical'  +tc_default;
   str_attr_bio          := tc_orange+'biological'  +tc_default;
   str_attr_light        := tc_yellow+'light'       +tc_default;
   str_attr_nlight       := tc_green +'heavy'       +tc_default;
   str_attr_fly          := tc_white +'flying'      +tc_default;
   str_attr_ground       := tc_lime  +'ground'      +tc_default;
   str_attr_floater      := tc_aqua  +'floater'     +tc_default;
   str_attr_level        := tc_white +'level'       +tc_default;
   str_attr_invuln       := tc_lime  +'invulnerable'+tc_default;
   str_attr_stuned       := tc_yellow+'stuned'      +tc_default;
   str_attr_detector     := tc_purple+'detector'    +tc_default;

   str_panelpos          := 'Control panel position';
   str_panelposp[0]      := tc_lime  +'left' +tc_default;
   str_panelposp[1]      := tc_orange+'right'+tc_default;
   str_panelposp[2]      := tc_yellow+'up'   +tc_default;
   str_panelposp[3]      := tc_aqua  +'down' +tc_default;

   str_uhbar             := 'Health bars';
   str_uhbars[0]         := tc_lime  +'selected'+tc_default+'+'+tc_red+'damaged'+tc_default;
   str_uhbars[1]         := tc_aqua  +'always'  +tc_default;
   str_uhbars[2]         := tc_orange+'only '   +tc_lime+'selected'+tc_default;

   str_pcolor            := 'Players colors';
   str_pcolors[0]        := tc_white +'default'+tc_default;
   str_pcolors[1]        := tc_lime  +'own '   +tc_yellow+'ally '+tc_red+'enemy'+tc_default;
   str_pcolors[2]        := tc_white +'own '   +tc_yellow+'ally '+tc_red+'enemy'+tc_default;
   str_pcolors[3]        := tc_purple+'teams'  +tc_default;
   str_pcolors[4]        := tc_white +'own '   +tc_purple+'teams'+tc_default;

   str_starta            := 'Builders at game start:';

   str_fstarts           := 'Fixed player starts:';

   str_pnua[0]           := tc_aqua  +'x1 '+tc_default+'/'+tc_red+' x1';
   str_pnua[1]           := tc_aqua  +'x2 '+tc_default+'/'+tc_red+' x2';
   str_pnua[2]           := tc_lime  +'x3 '+tc_default+'/'+tc_orange+' x3';
   str_pnua[3]           := tc_lime  +'x4 '+tc_default+'/'+tc_orange+' x4';
   str_pnua[4]           := tc_yellow+'x5 '+tc_default+'/'+tc_yellow+' x5';
   str_pnua[5]           := tc_yellow+'x6 '+tc_default+'/'+tc_yellow+' x6';
   str_pnua[6]           := tc_orange+'x7 '+tc_default+'/'+tc_lime+' x7';
   str_pnua[7]           := tc_orange+'x8 '+tc_default+'/'+tc_lime+' x8';
   str_pnua[8]           := tc_red   +'x9 '+tc_default+'/'+tc_aqua+' x9';
   str_pnua[9]           := tc_red   +'x10'+tc_default+'/'+tc_aqua+' x10';

   str_npnua[0]          := tc_red   +'x1 ';
   str_npnua[1]          := tc_red   +'x2 ';
   str_npnua[2]          := tc_orange+'x3 ';
   str_npnua[3]          := tc_orange+'x4 ';
   str_npnua[4]          := tc_yellow+'x5 ';
   str_npnua[5]          := tc_yellow+'x6 ';
   str_npnua[6]          := tc_lime  +'x7 ';
   str_npnua[7]          := tc_lime  +'x8 ';
   str_npnua[8]          := tc_aqua  +'x9 ';
   str_npnua[9]          := tc_aqua  +'x10';

   str_cmpd[0]           := tc_blue  +'I`m too young to die'+tc_default;
   str_cmpd[1]           := tc_aqua  +'Hey, not too rough'  +tc_default;
   str_cmpd[2]           := tc_lime  +'Hurt me plenty'      +tc_default;
   str_cmpd[3]           := tc_yellow+'Ultra-Violence'      +tc_default;
   str_cmpd[4]           := tc_orange+'Unholy massacre'     +tc_default;
   str_cmpd[5]           := tc_red   +'Nightmare'           +tc_default;
   str_cmpd[6]           := tc_purple+'HELL'                +tc_default;

   str_gmodet            := 'Game mode:';
   str_gmode[gm_scirmish]:= tc_lime  +'Skirmish'        +tc_default;
   str_gmode[gm_3x3     ]:= tc_orange+'3x3'             +tc_default;
   str_gmode[gm_2x2x2   ]:= tc_yellow+'2x2x2'           +tc_default;
   str_gmode[gm_capture ]:= tc_aqua  +'Capturing points'+tc_default;
   str_gmode[gm_invasion]:= tc_blue  +'Invasion'        +tc_default;
   str_gmode[gm_KotH    ]:= tc_purple+'King of the Hill'+tc_default;
   str_gmode[gm_royale  ]:= tc_red   +'Royal Battle'    +tc_default;

   str_cgenerators       := 'Neutral generators:';
   str_cgeneratorsM[0]   := 'none';
   str_cgeneratorsM[1]   := '5 min';
   str_cgeneratorsM[2]   := '10 min';
   str_cgeneratorsM[3]   := '15 min';
   str_cgeneratorsM[4]   := '20 min';
   str_cgeneratorsM[5]   := 'infinity';

   str_team              := 'Team:';
   str_srace             := 'Race:';
   str_ready             := 'Ready: ';
   str_udpport           := 'UDP port:';
   str_svup[false]       := 'Start server';
   str_svup[true ]       := 'Stop server';
   str_connect[false]    := 'Connect';
   str_connect[true ]    := 'Disconnect';
   str_pnu               := 'File size/quality: ';
   str_npnu              := 'Units update rate: ';
   str_connecting        := 'Connecting...';
   str_sver              := 'Wrong version!';
   str_sfull             := 'Server full!';
   str_sgst              := 'Game started!';

   str_hint_t[0]         := 'Buildings';
   str_hint_t[1]         := 'Units';
   str_hint_t[2]         := 'Researches';
   str_hint_t[3]         := 'Controls';

   str_hint_army         := 'Army: ';
   str_hint_energy       := 'Energy: ';

   str_hint_m[0]         := 'Menu (' +tc_lime+'Esc'+tc_default+')';
   str_hint_m[2]         := 'Pause ('+tc_lime+'Pause/Break'+tc_default+')';


   _mkHStrUid(UID_HKeep          ,'Hell Keep'                   ,'');
   _mkHStrUid(UID_HAKeep         ,'Great Hell Keep'             ,'');
   _mkHStrUid(UID_HGate          ,'Hell Gate'                   ,'');
   _mkHStrUid(UID_HSymbol        ,'Hell Symbol'                 ,'');
   _mkHStrUid(UID_HASymbol       ,'Great Hell Symbol'           ,'');
   _mkHStrUid(UID_HPools         ,'Hell Pools'                  ,'');
   _mkHStrUid(UID_HTeleport      ,'Hell Teleport'               ,'Teleport units');
   _mkHStrUid(UID_HPentagram     ,'Hell Pentagram'              ,'');
   _mkHStrUid(UID_HMonastery     ,'Hell Monastery'              ,'');
   _mkHStrUid(UID_HFortress      ,'Hell Fortress'               ,'');
   _mkHStrUid(UID_HTower         ,'Hell Tower'                  ,'Defensive structure'            );
   _mkHStrUid(UID_HTotem         ,'Hell Totem'                  ,'Advanced defensive structure'   );
   _mkHStrUid(UID_HAltar         ,'Hell Altar'                  ,'Casts "Invulnerability" powerup');
   _mkHStrUid(UID_HCommandCenter ,'Hell Command Center'         ,'Corrupted UAC Command Center'   );
   _mkHStrUid(UID_HACommandCenter,'Advanced Hell Command Center','Corrupted UAC Advanced Command Center');
   _mkHStrUid(UID_HBarracks      ,'Hell Barracks'               ,'Corrupted UAC Barracks'         );
   _mkHStrUid(UID_HEye           ,'Hell Eye'                    ,'Passive scouting and detection' );

   _mkHStrUid(UID_LostSoul       ,'Lost Soul'                 ,'');
   _mkHStrUid(UID_Phantom        ,'Phantom'                   ,'');
   _mkHStrUid(UID_Imp            ,'Imp'                       ,'');
   _mkHStrUid(UID_Demon          ,'Pinky Demon'               ,'');
   _mkHStrUid(UID_Cacodemon      ,'Cacodemon'                 ,'');
   _mkHStrUid(UID_Knight         ,'Hell Knight'               ,'');
   _mkHStrUid(UID_Baron          ,'Baron of Hell'             ,'');
   _mkHStrUid(UID_Cyberdemon     ,'Cyberdemon'                ,'');
   _mkHStrUid(UID_Mastermind     ,'Mastermind'                ,'');
   _mkHStrUid(UID_Pain           ,'Pain Elemental'            ,'');
   _mkHStrUid(UID_Revenant       ,'Revenant'                  ,'');
   _mkHStrUid(UID_Mancubus       ,'Mancubus'                  ,'');
   _mkHStrUid(UID_Arachnotron    ,'Arachnotron'               ,'');
   _mkHStrUid(UID_Archvile       ,'ArchVile'                  ,'');
   _mkHStrUid(UID_ZFormer        ,'Former Zombie'             ,'');
   _mkHStrUid(UID_ZEngineer      ,'Zombie Engineer'           ,'');
   _mkHStrUid(UID_ZSergant       ,'Zombie Shotguner'          ,'');
   _mkHStrUid(UID_ZSSergant      ,'Zombie SuperShotguner'     ,'');
   _mkHStrUid(UID_ZCommando      ,'Zombie Commando'           ,'');
   _mkHStrUid(UID_ZAntiaircrafter,'Zombie Antiaircrafter'     ,'');
   _mkHStrUid(UID_ZSiegeMarine   ,'Zombie Siege Marine'       ,'');
   _mkHStrUid(UID_ZFPlasmagunner ,'Zombie Plasmaguner'        ,'');
   _mkHStrUid(UID_ZBFGMarine     ,'Zombie BFG Marine'         ,'');


   _mkHStrUpid(upgr_hell_t1attack  ,'Hell Firepower'                ,'Increase the damage of ranged attacks for T1 units and defensive structures.');
   _mkHStrUpid(upgr_hell_uarmor    ,'Combat Flesh'                  ,'Increase the armor of all Hell`s units.'                                 );
   _mkHStrUpid(upgr_hell_barmor    ,'Stone Walls'                   ,'Increase the armor of all Hell`s buildings.'                             );
   _mkHStrUpid(upgr_hell_mattack   ,'Claws and Teeth'               ,'Increase the damage of melee attacks.'                                   );
   _mkHStrUpid(upgr_hell_regen     ,'Flesh Regeneration'            ,'Health regeneration for all Hell`s units.'                               );
   _mkHStrUpid(upgr_hell_pains     ,'Pain Threshold'                ,'Hell units can take more hits before pain stun happen.'                  );
   _mkHStrUpid(upgr_hell_towers    ,'Tower Range Upgrade'           ,'Increase defensive structures range.'                                    );
   _mkHStrUpid(upgr_hell_HKTeleport,'Hell Keep Teleportation Charge','Charge for Hell Keep`s teleportation ability.'                           );
   _mkHStrUpid(upgr_hell_paina     ,'Decay Aura'                    ,'Hell Keep start damage all enemies around. Decay Aura`s damage ignore unit`s armor.');
   _mkHStrUpid(upgr_hell_buildr    ,'Hell Keep Range Upgrade'       ,'Increase Hell Keep`s sight range.'                                       );
   _mkHStrUpid(upgr_hell_extbuild  ,'Adaptive Foundation'           ,'All buildings, except those that can produce units, can be placed on doodads.');
   _mkHStrUpid(upgr_hell_pinkspd   ,'Pinky`s Rage'                  ,'Increase the movement speed of Pinky.'                                   );

   _mkHStrUpid(upgr_hell_spectre   ,'Spectres'                      ,'Pinky become invisible.'                                     );
   _mkHStrUpid(upgr_hell_vision    ,'Hell Sight'                    ,'Increase the sight range of all Hell`s units.'               );
   _mkHStrUpid(upgr_hell_phantoms  ,'Phantoms'                      ,'Lost Soul become Phantom.'                                   );
   _mkHStrUpid(upgr_hell_t2attack  ,'Hell Weapons'                  ,'Increase the damage of ranged attacks for T2 units and defensive structures'  );
   _mkHStrUpid(upgr_hell_teleport  ,'Teleport Upgrade'              ,'Decrease cooldown time of Hell Teleport.'                        );
   _mkHStrUpid(upgr_hell_rteleport ,'Reverse Teleporting'           ,'Units can teleport back to Hell Teleport.'                       );
   _mkHStrUpid(upgr_hell_heye      ,'Hell Eye Upgrade'              ,'Increase the sight range of Hell Eye.'                           );
   _mkHStrUpid(upgr_hell_totminv   ,'Hell Totem Invisibility'       ,'Hell Totem become invisible.'                                    );
   _mkHStrUpid(upgr_hell_bldrep    ,'Building Restoration'          ,'Health regeneration for all Hell`s buildings.'                   );
   _mkHStrUpid(upgr_hell_b478tel   ,'Tower Teleportation Charge'    ,'Charges for Hell Tower`s and Hell Totem`s short-distance teleport ability.');
   _mkHStrUpid(upgr_hell_resurrect ,'Resurrection'                  ,'ArchVile`s ability.');
   _mkHStrUpid(upgr_hell_invuln    ,'Invulnerability Sphere'        ,'Charge for Hell Altar`s ability.'      );


   _mkHStrUid(UID_UCommandCenter   ,'UAC Command Center'         ,''      );
   _mkHStrUid(UID_UACommandCenter  ,'UAC Advanced Command Center',''      );
   _mkHStrUid(UID_UBarracks        ,'UAC Barracks'               ,''      );
   _mkHStrUid(UID_UFactory         ,'UAC Factory'                ,''      );
   _mkHStrUid(UID_UGenerator       ,'UAC Generator'              ,''      );
   _mkHStrUid(UID_UAGenerator      ,'UAC Advanced Generator'     ,''      );
   _mkHStrUid(UID_UWeaponFactory   ,'UAC Weapon Factory'         ,''      );
   _mkHStrUid(UID_UGTurret         ,'UAC Anti-ground Turret'     ,'Anti-ground defensive structure');
   _mkHStrUid(UID_UATurret         ,'UAC Anti-air Turret'        ,'Anti-air defensive structure'   );
   _mkHStrUid(UID_UTechCenter      ,'UAC Science Center'         ,''      );
   _mkHStrUid(UID_UNuclearPlant    ,'UAC Nuclear Plant'          ,''      );
   _mkHStrUid(UID_URadar           ,'UAC Radar'                  ,'Reveals map. Detector'          );
   _mkHStrUid(UID_URMStation       ,'UAC Rocket Launcher Station','Provide a missile strike. Missile strike requires "Missile strike" charge');
   _mkHStrUid(UID_UMine            ,'UAC Mine'                   ,''      );

   _mkHStrUid(UID_Sergant          ,'Shotguner'                  ,'');
   _mkHStrUid(UID_SSergant         ,'SuperShotguner'             ,'');
   _mkHStrUid(UID_Commando         ,'Commando'                   ,'');
   _mkHStrUid(UID_Antiaircrafter   ,'Antiaircrafter'             ,'');
   _mkHStrUid(UID_SiegeMarine      ,'Siege Marine'               ,'');
   _mkHStrUid(UID_FPlasmagunner    ,'Plasmaguner'                ,'');
   _mkHStrUid(UID_BFGMarine        ,'BFG Marine'                 ,'');
   _mkHStrUid(UID_Engineer         ,'Engineer'                   ,'');
   _mkHStrUid(UID_Medic            ,'Medic'                      ,'');
   _mkHStrUid(UID_UTransport       ,'UAC Dropship'               ,'');
   _mkHStrUid(UID_UACDron          ,'UAC Drone'                  ,'');
   _mkHStrUid(UID_Terminator       ,'UAC Terminator'             ,'');
   _mkHStrUid(UID_Tank             ,'UAC Tank'                   ,'');
   _mkHStrUid(UID_Flyer            ,'UAC Fighter'                ,'');
   _mkHStrUid(UID_APC              ,'Ground APC'                 ,'');


   _mkHStrUpid(upgr_uac_attack     ,'Ranged Attack Upgrade'            ,'Increase the damage of ranged attacks for all UAC units and defensive structures.');
   _mkHStrUpid(upgr_uac_uarmor     ,'Infantry Combat Armor Upgrade'    ,'Increase the armor of all Barrack`s units.'                     );
   _mkHStrUpid(upgr_uac_barmor     ,'Concrete Walls'                   ,'Increase the armor of all UAC buildings.'                       );
   _mkHStrUpid(upgr_uac_melee      ,'Advanced Tools'                   ,'Increase the efficiency of repair/healing of Engineers/Medics.' );
   _mkHStrUpid(upgr_uac_mspeed     ,'Lightweight Armor'                ,'Increase the movement speed of all Barrack`s units.'            );
   _mkHStrUpid(upgr_uac_painn      ,'Expansive bullets'                ,'Attacks by Shotguner, SuperShotguner, Commando, UAC Terminator and anti-ground turrets make demons have pain state more often.'                               );
   _mkHStrUpid(upgr_uac_towers     ,'Tower Range Upgrade'              ,'Increase defensive structures range.'                           );
   _mkHStrUpid(upgr_uac_CCFly      ,'UAC Command Center Engines'       ,'UAC Command Center gains ability to fly.'                       );
   _mkHStrUpid(upgr_uac_ccturr     ,'UAC Command Center Turret'        ,'Plasma turret for UAC Command Center.'                          );
   _mkHStrUpid(upgr_uac_buildr     ,'UAC Command Center Range Upgrade' ,'Increase UAC Command Center sight range.'                       );
   _mkHStrUpid(upgr_uac_extbuild   ,'Adaptive Foundation'              ,'All buildings, except those that can produce units, can be placed on doodads.');
   _mkHStrUpid(upgr_uac_soaring    ,'Engines for Soaring'              ,'UAC Drone can move over obstacles.');

   _mkHStrUpid(upgr_uac_botturret  ,'UAC Drone Transformation Protocol','UAC Drone can rebuild to Anti-ground turret.');
   _mkHStrUpid(upgr_uac_vision     ,'Light Amplification Visors'       ,'Increase the sight range of all UAC units.'  );
   _mkHStrUpid(upgr_uac_commando   ,'Stealth Technology'               ,'Commando become invisible.'                  );
   _mkHStrUpid(upgr_uac_airsp      ,'Fragmentation Missiles'           ,'Anti-air missiles deal additional damage around target.'  );
   _mkHStrUpid(upgr_uac_mechspd    ,'Advanced Engines'                 ,'Increase the movement speed of all Factory`s units.'      );
   _mkHStrUpid(upgr_uac_mecharm    ,'Mech Combat Armor Upgrade'        ,'Increase the armor of all Factory`s units.'               );
   _mkHStrUpid(upgr_uac_lturret    ,'UAC Fighter Laser Gun'            ,'UAC Fighter anti-ground weapon.'                          );
   _mkHStrUpid(upgr_uac_transport  ,'UAC Dropship Upgrade'             ,'Increase the capacity of UAC Dropship'                    );
   _mkHStrUpid(upgr_uac_radar_r    ,'UAC Radar Upgrade'                ,'Increase radar scouting radius.'             );
   _mkHStrUpid(upgr_uac_plasmt     ,'UAC Anti-ground Plasmagun'        ,'Plasmagun for UAC Anti-ground turret.'       );
   _mkHStrUpid(upgr_uac_turarm     ,'Additional Armoring'              ,'Additional armor for UAC Turrets.'           );
   _mkHStrUpid(upgr_uac_rstrike    ,'UAC Rocket Strike Charge'         ,'Missile for Rocket Launcher Station ability.');


   _mkHStrACT(0 ,'Action');
   _mkHStrACT(1 ,'Action at point');
   _mkHStrACT(2 ,'Rebuild/Advance');
   t:='attack enemies';
   _mkHStrACT(3 ,'Move, '  +t);
   _mkHStrACT(4 ,'Stop, '  +t);
   _mkHStrACT(5 ,'Patrol, '+t);
   t:='ignore enemies';
   _mkHStrACT(6 ,'Move, '  +t);
   _mkHStrACT(7 ,'Stop, '  +t);
   _mkHStrACT(8 ,'Patrol, '+t);
   _mkHStrACT(9 ,'Cancel production');
   _mkHStrACT(10,'Select all units' );
   _mkHStrACT(11,'Destroy'          );
   _mkHStrACT(12,'Alarm mark'       );
   _mkHStrACT(13,str_maction);

   _mkHStrREQ(0 ,'Faster game speed'    ,false);
   _mkHStrREQ(1 ,'Left click: skip 2 seconds ('                                +tc_lime+'W'+tc_default+')'+tc_nl1+
                 'Right click: skip 10 seconds ('+tc_lime+'Ctrl'+tc_default+'+'+tc_lime+'W'+tc_default+')'+tc_nl1+
                 'Skip 1 minute ('               +tc_lime+'Alt' +tc_default+'+'+tc_lime+'W'+tc_default+')',true);
   _mkHStrREQ(2 ,'Pause'                ,false);
   _mkHStrREQ(3 ,'Player POV'           ,false);
   _mkHStrREQ(4 ,'List of game messages',false);
   _mkHStrREQ(5 ,'Fog of war'           ,false);
   _mkHStrREQ(8 ,'All players',false);
   _mkHStrREQ(9 ,'Player #1'  ,false);
   _mkHStrREQ(10,'Player #2'  ,false);
   _mkHStrREQ(11,'Player #3'  ,false);
   _mkHStrREQ(12,'Player #4'  ,false);
   _mkHStrREQ(13,'Player #5'  ,false);
   _mkHStrREQ(14,'Player #6'  ,false);


   {str_camp_t[0]         := 'Hell #1: Phobos invasion';
   str_camp_t[1]         := 'Hell #2: Military base';
   str_camp_t[2]         := 'Hell #3: Deimos invasion';
   str_camp_t[3]         := 'Hell #4: Pentagram of Death';
   str_camp_t[4]         := 'Hell #7: Quarry';
   str_camp_t[5]         := 'Hell #8: Hell on Mars';
   str_camp_t[6]         := 'Hell #5: Hell on Earth';
   str_camp_t[7]         := 'Hell #6: Cosmodrome';
   str_camp_t[8]         := '9. ';
   str_camp_t[9]         := '10. ';
   str_camp_t[10]        := '11. ';
   str_camp_t[11]        := '12. ';
   str_camp_t[12]        := '13. ';
   str_camp_t[13]        := '14. ';
   str_camp_t[14]        := '15. ';
   str_camp_t[15]        := '16. ';
   str_camp_t[16]        := '17. ';
   str_camp_t[17]        := '18. ';
   str_camp_t[18]        := '19. ';
   str_camp_t[19]        := '20. ';
   str_camp_t[20]        := '21. ';
   str_camp_t[21]        := '22. ';

   str_camp_o[0]         := '-Destroy all human bases and armies'+tc_nl3+'-Protect the Portal';
   str_camp_o[1]         := '-Destroy Military Base';
   str_camp_o[2]         := '-Destroy all human bases and armies'+tc_nl3+'-Protect the Portal';
   str_camp_o[3]         := '-Protect the altars for 20 minutes';
   str_camp_o[4]         := '-Destroy all human bases and armies';
   str_camp_o[5]         := '-Destroy all human bases and armies';
   str_camp_o[6]         := '-Destroy all human bases and armies';
   str_camp_o[7]         := '-Destroy Cosmodrome'+tc_nl3+'-No one human`s transport should escape';

   str_camp_m[0]         := tc_lime+'Date:'+tc_default+tc_nl2+'15.11.2145'+tc_nl2+tc_lime+'Location:'+tc_default+tc_nl2+'PHOBOS'+tc_nl2+tc_lime+'Area:'+tc_default+tc_nl2+'Anomaly Zone';
   str_camp_m[1]         := tc_lime+'Date:'+tc_default+tc_nl2+'16.11.2145'+tc_nl2+tc_lime+'Location:'+tc_default+tc_nl2+'PHOBOS'+tc_nl2+tc_lime+'Area:'+tc_default+tc_nl2+'Hall crater';
   str_camp_m[2]         := tc_lime+'Date:'+tc_default+tc_nl2+'15.11.2145'+tc_nl2+tc_lime+'Location:'+tc_default+tc_nl2+'DEIMOS'+tc_nl2+tc_lime+'Area:'+tc_default+tc_nl2+'Anomaly Zone';
   str_camp_m[3]         := tc_lime+'Date:'+tc_default+tc_nl2+'16.11.2145'+tc_nl2+tc_lime+'Location:'+tc_default+tc_nl2+'DEIMOS'+tc_nl2+tc_lime+'Area:'+tc_default+tc_nl2+'Swift crater';
   str_camp_m[4]         := tc_lime+'Date:'+tc_default+tc_nl2+'18.11.2145'+tc_nl2+tc_lime+'Location:'+tc_default+tc_nl2+'MARS'  +tc_nl2+tc_lime+'Area:'+tc_default+tc_nl2+'Hellas Area';
   str_camp_m[5]         := tc_lime+'Date:'+tc_default+tc_nl2+'19.11.2145'+tc_nl2+tc_lime+'Location:'+tc_default+tc_nl2+'MARS'  +tc_nl2+tc_lime+'Area:'+tc_default+tc_nl2+'Hellas Area';
   str_camp_m[6]         := tc_lime+'Date:'+tc_default+tc_nl2+'18.11.2145'+tc_nl2+tc_lime+'Location:'+tc_default+tc_nl2+'EARTH' +tc_nl2+tc_lime+'Area:'+tc_default+tc_nl2+'Unknown';
   str_camp_m[7]         := tc_lime+'Date:'+tc_default+tc_nl2+'19.11.2145'+tc_nl2+tc_lime+'Location:'+tc_default+tc_nl2+'EARTH' +tc_nl2+tc_lime+'Area:'+tc_default+tc_nl2+'Unknown';  }

   {
   str_cmp_mn[1 ] := 'Hell #1: Invasion on Phobos';
   str_cmp_mn[2 ] := 'Hell #2: Toxin Refinery';
   str_cmp_mn[3 ] := 'Hell #3: Military Base';
   str_cmp_mn[4 ] := 'Hell #4: Deimos Anomaly';
   str_cmp_mn[5 ] := 'Hell #5: Nuclear Plant';
   str_cmp_mn[6 ] := 'Hell #6: Science Center';
   str_cmp_mn[7 ] := 'Hell #7: Quarry';
   str_cmp_mn[8 ] := 'Hell #8: Hell on Mars';
   str_cmp_mn[9 ] := 'Hell #9: Hell On Earth';
   str_cmp_mn[10] := 'Hell #10: Industrial Zone';
   str_cmp_mn[11] := 'Hell tc_nl1: Cosmodrome';
   str_cmp_mn[12] := 'UAC #1: Command Center';
   str_cmp_mn[13] := 'UAC #2: Super Generators';
   str_cmp_mn[14] := 'UAC #3: Phobos Anomaly';
   str_cmp_mn[15] := 'UAC #4: Deimos Anomaly 2';
   str_cmp_mn[16] := 'UAC #5: Lab';
   str_cmp_mn[17] := 'UAC #6: Fortress of Mystery';
   str_cmp_mn[18] := 'UAC #7: City of the Damned';
   str_cmp_mn[19] := 'UAC #8: Slough of Despair';
   str_cmp_mn[20] := 'UAC #9: Mt. Erebus';
   str_cmp_mn[21] := 'UAC #10: Dead Zone';
   str_cmp_mn[22] := 'UAC tc_nl1: Battle For Mars';

   str_cmp_ob[1 ] := '-Destroy all human bases and armies'+tc_nl3+'-Protect portal';
   str_cmp_ob[2 ] := '-Destroy Toxin Refinery';
   str_cmp_ob[3 ] := '-Destroy Military Base';
   str_cmp_ob[4 ] := '-Destroy all human bases and armies'+tc_nl3+'-Cyberdemon must survive'+tc_nl3+'-Protect portal';
   str_cmp_ob[5 ] := '-Destroy Nuclear Plant'+tc_nl3+'-Cyberdemon must survive';
   str_cmp_ob[6 ] := '-Destroy Science Center'+tc_nl3+'-Cyberdemon must survive';
   str_cmp_ob[7 ] := '-Destroy all human bases and armies';
   str_cmp_ob[8 ] := '-Kill all humans!';
   str_cmp_ob[9 ] := '-Protect Hell Fortess'+tc_nl3+'-Destroy all human towns and armies';
   str_cmp_ob[10] := '-Destroy all industrial buildings'+tc_nl3+'-Destroy all command centers';
   str_cmp_ob[11] := '-Destroy all military bases';
   str_cmp_ob[12] := '-Find, protect and reapir'+tc_nl3+'Command Center'+tc_nl3+'-At least one engineer must survive';
   str_cmp_ob[13] := '-Find and repair 5 Super Generators';
   str_cmp_ob[14] := '-Destroy all bases and armies of hell'+tc_nl3+'around portal until the arrival of'+tc_nl3+'enemy reinforcements(for 20 minutes)';
   str_cmp_ob[15] := '-Destroy all bases and armies of hell'+tc_nl3+'-Protect portal';
   str_cmp_ob[16] := '-Repair and protect Science Center'+tc_nl3+'-Destroy all bases and armies of hell';
   str_cmp_ob[17] := '-Destroy fortess of hell';
   str_cmp_ob[18] := '-Destroy all altars of hell'+tc_nl3+'-Protect portal';
   str_cmp_ob[19] := '-Reach the opposite side of the area';
   str_cmp_ob[20] := '-Find and kill the Spiderdemon';
   str_cmp_ob[21] := '-Cleanse the Quarry';
   str_cmp_ob[22] := '-Destroy all bases and armies of hell';

   str_cmp_map[1 ] := 'Date:'+tc_nl2+'15.11.2145'+tc_nl2+'Location:'+tc_nl2+'PHOBOS'+tc_nl2+'Area:'+tc_nl2+'Anomaly Zone';
   str_cmp_map[2 ] := 'Date:'+tc_nl2+'15.11.2145'+tc_nl2+'Location:'+tc_nl2+'PHOBOS'+tc_nl2+'Area:'+tc_nl2+'Hall crater';
   str_cmp_map[3 ] := 'Date:'+tc_nl2+'16.11.2145'+tc_nl2+'Location:'+tc_nl2+'PHOBOS'+tc_nl2+'Area:'+tc_nl2+'Drunlo crater';
   str_cmp_map[4 ] := 'Date:'+tc_nl2+'15.11.2145'+tc_nl2+'Location:'+tc_nl2+'DEIMOS'+tc_nl2+'Area:'+tc_nl2+'Anomaly Zone';
   str_cmp_map[5 ] := 'Date:'+tc_nl2+'16.11.2145'+tc_nl2+'Location:'+tc_nl2+'DEIMOS'+tc_nl2+'Area:'+tc_nl2+'Swift crater';
   str_cmp_map[6 ] := 'Date:'+tc_nl2+'16.11.2145'+tc_nl2+'Location:'+tc_nl2+'DEIMOS'+tc_nl2+'Area:'+tc_nl2+'Voltaire Area';
   str_cmp_map[7 ] := 'Date:'+tc_nl2+'16.11.2145'+tc_nl2+'Location:'+tc_nl2+'MARS'  +tc_nl2+'Area:'+tc_nl2+'Hellas Area';
   str_cmp_map[8 ] := 'Date:'+tc_nl2+'16.11.2145'+tc_nl2+'Location:'+tc_nl2+'MARS'  +tc_nl2+'Area:'+tc_nl2+'Hellas Area';
   str_cmp_map[9 ] := 'Date:'+tc_nl2+'25.11.2145'+tc_nl2+'Location:'+tc_nl2+'EARTH' +tc_nl2+'Area:'+tc_nl2+'Unknown';
   str_cmp_map[10] := 'Date:'+tc_nl2+'26.11.2145'+tc_nl2+'Location:'+tc_nl2+'EARTH' +tc_nl2+'Area:'+tc_nl2+'Unknown';
   str_cmp_map[11] := 'Date:'+tc_nl2+'27.11.2145'+tc_nl2+'Location:'+tc_nl2+'EARTH' +tc_nl2+'Area:'+tc_nl2+'Unknown';
   str_cmp_map[12] := 'Date:'+tc_nl2+'16.11.2145'+tc_nl2+'Location:'+tc_nl2+'PHOBOS'+tc_nl2+'Area:'+tc_nl2+'Todd crater';
   str_cmp_map[13] := 'Date:'+tc_nl2+'16.11.2145'+tc_nl2+'Location:'+tc_nl2+'PHOBOS'+tc_nl2+'Area:'+tc_nl2+'Roche crater';
   str_cmp_map[14] := 'Date:'+tc_nl2+'17.11.2145'+tc_nl2+'Location:'+tc_nl2+'PHOBOS'+tc_nl2+'Area:'+tc_nl2+'Anomaly Zone';
   str_cmp_map[15] := 'Date:'+tc_nl2+'17.11.2145'+tc_nl2+'Location:'+tc_nl2+'DEIMOS'+tc_nl2+'Area:'+tc_nl2+'Anomaly Zone';
   str_cmp_map[16] := 'Date:'+tc_nl2+'18.11.2145'+tc_nl2+'Location:'+tc_nl2+'DEIMOS'+tc_nl2+'Area:'+tc_nl2+'Voltaire Area';
   str_cmp_map[17] := 'Date:'+tc_nl2+'18.11.2145'+tc_nl2+'Location:'+tc_nl2+'DEIMOS'+tc_nl2+'Area:'+tc_nl2+'Voltaire Area';
   str_cmp_map[18] := 'Date:'+tc_nl2+'20.11.2145'+tc_nl2+'Location:'+tc_nl2+'HELL'  +tc_nl2+'Area:'+tc_nl2+'Unknown';
   str_cmp_map[19] := 'Date:'+tc_nl2+'21.11.2145'+tc_nl2+'Location:'+tc_nl2+'HELL'  +tc_nl2+'Area:'+tc_nl2+'Unknown';
   str_cmp_map[20] := 'Date:'+tc_nl2+'22.11.2145'+tc_nl2+'Location:'+tc_nl2+'HELL'  +tc_nl2+'Area:'+tc_nl2+'Unknown';
   str_cmp_map[21] := 'Date:'+tc_nl2+'21.11.2145'+tc_nl2+'Location:'+tc_nl2+'MARS'  +tc_nl2+'Area:'+tc_nl2+'Hellas Area';
   str_cmp_map[22] := 'Date:'+tc_nl2+'22.11.2145'+tc_nl2+'Location:'+tc_nl2+'MARS'  +tc_nl2+'Area:'+tc_nl2+'Hellas Area';

   }

   _makeHints;
end;

procedure lng_rus;
var t: shortstring;
begin
  str_MMap              := '�����';
  str_MPlayers          := '������';
  str_MObjectives       := '������';
  str_menu_s1[ms1_sett] := '���������';
  str_menu_s1[ms1_svld] := '����./����.';
  str_menu_s1[ms1_reps] := '������';
  str_menu_s2[ms2_camp] := '��������';
  str_menu_s2[ms2_scir] := '�������';
  str_menu_s2[ms2_mult] := '������� ����';
  str_menu_s3[ms3_game] := '����';
  str_menu_s3[ms3_vido] := '�������';
  str_menu_s3[ms3_sond] := '����';
  str_reset[false]      := '������';
  str_reset[true ]      := '�����';
  str_exit[false]       := '�����';
  str_exit[true]        := '�����';
  str_m_liq             := '�����: ';
  str_m_siz             := '������: ';
  str_m_obs             := '��������: ';
  str_m_sym             := '�������.: ';
  str_map               := '�����';
  str_players           := '������';
  str_mrandom           := '��������� �����';
  str_musicvol          := '��������� ������';
  str_soundvol          := '��������� ������';
  str_scrollspd         := '�������� ��.';
  str_mousescrl         := '�����. �����';
  str_fullscreen        := '� ����:';
  str_plname            := '��� ������';
  str_maction           := '�������� �� ������ ����';
  str_maction2[true ]   := tc_lime+'��������'+tc_default;
  str_maction2[false]   := tc_lime+'����.'   +tc_default+'+'+tc_red+'�����'+tc_default;
  str_race[r_random]    := tc_white+'����.'  +tc_default;
  str_pause             := '�����';
  str_win               := '������!';
  str_lose              := '���������!';
  str_gsunknown         := '����������� ������!';
  str_gsaved            := '���� ���������';
  str_repend            := '����� ������!';
  str_save              := '���������';
  str_load              := '���������';
  str_delete            := '�������';
  str_svld_errors_file  := '���� ��'+tc_nl3+'����������!';
  str_svld_errors_open  := '����������'+tc_nl3+'������� ����!';
  str_svld_errors_wdata := '������������'+tc_nl3+'������ �����!';
  str_svld_errors_wver  := '������������'+tc_nl3+'������ �����!';
  str_time              := '�����: ';
  str_menu              := '����';
  str_player_def        := ' ���������!';
  str_inv_time          := '����� #';
  str_inv_ml            := '����� ��������: ';
  str_play              := '���������';
  str_replay            := '������';
  str_replay_name       := '�������� ������:';
  str_cmpdif            := '���������: ';
  str_waitsv            := '�������� �������...';
  str_goptions          := '��������� ����';
  str_server            := '������';
  str_client            := '������';
  str_chat              := '���';
  str_chat_all          := '���:';
  str_chat_allies       := '��������:';
  str_randoms           := '��������� �������';
  str_apply             := '���������';
  str_plout             := ' ������� ����';
  str_aislots           := '��������� ������ �����:';
  str_resol             := '����������';
  str_language          := '���� ����������';
  str_req               := '����������: ';
  str_orders            := '������: ';
  str_all               := '���';
  str_uprod             := '��������� �: ';
  str_bprod             := '������: ';
  str_ColoredShadow     := '������� ����';
  str_kothtime          := '����� ������� ������: ';
  str_deadobservers     := '����������� ����� ���������:';

  str_Builder           := '���������';
  str_Barrack           := '���������� ������';
  str_Smith             := '��������� ��������� � ��������';
  str_IncEnergyLevel    := '����������� ������� �������';
  str_CanRebuildTo      := '����� ����������� � ';

  str_cant_build        := '������ ������� �����';
  str_need_energy       := '���������� ������ �������';
  str_cant_prod         := '��������� ���������� ���';
  str_check_reqs        := '��������� ����������';
  str_cant_execute      := '����������� ��������� ������';
  str_advanced          := '���������� ';
  str_unit_advanced     := '���� �������';
  str_upgrade_complete  := '������������ ���������';
  str_building_complete := '��������� ���������';
  str_unit_complete     := '���� �����';
  str_unit_attacked     := '���� ��������';
  str_base_attacked     := '���� ���������';
  str_allies_attacked   := '���� �������� ���������';
  str_maxlimit_reached  := '��������� ������������ ������ �����';
  str_need_more_builders:= '���������� ������ ����������';
  str_production_busy   := '��� ������������ ������';
  str_cant_advanced     := '���������� �����������/��������';
  str_NeedMoreProd      := '����� ����������� ���';
  str_MaximumReached    := '��������� ��������';

  str_attr_unit         := tc_gray  +'����'          +tc_default;
  str_attr_building     := tc_red   +'������'        +tc_default;
  str_attr_mech         := tc_blue  +'������������'  +tc_default;
  str_attr_bio          := tc_orange+'�������������' +tc_default;
  str_attr_light        := tc_yellow+'������'        +tc_default;
  str_attr_nlight       := tc_green +'�������'       +tc_default;
  str_attr_fly          := tc_white +'��������'      +tc_default;
  str_attr_ground       := tc_lime  +'��������'      +tc_default;
  str_attr_floater      := tc_aqua  +'�������'       +tc_default;
  str_attr_level        := tc_white +'������� '      +tc_default;
  str_attr_invuln       := tc_lime  +'����������'    +tc_default;
  str_attr_stuned       := tc_yellow+'�������'       +tc_default;
  str_attr_detector     := tc_purple+'��������'      +tc_default;

  str_panelpos          := '��������� ������� ������';
  str_panelposp[0]      := tc_lime  +'�����' +tc_default;
  str_panelposp[1]      := tc_orange+'������'+tc_default;
  str_panelposp[2]      := tc_yellow+'������'+tc_default;
  str_panelposp[3]      := tc_aqua  +'�����' +tc_default;

  str_uhbar             := '������� ��������';
  str_uhbars[0]         := tc_lime  +'���������'+tc_default+'+'+tc_red+'�������.'+tc_default;
  str_uhbars[1]         := tc_aqua  +'������'   +tc_default;
  str_uhbars[2]         := tc_orange+'������ '  +tc_lime+'���������'+tc_default;

  str_pcolor            := '����� �������';
  str_pcolors[0]        := tc_white +'�� ���������'+tc_default;
  str_pcolors[1]        := tc_lime  +'���� '+tc_yellow+'�������� '+tc_red+'�����'+tc_default;
  str_pcolors[2]        := tc_white +'���� '+tc_yellow+'�������� '+tc_red+'�����'+tc_default;
  str_pcolors[3]        := tc_purple+'�������'+tc_default;
  str_pcolors[4]        := tc_white +'���� '+tc_purple+'�������'+tc_default;

  str_starta            := '���������� ���������� �� ������:';

  str_fstarts           := '������������� ������:';

  str_gmodet            := '����� ����:';
  str_gmode[gm_scirmish]:= tc_lime  +'�������'           +tc_default;
  str_gmode[gm_3x3     ]:= tc_orange+'3x3'               +tc_default;
  str_gmode[gm_2x2x2   ]:= tc_yellow+'2x2x2'             +tc_default;
  str_gmode[gm_capture ]:= tc_aqua  +'������ �����'      +tc_default;
  str_gmode[gm_invasion]:= tc_blue  +'���������'         +tc_default;
  str_gmode[gm_KotH    ]:= tc_purple+'���� ����'         +tc_default;
  str_gmode[gm_royale  ]:= tc_red   +'����������� �����' +tc_default;

  str_cgenerators       := '����������� ����������:';
  str_cgeneratorsM[0]   := '���';
  str_cgeneratorsM[1]   := '5 ���.';
  str_cgeneratorsM[2]   := '10 ���.';
  str_cgeneratorsM[3]   := '15 ���.';
  str_cgeneratorsM[4]   := '20 ���.';
  str_cgeneratorsM[5]   := '�����������';

  str_team              := '����:';
  str_srace             := '����:';
  str_ready             := '�����: ';
  str_udpport           := 'UDP ����:';
  str_svup[false]       := '���. ������';
  str_svup[true ]       := '����. ������';
  str_connect[false]    := '�����������';
  str_connect[true ]    := '����.';
  str_pnu               := '������/��������: ';
  str_npnu              := '���������� ������: ';
  str_connecting        := '����������...';
  str_sver              := '������ ������!';
  str_sfull             := '��� ����!';
  str_sgst              := '���� ��������!';

  str_hint_t[0]         := '������';
  str_hint_t[1]         := '�����';
  str_hint_t[2]         := '������������';
  str_hint_t[3]         := '������';

  str_hint_m[0]         := '���� (' +tc_lime+'Esc'        +tc_default+')';
  str_hint_m[2]         := '����� ('+tc_lime+'Pause/Break'+tc_default+')';

  str_hint_army         := '�����: ';
  str_hint_energy       := '�������: ';

  _mkHStrUid(UID_HKeep           ,'������ ��������'            ,''             );
  _mkHStrUid(UID_HGate           ,'������ �����'               ,''             );
  _mkHStrUid(UID_HSymbol         ,'������ ������'              ,''             );
  _mkHStrUid(UID_HPools          ,'������ �����'               ,''             );
  _mkHStrUid(UID_HTower          ,'������ �����'               ,'�������� ����������. ����� ��������� �������� � ��������� ������'  );
  _mkHStrUid(UID_HTeleport       ,'������ ��������'            ,'������������� ������'                                              );
  _mkHStrUid(UID_HMonastery      ,'������ ���������'           ,'��������� ������ � T2 ����������� ��� ������'                      );
  _mkHStrUid(UID_HTotem          ,'������ �����'               ,'����������� �������� ����������.  ����� ��������� �������� � ��������� ������. �� ����� ��������� ������'      );
  _mkHStrUid(UID_HAltar          ,'������ ������'              ,'����� ����������� "������������" �� ������'     );
  _mkHStrUid(UID_HFortress       ,'������ �����'               ,'��������� ������ � T2 ����������� ��� ������'   );
  _mkHStrUid(UID_HCommandCenter  ,'��������� ��������� �����'  ,'');
  _mkHStrUid(UID_HACommandCenter ,'����������� ��������� ��������� �����','');
  _mkHStrUid(UID_HBarracks       ,'��������� �������'          ,'');


  _mkHStrUid(UID_UCommandCenter  ,'��������� �����'            ,'');
  _mkHStrUid(UID_UACommandCenter ,'����������� ��������� �����','');
  _mkHStrUid(UID_UBarracks       ,'�������'                    ,'');
  _mkHStrUid(UID_UFactory        ,'�������'                    ,'');
  _mkHStrUid(UID_UGenerator      ,'���������'                  ,'');
  _mkHStrUid(UID_UAGenerator     ,'����������� ���������'      ,'');
  _mkHStrUid(UID_UWeaponFactory  ,'����� ����������'           ,'');
  _mkHStrUid(UID_UGTurret        ,'����-�������� ������'       ,'����-�������� �������� ����������'           );
  _mkHStrUid(UID_UATurret        ,'����-��������� ������'      ,'����-��������� �������� ����������'          );
  _mkHStrUid(UID_UTechCenter     ,'������� �����'              ,'��������� ������ � T2 ����������� ��� ������');
  _mkHStrUid(UID_UNuclearPlant   ,'���'                        ,'��������� ������ � T2 ����������� ��� ������');
  _mkHStrUid(UID_URadar          ,'�����'                      ,'��������� �����. ��������'                   );
  _mkHStrUid(UID_URMStation      ,'������� ��������� �����'    ,'���������� �������� ����. ��� ����� ��������� ������������ "�������� ����"');
  _mkHStrUid(UID_UMine           ,'����'                       ,'');

  _mkHStrUid(UID_Sergant         ,'�������'                ,'');
  _mkHStrUid(UID_SSergant        ,'������� �������'        ,'');
  _mkHStrUid(UID_Commando        ,'��������'               ,'');
  _mkHStrUid(UID_Antiaircrafter  ,'��������'               ,'');
  _mkHStrUid(UID_SiegeMarine     ,'�����������'            ,'');
  _mkHStrUid(UID_FPlasmagunner   ,'������������'           ,'');
  _mkHStrUid(UID_BFGMarine       ,'������ � BFG'           ,'');
  _mkHStrUid(UID_Engineer        ,'�������'                ,'');
  _mkHStrUid(UID_Medic           ,'�����'                  ,'');
  _mkHStrUid(UID_UACDron         ,'����'                   ,'');
  _mkHStrUid(UID_UTransport      ,'��������� �������'      ,'');
  _mkHStrUid(UID_Terminator      ,'����������'             ,'');
  _mkHStrUid(UID_Tank            ,'����'                   ,'');
  _mkHStrUid(UID_Flyer           ,'�����������'            ,'');
  _mkHStrUid(UID_APC             ,'���'                    ,'');



  _mkHStrACT(0 ,'��������'            );
  _mkHStrACT(1 ,'�������� � �����'    );
  _mkHStrACT(2 ,'�����������/��������');
  t:='��������� ������';
  _mkHStrACT(3 ,'���������, '       +t);
  _mkHStrACT(4 ,'������, '          +t);
  _mkHStrACT(5 ,'�������������, '   +t);
  t:='������������ ������';
  _mkHStrACT(6 ,'���������, '       +t);
  _mkHStrACT(7 ,'������, '          +t);
  _mkHStrACT(8 ,'�������������, '   +t);
  _mkHStrACT(9 ,'������ ������������' );
  _mkHStrACT(10,'������� ���� ������ ��������� ������');
  _mkHStrACT(11,'����������'          );
  _mkHStrACT(12,'��������� �����'     );
  _mkHStrACT(13,str_maction           );

  _mkHStrREQ(0 ,'��������/��������� ���������� ��������',false);
  _mkHStrREQ(1 ,'����� ����: ���������� 2 ������� ('                               +tc_lime+'W'+tc_default+')'+tc_nl1+
                '������ ����: ���������� 10 ������ ('+tc_lime+'Ctrl'+tc_default+'+'+tc_lime+'W'+tc_default+')'+tc_nl1+
                '���������� 1 ������ ('              +tc_lime+'Alt' +tc_default+'+'+tc_lime+'W'+tc_default+')',true  );
  _mkHStrREQ(2 ,'�����'                   ,false);
  _mkHStrREQ(3 ,'������ ������'           ,false);
  _mkHStrREQ(4 ,'������ ������� ���������',false);
  _mkHStrREQ(5 ,'����� �����'             ,false);
  _mkHStrREQ(8 ,'��� ������'              ,false);
  _mkHStrREQ(9 ,'����� #1',false);
  _mkHStrREQ(10,'����� #2',false);
  _mkHStrREQ(11,'����� #3',false);
  _mkHStrREQ(12,'����� #4',false);
  _mkHStrREQ(13,'����� #5',false);
  _mkHStrREQ(14,'����� #6',false);


  {str_camp_t[0]         := 'Hell #1: ��������� �� �����';
  str_camp_t[1]         := 'Hell #2: ������� ����';
  str_camp_t[2]         := 'Hell #3: ��������� �� ������';
  str_camp_t[3]         := 'Hell #4: ����������� ������';
  str_camp_t[4]         := 'Hell #7: ������';
  str_camp_t[5]         := 'Hell #8: �� �� �����';
  str_camp_t[6]         := 'Hell #5: �� �� �����';
  str_camp_t[7]         := 'Hell #6: ���������';

  str_camp_o[0]         := '-�������� ��� ������� ���� � �����'+tc_nl3+'-������ ������';
  str_camp_o[1]         := '-�������� ������� ����';
  str_camp_o[2]         := '-�������� ��� ������� ���� � �����'+tc_nl3+'-������ ������';
  str_camp_o[3]         := '-������ ������ � ������� 20 �����';
  str_camp_o[4]         := '-�������� ��� ������� ���� � �����';
  str_camp_o[5]         := '-�������� ��� ������� ���� � �����';
  str_camp_o[6]         := '-�������� ��� ������� ���� � �����';
  str_camp_o[7]         := '-�������� ���������'+tc_nl3+'-�� ���� ������� ��������� �� ������'+tc_nl3+'����';

  str_camp_m[0]         := tc_lime+'����:'+tc_default+tc_nl2+'15.11.2145'+tc_nl2+tc_lime+'�����:'+tc_default+tc_nl2+'�����' +tc_nl2+tc_lime+'�����:'+tc_default+tc_nl2+'��������';
  str_camp_m[1]         := tc_lime+'����:'+tc_default+tc_nl2+'16.11.2145'+tc_nl2+tc_lime+'�����:'+tc_default+tc_nl2+'�����' +tc_nl2+tc_lime+'�����:'+tc_default+tc_nl2+'������ ����';
  str_camp_m[2]         := tc_lime+'����:'+tc_default+tc_nl2+'15.11.2145'+tc_nl2+tc_lime+'�����:'+tc_default+tc_nl2+'������'+tc_nl2+tc_lime+'�����:'+tc_default+tc_nl2+'��������';
  str_camp_m[3]         := tc_lime+'����:'+tc_default+tc_nl2+'16.11.2145'+tc_nl2+tc_lime+'�����:'+tc_default+tc_nl2+'������'+tc_nl2+tc_lime+'�����:'+tc_default+tc_nl2+'������ �����';
  str_camp_m[4]         := tc_lime+'����:'+tc_default+tc_nl2+'18.11.2145'+tc_nl2+tc_lime+'�����:'+tc_default+tc_nl2+'����'  +tc_nl2+tc_lime+'�����:'+tc_default+tc_nl2+'������� ������';
  str_camp_m[5]         := tc_lime+'����:'+tc_default+tc_nl2+'19.11.2145'+tc_nl2+tc_lime+'�����:'+tc_default+tc_nl2+'����'  +tc_nl2+tc_lime+'�����:'+tc_default+tc_nl2+'������� ������';
  str_camp_m[6]         := tc_lime+'����:'+tc_default+tc_nl2+'18.11.2145'+tc_nl2+tc_lime+'�����:'+tc_default+tc_nl2+'�����' +tc_nl2+tc_lime+'�����:'+tc_default+tc_nl2+'����������';
  str_camp_m[7]         := tc_lime+'����:'+tc_default+tc_nl2+'19.11.2145'+tc_nl2+tc_lime+'�����:'+tc_default+tc_nl2+'�����' +tc_nl2+tc_lime+'�����:'+tc_default+tc_nl2+'����������';  }

  _makeHints;
end;


procedure swLNG;
begin
  if(ui_language)
  then lng_rus
  else lng_eng;
end;



