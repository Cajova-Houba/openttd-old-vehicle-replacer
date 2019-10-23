
class ReplacerScript extends GSInfo {
	function GetAuthor()		{ return "Cajova-Houba"; }
	function GetName()			{ return "Old Vehicle Replacer"; }
	function GetDescription() 	{ return "Select this as game script and see for yourself"; }
	function GetVersion()		{ return 1; }
	function GetDate()			{ return "2019-10-16"; }
	function CreateInstance()	{ return "ReplacerScript"; }
	function GetShortName()		{ return "OVR_"; }
	function GetAPIVersion()	{ return "1.9"; }
	function GetUrl()			{ return ""; }

	function GetSettings() {
		AddSetting({name = "log_level", description = "Debug: Log level (higher = print more)", easy_value = 3, medium_value = 3, hard_value = 3, custom_value = 3, flags = CONFIG_INGAME, min_value = 1, max_value = 3});
		AddSetting({name = "debug_signs", description = "Debug: Build signs", easy_value = 1, medium_value = 1, hard_value = 1, custom_value = 1, flags = CONFIG_BOOLEAN | CONFIG_INGAME});
	}
}

RegisterGS(ReplacerScript());
