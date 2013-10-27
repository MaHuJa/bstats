#include "stdafx.h"
#include "dbthread.h"

void dbthread::connectloop() {	
	while (!conn.is_connected()) {
		logfile << "Connect error: " << conn.error_message();
		std::this_thread::sleep_for(std::chrono::seconds(conn.retries));
		conn.reconnect();
	}
}
void dbthread::run() {
	std::string s;
	{
		std::ifstream infile ("conninfo");
		if (!infile.is_open()) { 
			logfile << "Can't connect to db: File conninfo does not exist!\n"; 
			return; 
		}
		std::getline (infile,s); 
	}

	conn.connect(s);
	connectloop();

	while (running) {
		string s = grab_cmd();
		if (s.empty()) continue;	// Running is false, or caller sent blank string
		paramlist p = split(s);
		assert (!p.empty());
		for (auto& it : p) it = escapestring(it);
		std::ostringstream cmd;
		// newsession is a special case because we need to react to its return value
		if (p[0]=="newsession1") { // TODO support any newer version
			if (p.size()<2) {
				send_error("Newsession missing parameter",s);
				throw std::invalid_argument("Missing parameter");
			}
			cmd << "SELECT " << std::move(p[0]) << '(' 
				<< sessionid << ',' // previous session id
				<< std::move(p[1]) << ");";
			auto r = conn.exec(cmd.str());
			if (r.failed()) { send_error(conn.error_message(),s); }
			s = r.get_single_value();
			std::istringstream is(s); is >> sessionid;	// aka lexical_cast
			// todo consider better checking
		} else {
			// Normal case
			cmd << "PERFORM " << std::move(p[0]) << '(' << sessionid;
			for (auto it = p.begin()+1; it<p.end(); it++) {
				cmd << ',' << std::move(*it);
			}
			cmd << ");";
			auto r = conn.exec(cmd.str());
			if (r.failed()) { send_error(conn.error_message(),s); }

		}
		// todo check how this works with the database disconnecting
	}
}

void dbthread::sendquery (std::string s) {
	guard g(qm);
	q.push_back(std::move(s));
};
dbthread::~dbthread() {
	running = false;
	if (my_thread.joinable()) my_thread.join();
}
std::string dbthread::escapestring (std::string in) {
	return conn.escapestring(in);
}
std::string dbthread::grab_cmd () {
	string s;
	bool is_empty = false;
	do {
		if (!running) return s;
		if (is_empty) { // was empty last try, putting us here right away
			std::this_thread::sleep_for(std::chrono::milliseconds(500));
		}
		guard g(qm);
		if (q.empty()) { 
			is_empty = true;
		} else {
			is_empty = false;
			s = q.front();
			q.pop_front();
		}
	} while (is_empty);
	return s;
}
dbthread::paramlist dbthread::split(string) {
	throw std::exception("not implemented");	//todo
}
void dbthread::send_error(string msg, string input) {
	throw std::exception("not implemented");	// todo
}

