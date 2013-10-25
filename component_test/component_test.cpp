// component_test.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "dbthread.h"

#include "logging.h"
Logfile logfile;

int main(int, char*)
{
	dbthread db;
	db.sendquery("create table DELETEME;");

	return 0;
}

