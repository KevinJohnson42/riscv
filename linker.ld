_start = 0x0000;

MEMORY
{
    ram : ORIGIN = 0, LENGTH = 0X1000
}

SECTIONS
{
    .text.startup : { *(.text.startup*) } > ram
}