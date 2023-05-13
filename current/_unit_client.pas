
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


procedure _wudata_string(s:shortstring;rpl:boolean);
var sl,x:byte;
       c:char;
begin
   if(rpl=false)
   then net_writestring(s)
   else
   begin
      sl:=length(s);
      {$I-}
      BlockWrite(rpls_file,sl,SizeOf(sl));
      {$I+}
      for x:=1 to sl do
      begin
         c:=s[x];
         {$I-}
         BlockWrite(rpls_file,c,SizeOf(c));
         {$I+}
      end;
   end;
end;

procedure _wudata_byte(bt:byte;rpl:boolean);
begin
   if(rpl=false)
   then net_writebyte(bt)
   else begin {$I-} BlockWrite(rpls_file,bt,SizeOf(bt)); {$I+} end;
end;

procedure _wudata_word(bt:word;rpl:boolean);
begin
   if(rpl=false)
   then net_writeword(bt)
   else begin {$I-} BlockWrite(rpls_file,bt,SizeOf(bt)); {$I+} end;
end;

procedure _wudata_sint(bt:shortint;rpl:boolean);
begin
   if(rpl=false)
   then net_writesint(bt)
   else begin {$I-} BlockWrite(rpls_file,bt,SizeOf(bt)); {$I+} end;
end;

procedure _wudata_int(bt:integer;rpl:boolean);
begin
   if(rpl=false)
   then net_writeint(bt)
   else begin {$I-} BlockWrite(rpls_file,bt,SizeOf(bt)); {$I+} end;
end;

procedure _wudata_card(bt:cardinal;rpl:boolean);
begin
   if(rpl=false)
   then net_writecard(bt)
   else begin {$I-} BlockWrite(rpls_file,bt,SizeOf(bt)); {$I+} end;
end;

function _wudata_log(p:byte;clog_n:pcardinal;rpl:boolean):boolean;
var t,s:integer;
      i:cardinal;
      b:byte;
begin
   _wudata_log:=false;
   if(p<=MaxPlayers)then
    with _players[p] do
    begin
       if(log_n<clog_n^)then
        if(log_n=0)
        then clog_n^:=0
        else clog_n^:=log_n-1;

       if(log_n>clog_n^)then
       begin
          s:=min3(log_n,log_n-clog_n^,MaxPlayerLog);
          i:=log_i;
          clog_n^:=log_n;

          if(s>1)then
           for t:=1 to s-1 do
            if(i=0)
            then i:=MaxPlayerLog
            else i-=1;

          _wudata_byte(byte(s),rpl);
          for t:=1 to s do
          begin
             with log_l[i] do
             begin
                _wudata_byte  (mtype,rpl);
                b:=argt and %00000001;
                if(argx       >0)then b:=b or %00000010;
                if(length(str)>0)then b:=b or %00000100;
                if(xi         >0)then b:=b or %00001000;
                _wudata_byte  (b,rpl);

                if((b and %00000010)>0)then _wudata_byte  (argx ,rpl);
                if((b and %00000100)>0)then _wudata_string(str  ,rpl);
                if((b and %00001000)>0)then
                begin
                   _wudata_byte(byte(xi shr 5),rpl);
                   _wudata_byte(byte(yi shr 5),rpl);
                end;
             end;

             if(i=MaxPlayerLog)
             then i:=0
             else i+=1;
          end;
          if(rpl=false)then _wudata_card(clog_n^,rpl);
          _wudata_log:=true;
          exit;
       end;
    end;
   _wudata_byte(0,rpl);
end;

////////////////////////////////////////////////////////////////////////////////

procedure _wudata_bstat(pu:PTUnit;rpl:boolean);
var _bts1,
    _bts2:byte;
begin
   with pu^ do
   with uid^ do
   begin
      _bts1:=0;
      _bts2:=0;

      SetBBit(@_bts2,0, buff[ub_Resurect    ]>0);
      SetBBit(@_bts2,1, buff[ub_Summoned    ]>0);
      SetBBit(@_bts2,2, buff[ub_Invuln      ]>0);
      SetBBit(@_bts2,3, buff[ub_Teleport    ]>0);
      SetBBit(@_bts2,4, buff[ub_HVision     ]>0);
      SetBBit(@_bts2,5, buff[ub_Cast        ]>0);
      SetBBit(@_bts2,6, buff[ub_Scaned      ]>0);
      SetBBit(@_bts2,7, buff[ub_Decay       ]>0);

      SetBBit(@_bts1,0, iscomplete                    );
      SetBBit(@_bts1,1, transport>0            );
      SetBBit(@_bts1,2, (level and %01)      >0);
      SetBBit(@_bts1,3, (level and %10)      >0);
      SetBBit(@_bts1,4, buff[ub_Pain        ]>0);
      SetBBit(@_bts1,5,(a_tar_cl>0)and(a_rld>0));
      SetBBit(@_bts1,6, sel                    );
      SetBBit(@_bts1,7, _bts2>0                );

      _wudata_byte(_bts1,rpl);
      if(_bts2>0)then _wudata_byte(_bts2,rpl);
   end;
