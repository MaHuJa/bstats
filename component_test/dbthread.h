#pragma once
#include "pg.h"
#include "logging.h"

class dbthread { 
	pg::Connection conn;
	std::thread my_thread;
	std::deque<std::string> q; std::mutex qm;
	typedef std::lock_guard<std::mutex> guard;
	bool running;
	void run();
	void connectloop();
public:
	dbthread() : my_thread(&dbthread::run,this), running(true) {}
	~dbthread();
	bool is_online();
	void sendquery(std::string s);
};

