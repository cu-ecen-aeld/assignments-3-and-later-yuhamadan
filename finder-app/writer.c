#include <stdio.h>
#include <stdlib.h>
#include <syslog.h>

int main(int argc, char* argv[])
{

    if( argc != 3 )
    {
      syslog(LOG_ERR, "expected 2 arguments! - (1) writefile which is the path to the file & (2) writestr which is the content that is being written to the file ...exiting!\n");
      exit(1);
    }
    // printf("The (1) argument supplied is %s\n", argv[1]);
    // printf("The (2) argument supplied is %s\n", argv[2]);

    char* writefile = argv[1];
    char* writestr = argv[2];


    // printf("writefile: %s\n", writefile);
    // printf("writestr: %s\n", writestr);
    
    // You can assume the directory is created by the caller.
    FILE *fptr;

    // use appropriate location if you are using MacOS or Linux
    fptr = fopen(writefile, "w");

    if(fptr == NULL)
    {
        syslog(LOG_ERR, "failed to create writefile: %s ...exiting!\n", writefile);
        exit(1);
    }


    syslog(LOG_DEBUG, "Writing %s to %s", writestr, writefile);
    fprintf(fptr,"%s", writestr);
    fclose(fptr);

    return 0;

}