end;

function _wudata_rld(r:pinteger;rpl:boolean):byte;
begin
   if(r^<=0)
   then _wudata_rld:=0
   else _wudata_rld:=mm3(1,(r^ div fr_fps1)+1,255);
   _wudata_byte(_wudata_rld,rpl);
end;

procedure _wudata_prod(pu:PTUnit;rpl:boolean);
var i: byte;
begin
   with pu^ do
   with uid^ do
   for i:=0 to MaxUnitLevel do
   begin
      if(i>level)then break;
      if(_isbarrack)then if(_wudata_rld(@uprod_r[i],rpl)>0)then _wudata_byte(uprod_u[i],rpl);
      if(_issmith  )then if(_wudata_rld(@pprod_r[i],rpl)>0)then _wudata_byte(pprod_u[i],rpl);
   end;
end;

procedure _wudata_OwnerUData(pu:PTUnit;rpl:boolean);
var wudtick : pcardinal;
    wb      : boolean;
    b,uo    : byte;
begin
   wb:=false;

   with pu^ do
   with uid^ do
   begin
      if(rpl)
      then wudtick:=@rpls_wudata_t[unum]
      else wudtick:=@net_wudata_t[unum];

      if(wudtick^>G_Step)
      then wb:=true
      else
        if((G_Step-wudtick^)>=fr_fpsd2)
        then wb:=true;

      b:=group and %00001111;
      uo:=uo_id;
      if(uo_bx>0)then uo:=ua_patrol;
      uo:=(uo and %00000111) shl 4;

      b:=b or uo;

      if(wb)then b:=b or %10000000;

      _wudata_byte(b,rpl);

      if(not wb)then exit;

      wudtick^:=G_Step;

      if(iscomplete)then
       if(_ability in client_rld_abils)
       or(uidi     in client_rld_uids )then _wudata_rld(@rld,rpl);

      if(_ukbuilding)then
      begin
         if(iscomplete)then _wudata_prod(pu,rpl);
         if(sel)and(_UnitHaveRPoint(pu^.uidi))then
          if(_IsUnitRange(uo_tar,nil))
          then _wudata_int(-uo_tar,rpl)
          else
          begin
             _wudata_int(uo_x,rpl);
             _wudata_int(uo_y,rpl);
          end;
      end;
   end;
end;

procedure _wudata_main(pu:PTUnit;rpl:boolean;POVPlayer:byte;POVPlayerObserver:boolean);
var sh :shortint;
    wt :word;
begin
   with pu^ do
   with uid^ do
   begin
      if(CheckUnitTeamVision(_players[POVPlayer].team,pu,true))or(rpl)or(POVPlayerObserver)
      then sh:=_Hi2Si(hits,_mhits,_shcf)
      else sh:=-128;

      _wudata_sint(sh,rpl);
      if(sh>-127)then
      begin
         _wudata_byte (uidi,rpl);
         _wudata_bstat(pu,rpl);

         if(transport>0)
         then _wudata_int(transport,rpl)
         else
           if(sh>0)then
           begin
              _wudata_int(vx ,rpl);
              _wudata_int(vy ,rpl);
           end
           else
           begin
              _wudata_byte(byte(vx shr 5),rpl);
              _wudata_byte(byte(vy shr 5),rpl);
           end;

         if(sh>0)then
         begin
            if(a_tar_cl>0)and(a_rld>0)then
            begin
               wt:=0;
               if(_IsUnitRange(a_tar_cl,nil))then wt:=word(a_tar_cl) and %0000001111111111;
               wt:=wt or ((word(a_weap_cl) shl 10) and %1111110000000000);
               _wudata_word(wt,rpl);
            end;

            if(buff[ub_Cast]>0)then
             if(_ability in client_cast_abils)then
              if(_wudata_rld(@rld,rpl)>0)then
              begin
                 _wudata_byte(byte(uo_x shr 5),rpl);
                 _wudata_byte(byte(uo_y shr 5),rpl);
              end;

            if(playeri=POVPlayer)or(POVPlayerObserver)then _wudata_OwnerUData(pu,rpl);
         end;
      end;
   end;
end;

procedure _wpdata_upgr(rpl:boolean);
var p,n,bp,bv:byte;
begin
   for p:=1 to MaxPlayers do
    if(GetBBit(@g_player_status,p))then
     with _players[p] do
     begin
        bp:=0;

        for n:=0 to 255 do
         if(race=_upids[n]._up_race)then
          case bp of
          0: begin
                bv:=upgr[n];
                bp:=1;
             end;
          1: begin
                bv:=bv or (upgr[n] shl 4);
                _wudata_byte(bv,rpl);
                bp:=0;
                bv:=0;
             end;
          end;

        if(bp=1)then _wudata_byte(bv,rpl);
     end;
end;

