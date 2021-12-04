
procedure escape_key;
begin
   if(ingame_chat)then
   begin
      ingame_chat:=false;
      net_chat_str:='';
   end
   else ToggleMenu;
end;

procedure return_key;
begin
   if(_menu=false)and(not ingame_chat)and(net_status<>ns_none)
   then ingame_chat:=true
   else
    if(menu_item=100)or(ingame_chat)then
    begin
       if(length(net_chat_str)>0)then
        if(net_status=ns_clnt)
        then net_send_chat
        else PlayersAddLog(HPlayer,net_chat_tar,lmt_game,net_chat_str);
       net_chat_str:='';
       ingame_chat:=false;
    end;
end;

procedure TogglePause;
begin
   if(net_status=ns_clnt)
   then net_pause
   else
     if(net_status=ns_srvr)then
       if(G_paused=0)
       then G_paused:=HPlayer
       else G_paused:=0;
end;

procedure _ClientCommandEffect(cmd,tar,ox1,oy1:integer);
var su,i:integer;
    guid:byte;
    gadv:boolean;
function _checkEnemy:boolean;
begin
   _checkEnemy:=false;
   if(_IsUnitRange(tar,nil))then
    if(_units[tar].player^.team<>_players[HPlayer].team)then _checkEnemy:=true;
end;
procedure _PlayCommand(ss:PTSoundSet);
begin
   SoundPlayUnitCommand(ss);
   ui_UnitSelectedn:=0;
end;
procedure _ClickEffect(color:cardinal);
begin
   _click_eff(ox1,oy1,fr_4hfps,color);
end;

begin
   su  :=0;
   guid:=0;
   gadv:=false;

   with _players[HPlayer] do
   begin
      for i:=1 to MaxUnits do
      with _units[i] do
      with uid^ do
      if(hits>0)and(sel)and(playeri=HPlayer)then
      if(speed>0)or(_canattack(@_units[i]))or(_UnitHaveRPoint(_units[i].uidi))then
      begin
         su+=1;
         if(bld)then
         begin
            guid:=uidi;
            gadv:=buff[ub_advanced]>0;
         end;
      end;
   end;

   if(su<=0)then exit;

   with _uids[guid] do
   case cmd of
   co_paction,
   co_rcmove,
   co_move,
   co_astand,
   co_stand,
   co_patrol : _PlayCommand(un_snd_move[gadv]);
   co_amove,
   co_apatrol: _PlayCommand(un_snd_attack[gadv]);
   co_rcamove: if(_checkEnemy)
               then _PlayCommand(un_snd_attack[gadv])
               else _PlayCommand(un_snd_move  [gadv]);
   end;

   ox1+=vid_mapx;
   oy1+=vid_mapy;

   if(_IsUnitRange(tar,nil))then
   begin
      ui_umark_u:=tar;
      ui_umark_t:=fr_2hfps;
   end;

   case cmd of
   co_paction : _ClickEffect(c_aqua  );
   co_rcamove : _ClickEffect(c_yellow);
   co_rcmove,
   co_move,
   co_patrol  : _ClickEffect(c_lime  );
   co_amove,
   co_apatrol : _ClickEffect(c_red   );
   end;
end;

procedure _player_s_o(ox0,oy0,ox1,oy1:integer;oa0,oid,pl:byte);
begin
   if(G_Paused=0)and(_rpls_rst<rpl_rhead)then
   begin
      if(net_status=ns_clnt)then
      begin
         net_clearbuffer;
         net_writebyte(nmid_order);
         net_writeint (ox0);
         net_writeint (oy0);
         net_writeint (ox1);
         net_writeint (oy1);
         net_writebyte(oa0);
         net_writebyte(oid);
         net_send(net_cl_svip,net_cl_svport);
      end
      else
        with _players[pl] do
        begin
           o_x0:=ox0;
           o_y0:=oy0;
           o_x1:=ox1;
           o_y1:=oy1;
           o_a0:=oa0;
           o_id:=oid;
        end;

      if(oid=uo_corder)then _ClientCommandEffect(ox0,oy0,ox1,oy1);
   end;
