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


//Some useful test functions below
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
        while(uart_write_ready == 0) {} //Wait
        uart_data = nib;
    }
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
        while(timer_value > stop){} //Wait
    }
    //Normal wait
    while(timer_value < stop){} //Wait
}

void print(char*data)
{
    int i=0;
    while(data[i])
    {
        while(uart_write_ready == 0) {} //Wait
        uart_data = data[i];
        i++;
    }
}

void main()
{
    u32 wait_cycles = 1000;

    while(1)
    {
        sleep(wait_cycles);             //Read the timer
        print("Hello World!\n");        //Write to UART, See register 14 in sim
        io_data = ~(io_data);           //Read, invert, Write GPIO
    }
    
    //End of program safety
    while(1){}
}