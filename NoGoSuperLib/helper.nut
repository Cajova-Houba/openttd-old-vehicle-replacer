/*
 * This file is part of SuperLib.Helper, which is an AI Library for OpenTTD
 * Copyright (C) 2008-2010  Leif Linse
 *
 * SuperLib.Helper is free software; you can redistribute it and/or modify it 
 * under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 2 of the License
 *
 * SuperLib.Helper is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with SuperLib.Helper; If not, see <http://www.gnu.org/licenses/> or
 * write to the Free Software Foundation, Inc., 51 Franklin Street, 
 * Fifth Floor, Boston, MA 02110-1301 USA.
 *
 */

class _SuperLib_Helper
{
	//////////////////////////////////////////////////////////////////////
	//                                                                  //
	//  String                                                          //
	//                                                                  //
	//////////////////////////////////////////////////////////////////////

	/*
	 * Works the same way as eg. Explode in php
	 */
	static function SplitString(delimiter, string, limit = null);

	//////////////////////////////////////////////////////////////////////
	//                                                                  //
	//  Date                                                            //
	//                                                                  //
	//////////////////////////////////////////////////////////////////////

	/*
	 * Returns a date string on the format <year>-<month>-<day>.
	 * Eg. 2010-01-10
	 */
	static function GetCurrentDateString();
	static function GetDateString(date);


	//////////////////////////////////////////////////////////////////////
	//                                                                  //
	//  Sign                                                            //
	//                                                                  //
	//////////////////////////////////////////////////////////////////////

	/* Note: An AI can only access its own signs. So you must use the
	 *   cheat dialog and switch to the AI company if you want to place
	 *   control signs such as "break_on" etc.
	 */

	/* Use this function instead of GSSign.BuildSign to never build more 
	 * than one sign per tile 
	 *
	 * Signs are only placed if the AI setting debug_signs is equal to 1
	 */
	static function SetSign(tile, message, force_build_sign = false);

	/* Puts a "break" sign on the given tile and waits until that sign
	 * gets removed by the player. Usefull for debuging.
	 * 
	 * Break points are only placed if AI setting debug_signs == 1 or
	 * if the sign "break_on" is present. In either case if the sign
	 * "no_break" is present then no break points will be placed.
	 * See the implementation if this text is not clear enough.
	 */
	static function BreakPoint(sign_tile, force_break_point = false);

	/* Checks if the AI has a sign with the given text */
	static function HasSign(text);

	/* Removes all signs that the AI has. */
	static function ClearAllSigns();

	//////////////////////////////////////////////////////////////////////
	//                                                                  //
	//  Cargo                                                           //
	//                                                                  //
	//////////////////////////////////////////////////////////////////////

	/* Get the cargo ID of the passenger cargo */
	static function GetPAXCargo();

	/* The GetTownProducedCargoList and GetTownAcceptedCargoList functions
	 * are climate aware, but are somewhat hardcoded as they make use of
	 * the cargo labels "MAIL", "GOOD" etc.
	 *
	 * If a NewGRF defines houses that produce eg. Coal without being an
	 * industry, then that will not be included by these functions.
	 */

	/* Get an GSList with cargo IDs as items.
	 * The list contains cargos that towns may produce
	 */
	static function GetTownProducedCargoList();

	/* Get an GSList with cargo IDs as items.
	 * The list contains cargos that towns may accept
	 */
	static function GetTownAcceptedCargoList();
	

	//////////////////////////////////////////////////////////////////////
	//                                                                  //
	//  List                                                            //
	//                                                                  //
	//////////////////////////////////////////////////////////////////////

	/* A valuator function that returns the item itself */
	static function ItemValuator(a) { return a; }

	// This function comes from AdmiralAI, version 22, written by Yexo
	/**
	 * Apply a valuator function to every item of an GSAbstractList.
	 * @param list The GSAbstractList to apply the valuator to.
	 * @param valuator The function to apply.
	 * @param others Extra parameters for the valuator function).
	 */
	static function Valuate(list, valuator, ...);

