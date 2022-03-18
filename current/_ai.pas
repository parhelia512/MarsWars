
const

aiucl_main0      : array[1..r_cnt] of byte = (UID_HKeep          ,UID_UCommandCenter);
aiucl_main1      : array[1..r_cnt] of byte = (UID_HCommandCenter ,0);
aiucl_generator  : array[1..r_cnt] of byte = (UID_HSymbol        ,UID_UGenerator    );
aiucl_barrack0   : array[1..r_cnt] of byte = (UID_HGate          ,UID_UMilitaryUnit );
aiucl_barrack1   : array[1..r_cnt] of byte = (UID_HMilitaryUnit  ,UID_UFactory      );
aiucl_smith      : array[1..r_cnt] of byte = (UID_HPools         ,UID_UWeaponFactory);
aiucl_tech0      : array[1..r_cnt] of byte = (UID_HMonastery     ,UID_UTechCenter   );
aiucl_tech1      : array[1..r_cnt] of byte = (UID_HFortress      ,UID_UNuclearPlant );
aiucl_spec0      : array[1..r_cnt] of byte = (UID_HTeleport      ,UID_URadar        );
aiucl_spec1      : array[1..r_cnt] of byte = (UID_HAltar         ,UID_URMStation    );
aiucl_twr0       : array[1..r_cnt] of byte = (UID_HTower         ,UID_UCTurret      );
aiucl_twr1       : array[1..r_cnt] of byte = (UID_HTotem         ,UID_URTurret      );

aia_n = 4;

aia_common = 0;
aia_ground = 1;
aia_fly    = 2;
aia_invis  = 3;

type TAIAlarm = record
   aiau:PTUnit;
   aiax,
   aiay,
   aiad:integer;
end;

var

ai_alarm : array[0..aia_n] of TAIAlarm;

ai_need_heye,

ai_grd_commander_u,
ai_fly_commander_u,
ai_base_u         : PTUnit;
ai_base_d,

ai_enrg_cur,

ai_basep_builders,
ai_basep_need,

ai_unitp_cur,
ai_unitp_cur_na,
ai_unitp_barracks,
ai_unitp_need,
ai_upgrp_cur,
ai_upgrp_cur_na,
ai_upgrp_smiths,
ai_upgrp_need,

ai_tech0_cur,
ai_tech0_need,

ai_tech1_cur,

ai_spec0_cur,
ai_spec0_need,

ai_spec1_cur
                 : integer;


procedure PlayerSetSkirmishAIParams(p:byte);
begin
   with _players[p] do
   begin
      case ai_skill of
      0 : begin
             ai_max_energy:=600;
             ai_max_mains :=1;
             ai_max_unitps:=1;
             ai_max_upgrps:=0;
             ai_max_tech0 :=0;
             ai_max_tech1 :=0;
             ai_max_spec0 :=0;
             ai_max_spec1 :=0;
          end;
      1 : begin
             ai_max_energy:=1000;
             ai_max_mains :=3;
             ai_max_unitps:=2;
             ai_max_upgrps:=1;
             ai_max_tech0 :=0;
             ai_max_tech1 :=0;
             ai_max_spec0 :=0;
             ai_max_spec1 :=0;
          end;
      2 : begin
             ai_max_energy:=2000;
             ai_max_mains :=8;
             ai_max_unitps:=4;
             ai_max_upgrps:=1;
             ai_max_tech0 :=1;
             ai_max_tech1 :=0;
             ai_max_spec0 :=1;
             ai_max_spec1 :=0;
          end;
      3 : begin
             ai_max_energy:=32000;
             ai_max_mains :=12;
             ai_max_unitps:=8;
             ai_max_upgrps:=2;
             ai_max_tech0 :=2;
             ai_max_tech1 :=1;
             ai_max_spec0 :=2;
             ai_max_spec1 :=0;
          end;
      4 : begin
             ai_max_energy:=32000;
             ai_max_mains :=18;
             ai_max_unitps:=14;
             ai_max_upgrps:=4;
             ai_max_tech0 :=4;
             ai_max_tech1 :=1;
             ai_max_spec0 :=4;
             ai_max_spec1 :=1;
          end;
      else
             ai_max_energy:=32000;
             ai_max_mains :=25;
             ai_max_unitps:=20;
             ai_max_upgrps:=4;
             ai_max_tech0 :=4;
             ai_max_tech1 :=1;
             ai_max_spec0 :=4;
             ai_max_spec1 :=1;
      end;

      {case ai_skill of
      0,1 : ai_max_mains:=1;
      2   : ai_max_mains:=3;
      3   : ai_max_mains:=9;
      4   : ai_max_mains:=16;
      else  ai_max_mains:=25;
      end;
      {
      ai_max_ulimit,
      }

      ai_max_energy:=ai_max_mains*250+300;
      ai_max_unitps:=1;
      ai_max_upgrps:=1;
      ai_max_tech0 :=0;
      ai_max_tech1 :=0;
      ai_max_spec0 :=0;
      ai_max_spec1 :=0;

      if(ai_skill<=1)then exit;

      ai_max_unitps:=max2(3,trunc((ai_max_mains/6)*5));
      ai_max_upgrps:=max2(1,ai_max_unitps div 3);

      if(ai_skill<=2)then exit;

      ai_max_tech0 :=max2(1,ai_max_unitps div 4);
      ai_max_spec0 :=max2(1,ai_max_unitps div 4);

      if(ai_skill<=3)then exit;

      ai_max_tech1 :=1;
      ai_max_spec1 :=1; }
   end;
