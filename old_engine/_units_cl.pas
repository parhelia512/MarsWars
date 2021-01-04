
{$IFDEF _FULLGAME}


procedure _unit_fsrclc(u:PTUnit);
begin
   with u^ do
   begin
      fsr:=0;
      if(fog_cw>0)then
      begin
         fsr:=srng div fog_cw;
         if(fsr>MFogM)then fsr:=MFogM;
      end;
   end;
end;


procedure ObjTblCL;
var i:byte;

procedure setMWSM(mwsm,mwsma:PTMWSModel);
begin
   with _uids[i] do
   begin
      un_smodel[false]:= mwsm;
      if(mwsm=nil)
      then un_smodel[true ]:= mwsm
      else un_smodel[true ]:= mwsma;
   end;
end;

begin
   FillChar(ui_puids,SizeOf(ui_puids),0);


   for i:=0 to 255 do
   with _uids[i] do
   begin
      setMWSM(@spr_dmodel,nil);
      _animw:=20;
      _animd:=20;
      _animf:=0;

      case i of
UID_LostSoul:
begin
   setMWSM(@spr_LostSoul,nil);
end;


UID_HKeep:
begin
   setMWSM(@spr_HKeep,nil);
end;
UID_HGate:
begin
   setMWSM(@spr_HGate,@spr_HAGate);
end;
UID_HSymbol:
begin
   setMWSM(@spr_HSymbol,nil);
end;
UID_HPools:
begin
   setMWSM(@spr_HPools,@spr_HAPools);
end;
UID_HTower:
begin
   setMWSM(@spr_HTower,nil);
end;
UID_HTeleport:
begin
   setMWSM(@spr_HTeleport,nil);
end;
UID_HMonastery:
begin
   setMWSM(@spr_HMonastery,nil);
end;
UID_HTotem:
begin
   setMWSM(@spr_HTotem,nil);
end;
UID_HAltar:
begin
   setMWSM(@spr_HAltar,nil);
end;
UID_HFortress:
begin
   setMWSM(@spr_HFortress,nil);
end;
UID_HEye:
begin
   setMWSM(@spr_HEye,nil);
end;
UID_HCommandCenter:
begin
   setMWSM(@spr_HCC,nil);
end;
UID_HMilitaryUnit:
begin
   setMWSM(@spr_HMUnit,@spr_HMUnita);
end;


UID_UCommandCenter:
begin
   setMWSM(@spr_UCommandCenter,nil);
end;
UID_UMilitaryUnit:
begin
   setMWSM(@spr_UMilitaryUnit,@spr_UAMilitaryUnit);
end;
UID_UGenerator:
begin
   setMWSM(@spr_UGenerator,nil);
end;
UID_UWeaponFactory:
begin
   setMWSM(@spr_UWeaponFactory,@spr_UAWeaponFactory);
end;
UID_UTurret:
begin
   setMWSM(@spr_UTurret,nil);
end;
UID_URadar:
begin
   setMWSM(@spr_URadar,nil);
end;
UID_UVehicleFactory:
begin
   setMWSM(@spr_UVehicleFactory,nil);
end;
UID_UPTurret:
begin
   setMWSM(@spr_UPTurret,nil);
end;
UID_URocketL:
begin
   setMWSM(@spr_URocketL,nil);
end;
UID_URTurret:
begin
   setMWSM(@spr_URTurret,nil);
end;
UID_UNuclearPlant:
begin
   setMWSM(@spr_UNuclearPlant,nil);
end;
UID_UMine:
begin
   setMWSM(@spr_Mine,nil);
end;



      end;

      ui_puids[_urace,byte(not _isbuilding),_ucl]:=i;

      _fr:=(_r div fog_cw)+1;
      if(_fr<1)then _fr:=1;
   end;
end;

{$ENDIF}

procedure _unit_apUID(pu:PTUnit);
begin
   with pu^ do
   begin
      uid:=@_uids[uidi];
      with uid^ do
      begin
         srng  := _srng;
         speed := _speed;
         uf    := _uf;
         apcm  := _apcm;
         solid := _issolid;

         if(_isbuilding)and(_isbarrack)then inc(uo_y,_r+12);

         mmr   :=min2(1,round(_r*map_mmcx));

         {$IFDEF _FULLGAME}
         if(_isbuilding)
         then shadow:= fly_height[uf]-fly_z
         else shadow:= fly_height[uf];

         _unit_fsrclc(pu);
         {$ENDIF}
         if(onlySVCode)then hits:=_mhits;
      end;
   end;
