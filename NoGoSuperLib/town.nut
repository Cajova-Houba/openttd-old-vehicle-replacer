/*
 * This file is part of SuperLib, which is an AI Library for OpenTTD
 * Copyright (C) 2011  Leif Linse
 *
 * SuperLib is free software; you can redistribute it and/or modify it 
 * under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 2 of the License
 *
 * SuperLib is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with SuperLib; If not, see <http://www.gnu.org/licenses/> or
 * write to the Free Software Foundation, Inc., 51 Franklin Street, 
 * Fifth Floor, Boston, MA 02110-1301 USA.
 *
 */

class _SuperLib_Town
{
	static function TownRatingAllowStationBuilding(town_id);
}

function _SuperLib_Town::TownRatingAllowStationBuilding(town_id)
{
	local rating = GSTown.GetRating(town_id, GSCompany.COMPANY_SELF);
   	return rating == GSTown.TOWN_RATING_NONE || rating > GSTown.TOWN_RATING_VERY_POOR;
}
