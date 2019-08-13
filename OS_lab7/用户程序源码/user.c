extern int fork();
extern int wait();
extern void exit();
extern void cls();
extern char getchar();
extern void printchar();

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

char str[80] = "129djwqhdsajd128dw9i39ie93i8494urjoiew98kdkd";
int LetterNr = 0;

void main() 
{
	int pid;
	print("\r\n\r\ncount string: ");
	print(str);
	print("\r\n");
	print("In the user: before fork\r\n");
	pid = fork();
	print("In the user: after fork\r\n");
	print("The pid is: ");
	printInt(pid);
	print("\r\n");
	if(pid == -1) 
	{
		print("error in fork!\r\n");
		exit(-1);
	} 
	if(pid) 
	{
		print("In the user: before wait\r\n");
		wait();
		print("In the user: after wait\r\n");
		print("LetterNr = ");
		printInt(LetterNr);
		print("\r\n");
		print("In the user: process exit\r\n");
		exit(0);
	}
	else 
	{
		print("In the user: sub process is counting\r\n");
		LetterNr = strlen(str);
		print("In the user: sub process exit\r\n");
		exit(0);
	}
}