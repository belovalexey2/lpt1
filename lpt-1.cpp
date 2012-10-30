#include "windows.h"
#include "iostream"
#include<conio.h>
using namespace std;

int main()
{
	HANDLE  lpt_port = CreateFile("LPT1",GENERIC_WRITE,0,NULL,
		OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL);

    char x;
	if (lpt_port != INVALID_HANDLE_VALUE)
	{
	    DWORD dw;
        cout<<"Enter simvol:"<<endl;

        while(x != 0x1b)
        {
	        x = getch();

            if ((x == 0) || (x == 0xe0))
            {
                x = getch();
                int functionKey = x;
                cout<<"Pressing the function key: "<<functionKey<<endl;
            }
            else
            {
                if (x >= 0x2c && x <= 0x3b)
                {
                    WriteFile(lpt_port,&x,1,&dw,NULL);
                    cout<<x;
                }
                else if (x >= 0x41 && x <= 0x5a)
                {
                    WriteFile(lpt_port,&x,1,&dw,NULL);
                    cout<<x;
                }
                else if (x >= 0x61 && x <= 0x7a)
                {
                    WriteFile(lpt_port,&x,1,&dw,NULL);
                    cout<<x;
                }
                else  if (x == 0x0d)
                {
                    cout<<endl;
                    WriteFile(lpt_port,&x,1,&dw,NULL);
                }
                else  if ((x >=0x20 && x<=0x22) || (x == 0x3f))
                {
                    cout<<x;
                    WriteFile(lpt_port,&x,1,&dw,NULL);
                }
            }
        }

        CloseHandle(lpt_port);
	}
	else cout << "Error Open" << endl;
	return 0;
}
