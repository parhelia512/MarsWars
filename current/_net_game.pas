
function net_NewPlayer(sip:cardinal;sport:word):byte;
var p:byte;
begin
   net_NewPlayer:=255;
   for p:=0 to LastPlayer do
    if(p<>PlayerClient)then
     with g_players[p] do
      if(player_type=pt_none)then
       if(g_slot_state[p]=pss_opened  )
       or(g_slot_state[p]=pss_observer)then
       begin
          net_NewPlayer:=p;
          net_ip       :=sip;
          net_port     :=sport;
          player_type  :=pt_human;
          net_ttl      :=0;
          isready      :=false;
          {$IFNDEF _FULLGAME}
          GameLogCommon(p,255,'MarsWars dedicated server, '+str_ver,false);
          {$ENDIF}
          break;
       end;
end;

function net_GetPlayer(aip:cardinal;ap:word;MakeNew:boolean):byte;
var i:byte;
begin
   net_GetPlayer:=255;
   for i:=0 to LastPlayer do
    if(i<>PlayerClient)then
     with g_players[i] do
      if(player_type=pt_human)and(net_ip=aip)and(net_port=ap)then
      begin
         net_GetPlayer:=i;
         if(net_ttl>=fr_fps1)then {$IFDEF _FULLGAME}menu_remake{$ELSE}screen_redraw{$ENDIF}:=true;
         net_ttl:=0;
         break;
      end;

   if(net_GetPlayer=255)and(not g_Started)and(MakeNew)then net_GetPlayer:=net_NewPlayer(aip,ap);
end;

procedure net_SvReadPlayerData(pid:byte);
var
oldname:shortstring;
begin
   with g_players[pid] do
   begin
      oldname:=name;
      name   :=net_readstring;
      name   :=txt_ValidateStr(name,PlayerNameLen,@k_pname);
      if(length(name)=0)then name:=str_defaultPlayerName;
      if(oldname<>name)then {$IFDEF _FULLGAME}menu_remake{$ELSE}screen_redraw{$ENDIF}:=true;

      PNU     :=net_readbyte;
      log_n_cl:=net_readcard;

      if(log_n_cl=log_n)then net_logsend_pause:=0;
   end;
end;

procedure net_WriteGameData(pid:byte);
var p:byte;
begin
   net_writebyte(nmid_lobby_info);
   net_writebool(g_Started);

   for p:=0 to LastPlayer do
    with g_players[p] do
    begin
       net_writestring(name     );
       net_writebyte  (team     );
       net_writebyte  (slot_race);
       net_writebyte  (player_type    );
       net_writebyte  (g_slot_state[p]);
       net_writebool  (isready  );
       net_writeword  (net_ttl  );
       if(g_Started)then
       net_writebyte  (race     );
    end;

   net_writebyte(pid         );
   net_writebyte(PlayerLobby );

   net_writebyte(map_preset_cur);
   net_writeint (map_psize    );
   net_writebyte(map_type    );
   net_writecard(map_seed    );
   net_writebyte(map_symmetry);

   net_writebyte(map_scenario           );
   net_writebool(g_fixed_positions);
   net_writebyte(g_ai_slots       );
   net_writebyte(map_generators     );
   net_writebool(g_deadobservers  );

   if(g_Started)and(not g_fixed_positions)then
    for p:=0 to LastPlayer do
    begin
       net_writeint(map_PlayerStartX[p]);
       net_writeint(map_PlayerStartY[p]);
    end;
end;

procedure net_ReadMapMark(pid:byte);
var x,y:integer;
begin
   x:=net_readint;
   y:=net_readint;
   GameLogMapMark(pid,x,y);
end;

procedure net_WriteGameInfo;
var i:byte;
begin
   net_writebyte(nmid_localadv);
   net_writebyte(g_version);
   net_writebyte(map_scenario);
   for i:=0 to LastPlayer do
     with g_players[i] do
       if(player_type=pt_none)
       then net_writestring('')
       else net_writestring(name);
end;

procedure net_Server;
var mid,
    pid,
    i  :byte;
net_period_step
       :boolean;
