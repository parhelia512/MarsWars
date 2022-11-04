{$IFDEF _FULLGAME}

procedure initMissiles;
var m:byte;
begin
   FillChar(_mid_effs,SizeOf(_mid_effs),0);

   for m:=0 to 255 do
   with _mid_effs[m] do
   begin
      ms_smodel   :=spr_pdmodel;

      // sprite model
      case m of
MID_Imp      : ms_smodel:=@spr_h_p0;
MID_Cacodemon: ms_smodel:=@spr_h_p1;
MID_Baron    : ms_smodel:=@spr_h_p2;
MID_Blizzard,
MID_Granade,
MID_Mine,
MID_HRocket  : ms_smodel:=@spr_h_p3;
MID_Revenant : ms_smodel:=@spr_h_p4;
MID_Mancubus : ms_smodel:=@spr_h_p5;
MID_YPlasma  : ms_smodel:=@spr_h_p7;
MID_BPlasma  : ms_smodel:=@spr_u_p0;
MID_Bullet,
MID_Bulletx2,
MID_TBullet,
MID_MBullet,
MID_SShot,
MID_SSShot   : ms_smodel:=@spr_u_p1;
MID_BFG      : ms_smodel:=@spr_u_p2;
MID_Tank,
MID_StunMine     : ;
MID_ArchFire : ;
MID_Flyer    : ms_smodel:=@spr_u_p3;
MID_URocketS,
MID_URocket  : ms_smodel:=@spr_u_p8;
      end;

      // tracer
      case m of
MID_Granade,
MID_HRocket,
MID_URocketS,
MID_URocket,
MID_Revenant : begin
               ms_eid_fly   :=MID_Bullet;
               ms_eid_fly_st:=5;
               end;
MID_Blizzard : begin
               ms_eid_fly   :=MID_Granade;
               ms_eid_fly_st:=1;
               ms_eid_decal :=EID_db_h0;
               end;
      end;

      // death sound and effect (common)
      case m of
MID_Mancubus,
MID_YPlasma,
MID_BPlasma,
MID_Imp,
MID_Cacodemon,
MID_Baron    : ms_snd_death[false]:=snd_pexp;
MID_StunMine : ms_snd_death[false]:=snd_electro;
MID_ArchFire,
MID_Blizzard,
MID_Mine,
MID_Tank,
MID_Granade,
MID_HRocket,
MID_URocket,
MID_Revenant : ms_snd_death[false]:=snd_exp;
MID_Bullet,
MID_Bulletx2,
MID_TBullet,
MID_MBullet,
MID_SShot,
MID_SSShot   : begin
               ms_snd_death   [false]:=snd_rico;
               ms_snd_death_ch[false]:=5;
               end;
MID_BFG      : ms_snd_death[false]:=snd_bfg_exp;
MID_Flyer    : ms_snd_death[false]:=snd_flyer_a;
      end;
      ms_snd_death[true ]:=ms_snd_death[false];
      ms_eid_death    [false]:=m;
      ms_eid_death    [true ]:=m;
      ms_eid_death_cnt[false]:=1;
      ms_eid_death_cnt[true ]:=1;
      ms_eid_death_r  [false]:=0;
      ms_eid_death_r  [true ]:=0;

      // death sound and effect
      case m of
MID_URocketS : begin
                  ms_snd_death    [true ]:=snd_exp;
                  ms_eid_death_cnt[true ]:=4;
                  ms_eid_death_r  [true ]:=20;
                  ms_snd_death    [false]:=snd_exp;
                  ms_eid_death_cnt[false]:=4;
                  ms_eid_death_r  [false]:=20;
               end;
MID_Bullet,
MID_Bulletx2,
MID_TBullet,
MID_MBullet,
MID_SShot,
MID_SSShot   : begin
                  ms_snd_death    [true]:=nil;
                  ms_snd_death_ch [true]:=0;
                  ms_eid_death    [true]:=eid_blood;
                  ms_eid_death_cnt[true]:=0;
               end;
      end;
      case m of
MID_SShot    : begin
                  ms_eid_death_cnt[false]:=2;
                  ms_eid_death_cnt[true ]:=2;
                  ms_eid_death_r  [false]:=5;
                  ms_eid_death_r  [true ]:=5;
               end;
MID_SSShot   : begin
                  ms_eid_death_cnt[false]:=4;
                  ms_eid_death_cnt[true ]:=4;
                  ms_eid_death_r  [false]:=8;
                  ms_eid_death_r  [true ]:=8;
               end;
      end;
   end;
