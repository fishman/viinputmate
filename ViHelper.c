/*
 *  ViHelper.c
 *  ViMate
 *
 *  Created by Kirt Fitzpatrick on 5/13/07.
 *  Copyright 2007 __MyCompanyName__. All rights reserved.
 *
 */

#include "ViHelper.h"

void ViLog( void *str, ... )
{
	if ( debugOn ) {
        va_list arg_list;
        va_start( arg_list, str );
		NSLogv( str, arg_list );
        va_end( arg_list );
	}
}