function b2bs(b:byte):shortstring;
begin
   b2bs:='00000000';
   if((b and %10000000)>0)then b2bs[1]:='1';
   if((b and %01000000)>0)then b2bs[2]:='1';
   if((b and %00100000)>0)then b2bs[3]:='1';
   if((b and %00010000)>0)then b2bs[4]:='1';
   if((b and %00001000)>0)then b2bs[5]:='1';
   if((b and %00000100)>0)then b2bs[6]:='1';
   if((b and %00000010)>0)then b2bs[7]:='1';
   if((b and %00000001)>0)then b2bs[8]:='1';
end;

procedure _wclinet_cpoint(cpi:byte;rpl:boolean);
var    b: byte;
wdcptime: pbyte;
begin
   b:=0;
   if(rpl)
   then wdcptime:=@rpls_cpoints_t[cpi]
   else wdcptime:= @net_cpoints_t[cpi];

   wdcptime^:=(wdcptime^+1) mod 2;

   with g_cpoints[cpi] do
    if(cpCaptureR<=0)
    then _wudata_byte(0,rpl)
    else
    begin
       b:=b or (cpOwnerPlayer      shl 2) and %00011100;
       b:=b or (cpTimerOwnerPlayer shl 5) and %11100000;

       case wdcptime^ of
0       : begin
             _wudata_byte(b or %00000010,rpl);
             if(cpOwnerPlayer<>cpTimerOwnerPlayer)
             then _wudata_rld(@cpTimer,rpl);
          end;
1       : if(cpLifeTime<=0)
          then _wudata_byte(b or %00000001,rpl)
          else
          begin
             _wudata_byte(b or %00000011,rpl);
             _wudata_byte((cpLifeTime div fr_fps1) shr 2,rpl);
          end;
       end;
    end;
end;

{function _dbg:cardinal;
begin
   _dbg:=G_Step-G_Step_dbg;
   G_Step_dbg:=G_Step;
end;}

procedure _wclinet_gframe(POVPlayer:byte;rpl:boolean);
var
wstep  : cardinal;
POVPlayerObserver,
wstepb0,
wstepb1: boolean;
 _N_U  : pinteger;
i,
 _PNU  : integer;
begin
   _wudata_card(G_Step,rpl);

   wstep:=G_Step shr 1;

   wstepb0:=(wstep mod fr_fpsd2)=0;
   if(rpl)
   then wstepb1:=(wstep mod fr_fps1 )=0  // every 2 second
   else wstepb1:=wstepb0;                // every second

   if(rpl=false)and(wstepb1)then
    with _players[POVPlayer] do _wudata_rld(@build_cd,rpl);

   if(wstepb0)then
     if(g_mode=gm_capture)
     or(g_mode=gm_KotH)
     or(g_cgenerators>0)then
      for i:=1 to MaxCPoints do
       _wclinet_cpoint(i,rpl);

   if(wstepb1)then
     case g_mode of
gm_invasion : begin
              _wudata_byte(g_inv_wave_n     ,rpl);
              _wudata_int (g_inv_wave_t_next,rpl);
              end;
gm_royale   : _wudata_int(g_royal_r,rpl);
     end;

   if(rpl)then
   begin
      _PNU:=_cl_pnua[rpls_pnui];
      _N_U:=@rpls_u;
   end
   else
   begin
      _PNU:= _players[POVPlayer].PNU;
      _N_U:=@_players[POVPlayer].n_u;
   end;

   if(not rpl)
   then PlayersStatus(@g_player_status,@g_cl_units);

   POVPlayerObserver:=_players[POVPlayer].observer;
   if(g_player_status>0)and(POVPlayerObserver)then SetBBit(@g_player_status,7,true);

   _wudata_byte(g_player_status,rpl);
   if(g_player_status>0)then
   begin
      _wudata_byte(_PNU,rpl);
      _PNU:=min2(g_cl_units,_PNU*4);

      if(wstepb0)then _wpdata_upgr(rpl);

      _wudata_int(_N_U^,rpl);
      for i:=1 to _PNU do
      begin
         repeat
            _N_U^+=1;
            if (_N_U^<1)or(_N_U^>MaxUnits)then _N_U^:=1;
         until ( g_player_status and (1 shl ((_N_U^-1) div MaxPlayerUnits)) ) > 0 ;
         _wudata_main(@_units[_N_U^],rpl,POVPlayer,POVPlayerObserver);
      end;
   end;
end;

////////////////////////////////////////////////////////////////////////////////

{$IFDEF _FULLGAME}

procedure _ucInc(pu:PTUnit);
var i,_puid:byte;
    p:pinteger;