end;

procedure initUIDS;
var i:byte;
begin
   for i:=0 to 255 do
   with _uids[i] do
   begin
      _mhits     := 100;
      _max       := 32000;
      _btime     := 1;
      _uf        := uf_ground;
      _ucl       := 255;
      _apcs      := 1;
      _urace     := r_hell;

      _isbuilding:=false;
      _isbuilder :=false;
      _issmith   :=false;
      _isbarrack :=false;
      _ismech    :=false;
      _issolid   :=true;
      _slowturn  :=false;

      case i of
//         HELL BUILDINGS   ////////////////////////////////////////////////////
UID_HKeep:
begin
   _mhits     := 3000;
   _renerg    := 8;
   _generg    := 6;
   _r         := 66;
   _srng      := base_rA[0];
   _ucl       := 0;
   _btime     := 75;

   _isbuilding:= true;
   _isbuilder := true;

   ups_builder:= [UID_HKeep..UID_HFortress];
end;
UID_HGate:
begin
   _mhits     := 1500;
   _renerg    := 4;
   _r         := 60;
   _srng      := 200;
   _ucl       := 1;
   _btime     := 40;

   _isbuilding:= true;
   _isbarrack := true;

   ups_units  := [UID_LostSoul..UID_Archvile];
end;
UID_HSymbol:
begin
   _mhits     := 200;
   _renerg    := 1;
   _generg    := 1;
   _r         := 24;
   _srng      := 200;
   _ucl       := 2;
   _btime     := 10;

   _isbuilding:= true;
end;
UID_HPools:
begin
   _mhits     := 1000;
   _renerg    := 6;
   _r         := 53;
   _srng      := 200;
   _ucl       := 3;
   _btime     := 40;

   _isbuilding:= true;
   _issmith   := true;
end;
UID_HTower:
begin
   _mhits     := 700;
   _renerg    := 2;
   _r         := 21;
   _srng      := 250;
   _ucl       := 4;
   _btime     := 20;

   _isbuilding:= true;
end;
UID_HTeleport:
begin
   _mhits     := 400;
   _renerg    := 4;
   _r         := 28;
   _srng      := 200;
   _ucl       := 5;
   _btime     := 30;
   _max       := 1;

   _isbuilding:= true;
end;
UID_HMonastery:
begin
   _mhits     := 1000;
   _renerg    := 10;
   _r         := 65;
   _srng      := 200;
   _ucl       := 6;
   _btime     := 90;
   _max       := 1;
   _ruid      := UID_HPools;

   _isbuilding:= true;
end;
UID_HTotem:
begin
   _mhits     := 700;
   _renerg    := 3;
   _r         := 21;
   _srng      := 250;
   _ucl       := 7;
   _btime     := 25;
   _ruid      := UID_HMonastery;
   //_rupgr     := upgr_2tier;

   _isbuilding:= true;
end;
UID_HAltar:
begin
   _mhits     := 500;
   _renerg    := 4;
   _r         := 50;
   _srng      := 200;
   _ucl       := 8;
   _btime     := 30;
   _max       := 1;
   _ruid      := UID_HMonastery;
   //_rupgr     := upgr_2tier;

   _isbuilding:= true;
end;
UID_HFortress:
begin
   _mhits     := 4000;
   _renerg    := 10;
   _generg    := 4;
   _r         := 86;
   _srng      := 300;
   _ucl       := 9;
   _btime     := 90;
   _max       := 1;
   _ruid      := UID_HPools;

   _isbuilding:= true;
   _isbuilder := true;

   ups_builder:=[UID_HKeep..UID_HAltar]-[UID_HFortress];
end;
UID_HEye:
begin
   _mhits     := 240;
   _renerg    := 1;
   _r         := 5;
   _srng      := 250;
   _ucl       := 21;
   _btime     := 1;
   //_rupgr     := upgr_vision;

   _isbuilding:= true;
   _issolid   := false;
