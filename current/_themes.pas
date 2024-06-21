

function MakeReflectedSurface(sourceSurface:PSDL_Surface;xa,ya,transparent:boolean):PSDL_Surface;
var x,y,sx,sy:integer;
    c:cardinal;
begin
   MakeReflectedSurface:=gfx_SDLSurfaceCreate(sourceSurface^.w,sourceSurface^.h);
   for x:=1 to sourceSurface^.w do
    for y:=1 to sourceSurface^.h do
    begin
       if(xa)then sx:=sourceSurface^.w-x else sx:=x-1;
       if(ya)then sy:=sourceSurface^.h-y else sy:=y-1;
       c:=SDL_GETpixel(sourceSurface,x-1,y-1);

       SDL_SETpixel(MakeReflectedSurface,sx,sy,c);
    end;
   if(transparent)then
   begin
      if(xa)
      then x:=sourceSurface^.w-1
      else x:=0;
      SDL_SetColorKey(MakeReflectedSurface,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_getpixel(sourceSurface,x,0));
   end;
end;

procedure LoadTMWTextureList(MWTextureList:PTMWTextureList;MWTextureList_n:pinteger;fname:shortstring;addReflected:boolean);
var t:TMWTexture;
    i:integer;
procedure next;begin MWTextureList_n^+=1;setlength(MWTextureList^,MWTextureList_n^);MWTextureList^[MWTextureList_n^-1]:=t;end;
begin
   MWTextureList_n^:=0;
   i:=0;
   while true do
   begin
      with t do
      begin
         sdlSurface:=gfx_SDLSurfaceLoad(fname+i2s(i),false,false);
         if(sdlSurface=r_empty)then break;
         w :=sdlSurface^.w;
         h :=sdlSurface^.h;
         hw:=sdlSurface^.w div 2;
         hh:=sdlSurface^.h div 2;
      end;
      next;

      if(addReflected)then
      begin
         with t do sdlSurface:=MakeReflectedSurface(sdlSurface,true,false,false);
         next;
      end;

      i+=1;
   end;

   if(MWTextureList_n^=0)then
   begin
      t:=spr_dummy;
      next;
   end;
end;

procedure IntListAdd(intList:PTIntList;intListN:pinteger;value:integer);
begin
   intListN^+=1;
   setlength(intList^,intListN^);
   intList^[intListN^-1]:=value;
end;

procedure Str2IntList(intString:shortstring;intList:PTIntList;intListN:pinteger);
var p,l:integer;
    v,u:shortstring;
begin
   intListN^:=0;
   setlength(intList^,intListN^);

   l:=length(intString);
   while(l>0)do
   begin
      v:='';
      p:=pos(',',intString);
      if(p>0)then
      begin
         v:=copy(intString,1,p-1);
         delete(intString,1,p);
      end
      else
      begin
         v:=intString;
         delete(intString,1,l);
      end;

      while true do
      begin
         p:=pos(' ',v);
         if(p=0)
         then break
         else delete(v,p,1);
      end;

      if(length(v)>0)then
      begin
         p:=pos('_',v);
         if(p>0)then
         begin
            u:=copy(v,1,p-1);
            delete(v,1,p);
            if(length(u)>0)and(length(v)>0)then
            begin
               p:=s2i(u);
               l:=s2i(v);
               while (true) do
               begin
                  IntListAdd(intList,intListN,p);
                  if(p=l)
                  then break
                  else p+=sign(l-p);
               end;
            end;
         end
         else IntListAdd(intList,intListN,s2i(v));
      end;

      l:=length(intString);
   end;
end;

procedure gfx_MWTextureSetTransparent(spr:PTMWTexture;xa:boolean);
begin
   with spr^ do
    if(xa)
    then SDL_SetColorKey(sdlSurface,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_getpixel(sdlSurface,w-1,0))
    else SDL_SetColorKey(sdlSurface,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_getpixel(sdlSurface,0  ,0));
end;

procedure ThemeSetTransparent(SpriteList:pTMWTextureList;SpriteListN:integer;intString:shortstring);
var i,o,
intListN:integer;
intList :TIntList;
procedure SetParam(oid:integer);
begin
   if(oid<0)or(SpriteListN<=oid)then exit;
   gfx_MWTextureSetTransparent( @(SpriteList^[oid]),(oid mod 2)=1 );
