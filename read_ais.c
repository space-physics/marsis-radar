/*

Written by Robert Johnson
Date: November 28, 2006

Revisions:
  November 28, 2006 :: version 1.00 :: raj
    initial


  readais() - reads the binary Mars Express MARSIS AIS Data sets
and produces an ASCII readable text.

  Here is a list of the commands to be executed.  Each is explained in
detail in SOFTINFO.TXT.

  $ cp READAIS.C read_ais.c               # rename ".C" to ".c"
  $ cc read_ais.c -o read_ais            # compile
  $ read_ais AIS_TESTIN.DAT > aisdat.txt  # binary AIS to text AIS
  $ diff AIS_TESTOUT.DAT aisdat.txt       # compare with the expected output

In general, to run the program,

  $ readais FILENAME
    where FILENAME is the name of the binary archived data set

or to read from stdin,

  $ readais < FILENAME
    where FILENAME is the name of the binary archived data set

*/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

const char *sVersion="read_ais() ver1.00";

int Little_End_In_First(void);
char* nScet_to_sScet(unsigned long nDoy,unsigned long nMsec);
void show_help(FILE *h);



int main(int argc,char *argv[])
{
int i,bLsbFirst,nRead,nRecords=0;
char *sFile=NULL;
FILE *hIn;

char sTime[32];
unsigned char arRecord[1024];
int nBand,nRxAttn,nXmitPwr;
unsigned long nScetDays,nScetMsec;
unsigned long nXmitFrq;
float fXmitFrq,*pDen;



  /* parse the command line arguments */
  while(--argc){
    ++argv;
    if(!strcmp("-h",*argv) || !strcmp("-help",*argv)){
      show_help(stdout);
      exit(0);
    }
    else{
      sFile=*argv;
    }
  }/* eilhw parsing command line arguments */



  /* assume standard in if there are no files specified */
  /* on the command line */
  if(sFile==NULL){
    hIn=stdin;
    fprintf(stderr,"reading from stdin\n");
  }
  else if((hIn=fopen(sFile,"rb"))==NULL){
    fprintf(stderr,"Unable to open %s\n\n",sFile);
    show_help(stdout);
    exit(1);
  }
  else{
    fprintf(stderr,"reading %s\n",sFile);
  }


  /* determine what kind of architecture the program is running on */
  if((bLsbFirst=Little_End_In_First()) == 1)
    fprintf(stderr,"detected a little endian machine (lsb first)\n");
  else
    fprintf(stderr,"detected a big endian machine (msb first)\n");


  while((nRead=fread(arRecord,400,1,hIn))!=0){
    ++nRecords;

/*
    The most correct way to calculate universal coordinated time UTC
    is to use the spacecraft clock with the most current SPICE
    kernels provided by NAIF.  For convenience and simplicity, two
    additional time formats have been provided; an ASCII time string
    and the historical JPL milliseconds of day.  Data users are
    encouraged to calculate event times using the spacecraft clock
    and SPICE kernels, but that is beyond the scope of this simple
    example code.  NAIF SPICE kernels may change over time, so it is
    always best to calculate UTC rather than relying on an archived
    UTC time (the same applies even more so for geometry information).
*/

    /* extract the historical JPL time format */
    nScetDays =((unsigned long)arRecord[ 8])<<24; /*build 32 bit quantity */
    nScetDays|=((unsigned long)arRecord[ 9])<<16; /*that is independent    */
    nScetDays|=((unsigned long)arRecord[10])<< 8; /*of machine architecture*/
    nScetDays|=((unsigned long)arRecord[11])<< 0;

    nScetMsec =((unsigned long)arRecord[12])<<24; /*build a 32 bit quantity */
    nScetMsec|=((unsigned long)arRecord[13])<<16; /*that is independent    */
    nScetMsec|=((unsigned long)arRecord[14])<< 8; /*of machine architecture*/
    nScetMsec|=((unsigned long)arRecord[15])<< 0;

    /* extract the ASCII string format */
    strncpy(sTime,(char*)(arRecord+24),21);
    sTime[22]='\0';  /* terminate the string with NULL character */

    /* extract the transmit power level, 0=low and 15=high */
    nXmitPwr=arRecord[59];

    /* extract the band number, 0 to 4 */
    nBand=arRecord[62];

    /* extract the receiver attenuation */
    switch(arRecord[63]&0x07){
      case 0x00:  nRxAttn= 2;  break;
      case 0x01:  nRxAttn= 6;  break;
      case 0x02:  nRxAttn=10;  break;
      case 0x03:  nRxAttn=14;  break;
      case 0x04:  nRxAttn=18;  break;
      case 0x05:  nRxAttn=22;  break;
      case 0x06:  nRxAttn=26;  break;
      case 0x07:  nRxAttn=30;  break;
      default:    nRxAttn=50;  break;
    }
    nRxAttn=arRecord[63];


    /* extract the transmit frequency, an IEEE float */
    nXmitFrq =((unsigned long)arRecord[76])<<24; /* build a 32 bit quantity */
    nXmitFrq|=((unsigned long)arRecord[77])<<16; /* that is independent     */
    nXmitFrq|=((unsigned long)arRecord[78])<< 8; /* of machine architecture */
    nXmitFrq|=((unsigned long)arRecord[79])<< 0;
    /* interpret the 4 bytes in memory as a IEEE floating point number */
    fXmitFrq=*((float*)(&nXmitFrq));


/*
    If the architecture is little endian, reorder the IEEE Floats so
    that LSB is first.  The same technique as shown above could be
    done down here, but variations are good ;)  In memory bytes
    b4 b3 b2 b1 become b1 b2 b3 b4 for all the 80 measurements.
*/
    if(bLsbFirst == 1){
      unsigned char *p=arRecord+80;
        for(i=0;i<80*4;i+=4,p+=4){
          *(p+0)^=*(p+3);  *(p+3)^=*(p+0);  *(p+0)^=*(p+3);
          *(p+1)^=*(p+2);  *(p+2)^=*(p+1);  *(p+1)^=*(p+2);
        }
    }
    pDen=(float*)(arRecord+80);  /* data begins at byte 80, see format file */


    /* Output some header information */
    fprintf(stdout,"Frame Begin Time :: %s %s\r\n",sTime,
            nScet_to_sScet(nScetDays,nScetMsec));
    fprintf(stdout,"Transmit Frequency = %.3f KHz\r\n",fXmitFrq/1000.0);
    fprintf(stdout,"Band Number = %d\r\n",nBand);
    fprintf(stdout,"Receiver Attenuation = %d\r\n",nRxAttn);
    fprintf(stdout,"Transmit Power Level = %d\r\n",nXmitPwr);

    /* Output the data */
    for(i=0;i<80;i++)
      fprintf(stdout,"%.1E ",pDen[i]);
    fprintf(stdout,"\r\n\r\n");

  }

  fprintf(stderr,"Read %d records (%d frames) totaling %d bytes\n",
          nRecords,nRecords/160,nRecords*400);



return EXIT_SUCCESS;
}