end;
UID_HCommandCenter:  //UID_UCommandCenter
begin
   _mhits     := 3000;
   _renerg    := 8;
   _generg    := 6;
   _speed     := 6;
   _r         := 66;
   _srng      := base_rA[0];
   _ucl       := 12;
   _btime     := 90;

   _isbuilding:= true;

   ups_builder:=[UID_HCommandCenter,UID_HSymbol,UID_HTower,UID_HMilitaryUnit];
   ups_apc    :=demons;
end;
UID_HMilitaryUnit:
begin
   _mhits     := 1500;
   _renerg    := 4;
   _r         := 66;
   _srng      := base_rA[0];
   _ucl       := 13;
   _btime     := 40;

   _isbuilding:=true;
   _isbarrack :=true;

   ups_units  :=zimbas;
end;
//////////////////////////////

UID_LostSoul   :
begin
   _mhits     := 90;
   _renerg    := 1;
   _r         := 10;
   _speed     := 23;
   _srng      := 250;
   _ucl       := 0;
   _painc     := 1;
   _btime     := 8;
   _uf        := uf_soaring;
end;
UID_Imp        :
begin
   _mhits     := 70;
   _renerg    := 1;
   _r         := 11;
   _speed     := 9;
   _srng      := 250;
   _ucl       := 1;
   _painc     := 3;
   _btime     := 5;
end;
UID_Demon      :
begin
   _mhits     := 150;
   _renerg    := 2;
   _r         := 14;
   _speed     := 14;
   _srng      := 200;
   _ucl       := 2;
   _painc     := 8;
   _btime     := 8;
end;
UID_Cacodemon  :
begin
   _mhits     := 225;
   _renerg    := 2;
   _r         := 14;
   _speed     := 9;
   _srng      := 250;
   _ucl       := 3;
   _painc     := 6;
   _btime     := 20;
   _apcs      := 2;
end;
UID_Baron      :
begin
   _mhits     := 350;
   _renerg    := 4;
   _r         := 14;
   _speed     := 9;
   _srng      := 250;
   _ucl       := 4;
   _painc     := 8;
   _btime     := 40;
   _apcs      := 3;
end;
UID_Cyberdemon :
begin
   _mhits     := 2000;
   _renerg    := 10;
   _max       := 1;
   _r         := 20;
   _speed     := 11;
   _srng      := 250;
   _ucl       := 5;
   _painc     := 15;
   _btime     := 90;
   _apcs      := 10;
   _ruid      := UID_HMonastery;
end;
UID_Mastermind :
begin
   _mhits     := 2000;
   _renerg    := 10;
   _max       := 1;
   _r         := 35;
   _speed     := 11;
   _srng      := 250;
   _ucl       := 6;
   _painc     := 15;
   _btime     := 90;
   _apcs      := 10;
   _ruid      := UID_HMonastery;
end;
UID_Pain       :
begin
   _mhits     := 200;
   _renerg    := 6;
   _r         := 14;
   _speed     := 9;
   _srng      := 250;
   _ucl       := 7;
   _painc     := 3;
   _btime     := 40;
   _apcs      := 2;
   _ruid      := UID_HFortress;
end;
UID_Revenant   :
begin
   _mhits     := 200;
   _renerg    := 4;
   _r         := 13;
   _speed     := 12;
   _srng      := 250;
   _ucl       := 8;
   _painc     := 7;
   _btime     := 40;
   _ruid      := UID_HFortress;
end;
UID_Mancubus   :
begin
   _mhits     := 400;
   _renerg    := 6;
   _r         := 20;
   _speed     := 6;
   _srng      := 250;
   _ucl       := 9;
   _painc     := 4;
   _btime     := 60;
   _ruid      := UID_HMonastery;
   //_rupgr     := upgr_2tier;
end;
UID_Arachnotron:
begin
   _mhits     := 350;
   _renerg    := 6;
   _r         := 20;
   _speed     := 8;
   _srng      := 250;
   _ucl       := 10;
   _painc     := 4;
   _btime     := 50;
   _ruid      := UID_HMonastery;
   //_rupgr     := upgr_2tier;
