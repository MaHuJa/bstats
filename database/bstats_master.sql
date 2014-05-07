--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.13
-- Dumped by pg_dump version 9.3.1
-- Started on 2014-05-07 12:57:33

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 2170 (class 1262 OID 16404)
-- Name: bstats_master; Type: DATABASE; Schema: -; Owner: mahuja
--

CREATE DATABASE "bstats_master" WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';


ALTER DATABASE "bstats_master" OWNER TO "mahuja";

\connect "bstats_master"

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 13 (class 2615 OID 16754)
-- Name: event; Type: SCHEMA; Schema: -; Owner: mahuja
--

CREATE SCHEMA "event";


ALTER SCHEMA "event" OWNER TO "mahuja";

--
-- TOC entry 12 (class 2615 OID 17082)
-- Name: logs; Type: SCHEMA; Schema: -; Owner: mahuja
--

CREATE SCHEMA "logs";


ALTER SCHEMA "logs" OWNER TO "mahuja";

--
-- TOC entry 8 (class 2615 OID 16406)
-- Name: old_queries; Type: SCHEMA; Schema: -; Owner: mahuja
--

CREATE SCHEMA "old_queries";


ALTER SCHEMA "old_queries" OWNER TO "mahuja";

--
-- TOC entry 2172 (class 0 OID 0)
-- Dependencies: 8
-- Name: SCHEMA "old_queries"; Type: COMMENT; Schema: -; Owner: mahuja
--

COMMENT ON SCHEMA "old_queries" IS 'SQL code doing complex selects (e.g. ALS php embedded with joins) should be moved here; that way we get the dependency tracking.';


--
-- TOC entry 7 (class 2615 OID 16408)
-- Name: old_static; Type: SCHEMA; Schema: -; Owner: mahuja
--

CREATE SCHEMA "old_static";


ALTER SCHEMA "old_static" OWNER TO "mahuja";

--
-- TOC entry 6 (class 2615 OID 16599)
-- Name: player; Type: SCHEMA; Schema: -; Owner: mahuja
--

CREATE SCHEMA "player";


ALTER SCHEMA "player" OWNER TO "mahuja";

--
-- TOC entry 11 (class 2615 OID 16961)
-- Name: server; Type: SCHEMA; Schema: -; Owner: mahuja
--

CREATE SCHEMA "server";


ALTER SCHEMA "server" OWNER TO "mahuja";

--
-- TOC entry 2176 (class 0 OID 0)
-- Dependencies: 11
-- Name: SCHEMA "server"; Type: COMMENT; Schema: -; Owner: mahuja
--

COMMENT ON SCHEMA "server" IS 'This schema shall contain ALL the server needs access to. Mostly functions that run with enough priveleges for that particular task.';


--
-- TOC entry 14 (class 2615 OID 16620)
-- Name: session; Type: SCHEMA; Schema: -; Owner: mahuja
--

CREATE SCHEMA "session";


ALTER SCHEMA "session" OWNER TO "mahuja";

--
-- TOC entry 206 (class 3079 OID 16409)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS "plpgsql" WITH SCHEMA "pg_catalog";


--
-- TOC entry 2179 (class 0 OID 0)
-- Dependencies: 206
-- Name: EXTENSION "plpgsql"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "plpgsql" IS 'PL/pgSQL procedural language';


--
-- TOC entry 205 (class 3079 OID 16414)
-- Name: adminpack; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS "adminpack" WITH SCHEMA "pg_catalog";


--
-- TOC entry 2180 (class 0 OID 0)
-- Dependencies: 205
-- Name: EXTENSION "adminpack"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "adminpack" IS 'administrative functions for PostgreSQL';


SET search_path = "old_queries", pg_catalog;

--
-- TOC entry 219 (class 1255 OID 16427)
-- Name: view_page_player(integer); Type: FUNCTION; Schema: old_queries; Owner: bstats_auto
--

CREATE FUNCTION "view_page_player"("playerid" integer) RETURNS integer
    LANGUAGE "sql" SECURITY DEFINER
    AS $_$update queries.page_views_player set cnt = cnt + 1 where playerid = $1 returning cnt;$_$;


ALTER FUNCTION "old_queries"."view_page_player"("playerid" integer) OWNER TO "bstats_auto";

SET search_path = "old_static", pg_catalog;

--
-- TOC entry 220 (class 1255 OID 16438)
-- Name: add_unknown_classes(); Type: FUNCTION; Schema: old_static; Owner: mahuja
--

CREATE FUNCTION "add_unknown_classes"() RETURNS "void"
    LANGUAGE "sql"
    AS $$insert into classnames (classname) 
SELECT distinct class FROM weaponstats_sum
left join static.classnames on class = classnames.classname
WHERE classnames.classname IS NULL
$$;


ALTER FUNCTION "old_static"."add_unknown_classes"() OWNER TO "mahuja";

--
-- TOC entry 2182 (class 0 OID 0)
-- Dependencies: 220
-- Name: FUNCTION "add_unknown_classes"(); Type: COMMENT; Schema: old_static; Owner: mahuja
--

COMMENT ON FUNCTION "add_unknown_classes"() IS 'Fill classnames with entries known/reported through wpninfo but not already registered';


--
-- TOC entry 221 (class 1255 OID 16439)
-- Name: test_before_insert_upsert(); Type: FUNCTION; Schema: old_static; Owner: mahuja
--

CREATE FUNCTION "test_before_insert_upsert"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
perform * from test where key = new.key;
if found then
  update test set val = new.val where key=new.key;
  return null;
end if;
return new;
end
$$;


ALTER FUNCTION "old_static"."test_before_insert_upsert"() OWNER TO "mahuja";

SET search_path = "player", pg_catalog;

--
-- TOC entry 218 (class 1255 OID 16611)
-- Name: player_uid_to_id(character varying); Type: FUNCTION; Schema: player; Owner: mahuja
--

CREATE FUNCTION "player_uid_to_id"("uid" character varying) RETURNS integer
    LANGUAGE "sql" IMMUTABLE STRICT
    AS $_$select id from player.playerlist where gameuid = $1;
$_$;


ALTER FUNCTION "player"."player_uid_to_id"("uid" character varying) OWNER TO "mahuja";

--
-- TOC entry 222 (class 1255 OID 17032)
-- Name: weaponstats_sum_upsert(); Type: FUNCTION; Schema: player; Owner: bstats_auto
--

CREATE FUNCTION "weaponstats_sum_upsert"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$begin
perform * from weaponstats_sum where player = new.player and "class" = new.class;
if found then
  update player.weaponstats_sum set 
	totalseconds = totalseconds + new.totalseconds,
	"fired" = "fired" + new.fired,
	vehiclehits = vehiclehits + new.vehiclehits,
	headhits = headhits + new.headhits,
	bodyhits = bodyhits + new.bodyhits,
	leghits = leghits + new.leghits,
	armhits = armhits + new.armhits
	where player = new.player and "class" = new.class;
  return null;
end if;
return new;
end $$;


ALTER FUNCTION "player"."weaponstats_sum_upsert"() OWNER TO "bstats_auto";

--
-- TOC entry 2183 (class 0 OID 0)
-- Dependencies: 222
-- Name: FUNCTION "weaponstats_sum_upsert"(); Type: COMMENT; Schema: player; Owner: bstats_auto
--

COMMENT ON FUNCTION "weaponstats_sum_upsert"() IS 'To have an actual race condition, some server must delay its data transmission enough for the player to switch to another enabled server. Therefore this, despite being single-checked, is considered adequate.';


SET search_path = "server", pg_catalog;

--
-- TOC entry 223 (class 1255 OID 17139)
-- Name: accrash1(integer, "text", integer, integer, "text", integer, numeric[]); Type: FUNCTION; Schema: server; Owner: bstats_auto
--

CREATE FUNCTION "accrash1"("sessionid" integer, "playerid" "text", "when" integer, "passengercount" integer, "vehiclename" "text", "score" integer, "playerpos" numeric[]) RETURNS "void"
    LANGUAGE "sql" SECURITY DEFINER
    AS $_$
insert into event.ac_crash ("session", player, "time", "passengers", "vehicle", 
	points, "position" ) values
( $1, server.player_uid_to_id($2), 
  ($3 || ' seconds') :: interval,
  $4,
  $5,
  
  $6, $7
)
$_$;


ALTER FUNCTION "server"."accrash1"("sessionid" integer, "playerid" "text", "when" integer, "passengercount" integer, "vehiclename" "text", "score" integer, "playerpos" numeric[]) OWNER TO "bstats_auto";

--
-- TOC entry 224 (class 1255 OID 17140)
-- Name: death1(integer, "text", integer, integer, numeric[]); Type: FUNCTION; Schema: server; Owner: bstats_auto
--

CREATE FUNCTION "death1"("sessionid" integer, "playerid" "text", "when" integer, "score" integer, "playerpos" numeric[]) RETURNS "void"
    LANGUAGE "sql" SECURITY DEFINER
    AS $_$
insert into event.death ("session", player, "time", "position", points, is_suicide) values
( $1, server.player_uid_to_id($2), 
  ($3 || ' seconds') :: interval,
  $5,
  $4,
  false
)
$_$;


ALTER FUNCTION "server"."death1"("sessionid" integer, "playerid" "text", "when" integer, "score" integer, "playerpos" numeric[]) OWNER TO "bstats_auto";

--
-- TOC entry 225 (class 1255 OID 17119)
-- Name: endsession1(integer, integer, "text"); Type: FUNCTION; Schema: server; Owner: bstats_auto
--

CREATE FUNCTION "endsession1"("sessionid" integer, "duration" integer, "outcome" "text") RETURNS "void"
    LANGUAGE "sql" SECURITY DEFINER
    AS $_$
-- todo: Sanity checks - has this been called already?
update session.session set duration = ($2 || ' seconds')::interval, result = $3 where id = $1;
$_$;


ALTER FUNCTION "server"."endsession1"("sessionid" integer, "duration" integer, "outcome" "text") OWNER TO "bstats_auto";

--
-- TOC entry 226 (class 1255 OID 17152)
-- Name: inf_killed_inf1(integer, "text", "text", integer, "text", integer, numeric[], numeric[]); Type: FUNCTION; Schema: server; Owner: bstats_auto
--

CREATE FUNCTION "inf_killed_inf1"("sessionid" integer, "killer" "text", "victim" "text", "when" integer, "weapon" "text", "score" integer, "killerpos" numeric[], "victimpos" numeric[]) RETURNS "void"
    LANGUAGE "sql" SECURITY DEFINER
    AS $_$