begin
   net_clearbuffer;

   while(net_Receive>0)do
   begin
      mid:=net_readbyte;

      if(mid=nmid_getinfo)then
      begin
         net_clearbuffer;
         net_WriteGameInfo;
         net_send(net_LastinIP,net_LastinPort);
         continue;
      end;

      if(mid=nmid_connect)then
      begin
         i:=net_readbyte;
         if(i<>g_version)then
         begin
            net_clearbuffer;
            net_writebyte(nmid_wrong_ver);
            net_send(net_LastinIP,net_LastinPort);
            continue;
         end;
         pid:=net_GetPlayer(net_LastinIP,net_LastinPort,true);
         if(pid>LastPlayer)then
         begin
            net_clearbuffer;
            if(g_Started)
            then net_writebyte(nmid_game_started)
            else net_writebyte(nmid_server_full );
            net_send(net_LastinIP,net_LastinPort);
            continue;
         end;

         if(not g_Started)then net_SvReadPlayerData(pid);

         net_clearbuffer;
         net_WriteGameData(pid);
         net_send(net_LastinIP,net_LastinPort);
      end
      else   // other net mess
      begin
         pid:=net_GetPlayer(net_LastinIP,net_LastinPort,false);
         if(pid<=LastPlayer)then
         begin
            case mid of
nmid_log_chat    : begin
                      i:=net_readbyte;
                      GameLogChat(pid,i,net_readstring,false);    // chat
                      continue;
                   end;
nmid_player_leave: begin
                      GameLogPlayerLeave(pid);
                      if(not g_Started)
                      then PlayerSetType(pid,pt_none)//PlayerSlotChangeState(0,pid,pss_opened,false)
                      else PlayerLeave(pid,false);
                      {$IFDEF _FULLGAME}menu_remake{$ELSE}screen_redraw{$ENDIF}:=true;
                      continue;
                   end;
            else
               if(g_Started)then
                 case mid of
nmid_order       : with g_players[pid]do
                   begin
                      o_x0:=net_readint;
                      o_y0:=net_readint;
                      o_x1:=net_readint;
                      o_y1:=net_readint;
                      o_a0:=net_readint;
                      o_id:=net_readbyte;
                   end;
nmid_map_mark    : net_ReadMapMark(pid);
nmid_client_info : with g_players[pid] do
                   begin
                      PNU     :=net_readbyte;
                      log_n_cl:=net_readcard;
                      if(log_n_cl=log_n)then net_logsend_pause:=0;
                   end;
nmid_pause       : begin
                      if(G_Status<>gs_running)and(G_Status<=LastPlayer)then
                      begin
                         G_Status:=gs_running;
                         GameLogChat(pid,255,str_msg_PlayerResumed,false);
                      end
                      else
                        if(G_Status=gs_running)then
                        begin
                           G_Status:=pid;
                           GameLogChat(pid,255,str_msg_PlayerPaused,false);
                        end;
                     {$IFDEF _FULLGAME}menu_remake{$ELSE}screen_redraw{$ENDIF}:=true;
                   end;
nmid_break       : GameBreak(pid,false);
                 end
               else // not g_Started
                 case mid of
nmid_loby_mapMap      : if(MapLoad(pid,net_readbyte    ,false))then {$IFDEF _FULLGAME}menu_remake{$ELSE}screen_redraw{$ENDIF}:=true;
nmid_loby_mapSeed     : if(map_SetSetting(pid,mid,net_readcard,false))then {$IFDEF _FULLGAME}menu_remake{$ELSE}screen_redraw{$ENDIF}:=true;
nmid_loby_mapSize     : if(map_SetSetting(pid,mid,net_readint ,false))then {$IFDEF _FULLGAME}menu_remake{$ELSE}screen_redraw{$ENDIF}:=true;
nmid_loby_mapType        : if(map_SetSetting(pid,mid,net_readbyte,false))then {$IFDEF _FULLGAME}menu_remake{$ELSE}screen_redraw{$ENDIF}:=true;
nmid_loby_mapSymmetry    : if(map_SetSetting(pid,mid,net_readbyte,false))then {$IFDEF _FULLGAME}menu_remake{$ELSE}screen_redraw{$ENDIF}:=true;
nmid_loby_mapScenario,
nmid_loby_mapGenerators,
nmid_loby_gameFixStarts,
nmid_loby_gameDeadPObs,
nmid_loby_gameEmptySlots  : if(GameSetCommonSetting(pid,mid,net_readbyte,false))then {$IFDEF _FULLGAME}menu_remake{$ELSE}screen_redraw{$ENDIF}:=true;
nmid_loby_playerSlot  : begin
                          i:=net_readbyte;
                          if(PlayerSlotChangeState(pid,i,net_readbyte,false))then {$IFDEF _FULLGAME}menu_remake{$ELSE}screen_redraw{$ENDIF}:=true;
                          end;