ptransport:PTUnit;
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      army+=1;
      armylimit+=_limituse;
      ucl_e[_ukbuilding,_ucl]+=1;
      ucl_c[_ukbuilding     ]+=1;
      ucl_l[_ukbuilding     ]+=_limituse;
      uid_e[uidi            ]+=1;

      ptransport:=nil;
      if(_IsUnitRange(transport,@ptransport))then ptransport^.apcc+=_apcs;

      if(hits>0)and(ptransport=nil)then
      begin
         if(sel)then _unit_counters_inc_select(pu);
         if(iscomplete=false)
         then cenergy-=_renergy
         else
         begin
            _unit_bld_inc_cntrs(pu);

            p:=@ucl_x[_ukbuilding,_ucl];
            if(p^=0)
            then p^:=unum
            else if(0<p^)and(p^<=MaxUnits)then
                  if(_units[p^].uid^._ucl<>_ucl)then p^:=unum;

            p:=@uid_x[uidi];
            if(p^=0)
            then p^:=unum
            else if(0<p^)and(p^<=MaxUnits)then
                  if(_units[p^].uidi<>uidi)then p^:=unum;

            if(_isbarrack)then
             for i:=0 to MaxUnitLevel do
              if(uprod_r[i]>0)then
              begin
                 _puid:=uprod_u[i];

                 uprodl+=_uids[_puid]._limituse;
                 uproda+=1;
                 uprodc[_uids[_puid]._ucl]+=1;
                 uprodu[      _puid      ]+=1;
                 cenergy-=_uids[_puid]._renergy;
              end;
            if(_issmith)then
             for i:=0 to MaxUnitLevel do
              if(pprod_r[i]>0)then
              begin
                 _puid:=pprod_u[i] ;

                 upproda+=1;
                 upprodu[_puid]+=1;
                 pprod_e[i]:=_upid_energy(_puid,upgr[_puid]+1);
                 cenergy-=pprod_e[i];
              end;
         end;
      end;
   end;
end;

procedure _ucDec(pu:PTUnit);
var i,_puid:byte;
ptransport:PTUnit;
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      army-=1;
      armylimit-=_limituse;
      ucl_e[_ukbuilding,_ucl]-=1;
      ucl_c[_ukbuilding     ]-=1;
      ucl_l[_ukbuilding     ]-=_limituse;
      uid_e[uidi            ]-=1;

      ptransport:=nil;
      if(_IsUnitRange(transport,@ptransport))then ptransport^.apcc-=_apcs;

      if(hits>0)and(ptransport=nil)then
      begin
         if(sel)then _unit_counters_dec_select(pu);
         if(iscomplete=false)
         then cenergy+=_renergy
         else
         begin
            cenergy-=_genergy;
            menergy-=_genergy;
            uid_eb[uidi]-=1;
            ucl_eb[_ukbuilding,_ucl]-=1;
            if(ucl_x[_ukbuilding,_ucl]=unum)then ucl_x[_ukbuilding,_ucl]:=0;
            if(uid_x[uidi            ]=unum)then uid_x[uidi            ]:=0;

            _unit_done_dec_cntrs(pu);

            if(_isbarrack)then
             for i:=0 to MaxUnitLevel do
              if(uprod_r[i]>0)then
              begin
                 _puid:=uprod_u[i];

                 uprodl-=_uids[_puid]._limituse;
                 uproda-=1;
                 uprodc[_uids[_puid]._ucl]-=1;
                 uprodu[      _puid      ]-=1;
                 cenergy+=_uids[_puid]._renergy;
              end;
            if(_issmith)then
             for i:=0 to MaxUnitLevel do
              if(pprod_r[i]>0)then
              begin
                 _puid:=pprod_u[i];

                 upproda-=1;
                 upprodu[_puid]-=1;
                 //pprod_e[i]:=_upid_energy(_puid,upgr[_puid]+1);
                 cenergy+=pprod_e[i];
              end;
         end;
      end;
   end;
end;


procedure _SummonEffect(uu:PTUnit;vis:pboolean);
begin
   with uu^ do
   begin
      vx:=x;
      vy:=y;
      effect_UnitSummon(uu,vis);
   end;
end;

procedure _TeleportEffect(uu,pu:PTUnit);
begin
   with uu^  do
   begin
      vx:=x;
      vy:=y;
      if(uid^._ability=uab_HKeepBlink)then
      begin
         teleport_effects(pu^.vx,pu^.vy,vx,vy,ukfly,EID_HKeep_H,EID_HKeep_S,snd_cube);
         buff[ub_CCast]:=fr_fps1;
         exit;
      end // default teleport effects
      else teleport_effects(pu^.vx,pu^.vy,vx,vy,ukfly,EID_Teleport,EID_Teleport,snd_teleport)
   end;
end;

procedure _netSetUcl(uu:PTUnit);
var pu,tu:PTUnit;
   vis:boolean;
