/*
 * Currently only sends old vehicles to depot.
 */

require("NoGoSuperLib/main.nut");

// globals
Log <- SuperLib.Log;
Helper <- SuperLib.Helper;
Tile <- SuperLib.Tile;
Result <- SuperLib.Result;

// class declaration
class TestGame extends GSController
{
	_lastVehicleCount = 0;
	_lastDepotCount = 0;
	
	// replace vehicle 100 days before it gets old
	_maxVehicleAgeLeft = 100;
}


/*
 * Implementation
 */
 
function TestGame::Init() {
	// any init goes here
}
 
function TestGame::Start()
{
	// Any GameScript init code goes here
	this.Init();

	Log.Info("My Game Script setup done", Log.LVL_INFO);

	// Wait for the game to start
	this.Sleep(1);

	// Only when the game has started, the human company exist
	local company_mode = GSCompanyMode(0);

	Log.Info("The coolest script ever starts now", Log.LVL_INFO);

	this.DoStuff()
	
	// while (true) {
		// this.HandleEvents();
		// this.RunTutorial();
		// this.Sleep(10);
	// }
}

function TestGame::HandleEvents()
{
}

function TestGame::PrintVehicleStatistics()
{
	Log.Info("You have "+this._lastVehicleCount+" vehicles.");
	Log.Info("You have "+this._lastDepotCount+" depots.");
}

/*
 * Returns the first old vehicle found or null if no vehicle is old.
 * param vehicles List to search old vehicles in.
 *
 * return Number of vehicles sent to depo.
 */
function TestGame::SendOldVehiclesToDepot(vehicles)
{
	local vehicleId = vehicles.Begin();
	local maxAgeLeft = this._maxVehicleAgeLeft;
	local sentToDepo = 0;
	while(!vehicles.IsEnd()) 
	{
		local ageLeft = GSVehicle.GetAgeLeft(vehicleId);
		
		// vehicle is old and is not on its way to the depot
		if (ageLeft < maxAgeLeft 
				&& !GSVehicle.IsInDepot(vehicleId) 
				&& GSOrder.IsCurrentOrderPartOfOrderList(vehicleId)) 
		{
			Log.Info("Old vehicle "+vehicleId+" is not in  depot.");
			Log.Info("Sending old vehicle "+vehicleId+" to depot.");
			GSVehicle.SendVehicleToDepot(vehicleId);
			sentToDepo++;
		}
		
		vehicleId = vehicles.Next();
	}
	
	return sentToDepo;
}


/*
 * Replaces all old vehilces in depot.
 * param vehicles List of all vehicles used to find old vehicles in depots.
 */
function TestGame::ReplaceOldVehicles(vehicles) 
{
	local vehicleId = vehicles.Begin();
	local maxAgeLeft = this._maxVehicleAgeLeft;
	local oldVehiclesReplaced = 0;
	
	while(!vehicles.IsEnd()) 
	{
		local ageLeft = GSVehicle.GetAgeLeft(vehicleId);
		if (ageLeft < maxAgeLeft 
			&& GSVehicle.IsStoppedInDepot(vehicleId)) 
		{
			local res = this.ReplaceOldVehicle(vehicleId)
			oldVehiclesReplaced = oldVehiclesReplaced + res;
		}
			
		vehicleId = vehicles.Next();
	}
	
	return oldVehiclesReplaced;
}

/*
 * Replaces one vehicle which is in depot.
 * param vehicleId Id of vehicle to be replaced.
 * return 1 if the vehicle was replaced, 0 otherwise.
 */
function TestGame::ReplaceOldVehicle(vehicleId) 
{
	Log.Info("Vehicle "+vehicleId+" is in depot, replacing it.");
	local newVehicleId;
	try 
	{
		// clone vehicle
		newVehicleId = GSVehicle.CloneVehicle(GSVehicle.GetLocation(vehicleId), vehicleId, false);
		
		// start it
		GSVehicle.StartStopVehicle(newVehicleId);
		Log.Info("Old vehicle "+vehicleId+" clonned with new id "+newVehicleId);
		
		// sell old vehicle
		GSVehicle.SellVehicle(vehicleId);
		Log.Info("Old vehicle "+vehicleId+" sold.");
		
		return 1;
	} catch (exception)
	{
		Log.Error("Error while clonning vehicle "+vehicleId+": "+exception);
	}
	
	return 0;
}


function TestGame::DoStuff()
{
	
	// first print
	this.PrintVehicleStatistics();
	
	while (true)
	{
		local vehicles = GSVehicleList();
		local depots = GSDepotList(GSTile.TRANSPORT_ROAD);
		local sentToDepo = this.SendOldVehiclesToDepot(vehicles);
		
		// print current info about vehicles and depots
		if ((this._lastVehicleCount != vehicles.Count())
			|| (this._lastDepotCount != depots.Count()))
		{
			this._lastVehicleCount = vehicles.Count();
			this._lastDepotCount = depots.Count();
			this.PrintVehicleStatistics();
		}
		
		// print # of how many vehicles were sent to depo
		if (sentToDepo != 0) {
			Log.Info(sentToDepo + " old vehicles sent to depo.");
		}
		
		// replace old vehicles
		local vehiclesReplaced = this.ReplaceOldVehicles(vehicles);
		if (vehiclesReplaced != 0) {
			Log.Info(sentToDepo + " old vehicles replaced.");
		}
		
		this.HandleEvents();
		this.Sleep(10);
	}
}