nmid_loby_playerTeam  : begin
                          i:=net_readbyte;
                          if(PlayerSlotChangeTeam (pid,i,net_readbyte,false))then {$IFDEF _FULLGAME}menu_remake{$ELSE}screen_redraw{$ENDIF}:=true;
                          end;
nmid_loby_playerRace  : begin
                          i:=net_readbyte;
                          if(PlayerSlotChangeRace (pid,i,net_readbyte,false))then {$IFDEF _FULLGAME}menu_remake{$ELSE}screen_redraw{$ENDIF}:=true;
                          end;
                 end;
            end;
         end
         else
         begin
            net_clearbuffer;
            net_writebyte(nmid_notconnected);
            net_send(net_LastinIP,net_LastinPort);
         end;
      end;
   end;

   net_period_step:=(net_period mod NetTickN)=0;

   for i:=0 to LastPlayer do
    if(i<>PlayerClient)then
     with g_players[i] do
      if(player_type=pt_human)and(net_ttl<ClientTTL)then
      begin
         if(g_Started)and(net_period_step)then
         begin
            net_clearbuffer;
            net_writebyte(nmid_snapshot);
            net_writebyte(G_Status);
            if(G_Status=gs_running)
            then wclinet_gframe(i,false);
            net_send(net_ip,net_port);
         end;

         if(net_logsend_pause<=0)and(log_n_cl<>log_n)then
         begin
            net_clearbuffer;
            net_writebyte(nmid_log_upd);
            wudata_log(i,@log_n_cl,false);
            net_send(net_ip,net_port);
            net_logsend_pause:=fr_fpsd2;
         end;
      end;

   net_period+=1;
   net_period:=net_period mod fr_fpsd2;

   if(net_localAdv)and(not g_Started)then
     if(net_localAdv_timer<=0)then
     begin
        net_localAdv_timer:=net_localAdv_time;
        net_clearbuffer;
        net_WriteGameInfo;
        net_send(net_localAdv_ip,net_svlsearch_portS);
     end
     else net_localAdv_timer-=1;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   CLIENT

{$IFDEF _FULLGAME}

function net_ClientReadMapData(StartGame:boolean):boolean;
var
redraw_menu,
new_map    : boolean;
i          : byte;
function rByte(pv:pbyte;maxVal:byte):boolean;
var v:byte;
begin
   v:=net_readbyte;
   if(v>maxVal)then
   begin
      v:=0;
      net_ClientReadMapData:=true;
   end;
   rByte:=(v<>pv^);
   pv^:=v;
end;
function rInt(pv:pinteger;minVal,maxVal:integer):boolean;
var v:integer;
begin
   v:=net_readint;
   if(v<minVal)or(maxVal<v)then
   begin
      v:=minVal;
      net_ClientReadMapData:=true;
   end;
   rInt :=(v<>pv^);
   pv^:=v;
end;
function rCard(pv:pcardinal):boolean;var v:cardinal;begin v:=pv^;pv^:=net_readcard;rCard:=(v<>pv^);end;
function rBool(pv:pboolean ):boolean;var v:boolean ;begin v:=pv^;pv^:=net_readbool;rBool:=(v<>pv^);end;
begin
   redraw_menu:=false;
   new_map    :=false;
   net_ClientReadMapData:=false;

   if(rByte(@map_preset_cur     ,map_preset_n           ))then begin redraw_menu:=true;new_map:=true;end;
   if(rInt (@map_psize         ,MinMapSize,MaxMapSize))then begin redraw_menu:=true;new_map:=true;end;
   if(rByte(@map_type         ,gms_m_types          ))then begin redraw_menu:=true;new_map:=true;end;

   if(StartGame)
   or(not map_SetSetting(PlayerClient,nmid_loby_mapSeed,0,true))then
   begin
   if(rCard(@map_seed                           ))then begin redraw_menu:=true;new_map:=true;end;
   end
   else net_readcard;

   if(rByte(@map_symmetry     ,gms_m_symm       ))then begin redraw_menu:=true;new_map:=true;end;
   if(rByte(@map_scenario           ,ms_count        ))then begin redraw_menu:=true;new_map:=true;end;
   if(rBool(@g_fixed_positions                  ))then begin redraw_menu:=true;new_map:=true;end;
   if(rByte(@g_ai_slots       ,gms_g_maxai      ))then begin redraw_menu:=true;              end;
   if(rByte(@map_generators     ,gms_g_maxgens    ))then begin redraw_menu:=true;new_map:=true;end;
   if(rBool(@g_deadobservers                    ))then begin redraw_menu:=true;              end;

   if(new_map    )then map_Make1Scirmish;
   if(redraw_menu)then menu_remake:=true;

   if(StartGame)and(not g_fixed_positions)then
     for i:=0 to LastPlayer do
     begin
        map_PlayerStartX[i]:=net_readint;
        map_PlayerStartY[i]:=net_readint;
     end;