end;

procedure ai_clear_vars;
var i:integer;
begin
   // nearest enemy unit or last enemy position
   for i:=0 to aia_n do
    with ai_alarm[i] do
    begin
       aiau:=nil;
       aiax:=-1;
       aiay:=0;
       aiad:=32000;
    end;

   // nearest building
   ai_base_d        := 32000;
   ai_base_u        := nil;


   ai_enrg_cur      :=0;

   ai_basep_builders:=0;
   ai_basep_need    :=0;

   ai_unitp_cur     :=0;
   ai_unitp_cur_na  :=0;
   ai_unitp_barracks:=0;
   ai_unitp_need    :=0;

   ai_upgrp_cur     :=0;
   ai_upgrp_cur_na  :=0;
   ai_upgrp_smiths  :=0;
   ai_upgrp_need    :=0;

   ai_tech0_cur     :=0;
   ai_tech0_need    :=0;

   ai_tech1_cur     :=0;

   ai_spec0_cur     :=0;
   ai_spec0_need    :=0;

   ai_spec1_cur     :=0;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   AI DATA
//


procedure ai_alarm_target(aid:byte;tu:PTUnit;x,y,ud:integer);
begin
   with ai_alarm[aid] do
   if(ud<aiad)then
   begin
      if(tu<>nil)then
      begin
         aiax :=tu^.x;
         aiay :=tu^.y;
         aiau :=tu;
      end
      else
      begin
         aiax :=x;
         aiay :=y;
         aiau:=nil;
      end;
      aiad:=ud;
   end;
end;


procedure ai_collect_data(pu,tu:PTUnit;ud:integer);
procedure _setCommanderVar(pv:PPTUnit);
begin
   if(pv^=nil)
   then pv^:=tu
   else
     if(tu^.speed<pv^^.speed)
     then pv^:=tu
     else
       if (tu^.speed=pv^^.speed)
       and(tu^.unum <pv^^.unum)
       then pv^:=tu;
end;

