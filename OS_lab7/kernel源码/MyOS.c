#include "MyPro.h"

extern void printChar();
extern void getchar(); 
extern void cls();
extern void getdate(); 
extern void gettime();
extern void run();
extern void readAt();   
extern void readFile();
extern void int33h();
extern void int34h();
extern void int35h();
extern void int36h();
extern void int21h_0();
extern void int21h_1();
extern void int21h_2();
extern void int21h_3();
extern int  int21h_4();
extern int  int21h_5();
extern void run_process();

char in,ch1,ch2,ch3,ch4,p,fileSeg=7,insNum,sector_number, sector_size;;
char input[100],output[100],tem_str[100];
char ini[100];
int pFile=0;
int i,j,yy,mm,dd,hh,mmm,ss,t;

void print(char *p)
{
    /*打印字符串*/
    while(*p != '\0')
    {
        printChar(*p);
        p++;
    }
}

int getline(char arr[],int maxLen)
{
    /*读取一行*/
    if(maxLen == 0)
        return 0;

    i = 0;
    getchar();
    while(in != '\n'&& in != '\r') 
    {
        /*判断是否是回车*/
        int k = in;
        if(k == 8)
        {
            /*判断是否是退格*/
            i--;
            getchar();
            continue;
        }
        printChar(in);
        arr[i++] = in;
        if(i == maxLen)
        {
            /*判断是否到达允许输入最大长度*/
            arr[i] = '\0';
            printChar('\n');
            return 0;
        }
        getchar();
    }
    arr[i] = '\0';
    print("\n\r");
    return 1;
}

int strcmp(char* str1,char* str2)
{
    /*比较两字符串是否相同*/
    while(*str1 != '\0' && *str2 != '\0')
    {
        if(*str1 != *str2) return 0;
        str1++;str2++;
    }
    if(*str1 == '\0' && *str2 == '\0') 
        return 1;
    return 0;
}

void strcpy(char str1[],char str2[])
{
    /*将字符串 str2 复制到 str1 中*/
    i = 0;
    while(str2[i] != '\0')
    {
        str1[i] = str2[i];
        i++;
    }
    str1[i] = '\0';
}

int strlen(char str[])
{
    /*获取字符串长度*/
    i = 0;
    while(str[i] != '\0')
        i++;
    return i;
}

void reverse(char str[],int len)
{
    /*翻转字符串*/
    for(i = 0;i < len;++i)
        tem_str[i] = str[len-i-1];

    for(i = 0;i < len;++i)
        str[i] = tem_str[i];
}

int substr(char str1[],char str2[],int st,int len)
{
    /*将 str1中st开始len个字符复制到str2中*/
    for(i = st;i < st+len;++i)
        str2[i-st] = str1[i];

    str2[st+len] = '\0';
}

