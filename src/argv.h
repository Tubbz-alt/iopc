/*
    The InterOperability Platform: IOP
    Copyright (C) 2004 Ian A. Mason
    School of Mathematics, Statistics, and Computer Science   
    University of New England, Armidale, NSW 2351, Australia
    iam@turing.une.edu.au           Phone:  +61 (0)2 6773 2327 
    http://mcs.une.edu.au/~iam/     Fax:    +61 (0)2 6773 3312 


    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#ifndef _IOP_ARGV_H
#define _IOP_ARGV_H

#include <stdio.h>

int interpretTildes(const char* filename, char **newfilenamep);

/* CSL = "Colon Seperated List" (i.e. a class path) */
int interpretTildesCSL(const char* path, char **newpathp);

int makeArgv(const char *s, const char *delimiters, char ***argvp);
void freeArgv(int argc, char** argv);
void printArgv(FILE* file, int argc, char** argv, char*);

char *argv2String(int argc, char** argv, const char* seperator);


#endif /* _IOP_ARGV_H */