begin
   with pu^     do
   with player^ do
   begin
      if(tu^.hits>0)then
      begin
         if(team<>tu^.player^.team)then
          if(_uvision(pu^.player^.team,tu,true))then
          begin
             ai_alarm_target(aia_common,tu,0,0,ud);
             if(tu^.ukfly)
             then ai_alarm_target(aia_fly   ,tu,0,0,ud)
             else ai_alarm_target(aia_ground,tu,0,0,ud);
             if(tu^.buff[ub_invis]>0)and(tu^.vsni[pu^.player^.team]<=0)then
             begin
                ai_alarm_target(aia_invis,tu,0,0,ud);
                if(ud<srange)then ai_need_heye:=pu;
             end;
          end;

         if(pu^.player=tu^.player)then
         begin
            if(ud<ai_base_d)and(tu^.uid^._ukbuilding)and(tu^.speed<=0)then
            begin
               ai_base_u:=tu;
               ai_base_d:=ud;
            end;

            if(ud<base_ir)then
            begin
               if(tu^.ukfly=false)
               then _setCommanderVar(@ai_grd_commander_u)
               else _setCommanderVar(@ai_fly_commander_u);
            end;

            ai_enrg_cur+=tu^.uid^._generg;

            if(tu^.uid^._isbarrack)then
             if(tu^.uidi=aiucl_barrack0[race])or(tu^.uidi=aiucl_barrack1[race])then
              if(tu^.buff[ub_advanced]>0)
              then ai_unitp_cur+=MaxUnitProdsN
              else
              begin
                 ai_unitp_cur   +=1;
                 ai_unitp_cur_na+=1;
              end;

            if(tu^.uid^._issmith)then
             if(tu^.uidi=aiucl_smith[race])then
              if(tu^.buff[ub_advanced]>0)
              then ai_upgrp_cur+=MaxUnitProdsN
              else
              begin
                 ai_upgrp_cur   +=1;
                 ai_upgrp_cur_na+=1;
              end;
         end;
      end;
   end;
end;

function ai_noprod(pu:PTUnit):boolean;
var i:integer;
begin
   ai_noprod:=true;
   with pu^  do
   with uid^ do
   begin
      if(_isbarrack)then
       for i:=0 to MaxUnitProdsI do
       begin
          if(i>0)then
           if(buff[ub_advanced]<=0)then break;
          if(uprod_r[i]>0)then
          begin
             ai_noprod:=false;
             exit;
          end;
       end;
      if(_issmith)then
       for i:=0 to MaxUnitProdsI do
       begin
          if(i>0)then
           if(buff[ub_advanced]<=0)then break;
          if(pprod_r[i]>0)then
          begin
             ai_noprod:=false;
             exit;
          end;
       end;
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   BUILD BASE
//

procedure ai_builder(pu:PTUnit);
var  bt:byte;
      d:single;
bx,by,l:integer;
procedure SetBT(buid:byte);
var _c:cardinal;
begin
  if(bt=0)then
  begin
     _c:=_uid_conditionals(pu^.player,buid);
     if(_c=0)or(_c=ureq_energy)then bt:=buid;
  end;
end;

procedure SetBTX(buid1,buid2:byte;x:integer);
begin
   if(bt=0)then
     with pu^.player^ do
     begin
        if(uid_e[buid1]>=x)then exit;
        if(buid2>0)then
        if(uid_e[buid2]>=x)then exit;

        bt:=buid1;
     end;
end;

procedure SetBT2(b0,b1:byte);
begin
   if(bt=0)then
    if(b0=b1)or(b1=0)
    then SetBT(b0)
    else
    begin
       with pu^.player^ do
        if(uid_e[b1]<(uid_e[b0] div 2))then SetBT(b1);
       SetBT(b0);
       if(bt=0)then SetBT(b1);
    end;
end;

procedure BuildMain(x:integer);   // Builders
begin
   with pu^.player^ do
    if(ai_basep_builders<x)and(ai_basep_builders<ai_max_mains)
    then SetBT2(aiucl_main0[race],aiucl_main1[race]);
end;
procedure BuildEnergy(x:integer); // Energy
begin
   with pu^.player^ do
    if(ai_enrg_cur<x)and(ai_enrg_cur<ai_max_energy)
    then SetBT2(aiucl_generator[race],0);
end;
procedure BuildUProd(x:integer);  // Barracks
begin
    with pu^.player^ do
     if(ai_unitp_cur<x)and(ai_unitp_cur<ai_max_unitps)then
      if(ai_tech1_cur<=0)or(ai_unitp_cur_na=0)or(ai_unitp_cur<6)then
       SetBT2(aiucl_barrack0[race],aiucl_barrack1[race]);
end;
procedure BuildSmith(x:integer);  // Smiths
begin
    with pu^.player^ do
     if(ai_upgrp_cur<x)and(ai_upgrp_cur<ai_max_upgrps)then
      if(ai_tech1_cur<=0)or(ai_upgrp_cur_na=0)or(ai_upgrp_cur<2)then
       SetBT2(aiucl_smith[race],0);
