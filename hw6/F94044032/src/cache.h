#include <vector>
#include <string.h>
#include <stdio.h>
#include <math.h>
using namespace std;

void printVector(const vector<int> &v){
	for(int i=v.size()-1;i>=0;--i){
		cout<<v.at(i)<<" ";
	}
	cout<<endl;
	return;
}

int bi2dec(const vector<int> &v){
	int sum = 0;
	for(int i=0;i<v.size();++i){
		if(v.at(i)==1)sum+=pow(2, i);
	}
	return sum;
}

class CacheEntry{
public:
	CacheEntry(int t):counter(-1), timeLabel(-1){
		tagBits.assign(t, -1);
	}

	void writeTag(const vector<int> &t){
		tagBits = t;
	}
	vector<int> getTag(){return tagBits;}

	void writeTimeLabel(int t){timeLabel = t;}
	int getTimeLabel(){return timeLabel;}

	void resetCounter(){counter = 0;}
	void addCounter(){counter++;}
	int getCounter(){return counter;}

	bool isNew(){return (tagBits.at(0)==-1);}


private:
	int counter;
	int timeLabel;
	vector<int> tagBits; 
};




class CacheSet{
public:
	CacheSet(int t, int n):tagLength(t), entryNum(n){
		for(int i=0;i<entryNum;++i){
			CacheEntry *temp = new CacheEntry(tagLength); 
			entries.push_back(temp);
		}
	}

	CacheEntry *getEntry(int n){
		return entries.at(n);
	}

	bool findSameTag(const vector<int> &tag){
		for(int i=0;i<entryNum;++i){
			if(entries.at(i)->getTag()==tag){
				hitEntryId = i;
				return true;
			}
		}
		hitEntryId = -1;
		return false;
	}

	int getEmptyId(){
		for(int i=0;i<entries.size();++i){
			if(entries.at(i)->isNew())return i;
		}
		return -1;
	}

	int getLeastCntId(){
		int idx = 0;
		for(int i=0;i<entries.size();++i){
			if(entries.at(i)->getCounter() < entries.at(idx)->getCounter())
				idx = i;
		}
		return idx;
	}
	void addAll(){
		for(int i=0;i<entries.size();++i){
			entries.at(i)->addCounter();
		}
	}
	void resetOneCounter(int id){
		entries.at(id)->resetCounter();
	}

	int getLeastLabelId(){
		int idx = 0;
		for(int i=1;i<entries.size();++i){
			if(entries.at(i)->getTimeLabel() < entries.at(idx)->getTimeLabel())
				idx = i;
		}
		return idx;
	}
	int getSecondLabelId(){
		int idx1 = 0, idx2 = 0;
		for(int i=1;i<entries.size();++i){
			if(entries.at(i)->getTimeLabel() < entries.at(idx1)->getTimeLabel()){
				idx2 = idx1;
				idx1 = i;
			}
		}
		return idx2;
	}

	int getHitEntryId(){return hitEntryId;}

private:
	int tagLength;
	int entryNum;
	vector<CacheEntry*> entries;

	int hitEntryId;
};



class Cache{
public:
	Cache(int c=1024, int b=16, int a=0, int p=0):cacheSize(c), blockSize(b), associativity(a), policy(p){
		//calculate bits
		blockNum = cacheSize*1024/blockSize;
		if(associativity==0){	//direct-mapped
			setNum = blockNum;
			entryPerSet = 1;
		}
		else if(associativity==1){	//4-way associative
			setNum = blockNum/4;
			entryPerSet = 4;
		}
		else{ 	//fully associative
			setNum = 1;
			entryPerSet = blockNum;
		}

		int WO = (blockSize<4)?0:(int)(log(blockSize/4)/log(2) + 0.5);
		indexLength = (setNum==1)?0:(int)(log(setNum)/log(2) + 0.5);
		tagLength = 32-2-WO-indexLength;

		//initialize CacheSet
		for(int i=0;i<setNum;++i){
			CacheSet *temp = new CacheSet(tagLength, entryPerSet);
			sets.push_back(temp);
		}

		//intialize timeCnt & victimTag
		timeCnt = 0;
		victimTag.assign(tagLength, -1);
	}

	vector<int> &getVictimTag(){return victimTag;}

