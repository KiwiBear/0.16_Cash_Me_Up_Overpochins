private ["_isOk","_vehicle","_part","_hitpoint","_type","_selection","_array","_started","_finished","_animState","_isMedic","_num_removed","_damage","_dis","_sfx","_allFixed","_id","_hasToolbox","_section","_nameType","_namePart","_hitpoints","_mt","_nameClass1","_st","_cfg","_tc"];

if(DZE_ActionInProgress) exitWith { cutText [(localize "str_epoch_player_92") , "PLAIN DOWN"]; };
DZE_ActionInProgress = true;

_id = _this select 2;
_array =    _this select 3;

_vehicle =  _array select 0;
_part =     _array select 1;
_hitpoint = _array select 2;
_type = typeOf _vehicle; 

//
_hasToolbox =   "ItemToolbox" in items player;
_section = _part in magazines player;

// moving this here because we need to know which part needed if we don't have it
_nameType =         getText(configFile >> "cfgVehicles" >> _type >> "displayName");
_namePart =         getText(configFile >> "cfgMagazines" >> _part >> "displayName");
_isOk = true;
s_player_repair_crtl = 1;

if (_section && _hasToolbox) then {

    player playActionNow "Medic";
    _sfx = "repair";
    _dis=0;
    [player,_sfx,0,false,_dis] call dayz_zombieSpeak;  
    [player,_dis,true,(getPosATL player)] spawn player_alertZombies;
    
    r_interrupt = false;
    _animState = animationState player;
    r_doLoop = true;
    _started = false;
    _finished = false;
    
    while {r_doLoop} do {
        _animState = animationState player;
        _isMedic = ["medic",_animState] call fnc_inString;
        if (_isMedic) then {
            _started = true;
        };
        if (_started && !_isMedic) then {
            r_doLoop = false;
            _finished = true;
        };
        if (r_interrupt) then {
            r_doLoop = false;
        };
        sleep 0.1;
    };
    r_doLoop = false;

    if (_finished) then {
        if (_part == "PartGeneric") then {
            player removeMagazine _part;
            
            _cfg = configFile >> "CfgVehicles" >> typeof _vehicle >> "AnimationSources";
            _tc = count _cfg;
            for "_mti" from 0 to _tc-1 do {
                _mt = (_cfg select _mti);
                _nameClass1 = configName(_mt);
                _st = getText(_mt >> "source");
                if (_st==_hitpoint) then {  _selection = _st; };
            };
            PVDZE_veh_SFix = [_vehicle,_selection,0];
            publicVariable "PVDZE_veh_SFix";
            if (local _vehicle) then {
                PVDZE_veh_SFix call object_setFixServer;
            };
            
            player playActionNow "Medic";
            sleep 1;
            
            _dis=20;
            _sfx = "repair";
            [player,_sfx,0,false,_dis] call dayz_zombieSpeak;  
            [player,_dis,true,(getPosATL player)] spawn player_alertZombies;
            sleep 5;
            _vehicle setvelocity [0,0,1];
            
            //Success!
            cutText [format[(localize "str_epoch_player_166"),_namePart,_nameType], "PLAIN DOWN"];          
        } else {
            _damage = [_vehicle,_hitpoint] call object_getHit;
            _vehicle removeAction _id;
        
            //dont waste loot on undamaged parts
            if (_damage > 0) then {
            
                // ensure part was removed
                _num_removed = ([player,_part] call BIS_fnc_invRemove);

                if(_num_removed == 1) then {

                    //Fix the part
                    _selection = getText(configFile >> "cfgVehicles" >> _type >> "HitPoints" >> _hitpoint >> "name");
            
                    //vehicle is owned by whoever is in it, so we have to have each client try && fix it
                    PVDZE_veh_SFix = [_vehicle,_selection,0];
                    publicVariable "PVDZE_veh_SFix";
                    
                    if (local _vehicle) then {
                        PVDZE_veh_SFix call object_setFixServer;
                    };

                    _vehicle setvelocity [0,0,1];

                    //Success!
                    cutText [format[(localize "str_epoch_player_166"),_namePart,_nameType], "PLAIN DOWN"];

                };
            
            };
        };
    } else {
        r_interrupt = false;
        if (vehicle player == player) then {
            [objNull, player, rSwitchMove,""] call RE;
            player playActionNow "stop";
        };
        cutText [(localize "str_epoch_player_93"), "PLAIN DOWN"];
    };
            
} else {
    cutText [format[(localize "str_epoch_player_167"),_namePart], "PLAIN DOWN"];
};

{dayz_myCursorTarget removeAction _x} count s_player_repairActions;s_player_repairActions = [];
dayz_myCursorTarget = objNull;

//check if repaired fully
_hitpoints = _vehicle call vehicle_getHitpoints;
_allFixed = true;
{
    _damage = [_vehicle,_x] call object_getHit;
    if (_damage > 0) exitWith {
        _allFixed = false;
    };
} count _hitpoints;

//update if repaired
if (_allFixed) then {
    _vehicle setDamage 0;
    //["PVDZE_veh_Update",[_vehicle,"repair"]] call callRpcProcedure;
    PVDZE_veh_SFix = [_vehicle,_selection,0];
    publicVariable "PVDZE_veh_SFix";
    if (local _vehicle) then {
        PVDZE_veh_SFix call object_setFixServer;
    };
};

s_player_repair_crtl = -1;

DZE_ActionInProgress = false;