end;

function _whoInPoint(tx,ty,tt:integer):integer;
var i,sc:integer;
    htm :byte;
function _ch(up:PTPlayer):boolean;
begin
   _ch:=true;
   case tt of
   1  : _ch:=up^.team<>htm;
   2  : _ch:=up^.team= htm;
   3,4: _ch:=up^.pnum= HPlayer;
   end;
end;
begin
   sc:=0;
   with _players[HPlayer]do
   begin
      sc+=ucl_cs[false];
      sc+=ucl_cs[true ];
      htm:=team;
   end;
   _whoInPoint:=0;
   if(PointInCam(tx,ty))then
    for i:=1 to MaxUnits do
     with _units[i] do
      if(hits>0)and(inapc=0)and(_ch(player))then
       if(_uvision(htm,@_units[i],false))then
        if(dist2(vx,vy,tx,ty)<uid^._r)then
        begin
           case tt of
           1,2: begin
                   if(playeri=HPlayer)and(sc=1)and(sel=true)then continue;
                   _whoInPoint:=i;
                end;
           3  : _whoInPoint:=uidi;
           else _whoInPoint:=i;
           end;
           break;
       end;
end;

procedure check_mouse_brush;
begin
   case m_brush of
   0     : m_brush:=co_empty;
   1..255:
      with _players[HPlayer] do
       if _uid_conditionals(@_players[HPlayer],m_brush)>0
       then m_brush:=co_empty
       else
       begin
          if not(m_brush in ui_prod_builds)then
          begin
             m_brush:=co_empty;
             exit;
          end;

          if(k_ctrl>1)then
          begin
             m_brushx:=mouse_map_x;
             m_brushy:=mouse_map_y;
          end
          else
          begin
             _building_newplace(mouse_map_x,mouse_map_y,m_brush,HPlayer,@m_brushx,@m_brushy);
             m_brushx:=mm3(map_b0   ,m_brushx,map_b1);
             m_brushy:=mm3(map_b0   ,m_brushy,map_b1);
             m_brushx:=mm3(vid_cam_x,m_brushx,vid_cam_x+vid_cam_w);
             m_brushy:=mm3(vid_cam_y,m_brushy,vid_cam_y+vid_cam_h);
          end;

          case _CheckBuildPlace(m_brushx,m_brushy,0,0,HPlayer,m_brush,true) of
          0 :  m_brushc:=c_lime;
          1 :  m_brushc:=c_red;
          2 :  m_brushc:=c_blue;
          else m_brushc:=c_gray;
          end;
       end;
co_paction,
co_move   ,co_patrol  ,
co_amove  ,co_apatrol : if(ui_uibtn_move=0)then m_brush:=co_empty;
   else
   end;
end;

procedure _command(x,y:integer);
var t:integer;
begin
   t:=0;
   case m_brush of
co_move    : begin                     // move
                t:=_whoInPoint(x,y,2);
                _player_s_o(co_move ,t,x,y,0,uo_corder,HPlayer);
             end;
co_amove   : begin                     // attack
                t:=_whoInPoint(x,y,1);
                _player_s_o(co_amove,t,x,y,0,uo_corder,HPlayer);
             end;
co_paction,
co_patrol,
co_apatrol : _player_s_o(m_brush,0,x,y,0,uo_corder,HPlayer);
co_empty   : begin                     // rclick
                t:=_whoInPoint(x,y,0);
                if(m_a_inv)
                then _player_s_o(co_rcmove ,t,x,y,0,uo_corder,HPlayer)
                else _player_s_o(co_rcamove,t,x,y,0,uo_corder,HPlayer);
             end;
   end;

   m_brush:=co_empty;
end;

