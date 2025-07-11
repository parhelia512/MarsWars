
procedure SoundStopResetAllSources; forward;

////////////////////////////////////////////////////////////////////////////////
//
//   LOAD
//

function oalError:boolean;
begin
   oalError:=alGetError()<>AL_NO_ERROR;
end;

function Load_Chunk(fname:shortstring):TALuint;
var str,stre : shortstring;
SLformat: TALenum = 0;
SLdata  : TALvoid = nil;
SLsize  : TALsizei= 0;
SLfreq  : TALsizei= 0;
SLloop  : TALint  = 0;

procedure load_wav(sfn:shortstring);
begin
   oalError();

   alGenBuffers   (1,    @Load_Chunk);
   if(oalError)then begin Load_Chunk:=0;exit;end;
   alutLoadWAVFile(sfn   ,SLformat,SLdata,SLsize,SLfreq,SLloop);
   if(oalError)then begin Load_Chunk:=0;exit;end;
   alBufferData   (Load_Chunk,SLformat,SLdata,SLsize,SLfreq);
   if(oalError)then begin Load_Chunk:=0;exit;end;
   alutUnloadWAV  (       SLformat,SLdata,SLsize,SLfreq);
   if(oalError)then Load_Chunk:=0;
end;

procedure load_ogg(sfn:shortstring);
var
SLformat: TALenum     = 0;
SLdata  : TALvoid     = nil;
SLsize  : TALsizei    = 0;
SLfreq  : TALsizei    = 0;
error   : shortstring = '';
begin
   oalError();

   alGenBuffers(1,@Load_Chunk);
   if(oalError)then
   begin
      Load_Chunk:=0;
      WriteLog(sfn+' alGenBuffers() error');
      exit;
   end;

   if(LoadOGGData(sfn,@SLformat,@SLdata,@SLsize,@SLfreq,@error))then
   begin
      alBufferData(Load_Chunk,SLformat,SLdata,SLsize,SLfreq);
      if(oalError)then Load_Chunk:=0;
      FreeOGGData(@SLdata,@SLsize);
   end
   else
   begin
      WriteLog(sfn+' '+error);
      alDeleteBuffers(1,@Load_Chunk);
      Load_Chunk:=0;
   end;
end;

begin
   Load_Chunk:=0;
   str:=str_f_snd+fname;

   stre:=str+'.wav';
   if FileExists(stre)then
   begin
      load_wav(stre);
      if(Load_Chunk=0)then WriteLog(stre+' error!');
      exit;
   end;

   stre:=str+'.ogg';
   if FileExists(stre)then
   begin
      load_ogg(stre);
      if(Load_Chunk=0)then WriteLog(stre+' error!');
      exit;
   end;
end;


function load_sound(fn:shortstring):PTMWSound;
var t:TALuint;
begin
   load_sound:=nil;
   t := Load_Chunk(fn);
   if(t<>0)then
   begin
      new(load_sound);
      load_sound^.s_sound:=t;
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   SoundSets
//

procedure SoundSetUnLoad(sSet:PTSoundSet);
begin
   SoundStopResetAllSources;
   if(sSet=nil)then exit;
   with sSet^ do
   begin
      while(snds_size>0)do
      begin
         snds_size-=1;
         if(alIsBuffer(snds_list[snds_size]^.s_sound))then alDeleteBuffers(1,@(snds_list[snds_size]^.s_sound));
      end;
      setlength(snds_list,0);
   end;
   dispose(sSet);
end;

procedure SoundSetAdd(ss:PTSoundSet;tsnd:PTMWSound);
begin
   if(tsnd<>nil)then
   with ss^ do
   begin
      snds_size+=1;
      setlength(snds_list,snds_size);
      snds_list[snds_size-1]:=tsnd;
   end;
end;

function SoundSetLoad(fname:shortstring):PTSoundSet;
var tsnd:PTMWSound;
       i:integer;
begin
   i:=0;
   new(SoundSetLoad);
   with SoundSetLoad^ do
   begin
      snds_cur :=0;
      snds_size:=0;
      setlength(snds_list,snds_size);

      tsnd:=load_sound(fname);
      if(tsnd<>nil)then SoundSetAdd(SoundSetLoad,tsnd);

      while true do
      begin
         tsnd:=load_sound(fname+i2s(i));
         if(tsnd=nil)then
          if(i=0)then
          begin
             i+=1;
             continue;
          end
          else break;

         SoundSetAdd(SoundSetLoad,tsnd);
         i+=1;
      end;
      if(snds_size<=0)then WriteLog(fname);
   end;
end;
function MusicSetLoad(dir:shortstring;count:word):PTSoundSet;
var tsnd: PTMWSound;
    Info: TSearchRec;
    s   : shortstring;
