#include<stdio.h>
#include<string.h>
#include<ctype.h>
void _swap(char *arg1, char *arg2)
{
	char tmp;
	
	if(arg1 == NULL || arg2 == NULL)
	{
		printf("_swap argument error");
		return;
	}
	tmp =  *arg1;
	*arg1 =  *arg2;
	*arg2 =  tmp;
}

void _invert(char *start, char *end )
{
	if(start == NULL || end == NULL)
	{
		printf("_invert argument error");
		return;
	}
	while(start < end)
	{
		_swap(start, end);
		++start;
		--end;
	}
}

// 1
//cycle move left bitcount,if move right: bitcount = strlen(str) - bitcount;
//bitCount >0 move left; bitCount <0 move right
void StringRotate(char *str, int bitCount)
{
	int _len = strlen(str);
	
	if(str == NULL)
	{
		printf("StringRotate parameter error,a NULL parameter");
		return;
	}
	if(bitCount < 0)
		bitCount = strlen(str) + bitCount;
	
	_invert(str, str + bitCount-1);
	_invert(str + bitCount , str + _len -1);
	_invert(str, str + _len -1);
}

// 2
//judge whether the str is a substr of container
//use the rear 26 bit of int to express upper alphabet,  scan str1 and str2 , compare each bit while scanning str2. 
//only deal upper alpha.
bool IsStringContain(char *container, char *str)
{
	int hash = 0;
	int i;
	if(container == NULL || str == NULL )
	{
		printf("IsStringContain parameter error, a NULL parameter \n");
		return false;
	}
	for (i = 0; i < strlen(container); ++i)
	{
		if(! isupper(container[i]))
		{
			printf("IsStringContain parameter error ,include a char which is not a upper alpha\n");
			return false;
		}
		hash |= (1 << (container[i] - 'A'));
	}
	for(i = 0 ;i < strlen(str); ++i)
	{	
		if(! isupper(str[i]))
		{
			printf("IsStringContain parameter error ,include a char which is not a upper alpha\n");
			return false;
		}
		if(0 == (hash & (1<<(str[i] - 'A'))))
			return false;
	}
	return true;
}

// 3
int MAXINT = (int)((unsigned)~0 >> 1);
int MININT = -(int)((unsigned)~0 >> 1)-1;

bool _isOverFlow(int curInt, char curChar, int sign)
{
	
	if(sign > 0 && curInt > MAXINT)
		return true;
	if(sign > 0 && curInt == MAXINT/10 && (curChar - '0') > MAXINT%10)
		return true;
	if(sign < 0 && curInt > MININT)
		return true;
	if(sign < 0 && curInt == MININT/10 && (curChar - '0') > MININT%10)
		return true;
	return false;
}

bool _isNumStr(char *str)
{
	char *curChar;
	int i;
	
	for(i=0 ;i < strlen(str); i++)
	{
		if(i == 0 && (str[i] < '0' || str[i] > '9') && str[i] != '-' && str[i] != '+')
			return false;
		if(str[i] < '0' || str[i] > '9')
			return false;
	}

	return true;
}

int StrToInt(const char *str)
{
	int curInt = 0;
	char *curChar = str;
	int sign;

	if(str == NULL)
		return 0;
	if(!_isNumStr(str))
		return 0;

	sign = 1;
	if(str[0] == '-')
		sign = -1;
	
	if(!isdigit(str[0]))
		++curChar;
	
	for( ;*curChar != '\0'; ++curChar)
	{
		if(_isOverFlow(curInt, curChar, sign))
		{
			if(sign >0)
				curInt = MAXINT;
			else
				curInt = MININT;
			break;
		}
		curInt = curInt * 10 + (*curChar - '0'); 
	}
	return sign >0 ? curInt: -curInt ;
}

// 4
//it has two methods of sloving. One is searching from left and right end to middle slot , the other is searching from middle slot to left and right end.
//In this method, we adopt the second.
bool isPalindrome(const char *str)
{
	int len;
	int curLeft, curRight;

	if(str == NULL)
		return false;

	len = strlen(str);
	//curLeft = len/2; 
	curLeft = len>>1 -1; //Notice: >> or << is more effective than /2 or *2;
	
	//if( len%2 == 1) 
	if(len & 1 == 1)	//notice :bit operation;
		curRight = curLeft + 2;
	else
		curRight = curLeft + 1;

	for( ;curLeft >= 0; --curLeft, ++curRight)
	{
		if(str[curLeft] != str[curRight])
			return false;
	}
	return true;
}
