// loading.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"

typedef void (__stdcall *rve) (char*, int, const char*);

int main(int argc, char* argv[])
{
	HMODULE m = LoadLibraryA(
#ifdef _DEBUG
		"..\\Debug\\bstats.dll"
#else
		"..\\Release\\bstats.dll"
#endif
	);
	if (!m) { std::cout << "LoadLibraryA failed\n";	return 1; }
	rve foo = reinterpret_cast<rve>(GetProcAddress(m,"_RVExtension@12"));
	if (!foo) { std::cout << "No RVExtension()\n"; return 2; }
	char buf[256];
	foo (buf,256,"newmission1;HELLO WORLD!!!11one");
	std::cout << buf;
	__asm nop;
	std::this_thread::sleep_for(std::chrono::seconds(10));
	return 0;
}