flist_l : array of shortstring;
i,el,
flist_n : word;
begin
   new(MusicSetLoad);
   with MusicSetLoad^ do
   begin
      snds_cur :=0;
      snds_size:=0;
      setlength(snds_list,snds_size);
   end;

   if(count=0)then exit;

   // build file list
   flist_n:=0;
   el:=length(str_e_music);
   setlength(flist_l,0);
   if(FindFirst(str_f_snd+dir+'*'+str_e_music,faReadonly,info)=0)then
    repeat
      s:=info.Name;
      if(length(s)>el)then
      begin
         delete(s,length(s)-el+1,el);
         flist_n+=1;
         setlength(flist_l,flist_n);
         flist_l[flist_n-1]:=s;
      end;
    until(FindNext(info)<>0);
   FindClose(info);

   // shuffle
   if(flist_n>1)then
     for i:=0 to flist_n-1 do
     begin
        el:=random(flist_n);
        s :=flist_l[el];
        flist_l[el]:=flist_l[i];
        flist_l[i ]:=s;
     end;

   if(flist_n<count)then count:=flist_n;

   if(count>0)then
     for i:=0 to count-1 do
     begin
        tsnd:=load_sound(dir+flist_l[i]);
        if(tsnd<>nil)then SoundSetAdd(MusicSetLoad,tsnd);
     end;
end;
{function MusicSetLoad(dir:shortstring;):PTSoundSet;
var tsnd: PTMWSound;
    Info: TSearchRec;
    s   : shortstring;
begin
   new(MusicSetLoad);
   with MusicSetLoad^ do
   begin
      snds_cur :=0;
      snds_size:=0;
      setlength(snds_list,snds_size);

      if(FindFirst(str_f_snd+dir+'*.ogg',faReadonly,info)=0)then
       repeat
         s:=info.Name;
         if(length(s)>4)then
         begin
            delete(s,length(s)-3,4);
            tsnd:=load_sound(dir+s);
            if(tsnd<>nil)then SoundSetAdd(MusicSetLoad,tsnd);
         end;
       until(FindNext(info)<>0);
      FindClose(info);
   end;
end; }

procedure SoundShafleSoundSet(SoundSet:PTSoundSet);
var i,
m1,m2 : integer;
  snd : PTMWSound;
begin
   with SoundSet^ do
   begin
      snds_cur:=0;
      if(snds_size>1)then
       for i:=0 to snds_size+5 do
       begin
          m1:=random(snds_size);
          m2:=random(snds_size);

          snd:=snds_list[m1];
          snds_list[m1]:=snds_list[m2];
          snds_list[m2]:=snd;
          snds_cur:=random(snds_size);
       end;
   end;
end;

function SoundSetGetChunk(ss:PTSoundSet;NewChunk:boolean):PTMWSound;
begin
   SoundSetGetChunk:=nil;
   if(ss=nil)then exit;
   with ss^ do
    if(snds_size>0)then
     if(snds_size=1)
     then SoundSetGetChunk:=snds_list[0]
     else
     begin
        if(NewChunk)then snds_cur+=1;
        if(snds_cur<0)or(snds_cur>=snds_size)then snds_cur:=0;
        SoundSetGetChunk:=snds_list[snds_cur];
     end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   SOURCE SETs
//

procedure SoundSourceSetInit(sss:PTMWSoundSourceSet;sssn:integer;avolumevar:psingle);
begin
   if(sssn>0)then
   with sss^ do
   begin
      setlength(sss_list,sssn);
      sss_size:=sssn;

      while(sssn>0)do
      begin
         sssn-=1;
         with sss_list[sssn] do
         begin
            alGenSources(1,@ssrc_source);
            alSourcefv(ssrc_source, AL_POSITION, @SLpos);
            ssrc_volumeVar:=avolumevar;
         end;
      end;
   end;
end;

procedure SoundSourceUpdateGain(SoundSourceSet:PTMWSoundSourceSet);
var i:integer;
begin
   with SoundSourceSet^ do
    if(sss_size>0)then
     for i:=0 to sss_size-1 do
      with sss_list[i] do
       if(ssrc_volumeVar<>nil)then alSourcef(ssrc_source,AL_GAIN,ssrc_volumeVar^);
end;
procedure SoundSourceUpdateGainAll;
var s:integer;
begin
   for s:=0 to sss_count-1 do SoundSourceUpdateGain(@SoundSources[s]);
end;

function SourceIsPlaying(source:TALuint):boolean;
var i:TALint;
begin
   alGetSourcei(source,AL_SOURCE_STATE,@i);
   SourceisPlaying:=(i=AL_PLAYING);
end;
function SoundSourceSetIsPlaying(SoundSourceSet:PTMWSoundSourceSet):boolean;
var i:integer;
begin
   SoundSourceSetIsPlaying:=false;

   with SoundSourceSet^ do
    if(sss_size>0)then
     for i:=0 to sss_size-1 do
      with sss_list[i] do
       if(SourceIsPlaying(ssrc_source))then
       begin
          SoundSourceSetIsPlaying:=true;
          break;
       end;
end;