begin
   // pu - previous state
   // uu - current state
   pu:=@_units[0];
   with uu^ do vis:=PointInScreenP(x,y);
   with uu^ do
    with player^ do
     if(pu^.hits<=dead_hits)and(hits>dead_hits)then // create unit
     begin
        _unit_default(uu,true);
        _unit_reveal(uu,true);

        if(_IsUnitRange(transport,@tu))then _unit_inapc_target(uu,tu);

        vx:=x;
        vy:=y;

        _unit_upgr(uu);

        if(hits>0)then
        begin
           _unit_CalcForR(uu);
           if(buff[ub_Summoned]>0)then _SummonEffect  (uu,@vis);
           if(buff[ub_Teleport]>0)then _TeleportEffect(uu,@vis);
           if(buff[ub_HVision ]>0)then effect_LevelUp (uu,EID_HVision,@vis);

           if(playeri=UIPlayer)then
           begin
              if(iscomplete=false)then
                with uid^ do SoundPlayAnoncer(snd_build_place[_urace],false);
              if(sel)then UpdateLastSelectedUnit(unum);
           end;
        end;

        _ucInc(uu);
     end
     else
       if(pu^.hits>dead_hits)and(hits<=dead_hits)then // remove unit
       begin
          _unit_upgr(pu);

          vx:=x;
          vy:=y;
          if(pu^.hits>0)and(vis)then
          begin
             if(hits>ndead_hits)and(transport=0)then
             begin
                if(buff[ub_Teleport]>0)then _TeleportEffect(uu,@vis);

                with uid^ do
                  if(_ukbuilding)and(_ability<>uab_HellVision)then build_cd:=min2(build_cd+step_build_reload,max_build_reload);
                effect_UnitDeath(uu,true,@vis);
             end;
          end;

          if(playeri=UIPlayer)and(unum=ui_UnitSelectedPU)then ui_UnitSelectedPU:=0;

          _ucDec(pu);
       end
       else
         if(pu^.hits>dead_hits)and(hits>dead_hits)then
         begin
            if(pu^.uidi<>uidi)then
            begin
               vx:=x;
               vy:=y;
            end;

            _unit_upgr(pu);
            _ucDec(pu);

            _unit_upgr(uu);
            _ucInc(uu);

            if(hits>0)then
            begin
               case(speed>0)of
               false: if(buff[ub_Teleport]>0)then if(pu^.x<>x)or(pu^.y<>y)then _TeleportEffect(uu,pu  );
               true : if(pu^.buff[ub_Teleport]<=0)and(buff[ub_Teleport]>0)then _TeleportEffect(uu,pu  );
               end;
               if(pu^.buff[ub_Summoned]<=0)and(buff[ub_Summoned]>0)then _SummonEffect     (uu,            @vis);
               if(pu^.buff[ub_HVision ]<=0)and(buff[ub_HVision ]>0)then effect_LevelUp    (uu,EID_HVision,@vis);
               if(pu^.buff[ub_Pain    ]<=0)and(buff[ub_Pain    ]>0)then effect_UnitPain(uu,            @vis);

               if(pu^.iscomplete)and(iscomplete=false)then
                if(playeri=UIPlayer)then
                 with uid^ do SoundPlayAnoncer(snd_build_place[_urace],false);

               if(pu^.sel=false)and(sel)and(playeri=UIPlayer)then UpdateLastSelectedUnit(unum);
               if(pu^.transport<>transport)and(vis)then SoundPlayUnit(snd_transport,nil,@vis);

               if(iscomplete)then
               begin
                  if(pu^.buff[ub_Cast]<=0)and(buff[ub_Cast]>0)then
                   case uid^._ability of
               0:;
               uab_UACStrike   : _unit_umstrike_missile(uu);
               uab_UACScan     : if(team=_players[UIPlayer].team)then SoundPlayUnit(snd_radar,nil,nil);
               uab_SpawnLost   : _ability_unit_spawn(pu,UID_LostSoul);
                   end;

                  if(uid^._ukbuilding=false)then
                  begin
                     if(pu^.level<level)then effect_LevelUp(uu,0,@vis);

                     if(pu^.buff[ub_Invuln]<=0)and(buff[ub_Invuln]>0)then effect_LevelUp(uu,EID_Invuln,@vis);
                  end;
               end;
            end;

            if(pu^.hits<=0)and(hits>0)then  //resurrected
            begin
               _unit_CalcForR(uu);
               vx:=x;
               vy:=y;
            end
            else
              if(pu^.hits>0)and(hits<=0)and(buff[ub_Resurect]=0)then  // death
              begin
                 with uid^ do
                   if(_ukbuilding)and(_ability<>uab_HellVision)then build_cd:=min2(build_cd+step_build_reload,max_build_reload);
                 effect_UnitDeath(uu,hits<=fdead_hits,@vis);

                 with uid^ do
                  if(_death_missile>0)
                  then _missile_add(x,y,x,y,0,_death_missile,playeri,ukfly,ukfly,false,0,_death_missile_dmod);

                 if(playeri=UIPlayer)and(unum=ui_UnitSelectedPU)then ui_UnitSelectedPU:=0;
                 rld:=0;
              end;

            if(not _IsUnitRange(pu^.transport,nil))then
             if(_IsUnitRange(transport,@tu))then _unit_inapc_target(uu,tu);

            if(speed>0)then
            begin
               mv_x:=pu^.x;
               mv_y:=pu^.y;
            end;

            if(pu^.x<>x)or(pu^.y<>y)then
            begin
               _unit_update_xy(uu);

               if(speed>0)then
               begin
                  vstp:=UnitStepTicks;
                  dir :=point_dir(mp_x,mp_y,x,y);
               end;
            end;
         end;
end;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

function _rudata_string(rpl:boolean):shortstring;
var sl,x:byte;
       c:char;