end;


{$ENDIF}

const
mh_none     = 0;
mh_magnetic = 1;
mh_homing   = 2;


//procedure _d25 (d:pinteger);begin d^:=d^ div 4;     end;
procedure _d50 (d:pinteger);begin d^:=d^ div 2;     end;
//procedure _d150(d:pinteger);begin d^:=d^+(d^ div 2);end;
procedure _d200(d:pinteger);begin d^:=d^*2;         end;
procedure _d300(d:pinteger);begin d^:=d^*3;         end;


function _unit_melee_damage(pu,tu:PTUnit;damage:integer):integer;
begin
   case pu^.uidi of
   UID_LostSoul: begin
                    if(tu^.uid^._ukmech    )then _d50(@damage);
                 end;
   {UID_Demon   : begin
                    if(tu^.uid^._ukbuilding)then _d50(@damage);
                 end; }
   end;

   _unit_melee_damage:=damage;
end;

procedure _missile_add(mxt,myt,mvx,mvy,mtar:integer;msid,mpl:byte;mfst,mfet:boolean;adddmg:integer);
var m,d:integer;
    tu:PTUnit;
begin
   for m:=1 to MaxUnits do
   with _missiles[m] do
   if(vstep=0)then
   begin
      x      := mxt;  // end point
      y      := myt;
      vx     := mvx;  // start point
      vy     := mvy;
      tar    := mtar;
      mid    := msid;
      player := mpl;
      mfs    := mfst; // start floor
      mfe    := mfet; // end floor
      mtars  := 0;
      ntars  := 0;
      ystep  := 0;
      dir    := 270;
      homing := mh_none;

      d:=point_dist_rint(x,y,vx,vy);

      {$IFDEF _FULLGAME}
      ms_eid_bio_death:=false;
      {$ENDIF}

      case mid of
MID_Imp        : begin damage:=80  ; vstep:=d div 15; splashr :=0  ;         end;
MID_Cacodemon  : begin damage:=80  ; vstep:=d div 15; splashr :=0  ;         end;
MID_Baron      : begin damage:=80  ; vstep:=d div 15; splashr :=0  ;         end;
MID_Revenant   : begin damage:=80  ; vstep:=d div 12; splashr :=0  ;         dir:=point_dir(vx,vy,x,y);end;
MID_URocketS   : begin damage:=80  ; vstep:=d div 12; splashr :=rocket_sr;   dir:=point_dir(vx,vy,x,y);end;
MID_URocket    : begin damage:=80  ; vstep:=d div 12; splashr :=0;           dir:=point_dir(vx,vy,x,y);end;
MID_Mancubus   : begin damage:=80  ; vstep:=d div 15; splashr :=0  ;         dir:=point_dir(vx,vy,x,y);end;
MID_YPlasma    : begin damage:=40  ; vstep:=d div 15; splashr :=0  ;         end;
MID_ArchFire   : begin damage:=400 ; vstep:=1;        splashr :=15 ;         end;

MID_MBullet,
MID_TBullet,
MID_Bullet     : begin damage:=20  ; vstep:=5;        splashr :=0  ;         end;
MID_Bulletx2   : begin damage:=30  ; vstep:=5;        splashr :=0  ;         end;
MID_BPlasma    : begin damage:=40  ; vstep:=d div 15; splashr :=0  ;         end;
MID_BFG        : begin damage:=600 ; vstep:=d div 12; splashr :=125;         end;
MID_Flyer      : begin damage:=80  ; vstep:=d div 30; splashr :=0  ;         end;
MID_HRocket    : begin damage:=400 ; vstep:=d div 15; splashr :=rocket_sr;   dir:=point_dir(vx,vy,x,y);end;
MID_Granade    : begin damage:=80  ; vstep:=d div 12; splashr :=tank_sr;     ystep:=3;end;
MID_Tank       : begin damage:=80  ; vstep:=5;        splashr :=tank_sr;     end;
MID_StunMine   : begin damage:=1   ; vstep:=1;        splashr :=100;         end;
MID_Mine       : begin damage:=1000; vstep:=1;        splashr :=100;         end;
MID_Blizzard   : begin damage:=2000; vstep:=fr_fps;   splashr :=blizz_r;     dir:=point_dir(vx,vy,x,y);end;
MID_SShot      : begin damage:=80  ; vstep:=5;        splashr :=0  ;         end;
MID_SSShot     : begin damage:=160 ; vstep:=5;        splashr :=10 ;mtars:=2;end;
      else
         vstep:=0;
         exit;
      end;

      if(vstep<=0)then vstep:=1;

      hvstep:=vstep div 2;

      if(mtars=0)then
       if(tar<=0)or(splashr>0)
       then mtars:=MaxUnits
       else mtars:=1;

      damage+=adddmg;

      with _players[player] do
      case mid of
