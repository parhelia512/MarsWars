
////////////////////////////////////////////////////////////////////////////////
//
//  COMMON

procedure D_menu_ScrollBar(tar:pSDL_Surface;mi:byte;scrolli,scrolls,scrollmax:integer);
var posCY,
    barh:integer;
begin
   with menu_items[mi] do
   begin
      barh :=(mi_y1-mi_y0);
      if(scrolls<scrollmax)then
      begin
         barh :=mm3i(1,round((mi_y1-mi_y0)*(scrolls/scrollmax)),barh);
         posCY:=mi_y0+round((mi_y1-mi_y0-barh)*(scrolli/(scrollmax-scrolls)));
      end
      else posCY:=mi_y0;

      vlineColor(tar,mi_x0+1,posCY,posCY+barh,c_lime);
      vlineColor(tar,mi_x0+2,posCY,posCY+barh,c_lime);
   end;
end;

function mic(enable,selected:boolean):cardinal;
begin
   mic:=c_white;
   if(not enable)then mic:=c_gray
   else
     if(selected)then mic:=c_yellow;
end;
procedure D_menu_EText(tar:pSDL_Surface;me,halignment,valignment:byte;text:shortstring;listarrow:boolean;selected:byte;color:cardinal);
const larrow_w  = 13;
      larrow_hw = larrow_w div 2;
