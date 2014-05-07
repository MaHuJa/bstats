--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.13
-- Dumped by pg_dump version 9.3.1
-- Started on 2014-05-07 15:26:18

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = event, pg_catalog;

--
-- TOC entry 2189 (class 0 OID 16881)
-- Dependencies: 191
-- Data for Name: ac_crash; Type: TABLE DATA; Schema: event; Owner: mahuja
--

COPY ac_crash (eventid, message, session, "time", player, points, "position", passengers, vehicle) FROM stdin;
\.


--
-- TOC entry 2193 (class 0 OID 16929)
-- Dependencies: 195
-- Data for Name: civkill; Type: TABLE DATA; Schema: event; Owner: mahuja
--

COPY civkill (eventid, message, session, "time", player, points, "position", victim, victim_position, weapon, damage_only) FROM stdin;
\.


--
-- TOC entry 2188 (class 0 OID 16871)
-- Dependencies: 190
-- Data for Name: death; Type: TABLE DATA; Schema: event; Owner: mahuja
--

COPY death (eventid, message, session, "time", player, points, "position", is_suicide) FROM stdin;
\.


SET search_path = session, pg_catalog;

--
-- TOC entry 2176 (class 0 OID 16637)
-- Dependencies: 178
-- Data for Name: serverlist; Type: TABLE DATA; Schema: session; Owner: mahuja
--

COPY serverlist (id, name, address) FROM stdin;
1	testserv	\N
2	mahuja	\N
\.


--
-- TOC entry 2173 (class 0 OID 16623)
-- Dependencies: 175
-- Data for Name: session; Type: TABLE DATA; Schema: session; Owner: mahuja
--

COPY session (id, missionname, result, server, duration) FROM stdin;
8	Manual test	\N	2	\N
9	Manual test	\N	2	\N
10	Manual test	\N	2	\N
14	Manual test	\N	1	\N
15	HELLO WORLD!!!11one	\N	1	\N
16	HELLO WORLD!!!11one	\N	1	\N
17	HELLO WORLD!!!11one	\N	1	\N
18	HELLO WORLD!!!11one	\N	1	\N
19	HELLO WORLD!!!11one	\N	1	\N
20	HELLO WORLD!!!11one	\N	1	\N
21	HELLO WORLD!!!11one	\N	1	\N
22	HELLO WORLD!!!11one	\N	1	\N
23	HELLO WORLD!!!11one	\N	1	\N
24	HELLO WORLD!!!11one	\N	1	\N
25	HELLO WORLD!!!11one	\N	1	\N
26	HELLO WORLD!!!11one	\N	1	\N
27	HELLO WORLD!!!11one	\N	1	\N
28	HELLO WORLD!!!11one	\N	1	\N
29	HELLO WORLD!!!11one	\N	1	\N
30	HELLO WORLD!!!11one	\N	1	\N
\.


SET search_path = event, pg_catalog;

--
-- TOC entry 2180 (class 0 OID 16765)
-- Dependencies: 182
-- Data for Name: event; Type: TABLE DATA; Schema: event; Owner: mahuja
--

COPY event (eventid, message, session, "time") FROM stdin;
\.


--
-- TOC entry 2206 (class 0 OID 0)
-- Dependencies: 181
-- Name: event_eventid_seq; Type: SEQUENCE SET; Schema: event; Owner: mahuja
--

SELECT pg_catalog.setval('event_eventid_seq', 2, true);


--
-- TOC entry 2183 (class 0 OID 16798)
-- Dependencies: 185
-- Data for Name: inf_inf_kill; Type: TABLE DATA; Schema: event; Owner: mahuja
--

COPY inf_inf_kill (eventid, message, session, "time", player, points, victim, "position", victim_position, weapon) FROM stdin;
2	\N	30	00:00:15	1	10	2	{10,20,0}	{20,10,0}	testweapon
\.


--
-- TOC entry 2184 (class 0 OID 16812)
-- Dependencies: 186
-- Data for Name: inf_veh_kill; Type: TABLE DATA; Schema: event; Owner: mahuja
--

COPY inf_veh_kill (eventid, message, session, "time", player, points, "position", targettype, target_position, target_empty, weapon) FROM stdin;
\.


--
-- TOC entry 2187 (class 0 OID 16853)
-- Dependencies: 189
-- Data for Name: kill_assist; Type: TABLE DATA; Schema: event; Owner: mahuja
--

COPY kill_assist (eventid, message, session, "time", player, points, "position") FROM stdin;
\.


--
-- TOC entry 2181 (class 0 OID 16779)
-- Dependencies: 183
-- Data for Name: playerevent; Type: TABLE DATA; Schema: event; Owner: mahuja
--