insert into event.inf_inf_kill 
(session, player, victim, "time", weapon, points, "position", "victim_position")
values (
$1,			-- session id
server.player_uid_to_id($2),	-- killer/player
server.player_uid_to_id($3),	-- victim
($4 || ' seconds') ::interval,	-- when/time
$5,			-- weapon
$6,			-- points/score
$7,			-- position/killerpos
$8			-- victim_position/victimpos
)
$_$;


ALTER FUNCTION "server"."inf_killed_inf1"("sessionid" integer, "killer" "text", "victim" "text", "when" integer, "weapon" "text", "score" integer, "killerpos" numeric[], "victimpos" numeric[]) OWNER TO "bstats_auto";

--
-- TOC entry 228 (class 1255 OID 17148)
-- Name: newmission1(integer, "text"); Type: FUNCTION; Schema: server; Owner: bstats_auto
--

CREATE FUNCTION "newmission1"("oldsession" integer, "mission_name" "text") RETURNS integer
    LANGUAGE "sql" SECURITY DEFINER
    AS $_$
insert into session.session (missionname,server) 
values ($2,
  ( select id from session.serverlist where name = session_user )
)
returning id;
$_$;


ALTER FUNCTION "server"."newmission1"("oldsession" integer, "mission_name" "text") OWNER TO "bstats_auto";

--
-- TOC entry 231 (class 1255 OID 17141)
-- Name: newplayer1(integer, "text", "text", integer, "text"); Type: FUNCTION; Schema: server; Owner: bstats_auto
--

CREATE FUNCTION "newplayer1"("sessionid" integer, "playerid" "text", "playerside" "text", "jointime" integer, "playername_p" "text") RETURNS "void"
    LANGUAGE "sql" SECURITY DEFINER
    AS $_$
insert into player.player(gameuid,last_name_seen) values ($2, $5);
insert into session.sessionplayers(session, player, side, joined, playername) values 
($1, server.player_uid_to_id($2), $3, ($4 || ' seconds') ::interval, $5)
-- todo: add to player list
-- todo: add to playername list
$_$;


ALTER FUNCTION "server"."newplayer1"("sessionid" integer, "playerid" "text", "playerside" "text", "jointime" integer, "playername_p" "text") OWNER TO "bstats_auto";

--
-- TOC entry 227 (class 1255 OID 17137)
-- Name: player_uid_to_id("text"); Type: FUNCTION; Schema: server; Owner: bstats_auto
--

CREATE FUNCTION "player_uid_to_id"("uid" "text") RETURNS bigint
    LANGUAGE "sql" IMMUTABLE STRICT SECURITY DEFINER
    AS $_$
  select id from player.player where gameuid = $1;
$_$;


ALTER FUNCTION "server"."player_uid_to_id"("uid" "text") OWNER TO "bstats_auto";

--
-- TOC entry 229 (class 1255 OID 17143)
-- Name: playerleft1(integer, "text", integer); Type: FUNCTION; Schema: server; Owner: bstats_auto
--

CREATE FUNCTION "playerleft1"("sessionid" integer, "playerid" "text", "when" integer) RETURNS "void"
    LANGUAGE "sql" SECURITY DEFINER
    AS $_$
-- todo: Sanity checks - has this been called already?
update session.sessionplayers set "left" = ($3 || ' seconds')::interval 
where "session" = $1 and player = server.player_uid_to_id($2);
$_$;


ALTER FUNCTION "server"."playerleft1"("sessionid" integer, "playerid" "text", "when" integer) OWNER TO "bstats_auto";

--
-- TOC entry 230 (class 1255 OID 17142)
-- Name: suicide1(integer, "text", integer, integer, numeric[]); Type: FUNCTION; Schema: server; Owner: bstats_auto
--

CREATE FUNCTION "suicide1"("sessionid" integer, "playerid" "text", "when" integer, "score" integer, "playerpos" numeric[]) RETURNS "void"
    LANGUAGE "sql" SECURITY DEFINER
    AS $_$
insert into event.death ("session", player, "time", "position", points, is_suicide) values
( $1, server.player_uid_to_id($2), 
  ($3 || ' seconds') :: interval,
  $5,
  $4,
  true
)
$_$;


ALTER FUNCTION "server"."suicide1"("sessionid" integer, "playerid" "text", "when" integer, "score" integer, "playerpos" numeric[]) OWNER TO "bstats_auto";

SET search_path = "event", pg_catalog;

SET default_with_oids = false;

--
-- TOC entry 182 (class 1259 OID 16765)
-- Name: event; Type: TABLE; Schema: event; Owner: mahuja
--

CREATE TABLE "event" (
    "eventid" integer NOT NULL,
    "message" "text",
    "session" integer NOT NULL,
    "time" interval
);


ALTER TABLE "event"."event" OWNER TO "mahuja";

--
-- TOC entry 183 (class 1259 OID 16779)
-- Name: playerevent; Type: TABLE; Schema: event; Owner: mahuja
--

CREATE TABLE "playerevent" (
    "player" integer NOT NULL,
    "position" real[]
)
INHERITS ("event");


ALTER TABLE "event"."playerevent" OWNER TO "mahuja";

--
-- TOC entry 184 (class 1259 OID 16788)
-- Name: scoreevent; Type: TABLE; Schema: event; Owner: mahuja
--

CREATE TABLE "scoreevent" (
    "points" integer DEFAULT 0 NOT NULL
)
INHERITS ("playerevent");


ALTER TABLE "event"."scoreevent" OWNER TO "mahuja";

--
-- TOC entry 191 (class 1259 OID 16881)
-- Name: ac_crash; Type: TABLE; Schema: event; Owner: mahuja
--

CREATE TABLE "ac_crash" (
    "passengers" integer,
    "vehicle" "text"
)
INHERITS ("scoreevent");


ALTER TABLE "event"."ac_crash" OWNER TO "mahuja";

--
-- TOC entry 195 (class 1259 OID 16929)
-- Name: civkill; Type: TABLE; Schema: event; Owner: mahuja
--

CREATE TABLE "civkill" (
    "victim" integer NOT NULL,
    "victim_position" real[],
    "weapon" "text",
    "damage_only" boolean NOT NULL
)
INHERITS ("scoreevent");


ALTER TABLE "event"."civkill" OWNER TO "mahuja";

--
-- TOC entry 190 (class 1259 OID 16871)
-- Name: death; Type: TABLE; Schema: event; Owner: mahuja
--

CREATE TABLE "death" (
    "is_suicide" boolean DEFAULT false
)
INHERITS ("scoreevent");


ALTER TABLE "event"."death" OWNER TO "mahuja";

--
-- TOC entry 181 (class 1259 OID 16763)
-- Name: event_eventid_seq; Type: SEQUENCE; Schema: event; Owner: mahuja
--

CREATE SEQUENCE "event_eventid_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "event"."event_eventid_seq" OWNER TO "mahuja";

--
-- TOC entry 2199 (class 0 OID 0)
-- Dependencies: 181
-- Name: event_eventid_seq; Type: SEQUENCE OWNED BY; Schema: event; Owner: mahuja
--

ALTER SEQUENCE "event_eventid_seq" OWNED BY "event"."eventid";


--
-- TOC entry 185 (class 1259 OID 16798)
-- Name: inf_inf_kill; Type: TABLE; Schema: event; Owner: mahuja
--

CREATE TABLE "inf_inf_kill" (
    "victim" integer NOT NULL,
    "victim_position" real[],
    "weapon" "text"
)
INHERITS ("scoreevent");


ALTER TABLE "event"."inf_inf_kill" OWNER TO "mahuja";

--
-- TOC entry 186 (class 1259 OID 16812)
-- Name: inf_veh_kill; Type: TABLE; Schema: event; Owner: mahuja
--

CREATE TABLE "inf_veh_kill" (
    "targettype" "text" NOT NULL,
    "target_position" real[],
    "target_empty" boolean,
    "weapon" "text"
)
INHERITS ("scoreevent");


ALTER TABLE "event"."inf_veh_kill" OWNER TO "mahuja";

--
-- TOC entry 189 (class 1259 OID 16853)
-- Name: kill_assist; Type: TABLE; Schema: event; Owner: mahuja
--

CREATE TABLE "kill_assist" (
)
INHERITS ("scoreevent");


ALTER TABLE "event"."kill_assist" OWNER TO "mahuja";

--
-- TOC entry 194 (class 1259 OID 16919)
-- Name: roadkill; Type: TABLE; Schema: event; Owner: mahuja
--

CREATE TABLE "roadkill" (
    "victim" integer NOT NULL,
    "victim_position" real[],
    "vehicletype" "text",
    "player_slot" "text"
)
INHERITS ("scoreevent");


ALTER TABLE "event"."roadkill" OWNER TO "mahuja";

--
-- TOC entry 192 (class 1259 OID 16891)
-- Name: teamkill; Type: TABLE; Schema: event; Owner: mahuja
--

CREATE TABLE "teamkill" (
    "victim" integer NOT NULL,
    "victim_position" real[],
    "weapon" "text",
    "damage_only" boolean NOT NULL
)
INHERITS ("scoreevent");


ALTER TABLE "event"."teamkill" OWNER TO "mahuja";

--
-- TOC entry 196 (class 1259 OID 16939)
-- Name: transport; Type: TABLE; Schema: event; Owner: mahuja
--

CREATE TABLE "transport" (
    "vehicletype" "text" NOT NULL,
    "distance" numeric NOT NULL
)
INHERITS ("scoreevent");


ALTER TABLE "event"."transport" OWNER TO "mahuja";

--
-- TOC entry 187 (class 1259 OID 16836)
-- Name: veh_inf_kill; Type: TABLE; Schema: event; Owner: mahuja
--

CREATE TABLE "veh_inf_kill" (
    "victim" integer NOT NULL,
    "victim_position" real[],
    "vehicletype" "text",
    "player_slot" "text"
)
INHERITS ("scoreevent");


ALTER TABLE "event"."veh_inf_kill" OWNER TO "mahuja";

--
-- TOC entry 188 (class 1259 OID 16845)
-- Name: veh_veh_kill; Type: TABLE; Schema: event; Owner: mahuja
--

CREATE TABLE "veh_veh_kill" (
    "targettype" "text" NOT NULL,
    "target_position" real[],
    "target_empty" boolean,
    "vehicle_type" "text",
    "player_slot" "text"
)
INHERITS ("scoreevent");


ALTER TABLE "event"."veh_veh_kill" OWNER TO "mahuja";

--
-- TOC entry 193 (class 1259 OID 16901)
-- Name: zone_capture; Type: TABLE; Schema: event; Owner: mahuja
--

CREATE TABLE "zone_capture" (
    "zone_name" "text"
)
INHERITS ("scoreevent");


ALTER TABLE "event"."zone_capture" OWNER TO "mahuja";

SET search_path = "logs", pg_catalog;