	bool cacheWriteFIFO(vector<int> addr){
		//read the address
		vector<int> tag, index;
		int setId;	//index in decimal

		tag.assign(tagLength, 0);
		for(int i=0;i<tagLength;++i){
			tag.at(i) = addr.at(32-tagLength+i);
		}

		if(indexLength!=0){
			index.assign(indexLength, 0);
			for(int i=0;i<indexLength;++i){
				index.at(i) = addr.at(32-tagLength-indexLength+i);
			}
			setId = bi2dec(index);
		}
		else{
			setId = 0;
		}

		//hit or not
		bool findOrNot = sets.at(setId)->findSameTag(tag);

		if(!findOrNot){    //if not hit
			int emptyId = sets.at(setId)->getEmptyId();
			if(emptyId!=-1){	//if has empty entry
				sets.at(setId)->getEntry(emptyId)->writeTag(tag);
				sets.at(setId)->getEntry(emptyId)->writeTimeLabel(timeCnt++);
				return false;
			}
			else{	//if no empty entry
				int victimEntryId = sets.at(setId)->getLeastLabelId();	//find the victim entry
				victimTag = sets.at(setId)->getEntry(victimEntryId)->getTag();	//get victim's tag
				sets.at(setId)->getEntry(victimEntryId)->writeTag(tag);
				sets.at(setId)->getEntry(victimEntryId)->writeTimeLabel(timeCnt++);
				return true;
			}
		}
		else{
			return false;
		}
	} 

	bool cacheWriteLRU(vector<int> addr){
		//read the address
		vector<int> tag, index;
		int setId;	//index in decimal

		tag.assign(tagLength, 0);
		for(int i=0;i<tagLength;++i){
			tag.at(i) = addr.at(32-tagLength+i);
		}

		if(indexLength!=0){
			index.assign(indexLength, 0);
			for(int i=0;i<indexLength;++i){
				index.at(i) = addr.at(32-tagLength-indexLength+i);
			}
			setId = bi2dec(index);
		}
		else{
			setId = 0;
		}

		//hit or not
		bool findOrNot = sets.at(setId)->findSameTag(tag);

		if(!findOrNot){    //if not hit
			int emptyId = sets.at(setId)->getEmptyId();
			if(emptyId!=-1){	//if has empty entry
				sets.at(setId)->getEntry(emptyId)->writeTag(tag);
				sets.at(setId)->getEntry(emptyId)->writeTimeLabel(timeCnt++);
				return false;
			}
			else{	//if no empty entry
				int victimEntryId = sets.at(setId)->getLeastLabelId();	//find the victim entry
				victimTag = sets.at(setId)->getEntry(victimEntryId)->getTag();	//get victim's tag
				sets.at(setId)->getEntry(victimEntryId)->writeTag(tag);
				sets.at(setId)->getEntry(victimEntryId)->writeTimeLabel(timeCnt++);
				return true;
			}
		}
		else{ 	//if hit
			int idx = sets.at(setId)->getHitEntryId();
			sets.at(setId)->getEntry(idx)->writeTimeLabel(timeCnt++);
			return false;
		}
	} 

	bool cacheWriteMyself(vector<int> addr){
		//read the address
		vector<int> tag, index;
		int setId;	//index in decimal

		tag.assign(tagLength, 0);
		for(int i=0;i<tagLength;++i){
			tag.at(i) = addr.at(32-tagLength+i);
		}

		if(indexLength!=0){
			index.assign(indexLength, 0);
			for(int i=0;i<indexLength;++i){
				index.at(i) = addr.at(32-tagLength-indexLength+i);
			}
			setId = bi2dec(index);
		}
		else{
			setId = 0;
		}

		//hit or not
		bool findOrNot = sets.at(setId)->findSameTag(tag);

		if(!findOrNot){    //if not hit
			int emptyId = sets.at(setId)->getEmptyId();
			if(emptyId!=-1){	//if has empty entry
				sets.at(setId)->getEntry(emptyId)->writeTag(tag);
				sets.at(setId)->getEntry(emptyId)->writeTimeLabel(timeCnt++);
				return false;
			}
			else{	//if no empty entry
				int victimEntryId = sets.at(setId)->getSecondLabelId();	//find the victim entry
				victimTag = sets.at(setId)->getEntry(victimEntryId)->getTag();	//get victim's tag
				sets.at(setId)->getEntry(victimEntryId)->writeTag(tag);
				sets.at(setId)->getEntry(victimEntryId)->writeTimeLabel(timeCnt++);
				return true;
			}
		}
		else{ 	//if hit
			int idx = sets.at(setId)->getHitEntryId();
			sets.at(setId)->getEntry(idx)->writeTimeLabel(timeCnt++);
			return false;
		}
		
	} 

protected:
	int cacheSize; //KB
	int blockSize; //B
	int associativity; //0 direct-mapped, 1 four-way set associative, 2 fully associative
	int policy; // FIFO=0 , LRU=1, Your Policy=2

	int blockNum;
	int setNum;
	int entryPerSet;
	int indexLength;
	int tagLength;
	vector<CacheSet*> sets;

	int timeCnt;
	vector<int> victimTag;

};


