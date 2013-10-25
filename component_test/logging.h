#pragma once

class Logfile {
public:
	template <class T>
	Logfile& operator<< (T t) { std::cout << t; return *this; }
};

extern Logfile logfile;
