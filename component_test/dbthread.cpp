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
		std::string s;
		bool is_empty = false;
		do {
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
		}
		while (is_empty);
		// todo: transform
		conn.exec(s);	// todo: check result; possibly log error to database, deal with database disconnecting
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