function SoundSourceSetGetSource(SoundSourceSet:PTMWSoundSourceSet):PTMWSoundSource;
var i:integer;
begin
   SoundSourceSetGetSource:=nil;

   with SoundSourceSet^ do
    if(sss_size>0)then
     if(sss_size=1)
     then SoundSourceSetGetSource:=@sss_list[0]
     else
      for i:=0 to sss_size-1 do
       with sss_list[i] do
        if(SourceIsPlaying(ssrc_source)=false)then SoundSourceSetGetSource:=@sss_list[i];
end;

////////////////////////////////////////////////////////////////////////////////
//
//   PLAY
//

procedure StopSoundSource(sss:byte);
var i:integer;
begin
   if(sss>=sss_count)then exit;

   with SoundSources[sss] do
    if(sss_size>0)then
     for i:=0 to sss_size-1 do
      with sss_list[i] do alSourceStop(ssrc_source);
end;

procedure SoundStopResetAllSources;
var sss,sn:byte;
begin
   for sss:=0 to sss_count-1 do
     with SoundSources[sss] do
       if(sss_size>0)then
         for sn:=0 to sss_size-1 do
           with sss_list[sn] do
           begin
              alSourceStop(ssrc_source);
              alSourcei   (ssrc_source, AL_BUFFER, 0);
           end;
end;

procedure SoundPlay(SoundSet:PTSoundSet;sss:byte;NewChunk:boolean);
var vsound :PTMWSound;
    vsource:PTMWSoundSource;
begin
   if(sss>=sss_count)then exit;

   vsound :=SoundSetGetChunk(SoundSet,NewChunk);
   vsource:=SoundSourceSetGetSource(@SoundSources[sss]);

   if(vsound<>nil)and(vsource<>nil)then
   with vsound^  do
   with vsource^ do
   begin
      alSourceStop(ssrc_source);

      if(ssrc_volumeVar<>nil)then
      alSourcef   (ssrc_source, AL_GAIN  , ssrc_volumeVar^);

      alSourcei   (ssrc_source, AL_BUFFER, s_sound  );
      alSourcePlay(ssrc_source);
   end;
end;

function SoundPlayUnit(ss:PTSoundSet;pu:PTUnit;visdata:pboolean):boolean;
begin
   SoundPlayUnit:=false;
   if(ss=nil)
   or(menu_state)
   or(vid_draw=false)then exit;

   if(visdata<>nil)then
   begin
      if(visdata^=false)then exit;
   end
   else
     if(pu<>nil)then
       if(not ui_CheckUnitUIPlayerVision(pu,true))then exit;

   SoundPlay(ss,sss_world,true);
   SoundPlayUnit:=true;
end;

procedure SoundPlayUI(ss:PTSoundSet);
begin
   if(ss=nil)
   or(vid_draw=false)then exit;

   SoundPlay(ss,sss_ui,true);
end;

procedure SoundPlayAnoncer(ss:PTSoundSet;checkpause,stopother:boolean);
begin
   if(ss=nil)
   or(menu_state)
   or(vid_draw=false)then exit;

   if(checkpause)and(snd_anoncer_last=ss)and(snd_anoncer_ticks>0)then exit;

   if(stopother)
   then StopSoundSource(sss_anoncer);
   SoundPlay(ss,sss_anoncer,true);

   snd_anoncer_ticks:=fr_fps1;
   snd_anoncer_last :=ss;
end;
procedure SoundPlayMMapAlarm(ss:PTSoundSet;checkpause:boolean);
begin
   if(ss=nil)
   or(menu_state)
   or(vid_draw=false)then exit;

   if(checkpause)and(snd_mmap_last=ss)and(snd_mmap_ticks>0)then exit;

   SoundPlay(ss,sss_mmap,true);

   snd_mmap_ticks:=fr_fps1;
   snd_mmap_last :=ss;
end;

procedure SoundPlayUnitCommand(ss:PTSoundSet);
begin
   if(ss=nil)
   or(menu_state)
   or(vid_draw=false)then exit;

   if(snd_command_last=ss)and(snd_command_ticks>0)then exit;

   SoundPlay(ss,sss_ucommand,true);

   snd_command_last:=ss;
   snd_command_ticks:=fr_fps2d3;
end;

procedure SoundPlayUnitSelect;
const annoystart = 6;
      annoystop  = 12;
begin
   if(IsIntUnitRange(ui_UnitSelectedNU,nil))then
   begin
      if(ui_UnitSelectedNU<>ui_UnitSelectedPU)
      then ui_UnitSelectedn:=0
      else
        if(ui_UnitSelectedn<annoystop)
        then ui_UnitSelectedn+=1
        else ui_UnitSelectedn:=0;

      with g_units[ui_UnitSelectedNU] do
       with uid^ do
        if(_ukbuilding)and(iscomplete=false)
        then SoundPlayUnitCommand(snd_building[_urace])
        else
         if(ui_UnitSelectedn<annoystart)
         then SoundPlayUnitCommand(un_snd_select)
         else SoundPlayUnitCommand(un_snd_annoy );

      ui_UnitSelectedPU:=ui_UnitSelectedNU;
      ui_UnitSelectedNU:=0;
   end;
