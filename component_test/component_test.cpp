// component_test.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "dbthread.h"

int main(int, char*)
{
	dbthread db;
	db.sendquery("newmission1;HELLO WORLD!!!11one");

	return 0;
}