end;
procedure BuildTech0(x:integer);  // Tech0  TechCenter, HellMonastery
begin
    with pu^.player^ do
     if(ai_tech0_cur<x)and(ai_tech0_cur<ai_max_tech0)
     then SetBT2(aiucl_tech0[race],0);
end;
procedure BuildTech1(x:integer);  // Tech1
begin
    with pu^.player^ do
     if(ai_tech1_cur<x)and(ai_tech1_cur<ai_max_tech1)
     then SetBT2(aiucl_tech1[race],0);
end;
procedure BuildSpec0(x:integer);  // Radar, Teleport
begin
    with pu^.player^ do
     if(ai_spec0_cur<x)and(ai_spec0_cur<ai_max_spec0)
     then SetBT2(aiucl_spec0[race],0);
end;
procedure BuildSpec1(x:integer);  // RStation, Altar
begin
    with pu^.player^ do
     if(ai_spec1_cur<x)and(ai_spec1_cur<ai_max_spec1)
     then SetBT2(aiucl_spec1[race],0);
end;

begin
   bt:=0;

   with pu^     do
   with uid^    do
   with player^ do
   if(build_cd<=0)then
   begin
      // fixed opening
      if(race=r_hell)
      then SetBTX(UID_HSymbol,UID_HASymbol,ai_max_spec0);
      BuildEnergy(300 );
      BuildUProd (1   );
      BuildEnergy(600 );
      BuildUProd (2   );
      BuildMain  (2   );
      BuildEnergy(900 );
      BuildSmith (1   );
      BuildSpec0 (1   );
      BuildEnergy(1200);
      BuildUProd (3   );
      BuildMain  (4   );
      BuildTech0 (1   );
      BuildTech1 (1   );
      BuildSpec1 (1   );

      // common
      BuildSmith(ai_upgrp_need);
      BuildTech0(ai_tech0_need);
      BuildSpec0(ai_spec0_need);
      BuildUProd(ai_unitp_need);
      BuildMain (ai_basep_need);

      if(bt=0)then exit;

      d:=random(360)*degtorad;
      l:=random(srange-_r)+_r;
      bx:=x+trunc(l*cos(d));
      by:=y-trunc(l*sin(d));

      _building_newplace(bx,by,bt,playeri,@bx,@by);

      _unit_start_build(bx,by,bt,playeri);
   end;
end;


////////////////////////////////////////////////////////////////////////////////
//
//   UNIT PRODUCTION
//

procedure ai_UnitProduction(pu:PTUnit);
var ut,bt:byte;
    up_m,
    up_n:integer;
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      if((ucl_c[false]+uproda)<15)
      then bt:=random(4 )
      else bt:=random(13);

      case _urace of
r_hell: case bt of
        0 : ut:=UID_LostSoul;
        1 : ut:=UID_Imp;
        2 : ut:=UID_Demon;
        3 : ut:=UID_Cacodemon;
        4 : ut:=UID_Knight;
        5 : ut:=UID_Cyberdemon;
        6 : ut:=UID_Mastermind;
        7 : ut:=UID_Pain;
        8 : ut:=UID_Revenant;
        9 : ut:=UID_Mancubus;
        10: ut:=UID_Arachnotron;
        11: ut:=UID_Archvile;
        12: ut:=UID_Cacodemon;
        end;
r_uac : case bt of
        0 : ut:=UID_Medic;
        1 : ut:=UID_Engineer;
        2 : ut:=UID_Sergant;
        3 : ut:=UID_Commando;
        4 : ut:=UID_Bomber;
        5 : ut:=UID_Major;
        6 : ut:=UID_BFG;
        7 : ut:=UID_APC;
        8 : ut:=UID_FAPC;
        9 : ut:=UID_UACBot;
        10: ut:=UID_Terminator;
        11: ut:=UID_Tank;
        12: ut:=UID_Flyer;
        end;
      end;

      up_m:=10000;
      up_n:=uid_e[ut]+uprodu[ut];

      case ut of
UID_Mastermind,
UID_Cyberdemon   : up_m:=1;
UID_APC,
UID_FAPC         : up_m:=5;
UID_Pain         : up_m:=7;
      end;

      if(up_n<up_m)then _unit_straining(pu,ut);
   end;
end;


////////////////////////////////////////////////////////////////////////////////
//
//   UPGRADE PRODUCTION
//

