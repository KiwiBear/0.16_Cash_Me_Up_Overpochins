//select 0 = excavator
//select 1 = player
//select 2 = addAction ID
//select 3 = Origins Building
_excavator = _this select 0;
_nearestBuilding = _this select 3;
_objectID = _nearestBuilding getVariable["ObjectID","0"];
_objectUID = _nearestBuilding getVariable["ObjectUID","0"];
_position = getPos _nearestBuilding;
_func_databaseremove = {
    //titleText [format["Demolishing %1...",typeOf(_nearestBuilding)],"plain"];
    []execVM "origins\bucketOut.sqf";
    sleep 5;
    []execVM "origins\bucketIn.sqf";

    sleep 5;
    _nil = [objNull, player, rSAY, "z_demolishwall_0"] call RE;    
    
    PVDZE_obj_Delete = [_objectID,_objectUID,player];
    publicVariableServer "PVDZE_obj_Delete";
    if (isServer) then {
        PVDZE_obj_Delete call server_deleteObj;
    };
    titleText [format["%1 Demolished!",typeOf(_nearestBuilding)],"plain"];titleFadeOut 3;
    deletevehicle _nearestBuilding;
    _veh = createVehicle ["Land_Misc_Garb_Heap_EP1",_position, [], 0, "CAN_COLLIDE"];
    
    breakout "exit";
};

call _func_databaseremove;