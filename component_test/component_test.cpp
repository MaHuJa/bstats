// component_test.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <libpq-fe.h>



int main(int argc, char* argv[])
{
	PGconn* conn = PQconnectdb("host=playground.mahuja.net dbname=postgres user=mahuja password=xxxxxxxx");
    if (PQstatus(conn) != CONNECTION_OK) {
		std::cout << "Connection failed: " << PQerrorMessage(conn);
    } else {
		std::cout << "Success!";
	}
	PQfinish(conn);
	return 0;
}

