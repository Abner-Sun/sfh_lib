#ifndef MY_STRING_H
#define MY_STRING_H



//cycle move left bitcount,if move right: bitcount = strlen(str) - bitcount;
//bitCount >0 move left; bitCount <0 move right
void StringRotate(char *str, int bitCount);

//judge whether the str is a substr of container
//use the rear 26 bit of int to express upper alphabet,  scan str1 and str2 , compare each bit while scanning str2. 
//only deal upper alpha.
bool IsStringContain(char *container, char *str);


#endif
