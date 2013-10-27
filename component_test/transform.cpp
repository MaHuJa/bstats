#include "stdafx.h"
#include "transform.h"

#include "dbthread.h"	// To get escape function

std::vector<std::string> separate (std::string);
long int sessionid = 0;
typedef std::vector<std::string> paramlist;

std::string transform (std::string in, dbthread& thr) {
	std::string out;
	paramlist p = separate(in);
	if (!p.size()) {
		thr.senderror("No parts received",in);
		throw std::runtime_error("Input processing failed");
	}
	for (auto it = begin(p); it!= end(p); it++) {
		*it = thr.escapestring(*it);
	}
	std::ostringstream s;
	// TODO allow for newer versions
	if (p[0]=="newsession1") {
		s << "SELECT newsession1(" << p[1] << ");";
	} else {
		s << "PERFORM";
	}
}

/*
class bs_transform;
class bs_transform {
std::map<std::string,bs_transform*> transforms;
public:
	typedef std::string string;
	typedef std::vector<string> paramlist;
	bs_transform(string name) {
		transforms[name]=this;
	}
	virtual string perform (paramlist) = 0;
};

class bs_newsession : bs_transform {
public:
	bs_newsession() : bs_transform("newsession") {};
	string perform (paramlist p) override {
		std::ostringstream out;
		out << "SELECT bs_newsession(" << "";


		return out.str();
	}
} BS_newsession;
*/

/*
bstats_newsession ("Just testing", 1, 15)	-- (missionname, api_ver, sessionid)
bstats_newplayer (1, "west", 0, "Testdata - StartingPlayer1")	-- (playerid, side, timestamp, playername)
bstats_newplayer (2, "east", 0, "Testdata - StartingPlayer2")
bstats_newplayer (3, "west", 40, "Testdata - JIPplayer 1")
bstats_death (3, 63, -1, "[123,123,123]") 	-- (killeduid, timestamp, score, killedpos)
bstats_suicide (3, 83, -1, "[123,142,124]")	-- (killeduid, timestamp, score, killedpos)
bstats_accrash (3,113,1,-3, "[123,123,123]")	--(killeduid, timestamp, passengers, score, killedpos)
bstats_player_left (3, 120)	-- (playerid, timestamp)
bstats_wpninfo (1, "m16a4", 113, 110, 0, 0, 0, 0, 0, 0)
bstats_vehkill("UAZ", 1, 123, "M136", 5, 100, "[1234,1234,15]", "[1234,1334,15]")
	-- (vehicletype, killeruid, timestamp, weapon, score, distance, killerpos, targetpos)
bstats_killassist (3,123,1) -- (uid, timestamp, score)
bstats_kill (2, 1, 123, "M136", 100, 1, "[1234,1234,15]", "[1234,1334,15]")
	-- (killeduid, killeruid, timestamp, weapon, score, distance, killedpos, killerpos)
bstats_wpninfo (1, "M136", 126, 13, 1, 1, 0, 0, 0, 0)
bstats_capture(1,137.99, 50, "King's Hill")
	-- (playerid, timestamp, points, tag)  -- todo: add position
bstats_wpninfo (1, "m16a4", 135, 9, 4, 0, 0, 0, 1, 0)
bstats_newplayer (4, "east", 138, "Testdata - Griefer")
bstats_wpninfo (1, "m16a4", 145, 10, 8, 1, 1, 1, 1, 1)
bstats_tk( 2, 3, 152, "AK74", -5, 30, "[314,215,20]", "[344,215,20]")
	-- (killeduid, killeruid, timestamp, weapon, score, distance, killedpos, killerpos)
bstats_roadkill  (3, 1, 154, "HMMWV", 1, "[344,215,20]")
	-- (killeduid, killeruid, timestamp, vehicle, score, killedpos) -- will ignore a killerpos if given
bstats_civdmg (nil, 3, 155, "HMMWV", -2, 2, "[346,216,20]")
	-- (killeduid, killeruid, timestamp, weapon, score, distance, killedpos, killerpos)
	-- use nil for killeduid when the civilian was AI
bstats_civcas (nil,4, 169, "HandGrenade", -5, 60, "[346,216,20]", "[346,276,20]")
	-- (killeduid, killeruid, timestamp, weapon, score, distance, killedpos, killerpos)
bstats_friendlydmg (2,4, 169, "HandGrenade", -1, 70, "[346,206,20]", "[346,276,20]")
	-- (killeduid, killeruid, timestamp, weapon, score, distance, killedpos, killerpos)
bstats_trans(1,198,"HMMWV",1230,30,"[123,234,12]")
	-- uid, time, vehicle, distance, score, position
bstats_capture(1,260,20,"Hill fort")
	-- format ["bstats_capture (%1, %2, %3, %4)", _uid, time, _score, (str _obj)]
bstats_endsession (300, "west")		-- duration, winner
*/