end;
begin
   if(SpriteListN>0)then
     if(intString<>'all')then
     begin
        Str2IntList(intString,@intList,@intListN);

        if(intListN>0)then
          for i:=0 to intListN-1 do
          begin
             o:=intList[i]*2;
             SetParam(o  );
             SetParam(o+1);
          end;
     end
     else
       for o:=0 to SpriteListN-1 do SetParam(o);
end;

{procedure DecAnim(l:PTThemeDecorAnimL;it:pinteger;intString:shortstring;_at,_an,_xo,_yo,_sh,_dp:integer);
var i,o,
tmp_intListN:integer;
tmp_intList :TIntList;
procedure SetDecAnim(p:integer;xa:boolean);
begin
   with l^[p] do
   begin
      tda_atime:=_at;
      if(xa)then
      begin
         tda_anext:=_an*2+1;
         tda_xo   :=-_xo;
      end
      else
      begin
         tda_anext:=_an*2;
         tda_xo   :=_xo;
      end;
      tda_yo   :=_yo;
      tda_sh   :=_sh;
      tda_depth:=_dp;
   end;
end;
begin
   Str2IntList(intString,@tmp_intList,@tmp_intListN);

   for i:=1 to tmp_intListN do
   begin
      o:=tmp_intList[i-1]*2;
      if(0<=o)and(o<it^)then
      begin
         SetDecAnim(o  ,false);
         SetDecAnim(o+1,true );
      end;
   end;
end;
tda_depth,
tda_xo,
tda_yo,
tda_shadow,
tda_anext,
tda_atime:integer
}

procedure DecorationAnim(atime:integer;intString:shortstring);
var
tmp_il :TIntList;
tmp_iln,
i,o1,o2:integer;
procedure SetPramas(oid1,oid2:integer);
begin
   if(oid1<0)or(theme_all_decor_n<=oid1)
   or(oid2<0)or(theme_all_decor_n<=oid2)then exit;

   with theme_anm_decors[oid1] do
   begin
      tda_anext:=oid2;
      tda_atime:=atime;
   end;
end;
begin
   Str2IntList(intString,@tmp_il,@tmp_iln);

   if(tmp_iln>0)then
     for i:=0 to tmp_iln-1 do
     begin
        o1:=tmp_il[i]*2;
        o2:=tmp_il[(i+1) mod tmp_iln]*2;
        SetPramas(o1  ,o2  );
        SetPramas(o1+1,o2+1);
     end;
end;
procedure DecorationData(axo,ayo,ashadow:integer;intString:shortstring);
var
tmp_il :TIntList;
tmp_iln,
i,o    :integer;
procedure SetPramas(oid:integer;xflip:boolean);
begin
   if(0<=oid)and(oid<theme_all_decor_n)then
   with theme_anm_decors[oid] do
   begin
      if(axo    <>NOTSET)then if(xflip)
                              then tda_xo:=-axo
                              else tda_xo:= axo;
      if(ayo    <>NOTSET)then tda_yo     :=ayo;
      if(ashadow<>NOTSET)then tda_shadow :=ashadow;
   end;
end;
begin
   if(theme_all_decor_n>0)then
     if(intString<>'all')then
     begin
        Str2IntList(intString,@tmp_il,@tmp_iln);

        if(tmp_iln>0)then
          for i:=0 to tmp_iln-1 do
          begin
             o:=tmp_il[i]*2;
             SetPramas(o  ,false);
             SetPramas(o+1,true );
          end;
     end
     else
       for o:=0 to theme_all_decor_n-1 do SetPramas(o,false);
end;

procedure SetTerrainsTAS(tas,tasPeriod:byte;intString:shortstring);
var
tmp_il :TIntList;
tmp_iln,
o      :integer;
procedure SetParams(id:integer);
begin
   if(id<0)or(theme_all_terrain_n<=id)then exit;

   theme_all_terrain_tas      [id]:=tas;
   theme_all_terrain_tasPeriod[id]:=tasPeriod;
end;
begin
   if(theme_all_terrain_n>0)then
     if(intString<>'all')then
     begin
        Str2IntList(intString,@tmp_il,@tmp_iln);

        if(tmp_iln>0)then
          for o:=0 to tmp_iln-1 do SetParams(tmp_il[o]);
     end
     else
       for o:=0 to theme_all_terrain_n-1 do SetParams(o);