{
upgr_hell_dattack      = 1;  // distance attacks damage
upgr_hell_uarmor       = 2;  // base unit armor
upgr_hell_barmor       = 3;  // base building armor
upgr_hell_mattack      = 4;  // melee attack damage
upgr_hell_regen        = 5;  // regeneration
upgr_hell_pains        = 6;  // pain state
upgr_hell_heye         = 7;  // hell Eye
upgr_hell_towers       = 8;  // towers range
upgr_hell_teleport     = 9;  // Teleport reload
upgr_hell_hktele       = 10; // HK teleportation
upgr_hell_paina        = 11; // decay aura
upgr_hell_mainr        = 12; // main range
upgr_hell_hktdoodads   = 13; // HK on doodabs
upgr_hell_pinkspd      = 14; // demon speed
upgr_hell_revtele      = 15; // revers teleport
upgr_hell_6bld         = 16; // Souls
upgr_hell_9bld         = 17; // 9 class building reload time
upgr_hell_revmis       = 18; // revenant missile
upgr_hell_totminv      = 19; // totem and eye invisible
upgr_hell_bldrep       = 20; // build restoration
upgr_hell_b478tel      = 21; // teleport towers
upgr_hell_invuln       = 22; // hell invuln powerup


upgr_uac_attack        = 31; // distance attack
upgr_uac_uarmor        = 32; // base armor
upgr_uac_barmor        = 33; // base b armor
upgr_uac_melee         = 34; // repair/health upgr
upgr_uac_mspeed        = 35; // infantry speed
upgr_uac_plasmt        = 36; // turrent for apcs
upgr_uac_detect        = 37; // detectors
upgr_uac_towers        = 38; // towers sr
upgr_uac_radar_r       = 39; // Radar
upgr_uac_mainm         = 40; // Main b move
upgr_uac_ccturr        = 41; // CC turret
upgr_uac_mainr         = 42; // main sr
upgr_uac_ccldoodads    = 43; // main on doodabs
upgr_uac_mines         = 44; // mines for engineers
upgr_uac_jetpack       = 45; // jetpack for plasmagunner
upgr_uac_6bld          = 46; // adv
upgr_uac_9bld          = 47; // 9 class building reload time
upgr_uac_mechspd       = 48; // mech speed
upgr_uac_mecharm       = 49; // mech arm
upgr_uac_turarm        = 50; // turrets armor
upgr_uac_rstrike       = 51; // rstrike launch
}

procedure ai_UpgrProduction(pu:PTUnit);
procedure MakeUpgr(upid,lvl:byte);
begin
   if(upid>0)then
   with pu^     do
   with player^ do
   if(upgr[upid]<lvl)then _unit_supgrade(pu,upid);
end;
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      case race of
r_hell: begin
        MakeUpgr(upgr_hell_heye  ,1);
        MakeUpgr(upgr_hell_mainr ,1);
        MakeUpgr(upgr_hell_hktele,1);
        MakeUpgr(upgr_hell_9bld  ,1);
        MakeUpgr(upgr_hell_heye  ,3);
        MakeUpgr(upgr_hell_6bld  ,1);

        _unit_supgrade(pu,random(30));
        end;
r_uac : begin
        MakeUpgr(upgr_uac_detect ,1);
        MakeUpgr(upgr_uac_mainr  ,1);
        MakeUpgr(upgr_uac_mainm  ,1);
        MakeUpgr(upgr_uac_9bld   ,1);
        MakeUpgr(upgr_uac_6bld   ,1);

        _unit_supgrade(pu,30+random(30));
        end;
      end;
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   COMMON
//

procedure ai_buildings(pu:PTUnit);
var i:integer;
function _N(pn:pinteger;mx:integer):boolean;
begin
   _N:=false;
   if(mx<1)
   then pn^:=0
   else if(mx=1)
        then pn^:=1
        else _N:=true;