function _rclickmove(uid:byte):boolean;
begin
   _rclickmove:=false;
   if(uid>0)then
    with _uids[uid] do
     if(_max=1)and(_UnitHaveRPoint(uid))then _rclickmove:=true;
end;

procedure _panel_click(tab,bx,by:integer;right,mid:boolean);
var u:integer;
begin
   //writeln(tab,': ',bx,', ',by);
   SoundPlayUI(snd_click);

   by-=4;// 0,0 under minimap

   case by of
   -1: case vid_ppos of   // tabs
       0,1: begin mouse_x-=vid_panelx; if(mouse_y>ui_tabsy)then ui_tab:=mm3(0,mouse_x div vid_tBW,3);mouse_x+=vid_panelx;end;
       2,3: begin mouse_y-=vid_panely; if(mouse_x>ui_tabsy)then ui_tab:=mm3(0,mouse_y div vid_tBW,3);mouse_y+=vid_panely;end;
       end;
   9 : case bx of         // buttons
       0 : ToggleMenu;
       1 : ;
       2 : if(net_status>ns_none)then TogglePause;
       end;
   else
     u:=(by*3)+(bx mod 3);

     if(0<=by)and(by<9)and(bx>=0)then
     with _players[HPlayer] do
      case tab of

0: if(G_Paused=0)and(_rpls_rst<rpl_runit)then  // buildings
   if(u<=ui_ubtns)then
   case right of
false: begin
          m_brush:=ui_panel_uids[race,0,u];
          if(_uids[m_brush]._max=1)and(uid_e[m_brush]>0)then
          begin
             _player_s_o(m_brush,k_shift,0,0,0,uo_specsel ,HPlayer);
             m_brush:=co_empty;
          end
          else check_mouse_brush;
       end;
true : if(uid_x[ui_panel_uids[race,0,u]]>0)then
        if(_rclickmove(ui_panel_uids[race,0,u]))then
         with _units[uid_x[ui_panel_uids[race,0,u]]] do _command(x,y);
   end;

1: if(G_Paused=0)and(_rpls_rst<rpl_runit)then  // units
   if(u<=ui_ubtns)then
   case right of
false: _player_s_o(co_suprod  ,ui_panel_uids[race,1,u],0,0,0, uo_corder  ,HPlayer);
true : _player_s_o(co_cuprod  ,ui_panel_uids[race,1,u],0,0,0, uo_corder  ,HPlayer);
   end;

2: if(G_Paused=0)and(_rpls_rst<rpl_runit)then  // upgrades
   if(u<=ui_ubtns)then
   case right of
false: _player_s_o(co_supgrade,ui_panel_uids[race,2,u],0,0,0, uo_corder  ,HPlayer);
true : _player_s_o(co_cupgrade,ui_panel_uids[race,2,u],0,0,0, uo_corder  ,HPlayer);
   end;

3: if(_rpls_rst<rpl_rhead)then
   begin
      if(G_Paused=0)and(right=false)then
      begin
         case u of
   0 : m_brush:=co_move;
   1 : _player_s_o(co_stand  ,0,0,0,0, uo_corder  ,HPlayer);
   2 : m_brush:=co_patrol;

   3 : m_brush:=co_amove;
   4 : _player_s_o(co_astand ,0,0,0,0, uo_corder  ,HPlayer);
   5 : m_brush:=co_apatrol;

   6 : _player_s_o(co_action ,0,0,0,0, uo_corder  ,HPlayer);
   7 : m_a_inv:=not m_a_inv;
   8 : _player_s_o(co_pcancle,0,0,0,0, uo_corder  ,HPlayer);

   9 : m_brush:=co_paction;

   10: if(ui_orders_x[10]>0)then
        if(k_dbl>0)
        then MoveCamToPoint(ui_orders_x[10], ui_orders_y[10])
        else _player_s_o(0,0,0,0,0,uo_specsel,HPlayer);
   11: _player_s_o(co_destroy,0,0,0,0, uo_corder  ,HPlayer);
         end;

         check_mouse_brush;
      end;
   end
   else
     if(u=13)then
     begin
        if(mid)
        then _rpls_step:=fr_2hfps*fr_fps
        else
          if(right=false)
          then _rpls_step:=fr_2hfps*2
          else _rpls_step:=fr_2hfps*10;
     end
     else
       if(right=false)then
        case u of
     12: _fsttime:=not _fsttime;
     14: if(_rpls_rst<rpl_end)then
          if(G_Paused>0)
          then G_Paused:=0
          else G_Paused:=200;
     15: _rpls_vidm:=not _rpls_vidm;
     16: _rpls_log :=not _rpls_log;
     17: _fog      :=not _fog;
 20..26: HPlayer   :=u-20;
        end;

      end;
   end;