end;
UID_Archvile:
begin
   _mhits     := 400;
   _renerg    := 10;
   _r         := 14;
   _speed     := 15;
   _srng      := 250;
   _ucl       := 11;
   _painc     := 12;
   _btime     := 90;
   _apcs      := 2;
   _ruid      := UID_HMonastery;
   //_rupgr     := upgr_2tier;
end;

UID_ZFormer:
begin
   _mhits     := 50;
   _renerg    := 1;
   _r         := 12;
   _speed     := 13;
   _srng      := 250;
   _ucl       := 12;
   _painc     := 1;
   _btime     := 5;
end;
UID_ZEngineer:
begin
   _mhits     := 100;
   _renerg    := 2;
   _r         := 12;
   _speed     := 14;
   _srng      := 200;
   _ucl       := 13;
   _painc     := 4;
   _btime     := 20;
end;
UID_ZSergant:
begin
   _mhits     := 80;
   _renerg    := 2;
   _r         := 12;
   _speed     := 13;
   _srng      := 241;
   _ucl       := 14;
   _painc     := 4;
   _btime     := 10;
end;
UID_ZCommando:
begin
   _mhits     := 100;
   _renerg    := 2;
   _r         := 12;
   _speed     := 11;
   _srng      := 250;
   _ucl       := 15;
   _painc     := 4;
   _btime     := 15;
end;
UID_ZBomber:
begin
   _mhits     := 100;
   _renerg    := 4;
   _r         := 12;
   _speed     := 10;
   _srng      := 250;
   _ucl       := 16;
   _painc     := 4;
   _btime     := 30;
end;
UID_ZMajor:
begin
   _mhits     := 100;
   _renerg    := 4;
   _r         := 12;
   _speed     := 10;
   _srng      := 250;
   _ucl       := 17;
   _painc     := 4;
   _btime     := 20;
end;
UID_ZBFG:
begin
   _mhits     := 100;
   _renerg    := 5;
   _r         := 12;
   _speed     := 10;
   _srng      := 250;
   _ucl       := 18;
   _painc     := 4;
   _btime     := 60;
end;


//         UAC BUILDINGS   /////////////////////////////////////////////////////
UID_UCommandCenter:
begin
   _mhits     := 3500;
   _renerg    := 8;
   _generg    := 6;
   _r         := 66;
   _srng      := base_rA[0];
   _ucl       := 0;
   _btime     := 90;

   _isbuilding:= true;
   _isbuilder := true;
   _slowturn  := true;

   ups_builder:=[UID_UCommandCenter..UID_UNuclearPlant];
end;
UID_UMilitaryUnit:
begin
   _mhits     := 1750;
   _renerg    := 4;
   _r         := 66;
   _srng      := 200;
   _ucl       := 1;
   _btime     := 40;

   _isbuilding:=true;
   _isbarrack :=true;

   ups_units:=marines+[UID_APC,UID_FAPC,UID_Terminator,UID_Tank,UID_Flyer];
end;
UID_UGenerator:
begin
   _mhits     := 400;
   _renerg    := 2;
   _generg    := 2;
   _r         := 42;
   _srng      := 200;
   _ucl       := 2;
   _btime     := 20;

   _isbuilding:=true;
end;
UID_UWeaponFactory:
begin
   _mhits     := 1750;
   _renerg    := 6;
   _r         := 62;
   _srng      := 200;
   _ucl       := 3;
   _btime     := 40;

   _isbuilding:=true;
   _issmith   :=true;
end;
UID_UTurret:
begin
   _mhits     := 400;
   _renerg    := 2;
   _r         := 17;
   _srng      := 250;
   _ucl       := 4;
   _btime     := 15;

   _isbuilding:=true;
end;
UID_URadar:
begin
   _mhits     := 500;
   _renerg    := 4;
   _r         := 35;
   _srng      := 200;
   _ucl       := 5;
   _btime     := 30;
   _max       := 1;

   _isbuilding:=true;
end;
UID_UVehicleFactory :
begin
   _mhits     := 1750;
   _renerg    := 10;
   _r         := 62;
   _srng      := 200;
   _ucl       := 6;
   _btime     := 90;
   _max       := 1;
   _ruid      := UID_UWeaponFactory;

   _isbuilding:=true;
