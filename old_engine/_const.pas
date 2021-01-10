
const

ver                    : byte = 230;

degtorad               = pi/180;

////////////////////////////////////////////////////////////////////////////////
//
//  FRAME RATE
//

fr_fps                 = 60;
fr_hfps                = fr_fps div 2;
fr_hhfps               = fr_hfps div 2;
fr_2fps                = fr_fps*2;
fr_3fps                = fr_fps*3;
fr_mpt                 = trunc(1000/fr_fps);


////////////////////////////////////////////////////////////////////////////////
//
//  BASE
//

ps_none                = 0;  // player state
ps_play                = 1;
ps_comp                = 2;

gm_scir                = 0;  // game mode
gm_2fort               = 1;
gm_3fort               = 2;
gm_ct                  = 3;
gm_inv                 = 4;
gm_coop                = 5;

r_cnt                  = 2;  // race
r_random               = 0;
r_hell                 = 1;
r_uac                  = 2;

MaxPlayers             = 6;
MaxPlayerUnits         = 110;
MaxCPoints             = 6;

MaxSMapW               = 7000;
MinSMapW               = 3000;

build_b                = 5;

////////////////////////////////////////////////////////////////////////////////
//
//  BASE STRINGS
//

str_ver                = 'v51';
str_wcaption           : shortstring = 'The Ultimate MarsWars '+str_ver+#0;
str_cprt               : shortstring = '[ T3DStudio (c) 2016-2021 ]';
str_ps_c               : array[0..2] of char = ('-','P','C');
str_ps_t               : char = '?';
str_ps_comp            : shortstring = 'AI';
str_ps_h               : char = '<';
str_ps_none            : shortstring = '--';
b2pm                   : array[false..true] of string[3] = (#15+'-'+#25,#18+'+'+#25);
_str_mx                : array[0..12] of shortstring = ('-','x1','x2','x3','x4','x5','x6','x7','x8','x9','x10','x11','x12');

outlogfn               : shortstring = 'out.txt';

////////////////////////////////////////////////////////////////////////////////
//
//  NETGAME
//

                                             // 60 140 220 300 380 460 540 620 700 780
_cl_pnua               : array[0..9] of byte = (15,35 ,55 ,75 ,95 ,115,135,155,175,195);

ClientTTL              = fr_fps*10;

NetTickN               = 2;
MaxNetChat             = 16;
MaxNetBuffer           = 4096;

ns_none                = 0;
ns_srvr                = 1;
ns_clnt                = 2;

nmid_startinf          = 3;
nmid_connect           = 4;
nmid_clinf             = 5;
nmid_chat              = 6;
nmid_chatclupd         = 7;
nmid_shap              = 8;
nmid_pause             = 9;
nmid_sfull             = 10;
nmid_sver              = 11;
nmid_sgst              = 12;
nmid_ncon              = 13;
nmid_swapp             = 14;
nmid_order             = 15;
nmid_plout             = 16;
nmid_getinfo           = 66;

////////////////////////////////////////////////////////////////////////////////
//
//  PLAYER ORDERS
//

uo_build               = 1;
uo_dblselect           = 2;
uo_adblselect          = 3;
uo_select              = 4;
uo_aselect             = 5;
uo_selorder            = 6;
uo_setorder            = 7;
uo_corder              = 8;
uo_specsel             = 9;
uo_addorder            = 10;

////////////////////////////////////////////////////////////////////////////////
//
//  UNIT OTDERS
//

co_empty               = -32000;
co_destroy             = -111;
co_rcamove             = -101;
co_rcmove              = -100;
co_stand               = -90;
co_move                = -91;
co_patrol              = -92;
co_astand              = -93;
co_amove               = -94;
co_apatrol             = -95;
co_paction             = -79;
co_action              = -80;
co_supgrade            = -81;
co_cupgrade            = -82;
co_suprod              = -83;
co_cuprod              = -84;
co_pcancle             = -85;

////////////////////////////////////////////////////////////////////////////////
//
//  UNIT ACTIONS
//

ua_move                = 1;
ua_hold                = 2;
ua_amove               = 3;
ua_unload              = 4;
ua_paction             = 5;

////////////////////////////////////////////////////////////////////////////////
//
//  Conditionals for attack
//

atm_none             = 0;
atm_always           = 1;
atm_bunker           = 2;
atm_sturret          = 3;
atm_inapc            = 4;


////////////////////////////////////////////////////////////////////////////////
//
//  Weapon: requirements to attacker and some flags
//

wpr_any              : cardinal =  0;
wpr_adv              : cardinal =  1;
wpr_nadv             : cardinal =  1 shl 1;
wpr_zombie           : cardinal =  1 shl 2;


////////////////////////////////////////////////////////////////////////////////
//
//  Target flag
//

wtr_owner_p          : cardinal =  1;         // own
wtr_owner_a          : cardinal =  1 shl 1;   // ally
wtr_owner_e          : cardinal =  1 shl 2;   // enemy

wtr_hits_h           : cardinal =  1 shl 3;   // 0<hits<mhits
wtr_hits_d           : cardinal =  1 shl 4;   // hits<=0
wtr_hits_a           : cardinal =  1 shl 5;   // hits=mhits

wtr_bio              : cardinal =  1 shl 6;   // non mech
wtr_mech             : cardinal =  1 shl 7;   // mech and !building
wtr_building         : cardinal =  1 shl 8;   // building

wtr_bld              : cardinal =  1 shl 9;   // bld=true
wtr_nbld             : cardinal =  1 shl 10;  // bld=false

wtr_ground           : cardinal =  1 shl 11;
wtr_soaring          : cardinal =  1 shl 12;
wtr_fly              : cardinal =  1 shl 13;

wtr_adv              : cardinal =  1 shl 14;
wtr_nadv             : cardinal =  1 shl 15;

////////////////////////////////////////////////////////////////////////////////
//
//  Weapon: type
//

wpt_missle           = 0;
wpt_resurect         = 1;
wpt_heal             = 2;
wpt_unit             = 3;
wpt_directdmg        = 4;


////////////////////////////////////////////////////////////////////////////////
//
//  AI FLAGS
//

{aif_dattack            : cardinal = 1       ; // default attack sequense
aif_pushuids           : cardinal = 1 shl 1 ; // push only ai_pushuids
aif_pushair            : cardinal = 1 shl 2 ; // push air
aif_pushgrnd           : cardinal = 1 shl 3 ; // push ground
aif_help               : cardinal = 1 shl 4 ; // help allies
aif_hrrsmnt            : cardinal = 1 shl 5 ; // attacks with small forces
aif_usex5              : cardinal = 1 shl 6 ; // use teleport and radar
aif_nofogblds          : cardinal = 1 shl 7 ; // AI see enemy buildings through fog
aif_nofogunts          : cardinal = 1 shl 8 ; // AI see enemy units through fog
aif_alrmtwrs           : cardinal = 1 shl 9 ; // Builders build towers when alarm near
aif_CCescape           : cardinal = 1 shl 10; // CC and HK escape from alarm
aif_CCattack           : cardinal = 1 shl 11; // CC and HK attack
aif_buildseq1          : cardinal = 1 shl 12; // Base build order
aif_buildseq2          : cardinal = 1 shl 13; // Adv build order
aif_usex6              : cardinal = 1 shl 14; // Use advanced units
aif_usex8              : cardinal = 1 shl 15; // Use hell altar and rocket l station
aif_smarttpri          : cardinal = 1 shl 16; // Smart target priority
aif_upgrseq1           : cardinal = 1 shl 17; // Base upgr order
aif_upgrseq2           : cardinal = 1 shl 18; // Adv upgr order
aif_twrtlprt           : cardinal = 1 shl 19; // Hell Towers teleportation
aif_specblds           : cardinal = 1 shl 20; // Mines and Hell Eyes managment
aif_usex9              : cardinal = 1 shl 21; // Use adnvanced buildings
aif_destrblds          : cardinal = 1 shl 22; // Destroy buildngs
aif_unitaacts          : cardinal = 1 shl 23; // Units micro and actions
aif_useapcs            : cardinal = 1 shl 24; // Use transports
aif_hrsmntapcs         : cardinal = 1 shl 25; // transport harrasment
aif_smartbar           : cardinal = 1 shl 26; // Smart unit production
aif_detecatcs          : cardinal = 1 shl 27; // Mines and Hell Eyes
aif_stayathome         : cardinal = 1 shl 28; //   }

////////////////////////////////////////////////////////////////////////////////
//
//  UNIT BUFFs
//

_ubuffs                = 15;

ub_advanced            = 0;
ub_pain                = 1;
ub_toxin               = 2;
ub_gear                = 3;
ub_resur               = 4;
ub_cast                = 5;
ub_stopafa             = 6;
ub_slooow              = 7;
ub_clcast              = 8;
ub_invis               = 9;
ub_detect              = 10;
ub_invuln              = 11;
ub_notarget            = 12;
ub_born                = 13;
ub_cnttrans            = 14;
ub_teleeff             = 15;

_bufinf                = 32000;


////////////////////////////////////////////////////////////////////////////////
//
//  OBSTACLES
//

MaxDoodads             = 700;

//
ddc_div                = 1000000;
ddc_cf                 = (MaxSMapW*MaxSMapW) div ddc_div; // 49

// doodads cell
dcw                    = 200;
dcn                    = MaxSMapW div dcw;

DID_LiquidR1           = 1;
DID_LiquidR2           = 2;
DID_LiquidR3           = 3;
DID_LiquidR4           = 4;
DID_BRock              = 5;
DID_SRock              = 6;
DID_Other              = 7;

dids_liquids           = [DID_LiquidR1..DID_LiquidR4];

DID_R                  : array[0..7] of integer = (0,250,185,125,64,105,60,17);


////////////////////////////////////////////////////////////////////////////////
//
//  UPGRADES
//

upgr_hell_attack       = 1;  // distance attack
upgr_hell_armor        = 2;  // base armor
upgr_hell_build        = 3;  // base b armor
upgr_hell_melee        = 4;  // melee attack / repair/health upgr
upgr_hell_regen        = 5;  // hell
upgr_hell_pains        = 6;  // pain state
upgr_hell_heye         = 7;  // Hell Eye
upgr_hell_towers       = 8;  // towers sr
upgr_hell_5bld         = 9;  // Teleport/Radar
upgr_hell_mainm        = 10; // Main b move
upgr_hell_paina        = 11; // decay aura
upgr_hell_mainr        = 12; // main sr
upgr_hell_pinkspd      = 13; // demon speed
upgr_hell_misfst       = 14; // missiles fast
upgr_hell_6bld         = 15; // Souls / adv
upgr_hell_2tier        = 16; // Tier 2
upgr_hell_revtele      = 17; // revers teleport
upgr_hell_revmis       = 18; // revenant missile
upgr_hell_totminv      = 19; // totem and eye invisible
upgr_hell_bldrep       = 20; // build repair
upgr_hell_mainonr      = 21; // main on doodabs
upgr_hell_b478tel      = 22; // teleport towers and altars
upgr_hell_hinvuln      = 23; // hell invuln powerup
upgr_hell_bldenrg      = 24; // additional energy
upgr_hell_9bld         = 25; // 9 class building reload time


upgr_uac_attack        = 31; // distance attack
upgr_uac_armor         = 32; // base armor
upgr_uac_build         = 33; // base b armor
upgr_uac_melee         = 34; // repair/health upgr
upgr_uac_mspeed        = 35; // infantry speed
upgr_uac_plsmt         = 36; // turrent for apcs
upgr_uac_vision        = 37; // detectors
upgr_uac_towers        = 38; // towers sr
upgr_uac_5bld          = 39; // Teleport/Radar
upgr_uac_mainm         = 40; // Main b move
upgr_uac_ucomatt       = 41; // CC turret
upgr_uac_mainr         = 42; // main sr
upgr_uac_mines         = 43; // mines for engineers
upgr_uac_minesen       = 44; // mine-sensor
upgr_uac_6bld          = 45; // Souls / adv
upgr_uac_2tier         = 46; // Tier 2
upgr_uac_blizz         = 47; // blizzard launch
upgr_uac_mechspd       = 48; // mech speed
upgr_uac_mecharm       = 49; // mech arm
upgr_uac_6bld2         = 50; // 6bld upgr
upgr_uac_mainonr       = 51; // main on doodabs
upgr_uac_turarm        = 52; // turrets armor
upgr_uac_rturrets      = 53; // rocket turrets
upgr_uac_bldenrg       = 54; // additional energy
upgr_uac_9bld          = 55; // 9 class building reload time

upgr_fast_build        = 250;
upgr_fast_product      = 251;
upgr_mult_product      = 252;
upgr_invuln            = 255;


////////////////////////////////////////////////////////////////////////////////
//
//  MISSILES
//

MID_Imp                = 101;
MID_Cacodemon          = 102;
MID_Baron              = 103;
MID_HRocket            = 104;
MID_Revenant           = 105;
MID_RevenantS          = 106;
MID_Mancubus           = 107;
MID_YPlasma            = 108;
MID_BPlasma            = 109;
MID_Bullet             = 110;
MID_Bulletx2           = 111;
MID_TBullet            = 112;
MID_MBullet            = 113;
MID_SShot              = 114;
MID_SSShot             = 115;
MID_BFG                = 116;
MID_Granade            = 117;
MID_Tank               = 118;
MID_Mine               = 119;
MID_Blizzard           = 120;
MID_ArchFire           = 121;
MID_Flyer              = 122;


////////////////////////////////////////////////////////////////////////////////
//
//  UNITS
//

MaxUnits               = MaxPlayers*MaxPlayerUnits+MaxPlayerUnits;
MaxUnitWeapons         = 2; //0-2
MaxWeaponShootState    = 2;
MaxUnitProds           = 1; //0-1

uf_ground              = 0;
uf_soaring             = 1;
uf_fly                 = 2;

UID_HKeep              = 1;
UID_HGate              = 2;
UID_HSymbol            = 3;
UID_HPools             = 4;
UID_HTower             = 5;
UID_HTeleport          = 6;
UID_HMonastery         = 7;
UID_HTotem             = 8;
UID_HAltar             = 9;
UID_HFortress          = 10;
UID_HEye               = 11;
UID_HCommandCenter     = 12;
UID_HMilitaryUnit      = 13;

UID_LostSoul           = 15;
UID_Imp                = 16;
UID_Demon              = 17;
UID_Cacodemon          = 18;
UID_Baron              = 19;
UID_Cyberdemon         = 20;
UID_Mastermind         = 21;
UID_Pain               = 22;
UID_Revenant           = 23;
UID_Mancubus           = 24;
UID_Arachnotron        = 25;
UID_Archvile           = 26;
UID_ZFormer            = 27;
UID_ZEngineer          = 28;
UID_ZSergant           = 29;
UID_ZCommando          = 30;
UID_ZBomber            = 31;
UID_ZMajor             = 32;
UID_ZBFG               = 33;


UID_UCommandCenter     = 41;
UID_UMilitaryUnit      = 42;
UID_UGenerator         = 43;
UID_UWeaponFactory     = 44;
UID_UTurret            = 45;
UID_URadar             = 46;
UID_UVehicleFactory    = 47;
UID_UPTurret           = 48;
UID_URocketL           = 49;
UID_URTurret           = 50;
UID_UNuclearPlant      = 51;
UID_UMine              = 52;

UID_Engineer           = 55;
UID_Medic              = 56;
UID_Sergant            = 57;
UID_Commando           = 58;
UID_Bomber             = 59;
UID_Major              = 60;
UID_BFG                = 61;
UID_FAPC               = 62;
UID_APC                = 64;
UID_Terminator         = 65;
UID_Tank               = 66;
UID_Flyer              = 67;
UID_UTransport         = 68;

UID_UBaseMil           = 70;
UID_UBaseCom           = 71;
UID_UBaseGen           = 72;
UID_UBaseRef           = 73;
UID_UBaseNuc           = 74;
UID_UBaseLab           = 75;
UID_UCBuild            = 76;
UID_USPort             = 77;
UID_UPortal            = 78;


uids_hell              = [1 ..40];
uids_uac               = [41..80];

start_base             : array[1..r_cnt] of integer = (UID_HKeep,UID_UCommandCenter);

t2                     = [UID_URocketL,UID_URTurret,UID_HTotem,UID_HAltar,UID_Terminator,UID_Tank,UID_Flyer,UID_Pain..UID_Archvile];

marines                = [UID_Engineer ,UID_Medic   ,UID_Sergant ,UID_Commando ,UID_Bomber ,UID_Major ,UID_BFG ];
zimbas                 = [UID_ZEngineer,UID_ZFormer ,UID_ZSergant,UID_ZCommando,UID_ZBomber,UID_ZMajor,UID_ZBFG];
gavno                  = marines+[UID_Imp]+zimbas-[UID_ZEngineer];
arch_res               = [UID_Imp..UID_Baron,UID_Revenant..UID_Arachnotron]+zimbas;
demons                 = [UID_LostSoul..UID_Archvile]+zimbas;
whocanattack           = demons+marines+[UID_Terminator..UID_Flyer,UID_UMine,UID_APC,UID_FAPC,UID_HTower,UID_HTotem,UID_HCommandCenter,UID_UCommandCenter,UID_UTurret,UID_UPTurret,UID_URTurret];
whocanmp               = [UID_HGate,UID_UMilitaryUnit,UID_HTeleport,UID_UVehicleFactory,UID_HMilitaryUnit];

coopspawn              = marines+demons+[UID_Terminator,UID_Tank,UID_Flyer];

slowturn               = [UID_APC,UID_Tank];

armor_lite             = marines+zimbas+[UID_LostSoul,UID_Imp,UID_Revenant];
armor_massive           = [UID_Cyberdemon,UID_Mastermind,UID_Mancubus,UID_Arachnotron];


////////////////////////////////////////////////////////////////////////////////
//
//  OTHER
//


NameLen                = 13;
ChatLen                = 38;

gavno_dth_h            = -40;
dead_hits              = -12*fr_fps;
idead_hits             = dead_hits+fr_3fps;
ndead_hits             = dead_hits-1;

//upgr_1                 : array[1..r_cnt] of set of byte = ([upgr_6bld,upgr_b478tel,upgr_hinvuln],[upgr_blizz]);
ai_d2alrm              : array[false..true] of integer = (150,15);
builder_enrg           : array[0..4] of byte = (6,7,8,9,10);
base_r                 = 350;
base_rr                = base_r*2;
base_3r                = base_r*3;
base_ir                = base_r+(base_r div 2);
base_rA                : array[0..2] of integer = (280,320,360);
uaccc_fly              = 23;
apc_exp_damage         = 70;
regen_per              = fr_fps*2;
_uclord_p              = fr_hfps+1;
vistime                = _uclord_p+1;

radar_time             = fr_fps*30;
radar_rlda             : array[0..5] of integer = (radar_time-fr_fps*3,radar_time-fr_fps*5,radar_time-fr_fps*7,radar_time-fr_fps*9,radar_time-fr_fps*11,radar_time-fr_fps*13);
radar_rsg              : array[0..5] of integer = (200,225,250,275,300,325);
eye_rsg                : array[0..5] of integer = (250,275,300,325,350,375);
melee_r                = 8;
missile_mr             = 500;
gear_time              : array[false..true] of byte = (fr_fps,fr_fps*2);
dir_stepX              : array[0..7] of integer = (1,1,0,-1,-1,-1,0,1);
dir_stepY              : array[0..7] of integer = (0,-1,-1,-1,0,1,1,1);
rocket_sr              = 45;
map_ffly_fapc          : array[false..true] of byte = (3,6);
map_gapc               : array[false..true] of byte = (8,5);
towers_sr              : array[0..5] of integer = (250,265,280,295,310,325);
blizz_r                = 150;
mech_adv_rel           : array[false..true] of integer = (fr_fps*12,fr_fps*6);
uac_adv_rel            : array[false..true] of integer = (fr_fps*3,fr_fps);
g_ct_pr                = 150;
g_ct_ct                : array[1..r_cnt] of integer = (fr_fps*10,fr_fps*5);
bld_dec_mr             = 6;
def_ai                 = 5;
pain_time              = fr_hfps;
hinvuln_time           = (fr_fps*30);
_mms                   = 126;
_d2shi                 = abs(dead_hits div 126)+1;   // 5
advprod_rld            : array[false..true] of integer = (fr_fps*120,fr_fps*60);

fly_z                  = 30;
fly_height             : array[0..2] of integer = (1,fly_z*uf_soaring,fly_z*uf_fly);

map_flydpth            : array[0..2] of integer = (0,MaxSMapW*2,MaxSMapW*3);

{$IFDEF _FULLGAME}

////////////////////////////////////////////////////////////////////////////////
//
//  HOTKEYS
//

_mhkeys  = 26;
_hotkey1 : array[0.._mhkeys] of cardinal = (SDLK_R , SDLK_T , SDLK_Y ,
                                            SDLK_F , SDLK_G , SDLK_H ,
                                            SDLK_V , SDLK_B , SDLK_N ,

                                            SDLK_U , SDLK_I , SDLK_O ,
                                            SDLK_J , SDLK_K , SDLK_L ,
                                            SDLK_R , SDLK_T , SDLK_Y ,

                                            SDLK_F , SDLK_G , SDLK_H ,
                                            SDLK_V , SDLK_B , SDLK_N ,
                                            SDLK_R , SDLK_T , SDLK_Y );

_hotkey2 : array[0.._mhkeys] of cardinal = (0      , 0      , 0      ,
                                            0      , 0      , 0      ,
                                            0      , 0      , 0      ,

                                            0      , 0      , 0      ,
                                            0      , 0      , 0      ,
                                            SDLK_LCtrl, SDLK_LCtrl, SDLK_LCtrl,

                                            SDLK_LCtrl, SDLK_LCtrl, SDLK_LCtrl,
                                            SDLK_LCtrl, SDLK_LCtrl, SDLK_LCtrl,
                                            SDLK_LCtrl, SDLK_LCtrl, SDLK_LAlt);

_hotkeyA : array[0..11     ] of cardinal = (SDLK_Q , SDLK_W , SDLK_E ,
                                            SDLK_A , SDLK_S , SDLK_D ,
                                            SDLK_Z , SDLK_M , SDLK_C ,
                                            SDLK_X , SDLK_F2, SDLK_Delete );

_hotkeyR : array[0..14     ] of cardinal = (SDLK_Q , SDLK_W , SDLK_E ,
                                            SDLK_A , SDLK_S , SDLK_D ,
                                            SDLK_Z , SDLK_X , SDLK_C ,
                                            SDLK_R , SDLK_T , SDLK_Y ,
                                            SDLK_F , SDLK_G , SDLK_H      );


whocanaction           = [UID_Engineer,UID_UCommandCenter,UID_APC,UID_FAPC,UID_LostSoul,UID_Pain,UID_UMine,UID_UTurret,UID_UPTurret];

_buffst                : array[false..true] of smallint = (0,_bufinf);

str_ps_sv              : char = '@';

ChatLen2               = 255;
dead_time              = -dead_hits;
hp_detect              = #7;
hp_pshield             = #8;
adv_char               = #10;
revenant_ra            : array[false..true] of integer = (45,20);


////////////////////////////////////////////////////////////////////////////////
//
//  SPRITE MODEL KINDS
//

smt_effect             = 0;  // simple missile or effect
smt_missile            = 1;  // missile with direction
smt_buiding            = 2;
smt_turret             = 3;
smt_turret2            = 4;
smt_lost               = 5;  //UID_Lost
smt_imp                = 6;  //UID_Imp,UID_Demon,UID_ZFormer,UID_ZSergant,UID_ZBomber,UID_ZBFG,UID_Baron,UID_Cyberdemon:
smt_zengineer          = 7;  //UID_ZEngineer
smt_zcommando          = 8;  //UID_ZCommando
smt_fmajor             = 9;  //UID_Majot,UID_ZMajor
smt_caco               = 10; //UID_Cacodemon
smt_mmind              = 11; //UID_Mastermind
smt_pain               = 12; //UID_Pain
smt_revenant           = 13; //UID_Revenant
smt_mancubus           = 14; //UID_Mancubus
smt_archno             = 15; //UID_Arachnotron
smt_arch               = 16; //UID_ArachVile
smt_apc                = 17; //UID_APC
smt_fapc               = 18; //UID_FAPC
smt_marine0            = 19; //UID_Engineer,UID_Sergant,UID_Bomber,UID_BFG
smt_medic              = 20; //UID_Medic
smt_commando           = 21; //UID_Commando
smt_tank               = 22; //UID_Tank
smt_terminat           = 23; //UID_Terminator
smt_transport          = 24; //UID_Transport


////////////////////////////////////////////////////////////////////////////////
//
//  SPRITE MODEL STATES
//

sms_walk               = 0; // & stand
sms_pain               = 1;
sms_cast               = 2;
sms_dattack            = 3;
sms_mattack            = 4;
sms_death              = 5;
sms_build              = 6;


////////////////////////////////////////////////////////////////////////////////
//
//  EFFECTS
//

EID_BFG                = 200;
EID_BExp               = 201;
EID_BBExp              = 202;
EID_Teleport           = 203;
EID_Exp                = 204;
EID_Exp2               = 205;
EID_Gavno              = 206;
EID_HKT_h              = 207;
EID_HKT_s              = 208;
EID_db_h0              = 209;
EID_db_h1              = 210;
EID_db_u0              = 211;
EID_db_u1              = 212;
EID_Blood              = 213;
EID_ArchFire           = 214;
EID_HUpgr              = 215;
EID_HAMU               = 216;
EID_HMU                = 218;
EID_HCC                = 219;

////////////////////////////////////////////////////////////////////////////////
//
//  VIDEO & UI
//

fr_ifps                = fr_fps-1;

vid_bpp                = 32;
vid_minw               = 800;
vid_minh               = 600;
vid_maxw               = 1360;
vid_maxh               = 768;
vid_ab                 = 128;
vid_mvs                = 500; // max vis sprites;
vid_rtuir              = 6;
vid_rtuis              = fr_fps div vid_rtuir;
vid_rtuish             = vid_rtuis div 2;
vid_uialrm_t           = fr_fps div (vid_rtuir div 3);
vid_uialrm_ti          = vid_uialrm_t div 3;

vid_uialrm_mr          = vid_uialrm_t-(vid_uialrm_t div 3);
vid_BW                 = 44;
vid_2BW                = vid_BW*2;
vid_panelw             = vid_BW*3;
vid_tBW                = vid_panelw div 4;
vid_thBW               = vid_tBW div 2;
vid_2tBW               = vid_tBW*2;
//vid_3tBW               = vid_panel div 4;
vid_hBW                = vid_BW div 2;
vid_oiw                = 18;
vid_oihw               = vid_oiw+(vid_oiw div 2);
vid_oisw               = vid_oiw-(vid_oiw div 4);
vid_oips               = 2*vid_oiw+vid_oisw;
vid_svld_m             = 7;
vid_rpls_m             = 8;
vid_camp_m             = 11;

ui_max_alarms          = 10;

ui_bottomsy            = vid_BW*4;
ui_h3bw                = vid_BW-vid_tBW;
ui_hwp                 = vid_panelw div 2;
ui_tabsy               = vid_panelw+ui_h3bw;
ui_builder_srs         = 127;
ui_ubtns               = 23;

ui_menu_map_zx0        = 76;
ui_menu_map_zy0        = 110;
ui_menu_map_zx1        = 381;
ui_menu_map_zy1        = 289;
ui_menu_map_ys         = 19;
ui_menu_map_x0         = ((ui_menu_map_zx0+ui_menu_map_zx1) div 2)- vid_panelw;
ui_menu_map_y0         = ((ui_menu_map_zy0+ui_menu_map_zy1) div 2)-(vid_panelw div 2);
ui_menu_map_rx0        = ui_menu_map_x0+16+vid_panelw;
ui_menu_map_rx1        = ui_menu_map_zx1-12;
ui_menu_map_y1         = ui_menu_map_y0+(ui_menu_map_ys*7);
ui_menu_map_tx0        = ui_menu_map_rx0+6;
ui_menu_map_tx1        = ui_menu_map_rx0+((ui_menu_map_rx1-ui_menu_map_rx0) div 2);

ui_menu_ssr_x0         = 76;
ui_menu_ssr_y0         = 326;
ui_menu_ssr_x1         = 381;
ui_menu_ssr_y1         = 523;
ui_menu_ssr_xs         = 102;
ui_menu_ssr_xhs        = ui_menu_ssr_xs div 2;
ui_menu_ssr_xhhs       = ui_menu_ssr_xhs div 2;
ui_menu_ssr_ys         = 18;
ui_menu_ssr_x3         = ui_menu_ssr_x1-10;
ui_menu_ssr_x2         = ui_menu_ssr_x3-127;
ui_menu_ssr_x4         = ui_menu_ssr_x0+ui_menu_ssr_xs;
ui_menu_ssr_x5         = ui_menu_ssr_x0+ui_menu_ssr_xs*2;
ui_menu_ssr_x6         = ui_menu_ssr_x5+ui_menu_ssr_xhs;
ui_menu_ssr_xt0        = ui_menu_ssr_x6-ui_menu_ssr_xhhs;
ui_menu_ssr_xt1        = ui_menu_ssr_x6+ui_menu_ssr_xhhs;
ui_menu_ssl_x0         = (ui_menu_ssr_x0+ui_menu_ssr_x1) div 2;

ui_menu_pls_x0         = 418;
ui_menu_pls_y0         = 110;
ui_menu_pls_x1         = 723;
ui_menu_pls_y1         = 253;
ui_menu_pls_ys         = 18;
ui_menu_pls_zh         = (MaxPlayers*ui_menu_pls_ys);
ui_menu_pls_xc         = (ui_menu_pls_x0+ui_menu_pls_x1) div 2;
ui_menu_pls_zy0        = ((ui_menu_pls_y0+ui_menu_pls_y1) div 2)-(ui_menu_pls_zh div 2);
ui_menu_pls_zy1        = ui_menu_pls_zy0+ui_menu_pls_zh;
ui_menu_pls_zxn        = ui_menu_pls_x0+16;   // name
ui_menu_pls_zxs        = ui_menu_pls_zxn+130; // status
ui_menu_pls_zxr        = ui_menu_pls_zxs+24;  // race
ui_menu_pls_zxt        = ui_menu_pls_zxr+64;  // team
ui_menu_pls_zxc        = ui_menu_pls_zxt+24;  // color box
ui_menu_pls_zxe        = ui_menu_pls_x1-16;
ui_menu_pls_zxnt       =  ui_menu_pls_zxn+6;
ui_menu_pls_zxst       = (ui_menu_pls_zxs+ui_menu_pls_zxr) div 2;
ui_menu_pls_zxrt       = (ui_menu_pls_zxr+ui_menu_pls_zxt) div 2;
ui_menu_pls_zxtt       = (ui_menu_pls_zxt+ui_menu_pls_zxc) div 2;
ui_menu_pls_zxc1       = ui_menu_pls_zxc+8;
ui_menu_pls_zxc2       = ui_menu_pls_zxe-8;

ui_menu_csm_x0         = 418;
ui_menu_csm_y0         = 290;
ui_menu_csm_x1         = 723;
ui_menu_csm_y1         = 522;
ui_menu_csm_xs         = 102;
ui_menu_csm_xhs        = ui_menu_csm_xs div 2;
ui_menu_csm_ys         = 18;
ui_menu_csm_2ys        = ui_menu_csm_ys*2;
//ui_menu_csm_yhs        = ui_menu_csm_ys div 2;
ui_menu_csm_ycs        = 10;
ui_menu_csm_xct        = ui_menu_csm_x0+2;
ui_menu_csm_xc         = (ui_menu_csm_x0+ui_menu_csm_x1) div 2;
ui_menu_csm_x2         = ui_menu_csm_x0+ui_menu_csm_xs;
ui_menu_csm_x3         = ui_menu_csm_x2+ui_menu_csm_xs;
ui_menu_csm_xt0        = ui_menu_csm_x0+8;
ui_menu_csm_xt1        = ui_menu_csm_x0+24;
ui_menu_csm_xt2        = ui_menu_csm_x1-8;

chat_type              : array[false..true] of char = ('|',' ');
chat_shlm_t            = fr_fps*5;

////////////////////////////////////////////////////////////////////////////////
//
//  SOUND
//

AUDIO_FREQUENCY        : INTEGER = MIX_DEFAULT_FREQUENCY; //22050;
AUDIO_FORMAT           : WORD    = AUDIO_S16;
AUDIO_CHANNELS         : INTEGER = 1;
AUDIO_CHUNKSIZE        : INTEGER = 1024;                  //4096;

////////////////////////////////////////////////////////////////////////////////
//
//  SAVE/LOAD/REPLAY
//

svld_size              = 231087;
rpl_size               = 1574;

rpl_none               = 0;
rpl_whead              = 1;
rpl_wunit              = 2;
rpl_rhead              = 3;
rpl_runit              = 4;
rpl_end                = 5;

SvRpLen                = 15;

////////////////////////////////////////////////////////////////////////////////
//
//  FOG
//

MFogM                  = 30;
fog_cw                 = 32;
fog_chw                = fog_cw div 2;
fog_cr                 = round(fog_chw*1.45);
fog_cxr                = fog_cr-fog_chw;
fog_vfwm               = (vid_maxw div fog_cw)+2;
fog_vfhm               = (vid_maxh div fog_cw)+2;

////////////////////////////////////////////////////////////////////////////////
//
//  TEXT
//

ta_left                = 0;
ta_middle              = 1;
ta_right               = 2;

font_w                 = 8;
font_iw                = font_w-1;

txt_line_h             = 5;
txt_line_h2            = 25-font_w;

////////////////////////////////////////////////////////////////////////////////
//
//  MENU
//

ms1_sett               = 0;
ms1_svld               = 1;
ms1_reps               = 2;

ms2_camp               = 0;
ms2_scir               = 1;
ms2_mult               = 2;

ms3_game               = 0;
ms3_vido               = 1;
ms3_sond               = 2;

MaxMissions            = 21;
CMPMaxSkills           = 6;

////////////////////////////////////////////////////////////////////////////////
//
//  BASE STRINGS
//

cfgfn                  : shortstring = 'cfg';
str_screenshot         : shortstring = 'MVSCR_';
str_loading            : shortstring = 'LOADING...'+#0;
str_f_grp              : shortstring = 'graphic\';
str_f_map              : shortstring = 'map\';
str_f_msc              : shortstring = 'music\';
str_f_snd              : shortstring = 'sound\';
str_f_svld             : shortstring = 'save\';
str_e_svld             : shortstring = '.mws';
str_f_rpls             : shortstring = 'replay\';
str_e_rpls             : shortstring = '.mwr';

race_dir               : array[1..r_cnt] of string = ('hell\'          ,'uac\'          );
race_units             : array[1..r_cnt] of string = ('hell\units\'    ,'uac\units\'    );
race_buildings         : array[1..r_cnt] of string = ('hell\buildings\','uac\buildings\');


////////////////////////////////////////////////////////////////////////////////
//
//  INPUT
//

k_chrtt                = fr_fps div 3;
k_kbstr                : set of Char = [#192..#255,'A'..'Z','a'..'z','0'..'9','"','[',']','{','}',' ','_',',','.','(',')','<','>','-','+','`','@','#','%','?',':','$'];
k_kbdig                : set of Char = ['0'..'9'];
k_kbaddr               : set of Char = ['0'..'9','.',':'];

////////////////////////////////////////////////////////////////////////////////
//
//  MAP THEME
//

LiquidAnim             = 4;
LiquidRs               = 4;

crater_ri              = 4;
crater_r               : array[1..crater_ri] of integer = (33,60,88,110);

theme_n                = 8;
theme_name             : array[0..theme_n-1] of shortstring = (#18+'TECH BASE'  ,
                                                               #20+'TECH BASE'  ,
                                                                   'PLANET'     ,
                                                                   'PLANET MOON',
                                                               #21+'CAVES'      ,
                                                               #19+'ICE CAVES'  ,
                                                               #16+'HELL'       ,
                                                               #17+'HELL CAVES' );

{$ELSE }

{$ENDIF}