end;

procedure _hotkeys(k:cardinal);
var ko,k2:cardinal;
begin
   if(k=sdlk_pause)
   then TogglePause
   else
      case k of
      sdlk_tab: begin
                   ui_tab+=1;
                   ui_tab:=ui_tab mod 4;
                end;
      1       : ;
      else
        if(_testmode>0)and(net_status=0)then
         case k of
            sdlk_end       : if(k_ctrl>2)
                             then begin if(g_mode=gm_inv)then g_inv_wave_n+=1; end
                             else _fsttime:=not _fsttime;
            sdlk_home      : _warpten:=not _warpten;
            sdlk_pageup    : with _players[HPlayer] do if(state=PS_Play)then state:=PS_Comp else state:=PS_Play;
            sdlk_pagedown  : with _players[HPlayer] do if(upgr[upgr_invuln]=0)then upgr[upgr_invuln]:=1 else upgr[upgr_invuln]:=0;
            sdlk_backspace : _fog:=not _fog;
            SDLK_F5        : begin HPlayer:=0;exit end;
            SDLK_F6        : begin HPlayer:=1;exit end;
            SDLK_F7        : begin HPlayer:=2;exit end;
            SDLK_F8        : begin HPlayer:=3;exit end;
            SDLK_F9        : begin HPlayer:=4;exit end;
            SDLK_F10       : begin HPlayer:=5;exit end;
            SDLK_F11       : begin HPlayer:=6;exit end;
            sdlk_insert    : r_draw:= not r_draw;
         end;

        if(_rpls_rst<rpl_rhead)then
        begin
           k2:=0;
           if(k_ctrl >1)then k2:=SDLK_LCtrl;
           if(k_alt  >1)then k2:=SDLK_LAlt;
           if(k_shift>1)then k2:=SDLK_LShift;
           case ui_tab of
        0,1,2:for ko:=0 to _mhkeys do
              begin
                 if(_hotkey2[ko]<>k2)
                 or(_hotkey1[ko]= 0 )
                 or(_hotkey1[ko]<>k )then continue;
                 _panel_click(ui_tab,ko mod 3,4+(ko div 3),false,false);
                 exit;
              end;
           end;

           if(G_Paused=0)then
           begin
              for ko:=0 to _mhkeys do  // actions
               if(k=_hotkeyA[ko])then
               begin
                  if(_hotkeyA[ko]=0)then continue;
                  _panel_click(3,ko mod 3,4+(ko div 3),false,false);
                  exit;
               end;

              case k of
           sdlk_0..sdlk_9 :  begin
                                ko:=_event^.key.keysym.sym-sdlk_0;
                                if (k_ctrl>1)
                                then _player_s_o(ko,0,0,0,0,uo_setorder,HPlayer)
                                else
                                  if (k_alt>1)
                                  then _player_s_o(ko,0,0,0,0,uo_addorder,HPlayer)
                                  else
                                    if(k_dbl>0)and(ui_orders_x[ko]>0)and(ko>0)
                                    then MoveCamToPoint(ui_orders_x[ko] , ui_orders_y[ko])
                                    else _player_s_o(ko,k_shift,0,0,0,uo_selorder,HPlayer);
                             end;

              else
              end;
           end;
        end
        else
          for ko:=0 to 14 do  // actions
           if(k=_hotkeyR[ko])and(_hotkeyR[ko]>0)then
           begin
              _panel_click(3,ko mod 3,16+(ko div 3),k_ctrl>1,k_alt>1);
              exit;
           end;

      end;
   k_dbl:=fr_4hfps;
