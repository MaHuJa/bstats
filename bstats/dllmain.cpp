// dllmain.cpp : Defines the entry point for the DLL application.
#include "stdafx.h"
#include "dbthread.h"

std::ofstream logfile("bstats_log");
dbthread db;

BOOL APIENTRY DllMain(HMODULE hModule,
	DWORD  ul_reason_for_call,
	LPVOID lpReserved
	)
{
	hModule, lpReserved;	// silence "unreferenced"

	switch (ul_reason_for_call)
	{
	case DLL_PROCESS_ATTACH:
		logfile << "PROCESS_ATTACH" << std::endl;
		break;
	case DLL_THREAD_ATTACH:
		logfile << "THREAD_ATTACH" << std::endl;
		break;
	case DLL_THREAD_DETACH:
		logfile << "THREAD_DETACH" << std::endl;
		break;
	case DLL_PROCESS_DETACH:
		logfile << "PROCESS_DETACH" << std::endl;
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
	function, outputSize;	// ignore
	assert(outputSize > 200);
	db.sendquery(function);
	// TODO: Proper feedback
	output[0] = '1';
	output[1] = 0;
}

//*/


