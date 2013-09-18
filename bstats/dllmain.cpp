// dllmain.cpp : Defines the entry point for the DLL application.
#include "stdafx.h"

PGconn* conn;
std::ofstream logfile("bstats_log");

BOOL APIENTRY DllMain( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
					 )
{
	hModule,lpReserved;	// silence "unreferenced"
	
	switch (ul_reason_for_call)
	{
	case DLL_PROCESS_ATTACH:
		logfile << "PROCESS_ATTACH" << std::endl;
		// This should only happen once each time the server starts, so I'll try to leave it sync
		conn = PQconnectdb("host=playground.mahuja.net dbname=postgres user=mahuja password=xxxxxxxx");
		break;
   	case DLL_THREAD_ATTACH:
		logfile << "THREAD_ATTACH" << std::endl;
		break;
	case DLL_THREAD_DETACH:
		logfile << "THREAD_DETACH" << std::endl;
		break;
	case DLL_PROCESS_DETACH:
		logfile << "PROCESS_DETACH" << std::endl;
		PQfinish(conn);
		break;
	}
	return TRUE;
}

extern "C" 
{
  __declspec(dllexport) void __stdcall RVExtension(char *output, int outputSize, const char *function); 
};

using namespace std;


void __stdcall RVExtension(char *output, int outputSize, const char *function)
{
	function,outputSize;	// ignore
	assert(outputSize>200);
	ofstream outfile("bstats_log");
	if (PQstatus(conn) != CONNECTION_OK) {
		outfile << "Failed: " << PQerrorMessage(conn);
		strcpy(output,PQerrorMessage(conn));
	}
	else { outfile << "Success"; output[0]='a'; }

}

//*/


