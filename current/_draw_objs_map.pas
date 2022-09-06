

function DoodadAnimationTime(base:integer):integer;
const fr_h3fps = fr_fps div 3;
      fr_4fps  = fr_fps*4;
begin
   case base of
   -1 : DoodadAnimationTime:=random(fr_h3fps)+fr_h3fps;
   -2 : DoodadAnimationTime:=random(fr_2fps )+1;
   -3 : DoodadAnimationTime:=random(fr_fps  )+1;
   -4 : DoodadAnimationTime:=random(fr_2fps )+1;
   -5 : DoodadAnimationTime:=random(fr_3fps )+1;
   -6 : DoodadAnimationTime:=random(fr_4fps )+1;
   else if(base>0)
        then DoodadAnimationTime:=base
        else DoodadAnimationTime:=-100;
   end;
end;

procedure DoodadAnimation(d:integer;sprl:PTUSpriteList;anml:PTThemeAnimL;lst:PTIntList;lstn:pinteger;first:boolean);
begin
   if(lstn^>0)then
    with map_dds[d] do
     if(animt>0)or(first)then
     begin
        animt-=1;
        if(animt<=0)then
        begin
           if(animn<0)or(first)then
           begin
              animn:= d mod lstn^;
              animn:= lst^[animn];
           end
           else
           begin
              animn:=anml^[animn].anext;
           end;
           animt  :=DoodadAnimationTime(anml^[animn].atime);
           shadowz:= anml^[animn].sh;
           ox     := anml^[animn].xo;
           oy     := anml^[animn].yo;
           sprite :=@sprl^[animn];
           case anml^[animn].depth of
           0    : depth :=y;
           else   depth :=anml^[animn].depth;
           end;
        end;
     end;
end;

procedure map_DoodadsDraw(noanim:boolean);
var d,ro:integer;
begin
   for d:=1 to MaxDoodads do
    with map_dds[d] do
     if(t>0)then
     begin
        if(RectInCam(x,y,255,255,0)=false)then continue;

        ro:=0;
        if(1<=m_brush)and(m_brush<=255)then ro:=r-bld_dec_mr;

        if(noanim=false)or(sprite=pspr_dummy)then
        case t of
        DID_LiquidR1,
        DID_LiquidR2,
        DID_LiquidR3,
        DID_LiquidR4 : if(theme_liquid_animt<2)
                       then sprite:=@spr_liquid[((G_Step div theme_liquid_animm) mod LiquidAnim)+1,animn]
                       else sprite:=@spr_liquid[1                                                 ,animn];
        DID_Other    : DoodadAnimation(d,@theme_spr_decors,@theme_anm_decors,@theme_decors,@theme_decorn,false);
        DID_SRock    : DoodadAnimation(d,@theme_spr_srocks,@theme_anm_srocks,@theme_srocks,@theme_srockn,false);
        DID_BRock    : DoodadAnimation(d,@theme_spr_brocks,@theme_anm_brocks,@theme_brocks,@theme_brockn,false);
        end;

        if(RectInCam(x+ox,y+oy,sprite^.hw,sprite^.hh,0))then
        begin
           SpriteListAddDoodad(x,y,depth,shadowz,sprite,255,ox,oy);
           if(back_sprite<>nil)then SpriteListAddDoodad(x,y,-20000,-32000,back_sprite,255,ox,oy);
           if(ro>0)then UnitsInfoAddCircle(x,y,ro,ui_unitrR[vid_rtui>vid_rtuish]);
        end;
     end;
end;

procedure map_DoodadsDrawData;
var d:integer;
begin
   for d:=1 to MaxDoodads do
    with map_dds[d] do
     if(t>0)then
     begin
        depth  := y;
        shadowz:= -32000;
        animn  := -1;
        animt  := 0;
        ox     := 0;
        oy     := 0;
        sprite := pspr_dummy;
        back_sprite:=nil;

        case t of
        DID_LiquidR1,
        DID_LiquidR2,
        DID_LiquidR3,
        DID_LiquidR4: begin
                         depth  := -10000;
                         mmc    := theme_liquid_color;
                         animn  := t;
                         back_sprite := @spr_liquidb[animn];
                      end;
        DID_Srock  :  begin
                         mmc    := c_dgray;
                         DoodadAnimation(d,@theme_spr_srocks,@theme_anm_srocks,@theme_srocks,@theme_srockn,true);
                      end;
        DID_Brock  :  begin
                         mmc    := c_dgray;
                         DoodadAnimation(d,@theme_spr_brocks,@theme_anm_brocks,@theme_brocks,@theme_brockn,true);
                      end;
        DID_other  :  begin
                         shadowz:= 0;
                         mmc    := c_gray;
                         DoodadAnimation(d,@theme_spr_decors,@theme_anm_decors,@theme_decors,@theme_decorn,true);
                      end;
        end;

        mmx:=round(x*map_mmcx);
        mmy:=round(y*map_mmcx);
        mmr:=max2(1,round(r*map_mmcx));
     end;
end;