end;

function net_ClientReadPlayerData(pid:byte;StartGame:boolean):boolean;
var   i:integer;
newname:shortstring;
begin
   net_ClientReadPlayerData:=false;
   with g_players[pid] do
   begin
      // name
      newname:=txt_ValidateStr(net_readstring,PlayerNameLen,@k_pname);
      if(length(newname)=0)then newname:=str_defaultPlayerName;
      if(newname<>name)then
      begin
         menu_remake:=true;
         name:=newname;
      end;

      // team
      i:=net_readbyte;
      if(i>LastPlayer)then
      begin
         net_ClientReadPlayerData:=true;
         exit;
      end;
      if(i<>team)then
      begin
         menu_remake:=true;
         team:=i;
      end;

      // slot race
      i:=net_readbyte;
      if(i>race_num)then
      begin
         net_ClientReadPlayerData:=true;
         exit;
      end;
      if(i<>slot_race)then
      begin
         menu_remake:=true;
         slot_race:=i;
      end;

      // state
      i:=net_readbyte;
      if not(i in [pt_none,pt_human,pt_ai])then
      begin
         net_ClientReadPlayerData:=true;
         exit;
      end;
      if(i<>player_type)then
      begin
         menu_remake:=true;
         player_type:=i;
      end;

      // slot state
      i:=net_readbyte;
      if(i>ps_states_n)then
      begin
         net_ClientReadPlayerData:=true;
         exit;
      end;
      if(i<>g_slot_state[pid])then
      begin
         menu_remake:=true;
         g_slot_state[pid]:=i;
      end;

      // ready status
      i:=byte(net_readbool);
      if(i<>byte(isready))then
      begin
         menu_remake:=true;
         isready:=i<>0;
      end;

      // net_ttl
      i   :=net_ttl;
      net_ttl:=net_readint;
      if((i< fr_fps1)and(net_ttl>=fr_fps1))
      or((i>=fr_fps1)and(net_ttl< fr_fps1))then menu_remake:=true;

      if(StartGame)then
      begin
         i:=net_readbyte;
         if(i=r_random)or(i>race_num)then
         begin
            net_ClientReadPlayerData:=true;
            exit;
         end;
         race:=i;
      end
      else race:=slot_race;
   end;
end;

procedure net_Client;
var
mid,i:byte;
gst  :boolean;
procedure CleintProtocolError(perror:pshortstring);
begin
   GameBreakClientGame;
   //menu_s2:=ms2_mult;
   net_status_str:=perror^;
   menu_remake   :=true;
   menu_state    :=true;
end;
begin
   net_clearbuffer;
   while(net_Receive>0)do
   if(net_LastinIP=net_cl_svip)and(net_LastinPort=net_cl_svport)then
   begin
      if(net_cl_svttl>=ServerTTL)then menu_remake:=true;
      net_cl_svttl:=0;

      mid:=net_readbyte;
      case mid of
nmid_server_full : begin CleintProtocolError(@str_error_ServerFull  );exit;end;
nmid_wrong_ver   : begin CleintProtocolError(@str_error_WrongVersion);exit;end;
nmid_game_started: begin CleintProtocolError(@str_error_GameStarted );exit;end;
nmid_notconnected: begin
                      g_Started     :=false;
                      menu_state    :=true;
                      GameDefaultAll;
                   end;
nmid_log_upd     : begin
                      rudata_log(PlayerClient,false);
                      ui_LogLastMesTimer:=log_LastMesTime;
                      net_period:=0;
                   end;