end;

procedure _keyp(i:pbyte);
begin
   if(i^>1)and(i^<255)then i^+=1;
   if(i^=1)then i^:=0;
end;

procedure WindowEvents;
begin
   _keyp(@k_u    ); // arrows
   _keyp(@k_d    );
   _keyp(@k_r    );
   _keyp(@k_l    );
   _keyp(@k_shift);
   _keyp(@k_ctrl );
   _keyp(@k_alt  );
   _keyp(@k_ml   ); // mouse btns
   _keyp(@k_mr   );
   _keyp(@k_chart); // last key
   if(k_dbl>0)then k_dbl-=1;

   if(k_chart>k_chrtt)then
    if(length(k_keyboard_string)<255)then k_keyboard_string:=k_keyboard_string+k_char;

   while (SDL_PollEvent( _event )>0) do
    case (_event^.type_) of
      SDL_MOUSEMOTION    : begin
                              if(m_vmove)and(_menu=false)and(G_Started)then
                              begin
                                 vid_cam_x-=_event^.motion.x-mouse_x;
                                 vid_cam_y-=_event^.motion.y-mouse_y;
                                 _view_bounds;
                              end;
                              mouse_x:=_event^.motion.x;
                              mouse_y:=_event^.motion.y;
                           end;
      SDL_MOUSEBUTTONUP  : case (_event^.button.button) of
                            SDL_BUTTON_LEFT   : k_ml:=1;
                            SDL_BUTTON_RIGHT  : k_mr:=1;
                            SDL_BUTTON_MIDDLE : m_vmove:=false;
                           else
                           end;
      SDL_MOUSEBUTTONDOWN: case (_event^.button.button) of
                            SDL_BUTTON_LEFT      : if(k_ml=0)then k_ml:=2;
                            SDL_BUTTON_RIGHT     : if(k_mr=0)then k_mr:=2;
                            SDL_BUTTON_MIDDLE    : if(_menu=false)and(G_Started)and(_rpls_vidm=false)then m_vmove:=true;
                            SDL_BUTTON_WHEELDOWN : if(_menu)then
                                                   begin
                                                      vid_menu_redraw:=true;
                                                      case menu_item of
                                                      98: ScrollInt(@_cmp_sm ,1,0,MaxMissions-vid_camp_m);
                                                      36: ScrollInt(@_svld_sm,1,0,_svld_ln-vid_svld_m-1 );
                                                      41: ScrollInt(@_rpls_sm,1,0,_rpls_ln-vid_rpls_m-1 );
                                                      end;
                                                   end
                                                   else tmpmid-=1;
                            SDL_BUTTON_WHEELUP   : if(_menu)then
                                                   begin
                                                      vid_menu_redraw:=true;
                                                      case menu_item of
                                                      98: ScrollInt(@_cmp_sm ,-1,0,MaxMissions-vid_camp_m);
                                                      36: ScrollInt(@_svld_sm,-1,0,_svld_ln-vid_svld_m-1 );
                                                      41: ScrollInt(@_rpls_sm,-1,0,_rpls_ln-vid_rpls_m-1 );
                                                      end;
                                                   end
                                                   else tmpmid+=1;
                           else
                           end;
      SDL_QUITEV         : _CYCLE:=false;
      SDL_KEYUP          : begin
                              k_chart:=1;
                              case (_event^.key.keysym.sym) of
                                sdlk_up     : k_u    :=1;
                                sdlk_down   : k_d    :=1;
                                sdlk_left   : k_l    :=1;
                                sdlk_right  : k_r    :=1;
                                sdlk_rshift : k_shift:=1;
                                sdlk_lshift : k_shift:=1;
                                sdlk_lctrl  : k_ctrl :=1;
                                sdlk_rctrl  : k_ctrl :=1;
                                sdlk_lalt   : k_alt  :=1;
                                sdlk_ralt   : k_alt  :=1;
                              else
                              end;
                           end;
      SDL_KEYDOWN        : begin
                              k_chart  :=2;
                              k_char   :=Widechar(_event^.key.keysym.unicode);
                              k_keyboard_string:=k_keyboard_string+k_char;

                              case (_event^.key.keysym.sym) of
                                sdlk_up     : if(k_u    =0)then k_u    :=2;
                                sdlk_down   : if(k_d    =0)then k_d    :=2;
                                sdlk_left   : if(k_l    =0)then k_l    :=2;
                                sdlk_right  : if(k_r    =0)then k_r    :=2;
                                sdlk_rshift : if(k_shift=0)then k_shift:=2;
                                sdlk_lshift : if(k_shift=0)then k_shift:=2;
                                sdlk_rctrl  : if(k_ctrl =0)then k_ctrl :=2;
                                sdlk_lctrl  : if(k_ctrl =0)then k_ctrl :=2;
                                sdlk_ralt   : if(k_alt  =0)then k_alt  :=2;
                                sdlk_lalt   : if(k_alt  =0)then k_alt  :=2;
                                sdlk_print  : _screenshot;
                                sdlk_escape : escape_key;
                                sdlk_return : return_key;
                              else
                                if(_menu=false)and(G_Started)and(ingame_chat=false)then _hotkeys(_event^.key.keysym.sym);
                              end;
                           end;
    else
    end;