MID_URocket : if(upgr[upgr_uac_airsp]>0)then mid:=MID_URocketS;
      end;

      if(homing=mh_none)then
       case mid of
MID_Revenant,
MID_URocket,
MID_URocketS   : homing:=mh_homing;
MID_Imp,
MID_Cacodemon,
MID_Baron,
MID_BPlasma,
MID_YPlasma    : homing:=mh_magnetic;
       end;


      if(_IsUnitRange(tar,@tu))then
      begin
         x+=_randomr(tu^.uid^._missile_r);
         y+=_randomr(tu^.uid^._missile_r);
      end;

      break;
   end;
end;

function MissileUIDCheck(mid,uid:byte):boolean;
begin
   MissileUIDCheck:=false;

   case mid of
MID_Imp       : if(uid=UID_Imp        )then exit;
MID_Cacodemon : if(uid=UID_Cacodemon  )then exit;
MID_Baron     : if(uid=UID_Knight     )then exit;
MID_Mancubus  : if(uid=UID_Mancubus   )then exit;
MID_YPlasma   : if(uid=UID_Arachnotron)then exit;
MID_Revenant  : if(uid=UID_Revenant   )then exit;
MID_Mine,
MID_StunMine  : if(uid=UID_UMine      )then exit;
   end;

   MissileUIDCheck:=true;
end;


procedure _missle_damage(m:integer);
var tu: PTUnit;
teams : boolean;
ud,rdamage: integer;
     p: byte;
begin
   with _missiles[m] do
    if(_IsUnitRange(tar,@tu))then
     if(tu^.hits>0)and(not _IsUnitRange(tu^.inapc,nil))then
     begin
        if(mfs<>tu^.ukfly)or(MissileUIDCheck(mid,tu^.uidi)=false)then exit;

        teams  :=_players[player].team=tu^.player^.team;
        rdamage:=damage;

        if(teams)then
         if(splashr<=0)
         then exit
         else
           case mid of
           MID_BFG,
           MID_StunMine,
           MID_ArchFire: exit;
           end;

        ud:=point_dist_rint(vx,vy,tu^.x,tu^.y)-tu^.uid^._r;
        if(splashr<=0)or(mid=MID_Mine)then ud-=10;
        if(ud<0)then ud:=0;

        p:=1;

        /////////////////////////////////

        if(not tu^.uid^._ukbuilding)then// not buildings
        begin
        if (    tu^.uid^._uklight)then  // light all
            case mid of
            MID_Bulletx2    : _d300(@rdamage);
            MID_Cacodemon   : _d200(@rdamage);
            MID_HRocket,
            MID_Blizzard,
            MID_BFG         : _d50 (@rdamage);
            end;

        if (    tu^.uid^._uklight)
        and(not tu^.uid^._ukmech )then  // light bio
            case mid of
            MID_Bullet      : _d300(@rdamage);
            end;

        if (not tu^.uid^._uklight)
        and(not tu^.uid^._ukmech )then  // not light, bio
            case mid of
            MID_Imp,
            MID_SShot,
            MID_SSShot      : _d200(@rdamage);
            end;

        if (    tu^.uid^._ukmech)then   // mech
            case mid of
            MID_Baron,
            MID_BPlasma     : _d200(@rdamage);
            MID_YPlasma     : _d300(@rdamage);
            end;

        end
        else                            // buildings
            case mid of
            MID_Blizzard    : _d200(@rdamage);
            MID_Granade,
            MID_Mine,
            MID_Mancubus,
            MID_Tank        : _d300(@rdamage);
            end;

        if (    tu^.uid^._ukmech)then   // mech all
            case mid of
            MID_SSShot      : _d50 (@rdamage);
            end;

        if(tu^.ukfly)
        or(tu^.uidi=UID_LostSoul)then   // fly all
            case mid of
            MID_Revenant,
            MID_URocketS,
            MID_URocket     : _d200(@rdamage);
            MID_Flyer       : _d300(@rdamage);
            end;

        case mid of
            //MID_Bulletx2,
            //MID_SShot       : p:=2;
            MID_SSShot      : p:=2;
        end;

        if(ud<=0)and(ntars=0)then // direct and first target
        begin
           {$IFDEF _FULLGAME}
           ms_eid_bio_death:=not tu^.uid^._ukmech;
           {$ENDIF}

           if(ServerSide)then
            if(tu^.buff[ub_invuln]<=0)and(tu^.uid^._ukbuilding=false)then
            begin
               if((mid=MID_TBullet )and(not tu^.uid^._ukmech ))
               or((mid=MID_MBullet )and(    tu^.uid^._ukmech))
               or (mid=MID_StunMine)then tu^.buff[ub_stun]:=fr_2hfps;
               {$IFDEF _FULLGAME}
               if(mid=MID_StunMine)then _effect_add(tu^.vx,tu^.vy,_SpriteDepth(tu^.vy+1,tu^.ukfly),MID_BPlasma);
               {$ENDIF}
            end;

           mtars-=1;
           ntars+=1;

           _unit_damage(tu,rdamage,p,player);
        end
        else
          if(splashr>0)and(ud<splashr)then // splash damage
          begin
             {$IFDEF _FULLGAME}
             if(mid=MID_BFG)then _effect_add(tu^.vx,tu^.vy,_SpriteDepth(tu^.vy+1,tu^.ukfly),EID_BFG);
             {$ENDIF}

             if(ServerSide)then
              if(mid=MID_StunMine)then
              begin
                 tu^.buff[ub_stun]:=fr_fps;
                 {$IFDEF _FULLGAME}
                 _effect_add(tu^.vx,tu^.vy,_SpriteDepth(tu^.vy+1,tu^.ukfly),MID_BPlasma);
                 {$ENDIF}
              end;

             if(mid<>MID_BFG)then
              if(tu^.uid^._splashresist)then exit;

             mtars-=1;
             ntars+=1;

             rdamage:=mm3(0,trunc(rdamage*(1-(ud/splashr))),rdamage);
             _unit_damage(tu,rdamage,p,player);
          end;
     end;
