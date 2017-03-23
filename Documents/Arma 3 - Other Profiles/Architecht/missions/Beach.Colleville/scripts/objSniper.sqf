//creates a virtual sniper who attacks all enemies in range while its caller is alive
_self = _this select 0;
_maxSearchUnitDistance	= _this select 1;
while {alive _self} do {
	{
		if (alive _x && vehicle _x isKindOf "Man" && side _x != WEST) then {
			_x setDamage 1;

			_self say "gunshot";
			sleep 100 + random 3;
		};
	}forEach ((position _self) nearEntities ["Man", _maxSearchUnitDistance]);
	sleep 1 + random 3;
};