begin
   if(rpl=false)
   then _rudata_string:=net_readstring
   else
   begin
      sl:=0;
      _rudata_string:='';
      {$I-}
      BlockRead(rpls_file,sl,SizeOf(sl));
      {$I+}
      for x:=1 to sl do
      begin
         c:=#0;
         {$I-}
         BlockRead(rpls_file,c,SizeOf(c));
         {$I+}
         _rudata_string:=_rudata_string+c;
      end;
   end;
end;

function _rudata_byte(rpl:boolean;def:byte):byte;
begin
   if(rpl=false)
   then _rudata_byte:=net_readbyte
   else begin {$I-} BlockRead(rpls_file,_rudata_byte,SizeOf(_rudata_byte));{$I+}if(ioresult<>0)then _rudata_byte:=def;  end;
end;

function _rudata_word(rpl:boolean;def:word):word;
begin
   if(rpl=false)
   then _rudata_word:=net_readword
   else begin {$I-} BlockRead(rpls_file,_rudata_word,SizeOf(_rudata_word));{$I+}if(ioresult<>0)then _rudata_word:=def;  end;
end;

function _rudata_sint(rpl:boolean;def:shortint):shortint;
begin
   if(rpl=false)
   then _rudata_sint:=net_readsint
   else begin {$I-} BlockRead(rpls_file,_rudata_sint,SizeOf(_rudata_sint));{$I+}if(ioresult<>0)then _rudata_sint:=def;  end;
end;

function _rudata_int(rpl:boolean;def:integer):integer;
begin
   if(rpl=false)
   then _rudata_int:=net_readint
   else begin {$I-} BlockRead(rpls_file,_rudata_int ,SizeOf(_rudata_int ));{$I+}if(ioresult<>0)then _rudata_int :=def;  end;
end;

function _rudata_card(rpl:boolean;def:cardinal):cardinal;
begin
   if(rpl=false)
   then _rudata_card:=net_readcard
   else begin {$I-} BlockRead(rpls_file,_rudata_card,SizeOf(_rudata_card));{$I+}if(ioresult<>0)then _rudata_card:=def;  end;
end;

procedure  _rudata_log(p:byte;rpl:boolean);
var s,b,
mtype,
argt,
argx,
x,y    :byte;
    str:shortstring;
begin
   s:=_rudata_byte(rpl,0);
   if(s>0)then
   begin
      while(s>0)do
      begin
         mtype:=_rudata_byte(rpl,0);
         b    :=_rudata_byte(rpl,0);

         argt:=0;
         argx:=0;
         str :='';
         x   :=255;
         y   :=255;

         argt:=b and %00000001;
         if((b and %00000010)>0)then argx:=_rudata_byte(rpl,0);
         if((b and %00000100)>0)then str :=_rudata_string(rpl);
         if((b and %00001000)>0)then
         begin
            x:=_rudata_byte(rpl,0);
            y:=_rudata_byte(rpl,0);
         end;

         if(x=255)
         then PlayerAddLog(p,mtype,argt,argx,str,-1     ,-1     ,false)
         else PlayerAddLog(p,mtype,argt,argx,str,x shl 5,y shl 5,false);

         s-=1;
      end;
      if(rpl=false)then net_log_n:=_rudata_card(rpl,net_log_n);
   end;
end;

////////////////////////////////////////////////////////////////////////////////


procedure _rudata_bstat(uu:PTUnit;POVPlayer:byte;rpl:boolean);
var _bts1,
    _bts2:byte;
begin
   with uu^ do
   begin
      a_weap:=255;
      level:=0;

      _bts1:=_rudata_byte(rpl,0);

      iscomplete:=GetBBit(@_bts1,0);
      if(GetBBit(@_bts1,1))then transport:=1 else transport:=0;
      if(GetBBit(@_bts1,2))then level+=%01;
      if(GetBBit(@_bts1,3))then level+=%10;
      buff[ub_Pain]:=_buffst[GetBBit(@_bts1,4)];
      if(GetBBit(@_bts1,5))then a_tar:=-1 else a_tar:=0;
      sel:=GetBBit(@_bts1,6);
      if(GetBBit(@_bts1,7))
      then _bts2:=_rudata_byte(rpl,0)
      else _bts2:=0;

      if(_bts2>0)then
      begin
         buff[ub_Resurect]:=_buffst[GetBBit(@_bts2,0)];
         if(GetBBit(@_bts2,1))and(buff[ub_Summoned]<=0)
         then buff[ub_Summoned]:=fr_fps1;
         buff[ub_Invuln  ]:=_buffst[GetBBit(@_bts2,2)];
         buff[ub_Teleport]:=_buffst[GetBBit(@_bts2,3)];
         buff[ub_HVision ]:=_buffst[GetBBit(@_bts2,4)];
         buff[ub_Cast    ]:=_buffst[GetBBit(@_bts2,5)];
         buff[ub_Scaned  ]:=_buffst[GetBBit(@_bts2,6)];
         buff[ub_Decay   ]:=_buffst[GetBBit(@_bts2,7)];
      end
      else
      begin
         buff[ub_Resurect]:=0;
         //buff[ub_Summoned]:=0;
         buff[ub_Invuln  ]:=0;
         buff[ub_Teleport]:=0;
         buff[ub_HVision ]:=0;
         buff[ub_Cast    ]:=0;
         buff[ub_Scaned  ]:=0;
         buff[ub_Decay   ]:=0;
      end;

      with _players[POVPlayer] do
       if(team>0)then
        if(rpl=false)then _AddToInt(@vsnt[team],vistime);
   end;
