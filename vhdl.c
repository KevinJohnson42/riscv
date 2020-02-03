#include <stdio.h>
#include <stdlib.h>

typedef unsigned char u8;

int main(int argc, char**argv)
{
    if(argc != 2){printf("Usage: ./vhdl.out filename.bin"); exit(1);}
    FILE * fp;
    fp = fopen(argv[1],"r");
    if(!fp){printf("File not found!\n");}
    fseek(fp, 0, SEEK_END);
    int n = ftell(fp);
    fseek(fp, 0, SEEK_SET);

    u8*data = malloc(n);
    int size = fread(data,1,n,fp);
    fclose(fp);

    int width = 4*8;
    fp = fopen("inst_pack.vhd","w");
    char*header =
"library ieee;\n"
"use ieee.std_logic_1164.all;\n"
"use ieee.numeric_std.all;\n"
"use ieee.math_real.all;\n\n"
"package inst_pack is\n"
"   constant memory_depth : positive  := 10;\n"
"   type data_array is array (2**memory_depth-1 downto 0) of std_logic_vector(7 downto 0);\n";

    char*byte0 =
    "   constant memory_byte_0 : data_array :=\n"
    "   (\n";

    char*byte1 =
    "   constant memory_byte_1 : data_array :=\n"
    "   (\n";

    char*byte2 =
    "   constant memory_byte_2 : data_array :=\n"
    "   (\n";

    char*byte3 =
    "   constant memory_byte_3 : data_array :=\n"
    "   (\n";

    char*footer ="end inst_pack;\n";


    int count = 0;
    fprintf(fp,"%s",header);

    //Byte 0
    count = 0;
    fprintf(fp,"%s",byte0);
    for(int i=0;i<=n-width;i+=width)
    {
        for(int j=0;j<width;j++)
        {
            if((i+j)%4 == 0)
            {
                fprintf(fp,"%3d=>x\"%02X\",",count,data[i+j]);
                count++;
            }
        }
        fprintf(fp,"\n");
    }
    for(int i=width*(n/width);i<n;i++)
    {
        if(i%4 == 0)
        {
            fprintf(fp,"%3d=>x\"%02X\",",count,data[i]);
            count++;
        }
    }
    fprintf(fp,"\nothers => (others => '0')\n);\n");

    //Byte 1
    count = 0;
    fprintf(fp,"%s",byte1);
    for(int i=0;i<=n-width;i+=width)
    {
        for(int j=0;j<width;j++)
        {
            if((i+j)%4 == 1)
            {
                fprintf(fp,"%3d=>x\"%02X\",",count,data[i+j]);
                count++;
            }
        }
        fprintf(fp,"\n");
    }
    for(int i=width*(n/width);i<n;i++)
    {
        if(i%4 == 1)
        {
            fprintf(fp,"%3d=>x\"%02X\",",count,data[i]);
            count++;
        }
    }
    fprintf(fp,"\nothers => (others => '0')\n);\n");

    //Byte 2
    count = 0;
    fprintf(fp,"%s",byte2);
    for(int i=0;i<=n-width;i+=width)
    {
        for(int j=0;j<width;j++)
        {
            if((i+j)%4 == 2)
            {
                fprintf(fp,"%3d=>x\"%02X\",",count,data[i+j]);
                count++;
            }
        }
        fprintf(fp,"\n");
    }
    for(int i=width*(n/width);i<n;i++)
    {
        if(i%4 == 2)
        {
            fprintf(fp,"%3d=>x\"%02X\",",count,data[i]);
            count++;
        }
    }
    fprintf(fp,"\nothers => (others => '0')\n);\n");

    //Byte 3
    count = 0;
    fprintf(fp,"%s",byte3);
    for(int i=0;i<=n-width;i+=width)
    {
        for(int j=0;j<width;j++)
        {
            if((i+j)%4 == 3)
            {
                fprintf(fp,"%3d=>x\"%02X\",",count,data[i+j]);
                count++;
            }
        }
        fprintf(fp,"\n");
    }
    for(int i=width*(n/width);i<n;i++)
    {
        if(i%4 == 3)
        {
            fprintf(fp,"%3d=>x\"%02X\",",count,data[i]);
            count++;
        }
    }
    fprintf(fp,"\nothers => (others => '0')\n);\n");

    fprintf(fp,"%s",footer);



    fclose(fp);

}