end;

procedure SoundLogUIPlayer(playern:byte);
begin
   if(playern<=LastPlayer)then
    with g_players[playern] do
     with log_l[log_i] do
      case mtype of
0..LastPlayer         : if(mtype<>PlayerClient)then SoundPlayUI(snd_chat);
lmt_player_chat,
lmt_game_message      : SoundPlayUI(snd_chat);
lmt_game_end          : if(argx<=LastPlayer)then
                          if(argx=team)
                          then SoundPlayAnoncer(snd_victory[race],false,true)
                          else SoundPlayAnoncer(snd_defeat [race],false,true);
lmt_player_surrender,
lmt_player_defeated   : if(argx<=LastPlayer)and(g_status=gs_running)
                        then SoundPlayAnoncer(snd_player_defeated[race],true,false);
lmt_cant_build        : SoundPlayAnoncer(snd_cannot_build    [race],true,false);
lmt_unit_promoted     : SoundPlayAnoncer(snd_unit_promoted   [race],true,false);
lmt_upgrade_complete  : SoundPlayAnoncer(snd_upgrade_complete[race],true,false);
lmt_unit_ready        : with g_uids[argx] do
                        SoundPlayUnitCommand(un_snd_ready);
lmt_req_energy        : SoundPlayAnoncer(snd_not_enough_energy[race],true,false);
lmt_already_adv,
lmt_NeedMoreProd,
lmt_MaximumReached,
lmt_unit_needbuilder,
lmt_unit_limit,
lmt_production_busy,
lmt_req_ruids,
lmt_req_common,
lmt_cant_order        : SoundPlayAnoncer(snd_cant_order[race],true,false);
lmt_map_mark          : SoundPlayAnoncer(snd_mapmark,false,false);
lmt_allies_attacked   : SoundPlayAnoncer(snd_mapmark,false,false);
lmt_unit_attacked     : with g_uids[argx] do
                        SoundPlayMMapAlarm(snd_under_attack[_ukbuilding,race],true);
      end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   MUSIC
//