end;

function _rudata_rld(r:pinteger;rpl:boolean):byte;
begin
   _rudata_rld  :=_rudata_byte(rpl,0);
   if(_rudata_rld=0)
   then r^:=0
   else r^:=_rudata_rld*fr_fps1-1;
end;

procedure _rudata_prod(uu:PTUnit;rpl:boolean);
var i: byte;
begin
   with uu^ do
   with uid^ do
   for i:=0 to MaxUnitLevel do
   begin
      if(i>level)then break;
      if(_isbarrack)then if(_rudata_rld(@uprod_r[i],rpl)>0)then uprod_u[i]:=_rudata_byte(rpl,0);
      if(_issmith  )then if(_rudata_rld(@pprod_r[i],rpl)>0)then pprod_u[i]:=_rudata_byte(rpl,0);
   end;
end;

procedure _rudata_OwnerUData(uu:PTUnit;rpl:boolean);
var b : byte;
    tu: PTUnit;
begin
   with uu^  do
   with uid^ do
   begin
      b:=_rudata_byte(rpl,0);

      group:=b and %00001111;

      uo_id:=(b and %01110000)shr 4;
      if(uo_id=ua_patrol)then
      begin
         uo_id:=ua_amove;
         uo_bx:=1;
      end
      else uo_bx:=-1;

      if((b and %10000000)=0)then exit;

      if(iscomplete)then
       if(_ability in client_rld_abils)
       or(uidi     in client_rld_uids )then _rudata_rld(@rld,rpl);

      if(_ukbuilding)then
      begin
         if(iscomplete)then _rudata_prod(uu,rpl);
         if(sel)and(_UnitHaveRPoint(uidi))then
         begin
            uo_x:=_rudata_int(rpl,0);
            if(_IsUnitRange(-uo_x,@tu))then
            begin
               uo_tar:=-uo_x;
               uo_x  :=tu^.vx;
               uo_y  :=tu^.vy;
            end
            else
            begin
               uo_tar:=0;
               uo_y  :=_rudata_int(rpl,0);
            end;
         end;
      end;
   end;
end;

procedure _rudata_main(uu:PTUnit;rpl,DEAD:boolean;POVPlayer:byte;POVPlayerObserver,SkipRead:boolean);
var sh: shortint;
    i : byte;
    wt: word;
begin
   _units[0]:=uu^;
   with uu^ do
   begin
      playeri:=(unum-1) div MaxPlayerUnits;
      player :=@_players[playeri];
      if(not DEAD)
      then sh:=_rudata_sint(rpl,-128)
      else
        if(hits<dead_hits)
        then sh:=-128
        else sh:=-127;

      if(sh>-127)then
      begin
         i   :=uidi;
         uidi:=_rudata_byte(rpl,0);
         if(i<>uidi)then
         begin
            _unit_apUID(uu);
            _unit_default(uu,false);
            FillChar(buff,SizeOf(buff),0);
         end;
         hits:=_Si2Hi(sh,uid^._mhits,uid^._shcf);
         _rudata_bstat(uu,POVPlayer,rpl);

         if(transport>0)then
         begin
            transport:=_rudata_int(rpl,0);
            if(_IsUnitRange(transport,nil)=false)then transport:=0;
         end
         else
           if(sh>0)then
           begin
              x:=_rudata_int(rpl,x);
              y:=_rudata_int(rpl,y);
           end
           else
           begin
              x:=integer(_rudata_byte(rpl,0) shl 5)+(x mod 32);
              y:=integer(_rudata_byte(rpl,0) shl 5)+(y mod 32);
           end;

         if(sh>0)then
         begin
            if(a_tar=-1)then
            begin
               wt    :=_rudata_word(rpl,0);
               a_tar :=integer(wt and %0000001111111111);
               a_weap:=(wt and %1111110000000000) shr 10;
            end;

            if(buff[ub_Cast]>0)then
             if(uid^._ability in client_cast_abils)then
              if(_rudata_rld(@rld,rpl)>0)then
              begin
                 uo_x:=integer(_rudata_byte(rpl,0) shl 5);
                 uo_y:=integer(_rudata_byte(rpl,0) shl 5);
              end;

            if(playeri=POVPlayer)or(POVPlayerObserver)then _rudata_OwnerUData(uu,rpl);
         end;
      end
      else
        case sh of
        -127: hits:=dead_hits;
        -128: hits:=ndead_hits;
        end;
      if(SkipRead)then
      begin
         vx:=x;
         vy:=y;
      end;
   end;
   _netSetUcl(uu);
end;


