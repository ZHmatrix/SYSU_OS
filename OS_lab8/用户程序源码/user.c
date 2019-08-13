extern int fork();
extern int wait();
extern void exit();
extern void cls();
extern char getchar();
extern void printchar();
extern void p(int);
extern void v(int); 
extern int semaGet(int);
extern void delay();

void reverse(char str[],int len) 
{
	int i;
    char t_char[100];
	for(i = 0;i < len;++i) 
		t_char[i] = str[len-i-1];

	for(i = 0;i < len;++i)
		str[i] = t_char[i];
}

int strlen(char str[]) 
{
	int i = 0;
	while(str[i] != '\0') 
		i++;
	return i;
}

void print(char *p) 
{
	while(*p != '\0') 
	{
		printChar(*p);
		p++;
	}
}

int getline(char arr[],int maxLen) 
{
	int i = 0;
	char in;
	if(maxLen == 0) 
	{
		return 0;
	}
	in = getchar();
	while(in != '\n'&& in != '\r') 
	{
		int k = in;
		if(k == 8) 
		{
			i--;
			in = getchar();
			continue;
		}
		printChar(in);
		arr[i++] = in;
		if(i == maxLen) 
		{
			arr[i] = '\0';
			printChar('\n');
			return 0;
		}
		in = getchar();
	}
	arr[i] = '\0';
	print("\n\r");
    return 1;
}

void printInt(int ans) 
{
	int i = 0;
    char output[100];
	if(ans == 0) 
	{
		output[0] = '0';
		i++;
		output[i] = '\0';
		print("0");
		return;
	}
	while(ans) 
	{
		int t = ans%10;
		output[i++] = '0'+t;
		ans/=10;
	}
	reverse(output,i);
	output[i] = '\0';
	print(output);
}


char words[100];
char *fruits[10]={"apple","peach","pear","pear","peach","apple","peach","pear","pear","peach"};
int fruit_disk=1; /* 苹果=1,雪梨=2... */
void putwords(char *w) 
{  
	/*将祝福一个词一个词放进words[]*/
	int i=0;
	for(i=0;w[i]!='\0';i++)
		words[i]=w[i];
	words[i]='\0';
}
void putfruit() 
{    
	/*随机选择一个水果放进fruit_disk*/
	fruit_disk++;
	if (fruit_disk>=10)
		fruit_disk=0;
	
}
void main()
{
   	int s;
   	s=semaGet(0);
   	if (fork())
   	{
		while(1) 
		{ 
			p(s); 
			p(s); 
			print(words);
			print("\r\nFather eats: ");
			print(fruits[fruit_disk]);
			fruit_disk = 0;
		}
   	}        
   	else if(fork())
	{
		while(1) 
		{ 
			putwords("\r\nFather will live one year after anther for ever!"); 
			v(s);
			delay();
		}
	}
	else
	{
		while(1) 
		{ 
			putfruit(); 
			v(s);
			delay();
		}
	}      
}