end;
UID_UPTurret:
begin
   _mhits     := 400;
   _renerg    := 2;
   _r         := 17;
   _srng      := 250;
   _ucl       := 7;
   _btime     := 20;
   _ruid      := UID_UVehicleFactory;

   _isbuilding:=true;
end;
UID_URocketL:
begin
   _mhits     := 500;
   _renerg    := 4;
   _r         := 40;
   _srng      := 200;
   _ucl       := 8;
   _btime     := 30;
   _max       := 1;
   _ruid      := UID_UVehicleFactory;
   //_rupgr     := upgr_2tier;

   _isbuilding:=true;
end;
UID_URTurret:
begin
   _mhits     := 400;
   _renerg    := 2;
   _r         := 17;
   _srng      := 250;
   _ucl       := 10;
   _btime     := 25;
   _ruid      := UID_UVehicleFactory;
   //_rupgr     := upgr_rturrets;

   _isbuilding:=true;
end;
UID_UNuclearPlant:
begin
   _mhits     := 2000;
   _renerg    := 10;
   _generg    := 10;
   _r         := 70;
   _srng      := 200;
   _ucl       := 9;
   _btime     := 90;
   _max       := 1;
   _ruid      := UID_UVehicleFactory;

   _isbuilding:=true;
end;
UID_UMine:
begin
   _mhits     := 5;
   _renerg    := 1;
   _r         := 5;
   _srng      := 100;
   _ucl       := 21;
   _btime     := 5;
   _ucl       := 9;

   _isbuilding:=true;
   _issolid   := false;
end;

///////////////////////////////////
UID_Engineer:
begin
   _mhits     := 100;
   _renerg    := 1;
   _r         := 12;
   _speed     := 13;
   _srng      := 200;
   _ucl       := 0;
   _btime     := 10;
end;
UID_Medic:
begin
   _mhits     := 100;
   _renerg    := 1;
   _r         := 12;
   _speed     := 13;
   _srng      := 200;
   _ucl       := 1;
   _btime     := 10;
end;
UID_Sergant:
begin
   _mhits     := 100;
   _renerg    := 2;
   _r         := 12;
   _speed     := 13;
   _srng      := 241;
   _ucl       := 2;
   _btime     := 10;
end;
UID_Commando:
begin
   _mhits     := 100;
   _renerg    := 2;
   _r         := 12;
   _speed     := 11;
   _srng      := 250;
   _ucl       := 3;
   _btime     := 15;
end;
UID_Bomber:
begin
   _mhits     := 100;
   _renerg    := 4;
   _r         := 12;
   _speed     := 10;
   _srng      := 250;
   _ucl       := 4;
   _btime     := 30;
end;
UID_Major:
begin
   _mhits     := 100;
   _renerg    := 4;
   _r         := 12;
   _speed     := 10;
   _srng      := 250;
   _ucl       := 5;
   _btime     := 20;
end;
UID_BFG:
begin
   _mhits     := 100;
   _renerg    := 5;
   _r         := 12;
   _speed     := 10;
   _srng      := 250;
   _ucl       := 6;
   _btime     := 60;
end;
UID_FAPC:
begin
   _mhits     := 250;
   _renerg    := 3;
   _r         := 33;
   _speed     := 22;
   _srng      := 250;
   _ucl       := 7;
   _btime     := 25;
   _apcm      := 10;
   _apcs      := 8;
   _ruid      := UID_UWeaponFactory;

   _ismech    := true;
   _slowturn  := true;

   ups_apc    :=marines+[UID_APC,UID_Terminator,UID_Tank,UID_Flyer];
end;
UID_APC:
begin
   _mhits     := 350;
   _renerg    := 3;
   _r         := 25;
   _speed     := 15;
   _srng      := 250;
   _ucl       := 8;
   _btime     := 25;
   _apcm      := 10;
   _apcs      := 10;
   _ruid      := UID_UWeaponFactory;

   _ismech    := true;
   _slowturn  := true;

   ups_apc    :=marines;
end;
UID_Terminator:
begin
   _mhits     := 350;
   _renerg    := 6;
   _r         := 16;
   _speed     := 14;
   _srng      := 275;
   _ucl       := 9;
   _btime     := 60;
   _apcs      := 3;
   _ruid      := UID_UVehicleFactory;
   //_rupgr     := upgr_2tier;

   _ismech    := true;