procedure _rpdata_upgr(rpl:boolean);
var p,n,bp,bv:byte;
begin
   for p:=1 to MaxPlayers do
    if(GetBBit(@g_player_status,p))then
     with _players[p] do
     begin
        bp:=0;

        for n:=0 to 255 do
        with _upids[n] do
         if(race=_up_race)then
         case bp of
         0: begin
               bv:=_rudata_byte(rpl,0);
               upgr[n]:=min2(_up_max,bv and %00001111);
               bp:=1;
            end;
         1: begin
               upgr[n]:=min2(_up_max,bv shr 4);
               bp:=0;
            end;
         end;
     end;
end;

procedure _rclient_cl_units;
var i:byte;
begin
   g_cl_units:=0;
   for i:=1 to MaxPlayers do
    if((g_player_status and (1 shl i))>0)then g_cl_units+=MaxPlayerUnits;
end;

procedure _rclinet_cpoint(cpi:byte;rpl,no_effect:boolean);
var b,t,p:byte;
begin
   with g_cpoints[cpi] do
   begin
      b:=_rudata_byte(rpl,0);
      t:=b and %00000011;
      if(t=0)then
      begin
         if(cpCaptureR>0)then
         begin
            CPoint_ChangeOwner(cpi,0);
            cpCaptureR:=-cpCaptureR;
            if(not no_effect)
            then effect_CPExplode(cpx,cpy);
         end;
      end
      else
      begin
         if(cpCaptureR<0)then cpCaptureR:=-cpCaptureR;
         p:=(b and %00011100) shr 2;
         CPoint_ChangeOwner(cpi,p);
         cpTimerOwnerPlayer:=(b and %11100000) shr 5;
         if(cpTimerOwnerPlayer<=MaxPlayers)
         then cpTimerOwnerTeam:=_players[cpTimerOwnerPlayer].team;

         case t of
%00000001 : ;
%00000010 : begin
               if(cpOwnerPlayer<>cpTimerOwnerPlayer)
               then _rudata_rld(@cpTimer,rpl)
               else cpTimer:=0;
            end;
%00000011 : cpLifeTime:=(_rudata_byte(rpl,0)*fr_fps1) shl 2;
         end;
      end;
   end;
end;

procedure _rclinet_gframe(POVPlayer:byte;rpl,fast_skip:boolean);
var
wstep  : cardinal;
POVPlayerObserver,
wstepb0,
wstepb1: boolean;
i,
_PNU,
_N_U   : integer;
begin
   G_Step:=_rudata_card(rpl,G_Step);

   wstep:=G_Step shr 1;

   wstepb0:=(wstep mod fr_fpsd2)=0;
   if(rpl)
   then wstepb1:=(wstep mod fr_fps1)=0
   else wstepb1:=wstepb0;

   if(rpl=false)and(wstepb1)then
    with _players[POVPlayer] do
     _rudata_rld(@build_cd,rpl);

   if(wstepb0)then
     if(g_mode=gm_capture)
     or(g_mode=gm_KotH)
     or(g_cgenerators>0)then
      for i:=1 to MaxCPoints do
       _rclinet_cpoint(i,rpl,fast_skip);

   if(wstepb1)then
     case g_mode of
gm_invasion : begin
                 i:=g_inv_wave_n;
                 g_inv_wave_n:=_rudata_byte(rpl,0);
                 if(g_inv_wave_n>i)then SoundPlayUnit(snd_teleport,nil,nil);
                 g_inv_wave_t_next :=_rudata_int (rpl,0);
              end;
gm_royale   : g_royal_r:=_rudata_int(rpl,0);
     end;

   g_player_status:=_rudata_byte(rpl,0);
   if(g_player_status>0)then
   begin
      POVPlayerObserver:=GetBBit(@g_player_status,7);
      _players[POVPlayer].observer:=POVPlayerObserver;

      _PNU:=_rudata_byte(rpl,0)*4;

      if(_PNU<=0)then exit;

      _rclient_cl_units;

      if(_PNU>g_cl_units)then _PNU:=g_cl_units;

      if(_PNU<>rpls_pnu)then
      begin
         rpls_pnu:=_PNU;
         if(rpls_pnu<=0)then rpls_pnu:=1;
         UnitStepTicks:=round(g_cl_units/rpls_pnu*NetTickN)+1;
         if(UnitStepTicks=0)then UnitStepTicks:=1;
      end;

      if(wstepb0)then _rpdata_upgr(rpl);

      _N_U:=_rudata_int(rpl,0);
      for i:=1 to _PNU do
      begin
         while(true)do
         begin
           _N_U+=1;
           if(_N_U<1)or(_N_U>MaxUnits)then _N_U:=1;
           _units[_N_U].unum:=_N_U;
           if( g_player_status and (1 shl ((_N_U-1) div MaxPlayerUnits)) ) > 0
           then break
           else _rudata_main(@_units[_N_U],rpl,true,POVPlayer,POVPlayerObserver,fast_skip);
         end;
         _rudata_main(@_units[_N_U],rpl,false,POVPlayer,POVPlayerObserver,fast_skip);
      end;
   end;
end;
{$ENDIF}