COPY playerevent (eventid, message, session, "time", player, "position") FROM stdin;
\.


--
-- TOC entry 2192 (class 0 OID 16919)
-- Dependencies: 194
-- Data for Name: roadkill; Type: TABLE DATA; Schema: event; Owner: mahuja
--

COPY roadkill (eventid, message, session, "time", player, points, "position", victim, victim_position, vehicletype, player_slot) FROM stdin;
\.


--
-- TOC entry 2182 (class 0 OID 16788)
-- Dependencies: 184
-- Data for Name: scoreevent; Type: TABLE DATA; Schema: event; Owner: mahuja
--

COPY scoreevent (eventid, message, session, "time", player, points, "position") FROM stdin;
\.


--
-- TOC entry 2190 (class 0 OID 16891)
-- Dependencies: 192
-- Data for Name: teamkill; Type: TABLE DATA; Schema: event; Owner: mahuja
--

COPY teamkill (eventid, message, session, "time", player, points, "position", victim, victim_position, weapon, damage_only) FROM stdin;
\.


--
-- TOC entry 2194 (class 0 OID 16939)
-- Dependencies: 196
-- Data for Name: transport; Type: TABLE DATA; Schema: event; Owner: mahuja
--

COPY transport (eventid, message, session, "time", player, points, "position", vehicletype, distance) FROM stdin;
\.


--
-- TOC entry 2185 (class 0 OID 16836)
-- Dependencies: 187
-- Data for Name: veh_inf_kill; Type: TABLE DATA; Schema: event; Owner: mahuja
--

COPY veh_inf_kill (eventid, message, session, "time", player, points, "position", victim, victim_position, vehicletype, player_slot) FROM stdin;
\.


--
-- TOC entry 2186 (class 0 OID 16845)
-- Dependencies: 188
-- Data for Name: veh_veh_kill; Type: TABLE DATA; Schema: event; Owner: mahuja
--

COPY veh_veh_kill (eventid, message, session, "time", player, points, "position", targettype, target_position, target_empty, vehicle_type, player_slot) FROM stdin;
\.


--
-- TOC entry 2191 (class 0 OID 16901)
-- Dependencies: 193
-- Data for Name: zone_capture; Type: TABLE DATA; Schema: event; Owner: mahuja
--

COPY zone_capture (eventid, message, session, "time", player, points, "position", zone_name) FROM stdin;
\.


SET search_path = logs, pg_catalog;

--
-- TOC entry 2201 (class 0 OID 17085)
-- Dependencies: 204
-- Data for Name: client_errors; Type: TABLE DATA; Schema: logs; Owner: mahuja
--

COPY client_errors (id, clientname, "timestamp", errormsg, query) FROM stdin;
\.


--
-- TOC entry 2207 (class 0 OID 0)
-- Dependencies: 203
-- Name: client_errors_id_seq; Type: SEQUENCE SET; Schema: logs; Owner: mahuja
--

SELECT pg_catalog.setval('client_errors_id_seq', 1, false);


SET search_path = old_queries, pg_catalog;

--
-- TOC entry 2167 (class 0 OID 16495)
-- Dependencies: 169
-- Data for Name: page_views_player; Type: TABLE DATA; Schema: old_queries; Owner: mahuja
--

COPY page_views_player (playerid, cnt) FROM stdin;
\.


SET search_path = old_static, pg_catalog;

--
-- TOC entry 2168 (class 0 OID 16527)
-- Dependencies: 170
-- Data for Name: classgroups; Type: TABLE DATA; Schema: old_static; Owner: mahuja
--

COPY classgroups (groupname, categories, vorder, worder) FROM stdin;
\.


--
-- TOC entry 2169 (class 0 OID 16533)
-- Dependencies: 171
-- Data for Name: classnames; Type: TABLE DATA; Schema: old_static; Owner: mahuja
--

COPY classnames (classname, displayname, vehiclecategory, weaponcategory) FROM stdin;
\.


SET search_path = player, pg_catalog;

--
-- TOC entry 2171 (class 0 OID 16602)
-- Dependencies: 173
-- Data for Name: player; Type: TABLE DATA; Schema: player; Owner: mahuja
--

COPY player (id, gameuid, first_seen, last_name_seen) FROM stdin;
1	AAA	2014-05-07 12:43:20.965437+02	Testplayer A
2	BBB	2014-05-07 12:50:24.150959+02	Testplayer B
3	CCC	2014-05-07 12:50:24.162682+02	Testplayer C
\.


--
-- TOC entry 2208 (class 0 OID 0)
-- Dependencies: 172
-- Name: playerlist_id_seq; Type: SEQUENCE SET; Schema: player; Owner: mahuja
--

