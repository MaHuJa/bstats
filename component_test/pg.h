#pragma once

namespace pg {

class Result;
class Connection {
	void* conn;
public:
	int retries;
	bool reconnect();
public:
	void connect(std::string conninfo);
	void disconnect();
	Result exec(std::string query);
	bool is_connected();
	std::string error_message();

	Connection() : conn(nullptr), retries(0) {}
	Connection(std::string conninfo) : conn(nullptr), retries(0) 
		{ connect(conninfo); }
	~Connection() {disconnect();}
};

class Result {
	void* res;
public:
	std::string get_single_value();
	Result(void*);
	~Result();

};

} //namespace