/*
  Check to see what the machine byte order is, either lsb or msb first
  RETURNS:
    0 = msb first
    1 = lsb first
*/
int Little_End_In_First(void)
{
int bStatus;
unsigned char buf[4]={0x0C,0x00,0x00,0x00};
unsigned int *p;

  p=(unsigned int*)buf;
  if(*p==0x0C)
    bStatus=1;   /* Lsb first */
  else
    bStatus=0;  /* Msb first */

return bStatus;
}



/*
  Converts the standard JPL binary scet into a string.

nDoy  - is the number of days since Jan. 1, 2958
nMsec - is the milliseconds since the beginning of the day

Returns:
  A pointer to the standard JPL spacecraft event time format.
  year-doyThh:mm:ss.mil.  The string is statically stored in the function.
*/

char* nScet_to_sScet(unsigned long nDoy,unsigned long nMsec)
{
int nYear,nHour,nMin,nSec;
int nDays,nTotal;
static char arStr[32];

/*
     hint: time addition can be performed by simply adding a time to the
     variables before they are passed into the function; add days to nDoy
     and milliseconds to nMsec.
*/

  /* normalize the milliseconds of day to be a fractions of days */
  while(nMsec>= 24*60*60*1000){
    nMsec-=(24*60*60*1000);
    ++nDoy;
  }
  ++nDoy;  /* convert days since Jan. 1, 1958 [0-356] to day of year [1-366]  */



  nDays=365;  nYear=1959;          /* initial conditions 365 days in 1958 */
  nTotal=nDays;
  while(nDoy>nTotal){
    if(nYear%100)                  /* Year is NOT a century year */
      nDays=(nYear%4)?365:366;     /* if evenly divisible by 4, leap year */
    else                           /* Year is a century year */
      nDays=(nYear%400)?365:366;   /* if evenly divisible by 400, leap year */
    nTotal+=nDays;
    ++nYear;
  }
  nYear-=1;
  nTotal-=nDays;
  nDoy-=nTotal;    /* days since jan 1 [0-365] */

  nHour=nMsec/(1000*60*60);  nMsec-=(nHour*1000*60*60);
  nMin= nMsec/(1000*60);     nMsec-=(nMin*1000*60);
  nSec= nMsec/(1000);        nMsec-=(nSec*1000);

             /* yyyy-doy T hh : mm : ss .mil */
  sprintf(arStr,"%04d-%03dT%02d:%02d:%02d.%03d",nYear,(int)nDoy,
          nHour,nMin,nSec,(int)nMsec);


return arStr;
}



void show_help(FILE *h)
{
  if(h==NULL)  h=stderr;

fprintf(h,"\n");
fprintf(h,"%s\n",sVersion);
fprintf(h,"\n");
fprintf(h,"usage :: read_ais FILENAME\n");
fprintf(h,"  where FILENAME is the name of the AIS binary data.  If no \n");
fprintf(h,"FILENAME is specified, stdin is assumed.\n");
fprintf(h,"\n");
fprintf(h,"  The purpose of this program is to demonstrate how to extract\n");
fprintf(h,"the binary archived AIS data as well as providing a program to\n");
fprintf(h,"convert binary AIS data to ASCII AIS data to be processed by\n");
fprintf(h,"other programs.\n");
fprintf(h,"\n");
fprintf(h,"  Help may be displayed by using \"-h\" or \"-help\" on the\n");
fprintf(h,"command line.\n");
fprintf(h,"\n\n");

}