SELECT pg_catalog.setval('playerlist_id_seq', 3, true);


--
-- TOC entry 2178 (class 0 OID 16708)
-- Dependencies: 180
-- Data for Name: playername; Type: TABLE DATA; Schema: player; Owner: mahuja
--

COPY playername (playerid, name, lastseen, firstseen) FROM stdin;
\.


--
-- TOC entry 2197 (class 0 OID 16973)
-- Dependencies: 199
-- Data for Name: playersum; Type: TABLE DATA; Schema: player; Owner: mahuja
--

COPY playersum (playerid, totalscore, battlescore, otherscore, suicides, weaponkills, deaths, aircrashes, roadkills, civcas, civdmg, teamkills, teamdmg, killed_vehicles, tked_vehicles, killassist) FROM stdin;
\.


--
-- TOC entry 2199 (class 0 OID 17048)
-- Dependencies: 202
-- Data for Name: weaponstats; Type: TABLE DATA; Schema: player; Owner: mahuja
--

COPY weaponstats (session, player, class, totalseconds, fired, vehiclehits, headhits, bodyhits, leghits, armhits) FROM stdin;
\.


--
-- TOC entry 2198 (class 0 OID 17033)
-- Dependencies: 201
-- Data for Name: weaponstats_sum; Type: TABLE DATA; Schema: player; Owner: mahuja
--

COPY weaponstats_sum (player, class, totalseconds, fired, vehiclehits, headhits, bodyhits, leghits, armhits, avgdist, avgcnt) FROM stdin;
\.


SET search_path = session, pg_catalog;

--
-- TOC entry 2196 (class 0 OID 16952)
-- Dependencies: 198
-- Data for Name: errorlog; Type: TABLE DATA; Schema: session; Owner: mahuja
--

COPY errorlog (errorid, query, errormessage) FROM stdin;
\.


--
-- TOC entry 2209 (class 0 OID 0)
-- Dependencies: 197
-- Name: errorlog_errorid_seq; Type: SEQUENCE SET; Schema: session; Owner: mahuja
--

SELECT pg_catalog.setval('errorlog_errorid_seq', 1, false);


--
-- TOC entry 2210 (class 0 OID 0)
-- Dependencies: 177
-- Name: serverlist_id_seq; Type: SEQUENCE SET; Schema: session; Owner: mahuja
--

SELECT pg_catalog.setval('serverlist_id_seq', 2, true);


--
-- TOC entry 2211 (class 0 OID 0)
-- Dependencies: 174
-- Name: session_id_seq; Type: SEQUENCE SET; Schema: session; Owner: mahuja
--

SELECT pg_catalog.setval('session_id_seq', 30, true);


--
-- TOC entry 2174 (class 0 OID 16629)
-- Dependencies: 176
-- Data for Name: sessionplayers; Type: TABLE DATA; Schema: session; Owner: mahuja
--

COPY sessionplayers (player, session, side, playername, id, joined, "left") FROM stdin;
1	23	west	Testplayer A	7	00:00:00	\N
1	24	west	Testplayer AA	8	00:00:00	\N
1	25	west	Testplayer A	9	00:00:00	\N
2	25	east	Testplayer B	10	00:00:00	\N
3	25	west	Testplayer C	11	00:00:10	\N
1	26	west	Testplayer A	12	00:00:00	\N
2	26	east	Testplayer B	13	00:00:00	\N
3	26	west	Testplayer C	14	00:00:10	\N
1	27	west	Testplayer A	15	00:00:00	\N
2	27	east	Testplayer B	16	00:00:00	\N
3	27	west	Testplayer C	17	00:00:10	\N
1	28	west	Testplayer A	18	00:00:00	\N
2	28	east	Testplayer B	19	00:00:00	\N
3	28	west	Testplayer C	20	00:00:10	\N
1	29	west	Testplayer A	21	00:00:00	\N
2	29	east	Testplayer B	22	00:00:00	\N
3	29	west	Testplayer C	23	00:00:10	\N
1	30	west	Testplayer A	24	00:00:00	\N
2	30	east	Testplayer B	25	00:00:00	\N
3	30	west	Testplayer C	26	00:00:10	\N
\.


--
-- TOC entry 2212 (class 0 OID 0)
-- Dependencies: 179
-- Name: sessionplayers_id_seq; Type: SEQUENCE SET; Schema: session; Owner: mahuja
--

SELECT pg_catalog.setval('sessionplayers_id_seq', 26, true);


-- Completed on 2014-05-07 15:26:22

--
-- PostgreSQL database dump complete
--