void printInt(int ans)
{
    /*打印十进制整数*/
    i = 0;
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

void init()
{
    /*操作系统初始界面*/
    cls();
    print("        16327143 ZhongXun\n\r\n");
    print("        Welcome to use my OS\n\r\n");
    print("        [cls] -- clear the screen         [time] -- Get the time\n\r");
    print("        [run] -- run one or several of program 1 2 3 4. etc: run 1 or run 24131\n\r"); 
    print("        [ESC Button] -- return MyOS while running a program\n\r"); 
    print("        [ls] -- Display the details of files    [help] -- get some help\n\n\r"); 

}

int BCD2DEC(int x)
{
    /*BCD to DEC Number*/
    return x/16*10 + x%16;
}

void time()
{
     /*获取日期*/
    print("The time is: ");
    getdate();
    yy = BCD2DEC(ch1)*100 + BCD2DEC(ch2);
    if(yy == 0) 
        print("0000");
    else if(yy >0 && yy < 10) 
        print("000");
    else if(yy > 10 && yy < 100) 
        print("00");
    else if(yy > 100 && yy < 1000) 
        print("0");
    printInt(yy);
    printChar('/');
    mm = BCD2DEC(ch3);
    if(mm == 0) 
        print("00");
    else if(mm > 0 && mm < 10) 
        printChar('0');
    printInt(mm);
    printChar('/');
    dd = BCD2DEC(ch4);
    if(dd == 0) 
        print("00");
    else if(dd > 0 && dd < 10) 
        printChar('0');
    printInt(dd);
    print(" ");
    
    /*获取时间*/
    gettime();
    hh = BCD2DEC(ch1);
    if(hh == 0) 
        print("00");
    else if(hh >0 && hh < 10) 
        printChar('0');
    printInt(hh);
    printChar(':');
    mmm = BCD2DEC(ch2);
    if(mmm == 0) 
        print("00");
    else if(mmm > 0 && mmm < 10) 
        printChar('0');
    printInt(mmm);
    printChar(':');
    ss = BCD2DEC(ch3);
    if(ss == 0) 
        print("00");
    else if(ss > 0 && ss < 10) 
        printChar('0');
    printInt(ss);
    print("\n\n");
}
void fdetail()
{
    print("\n--------------------------------------\n\r");
    print("\n|   name       |  segNum   |   size  |\n\r");
    print("\n|   left-up    |    11     |   512B  |\n\r");
    print("\n|   right-up   |    12     |   512B  |\n\r");
    print("\n|   left-down  |    13     |   512B  |\n\r");
    print("\n|   left-up    |    14     |   512B  |\n\r");
    print("\n--------------------------------------\n\n\r");
}
void fread()
{
    readFile();
    i=0;
    while(i<insNum)
    {
        for(j = 0; j < 32; j++)
        {
            readAt(pFile);
            tem_str[j]=p;
            pFile++;
        }
        tem_str[j]='\0';
        i++;
    }
    pFile=0;
}

void runPro()
{
    /* 依次运行指定程序*/
    int j;
    for(j = 4;j < strlen(input);++j)
    {
        if(input[j] < '1' || input[j] > '4')
        {
            print("Can't find program! Please input one number of 1,2,3,4!\n\n");
            return ;
        }
    }

    for(j = 4;j < strlen(input);++j)
    {
        if(input[j] == ' ') 
            continue;
        else if(input[j] >= '1' && input[j] <= '4')
        {
            p = input[j] - '0' + 2;
            run();
        }
    }
}
void batch()
{
    /* 依次运行指定程序*/
    int j;
    for(j = 4;j < strlen(tem_str);++j)
    {
        if(tem_str[j] == ' ') 
            continue;
        else if(tem_str[j] >= '1' && tem_str[j] <= '4')
        {
            p = tem_str[j] - '0' + 2;
            run();
        }
    }
}
void help()
{
    print("\r\n        You can uses these instructions:\n\n\r");
    print("        [cls] -- clear the screen         [time] -- Get the time\n\r");
    print("        [run] -- run one or several of program 1 2 3 4. etc: run 1 or run 24131\r\n");
    print("        [ESC Button] -- return MyOS while running a program\n\r");  
    print("        [ls] -- Display the details of files    [help] -- get some help\n\n"); 
}
int HEX2DEC(char *phex)
{
	/*十六进制转十进制 21h中断5号功能*/
	int dec = 0;
	while(*phex != '\0')
	{
		int tem = 0;
		dec = dec*16;
		if(*phex >= '0' && *phex <= '9')
			tem = *phex - '0';
		else if(*phex >= 'A' && *phex <= 'F')
			tem = *phex - 'A' + 10;
		else if(*phex >= 'a' && *phex <= 'f')
			tem = *phex - 'a' + 10;
		else 
            tem = 0;
		dec += tem;
		phex++;
	}
	return dec;
}
int BIN2DEC(char* word)
{
	/*二进制转十进制 21h中断4号功能*/
    int num = 0;
	while( (*word) != '\0' )
	{
		num *= 2;
		num += (*word) - '0';
		word++;
	}
	return num;
}
void upper(char *word)
{
	/*字符串转为全大写 21h中断2号功能*/
	while(*word != '\0')
	{
		if(*word >= 'a' && *word <= 'z')
			*word = (*word)-32;
		word++;
	}
}

void lower(char *word)
{
	/*字符串转为全小写 21h中断3号功能*/
	while(*word != '\0')
	{
		if(*word >= 'A' && *word <= 'Z')
			*word = (*word)+32;
		word++;
	}
}
void BIOSCall()
{
    p = 8;
    run();
}
void test21h(char op)
{
    switch (op)
    {
    case '0':
        int21h_0();
        init();
        break;
    case '1':
        print("\n\rinput your string:\n\r");
        getline(input,50);
        print("\n\r21h_1 print:\n\r");
        int21h_1(input);
        print("\n\r");
        break;
    case '2':
        print("\r\nPlease input a sentence:\n\r");
		getline(input,50);
        int21h_2(input);
        print(input);
        print("\r\n");
        break;
    case '3':
        print("\r\nPlease input a sentence:\n\r");
		getline(input,50);
        int21h_3(input);
        print(input);
        print("\r\n");
        break;
    case '4':
        print("\r\nplease input your Bin number:\n\n\r");
        getline(input,10);
        print("\r\n");
        pFile=int21h_4(input);
        printInt(pFile);
        print("\r\n");
        break;
    case '5':
        print("\r\nplease input your Hex number:\n\n\r");
        getline(input,4);
        print("\r\n");
        pFile=int21h_5(input);
        printInt(pFile);
        print("\r\n");
        break;
    default:
        break;
    }
}
void create_process(char *comm) 
{
	int sum = 0, flag = 0;
	for (j = 1; j < strlen(comm); ++j) 
    {
		if (comm[j] == ' ' || comm[j] >= '1' && comm[j] <= '4') 
            continue;
		else 
        {
			print("invalid program number: ");
			printChar(comm[j]);
			print("\n\n\r");
			return;
		}
	}
	for (j = 1; j < strlen(comm); ++j) 
    {
		if (comm[j] != ' ') 
            flag = 1;
	}
	if (flag == 0) 
    {
		print("invalid input\n\n\r");
		return;
	}
	for (j = 1; j < strlen(comm) && sum < MAX_PCB_NUMBER; ++j) 
    {
		if (comm[j] == ' ') 
            continue;
		sum++;
		sector_number = comm[j] - '0' + 2;
		sector_size = 1;
		run_process();
	}
	PCB_initial(&PCB_LIST[0], 1, 0x1000);
	kernal_mode = 0;
}
void run_test() 
{
	sector_number = 15;
	sector_size = 2;
	run_process();
	kernal_mode = 0;
}
cmain()
{
    initial_PCB_settings();
    init();
    kernal_mode = 1;
    while(1)
    {
        print("\rzhongx-root#");
        getline(input,10);
        if(strcmp(input,"time")) 
        {
            /*getTime*/
            time();
        }
        else if(strcmp(input,"cls"))
        {
            /*cls*/
            init();
        }
        else if(substr(input,tem_str,0,3) && strcmp(tem_str,"run"))
        {
            /*run*/
            runPro();
            init();
        }
        else if(strcmp(input,"help"))
        {
            /*help*/
            help();
        }
        else if (strcmp(input,"ls")) 
        {
            /*File information*/
            fdetail();
        }
        else if(strcmp(input,"ini.cmd"))
        {
            /*batch*/
            fread();
            batch();
            init();
        }
        else if(strcmp(input,"int 33h"))
        {
            int33h();
            init();
        }
        else if(strcmp(input,"int 34h"))
        {
            int34h();
            init();
        }
        else if(strcmp(input,"int 35h"))
        {
            int35h();
            init();
        }
        else if(strcmp(input,"int 36h"))
        {
            int36h();
            init();
        }
        else if(strcmp(input,"test bios"))
        {
            BIOSCall();
            init();
        }
        else if(strcmp(input,"test"))
        {
            run_test();
        }
        else if (input[0] == 'p')
        {
            create_process(input);
        } 
        else if(substr(input,tem_str,0,6) && strcmp(tem_str,"int21h"))
        {
            test21h(input[8]);
        }
        else
        {
            /*error*/
            print("Cat't find the Command: ");
            print(input);
            print("\n\n");
        }
    }
}