procedure SoundMusicReload;
begin
   StopSoundSource(sss_music);
   draw_LoadingScreen(str_loading_msc,c_aqua);
   SoundSetUnLoad(snd_music_game);
   SoundSetUnLoad(snd_music_menu);

   snd_music_menu:=MusicSetLoad('music\menu\',snd_PlayListSize);
   snd_music_game:=MusicSetLoad('music\game\',snd_PlayListSize);
end;

procedure SoundMusicControll(ForceNextTreck:boolean);
var current_music_ss: PTSoundSet;
begin
   if(g_Started)
   then current_music_ss:=snd_music_game
   else current_music_ss:=snd_music_menu;

   if(snd_music_current<>current_music_ss)or(not SoundSourceSetIsPlaying(@SoundSources[sss_music]))or(ForceNextTreck)then
   begin
      if(snd_music_current<>current_music_ss)and(not ForceNextTreck)then SoundShafleSoundSet(current_music_ss);
      snd_music_current:=current_music_ss;

      SoundPlay(snd_music_current,sss_music,ForceNextTreck);
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   MAIN
//

procedure SoundControl;
begin
   if(ui_blink_timer1=0)then SoundMusicControll(false);
   if(snd_anoncer_ticks>0)then snd_anoncer_ticks-=1;
   if(snd_command_ticks>0)then snd_command_ticks-=1;

   if(g_Started)and(G_status=gs_running)and(not menu_state)
   then SoundPlayUnitSelect;
end;


function InitSound:boolean;
var r:integer;
begin
   InitSound:=false;

   if(not InitOpenAL)then exit;

   if(oalError)then exit;

   MainDevice  := alcOpenDevice(nil);
   MainContext := alcCreateContext(MainDevice,nil);
   alcMakeContextCurrent(MainContext);

   if(oalError)then exit;

   FillChar(SLpos,SizeOf(SLpos),0);
   FillChar(SLori,SizeOf(SLori),0);

   alListenerfv(AL_POSITION   ,@SLPos);
   alListenerfv(AL_ORIENTATION,@SLOri);

   // set sound source volume var
   for r:=0 to sss_count-1 do
     case r of
     sss_music: SoundSourceSetInit(@SoundSources[r],sss_sssize[r],@snd_mvolume1);
     else       SoundSourceSetInit(@SoundSources[r],sss_sssize[r],@snd_svolume1);
     end;

   SoundMusicReload;

   SoundShafleSoundSet(@snd_music_menu);
   SoundShafleSoundSet(@snd_music_game);
   /////////////////////////////////////////////////////////////////////////////////
   //
   // COMMON
   //

   draw_LoadingScreen(str_loading_sfx,c_green);

   snd_click                :=SoundSetLoad('click'           );
   snd_chat                 :=SoundSetLoad('chat'            );
   snd_building_explode     :=SoundSetLoad('building_explode');
   snd_teleport             :=SoundSetLoad('teleport'        );
   snd_exp                  :=SoundSetLoad('explode'         );
   snd_mine_place           :=SoundSetLoad('mine_place'      );
   snd_transport            :=SoundSetLoad('inapc'           );
   snd_meat                 :=SoundSetLoad('meat'            );
   snd_cube                 :=SoundSetLoad('cube_s'          );
   snd_mapmark              :=SoundSetLoad('mapmark'         );

   snd_pexp                 :=SoundSetLoad(missiles_folder+'p_exp'           );
   snd_launch               :=SoundSetLoad(missiles_folder+'launch'          );
   snd_pistol               :=SoundSetLoad(missiles_folder+'pistol'          );
   snd_shotgun              :=SoundSetLoad(missiles_folder+'shotgun'         );
   snd_ssg                  :=SoundSetLoad(missiles_folder+'ssg'             );
   snd_plasma               :=SoundSetLoad(missiles_folder+'plasma'          );
   snd_bfg_shot             :=SoundSetLoad(missiles_folder+'bfg_shot'        );
   snd_healing              :=SoundSetLoad(missiles_folder+'healing'         );
   snd_electro              :=SoundSetLoad(missiles_folder+'electro'         );
   snd_rico                 :=SoundSetLoad(missiles_folder+'rico'            );
   snd_bfg_exp              :=SoundSetLoad(missiles_folder+'bfg_exp'         );
   snd_flyer_s              :=SoundSetLoad(missiles_folder+'flyer_s'         );
   snd_flyer_a              :=SoundSetLoad(missiles_folder+'flyer_a'         );

   for r:=1 to race_num do
   begin
   snd_under_attack[true ,r]:=SoundSetLoad(race_dir[r]+'base_under_attack'         );
   snd_under_attack[false,r]:=SoundSetLoad(race_dir[r]+'unit_under_attack'         );
   snd_build_place       [r]:=SoundSetLoad(race_dir[r]+'build_place'               );
   snd_building          [r]:=SoundSetLoad(race_dir[r]+'building'                  );
   snd_constr_complete   [r]:=SoundSetLoad(race_dir[r]+'construction_complete'     );
   snd_cannot_build      [r]:=SoundSetLoad(race_dir[r]+'cannot_build_here'         );
   snd_defeat            [r]:=SoundSetLoad(race_dir[r]+'defeat'                    );
   snd_not_enough_energy [r]:=SoundSetLoad(race_dir[r]+'not_enough_energy'         );
   snd_player_defeated   [r]:=SoundSetLoad(race_dir[r]+'player_defeated'           );
   snd_upgrade_complete  [r]:=SoundSetLoad(race_dir[r]+'upgrade_complete'          );
   snd_victory           [r]:=SoundSetLoad(race_dir[r]+'victory'                   );
   snd_unit_adv          [r]:=SoundSetLoad(race_dir[r]+'unit_adv'                  );
   snd_unit_promoted     [r]:=SoundSetLoad(race_dir[r]+'unit_promoted'             );
   snd_cant_order        [r]:=SoundSetLoad(race_dir[r]+'cant_order'                );
   end;

   /////////////////////////////////////////////////////////////////////////////////
   //
   // UAC
   //

   snd_radar                :=SoundSetLoad(race_dir[r_uac]+'radar');

   snd_jetpoff              :=SoundSetLoad(race_dir[r_uac]+'jetpoff'   );
   snd_jetpon               :=SoundSetLoad(race_dir[r_uac]+'jetpon'    );
   snd_CCup                 :=SoundSetLoad(race_dir[r_uac]+'ccup'      );
   snd_bomblaunch           :=SoundSetLoad(race_dir[r_uac]+'bomblaunch');

   snd_uac_cc               :=SoundSetLoad(race_buildings[r_uac ]+'command_center' );
   snd_uac_barracks         :=SoundSetLoad(race_buildings[r_uac ]+'barraks'        );
   snd_uac_generator        :=SoundSetLoad(race_buildings[r_uac ]+'generator'      );
   snd_uac_smith            :=SoundSetLoad(race_buildings[r_uac ]+'weapon_factory' );
   snd_uac_ctower           :=SoundSetLoad(race_buildings[r_uac ]+'chaingun_tower' );
   snd_uac_radar            :=SoundSetLoad(race_buildings[r_uac ]+'radar_on'       );
   snd_uac_rtower           :=SoundSetLoad(race_buildings[r_uac ]+'rocket_turret'  );
   snd_uac_factory          :=SoundSetLoad(race_buildings[r_uac ]+'factory'        );
   snd_uac_tech             :=SoundSetLoad(race_buildings[r_uac ]+'tech_center'    );
   snd_uac_rls              :=SoundSetLoad(race_buildings[r_uac ]+'rocketstation'  );
   snd_uac_nucl             :=SoundSetLoad(race_buildings[r_uac ]+'nuclear_plant'  );

   snd_uac_suply            :=SoundSetLoad(race_buildings[r_uac ]+'supply-depot'   );
   snd_uac_rescc            :=SoundSetLoad(race_buildings[r_uac ]+'resourse_senter');

   snd_uac_hdeath           :=SoundSetLoad(race_units[r_uac ]+'death'              );

   snd_APC_ready            :=SoundSetLoad(race_units[r_uac ]+'APC\UAC_im_find2'   );
   snd_APC_move             :=SoundSetLoad(race_units[r_uac ]+'APC\uac_u'          );

   snd_bfgmarine_ready      :=SoundSetLoad(race_units[r_uac ]+'bfgmarine\ready'    );
   snd_bfgmarine_annoy      :=SoundSetLoad(race_units[r_uac ]+'bfgmarine\an'       );
   snd_bfgmarine_attack     :=SoundSetLoad(race_units[r_uac ]+'bfgmarine\attack'   );
   snd_bfgmarine_select     :=SoundSetLoad(race_units[r_uac ]+'bfgmarine\select'   );
   snd_bfgmarine_move       :=SoundSetLoad(race_units[r_uac ]+'bfgmarine\go'       );

   snd_commando_ready       :=SoundSetLoad(race_units[r_uac ]+'commando\ready'     );
   snd_commando_annoy       :=SoundSetLoad(race_units[r_uac ]+'commando\annoy'     );
   snd_commando_attack      :=SoundSetLoad(race_units[r_uac ]+'commando\attack'    );
   snd_commando_select      :=SoundSetLoad(race_units[r_uac ]+'commando\select'    );
   snd_commando_move        :=SoundSetLoad(race_units[r_uac ]+'commando\move'      );

   snd_engineer_ready       :=SoundSetLoad(race_units[r_uac ]+'engineer\ready'     );
   snd_engineer_annoy       :=SoundSetLoad(race_units[r_uac ]+'engineer\annoy'     );
   snd_engineer_attack      :=SoundSetLoad(race_units[r_uac ]+'engineer\attack'    );
   snd_engineer_select      :=SoundSetLoad(race_units[r_uac ]+'engineer\select'    );
   snd_engineer_move        :=SoundSetLoad(race_units[r_uac ]+'engineer\move'      );

   snd_scout_ready          :=SoundSetLoad(race_units[r_uac ]+'scout\ready'        );
   snd_scout_select         :=SoundSetLoad(race_units[r_uac ]+'scout\select'       );
   snd_scout_move           :=SoundSetLoad(race_units[r_uac ]+'scout\go'           );

   snd_medic_ready          :=SoundSetLoad(race_units[r_uac ]+'medic\ready'        );
   snd_medic_annoy          :=SoundSetLoad(race_units[r_uac ]+'medic\annoy'        );
   snd_medic_select         :=SoundSetLoad(race_units[r_uac ]+'medic\select'       );
   snd_medic_move           :=SoundSetLoad(race_units[r_uac ]+'medic\move'         );

   snd_plasmamarine_ready   :=SoundSetLoad(race_units[r_uac ]+'plasmamarine\ready' );
   snd_plasmamarine_annoy   :=SoundSetLoad(race_units[r_uac ]+'plasmamarine\annoy' );
   snd_plasmamarine_attack  :=SoundSetLoad(race_units[r_uac ]+'plasmamarine\attack');
   snd_plasmamarine_select  :=SoundSetLoad(race_units[r_uac ]+'plasmamarine\select');
   snd_plasmamarine_move    :=SoundSetLoad(race_units[r_uac ]+'plasmamarine\move'  );

   snd_rocketmarine_ready   :=SoundSetLoad(race_units[r_uac ]+'rocketmarine\rocket_ready');
   snd_rocketmarine_annoy   :=SoundSetLoad(race_units[r_uac ]+'rocketmarine\rocket_irr'  );
   snd_rocketmarine_attack  :=SoundSetLoad(race_units[r_uac ]+'rocketmarine\rocket_atk'  );
   snd_rocketmarine_select  :=SoundSetLoad(race_units[r_uac ]+'rocketmarine\rocket_sel'  );
   snd_rocketmarine_move    :=SoundSetLoad(race_units[r_uac ]+'rocketmarine\rocket_conf' );

   snd_shotgunner_ready     :=SoundSetLoad(race_units[r_uac ]+'shotgunner\ready'   );
   snd_shotgunner_annoy     :=SoundSetLoad(race_units[r_uac ]+'shotgunner\an'      );
   snd_shotgunner_attack    :=SoundSetLoad(race_units[r_uac ]+'shotgunner\attack'  );
   snd_shotgunner_select    :=SoundSetLoad(race_units[r_uac ]+'shotgunner\select'  );
   snd_shotgunner_move      :=SoundSetLoad(race_units[r_uac ]+'shotgunner\go'      );

   snd_ssg_ready            :=SoundSetLoad(race_units[r_uac ]+'ssg\ready'          );
   snd_ssg_annoy            :=SoundSetLoad(race_units[r_uac ]+'ssg\annoy'          );
   snd_ssg_attack           :=SoundSetLoad(race_units[r_uac ]+'ssg\attack'         );
   snd_ssg_select           :=SoundSetLoad(race_units[r_uac ]+'ssg\select'         );
   snd_ssg_move             :=SoundSetLoad(race_units[r_uac ]+'ssg\move'           );

   snd_tank_ready           :=SoundSetLoad(race_units[r_uac ]+'tank\ready'         );
   snd_tank_annoy           :=SoundSetLoad(race_units[r_uac ]+'tank\annoy'         );
   snd_tank_attack          :=SoundSetLoad(race_units[r_uac ]+'tank\attack'        );
   snd_tank_select          :=SoundSetLoad(race_units[r_uac ]+'tank\select'        );
   snd_tank_move            :=SoundSetLoad(race_units[r_uac ]+'tank\move'          );

   snd_uacbot_annoy         :=SoundSetLoad(race_units[r_uac ]+'uacbot\annoy'       );
   snd_uacbot_attack        :=SoundSetLoad(race_units[r_uac ]+'uacbot\attack'      );
   snd_uacbot_select        :=SoundSetLoad(race_units[r_uac ]+'uacbot\select'      );
   snd_uacbot_move          :=SoundSetLoad(race_units[r_uac ]+'uacbot\move'        );

   snd_terminator_ready     :=SoundSetLoad(race_units[r_uac ]+'terminator\ready'   );
   snd_terminator_annoy     :=SoundSetLoad(race_units[r_uac ]+'terminator\annoy'   );
   snd_terminator_attack    :=SoundSetLoad(race_units[r_uac ]+'terminator\attack'  );
   snd_terminator_select    :=SoundSetLoad(race_units[r_uac ]+'terminator\select'  );
   snd_terminator_move      :=SoundSetLoad(race_units[r_uac ]+'terminator\move'    );

   snd_transport_ready      :=SoundSetLoad(race_units[r_uac ]+'transport\ready'    );
   snd_transport_annoy      :=SoundSetLoad(race_units[r_uac ]+'transport\annoy'    );
   snd_transport_select     :=SoundSetLoad(race_units[r_uac ]+'transport\select'   );
   snd_transport_move       :=SoundSetLoad(race_units[r_uac ]+'transport\move'     );

   snd_uacfighter_ready     :=SoundSetLoad(race_units[r_uac ]+'uacfighter\ready'   );
   snd_uacfighter_annoy     :=SoundSetLoad(race_units[r_uac ]+'uacfighter\an'      );
   snd_uacfighter_attack    :=SoundSetLoad(race_units[r_uac ]+'uacfighter\attack'  );
   snd_uacfighter_select    :=SoundSetLoad(race_units[r_uac ]+'uacfighter\select'  );
   snd_uacfighter_move      :=SoundSetLoad(race_units[r_uac ]+'uacfighter\go'      );


   /////////////////////////////////////////////////////////////////////////////////
   //
   // HELL
   //

   snd_hell_hk              :=SoundSetLoad(race_buildings[r_hell]+'hell_keep'     );
   snd_hell_hgate           :=SoundSetLoad(race_buildings[r_hell]+'hell_gate'     );
   snd_hell_hsymbol         :=SoundSetLoad(race_buildings[r_hell]+'hell_symbol'   );
   snd_hell_hpool           :=SoundSetLoad(race_buildings[r_hell]+'hell_pool'     );
   snd_hell_htower          :=SoundSetLoad(race_buildings[r_hell]+'hell_tower'    );
   snd_hell_hteleport       :=SoundSetLoad(race_buildings[r_hell]+'hell_teleport' );
   snd_hell_htotem          :=SoundSetLoad(race_buildings[r_hell]+'hell_totem'    );
   snd_hell_hmon            :=SoundSetLoad(race_buildings[r_hell]+'hell_monastery');
   snd_hell_hfort           :=SoundSetLoad(race_buildings[r_hell]+'hell_temple'   );
   snd_hell_haltar          :=SoundSetLoad(race_buildings[r_hell]+'hell_altar'    );
   snd_hell_hbuild          :=SoundSetLoad(race_buildings[r_hell]+'hell_building' );
   snd_hell_eye             :=SoundSetLoad(race_buildings[r_hell]+'hell_eye'      );

   snd_hell                 :=SoundSetLoad(race_dir[r_hell]+'hell' );

   snd_hell_invuln          :=SoundSetLoad(race_units[r_hell]+'invuln');
   snd_hell_pain            :=SoundSetLoad(race_units[r_hell]+'d_p');
   snd_hell_melee           :=SoundSetLoad(race_units[r_hell]+'d_m');
   snd_hell_attack          :=SoundSetLoad(race_units[r_hell]+'d_a');
   snd_hell_move            :=SoundSetLoad(race_units[r_hell]+'d_' );

   snd_zimba_death          :=SoundSetLoad(race_units[r_hell]+'zimbas\d_z_d' );
   snd_zimba_ready          :=SoundSetLoad(race_units[r_hell]+'zimbas\d_z_s' );
   snd_zimba_pain           :=SoundSetLoad(race_units[r_hell]+'zimbas\d_z_p' );
   snd_zimba_move           :=SoundSetLoad(race_units[r_hell]+'zimbas\d_z_ac');

   snd_revenant_death       :=SoundSetLoad(race_units[r_hell]+'revenant\d_rev_d' );
   snd_revenant_ready       :=SoundSetLoad(race_units[r_hell]+'revenant\d_rev_c' );
   snd_revenant_melee       :=SoundSetLoad(race_units[r_hell]+'revenant\d_rev_m' );
   snd_revenant_attack      :=SoundSetLoad(race_units[r_hell]+'revenant\d_rev_a' );
   snd_revenant_move        :=SoundSetLoad(race_units[r_hell]+'revenant\d_rev_ac');

   snd_pain_ready           :=SoundSetLoad(race_units[r_hell]+'pain\d_pain_c');
   snd_pain_death           :=SoundSetLoad(race_units[r_hell]+'pain\d_pain_d');
   snd_pain_pain            :=SoundSetLoad(race_units[r_hell]+'pain\d_pain_p');

   snd_mastermind_ready     :=SoundSetLoad(race_units[r_hell]+'mastermind\d_u6_c');
   snd_mastermind_death     :=SoundSetLoad(race_units[r_hell]+'mastermind\d_u6_d');
   snd_mastermind_foot      :=SoundSetLoad(race_units[r_hell]+'mastermind\d_u6_f');

   snd_mancubus_ready       :=SoundSetLoad(race_units[r_hell]+'mancubus\d_man_c');
   snd_mancubus_death       :=SoundSetLoad(race_units[r_hell]+'mancubus\d_man_d');
   snd_mancubus_pain        :=SoundSetLoad(race_units[r_hell]+'mancubus\d_man_p');
   snd_mancubus_attack      :=SoundSetLoad(race_units[r_hell]+'mancubus\d_man_a');

   snd_lost_move            :=SoundSetLoad(race_units[r_hell]+'lost\d_u0'     );

   snd_knight_ready         :=SoundSetLoad(race_units[r_hell]+'knight\knightc');
   snd_knight_death         :=SoundSetLoad(race_units[r_hell]+'knight\knightd');
   snd_baron_ready          :=SoundSetLoad(race_units[r_hell]+'baron\d_u4_c'  );
   snd_baron_death          :=SoundSetLoad(race_units[r_hell]+'baron\d_u4_d'  );

   snd_imp_ready            :=SoundSetLoad(race_units[r_hell]+'imp\d_u1_s');
   snd_imp_death            :=SoundSetLoad(race_units[r_hell]+'imp\d_u1_d');
   snd_imp_move             :=SoundSetLoad(race_units[r_hell]+'imp\d_imp' );

   snd_demon_ready          :=SoundSetLoad(race_units[r_hell]+'demon\d_u2'   );
   snd_demon_death          :=SoundSetLoad(race_units[r_hell]+'demon\d_u2_d' );
   snd_demon_melee          :=SoundSetLoad(race_units[r_hell]+'demon\d_u2_a' );

   snd_cyber_ready          :=SoundSetLoad(race_units[r_hell]+'cyber\d_u5'   );
   snd_cyber_death          :=SoundSetLoad(race_units[r_hell]+'cyber\d_u5_d' );
   snd_cyber_foot           :=SoundSetLoad(race_units[r_hell]+'cyber\d_u5_f' );

   snd_caco_death           :=SoundSetLoad(race_units[r_hell]+'caco\d_u3_d'   );
   snd_caco_ready           :=SoundSetLoad(race_units[r_hell]+'caco\d_u3'     );

   snd_archvile_death       :=SoundSetLoad(race_units[r_hell]+'archvile\d_arch_d' );
   snd_archvile_attack      :=SoundSetLoad(race_units[r_hell]+'archvile\d_arch_at');
   snd_archvile_fire        :=SoundSetLoad(race_units[r_hell]+'archvile\d_arch_f' );
   snd_archvile_pain        :=SoundSetLoad(race_units[r_hell]+'archvile\d_arch_p' );
   snd_archvile_ready       :=SoundSetLoad(race_units[r_hell]+'archvile\d_arch_c' );
   snd_archvile_move        :=SoundSetLoad(race_units[r_hell]+'archvile\d_arch_a' );

   snd_arachno_death        :=SoundSetLoad(race_units[r_hell]+'arachnotron\d_ar_d');
   snd_arachno_move         :=SoundSetLoad(race_units[r_hell]+'arachnotron\d_ar_act');
   snd_arachno_foot         :=SoundSetLoad(race_units[r_hell]+'arachnotron\d_ar_f');
   snd_arachno_ready        :=SoundSetLoad(race_units[r_hell]+'arachnotron\d_ar_c');

   InitSound:=true;
end;