end;

procedure InitThemes;
var o:integer;
begin
   // load graph
   LoadTMWTextureList(@theme_all_decal_l  ,@theme_all_decal_n  ,str_f_map+'decals\adt'  ,true );
   LoadTMWTextureList(@theme_all_decor_l  ,@theme_all_decor_n  ,str_f_map+'decors\dec_' ,true );
   LoadTMWTextureList(@theme_all_terrain_l,@theme_all_terrain_n,str_f_map+'terrains\ter',false);

   // transparent

   ThemeSetTransparent(@theme_all_decal_l,theme_all_decal_n,'0_20,23_34');
   ThemeSetTransparent(@theme_all_decor_l,theme_all_decor_n,'all');

   // animation and effects
   setlength(theme_anm_decors  ,theme_all_decor_n );


   // SHADOW
   DecorationData(NOTSET,NOTSET,1     ,'0_53'          );
   DecorationData(NOTSET,NOTSET,-32000,'24_27,54_102'  );

   // X Y offset
   DecorationData(NOTSET,-3    ,NOTSET,'13,35'         );
   DecorationData(NOTSET,-4    ,NOTSET,'30,31,20,21'   );
   DecorationData(NOTSET,-5    ,NOTSET,'15_17,39,41'   );
   DecorationData(NOTSET,-5    ,NOTSET,'15_17,39,41'   );
   DecorationData(NOTSET,-8    ,NOTSET,'1,2,6,13,24_27');
   DecorationData(NOTSET,-10   ,NOTSET,'34,36,29'      );
   DecorationData(NOTSET,-14   ,NOTSET,'3'             );
   DecorationData(NOTSET,-18   ,NOTSET,'7_12,18'       );
   DecorationData(12    ,-18   ,NOTSET,'5,11'          );

   DecorationData(NOTSET,-20   ,NOTSET,'32'            );
   DecorationData(NOTSET,-21   ,NOTSET,'19'            );
   DecorationData(5     ,-22   ,NOTSET,'33'            );

   DecorationData(5     ,-22   ,NOTSET,'33'            );

   DecorationData(NOTSET,-9    ,NOTSET,'52,22'         );
   DecorationData(NOTSET,-8    ,NOTSET,'53,23'         );
   DecorationData(4     ,-8    ,NOTSET,'48_50'         );
   DecorationData(0     ,-17   ,NOTSET,'43_47'         );

   DecorationAnim(-1  ,'51,14');
   DecorationAnim(-6  ,'52,22');
   DecorationAnim(-5  ,'53,23');
   DecorationAnim(15  ,'48_50');
   DecorationAnim(15  ,'43,42');
   DecorationAnim(15  ,'44,45');
   DecorationAnim(15  ,'46,47');

   DecorationAnim(20  ,'76,80');
   DecorationAnim(20  ,'78,94');
   DecorationAnim(20  ,'79,95');
   DecorationAnim(20  ,'91,96');
   DecorationAnim(20  ,'92,97');
   DecorationAnim(20  ,'93,102');

   DecorationAnim(20  ,'54,60');
   DecorationAnim(20  ,'57,67');
   DecorationAnim(20  ,'59,68');
   DecorationAnim(20  ,'61,71');
   DecorationAnim(20  ,'62,72');
   DecorationAnim(20  ,'63,73');
   DecorationAnim(20  ,'64,74');
   DecorationAnim(20  ,'65,75');

   setlength(theme_all_terrain_mmcolor  ,theme_all_terrain_n);
   setlength(theme_all_terrain_tas      ,theme_all_terrain_n);
   setlength(theme_all_terrain_tasPeriod,theme_all_terrain_n);

   if(theme_all_terrain_n>0)then
     for o:=0 to theme_all_terrain_n-1 do
     begin
        theme_all_terrain_mmcolor  [o]:=gfx_SDLSurfaceGetColor(theme_all_terrain_l[o].sdlSurface);
        theme_all_terrain_tas      [o]:=tas_ice;
        theme_all_terrain_tasPeriod[o]:=fr_fpsd3;
     end;

   SetTerrainsTAS(tas_liquid,25,'13,20,23,28,48');
   SetTerrainsTAS(tas_liquid,15,'52,53,55,60,71,72,73,77');