	// This function comes from AdmiralAI, version 22, written by Yexo
	/**
	 * Call a function with the arguments given.
	 * @param func The function to call.
	 * @param args An array with all arguments for func.
	 * @pre args.len() <= 8.
	 * @return The return value from the called function.
	 */
	static function CallFunction(func, args);

	/* Returns the sum of all values in an GSList */
	static function ListValueSum(ai_list);

	/* Returns a list where the values and items has been swapped */
	static function CopyListSwapValuesAndItems(old_list);

	static function GetListMinValue(ai_list);
	static function GetListMaxValue(ai_list);

	static function SquirrelListToAIList(squirrel_list);

	// Todo: Rename this function to eg. FindSquirrelArrayKey or similar
	static function ArrayFind(array, toFind);

	//////////////////////////////////////////////////////////////////////
	//                                                                  //
	//  Max, Min, Clamp etc.                                            //
	//                                                                  //
	//////////////////////////////////////////////////////////////////////

	static function Min(x1, x2);
	static function Max(x1, x2);
	static function Clamp(x, min, max);
	static function Abs(a);
}

// Note to self: Internal static vars are defined at the very bottom of this file

function _SuperLib_Helper::SplitString(delimiter, string, limit = null)
{
	local result = [];

	if(limit != null && limit <= 0) return result;

	local start = 0;
	local pos = string.find(delimiter, start);
	while(pos != null)
	{
		result.append(string.slice(start, pos));
		if(limit != null && result.len() >= limit) return result;

		start = pos + delimiter.len();
		pos = string.find(delimiter, start);
	}

	if(start != string.len())
		result.append(string.slice(start));

	return result;
}

function _SuperLib_Helper::GetCurrentDateString()
{
	local date = GSDate.GetCurrentDate();
	return _SuperLib_Helper.GetDateString(date);
}

function _SuperLib_Helper::GetDateString(date)
{
	local year = GSDate.GetYear(date);
	local month = GSDate.GetMonth(date);
   	local day = GSDate.GetDayOfMonth(date);

	return year + "-" + (month < 10? "0" + month : month) + "-" + (day < 10? "0" + day : day);
}

function _SuperLib_Helper::SetSign(tile, message, force_build_sign = false)
{
	if(!force_build_sign && GSController.GetSetting("debug_signs") != 1)
		return;

	local found = false;
	local sign_list = GSSignList();
	foreach(i, _ in sign_list)
	{
		if(GSSign.GetLocation(i) == tile)
		{
			if(found)
				GSSign.RemoveSign(i);
			else
			{
				if(message == "")
					GSSign.RemoveSign(i);
				else
					GSSign.SetName(i, message);
				found = true;
			}
		}
	}

	if(!found)
		GSSign.BuildSign(tile, message);
}

// Places a sign on tile sign_tile and waits until the sign gets removed
function _SuperLib_Helper::BreakPoint(sign_tile, force_break_point = false)
{
	if(force_break_point != false)
	{
		if(_SuperLib_Helper.HasSign("no_break"))
			return;

		if(!_SuperLib_Helper.HasSign("break_on"))
		{
			if(GSController.GetSetting("debug_signs") != 1)
				return;

		}
	}

	/* This message is so important, so it do not use the log system to not get
	 * suppressed by it.
	 */
	GSLog.Warning("Break point reached. -> Remove the \"break\" sign to continue.");
	_SuperLib_Helper.SetSign(sign_tile, ""); // remove any signs on the tile first
	local sign = GSSign.BuildSign(sign_tile, "break");
	while(GSSign.IsValidSign(sign)) { GSController.Sleep(1); }
}

function _SuperLib_Helper::HasSign(text)
{
	local sign_list = GSSignList();
	foreach(i, _ in sign_list)
	{
		if(GSSign.GetName(i) == text)
		{
			return true;
		}
	}
	return false;
}
function _SuperLib_Helper::ClearAllSigns()
{
	local sign_list = GSSignList();
	foreach(i, _ in sign_list)
	{
		GSSign.RemoveSign(i);
	}
}

