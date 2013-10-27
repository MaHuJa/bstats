// component_test.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "dbthread.h"

int main(int, char*)
{
	dbthread db;
	db.sendquery("newmission1;HELLO WORLD!!!11one");
	std::this_thread::sleep_for(std::chrono::seconds(5));
	return 0;
}