end;


procedure SetThemeList(intList:PTIntList;intListN:pinteger;smax:integer;addReflected:boolean;intString:shortstring);
var i,o,
tmp_iln:integer;
tmp_il :TIntList;
begin
   Str2IntList(intString,@tmp_il,@tmp_iln);

   intListN^:=0;
   setlength(intList^,intListN^);

   if(tmp_iln>0)then
   for i:=0 to tmp_iln-1 do
   begin
      o:=tmp_il[i];

      if(o>=0)then
      begin
         if(addReflected)then
         begin
            o:=o*2;
            if(o<smax)then IntListAdd(intList,intListN,o);
            o+=1;
            if(o<smax)then IntListAdd(intList,intListN,o);
         end
         else
           if(o<smax)then IntListAdd(intList,intListN,o);
      end;
   end;
end;

procedure SetTerrainIDs(new_terrain,new_crater,new_liquid:integer);
var t:integer;
begin
   if(theme_cur_terrain_n<=0)then theme_cur_tile_terrain_id:=-1 else begin if(new_terrain<0)then t:=abs(new_terrain) mod theme_cur_terrain_n else t:=min2i(theme_cur_terrain_n-1,new_terrain);theme_cur_tile_terrain_id:=theme_cur_terrain_l[t];end;
   if(theme_cur_crater_n <=0)then theme_cur_tile_crater_id :=-1 else begin if(new_crater <0)then t:=abs(new_crater ) mod theme_cur_crater_n  else t:=min2i(theme_cur_crater_n -1,new_crater );theme_cur_tile_crater_id :=theme_cur_crater_l [t];end;
   if(theme_cur_liquid_n <=0)then theme_cur_tile_liquid_id :=-1 else begin if(new_liquid <0)then t:=abs(new_liquid ) mod theme_cur_liquid_n  else t:=min2i(theme_cur_liquid_n -1,new_liquid );theme_cur_tile_liquid_id :=theme_cur_liquid_l [t];end;

   if(theme_cur_tile_terrain_id>=0)then
   begin
      theme_cur_liquid_mmcolor  :=theme_all_terrain_mmcolor  [theme_cur_tile_liquid_id];
      theme_cur_liquid_tas      :=theme_all_terrain_tas      [theme_cur_tile_liquid_id];
      theme_cur_liquid_tasPeriod:=theme_all_terrain_tasPeriod[theme_cur_tile_liquid_id];
   end
   else
   begin
      theme_cur_liquid_mmcolor  :=c_white;
      theme_cur_liquid_tas      :=tas_ice;
      theme_cur_liquid_tasPeriod:=fr_fpsd2;
   end;
end;