--
-- TOC entry 204 (class 1259 OID 17085)
-- Name: client_errors; Type: TABLE; Schema: logs; Owner: mahuja
--

CREATE TABLE "client_errors" (
    "id" integer NOT NULL,
    "clientname" "text",
    "timestamp" timestamp without time zone NOT NULL,
    "errormsg" "text" NOT NULL,
    "query" "text"
);


ALTER TABLE "logs"."client_errors" OWNER TO "mahuja";

--
-- TOC entry 203 (class 1259 OID 17083)
-- Name: client_errors_id_seq; Type: SEQUENCE; Schema: logs; Owner: mahuja
--

CREATE SEQUENCE "client_errors_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "logs"."client_errors_id_seq" OWNER TO "mahuja";

--
-- TOC entry 2211 (class 0 OID 0)
-- Dependencies: 203
-- Name: client_errors_id_seq; Type: SEQUENCE OWNED BY; Schema: logs; Owner: mahuja
--

ALTER SEQUENCE "client_errors_id_seq" OWNED BY "client_errors"."id";


SET search_path = "old_queries", pg_catalog;

--
-- TOC entry 169 (class 1259 OID 16495)
-- Name: page_views_player; Type: TABLE; Schema: old_queries; Owner: mahuja
--

CREATE TABLE "page_views_player" (
    "playerid" integer NOT NULL,
    "cnt" integer DEFAULT 0
);


ALTER TABLE "old_queries"."page_views_player" OWNER TO "mahuja";

SET search_path = "old_static", pg_catalog;

--
-- TOC entry 170 (class 1259 OID 16527)
-- Name: classgroups; Type: TABLE; Schema: old_static; Owner: mahuja
--

CREATE TABLE "classgroups" (
    "groupname" character varying(40) NOT NULL,
    "categories" character varying(40)[],
    "vorder" smallint,
    "worder" smallint
);


ALTER TABLE "old_static"."classgroups" OWNER TO "mahuja";

--
-- TOC entry 171 (class 1259 OID 16533)
-- Name: classnames; Type: TABLE; Schema: old_static; Owner: mahuja
--

CREATE TABLE "classnames" (
    "classname" character varying(40) NOT NULL,
    "displayname" character varying(40),
    "vehiclecategory" character varying(20),
    "weaponcategory" character varying(20),
    CONSTRAINT "either_weapon_or_vehicle" CHECK ((NOT (("weaponcategory" IS NOT NULL) AND ("vehiclecategory" IS NOT NULL))))
);


ALTER TABLE "old_static"."classnames" OWNER TO "mahuja";

SET search_path = "player", pg_catalog;

--
-- TOC entry 180 (class 1259 OID 16708)
-- Name: playername; Type: TABLE; Schema: player; Owner: mahuja
--

