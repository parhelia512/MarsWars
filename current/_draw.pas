

procedure d_AddObjSprites(noanim:boolean);
begin
     map_sprites(noanim);
    unit_sprites(noanim);
 effects_sprites(noanim,r_draw);
missiles_sprites(noanim,r_draw);
end;

procedure d_Game;
begin
   d_AddObjSprites(G_Paused>0);

   d_terrain   (r_screen,vid_mapx,vid_mapy);
   d_SpriteList(r_screen,vid_mapx,vid_mapy);
   d_foglayer  (r_screen,vid_mapx,vid_mapy);
   d_ui        (r_screen,vid_mapx,vid_mapy);

   _draw_surf(r_screen,vid_panelx,vid_panely,r_uipanel);

   d_uimouse(r_screen);

   if(_testmode>1)and(net_nstate=0)then _draw_dbg;
end;


procedure DrawGame;
begin
   sdl_FillRect(r_screen,nil,0);

   if(_menu)
   then d_Menu
   else d_Game;

   //_drawMWSModel(@spr_HCC);

   if(_testmode>0)then _draw_text(r_screen,vid_cam_w,0,
   c2s(fps_tt)+' '+b2pm[_fsttime]+' '+i2s(mouse_map_x div pf_pathmap_w)+' '+i2s(mouse_map_y div pf_pathmap_w)+' '+w2s(pf_pathgrid_areas[mm3(0,mouse_map_x div pf_pathmap_w,pf_pathmap_c),mm3(0,mouse_map_y div pf_pathmap_w,pf_pathmap_c)]),
   ta_right,255, c_white);

   sdl_flip(r_screen);
end;