end;
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      //if(sel)then
      //if(k_ctrl>1)and(k_ctrl<fr_2hfps)then writeln('ai_unitp_need=',ai_unitp_need,' ai_max_unitps=',ai_max_unitps);

      ai_basep_builders:=uid_e[aiucl_main0   [race]]
                        +uid_e[aiucl_main1   [race]];
      ai_unitp_barracks:=uid_e[aiucl_barrack0[race]]
                        +uid_e[aiucl_barrack1[race]];
      ai_upgrp_smiths  :=uid_e[aiucl_smith   [race]];
      ai_tech0_cur     :=uid_e[aiucl_tech0   [race]];
      ai_tech1_cur     :=uid_e[aiucl_tech1   [race]];
      ai_spec0_cur     :=uid_e[aiucl_spec0   [race]];
      ai_spec1_cur     :=uid_e[aiucl_spec1   [race]];


      if(_N(@ai_basep_need,ai_max_mains ))then ai_basep_need:=mm3(1,ai_basep_builders+1           ,ai_max_mains );
      if(_N(@ai_unitp_need,ai_max_unitps))then ai_unitp_need:=mm3(1,trunc((ai_basep_builders/6)*5),ai_max_unitps);
      if(_N(@ai_upgrp_need,ai_max_upgrps))then ai_upgrp_need:=mm3(1,ai_unitp_cur div 3            ,ai_max_upgrps);
      if(_N(@ai_tech0_need,ai_max_tech0 ))then ai_tech0_need:=mm3(0,ai_unitp_cur div 4            ,ai_max_tech0 );
      if(_N(@ai_spec0_need,ai_max_spec0 ))then ai_spec0_need:=mm3(0,ai_unitp_cur div 4            ,ai_max_spec0 );

      case uidi of
UID_HSymbol,
UID_HASymbol   : if(cenerg>_generg)and(menerg>2200)and(uid_eb[uidi]>ai_max_spec0)then begin _unit_kill(pu,false,true,true);exit;end;
UID_UGenerator,
UID_UAGenerator: if(cenerg>_generg)and(menerg>2200)then begin _unit_kill(pu,false,true,true);exit;end;
      else
         if(_isbarrack)or(_issmith)then
         if(ai_noprod(pu))then
         begin
            if(buff[ub_advanced]>0)
            then i:=MaxUnitProdsN
            else i:=1;

            if(_isbarrack)and(ai_unitp_cur>6)then
             if(ai_unitp_cur_na<=0)or((buff[ub_advanced]<=0)and(ai_unitp_cur_na>0))then
              if((ai_unitp_cur-i)>=ai_unitp_need)then begin _unit_kill(pu,false,true,true);exit;end;
            if(_issmith  )and(ai_upgrp_cur>3)then
             if(ai_upgrp_cur_na<=0)or((buff[ub_advanced]<=0)and(ai_upgrp_cur_na>0))then
              if((ai_upgrp_cur-i)>=ai_upgrp_need)then begin _unit_kill(pu,false,true,true);exit;end;
         end;
      end;

      if(ai_unitp_cur>=1)then
      case uidi of
UID_HSymbol    : if(ai_enrg_cur<ai_max_energy)or(uid_e[UID_HASymbol]<ai_max_spec0)then begin _unit_action(pu);exit;end;
UID_UGenerator : if(ai_enrg_cur<ai_max_energy)then begin _unit_action(pu);exit;end;
      else
         if(_isbarrack)or(_issmith)then
          if(_unit_action(pu))then exit;
      end;

      if(n_builders>0)and(isbuildarea)then ai_builder(pu);

      if(_isbarrack)then
      begin
         ai_UnitProduction(pu);
         with ai_alarm[aia_common] do
         if(aiax>-1)then
         begin
            uo_x:=aiax;
            uo_y:=aiay;
         end;
      end;
      if(_issmith  )then ai_UpgrProduction(pu);
   end;
end;


procedure ai_code(pu:PTUnit);
begin
   with pu^     do
   with uid^ do
   begin
      uo_id:=ua_amove;

      if(playeri=HPlayer)and(sel)then
      begin
         //if(ai_alarm_x      >-1)then UnitsInfoAddLine(x,y,ai_alarm_x,ai_alarm_y,c_red);
         //if(ai_alarm_invis_x>-1)then UnitsInfoAddLine(x,y,ai_alarm_invis_x+1,ai_alarm_invis_y+1,c_aqua);
      end;

      if(_ukbuilding)then ai_buildings(pu);
      if(hits<=0)or(not bld)or(speed<=0)then exit;




   end;
end;