nmid_lobby_info  : begin
                      gst:=net_readbool;

                      // players
                      for i:=0 to LastPlayer do
                       with g_players[i] do
                       begin
                          if(net_ClientReadPlayerData(i,gst))then
                          begin
                             CleintProtocolError(@str_error_WrongVersion);
                             exit;
                          end;
                          PlayerSetSkirmishTech(i);
                       end;

                      // PlayerClient
                      i:=net_readbyte;
                      if(i>LastPlayer)then
                      begin
                         CleintProtocolError(@str_error_WrongVersion);
                         exit;
                      end;
                      if(PlayerClient<>i)then
                      begin
                         menu_remake:=true;
                         PlayerClient:=i;
                      end;

                      // PlayerLobby
                      i:=net_readbyte;
                      if(i>LastPlayer)then
                      begin
                         CleintProtocolError(@str_error_WrongVersion);
                         exit;
                      end;
                      if(PlayerLobby<>i)then
                      begin
                         menu_remake:=true;
                         PlayerLobby:=i;
                      end;

                      // map and game settings
                      if(net_ClientReadMapData(gst))then
                      begin
                         CleintProtocolError(@str_error_WrongVersion);
                         exit;
                      end;
                      net_status_str:='';

                      if(gst<>g_Started)then
                      begin
                         g_Started:=gst;
                         if(g_Started)then
                         begin
                            menu_state:=false;
                            g_ServerSide:=false;
                            GameCameraMoveToPoint(map_PlayerStartX[PlayerClient],map_PlayerStartY[PlayerClient]);
                            {if(g_players[PlayerClient].team=0)then
                            begin
                               ui_tab:=tt_controls;
                               ui_player:=255;
                            end
                            else }
                            ui_player:=PlayerClient;
                         end
                         else
                         begin
                            menu_state:=true;
                            GameDefaultAll;
                         end;
                      end;
                   end;
      end;

      if(g_Started)then
      begin
         if(mid=nmid_snapshot)then
         begin
            G_Status:=net_readbyte;

            if(G_Status=gs_running)
            then rclinet_gframe(PlayerClient,false,false);
         end;
      end;
   end;

   if(net_period=0)then
   begin
      net_clearbuffer;
      if(not g_Started) then
      begin
         net_writebyte  (nmid_connect);
         net_writebyte  (g_version   );
         net_writestring(PlayerName  );
         net_writebyte  (cl_UpT_array[net_Quality]);
         net_writecard  (net_log_n   );
      end
      else
      begin
         net_writebyte(nmid_client_info);
         net_writebyte(cl_UpT_array[net_Quality]);
         net_writecard(net_log_n   );
      end;
      net_send(net_cl_svip,net_cl_svport);
   end;

   net_period+=1;
   net_period:=net_period mod fr_fpsd2;
   if(net_cl_svttl<ServerTTL)then
   begin
      net_cl_svttl+=1;
      if(net_cl_svttl=ServerTTL)then
      begin
         menu_remake:=true;
         G_Status:=gs_waitserver;
      end;
   end;
end;

procedure net_DiscoweringUpdate(aip:cardinal;aport:word;ainfo:shortstring);
var i,e:word;
begin
   e:=0;
   if(net_svsearch_listn>0)then
    for i:=0 to net_svsearch_listn-1 do
     with net_svsearch_listi[i] do
      if(aip=ip)and(aport=port)then
      begin
         e:=i+1;
         break;
      end;

   if(e=0)then
    if(net_svsearch_listn<net_svsearch_listn.MaxValue)then
    begin
       net_svsearch_listn+=1;
       setlength(net_svsearch_listi,net_svsearch_listn);
       setlength(net_svsearch_lists,net_svsearch_listn);
       with net_svsearch_listi[net_svsearch_listn-1] do
       begin
          ip  :=aip;
          port:=aport;
       end;
       e:=net_svsearch_listn;
       menu_remake:=true;
    end;

    if(e>0)then
    begin
       e-=1;
       if(net_svsearch_lists[e]<>ainfo)then menu_remake:=true;
       net_svsearch_lists[e]:=ainfo;
    end;
end;

procedure net_Discowering;
var mid,v,i:byte;
          s:shortstring;
begin
   net_clearbuffer;
   while(net_Receive>0)do
   begin
      mid:=net_readbyte;
      if(mid=nmid_localadv)then
      begin
         v:=net_readbyte;
         if(v=g_version)then
         begin
            v:=net_readbyte;
            if(v in allmapscenarios)then
            begin
               s:='';
               for i:=0 to LastPlayer do _ADDSTR(@s,net_readstring,sep_comma);
               s:=c2ip(net_LastinIP)+':'+w2s(swap(net_LastinPort))+' '+str_map_scenariol[v]+'  '+s;
               net_DiscoweringUpdate(net_LastinIP,net_LastinPort,s);
               continue;
            end;
         end;
         net_DiscoweringUpdate(net_LastinIP,net_LastinPort,c2ip(net_LastinIP)+':'+w2s(swap(net_LastinPort))+' '+str_error_WrongVersion);
      end;
   end;
end;

{$ENDIF}