CREATE TABLE "playername" (
    "playerid" integer NOT NULL,
    "name" "text" NOT NULL,
    "lastseen" timestamp with time zone DEFAULT "now"() NOT NULL,
    "firstseen" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "player"."playername" OWNER TO "mahuja";

--
-- TOC entry 200 (class 1259 OID 17013)
-- Name: last_name_seen; Type: VIEW; Schema: player; Owner: mahuja
--

CREATE VIEW "last_name_seen" AS
SELECT "playername"."playerid", "first_value"("playername"."name") OVER (PARTITION BY "playername"."playerid" ORDER BY "playername"."lastseen" DESC) AS "name" FROM "playername";


ALTER TABLE "player"."last_name_seen" OWNER TO "mahuja";

--
-- TOC entry 173 (class 1259 OID 16602)
-- Name: player; Type: TABLE; Schema: player; Owner: mahuja
--

CREATE TABLE "player" (
    "id" bigint NOT NULL,
    "gameuid" character varying(64) NOT NULL,
    "first_seen" timestamp with time zone DEFAULT "now"() NOT NULL,
    "last_name_seen" "text" NOT NULL
);


ALTER TABLE "player"."player" OWNER TO "mahuja";

--
-- TOC entry 172 (class 1259 OID 16600)
-- Name: playerlist_id_seq; Type: SEQUENCE; Schema: player; Owner: mahuja
--

CREATE SEQUENCE "playerlist_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "player"."playerlist_id_seq" OWNER TO "mahuja";

--
-- TOC entry 2217 (class 0 OID 0)
-- Dependencies: 172
-- Name: playerlist_id_seq; Type: SEQUENCE OWNED BY; Schema: player; Owner: mahuja
--

ALTER SEQUENCE "playerlist_id_seq" OWNED BY "player"."id";


--
-- TOC entry 199 (class 1259 OID 16973)
-- Name: playersum; Type: TABLE; Schema: player; Owner: mahuja
--

CREATE TABLE "playersum" (
    "playerid" integer NOT NULL,
    "totalscore" integer DEFAULT 0 NOT NULL,
    "battlescore" integer DEFAULT 0 NOT NULL,
    "otherscore" integer DEFAULT 0 NOT NULL,
    "suicides" integer DEFAULT 0 NOT NULL,
    "weaponkills" integer DEFAULT 0 NOT NULL,
    "deaths" integer DEFAULT 0 NOT NULL,
    "aircrashes" integer DEFAULT 0 NOT NULL,
    "roadkills" integer DEFAULT 0 NOT NULL,
    "civcas" integer DEFAULT 0 NOT NULL,
    "civdmg" integer DEFAULT 0 NOT NULL,
    "teamkills" integer DEFAULT 0 NOT NULL,
    "teamdmg" integer DEFAULT 0 NOT NULL,
    "killed_vehicles" integer DEFAULT 0 NOT NULL,
    "tked_vehicles" integer DEFAULT 0 NOT NULL,
    "killassist" integer DEFAULT 0 NOT NULL
);


ALTER TABLE "player"."playersum" OWNER TO "mahuja";

--
-- TOC entry 202 (class 1259 OID 17048)
-- Name: weaponstats; Type: TABLE; Schema: player; Owner: mahuja
--

CREATE TABLE "weaponstats" (
    "session" integer NOT NULL,
    "player" integer NOT NULL,
    "class" character varying(40) NOT NULL,
    "totalseconds" integer DEFAULT 0,
    "fired" integer DEFAULT 0,
    "vehiclehits" integer DEFAULT 0,
    "headhits" integer DEFAULT 0,
    "bodyhits" integer DEFAULT 0,
    "leghits" integer DEFAULT 0,
    "armhits" integer DEFAULT 0
);


ALTER TABLE "player"."weaponstats" OWNER TO "mahuja";

--
-- TOC entry 201 (class 1259 OID 17033)
-- Name: weaponstats_sum; Type: TABLE; Schema: player; Owner: mahuja
--

CREATE TABLE "weaponstats_sum" (
    "player" integer NOT NULL,
    "class" character varying(40) NOT NULL,
    "totalseconds" integer DEFAULT 0 NOT NULL,
    "fired" integer DEFAULT 0 NOT NULL,
    "vehiclehits" integer DEFAULT 0 NOT NULL,
    "headhits" integer DEFAULT 0 NOT NULL,
    "bodyhits" integer DEFAULT 0 NOT NULL,
    "leghits" integer DEFAULT 0 NOT NULL,
    "armhits" integer DEFAULT 0 NOT NULL,
    "avgdist" real DEFAULT 0 NOT NULL,
    "avgcnt" integer DEFAULT 0 NOT NULL
);


ALTER TABLE "player"."weaponstats_sum" OWNER TO "mahuja";

SET search_path = "session", pg_catalog;

--
-- TOC entry 198 (class 1259 OID 16952)
-- Name: errorlog; Type: TABLE; Schema: session; Owner: mahuja
--

CREATE TABLE "errorlog" (
    "errorid" integer NOT NULL,
    "query" "text",
    "errormessage" "text"
);


ALTER TABLE "session"."errorlog" OWNER TO "mahuja";

--
-- TOC entry 2219 (class 0 OID 0)
-- Dependencies: 198
-- Name: TABLE "errorlog"; Type: COMMENT; Schema: session; Owner: mahuja
--

COMMENT ON TABLE "errorlog" IS 'Anytime a query fails on a server, that should be logged in this table.';


--
-- TOC entry 197 (class 1259 OID 16950)
-- Name: errorlog_errorid_seq; Type: SEQUENCE; Schema: session; Owner: mahuja
--

CREATE SEQUENCE "errorlog_errorid_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "session"."errorlog_errorid_seq" OWNER TO "mahuja";

--
-- TOC entry 2221 (class 0 OID 0)
-- Dependencies: 197
-- Name: errorlog_errorid_seq; Type: SEQUENCE OWNED BY; Schema: session; Owner: mahuja
--

ALTER SEQUENCE "errorlog_errorid_seq" OWNED BY "errorlog"."errorid";


--
-- TOC entry 178 (class 1259 OID 16637)
-- Name: serverlist; Type: TABLE; Schema: session; Owner: mahuja
--

CREATE TABLE "serverlist" (
    "id" integer NOT NULL,
    "name" character varying(64),
    "address" "inet"
);


ALTER TABLE "session"."serverlist" OWNER TO "mahuja";

--
-- TOC entry 177 (class 1259 OID 16635)
-- Name: serverlist_id_seq; Type: SEQUENCE; Schema: session; Owner: mahuja
--

CREATE SEQUENCE "serverlist_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "session"."serverlist_id_seq" OWNER TO "mahuja";

--
-- TOC entry 2224 (class 0 OID 0)
-- Dependencies: 177
-- Name: serverlist_id_seq; Type: SEQUENCE OWNED BY; Schema: session; Owner: mahuja
--

ALTER SEQUENCE "serverlist_id_seq" OWNED BY "serverlist"."id";


--
-- TOC entry 175 (class 1259 OID 16623)
-- Name: session; Type: TABLE; Schema: session; Owner: mahuja
--

CREATE TABLE "session" (
    "id" integer NOT NULL,
    "missionname" "text",
    "result" "text",
    "server" integer NOT NULL,
    "duration" interval
);


ALTER TABLE "session"."session" OWNER TO "mahuja";

--
-- TOC entry 174 (class 1259 OID 16621)
-- Name: session_id_seq; Type: SEQUENCE; Schema: session; Owner: mahuja
--

CREATE SEQUENCE "session_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "session"."session_id_seq" OWNER TO "mahuja";

--
-- TOC entry 2227 (class 0 OID 0)
-- Dependencies: 174
-- Name: session_id_seq; Type: SEQUENCE OWNED BY; Schema: session; Owner: mahuja
--

ALTER SEQUENCE "session_id_seq" OWNED BY "session"."id";


--
-- TOC entry 176 (class 1259 OID 16629)
-- Name: sessionplayers; Type: TABLE; Schema: session; Owner: mahuja
--

CREATE TABLE "sessionplayers" (
    "player" integer NOT NULL,
    "session" integer,
    "side" character varying(8),
    "playername" "text",
    "id" integer NOT NULL,
    "joined" interval,
    "left" interval
);


ALTER TABLE "session"."sessionplayers" OWNER TO "mahuja";

--
-- TOC entry 179 (class 1259 OID 16668)
-- Name: sessionplayers_id_seq; Type: SEQUENCE; Schema: session; Owner: mahuja
--

CREATE SEQUENCE "sessionplayers_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "session"."sessionplayers_id_seq" OWNER TO "mahuja";

--
-- TOC entry 2230 (class 0 OID 0)
-- Dependencies: 179
-- Name: sessionplayers_id_seq; Type: SEQUENCE OWNED BY; Schema: session; Owner: mahuja
--

ALTER SEQUENCE "sessionplayers_id_seq" OWNED BY "sessionplayers"."id";


SET search_path = "event", pg_catalog;

--
-- TOC entry 1954 (class 2604 OID 16884)
-- Name: eventid; Type: DEFAULT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "ac_crash" ALTER COLUMN "eventid" SET DEFAULT "nextval"('"event_eventid_seq"'::"regclass");


--
-- TOC entry 1955 (class 2604 OID 16885)
-- Name: points; Type: DEFAULT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "ac_crash" ALTER COLUMN "points" SET DEFAULT 0;


--
-- TOC entry 1962 (class 2604 OID 16932)
-- Name: eventid; Type: DEFAULT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "civkill" ALTER COLUMN "eventid" SET DEFAULT "nextval"('"event_eventid_seq"'::"regclass");


--
-- TOC entry 1963 (class 2604 OID 16933)
-- Name: points; Type: DEFAULT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "civkill" ALTER COLUMN "points" SET DEFAULT 0;


--
-- TOC entry 1951 (class 2604 OID 16874)
-- Name: eventid; Type: DEFAULT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "death" ALTER COLUMN "eventid" SET DEFAULT "nextval"('"event_eventid_seq"'::"regclass");


--
-- TOC entry 1952 (class 2604 OID 16875)
-- Name: points; Type: DEFAULT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "death" ALTER COLUMN "points" SET DEFAULT 0;


--
-- TOC entry 1937 (class 2604 OID 16768)
-- Name: eventid; Type: DEFAULT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "event" ALTER COLUMN "eventid" SET DEFAULT "nextval"('"event_eventid_seq"'::"regclass");


--
-- TOC entry 1941 (class 2604 OID 16801)
-- Name: eventid; Type: DEFAULT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "inf_inf_kill" ALTER COLUMN "eventid" SET DEFAULT "nextval"('"event_eventid_seq"'::"regclass");


--
-- TOC entry 1942 (class 2604 OID 16802)
-- Name: points; Type: DEFAULT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "inf_inf_kill" ALTER COLUMN "points" SET DEFAULT 0;


--
-- TOC entry 1943 (class 2604 OID 16815)
-- Name: eventid; Type: DEFAULT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "inf_veh_kill" ALTER COLUMN "eventid" SET DEFAULT "nextval"('"event_eventid_seq"'::"regclass");


--
-- TOC entry 1944 (class 2604 OID 16816)
-- Name: points; Type: DEFAULT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "inf_veh_kill" ALTER COLUMN "points" SET DEFAULT 0;


--
-- TOC entry 1949 (class 2604 OID 16856)
-- Name: eventid; Type: DEFAULT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "kill_assist" ALTER COLUMN "eventid" SET DEFAULT "nextval"('"event_eventid_seq"'::"regclass");


--
-- TOC entry 1950 (class 2604 OID 16857)
-- Name: points; Type: DEFAULT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "kill_assist" ALTER COLUMN "points" SET DEFAULT 0;


--
-- TOC entry 1938 (class 2604 OID 16782)
-- Name: eventid; Type: DEFAULT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "playerevent" ALTER COLUMN "eventid" SET DEFAULT "nextval"('"event_eventid_seq"'::"regclass");


--
-- TOC entry 1960 (class 2604 OID 16922)
-- Name: eventid; Type: DEFAULT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "roadkill" ALTER COLUMN "eventid" SET DEFAULT "nextval"('"event_eventid_seq"'::"regclass");


--
-- TOC entry 1961 (class 2604 OID 16923)
-- Name: points; Type: DEFAULT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "roadkill" ALTER COLUMN "points" SET DEFAULT 0;


--
-- TOC entry 1939 (class 2604 OID 16791)
-- Name: eventid; Type: DEFAULT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "scoreevent" ALTER COLUMN "eventid" SET DEFAULT "nextval"('"event_eventid_seq"'::"regclass");


--
-- TOC entry 1956 (class 2604 OID 16894)
-- Name: eventid; Type: DEFAULT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "teamkill" ALTER COLUMN "eventid" SET DEFAULT "nextval"('"event_eventid_seq"'::"regclass");


--
-- TOC entry 1957 (class 2604 OID 16895)
-- Name: points; Type: DEFAULT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "teamkill" ALTER COLUMN "points" SET DEFAULT 0;


--
-- TOC entry 1964 (class 2604 OID 16942)
-- Name: eventid; Type: DEFAULT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "transport" ALTER COLUMN "eventid" SET DEFAULT "nextval"('"event_eventid_seq"'::"regclass");


--
-- TOC entry 1965 (class 2604 OID 16943)
-- Name: points; Type: DEFAULT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "transport" ALTER COLUMN "points" SET DEFAULT 0;


--
-- TOC entry 1945 (class 2604 OID 16839)
-- Name: eventid; Type: DEFAULT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "veh_inf_kill" ALTER COLUMN "eventid" SET DEFAULT "nextval"('"event_eventid_seq"'::"regclass");


--
-- TOC entry 1946 (class 2604 OID 16840)
-- Name: points; Type: DEFAULT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "veh_inf_kill" ALTER COLUMN "points" SET DEFAULT 0;


--
-- TOC entry 1947 (class 2604 OID 16848)
-- Name: eventid; Type: DEFAULT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "veh_veh_kill" ALTER COLUMN "eventid" SET DEFAULT "nextval"('"event_eventid_seq"'::"regclass");


--
-- TOC entry 1948 (class 2604 OID 16849)
-- Name: points; Type: DEFAULT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "veh_veh_kill" ALTER COLUMN "points" SET DEFAULT 0;


--
-- TOC entry 1958 (class 2604 OID 16904)
-- Name: eventid; Type: DEFAULT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "zone_capture" ALTER COLUMN "eventid" SET DEFAULT "nextval"('"event_eventid_seq"'::"regclass");


--
-- TOC entry 1959 (class 2604 OID 16905)
-- Name: points; Type: DEFAULT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "zone_capture" ALTER COLUMN "points" SET DEFAULT 0;


SET search_path = "logs", pg_catalog;

--
-- TOC entry 1998 (class 2604 OID 17088)
-- Name: id; Type: DEFAULT; Schema: logs; Owner: mahuja
--

ALTER TABLE ONLY "client_errors" ALTER COLUMN "id" SET DEFAULT "nextval"('"client_errors_id_seq"'::"regclass");


SET search_path = "player", pg_catalog;

--
-- TOC entry 1930 (class 2604 OID 16612)
-- Name: id; Type: DEFAULT; Schema: player; Owner: mahuja
--

ALTER TABLE ONLY "player" ALTER COLUMN "id" SET DEFAULT "nextval"('"playerlist_id_seq"'::"regclass");


SET search_path = "session", pg_catalog;

--
-- TOC entry 1966 (class 2604 OID 16955)
-- Name: errorid; Type: DEFAULT; Schema: session; Owner: mahuja
--

ALTER TABLE ONLY "errorlog" ALTER COLUMN "errorid" SET DEFAULT "nextval"('"errorlog_errorid_seq"'::"regclass");


--
-- TOC entry 1934 (class 2604 OID 16640)
-- Name: id; Type: DEFAULT; Schema: session; Owner: mahuja
--

ALTER TABLE ONLY "serverlist" ALTER COLUMN "id" SET DEFAULT "nextval"('"serverlist_id_seq"'::"regclass");


--
-- TOC entry 1932 (class 2604 OID 16626)
-- Name: id; Type: DEFAULT; Schema: session; Owner: mahuja
--

ALTER TABLE ONLY "session" ALTER COLUMN "id" SET DEFAULT "nextval"('"session_id_seq"'::"regclass");


--
-- TOC entry 1933 (class 2604 OID 16670)
-- Name: id; Type: DEFAULT; Schema: session; Owner: mahuja
--

ALTER TABLE ONLY "sessionplayers" ALTER COLUMN "id" SET DEFAULT "nextval"('"sessionplayers_id_seq"'::"regclass");


SET search_path = "event", pg_catalog;

--
-- TOC entry 2036 (class 2606 OID 16890)
-- Name: ac_crash_pkey; Type: CONSTRAINT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "ac_crash"
    ADD CONSTRAINT "ac_crash_pkey" PRIMARY KEY ("eventid");


--
-- TOC entry 2044 (class 2606 OID 16938)
-- Name: civkill_pkey; Type: CONSTRAINT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "civkill"
    ADD CONSTRAINT "civkill_pkey" PRIMARY KEY ("eventid");


--
-- TOC entry 2034 (class 2606 OID 16880)
-- Name: death_pkey; Type: CONSTRAINT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "death"
    ADD CONSTRAINT "death_pkey" PRIMARY KEY ("eventid");


--
-- TOC entry 2018 (class 2606 OID 16773)
-- Name: event_pkey; Type: CONSTRAINT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "event"
    ADD CONSTRAINT "event_pkey" PRIMARY KEY ("eventid");


--
-- TOC entry 2024 (class 2606 OID 16862)
-- Name: inf_inf_kill_pkey; Type: CONSTRAINT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "inf_inf_kill"
    ADD CONSTRAINT "inf_inf_kill_pkey" PRIMARY KEY ("eventid");


--
-- TOC entry 2026 (class 2606 OID 16864)
-- Name: inf_veh_kill_pkey; Type: CONSTRAINT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "inf_veh_kill"
    ADD CONSTRAINT "inf_veh_kill_pkey" PRIMARY KEY ("eventid");


--
-- TOC entry 2032 (class 2606 OID 16866)
-- Name: kill_assist_pkey; Type: CONSTRAINT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "kill_assist"
    ADD CONSTRAINT "kill_assist_pkey" PRIMARY KEY ("eventid");


--
-- TOC entry 2020 (class 2606 OID 16787)
-- Name: playerevent_pkey; Type: CONSTRAINT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "playerevent"
    ADD CONSTRAINT "playerevent_pkey" PRIMARY KEY ("eventid");


--
-- TOC entry 2042 (class 2606 OID 16928)
-- Name: roadkill_pkey; Type: CONSTRAINT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "roadkill"
    ADD CONSTRAINT "roadkill_pkey" PRIMARY KEY ("eventid");


--
-- TOC entry 2022 (class 2606 OID 16797)
-- Name: scoreevent_pkey; Type: CONSTRAINT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "scoreevent"
    ADD CONSTRAINT "scoreevent_pkey" PRIMARY KEY ("eventid");


--
-- TOC entry 2038 (class 2606 OID 16900)
-- Name: teamkill_pkey; Type: CONSTRAINT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "teamkill"
    ADD CONSTRAINT "teamkill_pkey" PRIMARY KEY ("eventid");


--
-- TOC entry 2046 (class 2606 OID 16948)
-- Name: transport_pkey; Type: CONSTRAINT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "transport"
    ADD CONSTRAINT "transport_pkey" PRIMARY KEY ("eventid");


--
-- TOC entry 2028 (class 2606 OID 16868)
-- Name: veh_inf_kill_pkey; Type: CONSTRAINT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "veh_inf_kill"
    ADD CONSTRAINT "veh_inf_kill_pkey" PRIMARY KEY ("eventid");


--
-- TOC entry 2030 (class 2606 OID 16870)
-- Name: veh_veh_kill_pkey; Type: CONSTRAINT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "veh_veh_kill"
    ADD CONSTRAINT "veh_veh_kill_pkey" PRIMARY KEY ("eventid");


--
-- TOC entry 2040 (class 2606 OID 16910)
-- Name: zone_capture_pkey; Type: CONSTRAINT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "zone_capture"
    ADD CONSTRAINT "zone_capture_pkey" PRIMARY KEY ("eventid");


SET search_path = "logs", pg_catalog;

--
-- TOC entry 2056 (class 2606 OID 17093)
-- Name: client_errors_pkey; Type: CONSTRAINT; Schema: logs; Owner: mahuja
--

ALTER TABLE ONLY "client_errors"
    ADD CONSTRAINT "client_errors_pkey" PRIMARY KEY ("id");


SET search_path = "old_queries", pg_catalog;

--
-- TOC entry 2000 (class 2606 OID 16546)
-- Name: page_views_player_pkey; Type: CONSTRAINT; Schema: old_queries; Owner: mahuja
--

ALTER TABLE ONLY "page_views_player"
    ADD CONSTRAINT "page_views_player_pkey" PRIMARY KEY ("playerid");


SET search_path = "old_static", pg_catalog;

--
-- TOC entry 2002 (class 2606 OID 16556)
-- Name: classgroups_pkey; Type: CONSTRAINT; Schema: old_static; Owner: mahuja
--

ALTER TABLE ONLY "classgroups"
    ADD CONSTRAINT "classgroups_pkey" PRIMARY KEY ("groupname");


--
-- TOC entry 2004 (class 2606 OID 16558)
-- Name: classnames_pkey; Type: CONSTRAINT; Schema: old_static; Owner: mahuja
--

ALTER TABLE ONLY "classnames"
    ADD CONSTRAINT "classnames_pkey" PRIMARY KEY ("classname");


SET search_path = "player", pg_catalog;

--
-- TOC entry 2006 (class 2606 OID 16614)
-- Name: playerlist_pkey; Type: CONSTRAINT; Schema: player; Owner: mahuja
--

ALTER TABLE ONLY "player"
    ADD CONSTRAINT "playerlist_pkey" PRIMARY KEY ("id");


--
-- TOC entry 2016 (class 2606 OID 16716)
-- Name: playername_pkey; Type: CONSTRAINT; Schema: player; Owner: mahuja
--

ALTER TABLE ONLY "playername"
    ADD CONSTRAINT "playername_pkey" PRIMARY KEY ("playerid", "name");


--
-- TOC entry 2050 (class 2606 OID 16992)
-- Name: playersum_pkey; Type: CONSTRAINT; Schema: player; Owner: mahuja
--

ALTER TABLE ONLY "playersum"
    ADD CONSTRAINT "playersum_pkey" PRIMARY KEY ("playerid");


--
-- TOC entry 2008 (class 2606 OID 16701)
-- Name: unique_gameuid; Type: CONSTRAINT; Schema: player; Owner: mahuja
--

ALTER TABLE ONLY "player"
    ADD CONSTRAINT "unique_gameuid" UNIQUE ("gameuid");


--
-- TOC entry 2054 (class 2606 OID 17059)
-- Name: weaponstats_pkey; Type: CONSTRAINT; Schema: player; Owner: mahuja
--

ALTER TABLE ONLY "weaponstats"
    ADD CONSTRAINT "weaponstats_pkey" PRIMARY KEY ("session", "player", "class");


--
-- TOC entry 2052 (class 2606 OID 17046)
-- Name: weaponstats_sum_pkey; Type: CONSTRAINT; Schema: player; Owner: mahuja
--

ALTER TABLE ONLY "weaponstats_sum"
    ADD CONSTRAINT "weaponstats_sum_pkey" PRIMARY KEY ("player", "class");


SET search_path = "session", pg_catalog;

--
-- TOC entry 2048 (class 2606 OID 16960)
-- Name: errorlog_pkey; Type: CONSTRAINT; Schema: session; Owner: mahuja
--

ALTER TABLE ONLY "errorlog"
    ADD CONSTRAINT "errorlog_pkey" PRIMARY KEY ("errorid");


--
-- TOC entry 2014 (class 2606 OID 16645)
-- Name: serverlist_pkey; Type: CONSTRAINT; Schema: session; Owner: mahuja
--

ALTER TABLE ONLY "serverlist"
    ADD CONSTRAINT "serverlist_pkey" PRIMARY KEY ("id");


--
-- TOC entry 2010 (class 2606 OID 16657)
-- Name: session_pkey; Type: CONSTRAINT; Schema: session; Owner: mahuja
--

ALTER TABLE ONLY "session"
    ADD CONSTRAINT "session_pkey" PRIMARY KEY ("id");


--
-- TOC entry 2012 (class 2606 OID 16672)
-- Name: sessionplayers_pkey; Type: CONSTRAINT; Schema: session; Owner: mahuja
--

ALTER TABLE ONLY "sessionplayers"
    ADD CONSTRAINT "sessionplayers_pkey" PRIMARY KEY ("id");


SET search_path = "player", pg_catalog;

--
-- TOC entry 2165 (class 2618 OID 17153)
-- Name: upsert; Type: RULE; Schema: player; Owner: mahuja
--

CREATE RULE "upsert" AS ON INSERT TO "player" WHERE (("new"."gameuid")::"text" IN (SELECT "player"."gameuid" FROM "player")) DO INSTEAD UPDATE "player" SET "last_name_seen" = "new"."last_name_seen" WHERE (("player"."gameuid")::"text" = ("new"."gameuid")::"text");


--
-- TOC entry 2062 (class 2620 OID 17047)
-- Name: upsert; Type: TRIGGER; Schema: player; Owner: mahuja
--

CREATE TRIGGER "upsert" BEFORE INSERT ON "weaponstats_sum" FOR EACH ROW EXECUTE PROCEDURE "weaponstats_sum_upsert"();


SET search_path = "event", pg_catalog;

--
-- TOC entry 2061 (class 2606 OID 16774)
-- Name: event_session_fkey; Type: FK CONSTRAINT; Schema: event; Owner: mahuja
--

ALTER TABLE ONLY "event"
    ADD CONSTRAINT "event_session_fkey" FOREIGN KEY ("session") REFERENCES "session"."session"("id");


SET search_path = "player", pg_catalog;

--
-- TOC entry 2060 (class 2606 OID 16717)
-- Name: playername_playerid_fkey; Type: FK CONSTRAINT; Schema: player; Owner: mahuja
--

ALTER TABLE ONLY "playername"
    ADD CONSTRAINT "playername_playerid_fkey" FOREIGN KEY ("playerid") REFERENCES "player"("id");


SET search_path = "session", pg_catalog;

--
-- TOC entry 2057 (class 2606 OID 16758)
-- Name: session_server_fkey; Type: FK CONSTRAINT; Schema: session; Owner: mahuja
--

ALTER TABLE ONLY "session"
    ADD CONSTRAINT "session_server_fkey" FOREIGN KEY ("server") REFERENCES "serverlist"("id");


--
-- TOC entry 2058 (class 2606 OID 16725)
-- Name: sessionplayers_player_fkey; Type: FK CONSTRAINT; Schema: session; Owner: mahuja
--

ALTER TABLE ONLY "sessionplayers"
    ADD CONSTRAINT "sessionplayers_player_fkey" FOREIGN KEY ("player") REFERENCES "player"."player"("id");


--
-- TOC entry 2059 (class 2606 OID 16737)
-- Name: sessionplayers_session_fkey; Type: FK CONSTRAINT; Schema: session; Owner: mahuja
--

ALTER TABLE ONLY "sessionplayers"
    ADD CONSTRAINT "sessionplayers_session_fkey" FOREIGN KEY ("session") REFERENCES "session"("id") ON DELETE CASCADE;


--
-- TOC entry 2171 (class 0 OID 0)
-- Dependencies: 13
-- Name: event; Type: ACL; Schema: -; Owner: mahuja
--

REVOKE ALL ON SCHEMA "event" FROM PUBLIC;
REVOKE ALL ON SCHEMA "event" FROM "mahuja";
GRANT ALL ON SCHEMA "event" TO "mahuja";
GRANT USAGE ON SCHEMA "event" TO "bstats_auto";
GRANT USAGE ON SCHEMA "event" TO "bstats_reader";
GRANT USAGE ON SCHEMA "event" TO "bstats_admin";


--
-- TOC entry 2173 (class 0 OID 0)
-- Dependencies: 8
-- Name: old_queries; Type: ACL; Schema: -; Owner: mahuja
--

REVOKE ALL ON SCHEMA "old_queries" FROM PUBLIC;
REVOKE ALL ON SCHEMA "old_queries" FROM "mahuja";
GRANT ALL ON SCHEMA "old_queries" TO "mahuja";
GRANT USAGE ON SCHEMA "old_queries" TO PUBLIC;


--
-- TOC entry 2174 (class 0 OID 0)
-- Dependencies: 7
-- Name: old_static; Type: ACL; Schema: -; Owner: mahuja
--

REVOKE ALL ON SCHEMA "old_static" FROM PUBLIC;
REVOKE ALL ON SCHEMA "old_static" FROM "mahuja";
GRANT ALL ON SCHEMA "old_static" TO "mahuja";
GRANT USAGE ON SCHEMA "old_static" TO PUBLIC;


--
-- TOC entry 2175 (class 0 OID 0)
-- Dependencies: 6
-- Name: player; Type: ACL; Schema: -; Owner: mahuja
--

REVOKE ALL ON SCHEMA "player" FROM PUBLIC;
REVOKE ALL ON SCHEMA "player" FROM "mahuja";
GRANT ALL ON SCHEMA "player" TO "mahuja";
GRANT USAGE ON SCHEMA "player" TO "bstats_auto";
GRANT USAGE ON SCHEMA "player" TO "bstats_admin";
GRANT USAGE ON SCHEMA "player" TO "bstats_reader";


--
-- TOC entry 2177 (class 0 OID 0)
-- Dependencies: 11
-- Name: server; Type: ACL; Schema: -; Owner: mahuja
--

REVOKE ALL ON SCHEMA "server" FROM PUBLIC;
REVOKE ALL ON SCHEMA "server" FROM "mahuja";
GRANT ALL ON SCHEMA "server" TO "mahuja";
GRANT USAGE ON SCHEMA "server" TO "bstats_servers";


--
-- TOC entry 2178 (class 0 OID 0)
-- Dependencies: 14
-- Name: session; Type: ACL; Schema: -; Owner: mahuja
--

REVOKE ALL ON SCHEMA "session" FROM PUBLIC;
REVOKE ALL ON SCHEMA "session" FROM "mahuja";
GRANT ALL ON SCHEMA "session" TO "mahuja";
GRANT USAGE ON SCHEMA "session" TO "bstats_auto";
GRANT USAGE ON SCHEMA "session" TO "bstats_reader";


SET search_path = "old_queries", pg_catalog;

--
-- TOC entry 2181 (class 0 OID 0)
-- Dependencies: 219
-- Name: view_page_player(integer); Type: ACL; Schema: old_queries; Owner: bstats_auto
--

REVOKE ALL ON FUNCTION "view_page_player"("playerid" integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION "view_page_player"("playerid" integer) FROM "bstats_auto";
GRANT ALL ON FUNCTION "view_page_player"("playerid" integer) TO "bstats_auto";
GRANT ALL ON FUNCTION "view_page_player"("playerid" integer) TO PUBLIC;
GRANT ALL ON FUNCTION "view_page_player"("playerid" integer) TO "bstats_reader";


SET search_path = "server", pg_catalog;

--
-- TOC entry 2184 (class 0 OID 0)
-- Dependencies: 223
-- Name: accrash1(integer, "text", integer, integer, "text", integer, numeric[]); Type: ACL; Schema: server; Owner: bstats_auto
--

REVOKE ALL ON FUNCTION "accrash1"("sessionid" integer, "playerid" "text", "when" integer, "passengercount" integer, "vehiclename" "text", "score" integer, "playerpos" numeric[]) FROM PUBLIC;
REVOKE ALL ON FUNCTION "accrash1"("sessionid" integer, "playerid" "text", "when" integer, "passengercount" integer, "vehiclename" "text", "score" integer, "playerpos" numeric[]) FROM "bstats_auto";
GRANT ALL ON FUNCTION "accrash1"("sessionid" integer, "playerid" "text", "when" integer, "passengercount" integer, "vehiclename" "text", "score" integer, "playerpos" numeric[]) TO "bstats_auto";
GRANT ALL ON FUNCTION "accrash1"("sessionid" integer, "playerid" "text", "when" integer, "passengercount" integer, "vehiclename" "text", "score" integer, "playerpos" numeric[]) TO "bstats_servers";
GRANT ALL ON FUNCTION "accrash1"("sessionid" integer, "playerid" "text", "when" integer, "passengercount" integer, "vehiclename" "text", "score" integer, "playerpos" numeric[]) TO "mahuja";


--
-- TOC entry 2185 (class 0 OID 0)
-- Dependencies: 224
-- Name: death1(integer, "text", integer, integer, numeric[]); Type: ACL; Schema: server; Owner: bstats_auto
--

REVOKE ALL ON FUNCTION "death1"("sessionid" integer, "playerid" "text", "when" integer, "score" integer, "playerpos" numeric[]) FROM PUBLIC;
REVOKE ALL ON FUNCTION "death1"("sessionid" integer, "playerid" "text", "when" integer, "score" integer, "playerpos" numeric[]) FROM "bstats_auto";
GRANT ALL ON FUNCTION "death1"("sessionid" integer, "playerid" "text", "when" integer, "score" integer, "playerpos" numeric[]) TO "bstats_auto";
GRANT ALL ON FUNCTION "death1"("sessionid" integer, "playerid" "text", "when" integer, "score" integer, "playerpos" numeric[]) TO "bstats_servers";


--
-- TOC entry 2186 (class 0 OID 0)
-- Dependencies: 225
-- Name: endsession1(integer, integer, "text"); Type: ACL; Schema: server; Owner: bstats_auto
--

REVOKE ALL ON FUNCTION "endsession1"("sessionid" integer, "duration" integer, "outcome" "text") FROM PUBLIC;
REVOKE ALL ON FUNCTION "endsession1"("sessionid" integer, "duration" integer, "outcome" "text") FROM "bstats_auto";
GRANT ALL ON FUNCTION "endsession1"("sessionid" integer, "duration" integer, "outcome" "text") TO "bstats_auto";
GRANT ALL ON FUNCTION "endsession1"("sessionid" integer, "duration" integer, "outcome" "text") TO "bstats_servers";


--
-- TOC entry 2187 (class 0 OID 0)
-- Dependencies: 226
-- Name: inf_killed_inf1(integer, "text", "text", integer, "text", integer, numeric[], numeric[]); Type: ACL; Schema: server; Owner: bstats_auto
--

REVOKE ALL ON FUNCTION "inf_killed_inf1"("sessionid" integer, "killer" "text", "victim" "text", "when" integer, "weapon" "text", "score" integer, "killerpos" numeric[], "victimpos" numeric[]) FROM PUBLIC;
REVOKE ALL ON FUNCTION "inf_killed_inf1"("sessionid" integer, "killer" "text", "victim" "text", "when" integer, "weapon" "text", "score" integer, "killerpos" numeric[], "victimpos" numeric[]) FROM "bstats_auto";
GRANT ALL ON FUNCTION "inf_killed_inf1"("sessionid" integer, "killer" "text", "victim" "text", "when" integer, "weapon" "text", "score" integer, "killerpos" numeric[], "victimpos" numeric[]) TO "bstats_auto";
GRANT ALL ON FUNCTION "inf_killed_inf1"("sessionid" integer, "killer" "text", "victim" "text", "when" integer, "weapon" "text", "score" integer, "killerpos" numeric[], "victimpos" numeric[]) TO "bstats_servers";


--
-- TOC entry 2188 (class 0 OID 0)
-- Dependencies: 228
-- Name: newmission1(integer, "text"); Type: ACL; Schema: server; Owner: bstats_auto
--

REVOKE ALL ON FUNCTION "newmission1"("oldsession" integer, "mission_name" "text") FROM PUBLIC;
REVOKE ALL ON FUNCTION "newmission1"("oldsession" integer, "mission_name" "text") FROM "bstats_auto";
GRANT ALL ON FUNCTION "newmission1"("oldsession" integer, "mission_name" "text") TO "bstats_auto";
GRANT ALL ON FUNCTION "newmission1"("oldsession" integer, "mission_name" "text") TO "bstats_servers";


--
-- TOC entry 2189 (class 0 OID 0)
-- Dependencies: 231
-- Name: newplayer1(integer, "text", "text", integer, "text"); Type: ACL; Schema: server; Owner: bstats_auto
--

REVOKE ALL ON FUNCTION "newplayer1"("sessionid" integer, "playerid" "text", "playerside" "text", "jointime" integer, "playername_p" "text") FROM PUBLIC;
REVOKE ALL ON FUNCTION "newplayer1"("sessionid" integer, "playerid" "text", "playerside" "text", "jointime" integer, "playername_p" "text") FROM "bstats_auto";
GRANT ALL ON FUNCTION "newplayer1"("sessionid" integer, "playerid" "text", "playerside" "text", "jointime" integer, "playername_p" "text") TO "bstats_auto";
GRANT ALL ON FUNCTION "newplayer1"("sessionid" integer, "playerid" "text", "playerside" "text", "jointime" integer, "playername_p" "text") TO "bstats_servers";


--
-- TOC entry 2190 (class 0 OID 0)
-- Dependencies: 227
-- Name: player_uid_to_id("text"); Type: ACL; Schema: server; Owner: bstats_auto
--

REVOKE ALL ON FUNCTION "player_uid_to_id"("uid" "text") FROM PUBLIC;
REVOKE ALL ON FUNCTION "player_uid_to_id"("uid" "text") FROM "bstats_auto";
GRANT ALL ON FUNCTION "player_uid_to_id"("uid" "text") TO "bstats_auto";
GRANT ALL ON FUNCTION "player_uid_to_id"("uid" "text") TO "bstats_servers";


--
-- TOC entry 2191 (class 0 OID 0)
-- Dependencies: 229
-- Name: playerleft1(integer, "text", integer); Type: ACL; Schema: server; Owner: bstats_auto
--

REVOKE ALL ON FUNCTION "playerleft1"("sessionid" integer, "playerid" "text", "when" integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION "playerleft1"("sessionid" integer, "playerid" "text", "when" integer) FROM "bstats_auto";
GRANT ALL ON FUNCTION "playerleft1"("sessionid" integer, "playerid" "text", "when" integer) TO "bstats_auto";
GRANT ALL ON FUNCTION "playerleft1"("sessionid" integer, "playerid" "text", "when" integer) TO "bstats_servers";


--
-- TOC entry 2192 (class 0 OID 0)
-- Dependencies: 230
-- Name: suicide1(integer, "text", integer, integer, numeric[]); Type: ACL; Schema: server; Owner: bstats_auto
--

REVOKE ALL ON FUNCTION "suicide1"("sessionid" integer, "playerid" "text", "when" integer, "score" integer, "playerpos" numeric[]) FROM PUBLIC;
REVOKE ALL ON FUNCTION "suicide1"("sessionid" integer, "playerid" "text", "when" integer, "score" integer, "playerpos" numeric[]) FROM "bstats_auto";
GRANT ALL ON FUNCTION "suicide1"("sessionid" integer, "playerid" "text", "when" integer, "score" integer, "playerpos" numeric[]) TO "bstats_auto";
GRANT ALL ON FUNCTION "suicide1"("sessionid" integer, "playerid" "text", "when" integer, "score" integer, "playerpos" numeric[]) TO "bstats_servers";


SET search_path = "event", pg_catalog;

--
-- TOC entry 2193 (class 0 OID 0)
-- Dependencies: 182
-- Name: event; Type: ACL; Schema: event; Owner: mahuja
--

REVOKE ALL ON TABLE "event" FROM PUBLIC;
REVOKE ALL ON TABLE "event" FROM "mahuja";
GRANT ALL ON TABLE "event" TO "mahuja";
GRANT SELECT,INSERT,UPDATE ON TABLE "event" TO "bstats_auto";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "event" TO "bstats_admin";


--
-- TOC entry 2194 (class 0 OID 0)
-- Dependencies: 183
-- Name: playerevent; Type: ACL; Schema: event; Owner: mahuja
--

REVOKE ALL ON TABLE "playerevent" FROM PUBLIC;
REVOKE ALL ON TABLE "playerevent" FROM "mahuja";
GRANT ALL ON TABLE "playerevent" TO "mahuja";
GRANT SELECT,INSERT,UPDATE ON TABLE "playerevent" TO "bstats_auto";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "playerevent" TO "bstats_admin";


--
-- TOC entry 2195 (class 0 OID 0)
-- Dependencies: 184
-- Name: scoreevent; Type: ACL; Schema: event; Owner: mahuja
--

REVOKE ALL ON TABLE "scoreevent" FROM PUBLIC;
REVOKE ALL ON TABLE "scoreevent" FROM "mahuja";
GRANT ALL ON TABLE "scoreevent" TO "mahuja";
GRANT SELECT,INSERT,UPDATE ON TABLE "scoreevent" TO "bstats_auto";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "scoreevent" TO "bstats_admin";


--
-- TOC entry 2196 (class 0 OID 0)
-- Dependencies: 191
-- Name: ac_crash; Type: ACL; Schema: event; Owner: mahuja
--

REVOKE ALL ON TABLE "ac_crash" FROM PUBLIC;
REVOKE ALL ON TABLE "ac_crash" FROM "mahuja";
GRANT ALL ON TABLE "ac_crash" TO "mahuja";
GRANT SELECT,INSERT,UPDATE ON TABLE "ac_crash" TO "bstats_auto";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "ac_crash" TO "bstats_admin";


--
-- TOC entry 2197 (class 0 OID 0)
-- Dependencies: 195
-- Name: civkill; Type: ACL; Schema: event; Owner: mahuja
--

REVOKE ALL ON TABLE "civkill" FROM PUBLIC;
REVOKE ALL ON TABLE "civkill" FROM "mahuja";
GRANT ALL ON TABLE "civkill" TO "mahuja";
GRANT SELECT,INSERT,UPDATE ON TABLE "civkill" TO "bstats_auto";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "civkill" TO "bstats_admin";


--
-- TOC entry 2198 (class 0 OID 0)
-- Dependencies: 190
-- Name: death; Type: ACL; Schema: event; Owner: mahuja
--

REVOKE ALL ON TABLE "death" FROM PUBLIC;
REVOKE ALL ON TABLE "death" FROM "mahuja";
GRANT ALL ON TABLE "death" TO "mahuja";
GRANT SELECT,INSERT,UPDATE ON TABLE "death" TO "bstats_auto";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "death" TO "bstats_admin";


--
-- TOC entry 2200 (class 0 OID 0)
-- Dependencies: 181
-- Name: event_eventid_seq; Type: ACL; Schema: event; Owner: mahuja
--

REVOKE ALL ON SEQUENCE "event_eventid_seq" FROM PUBLIC;
REVOKE ALL ON SEQUENCE "event_eventid_seq" FROM "mahuja";
GRANT ALL ON SEQUENCE "event_eventid_seq" TO "mahuja";
GRANT ALL ON SEQUENCE "event_eventid_seq" TO "bstats_auto";
GRANT ALL ON SEQUENCE "event_eventid_seq" TO "bstats_admin";


--
-- TOC entry 2201 (class 0 OID 0)
-- Dependencies: 185
-- Name: inf_inf_kill; Type: ACL; Schema: event; Owner: mahuja
--

REVOKE ALL ON TABLE "inf_inf_kill" FROM PUBLIC;
REVOKE ALL ON TABLE "inf_inf_kill" FROM "mahuja";
GRANT ALL ON TABLE "inf_inf_kill" TO "mahuja";
GRANT SELECT,INSERT,UPDATE ON TABLE "inf_inf_kill" TO "bstats_auto";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "inf_inf_kill" TO "bstats_admin";


--
-- TOC entry 2202 (class 0 OID 0)
-- Dependencies: 186
-- Name: inf_veh_kill; Type: ACL; Schema: event; Owner: mahuja
--

REVOKE ALL ON TABLE "inf_veh_kill" FROM PUBLIC;
REVOKE ALL ON TABLE "inf_veh_kill" FROM "mahuja";
GRANT ALL ON TABLE "inf_veh_kill" TO "mahuja";
GRANT SELECT,INSERT,UPDATE ON TABLE "inf_veh_kill" TO "bstats_auto";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "inf_veh_kill" TO "bstats_admin";


--
-- TOC entry 2203 (class 0 OID 0)
-- Dependencies: 189
-- Name: kill_assist; Type: ACL; Schema: event; Owner: mahuja
--

REVOKE ALL ON TABLE "kill_assist" FROM PUBLIC;
REVOKE ALL ON TABLE "kill_assist" FROM "mahuja";
GRANT ALL ON TABLE "kill_assist" TO "mahuja";
GRANT SELECT,INSERT,UPDATE ON TABLE "kill_assist" TO "bstats_auto";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "kill_assist" TO "bstats_admin";


--
-- TOC entry 2204 (class 0 OID 0)
-- Dependencies: 194
-- Name: roadkill; Type: ACL; Schema: event; Owner: mahuja
--

REVOKE ALL ON TABLE "roadkill" FROM PUBLIC;
REVOKE ALL ON TABLE "roadkill" FROM "mahuja";
GRANT ALL ON TABLE "roadkill" TO "mahuja";
GRANT SELECT,INSERT,UPDATE ON TABLE "roadkill" TO "bstats_auto";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "roadkill" TO "bstats_admin";


--
-- TOC entry 2205 (class 0 OID 0)
-- Dependencies: 192
-- Name: teamkill; Type: ACL; Schema: event; Owner: mahuja
--

REVOKE ALL ON TABLE "teamkill" FROM PUBLIC;
REVOKE ALL ON TABLE "teamkill" FROM "mahuja";
GRANT ALL ON TABLE "teamkill" TO "mahuja";
GRANT SELECT,INSERT,UPDATE ON TABLE "teamkill" TO "bstats_auto";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "teamkill" TO "bstats_admin";


--
-- TOC entry 2206 (class 0 OID 0)
-- Dependencies: 196
-- Name: transport; Type: ACL; Schema: event; Owner: mahuja
--

REVOKE ALL ON TABLE "transport" FROM PUBLIC;
REVOKE ALL ON TABLE "transport" FROM "mahuja";
GRANT ALL ON TABLE "transport" TO "mahuja";
GRANT SELECT,INSERT,UPDATE ON TABLE "transport" TO "bstats_auto";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "transport" TO "bstats_admin";


--
-- TOC entry 2207 (class 0 OID 0)
-- Dependencies: 187
-- Name: veh_inf_kill; Type: ACL; Schema: event; Owner: mahuja
--

REVOKE ALL ON TABLE "veh_inf_kill" FROM PUBLIC;
REVOKE ALL ON TABLE "veh_inf_kill" FROM "mahuja";
GRANT ALL ON TABLE "veh_inf_kill" TO "mahuja";
GRANT SELECT,INSERT,UPDATE ON TABLE "veh_inf_kill" TO "bstats_auto";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "veh_inf_kill" TO "bstats_admin";


--
-- TOC entry 2208 (class 0 OID 0)
-- Dependencies: 188
-- Name: veh_veh_kill; Type: ACL; Schema: event; Owner: mahuja
--

REVOKE ALL ON TABLE "veh_veh_kill" FROM PUBLIC;
REVOKE ALL ON TABLE "veh_veh_kill" FROM "mahuja";
GRANT ALL ON TABLE "veh_veh_kill" TO "mahuja";
GRANT SELECT,INSERT,UPDATE ON TABLE "veh_veh_kill" TO "bstats_auto";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "veh_veh_kill" TO "bstats_admin";


--
-- TOC entry 2209 (class 0 OID 0)
-- Dependencies: 193
-- Name: zone_capture; Type: ACL; Schema: event; Owner: mahuja
--

REVOKE ALL ON TABLE "zone_capture" FROM PUBLIC;
REVOKE ALL ON TABLE "zone_capture" FROM "mahuja";
GRANT ALL ON TABLE "zone_capture" TO "mahuja";
GRANT SELECT,INSERT,UPDATE ON TABLE "zone_capture" TO "bstats_auto";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "zone_capture" TO "bstats_admin";


SET search_path = "logs", pg_catalog;

--
-- TOC entry 2210 (class 0 OID 0)
-- Dependencies: 204
-- Name: client_errors; Type: ACL; Schema: logs; Owner: mahuja
--

REVOKE ALL ON TABLE "client_errors" FROM PUBLIC;
REVOKE ALL ON TABLE "client_errors" FROM "mahuja";
GRANT ALL ON TABLE "client_errors" TO "mahuja";
GRANT INSERT ON TABLE "client_errors" TO "bstats_auto";


--
-- TOC entry 2212 (class 0 OID 0)
-- Dependencies: 203
-- Name: client_errors_id_seq; Type: ACL; Schema: logs; Owner: mahuja
--

REVOKE ALL ON SEQUENCE "client_errors_id_seq" FROM PUBLIC;
REVOKE ALL ON SEQUENCE "client_errors_id_seq" FROM "mahuja";
GRANT ALL ON SEQUENCE "client_errors_id_seq" TO "mahuja";


SET search_path = "old_queries", pg_catalog;

--
-- TOC entry 2213 (class 0 OID 0)
-- Dependencies: 169
-- Name: page_views_player; Type: ACL; Schema: old_queries; Owner: mahuja
--

REVOKE ALL ON TABLE "page_views_player" FROM PUBLIC;
REVOKE ALL ON TABLE "page_views_player" FROM "mahuja";
GRANT ALL ON TABLE "page_views_player" TO "mahuja";
GRANT SELECT ON TABLE "page_views_player" TO PUBLIC;
GRANT SELECT,INSERT,UPDATE ON TABLE "page_views_player" TO "bstats_auto";


SET search_path = "old_static", pg_catalog;

--
-- TOC entry 2214 (class 0 OID 0)
-- Dependencies: 170
-- Name: classgroups; Type: ACL; Schema: old_static; Owner: mahuja
--

REVOKE ALL ON TABLE "classgroups" FROM PUBLIC;
REVOKE ALL ON TABLE "classgroups" FROM "mahuja";
GRANT ALL ON TABLE "classgroups" TO "mahuja";
GRANT SELECT ON TABLE "classgroups" TO PUBLIC;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "classgroups" TO "bstats_admin";


--
-- TOC entry 2215 (class 0 OID 0)
-- Dependencies: 171
-- Name: classnames; Type: ACL; Schema: old_static; Owner: mahuja
--

REVOKE ALL ON TABLE "classnames" FROM PUBLIC;
REVOKE ALL ON TABLE "classnames" FROM "mahuja";
GRANT ALL ON TABLE "classnames" TO "mahuja";
GRANT SELECT ON TABLE "classnames" TO PUBLIC;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "classnames" TO "bstats_admin";


SET search_path = "player", pg_catalog;

--
-- TOC entry 2216 (class 0 OID 0)
-- Dependencies: 173
-- Name: player; Type: ACL; Schema: player; Owner: mahuja
--

REVOKE ALL ON TABLE "player" FROM PUBLIC;
REVOKE ALL ON TABLE "player" FROM "mahuja";
GRANT ALL ON TABLE "player" TO "mahuja";
GRANT SELECT,INSERT,UPDATE ON TABLE "player" TO "bstats_auto";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "player" TO "bstats_admin";
GRANT SELECT ON TABLE "player" TO "bstats_reader";


--
-- TOC entry 2218 (class 0 OID 0)
-- Dependencies: 172
-- Name: playerlist_id_seq; Type: ACL; Schema: player; Owner: mahuja
--

REVOKE ALL ON SEQUENCE "playerlist_id_seq" FROM PUBLIC;
REVOKE ALL ON SEQUENCE "playerlist_id_seq" FROM "mahuja";
GRANT ALL ON SEQUENCE "playerlist_id_seq" TO "mahuja";
GRANT USAGE ON SEQUENCE "playerlist_id_seq" TO "bstats_auto";


SET search_path = "session", pg_catalog;

--
-- TOC entry 2220 (class 0 OID 0)
-- Dependencies: 198
-- Name: errorlog; Type: ACL; Schema: session; Owner: mahuja
--

REVOKE ALL ON TABLE "errorlog" FROM PUBLIC;
REVOKE ALL ON TABLE "errorlog" FROM "mahuja";
GRANT ALL ON TABLE "errorlog" TO "mahuja";
GRANT SELECT,INSERT,UPDATE ON TABLE "errorlog" TO "bstats_auto";


--
-- TOC entry 2222 (class 0 OID 0)
-- Dependencies: 197
-- Name: errorlog_errorid_seq; Type: ACL; Schema: session; Owner: mahuja
--

REVOKE ALL ON SEQUENCE "errorlog_errorid_seq" FROM PUBLIC;
REVOKE ALL ON SEQUENCE "errorlog_errorid_seq" FROM "mahuja";
GRANT ALL ON SEQUENCE "errorlog_errorid_seq" TO "mahuja";
GRANT SELECT,UPDATE ON SEQUENCE "errorlog_errorid_seq" TO "bstats_auto";


--
-- TOC entry 2223 (class 0 OID 0)
-- Dependencies: 178
-- Name: serverlist; Type: ACL; Schema: session; Owner: mahuja
--

REVOKE ALL ON TABLE "serverlist" FROM PUBLIC;
REVOKE ALL ON TABLE "serverlist" FROM "mahuja";
GRANT ALL ON TABLE "serverlist" TO "mahuja";
GRANT SELECT,INSERT,UPDATE ON TABLE "serverlist" TO "bstats_auto";


--
-- TOC entry 2225 (class 0 OID 0)
-- Dependencies: 177
-- Name: serverlist_id_seq; Type: ACL; Schema: session; Owner: mahuja
--

REVOKE ALL ON SEQUENCE "serverlist_id_seq" FROM PUBLIC;
REVOKE ALL ON SEQUENCE "serverlist_id_seq" FROM "mahuja";
GRANT ALL ON SEQUENCE "serverlist_id_seq" TO "mahuja";
GRANT SELECT,UPDATE ON SEQUENCE "serverlist_id_seq" TO "bstats_auto";


--
-- TOC entry 2226 (class 0 OID 0)
-- Dependencies: 175
-- Name: session; Type: ACL; Schema: session; Owner: mahuja
--

REVOKE ALL ON TABLE "session" FROM PUBLIC;
REVOKE ALL ON TABLE "session" FROM "mahuja";
GRANT ALL ON TABLE "session" TO "mahuja";
GRANT SELECT,INSERT,UPDATE ON TABLE "session" TO "bstats_auto";


--
-- TOC entry 2228 (class 0 OID 0)
-- Dependencies: 174
-- Name: session_id_seq; Type: ACL; Schema: session; Owner: mahuja
--

REVOKE ALL ON SEQUENCE "session_id_seq" FROM PUBLIC;
REVOKE ALL ON SEQUENCE "session_id_seq" FROM "mahuja";
GRANT ALL ON SEQUENCE "session_id_seq" TO "mahuja";
GRANT SELECT,UPDATE ON SEQUENCE "session_id_seq" TO "bstats_auto";


--
-- TOC entry 2229 (class 0 OID 0)
-- Dependencies: 176
-- Name: sessionplayers; Type: ACL; Schema: session; Owner: mahuja
--

REVOKE ALL ON TABLE "sessionplayers" FROM PUBLIC;
REVOKE ALL ON TABLE "sessionplayers" FROM "mahuja";
GRANT ALL ON TABLE "sessionplayers" TO "mahuja";
GRANT SELECT,INSERT,UPDATE ON TABLE "sessionplayers" TO "bstats_auto";


--
-- TOC entry 2231 (class 0 OID 0)
-- Dependencies: 179
-- Name: sessionplayers_id_seq; Type: ACL; Schema: session; Owner: mahuja
--

REVOKE ALL ON SEQUENCE "sessionplayers_id_seq" FROM PUBLIC;
REVOKE ALL ON SEQUENCE "sessionplayers_id_seq" FROM "mahuja";
GRANT ALL ON SEQUENCE "sessionplayers_id_seq" TO "mahuja";
GRANT SELECT,UPDATE ON SEQUENCE "sessionplayers_id_seq" TO "bstats_auto";


SET search_path = "event", pg_catalog;

--
-- TOC entry 1591 (class 826 OID 17150)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: event; Owner: mahuja
--

ALTER DEFAULT PRIVILEGES FOR ROLE "mahuja" IN SCHEMA "event" REVOKE ALL ON SEQUENCES  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE "mahuja" IN SCHEMA "event" REVOKE ALL ON SEQUENCES  FROM "mahuja";
ALTER DEFAULT PRIVILEGES FOR ROLE "mahuja" IN SCHEMA "event" GRANT ALL ON SEQUENCES  TO "bstats_auto";


--
-- TOC entry 1590 (class 826 OID 17149)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: event; Owner: mahuja
--

ALTER DEFAULT PRIVILEGES FOR ROLE "mahuja" IN SCHEMA "event" REVOKE ALL ON TABLES  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE "mahuja" IN SCHEMA "event" REVOKE ALL ON TABLES  FROM "mahuja";
ALTER DEFAULT PRIVILEGES FOR ROLE "mahuja" IN SCHEMA "event" GRANT INSERT ON TABLES  TO "bstats_auto";
ALTER DEFAULT PRIVILEGES FOR ROLE "mahuja" IN SCHEMA "event" GRANT SELECT ON TABLES  TO "bstats_reader";


SET search_path = "old_queries", pg_catalog;

--
-- TOC entry 1586 (class 826 OID 16575)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: old_queries; Owner: mahuja
--

ALTER DEFAULT PRIVILEGES FOR ROLE "mahuja" IN SCHEMA "old_queries" REVOKE ALL ON FUNCTIONS  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE "mahuja" IN SCHEMA "old_queries" REVOKE ALL ON FUNCTIONS  FROM "mahuja";
ALTER DEFAULT PRIVILEGES FOR ROLE "mahuja" IN SCHEMA "old_queries" GRANT ALL ON FUNCTIONS  TO "bstats_reader";


--
-- TOC entry 1587 (class 826 OID 16576)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: old_queries; Owner: mahuja
--

ALTER DEFAULT PRIVILEGES FOR ROLE "mahuja" IN SCHEMA "old_queries" REVOKE ALL ON TABLES  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE "mahuja" IN SCHEMA "old_queries" REVOKE ALL ON TABLES  FROM "mahuja";
ALTER DEFAULT PRIVILEGES FOR ROLE "mahuja" IN SCHEMA "old_queries" GRANT SELECT ON TABLES  TO PUBLIC;


SET search_path = "old_static", pg_catalog;

--
-- TOC entry 1588 (class 826 OID 16578)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: old_static; Owner: mahuja
--

ALTER DEFAULT PRIVILEGES FOR ROLE "mahuja" IN SCHEMA "old_static" REVOKE ALL ON TABLES  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE "mahuja" IN SCHEMA "old_static" REVOKE ALL ON TABLES  FROM "mahuja";
ALTER DEFAULT PRIVILEGES FOR ROLE "mahuja" IN SCHEMA "old_static" GRANT SELECT ON TABLES  TO PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE "mahuja" IN SCHEMA "old_static" GRANT SELECT,INSERT,DELETE,UPDATE ON TABLES  TO "bstats_admin";


SET search_path = "server", pg_catalog;

--
-- TOC entry 1589 (class 826 OID 16962)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: server; Owner: mahuja
--

ALTER DEFAULT PRIVILEGES FOR ROLE "mahuja" IN SCHEMA "server" REVOKE ALL ON FUNCTIONS  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE "mahuja" IN SCHEMA "server" REVOKE ALL ON FUNCTIONS  FROM "mahuja";
ALTER DEFAULT PRIVILEGES FOR ROLE "mahuja" IN SCHEMA "server" GRANT ALL ON FUNCTIONS  TO "bstats_servers";


SET search_path = "session", pg_catalog;

--
-- TOC entry 1592 (class 826 OID 17151)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: session; Owner: mahuja
--

ALTER DEFAULT PRIVILEGES FOR ROLE "mahuja" IN SCHEMA "session" REVOKE ALL ON TABLES  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE "mahuja" IN SCHEMA "session" REVOKE ALL ON TABLES  FROM "mahuja";
ALTER DEFAULT PRIVILEGES FOR ROLE "mahuja" IN SCHEMA "session" GRANT SELECT,INSERT,UPDATE ON TABLES  TO "bstats_auto";
ALTER DEFAULT PRIVILEGES FOR ROLE "mahuja" IN SCHEMA "session" GRANT SELECT ON TABLES  TO "bstats_reader";


-- Completed on 2014-05-07 12:57:36

--
-- PostgreSQL database dump complete
--

