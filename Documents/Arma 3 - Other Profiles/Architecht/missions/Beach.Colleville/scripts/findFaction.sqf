//This file parses the faction of the inputted entity and return a side
_faction = faction _this;
switch ((_faction splitString "_") select 0) do { 
	case "CIV" : {civilian}; 
	case "IND" : {resistance}; 
	case "BLU" : {west}; 
	case "OPF" : {east}; 
	case "LIB" : {
		switch ((_faction splitString "_") select 1) do {
			case "GER" : {west};
			case "WEHRMACHT" : {west};
			case "LUFTWAFFE" : {west};
			case "SOV" : {east};
			case "US" : {resistance};
			default {hint format ["Error identifying faction: %1.",_faction];};
		};
	};
	case "CUP" : {
		switch ((_faction splitString "_") select 1) do {
			case "B" : {
				switch ((_faction splitString "_") select 2) do {
					case "US" : {resistance};
					case "RNZN" : {resistance};
					default {hint format ["Error identifying faction: %1.",_faction];};
				};
			};
			default {hint format ["Error identifying faction: %1.",_faction];};
		};
	};
	default {hint format ["Error identifying faction: %1.",_faction];};
};