/*function _SuperLib_Helper::MyClassValuate(list, valuator, valuator_class, ...)
{
   assert(typeof(list) == "instance");
   assert(typeof(valuator) == "function");
   
   local args = [valuator_class, null];
   
   for(local c = 0; c < vargc; c++) {
      args.append(vargv[c]);
   }

   foreach(item, _ in list) {
      args[1] = item;
      local value = valuator.acall(args);
      if (typeof(value) == "bool") {
         value = value ? 1 : 0;
      } else if (typeof(value) != "integer") {
         throw("Invalid return type from valuator");
      }
      list.SetValue(item, value);
   }
}*/

function _SuperLib_Helper::ListValueSum(ai_list)
{
	local sum = 0;
	foreach(item, value in ai_list)
	{
		sum += value
	}

	return sum;
}

function _SuperLib_Helper::CopyListSwapValuesAndItems(old_list)
{
	local new_list = GSList();
	foreach(i, _ in old_list)
	{
		local value = old_list.GetValue(i);
		new_list.AddItem(value, i);
	}

	return new_list;
}

function _SuperLib_Helper::GetListMinValue(ai_list)
{
	ai_list.Sort(GSAbstractList.SORT_BY_VALUE, true); // highest last
	return ai_list.GetValue(ai_list.Begin());
}

function _SuperLib_Helper::GetListMaxValue(ai_list)
{
	ai_list.Sort(GSAbstractList.SORT_BY_VALUE, false); // highest first
	return ai_list.GetValue(ai_list.Begin());
}

function _SuperLib_Helper::SquirrelListToAIList(squirrel_list)
{
	local ai_list = GSList();
	foreach(item in squirrel_list)
	{
		ai_list.AddItem(item, 0);
	}

	return ai_list;
}

// RETURN null if not found, else the key to the found value.
function _SuperLib_Helper::ArrayFind(array, toFind)
{
	
	foreach(key, val in array)
	{
		if(val == toFind)
		{
			return key;
		}
	}
	return null;
}


function _SuperLib_Helper::GetPAXCargo()
{
	if(!GSCargo.IsValidCargo(_SuperLib_Helper_private_pax_cargo))
	{
		local cargo_list = GSCargoList();
		cargo_list.Valuate(GSCargo.HasCargoClass, GSCargo.CC_PASSENGERS);
		cargo_list.KeepValue(1);
		cargo_list.Valuate(GSCargo.GetTownEffect);
		cargo_list.KeepValue(GSCargo.TE_PASSENGERS);

		if(cargo_list.Count() > 1) // Eg. ECS has both passengers and tourists
		{
			// Check which pax cargo that has biggest availability in the biggest town
			// This should rule out the tourists in most cases.
			local town_list = GSTownList();
			town_list.Valuate(GSTown.GetPopulation);
			town_list.KeepTop(1);

			local top_town = town_list.Begin();
			local town_tile = GSTown.GetLocation(top_town);
			if(GSTown.IsValidTown(top_town))
			{
				foreach(cargo_id, _ in cargo_list)
				{
					local radius = 5;
					local acceptance = GSTile.GetCargoAcceptance(town_tile, cargo_id, 1, 1, radius);

					cargo_list.SetValue(cargo_id, acceptance);
				}

				// Keep the most accepted pax cargo
				cargo_list.Sort(GSAbstractList.SORT_BY_VALUE, GSAbstractList.SORT_DESCENDING);
				cargo_list.KeepTop(1);
			}
		}

		if(!GSCargo.IsValidCargo(cargo_list.Begin()))
		{
			_SuperLib_Log.Error("PAX Cargo do not exist", _SuperLib_Log.LVL_INFO);
			return -1;
		}

		// Remember the cargo id of PAX
		_SuperLib_Helper_private_pax_cargo = cargo_list.Begin();
		return cargo_list.Begin();
	}

	return _SuperLib_Helper_private_pax_cargo;
}

