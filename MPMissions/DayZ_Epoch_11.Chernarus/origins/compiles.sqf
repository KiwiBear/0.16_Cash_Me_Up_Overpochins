if (!isDedicated) then {
	origins_checkNeededMaterial = compile preprocessFileLineNumbers "origins\origins_checkNeededMaterial.sqf";
	origins_removeActions = compile preprocessFileLineNumbers "origins\origins_removeActions.sqf";
};