end;

procedure _missileCycle;
const  mb_s0 = fr_fps div 5;
       mb_s1 = fr_fps-mb_s0;
var m,u:integer;
     tu:PTUnit;
begin
   for m:=1 to MaxMissiles do
   with _missiles[m] do
   if(vstep>0)then
   begin
      if(homing>mh_none)then
       if(_IsUnitRange(tar,@tu))then
        if(tu^.x<>tu^.vx)
        or(tu^.y<>tu^.vy)
        or(max2(abs(tu^.x-x),abs(tu^.y-y))>tu^.uid^._missile_r)then
         case homing of
mh_magnetic : begin
                 x  +=sign(tu^.x-x)*3;
                 y  +=sign(tu^.y-y)*3;
              end;
mh_homing   : begin
                 x  :=tu^.x;
                 y  :=tu^.y;
                 mfe:=tu^.ukfly;
              end;
         end;

      if(mid=MID_Blizzard)then
      begin
         if(vstep>mb_s1)
         then vy-=fr_fps
         else
           if(vstep=mb_s1)then
           begin
              vx:=x;
              vy:=y-(fr_fps*mb_s0);
           end
           else
             if(vstep<=mb_s0)then vy+=fr_fps;

      end
      else
      begin
         vx+=(x-vx) div vstep;
         vy+=(y-vy) div vstep;
      end;

      vstep-=1;
      if(vstep<=hvstep)then mfs:=mfe;

      if(ystep>0)then vy-=vstep div ystep;

      if(vstep=0)then
      begin
         if(damage>0)and(splashr>=0)then
          if _IsUnitRange(tar,nil)and(mtars=1)
          then _missle_damage(m)
          else
            for u:=1 to MaxUnits do
            begin
               tar:=u;
               _missle_damage(m);
               if(mtars<=0)then break;
            end;

         {$IFDEF _FULLGAME}
         _missile_explode_effect(m);
         {$ENDIF}
      end
      {$IFDEF _FULLGAME}
      else
        with _mid_effs[mid] do
         if(ms_eid_fly_st>0)and(ms_eid_fly>0)then
          if((vstep mod ms_eid_fly_st)=0)then _effect_add(vx,vy,_SpriteDepth(vy,mfs),ms_eid_fly);
      {$ENDIF};
   end;
end;




