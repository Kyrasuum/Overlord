// Smarter tanks v.1.6

class CfgPatches
{
	class Smarter_tanks
	{
		units[] = {};
		weapons[] = {};
		requiredVersion = 1.0;
		requiredAddons[] = {"A3_Data_F","A3_Weapons_F","A3_Characters_F","Extended_EventHandlers"};

	};
};

class Extended_PostInit_EventHandlers 
	{
		myInit = "[] execVM ""\alarm\smart.sqf""";
	};

class CfgAISkill 
{
	spotDistance[] = {0, 0.2, 1, 1};
};

//Max range of fire and hit proba at the max
#define VTS_sniperriflemaxdist 1200
#define VTS_sniperriflemaxdistproba 0.005

#define VTS_longriflemaxdist 1000
#define VTS_longriflemaxdistproba 0.0015

#define VTS_riflemaxdist 800
#define VTS_riflemaxdistproba 0.001

#define VTS_shortriflemaxdist 600
#define VTS_shortriflemaxdistproba 0.0005

#define VTS_lmgmaxdist 900
#define VTS_lmgmaxdistproba 0.001



class cfgweapons 
{
	//Base not used but still there in case other of addons using it
	class Default;
	class RifleCore;
	class Rifle;
	class Rifle_Base_F:Rifle
	{
		maxrange = VTS_riflemaxdist;		
		maxrangeprobab = VTS_riflemaxdistproba;
	};
	
	class Rifle_Long_Base_F:Rifle_Base_F
	{
		maxrange = VTS_longriflemaxdist;		
		maxrangeprobab = VTS_longriflemaxdistproba;		
	};

	
	//EBR
	class EBR_base_F: Rifle_Long_Base_F
	{
		maxrange = VTS_longriflemaxdist;		
		maxrangeprobab = VTS_longriflemaxdistproba;
		class Single;
		
	};	

	class srifle_EBR_F: EBR_base_F
	{
		maxrange = VTS_longriflemaxdist;		
		maxrangeprobab = VTS_longriflemaxdistproba;
		class Single: Single
		{
			maxrange = VTS_longriflemaxdist;
			maxrangeprobab = VTS_longriflemaxdistproba;
		};
	};		
	
	//GM6
	class GM6_base_F: Rifle_Long_Base_F
	{
		maxrange = VTS_sniperriflemaxdist;		
		maxrangeprobab = VTS_sniperriflemaxdistproba;
		class Single;
	};	
	class srifle_GM6_F: GM6_base_F
	{
		maxrange = VTS_sniperriflemaxdist;		
		maxrangeprobab = VTS_sniperriflemaxdistproba;
		class Single: Single
		{
			maxrange = VTS_sniperriflemaxdist;
			maxrangeprobab = VTS_sniperriflemaxdistproba;
		};
	};	
	
	//LRR
	class LRR_base_F: Rifle_Long_Base_F
	{
		maxrange = VTS_sniperriflemaxdist;		
		maxrangeprobab = VTS_sniperriflemaxdistproba;
		class Single;
	};	
	class srifle_LRR_F: LRR_base_F
	{
		maxrange = VTS_sniperriflemaxdist;		
		maxrangeprobab = VTS_sniperriflemaxdistproba;
		class Single: Single
		{
			maxrange = VTS_sniperriflemaxdist;
			maxrangeprobab = VTS_sniperriflemaxdistproba;
		};
	};		
	
	//MK200
	class LMG_Mk200_F: Rifle_Long_Base_F
	{
		maxrange = VTS_lmgmaxdist;	
		maxrangeprobab = VTS_lmgmaxdistproba;	
		class close;
		class medium: close  
		{
			maxrange = VTS_lmgmaxdist;
			maxrangeprobab = VTS_lmgmaxdistproba;
		};
	};

