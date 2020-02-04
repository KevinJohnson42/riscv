#include <stdio.h>
#include <stdlib.h>

char*header =
    "--This is autogenerated file. If hand modified, it may be accidentally over written!\n"
    "library ieee;\n"
    "use ieee.std_logic_1164.all;\n"
    "use ieee.numeric_std.all;\n"
    "use ieee.math_real.all;\n\n"
    "package inst_pack is\n"
    "    constant memory_depth : positive  := 10;\n"
    "    type data_array is array (2**memory_depth-1 downto 0) of std_logic_vector(7 downto 0);\n";

char*byte0  = "    constant memory_byte_0 : data_array :=\n    (\n";
char*byte1  = "    constant memory_byte_1 : data_array :=\n    (\n";
char*byte2  = "    constant memory_byte_2 : data_array :=\n    (\n";
char*byte3  = "    constant memory_byte_3 : data_array :=\n    (\n";
char*footer ="end inst_pack;\n";

typedef unsigned char u8;

void write_data_array(FILE*fp, char*name, u8*data, int mod, int n)
{
    int width = 4*8;
    int count = 0;
    fprintf(fp,"%s",name);
    for(int i=0;i<=n-width;i+=width)
    {
        fprintf(fp,"        ");
        for(int j=0;j<width;j++)
        {
            if((i+j)%4 == mod)
            {
                fprintf(fp,"%3d=>x\"%02X\",",count,data[i+j]);
                count++;
            }
        }
        fprintf(fp,"\n");
    }
    fprintf(fp,"        ");
    for(int i=width*(n/width);i<n;i++)
    {
        if(i%4 == mod)
        {
            fprintf(fp,"%3d=>x\"%02X\",",count,data[i]);
            count++;
        }
    }
    fprintf(fp,"\n         ");
    fprintf(fp,"others => (others => '0')\n    );\n");
}

int main(int argc, char**argv)
{
    //Check args
    if(argc != 2){printf("Usage: ./vhdl.out filename.bin"); exit(1);}
    
    //Open bin file
    FILE * fp;
    fp = fopen(argv[1],"r");
    if(!fp){printf("File not found!\n"); exit(2);}
    
    //Get file size
    fseek(fp, 0, SEEK_END);
    int n = ftell(fp);
    fseek(fp, 0, SEEK_SET);

    //Read the file into RAM
    u8*data = malloc(n);
    int size = fread(data,1,n,fp);
    fclose(fp);

    //Create the inst_pack.vhd file
    fp = fopen("inst_pack.vhd","w");
    fprintf(fp,"%s",header);
    write_data_array(fp,byte0,data,0,n);
    write_data_array(fp,byte1,data,1,n);
    write_data_array(fp,byte2,data,2,n);
    write_data_array(fp,byte3,data,3,n);
    fprintf(fp,"%s",footer);
    fclose(fp);
}