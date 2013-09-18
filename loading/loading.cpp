// loading.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"

typedef void (*rve) (char*, int, const char*);


int main(int argc, char* argv[])
{
	HMODULE m = LoadLibraryA("..\\Release\\bstats.dll");
	if (!m) { std::cout << "LoadLibraryA failed\n";	goto end; }
	rve foo = reinterpret_cast<rve>(GetProcAddress(m,"RVExtension"));
	if (!foo) { std::cout << "No RVExtension()\n"; goto end; }
	char buf[256];
	foo (buf,256,"*");
	std::cout << buf;
end:
	return 0;
}