	//Zafir
	class LMG_Zafir_F: Rifle_Long_Base_F
	{
		maxrange = VTS_lmgmaxdist;	
		maxrangeprobab = VTS_lmgmaxdistproba;		
		class close;
		class medium: close  
		{
			maxrange = VTS_lmgmaxdist;
			maxrangeprobab = VTS_lmgmaxdistproba;
		};
	};
	
	//KATIBA
	class arifle_Katiba_Base_F: Rifle_Base_F
	{
		maxrange = VTS_riflemaxdist;		
		maxrangeprobab = VTS_riflemaxdistproba;		
		class Single;
	};
	class arifle_Katiba_F: arifle_Katiba_Base_F 
	{
		maxrange = VTS_riflemaxdist;		
		maxrangeprobab = VTS_riflemaxdistproba;	
		class Single: Single
		{
			maxrange = VTS_riflemaxdist;
			maxrangeprobab = VTS_riflemaxdistproba;
		};
		
	};
	class  arifle_Katiba_C_F: arifle_Katiba_Base_F 
	{
		maxrange = VTS_riflemaxdist;		
		maxrangeprobab = VTS_riflemaxdistproba;
		class Single: Single
		{
			maxrange = VTS_riflemaxdist;
			maxrangeprobab = VTS_riflemaxdistproba;
		};
	};
	class arifle_Katiba_GL_F: arifle_Katiba_Base_F 
	{
		maxrange = VTS_riflemaxdist;		
		maxrangeprobab = VTS_riflemaxdistproba;
		class Single: Single
		{
			maxrange = VTS_riflemaxdist;
			maxrangeprobab = VTS_riflemaxdistproba;
		};
	};
	
	//MX
	
	class arifle_MX_Base_F: Rifle_Base_F
	{
		maxrange = VTS_riflemaxdist;		
		maxrangeprobab = VTS_riflemaxdistproba;		
		class single;
	};
	
	class arifle_MXC_F: arifle_MX_Base_F
	{
		maxrange = VTS_riflemaxdist;		
		maxrangeprobab = VTS_riflemaxdistproba;
		class Single: Single
		{
			maxrange = VTS_riflemaxdist;
			maxrangeprobab = VTS_riflemaxdistproba;
		};
	};
	class arifle_MX_F: arifle_MX_Base_F
	{
		maxrange = VTS_riflemaxdist;		
		maxrangeprobab = VTS_riflemaxdistproba;
		class Single: Single
		{
			maxrange = VTS_riflemaxdist;
			maxrangeprobab = VTS_riflemaxdistproba;
		};
	};	
	class arifle_MX_GL_F: arifle_MX_Base_F
	{
		maxrange = VTS_riflemaxdist;		
		maxrangeprobab = VTS_riflemaxdistproba;
		class Single: Single
		{
			maxrange = VTS_riflemaxdist;
			maxrangeprobab = VTS_riflemaxdistproba;
		};
	};
	
	class arifle_MX_SW_F: arifle_MX_Base_F
	{
		maxrange = VTS_lmgmaxdist;		
		maxrangeprobab = VTS_lmgmaxdistproba;
		class Single : Single
		{
			maxrange = VTS_lmgmaxdist;
			maxrangeprobab = VTS_lmgmaxdistproba;
		};		
	};
	
	class arifle_MXM_F: arifle_MX_Base_F
	{
		maxrange = VTS_longriflemaxdist;		
		maxrangeprobab = VTS_longriflemaxdistproba;

		class Single : Single
		{
			maxrange = VTS_longriflemaxdist;
			maxrangeprobab = VTS_longriflemaxdistproba;
		};
	};
	
	
	//SDAR
	class SDAR_base_F: Rifle_Base_F   
	{
		maxrange = VTS_shortriflemaxdist;		
		maxrangeprobab = VTS_shortriflemaxdistproba;
		class Single;
	};	
	class arifle_SDAR_F: SDAR_base_F   
	{
		maxrange = VTS_shortriflemaxdist;		
		maxrangeprobab = VTS_shortriflemaxdistproba;
		class Single: Single
		{
			maxrange = VTS_shortriflemaxdist;
			maxrangeprobab = VTS_shortriflemaxdistproba;
		};
	};