end;

procedure ui_SicpleClick;
var u:integer;
begin
   u:=_whoInPoint(mouse_map_x,mouse_map_y,4);
   if(u>0)then ui_UnitSelectedNU:=u;
end;

procedure g_mouse;
var u:integer;
begin
   mouse_map_x :=mouse_x+vid_cam_x-vid_mapx;
   mouse_map_y :=mouse_y+vid_cam_y-vid_mapy;
   if(vid_ppos<2)then
   begin
      u:=mouse_x-vid_panelx;m_bx:=u div vid_BW;if(u<0)then m_bx-=1;
      u:=mouse_y-vid_panely;m_by:=u div vid_BW;if(u<0)then m_by-=1;
   end
   else
   begin
      u:=mouse_y-vid_panely;m_bx:=u div vid_BW;if(u<0)then m_bx-=1;
      u:=mouse_x-vid_panelx;m_by:=u div vid_BW;if(u<0)then m_by-=1;
   end;

   if(m_ldblclk>0)then m_ldblclk-=1;

   check_mouse_brush;

   if(k_ml=2)then                    // LMB down
    if(m_bx<0)or(3<=m_bx)then        // map
     case m_brush of
co_empty  : begin
               mouse_select_x0:=mouse_map_x;
               mouse_select_y0:=mouse_map_y;
               //_missile_add(vid_cam_x+400,vid_cam_y+250,mouse_map_x,mouse_map_y,0,tmpmid,HPlayer,uf_ground,false);
               //_effect_add(mouse_map_x,mouse_map_y-50,10000,EID_HCC);
               //PlaySoundSet(snd_engineer_attack);
            end;
1..255    : if(m_brushc=c_lime)
            then _player_s_o(m_brushx,m_brushy,m_brush,0,0, uo_build  ,HPlayer)
            else SoundPlayAnoncer(snd_cannot_build[_players[HPlayer].race]);
