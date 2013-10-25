#include "stdafx.h"
#include "pg.h"

#include <libpq-fe.h>

namespace pg {
namespace { 
	PGconn* connection(void* p) { return static_cast<PGconn*>(p); }
	PGresult* result(void* p) { return static_cast<PGresult*>(p); }
}

void Connection::connect(std::string conninfo) {
	conn = PQconnectdb(conninfo.c_str());
}
void Connection::disconnect() {
	PQfinish(connection(conn));
}
std::string Connection::error_message() {
	return PQerrorMessage(connection(conn));
}
bool Connection::is_connected() {
	bool status = PQstatus(connection(conn)) == CONNECTION_OK;
	if (status) retries = 0;
	return status;
}
bool Connection::reconnect() {
	retries++;
	PQreset(connection(conn));
	return is_connected();
}
Result Connection::exec(std::string query) {
	return PQexec(connection(conn),query.c_str());
}
Result::Result(void* p) :res(p) {}
Result::~Result() {
	// I don't seem to need to clear the result of tuples; clear takes care of that.
	PQclear(result(res));
}

std::string Result::get_single_value() {
	PGresult* p = result(res);
	assert(PQntuples(p)==1);
	assert(PQnfields(p)==1);
	assert(PQfformat(p,0)==0);	// is text
	return PQgetvalue(p,0,0);
}




}// namespace