var tx,tx1,ty:integer;
begin
   with menu_items[me] do
   if(mi_x0>0)then
   begin
      tx:=mi_x0;
      ty:=mi_y0;
      if(listarrow)
      then tx1:=max2i(mi_x0,mi_x1-larrow_w)
      else tx1:=mi_x1;
      if(not mi_enabled)then listarrow:=false;
      case halignment of
      ta_left    : tx:=mi_x0+font_34;
      ta_middle  : tx:=(mi_x0+tx1) div 2;
      ta_right   : tx:=tx1-font_34;
      ta_rightmid: begin
                   tx:=((mi_x0+mi_x1) div 2)+font_34;
                   halignment:=ta_left;
                   end;
      ta_x0y0    : begin
                   tx:=mi_x0+font_hw;
                   halignment:=ta_left;
                   end;
      ta_x1y1    : begin
                   tx:=tx1-font_hhw;
                   halignment:=ta_right;
                   end;
      end;
      case valignment of
      ta_x0y0    : ty:= mi_y0+font_hw;
      ta_x1y1    : ty:= mi_y1-font_hhw-font_w;
      ta_left    : ty:= mi_y0+font_34;
      ta_middle  : ty:=((mi_y0+mi_y1) div 2)-font_hw+1;
      ta_right   : ty:= mi_y1-font_3hw;
      end;

      if(color=0)
      then color:=mic(mi_enabled,((selected>0) or listarrow)and((menu_item=me)or(selected>1)));

      draw_text(tar,tx,ty,text,halignment,255,color);

      if(listarrow)then characterColor(tar,tx1+larrow_hw-font_hw,ty,#31,c_white);
   end;
end;

procedure D_menu_ValBar(tar:pSDL_Surface;mi:byte;val,max:integer);
var tx0,tx1:integer;
begin
   with menu_items[mi] do
   begin
      tx1:=mi_x1-font_w;
      tx0:=tx1-max;
      vlineColor(tar,tx0,mi_y0+1,mi_y1,c_gray);
      vlineColor(tar,tx1,mi_y0+1,mi_y1,c_gray);
      boxColor  (tar,tx0,mi_y0+font_hw+1,tx0+val,mi_y1-font_hw,c_lime);

      draw_text(tar,tx0-font_34,((mi_y0+mi_y1) div 2)-font_hw+1,i2s(round(val/max*100))+'%',ta_right,255,c_white);
   end;
end;
procedure D_menu_ETextD(tar:pSDL_Surface;mi:byte;l_text,r_text:shortstring;listarrow:boolean;selected:byte;color:cardinal);
begin
   D_menu_EText(tar,mi,ta_left  ,ta_middle,l_text,false    ,byte(listarrow)+selected,color);
   D_menu_EText(tar,mi,ta_right ,ta_middle,r_text,listarrow,selected                ,color);
end;
procedure D_menu_ETextN(tar:pSDL_Surface;mi:byte;l_text,r_text:shortstring;listarrow:boolean;selected:byte;color:cardinal);
begin
   D_menu_EText(tar,mi,ta_left    ,ta_middle,l_text,false    ,byte(listarrow)+selected,color);
   D_menu_EText(tar,mi,ta_rightmid,ta_middle,r_text,listarrow,selected                ,color);
   with menu_items[mi] do vlineColor(tar,(mi_x0+mi_x1) div 2,mi_y0+1,mi_y1,c_gray);
end;

////////////////////////////////////////////////////////////////////////////////
//
//  DRAW SECTIONS

procedure D_MMap(tar:pSDL_Surface);
var i:integer;
begin
   draw_text(tar, ui_menu_map_cx, ui_menu_map_cy, str_MMap, ta_middle,255, c_white);

   if(menu_s2=ms2_camp)then
   begin
      //draw_surf(tar, 91 ,129,campain_mmap  [campain_mission_n]);
      //draw_text(tar, 252,132,str_camp_m[campain_mission_n], ta_left,255, c_white);
   end
   else
   begin
      i:=0;
      while (i<=ui_menu_map_ph) do
      begin
         hlineColor(tar,ui_menu_map_px0,ui_menu_map_px1,ui_menu_map_py0+i,c_ltgray);
         i+=ui_menu_map_lh;
      end;
      vlineColor(tar,ui_menu_map_px0,ui_menu_map_py0,ui_menu_map_py1,c_ltgray);
      vlineColor(tar,ui_menu_map_px1,ui_menu_map_py0,ui_menu_map_py1,c_ltgray);

      D_menu_EText (tar,mi_map_params1,ta_middle,ta_middle,g_presets[g_preset_cur].gp_name
                                                                              ,true ,0,0);
      D_menu_EText (tar,mi_map_params2,ta_middle,ta_middle,c2s(map_seed)      ,false,1,0);

      D_menu_ETextD(tar,mi_map_params3,str_map_size,i2s(map_size)               ,true ,0,0);
      D_menu_ETextD(tar,mi_map_params4,str_map_type,str_map_typel[map_type]   ,true ,0,0);
      D_menu_ETextD(tar,mi_map_params5,str_map_sym ,str_map_syml[map_symmetry],true ,0,0);

      D_menu_EText (tar,mi_map_params6,ta_middle,ta_middle,str_mrandom        ,false,0,0);
      D_menu_EText (tar,mi_map_params7,ta_middle,ta_middle,theme_name[theme_cur],false,0,0);
   end;
end;

procedure D_MPlayers(tar:pSDL_Surface);
var y,u:integer;
   p,p0:byte;
   tstr:shortstring;
function _yl(s:integer):integer;begin _yl:=s*ui_menu_pls_lh; end;
function _yt(s:integer):integer;begin _yt:=_yl(s)+font_34; end;
begin
   if(menu_s2=ms2_camp)then
   begin
      draw_text(tar,ui_menu_pls_cptx, ui_menu_pls_cpty, str_MObjectives, ta_middle,255, c_white);

      //draw_text(tar, ui_menu_pls_xc , ui_menu_pls_zy0+_yt(0)  ,str_camp_t[campain_mission_n],ta_middle,255,c_white);
      //draw_text(tar, ui_menu_pls_zxn, ui_menu_pls_zy0+_yt(1)+8,str_camp_o[campain_mission_n],ta_left  ,255,c_white);
   end
   else
     if(net_svsearch)then
     begin
        draw_text(tar,ui_menu_pls_cptx, ui_menu_pls_cpty, str_MServers+'('+i2s(net_svsearch_listn)+')', ta_middle,255, c_white);

        with menu_items[mi_mplay_NetSearchList] do
        begin
           hlineColor(tar,mi_x0,mi_x1,mi_y0,c_white);
           hlineColor(tar,mi_x0,mi_x1,mi_y1,c_white);

           if(net_svsearch_listn>0)then
            for u:=0 to vid_srch_m do
            begin
               p:=u+net_svsearch_scroll;
               if(p<net_svsearch_listn)then
                with net_svsearch_list[p] do
                begin
                   y:=mi_y0+(u*ui_menu_nsrch_lh3);
                   if(p=net_svsearch_sel)then boxColor(tar,mi_x0,y+1,mi_x1,y+ui_menu_nsrch_lh3,c_dgray);
                   hlineColor(tar,mi_x0,mi_x1,y+ui_menu_nsrch_lh3,c_white);
                   draw_text(tar,mi_x0+3,y+font_hw,i2s(p+1)+')'+info,ta_left,ui_menu_chat_width,c_white);
                end;
            end;
        end;

        D_menu_ScrollBar(tar,mi_mplay_NetSearchList,net_svsearch_scroll,vid_srch_m+1,net_svsearch_listn);
        D_menu_EText(tar,mi_mplay_NetSearchCon,ta_middle,ta_middle,str_connect[false],false,0,0);
     end
     else
     begin
        draw_text(tar, ui_menu_pls_cptx, ui_menu_pls_cpty, str_MPlayers, ta_middle,255, c_white);

        vlineColor(tar, ui_menu_pls_cx_race , ui_menu_pls_pby0, ui_menu_pls_pby1,c_gray);
        vlineColor(tar, ui_menu_pls_cx_team , ui_menu_pls_pby0, ui_menu_pls_pby1,c_gray);
        vlineColor(tar, ui_menu_pls_cx_color, ui_menu_pls_pby0, ui_menu_pls_pby1,c_gray);

        for p:=1 to MaxPlayers do
         with g_players[p] do
         begin
            y:=ui_menu_pls_pby0+_yl(p-1);
            u:=ui_menu_pls_pby0+_yt(p-1);
            p0:=p-1;

            hlineColor(tar,ui_menu_pls_pbx0,ui_menu_pls_pbx1,y,c_gray);

            case g_slot_state[p] of
            ps_observer,
            ps_closed,
            ps_opened   : if(state>ps_none)then
                          begin
                             D_menu_EText(tar,mi_player_status1+p0,ta_x0y0 ,ta_x0y0 ,name,true,0,c_white);
                             if(state=ps_play)and(net_status<>ns_single)then
                             begin
                                if(p=PlayerLobby)
                                then tstr:=str_server
                                else
                                  if(isready)
                                  then tstr:=str_ready
                                  else tstr:=str_nready;
                                D_menu_EText(tar,mi_player_status1+p0,ta_x1y1,ta_x1y1,tstr,true,0,c_ltgray);
                             end
                             else D_menu_EText(tar,mi_player_status1+p0,ta_x1y1,ta_x1y1,str_PlayerSlots[g_slot_state[p]],true ,0,c_ltgray);
                          end
                          else
                          begin
                             if(g_ai_slots >0)and(g_slot_state[p]=ps_opened)then
                             D_menu_EText(tar,mi_player_status1+p0,ta_x0y0,ta_x0y0,str_PlayerSlots[ps_AI_1+g_ai_slots-1],false,0,c_ltgray);

                             D_menu_EText(tar,mi_player_status1+p0,ta_x1y1,ta_x1y1,str_PlayerSlots[g_slot_state[p]],true ,0,c_ltgray);
                          end;
            ps_AI_1..
            ps_AI_11    : if(state>ps_none)
                          then D_menu_EText(tar,mi_player_status1+p0,ta_x0y0 ,ta_x0y0 ,name                         ,true,0,0);
            end;

            D_menu_EText(tar,mi_player_race1+p0,ta_middle,ta_middle,str_racel[slot_race]                  ,true,0,0);
            D_menu_EText(tar,mi_player_team1+p0,ta_middle,ta_middle,str_teams[PlayerGetTeam(g_mode,p,255)],true,0,0);

            boxColor(tar,ui_menu_pls_color_x0,y+ui_menu_pls_border,
                         ui_menu_pls_color_x1,y-ui_menu_pls_border+ui_menu_pls_lh,PlayerGetColor(p));
         end;

        hlineColor(tar,ui_menu_pls_pbx0,ui_menu_pls_pbx1,ui_menu_pls_pby1,c_gray);
     end;
end;

procedure D_M1(tar:pSDL_Surface);
var t,i,y:integer;
function _yl(s:integer):integer;begin _yl:=ui_menu_ssr_zy0+s*ui_menu_ssr_lh+1; end;
begin

   D_menu_EText(tar,mi_tab_settings,ta_middle,ta_middle,str_menu_s1[ms1_sett],false,1+byte(menu_s1=ms1_sett),0);
   D_menu_EText(tar,mi_tab_saveload,ta_middle,ta_middle,str_menu_s1[ms1_svld],false,1+byte(menu_s1=ms1_svld),0);
   D_menu_EText(tar,mi_tab_replays ,ta_middle,ta_middle,str_menu_s1[ms1_reps],false,1+byte(menu_s1=ms1_reps),0);

   hlineColor(tar,ui_menu_ssr_zx0,ui_menu_ssr_zx1,ui_menu_ssr_zy0+ui_menu_ssr_lh,c_ltgray);

   i:=ui_menu_ssr_zx0+ui_menu_ssr_cw;
   t:=ui_menu_ssr_zy0;
   while (i<ui_menu_ssr_zx1) do
   begin
      vlineColor(tar,i,t,t+ui_menu_ssr_lh,c_ltgray);
      i+=ui_menu_ssr_cw;
   end;


   case menu_s1 of
   ms1_sett : begin
                 D_menu_EText(tar,mi_settings_game ,ta_middle,ta_middle,str_menu_s3[ms3_game],false,1+byte(menu_s3=ms3_game),0);
                 D_menu_EText(tar,mi_settings_video,ta_middle,ta_middle,str_menu_s3[ms3_vido],false,1+byte(menu_s3=ms3_vido),0);
                 D_menu_EText(tar,mi_settings_sound,ta_middle,ta_middle,str_menu_s3[ms3_sond],false,1+byte(menu_s3=ms3_sond),0);

                 t:=_yl(2);
                 hlineColor(tar,ui_menu_ssr_zx0,ui_menu_ssr_zx1,t,c_ltgray);

                 i:=ui_menu_ssr_zx0+ui_menu_ssr_cw;
                 while(i<ui_menu_ssr_zx1)do
                 begin
                    vlineColor(tar,i,t,t-ui_menu_ssr_lh,c_ltgray);
                    i+=ui_menu_ssr_cw;
                 end;

                 t:=_yl(3);
                 while(t<ui_menu_ssr_zy1)do
                 begin
                    hlineColor(tar,ui_menu_ssr_zx0,ui_menu_ssr_zx1,t,c_gray);
                    t+=ui_menu_ssr_lh;
                 end;


                 case menu_s3 of
       ms3_game: begin
                    D_menu_ETextD(tar,mi_settings_ColoredShadows ,str_ColoredShadow  ,str_bool[vid_ColoredShadow]  ,false,0,0);
                    D_menu_ETextD(tar,mi_settings_ShowAPM        ,str_APM            ,str_bool[vid_APM]            ,false,0,0);
                    D_menu_ETextD(tar,mi_settings_HitBars        ,str_uhbar          ,str_uhbars[vid_uhbars]   ,true ,0,0);
                    D_menu_ETextD(tar,mi_settings_MRBAction      ,str_maction        ,str_mactionl[m_action]   ,true ,0,0);

                    D_menu_ETextD(tar,mi_settings_ScrollSpeed    ,str_scrollspd      ,''                       ,false,0,0);
                    D_menu_ValBar(tar,mi_settings_ScrollSpeed    ,vid_CamSpeed,max_CamSpeed);

                    D_menu_ETextD(tar,mi_settings_MouseScroll    ,str_mousescrl      ,str_bool[vid_CamMScroll]     ,false,0,0);

                    D_menu_ETextN(tar,mi_settings_PlayerName     ,str_plname         ,PlayerName               ,false,1,0);

                    D_menu_ETextD(tar,mi_settings_Langugage      ,str_language       ,str_lng[ui_language]     ,true ,0,0);
                    D_menu_ETextD(tar,mi_settings_PanelPosition  ,str_panelpos       ,str_panelposp[vid_PannelPos]  ,true ,0,0);
                    D_menu_ETextD(tar,mi_settings_PlayerColors   ,str_pcolor         ,str_pcolors[vid_plcolors],true ,0,0);
                 end;

       ms3_vido: begin
                    D_menu_ETextD(tar,mi_settings_ResWidth       ,str_resol_width    ,i2s(menu_res_w)          ,true ,0,0);
                    D_menu_ETextD(tar,mi_settings_ResHeight      ,str_resol_height   ,i2s(menu_res_h)          ,true ,0,0);
                    D_menu_EText (tar,mi_settings_ResApply       ,ta_middle,ta_middle,str_apply                ,false,0,0);

                    D_menu_ETextD(tar,mi_settings_Fullscreen     ,str_fullscreen     ,str_bool[not vid_fullscreen] ,false,0,0);
                    D_menu_ETextD(tar,mi_settings_ShowFPS        ,str_fps            ,str_bool[vid_fps]            ,false,0,0);
                 end;

       ms3_sond: begin
                    D_menu_ETextD(tar,mi_settings_SoundVol       ,str_soundvol       ,''                       ,false,0,0);
                    D_menu_ValBar(tar,mi_settings_SoundVol       ,round(snd_svolume1*max_svolume),max_svolume);

                    D_menu_ETextD(tar,mi_settings_MusicVol       ,str_musicvol       ,''                       ,false,0,0);
                    D_menu_ValBar(tar,mi_settings_MusicVol       ,round(snd_mvolume1*max_svolume),max_svolume);

                    D_menu_EText (tar,mi_settings_NextTrack      ,ta_middle,ta_middle,str_NextTrack            ,false,0,0);
                 end;
                 end;
              end;
   ms1_svld : begin
                 vlineColor(tar,ui_menu_ssr_cx,_yl(1)+1,_yl(12),c_gray);

                 i:=_yl(12);
                 hlineColor(tar,ui_menu_ssr_zx0,ui_menu_ssr_cx,i-ui_menu_ssr_lh,c_gray);
                 hlineColor(tar,ui_menu_ssr_zx0,ui_menu_ssr_zx1,i,c_gray);
                 t:=ui_menu_ssr_zx0+ui_menu_ssr_cw;
                 vlineColor(tar,t,i,i+ui_menu_ssr_lh,c_gray);
                 t+=ui_menu_ssr_cw;
                 vlineColor(tar,t,i,i+ui_menu_ssr_lh,c_gray);

                 D_menu_EText (tar,mi_saveload_fname ,ta_left  ,ta_middle,svld_str_fname,false,1,0);

                 D_menu_EText (tar,mi_saveload_save  ,ta_middle,ta_middle,str_save      ,false,0,0);
                 D_menu_EText (tar,mi_saveload_load  ,ta_middle,ta_middle,str_load      ,false,0,0);
                 D_menu_EText (tar,mi_saveload_delete,ta_middle,ta_middle,str_delete    ,false,0,0);

                 for t:=0 to vid_svld_m do
                 begin
                    i:=t+svld_list_scroll;
                    if(i<svld_list_size)then
                    begin
                       y:=_yl(t+1);
                       if(i=svld_list_sel)then
                       begin
                          boxColor(tar,ui_menu_ssr_zx0,y+1,ui_menu_ssr_cx-1,y+ui_menu_ssr_lh-1,c_dgray);
                          hlineColor(tar,ui_menu_ssr_zx0,ui_menu_ssr_cx,y+1               ,c_gray);
                          hlineColor(tar,ui_menu_ssr_zx0,ui_menu_ssr_cx,y+ui_menu_ssr_lh-1,c_gray);
                       end;
                       draw_text(tar,ui_menu_ssr_zx0+font_34,y+font_34,b2s(i+1)+'.'+svld_list[i],ta_left,255,mic(true,i=svld_list_sel));
                    end;
                 end;
                 D_menu_ScrollBar(tar,mi_saveload_list,svld_list_scroll,vid_svld_m+1,svld_list_size);

                 draw_text(tar,ui_menu_ssr_cx+font_34,_yl(1)+font_34,svld_str_info,ta_left,19,c_white);
              end;
   ms1_reps : begin
                 vlineColor(tar,ui_menu_ssr_cx,_yl(1)+1,_yl(12),c_gray);

                 i:=_yl(12);
                 hlineColor(tar,ui_menu_ssr_zx0,ui_menu_ssr_zx1,i,c_gray);
                 t:=ui_menu_ssr_zx0+ui_menu_ssr_cw;
                 vlineColor(tar,t,i,i+ui_menu_ssr_lh,c_gray);
                 t+=ui_menu_ssr_cw;
                 vlineColor(tar,t,i,i+ui_menu_ssr_lh,c_gray);

                 D_menu_EText (tar,mi_replays_play  ,ta_middle,ta_middle,str_play      ,false,0,0);
                 D_menu_EText (tar,mi_replays_delete,ta_middle,ta_middle,str_delete    ,false,0,0);

                 for t:=0 to vid_rpls_m do
                 begin
                    i:=t+rpls_list_scroll;
                    if(i<rpls_list_size)then
                    begin
                       y:=_yl(t+1);
                       if(i=rpls_list_sel)then
                       begin
                          boxColor(tar,ui_menu_ssr_zx0,y+1,ui_menu_ssr_cx-1,y+ui_menu_ssr_lh-1,c_dgray);
                          hlineColor(tar,ui_menu_ssr_zx0,ui_menu_ssr_cx,y+1               ,c_gray);
                          hlineColor(tar,ui_menu_ssr_zx0,ui_menu_ssr_cx,y+ui_menu_ssr_lh-1,c_gray);
                       end;
                       draw_text(tar,ui_menu_ssr_zx0+font_34,y+font_34,TrimString(b2s(i+1)+'.'+rpls_list[i],18),ta_left,255,mic(true,i=rpls_list_sel));
                    end;
                 end;
                 D_menu_ScrollBar(tar,mi_replays_list,rpls_list_scroll,vid_rpls_m+1,rpls_list_size);

                 draw_text(tar,ui_menu_ssr_cx+font_34,_yl(1)+font_34,rpls_str_info,ta_left,19,c_white);
              end;
   end;
end;

procedure D_M2(tar:pSDL_Surface);
var t,i:integer;
function _yl(s:integer):integer;begin _yl:=ui_menu_cgm_zy0+s*ui_menu_cgm_lh+1; end;
procedure default_lines;
begin
   t:=_yl(2);
   while(t<ui_menu_cgm_zy1)do
   begin
      hlineColor(tar,ui_menu_cgm_zx0,ui_menu_cgm_zx1,t,c_gray);
      t+=ui_menu_cgm_lh;
   end;
end;
begin
   D_menu_EText (tar,mi_tab_campaing   ,ta_middle,ta_middle,str_menu_s2[ms2_camp],false,1+byte(menu_s2=ms2_camp),0);
   D_menu_EText (tar,mi_tab_game       ,ta_middle,ta_middle,str_menu_s2[ms2_game],false,1+byte(menu_s2=ms2_game),0);
   D_menu_EText (tar,mi_tab_multiplayer,ta_middle,ta_middle,str_menu_s2[ms2_mult],false,1+byte(menu_s2=ms2_mult),0);

   hlineColor(tar,ui_menu_cgm_zx0,ui_menu_cgm_zx1,ui_menu_cgm_zy0+ui_menu_cgm_lh,c_ltgray);

   i:=ui_menu_cgm_zx0+ui_menu_cgm_cw;
   t:=ui_menu_cgm_zy0;
   while (i<ui_menu_cgm_zx1) do
   begin
      vlineColor(tar,i,t,t+ui_menu_cgm_lh,c_ltgray);
      i+=ui_menu_cgm_cw;
   end;

   case menu_s2 of
   ms2_camp : begin
                 {draw_text(tar,ui_menu_csm_xt0,_yt(1),str_cmpdif+str_cmpd[campain_skill],ta_left,255,mic(not g_started,false));
                 y:=_yl(2);
                 hlineColor(tar,ui_menu_csm_x0,ui_menu_csm_x1,y,c_white);
                 for t:=1 to vid_camp_m do
                 begin
                    i:=t+_cmp_sm-1;
                    if(i=campain_mission_n)then
                    begin
                       hlineColor(tar,ui_menu_csm_x0,ui_menu_csm_x1,y,c_gray);
                       hlineColor(tar,ui_menu_csm_x0,ui_menu_csm_x1,y+ui_menu_csm_ys,c_gray);
                    end;
                    //draw_text(tar,ui_menu_csm_xt0,y+6,str_camp_t[i],ta_left,255,mic(not g_started,i=campain_mission_n));
                    y+=ui_menu_csm_ys;
                 end;}
              end;
   ms2_game : begin
                 default_lines;

                 // game options
                 D_menu_EText (tar,mi_game_GameCaption   ,ta_middle,ta_middle,str_goptions                  ,false,0,0);
                 D_menu_ETextD(tar,mi_game_mode          ,str_gmodet         ,str_gmode[g_mode]             ,true ,0,0);
                 D_menu_ETextD(tar,mi_game_builders      ,str_starta         ,b2s(g_start_base+1)           ,true ,0,0);
                 D_menu_ETextD(tar,mi_game_generators    ,str_generators     ,str_generatorsO[g_generators] ,true ,0,0);
                 D_menu_ETextD(tar,mi_game_FixStarts     ,str_fstarts        ,str_bool[g_fixed_positions]   ,false,0,0);
                 D_menu_ETextD(tar,mi_game_DeadPbserver  ,str_DeadObservers  ,str_bool[g_deadobservers]     ,false,0,0);
                 D_menu_ETextD(tar,mi_game_EmptySlots    ,str_aislots        ,ai_name(g_ai_slots)           ,true ,0,0);
                 D_menu_EText (tar,mi_game_RandomSkrimish,ta_middle,ta_middle,str_randoms                   ,false,0,0);

                 D_menu_EText (tar,mi_game_RecordCaption ,ta_middle,ta_middle,str_replay                    ,false,0,0);
                 D_menu_ETextD(tar,mi_game_RecordStatus  ,str_replay_status  ,str_rstatus[rpls_state]       ,false,0,0);
                 D_menu_ETextN(tar,mi_game_RecordName    ,str_replay_name    ,rpls_str_name                 ,false,1,0);
            if(rpls_state>rpls_state_none)and(g_cl_units>0)
            then D_menu_ETextD(tar,mi_game_RecordQuality ,str_replay_Quality ,i2s(min2i(cl_UpT_array[rpls_pnui]*4,g_cl_units))+'/'+i2s(g_cl_units)+' '+str_pnua[rpls_pnui]
                                                                                                            ,true ,0,0)
            else D_menu_ETextD(tar,mi_game_RecordQuality ,str_replay_Quality ,str_pnua[rpls_pnui]           ,true ,0,0);
              end;
   ms2_mult : begin
                 default_lines;

                 D_menu_EText (tar,mi_mplay_ServerCaption,ta_middle,ta_middle,str_server                    ,false,0,0);
                 D_menu_EText (tar,mi_mplay_ServerToggle ,ta_middle,ta_middle,str_svup[net_status=ns_server],false,0,0);
                 D_menu_ETextD(tar,mi_mplay_ServerPort   ,str_udpport        ,net_sv_pstr                   ,false,1,0);

                 D_menu_EText (tar,mi_mplay_ClientCaption,ta_middle,ta_middle,str_client                    ,false,0,0);
                 D_menu_ETextD(tar,mi_mplay_NetSearch    ,str_netsearch      ,str_bool[net_svsearch]        ,false,0,0);
                 D_menu_ETextD(tar,mi_mplay_ClientAddress,str_Address        ,net_cl_svstr                  ,false,1,0);
                 D_menu_ETextD(tar,mi_mplay_ClientConnect,str_connect[net_status=ns_client],net_status_str  ,false,0,0);
            if(g_cl_units>0)
            then D_menu_ETextD(tar,mi_mplay_ClientQuality,str_net_Quality    ,i2s(min2i(cl_UpT_array[net_pnui]*4,g_cl_units))+'/'+i2s(g_cl_units)+' '+str_pnua[net_pnui]
                                                                                                            ,true ,0,0)
            else D_menu_ETextD(tar,mi_mplay_ClientQuality,str_net_Quality    ,str_pnua[net_pnui]            ,true ,0,0);

                 {
                    y:=_yl(12);
                    hlineColor(tar,ui_menu_csm_x0,ui_menu_csm_x1,y-ui_menu_csm_ys,c_gray);
                    hlineColor(tar,ui_menu_csm_x0,ui_menu_csm_x1,y,c_gray);

                    y:=_yt(10);
                    MakeLogListForDraw(PlayerClient,ui_menu_chat_width,ui_menu_chat_height,lmts_menu_chat);
                    if(ui_log_n>0)then
                     for t:=0 to ui_log_n-1 do
                      if(ui_log_c[t]>0)then draw_text(tar,ui_menu_csm_xct,y-t*ui_menu_csm_ycs,ui_log_s[t],ta_left,255,ui_log_c[t]);

                    draw_text(tar,ui_menu_csm_xct, _yt(11), net_chat_str , ta_chat,ui_menu_chat_width, c_white);}
              end;
   end;
end;

procedure d_UpdateMenu(tar:pSDL_Surface);
begin
   draw_surf(tar,0,0,spr_mback);
   draw_text(tar,spr_mback^.w,spr_mback^.h-font_w,str_ver,ta_right,255,c_white);

   if(test_mode>0)then draw_text(tar,spr_mback^.w div 2,spr_mback^.h-font_5w,'TEST MODE '+b2s(test_mode),ta_middle,255,c_white);

   draw_text(tar,spr_mback^.w div 2,spr_mback^.h-font_w, str_cprt , ta_middle,255, c_white);

   D_menu_EText(tar,mi_exit     ,ta_middle,ta_middle,str_exit [G_Started],false,0,0);
   D_menu_EText(tar,mi_back     ,ta_middle,ta_middle,str_exit [G_Started],false,0,0);

   D_menu_EText(tar,mi_start    ,ta_middle,ta_middle,str_reset[G_Started],false,0,0);
   D_menu_EText(tar,mi_break    ,ta_middle,ta_middle,str_reset[G_Started],false,0,0);
   D_menu_EText(tar,mi_surrender,ta_middle,ta_middle,'surender',false,0,0);

   D_MMap    (tar);
   D_MPlayers(tar);
   D_M1      (tar);
   D_M2      (tar);
end;

procedure D_Menu_List;
var i,y:integer;
  color:cardinal;
begin
   menu_list_x+=menu_x;
   menu_list_y+=menu_y;
   y:=menu_list_y+(ui_menu_list_item_H*menu_list_n);
   boxColor      (r_screen,menu_list_x-menu_list_w,menu_list_y,menu_list_x,y,c_black);
   RectangleColor(r_screen,menu_list_x-menu_list_w,menu_list_y,menu_list_x,y,c_white);
   for i:=0 to menu_list_n-1 do
   with menu_list_items[i] do
   begin
      y:=menu_list_y+(ui_menu_list_item_H*i);
      color:=0;
      if(i=menu_list_selected)
      then color:=c_dgray
      else
        if(i=menu_list_current)
        then color:=c_gray;

      if(color<>0)
      then boxColor(r_screen,menu_list_x-menu_list_w+1,y+1,menu_list_x-1,y+ui_menu_list_item_H,color);

      if(mli_enabled)
      then color:=c_white
      else color:=c_gray;

      draw_text (r_screen,menu_list_x-ui_menu_list_item_S,y+ui_menu_list_item_S,mli_caption,ta_right,255,color);
      hlineColor(r_screen,menu_list_x-menu_list_w+1,menu_list_x-1,y+ui_menu_list_item_H,c_white);
   end;
   menu_list_x-=menu_x;
   menu_list_y-=menu_y;
end;

procedure D_Menu;
var i:integer;
begin
   if(menu_redraw)then
   begin
      map_RedrawMenuMinimap(vid_map_RedrawBack);
      d_UpdateMenu(r_menu);
      menu_redraw:=false;
      vid_map_RedrawBack:=false;

      if(menu_list_n>0)then
       with menu_items[menu_item] do
       begin
          boxColor(r_menu,0   ,0 ,mi_x0       ,r_menu^.h,c_ablack);
          boxColor(r_menu,mi_x1  ,0 ,r_menu^.w,r_menu^.h,c_ablack);
          boxColor(r_menu,mi_x0+1,0 ,mi_x1-1     ,mi_y0       ,c_ablack);
          boxColor(r_menu,mi_x0+1,mi_y1,mi_x1-1     ,r_menu^.h,c_ablack);
       end;
      //if false then
      {for i:=0 to 255 do
       with menu_items[i] do
        if(x0>0)then
         rectangleColor(r_menu,x0,y0,x1,y1,rgba2c(128+random(128),128+random(128),128+random(128),255));}
   end;

   draw_surf(r_screen,menu_x,menu_y,r_menu);

   if(menu_list_n>0)then D_Menu_List;

   if(vid_FPS)then draw_text(r_screen,vid_vw,2,'FPS: '+c2s(fr_FPSSecondC)+'('+c2s(fr_FPSSecondU)+')',ta_right,255,c_white);

   draw_surf(r_screen,mouse_x,mouse_y,spr_cursor);
end;