co_paction,
co_move,
co_amove,
co_patrol,
co_apatrol: _command(mouse_map_x,mouse_map_y);
     end
    else
      if(m_by<3)then      // minimap
      case m_brush of
      co_paction,
      co_move,
      co_amove,
      co_patrol,
      co_apatrol : _command(trunc((mouse_x-vid_panelx)/map_mmcx),trunc((mouse_y-vid_panely)/map_mmcx));
      else         if(_rpls_vidm=false)then m_mmap_move:=true;
      end
      else _panel_click(ui_tab,m_bx,m_by,false,false);     // panel


   if(k_ml=1)then  // LMB up
   begin
      m_mmap_move:=false;

      if(mouse_select_x0>-1)then //select
      begin
         if(m_ldblclk>0)then
            if(k_shift<2)
            then _player_s_o(vid_cam_x,vid_cam_y, vid_cam_x+vid_cam_w,vid_cam_y+vid_cam_h,_whoInPoint(mouse_map_x,mouse_map_y,3), uo_dblselect  ,HPlayer)
            else _player_s_o(vid_cam_x,vid_cam_y, vid_cam_x+vid_cam_w,vid_cam_y+vid_cam_h,_whoInPoint(mouse_map_x,mouse_map_y,3), uo_adblselect ,HPlayer)
         else
         begin
            if(k_shift<2)
            then _player_s_o(mouse_select_x0,mouse_select_y0,mouse_map_x,mouse_map_y,0,uo_select ,HPlayer)
            else _player_s_o(mouse_select_x0,mouse_select_y0,mouse_map_x,mouse_map_y,0,uo_aselect,HPlayer);

            if(G_Paused=0)and(_rpls_rst<rpl_runit)then
             if(CheckSimpleClick(mouse_select_x0,mouse_select_y0,mouse_map_x,mouse_map_y))then ui_SicpleClick;
         end;

         mouse_select_x0:=-1;
         m_ldblclk:=fr_4hfps;
      end;
   end;

   if(m_mmap_move)and(mouse_select_x0=-1)then
   begin
      MoveCamToPoint(trunc((mouse_x-vid_panelx)/map_mmcx), trunc((mouse_y-vid_panely)/map_mmcx));
      _view_bounds;
   end;

   //if(k_mr=2)then _effect_add(mouse_map_x,mouse_map_y-50,10000,EID_HMU);

   if(k_mr=2)then                 // RMB down
    if(m_brush<>co_empty)
    then m_brush:=co_empty
    else
     if(m_bx<0)or(3<=m_bx)        // map
     then _command(mouse_map_x,mouse_map_y)
     else
       if(m_by<3)                 // minimap
       then _command(trunc((mouse_x-vid_panelx)/map_mmcx), trunc((mouse_y-vid_panely)/map_mmcx))
       else _panel_click(ui_tab,m_bx,m_by,true,false);     // panel
end;

procedure _move_v_m;
begin
   if(mouse_x<vid_vmb_x0)then vid_cam_x-=vid_vmspd;
   if(mouse_y<vid_vmb_y0)then vid_cam_y-=vid_vmspd;
   if(mouse_x>vid_vmb_x1)then vid_cam_x+=vid_vmspd;
   if(mouse_y>vid_vmb_y1)then vid_cam_y+=vid_vmspd;
end;

procedure _view_move;
var vx,vy:integer;
begin
   vx:=vid_cam_x;
   vy:=vid_cam_y;

   if(vid_vmm)then _move_v_m;

   if(k_u>1)then vid_cam_y-=vid_vmspd;
   if(k_l>1)then vid_cam_x-=vid_vmspd;
   if(k_d>1)then vid_cam_y+=vid_vmspd;
   if(k_r>1)then vid_cam_x+=vid_vmspd;

   if(vx<>vid_cam_x)or(vy<>vid_cam_y)then _view_bounds;
end;

procedure g_keyboard;
begin
   if(m_vmove=false)and(_rpls_vidm=false)then _view_move;
   if(ingame_chat)then net_chat_str:=menu_sf(net_chat_str,k_kbstr,ChatLen2);
end;

procedure InputGame;
begin
   WindowEvents;

   if(_menu)
   then g_menu
   else
   begin
      g_keyboard;
      g_mouse;
   end;
end;



