//#include "math.h"

typedef unsigned int    u32;
typedef unsigned short  u16;
typedef unsigned char   u8;

//Memory mapped IO
#define timer_address   0x00001000
#define uart_address    0x00002000
#define io_address      0x00003000
#define vga_address     0x00004000

//Timer registers
#define timer_value         *((volatile u32*)timer_address)

//Uart registers
#define uart_data           *((volatile u8*)uart_address)
#define uart_read_ready     *((volatile u8*)(uart_address+1))
#define uart_write_ready    *((volatile u8*)(uart_address+2))
#define uart_read_count     *((volatile u32*)(uart_address+4))
#define uart_write_count    *((volatile u32*)(uart_address+8))

//IO registers
#define io_data             *((volatile u32*)io_address)

//VGA registers
#define vga_data            *((volatile u16*)vga_address)

//DONT TOUCH
void main(); void _start(){main();}
//DONT TOUCH

/*
int mul(int a, int b)
{
    int y = 0;
    for(int i=0;i<32;i++)
    {
        if(b&1){y += a;}
        a = a << 1;
        b = b >> 1;
    }
    return y;
}

int factorial(int x)
{
    if(x == 0) {return 1;}
    else {return mul(x,factorial(x-1));}
}

int mul_fast(int a, int b)
{
    int y = 0;
    while((a!=0)&&(b!=0))
    {
        if(b&1){y += a;}
        a = a << 1;
        b = b >> 1;
    }
    return y;
}

int factorial_fast(int x)
{
    if(x == 0) {return 1;}
    else {return mul_fast(x,factorial(x-1));}
}

*/

void sleep(u32 time)
{
    u32 start, stop;
    start = timer_value;
    stop = start + time;
    //Roll over wait
    if(stop < start)
    {
        while(timer_value > stop){/*Wait*/}
    }
    //Normal wait
    while(timer_value < stop){/*Wait*/}
}

void print(char*data)
{
    int i=0;
    while(data[i])
    {
        while(uart_write_ready == 0) {/*WAIT*/}
        uart_data = data[i];
        i++;
    }
}

int uart_rx(char*x, int size)
{
    int count = 0;
    while((uart_read_ready == 1) && (count < size))
    {
        x[count] = uart_data;
        count++;
    }
    return count;
}

void print_hex(u32 a, u32 n)
{
    u8 nib;
    for(int i=0;i<2*n;i++)
    {
        nib = (a >> (4*2*n - 4*(i+1)))&0xF;
        if(nib < 10)    {nib += 48;}
        else            {nib += 65-10;}
        while(uart_write_ready == 0) {/*WAIT*/}
        uart_data = nib;
    }
}



void main()
{

    u32 wait_cycles = 1000;

    while(1)
    {
        sleep(wait_cycles);
        print("Uart: ");
        print_hex(uart_read_count,4);
        print("\n");
        io_data = ~(io_data);
    }
    
    //End of program
    while(1){}
}




/*
int main()
{

    int a,b,c;
    write(1,io_address);
    write(2,io_address+4);
    a = read(io_address);
    b = read(io_address+4);
    c = a + b;
    write(c,io_address);
    

    
    
    for(int i=0;i<2;i++)
    {
        write_32(i+2,io_address+i*4);
    }
    int total = 27;
    for(int i=0;i<2;i++)
    {
        total = mul(total,read_32(io_address+4*i));
        write_32(total,io_address);
    }

    print("Hello World\n");
    for(int i=0;i<12;i++)
    {
        int x = read_8(uart_address+i);
    }
    

    
    write_32(10,io_address);
    int a = read_32(io_address);
    int b = factorial(a);
    write_32(b,io_address);
    
    
    //faster
    
    write_32(8,io_address);
    int a = read_32(io_address);
    int b = factorial_fast(a);
    write_32(b,io_address);
    
}
*/