end;
UID_Tank:
begin
   _mhits     := 400;
   _renerg    := 8;
   _r         := 20;
   _speed     := 10;
   _srng      := 250;
   _ucl       := 10;
   _btime     := 60;
   _apcs      := 7;
   _ruid      := UID_UVehicleFactory;
   //_rupgr     := upgr_2tier;

   _ismech    := true;
end;
UID_Flyer:
begin
   _mhits     := 350;
   _renerg    := 8;
   _r         := 18;
   _speed     := 19;
   _srng      := 275;
   _ucl       := 11;
   _btime     := 60;
   _apcs      := 7;
   _uf        := uf_fly;
   _ruid      := UID_UVehicleFactory;
   //_rupgr     := upgr_2tier;

   _ismech    := true;
end;
UID_UTransport:
begin
   _mhits     := 400;
   _renerg    := 5;
   _r         := 36;
   _speed     := 10;
   _srng      := 250;
   _ucl       := 12;
   _btime     := 60;
   _apcm      := 30;
   _apcs      := 10;
   _ruid      := UID_UVehicleFactory;

   _ismech    := true;
   _slowturn  := true;
end;

UID_UBaseMil:
begin
end;
UID_UBaseCom:
begin
end;
UID_UBaseGen:
begin
end;
UID_UBaseRef:
begin
end;
UID_UBaseNuc:
begin
end;
UID_UBaseLab:
begin
end;
UID_UCBuild:
begin
end;
UID_USPort:
begin
end;
UID_UPortal:
begin
end;
      end;

      if(i in uids_hell)then _urace:=r_hell;
      if(i in uids_uac )then _urace:=r_uac;

      _ismech:=_ismech or _isbuilding;

      _shcf:=_mhits/_mms;

      if(_btime> 0)then _bstep:=(_mhits div 2) div _btime;
      if(_bstep<=0)then _bstep:=1;
      _tprod:=_btime*fr_fps;
   end;
end;


procedure _setUPGR(rc,upcl,stime,max,enrg:integer;rupgr,ruid:byte);
begin
   with _upids[upcl] do
   begin
      _up_ruid  := ruid;
      _up_rupgr := rupgr;
      _up_race  := rc;
      _up_time  := stime*fr_fps;
      _up_renerg:= enrg;
      _up_max   := max;
      _up_mfrg  := false;
   end;
end;

