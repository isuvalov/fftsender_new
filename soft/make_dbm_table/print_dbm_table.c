#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>


double dbm(double val, int harm) {
    if (val <= 0 || harm <= 0)
        return -90;
    double dist = harm * 0.5;
    double part1 = 20 * log10(val/1300) - 40.0;
    double part2 = dist <= 200 ? 14.75 * log10(dist) + 15 : 44.0;
    double part3 = -27.32;
    return part1 + part2 + part3;
  //return 20.0 * log10(val/1300.0) - 40.0 + 3.2175 * log10(double(harm) / 0.5) - 3.6; //Chernovs version

}


main(int argc, char *argv[])
{

int z;
double val,dbm_val;

	for (z=0;z<10;z++)
	{
		val=(double)z;
		dbm_val=dbm(val,1);
		printf ("%f\n",dbm_val);
	}

	                          
}