procedure SetTheme(new_theme:integer);
begin
   if(new_theme<0)or(new_theme>=theme_n)then new_theme:=abs(new_theme) mod theme_n;
   theme_cur:=new_theme;
   case theme_cur of
   0: begin  // TECH BASE
         SetThemeList(@theme_cur_terrain_l,@theme_cur_terrain_n,theme_all_terrain_n,false,'0,2,5,6,7,8,9'                );
         SetThemeList(@theme_cur_crater_l ,@theme_cur_crater_n ,theme_all_terrain_n,false,'0,2,5,6,7,8,9,11,79'          );
         SetThemeList(@theme_cur_liquid_l ,@theme_cur_liquid_n ,theme_all_terrain_n,false,'13,20,48,55,71,72'            );
         SetThemeList(@theme_cur_decal_l  ,@theme_cur_decal_n  ,theme_all_decal_n  ,true ,'1_3,21,22,26,27,29,31,32'     );
         SetThemeList(@theme_cur_decor_l  ,@theme_cur_decor_n  ,theme_all_decor_n  ,true ,'19,22_27,32,35,37_41,52_53'   );
         SetThemeList(@theme_cur_1rock_l  ,@theme_cur_1rock_n  ,theme_all_decor_n  ,true ,'81_87'                        );
         SetThemeList(@theme_cur_2rock_l  ,@theme_cur_2rock_n  ,theme_all_decor_n  ,true ,'56_58,65,67,75'               );

         theme_cur_crater_tes:=tes_tech;
         theme_cur_liquid_tes:=tes_tech;
      end;
   1: begin  // TECH BLUE BASE
         SetThemeList(@theme_cur_terrain_l,@theme_cur_terrain_n,theme_all_terrain_n,false,'11,79,80,81,82,85,87'         );
         SetThemeList(@theme_cur_crater_l ,@theme_cur_crater_n ,theme_all_terrain_n,false,'80,81,82,85,87,67,83,84'      );
         SetThemeList(@theme_cur_liquid_l ,@theme_cur_liquid_n ,theme_all_terrain_n,false,'13,20,48,55,71,72'            );
         SetThemeList(@theme_cur_decal_l  ,@theme_cur_decal_n  ,theme_all_decal_n  ,true ,'1_3,21,22,26,27,29,31,32'     );
         SetThemeList(@theme_cur_decor_l  ,@theme_cur_decor_n  ,theme_all_decor_n  ,true ,'19,22_27,32,35,37_41,52_53,31,48_50');
         SetThemeList(@theme_cur_1rock_l  ,@theme_cur_1rock_n  ,theme_all_decor_n  ,true ,'81_87'                        );
         SetThemeList(@theme_cur_2rock_l  ,@theme_cur_2rock_n  ,theme_all_decor_n  ,true ,'56_58,65,67,75'               );

         theme_cur_crater_tes:=tes_tech;
         theme_cur_liquid_tes:=tes_nature;
      end;

  { 2: begin  // PLANET
         SetThemeList(@theme_decals  ,@theme_decaln  ,@theme_spr_decaln  ,'1,4_17,23_25');
         SetThemeList(@theme_terrains,@theme_terrainn,@theme_spr_terrainn,'0,2_16,20_25'   );
         SetThemeList(@theme_bliquids,@theme_bliquidn,@theme_spr_terrainn,'0,2_16,20_25,28');
         SetThemeList(@theme_craters ,@theme_cratern ,@theme_spr_terrainn,'0,2_16,20_25,28');
         SetThemeList(@theme_liquids ,@theme_liquidn ,@theme_spr_liquidn ,'0_15'           );
         SetThemeList(@theme_srocks  ,@theme_srockn  ,@theme_all_srock_n  ,'1_8,20,21'      );
         SetThemeList(@theme_brocks  ,@theme_brockn  ,@theme_all_brock_n  ,'1_4'            );
         SetThemeList(@theme_decors  ,@theme_decorn  ,@theme_all_decor_n  ,'0_12,18,28_29,36,48_50 ');

         theme_liquid_style:=0;
         theme_crater_style:=0;
      end;
   3: begin  // PLANET MOON
         SetThemeList(@theme_decals  ,@theme_decaln  ,@theme_spr_decaln  ,'1,4_17,23_25'       );
         SetThemeList(@theme_terrains,@theme_terrainn,@theme_spr_terrainn,'0,2_4,8,10_13,20_23,25'   );
         SetThemeList(@theme_bliquids,@theme_bliquidn,@theme_spr_terrainn,'0,2_4,8,10_13,20_23,25,28');
         SetThemeList(@theme_craters ,@theme_cratern ,@theme_spr_terrainn,'0,2_4,8,10_13,20_23,25,28');
         SetThemeList(@theme_liquids ,@theme_liquidn ,@theme_spr_liquidn ,'0,4,6,8,9,11,14'          );
         SetThemeList(@theme_srocks  ,@theme_srockn  ,@theme_all_srock_n  ,'1_8,20,21'   );
         SetThemeList(@theme_brocks  ,@theme_brockn  ,@theme_all_brock_n  ,'1_4'         );
         SetThemeList(@theme_decors  ,@theme_decorn  ,@theme_all_decor_n  ,'0_12,29_34 ' );

         theme_liquid_style:=0;
         theme_crater_style:=0;
      end;

   4: begin  // CAVES
         SetThemeList(@theme_decals  ,@theme_decaln  ,@theme_spr_decaln  ,'1,4_20,23_25,28,30,33,34'   );
         SetThemeList(@theme_terrains,@theme_terrainn,@theme_spr_terrainn,'0_4,8_16,20_25'   );
         SetThemeList(@theme_bliquids,@theme_bliquidn,@theme_spr_terrainn,'0_4,8_16,20_25,28_30');
         SetThemeList(@theme_craters ,@theme_cratern ,@theme_spr_terrainn,'0_4,8_16,20_25,28_30');
         SetThemeList(@theme_liquids ,@theme_liquidn ,@theme_spr_liquidn ,'0_14'             );
         SetThemeList(@theme_srocks  ,@theme_srockn  ,@theme_all_srock_n  ,'1_8,13,14,20,21'  );
         SetThemeList(@theme_brocks  ,@theme_brockn  ,@theme_all_brock_n  ,'1_4,12'           );
         SetThemeList(@theme_decors  ,@theme_decorn  ,@theme_all_decor_n  ,'0_22,28,35,36,42_47,48_50');

         theme_liquid_style:=0;
         theme_crater_style:=0;
      end;
   5: begin  // ICE CAVES
         SetThemeList(@theme_decals  ,@theme_decaln  ,@theme_spr_decaln  ,'1_20,23_25,28,30,33,34');
         SetThemeList(@theme_terrains,@theme_terrainn,@theme_spr_terrainn,'0,2,11_13,20,25');
         SetThemeList(@theme_bliquids,@theme_bliquidn,@theme_spr_terrainn,'0,2,11_13,20,25,28');
         SetThemeList(@theme_craters ,@theme_cratern ,@theme_spr_terrainn,'0,2,11_13,20,25,28');
         SetThemeList(@theme_liquids ,@theme_liquidn ,@theme_spr_liquidn ,'16'             );
         SetThemeList(@theme_srocks  ,@theme_srockn  ,@theme_all_srock_n  ,'1,2,5_8,20,21'  );
         SetThemeList(@theme_brocks  ,@theme_brockn  ,@theme_all_brock_n  ,'1_4'            );
         SetThemeList(@theme_decors  ,@theme_decorn  ,@theme_all_decor_n  ,'0_23,28,35,36,42_47,48_50');

         theme_liquid_style:=0;
         theme_crater_style:=0;
      end;

   6: begin  // HELL
         SetThemeList(@theme_decals  ,@theme_decaln  ,@theme_spr_decaln  ,'1,4,9,15,18_20,23_25,28,30,33,34');
         SetThemeList(@theme_terrains,@theme_terrainn,@theme_spr_terrainn,'1,27'                  );
         SetThemeList(@theme_bliquids,@theme_bliquidn,@theme_spr_terrainn,'1,27'                  );
         SetThemeList(@theme_craters ,@theme_cratern ,@theme_spr_terrainn,'1,27'                  );
         SetThemeList(@theme_liquids ,@theme_liquidn ,@theme_spr_liquidn ,'4,8_9,11'              );
         SetThemeList(@theme_srocks  ,@theme_srockn  ,@theme_all_srock_n  ,'9_12'                  );
         SetThemeList(@theme_brocks  ,@theme_brockn  ,@theme_all_brock_n  ,'5_8,13,14'             );
         SetThemeList(@theme_decors  ,@theme_decorn  ,@theme_all_decor_n  ,'3,13_17,20,21,36,42_47');

         theme_liquid_style:=0;
         theme_crater_style:=0;
      end;
   7: begin  // HELL CAVES
         SetThemeList(@theme_decals  ,@theme_decaln  ,@theme_spr_decaln  ,'1,4,9,15,18_20,23_25,28,30,33,34');
         SetThemeList(@theme_terrains,@theme_terrainn,@theme_spr_terrainn,'4,10,14,16,21,23'      );
         SetThemeList(@theme_bliquids,@theme_bliquidn,@theme_spr_terrainn,'4,10,14,16,21,23,29,30');
         SetThemeList(@theme_craters ,@theme_cratern ,@theme_spr_terrainn,'4,10,14,16,21,23,29,30');
         SetThemeList(@theme_liquids ,@theme_liquidn ,@theme_spr_liquidn ,'4,5,8_9,11'            );
         SetThemeList(@theme_srocks  ,@theme_srockn  ,@theme_all_srock_n  ,'1_8'                   );
         SetThemeList(@theme_brocks  ,@theme_brockn  ,@theme_all_brock_n  ,'1_4'                   );
         SetThemeList(@theme_decors  ,@theme_decorn  ,@theme_all_decor_n  ,'3,13_17,20,21,36,42_47');

         theme_liquid_style:=0;
         theme_crater_style:=0;
      end; }
   end;
end;



