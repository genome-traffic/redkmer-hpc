#include <map>
#include <string>
#include <sstream>
#include <fstream>
#include <iostream>

using namespace std;

int main( int argc, char **argv ){

  if( argc < 1) {
		std::cout << "Syntax: " <<argv[0] << " input-file-list" << endl;
		exit(1);
	}

	map<std::string, int> map;

	for( int i=1; i<argc; i++ ) {
	  std::ifstream fin( argv[i] );
  	std::string line;
  	while( std::getline( fin, line )) {
			map[line]++;
		}
		fin.close();
	}

	for( const auto &pair : map ) {
		cout << pair.first << " " << pair.second << endl;
	}
}