	//Tavor
	class Tavor_base_F: Rifle_Base_F
	{
		maxrange = VTS_riflemaxdist;		
		maxrangeprobab = VTS_riflemaxdistproba;
		class Single;
	};
	class arifle_TRG21_F: Tavor_base_F
	{
		maxrange = VTS_riflemaxdist;		
		maxrangeprobab = VTS_riflemaxdistproba;
		class Single: Single
		{
			maxrange = VTS_riflemaxdist;
			maxrangeprobab = VTS_riflemaxdistproba;
		};	
	};
	class arifle_TRG20_F: Tavor_base_F
	{
		maxrange = VTS_riflemaxdist;		
		maxrangeprobab = VTS_riflemaxdistproba;
		class Single: Single
		{
			maxrange = VTS_riflemaxdist;
			maxrangeprobab = VTS_riflemaxdistproba;
		};	
	};
	
	//MK20
	class mk20_base_F: Rifle_Base_F
	{
		maxrange = VTS_riflemaxdist;		
		maxrangeprobab = VTS_riflemaxdistproba;
		class Single;
	};
	class arifle_Mk20_F: mk20_base_F
	{
		maxrange = VTS_riflemaxdist;		
		maxrangeprobab = VTS_riflemaxdistproba;
		class Single: Single
		{
			maxrange = VTS_riflemaxdist;
			maxrangeprobab = VTS_riflemaxdistproba;
		};	
	};	
	class arifle_Mk20C_F: mk20_base_F
	{
		maxrange = VTS_riflemaxdist;		
		maxrangeprobab = VTS_riflemaxdistproba;
		class Single: Single
		{
			maxrange = VTS_riflemaxdist;
			maxrangeprobab = VTS_riflemaxdistproba;
		};	
	};	
	class arifle_Mk20_GL_F: mk20_base_F
	{
		maxrange = VTS_riflemaxdist;		
		maxrangeprobab = VTS_riflemaxdistproba;
		class Single: Single
		{
			maxrange = VTS_riflemaxdist;
			maxrangeprobab = VTS_riflemaxdistproba;
		};	
	};	
	
	//SMG1
	class SMG_01_Base: Rifle_Base_F
	{
		maxrange = VTS_shortriflemaxdist;		
		maxrangeprobab = VTS_shortriflemaxdistproba;
		class Single;
	};
	class SMG_01_F: SMG_01_Base
	{
		maxrange = VTS_shortriflemaxdist;		
		maxrangeprobab = VTS_shortriflemaxdistproba;
		class Single: Single
		{
			maxrange = VTS_shortriflemaxdist;
			maxrangeprobab = VTS_shortriflemaxdistproba;
		};	
	};	
	
	//SMG2
	class SMG_02_base_F: Rifle_Base_F
	{
		maxrange = VTS_shortriflemaxdist;		
		maxrangeprobab = VTS_shortriflemaxdistproba;
		class Single;
	};
	class SMG_02_F: SMG_02_base_F
	{
		maxrange = VTS_shortriflemaxdist;		
		maxrangeprobab = VTS_shortriflemaxdistproba;
		class Single: Single
		{
			maxrange = VTS_shortriflemaxdist;
			maxrangeprobab = VTS_shortriflemaxdistproba;
		};	
	};	

	//PDW2000
	class pdw2000_base_F: Rifle_Base_F
	{
		maxrange = VTS_shortriflemaxdist;		
		maxrangeprobab = VTS_shortriflemaxdistproba;
		class Single;
	};
	class hgun_PDW2000_F: pdw2000_base_F
	{
		maxrange = VTS_shortriflemaxdist;		
		maxrangeprobab = VTS_shortriflemaxdistproba;
		class Single: Single
		{
			maxrange = VTS_shortriflemaxdist;
			maxrangeprobab = VTS_shortriflemaxdistproba;
		};	
	};		

};
	