procedure ObjTbl;
begin
   FillChar(_upids,SizeOf(_upids),0);

                              // time lvl enr rupgr     ruid
  { _setUPGR(r_hell,upgr_attack    ,180,4 ,4 ,255       ,255);
   _setUPGR(r_hell,upgr_armor     ,180,4 ,4 ,255       ,255);
   _setUPGR(r_hell,upgr_build     ,120,4 ,4 ,255       ,255);
   _setUPGR(r_hell,upgr_melee     ,60 ,3 ,3 ,255       ,255);
   _setUPGR(r_hell,upgr_regen     ,120,2 ,3 ,255       ,255);
   _setUPGR(r_hell,upgr_pains     ,60 ,4 ,2 ,255       ,255);
   _setUPGR(r_hell,upgr_vision    ,120,3 ,3 ,255       ,255);
   _setUPGR(r_hell,upgr_towers    ,120,4 ,3 ,255       ,255);
   _setUPGR(r_hell,upgr_5bld      ,120,3 ,2 ,255       ,255);
   _setUPGR(r_hell,upgr_mainm     ,180,1 ,3 ,255       ,255);
   _setUPGR(r_hell,upgr_paina     ,120,2 ,3 ,255       ,255);
   _setUPGR(r_hell,upgr_mainr     ,120,2 ,2 ,255       ,255);
   _setUPGR(r_hell,upgr_pinkspd   ,60 ,1 ,3 ,255       ,255);
   _setUPGR(r_hell,upgr_misfst    ,120,1 ,2 ,255       ,255);
   _setUPGR(r_hell,upgr_6bld      ,20 ,15,8 ,255       ,UID_HMonastery);
   _setUPGR(r_hell,upgr_2tier     ,180,1 ,10,255       ,UID_HMonastery);
   _setUPGR(r_hell,upgr_revtele   ,120,1 ,3 ,upgr_2tier,UID_HMonastery);
   _setUPGR(r_hell,upgr_revmis    ,120,1 ,2 ,upgr_2tier,UID_HMonastery);
   _setUPGR(r_hell,upgr_totminv   ,120,1 ,2 ,upgr_2tier,UID_HMonastery);
   _setUPGR(r_hell,upgr_bldrep    ,120,3 ,2 ,upgr_2tier,UID_HMonastery);
   _setUPGR(r_hell,upgr_mainonr   ,60 ,1 ,2 ,upgr_2tier,UID_HMonastery);
   _setUPGR(r_hell,upgr_b478tel   ,30 ,15,1 ,upgr_2tier,UID_HMonastery);
   _setUPGR(r_hell,upgr_hinvuln   ,180,3 ,10,upgr_2tier,UID_HAltar    );
   _setUPGR(r_hell,upgr_bldenrg   ,180,3 ,4 ,upgr_2tier,UID_HFortress );
   _setUPGR(r_hell,upgr_9bld      ,180,1 ,4 ,upgr_2tier,UID_HFortress );

   _setUPGR(r_uac ,upgr_attack    ,180,4 ,4 ,255       ,255);
   _setUPGR(r_uac ,upgr_armor     ,120,5 ,4 ,255       ,255);
   _setUPGR(r_uac ,upgr_build     ,180,4 ,4 ,255       ,255);
   _setUPGR(r_uac ,upgr_melee     ,60 ,3 ,3 ,255       ,255);
   _setUPGR(r_uac ,upgr_mspeed    ,60 ,2 ,3 ,255       ,255);
   _setUPGR(r_uac ,upgr_plsmt     ,120,2 ,2 ,255       ,255);
   _setUPGR(r_uac ,upgr_vision    ,120,1 ,3 ,255       ,255);
   _setUPGR(r_uac ,upgr_towers    ,120,4 ,3 ,255       ,255);
   _setUPGR(r_uac ,upgr_5bld      ,120,3 ,2 ,255       ,255);
   _setUPGR(r_uac ,upgr_mainm     ,180,1 ,3 ,255       ,255);
   _setUPGR(r_uac ,upgr_ucomatt   ,180,1 ,4 ,upgr_mainm,255);
   _setUPGR(r_uac ,upgr_mainr     ,120,2 ,2 ,255       ,255);
   _setUPGR(r_uac ,upgr_mines     ,60 ,1 ,2 ,255       ,255);
   _setUPGR(r_uac ,upgr_minesen   ,60 ,1 ,2 ,upgr_mines,255);
   _setUPGR(r_uac ,upgr_6bld      ,180,1 ,8 ,255       ,UID_UVehicleFactory);
   _setUPGR(r_uac ,upgr_2tier     ,180,1 ,10,255       ,UID_UVehicleFactory);
   _setUPGR(r_uac ,upgr_blizz     ,180,8 ,10,upgr_2tier,UID_UVehicleFactory);
   _setUPGR(r_uac ,upgr_mechspd   ,120,2 ,3 ,upgr_2tier,UID_UVehicleFactory);
   _setUPGR(r_uac ,upgr_mecharm   ,180,4 ,4 ,upgr_2tier,UID_UVehicleFactory);
   _setUPGR(r_uac ,upgr_6bld2     ,120,1 ,2 ,upgr_2tier,UID_UVehicleFactory);
   _setUPGR(r_uac ,upgr_mainonr   ,60 ,1 ,2 ,upgr_2tier,UID_UVehicleFactory);
   _setUPGR(r_uac ,upgr_turarm    ,120,2 ,3 ,upgr_2tier,UID_UVehicleFactory);
   _setUPGR(r_uac ,upgr_rturrets  ,180,1 ,4 ,upgr_2tier,UID_UVehicleFactory);
   _setUPGR(r_uac ,upgr_bldenrg   ,180,3 ,4 ,upgr_2tier,UID_UNuclearPlant  );
   _setUPGR(r_uac ,upgr_9bld      ,180,1 ,4 ,upgr_2tier,UID_UNuclearPlant  );  }

   FillChar(_uids   ,SizeOf(_uids   ),0);

   initUIDS;
end;