function _SuperLib_Helper::GetTownProducedCargoList()
{
	if (_SuperLib_Helper_private_town_produced_cargo_list  == null)
	{
		_SuperLib_Helper_private_town_produced_cargo_list = GSList();
		_SuperLib_Helper_private_town_produced_cargo_list.AddItem(Helper.GetPAXCargo(), 0);
		local cargos = GSCargoList();
		foreach(cargo_id, _ in cargos)
		{
			local label = GSCargo.GetCargoLabel(cargo_id);
			if (label == "MAIL")
				_SuperLib_Helper_private_town_produced_cargo_list.AddItem(cargo_id, 0);
		}
	}

	return _SuperLib_Helper_private_town_produced_cargo_list;
}

function _SuperLib_Helper::GetTownAcceptedCargoList()
{
	if (_SuperLib_Helper_private_town_accepted_cargo_list  == null)
	{
		_SuperLib_Helper_private_town_accepted_cargo_list = GSList();
		_SuperLib_Helper_private_town_accepted_cargo_list.AddItem(Helper.GetPAXCargo(), 0);

		local cargos = GSCargoList();
		foreach(cargo_id, _ in cargos)
		{
			local label = GSCargo.GetCargoLabel(cargo_id);
			if (label == "GOOD")
				_SuperLib_Helper_private_town_accepted_cargo_list.AddItem(cargo_id, 0);
			if (label == "FOOD")
				_SuperLib_Helper_private_town_accepted_cargo_list.AddItem(cargo_id, 0);
			if (label == "MAIL")
				_SuperLib_Helper_private_town_accepted_cargo_list.AddItem(cargo_id, 0);
			if (label == "FZDR") // Fizzy drinks
				_SuperLib_Helper_private_town_accepted_cargo_list.AddItem(cargo_id, 0);
			if (label == "SWET") // Sweets
				_SuperLib_Helper_private_town_accepted_cargo_list.AddItem(cargo_id, 0);
		}
	}

	return _SuperLib_Helper_private_town_accepted_cargo_list;
}

// This function comes from AdmiralAI, version 22, written by Yexo
function _SuperLib_Helper::CallFunction(func, args)
{
	switch (args.len()) {
		case 0: return func();
		case 1: return func(args[0]);
		case 2: return func(args[0], args[1]);
		case 3: return func(args[0], args[1], args[2]);
		case 4: return func(args[0], args[1], args[2], args[3]);
		case 5: return func(args[0], args[1], args[2], args[3], args[4]);
		case 6: return func(args[0], args[1], args[2], args[3], args[4], args[5]);
		case 7: return func(args[0], args[1], args[2], args[3], args[4], args[5], args[6]);
		case 8: return func(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7]);
		default: throw "Too many arguments to CallFunction";
	}
}

// This function comes from AdmiralAI, version 22, written by Yexo
function _SuperLib_Helper::Valuate(list, valuator, ...)
{
	assert(typeof(list) == "instance");
	assert(typeof(valuator) == "function");

	local args = [null];

	for(local c = 0; c < vargc; c++) {
		args.append(vargv[c]);
	}

	foreach(item, _ in list) {
		args[0] = item;
		local value = _SuperLib_Helper.CallFunction(valuator, args);
		if (typeof(value) == "bool") {
			value = value ? 1 : 0;
		} else if (typeof(value) != "integer") {
			throw("Invalid return type from valuator");
		}
		list.SetValue(item, value);
	}
}

function _SuperLib_Helper::Min(x1, x2)
{
	return x1 < x2? x1 : x2;
}

function _SuperLib_Helper::Max(x1, x2)
{
	return x1 > x2? x1 : x2;
}

function _SuperLib_Helper::Clamp(x, min, max)
{
	x = _SuperLib_Helper.Max(x, min);
	x = _SuperLib_Helper.Min(x, max);
	return x;
}

function _SuperLib_Helper::Abs(a)
{
	return a >= 0? a : -a;
}

// Private static variable - don't touch (read or write) from the outside.
_SuperLib_Helper_private_pax_cargo <- -1;

_SuperLib_Helper_private_town_accepted_cargo_list <- null;
_SuperLib_Helper_private_town_produced_cargo_list <- null;

