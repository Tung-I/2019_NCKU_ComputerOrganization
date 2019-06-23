#include <vector>
#include <iostream>
#include <fstream>
#include <string.h>
#include <stdio.h>
#include "cache.h"
using namespace std;

vector<int> hex2bi(string s){
	vector<int> v;
	v.assign(32, 0);
	for(int i=2;i<10;++i){
		int decimal = 0;
		if(s.at(i)=='a' || s.at(i)=='b' || s.at(i)=='c' || s.at(i)=='d' || s.at(i)=='e' || s.at(i)=='f'){
			decimal = (int)s.at(i)-87;
		}
		else decimal = (int)s.at(i)-48;

		int idx = (10-i)*4;
		if(decimal>=8){
			decimal-=8;
			v.at(--idx) = 1;
		}
		else v.at(--idx) = 0;
		if(decimal>=4){
			decimal-=4;
			v.at(--idx) = 1;
		}
		else v.at(--idx) = 0;
		if(decimal>=2){
			decimal-=2;
			v.at(--idx) = 1;
		}
		else v.at(--idx) = 0;
		if(decimal==1){
			decimal-=1;
			v.at(--idx) = 1;
		}
		else v.at(--idx) = 0;
	}
	return v;
}

// int bi2dec(vector<int> v){
// 	int sum = 0;
// 	for(int i=0;i<v.size();++i){
// 		if(v.at(i)==1)sum+=pow(2, i);
// 	}
// 	return sum;
// }

int main(int argc, char *argv[]){
	int cacheSize, blockSize, associateNum, policyNum;

	ifstream inFile(argv[1], ios::in);
	if(!inFile){
		cerr<<"fail opening reading file"<<endl;
		exit(1);
	}

	ofstream outFile(argv[2], ios::out);
	if(!outFile){
		cerr<<"fail opening writting file"<<endl;
		exit(1);
	}

	inFile>>cacheSize;
	inFile>>blockSize;
	inFile>>associateNum;
	inFile>>policyNum;

	Cache *myCache = new Cache(cacheSize, blockSize, associateNum, policyNum);

	string addr;
	while(inFile>>addr){
		vector<int> v;
		v = hex2bi(addr);

		// cout<<"///////////////////////////"<<endl;
		// for(int i=0;i<v.size();++i){
		// 	cout<<v.at(31-i)<<" ";
		// 	if(i==11||i==27)cout<<" ";
		// }
		// cout<<endl;
		// cout<<"///////////////////////////"<<endl;
		
		bool result;
		if(policyNum==0){	//FIFO
			result = myCache->cacheWriteFIFO(v);
		}
		else if(policyNum==2){	//my policy
			result = myCache->cacheWriteMyself(v);
		}
		else{	//LRU
			result = myCache->cacheWriteLRU(v);
		}

		// if(!result)cout<<-1<<endl;
		// else{
		// 	vector<int> outputTag = myCache->getVictimTag();
		// 	for(int i=outputTag.size()-1;i>=0;--i){
		// 		cout<<outputTag.at(i)<<" ";
		// 	}
		// 	cout<<endl;
		// }

		if(!result)outFile<<-1<<endl;
		else{
			int outputTag = bi2dec(myCache->getVictimTag());
			outFile<<outputTag<<endl;;
		}
	}
	


	// Cache c = Cache(cacheSize, blockSize, associateNum, policyNum);

	// vector<int> v1, v2;
	// v1.assign(12, 1);
	// v1.at(1) = 0;
	// v1.at(2) = 0;
	// v2.assign(12, 1);
	// v2.at(0) = 0;
	
	// c.getSet(0).getEntry(0).writeTag(v1);
	// c.getSet(1).getEntry(0).writeTag(v2);
	// c.debug(0);
	// c.debug(1);

	



	return 0;
}