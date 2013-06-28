#include <stdlib.h>
#include <string.h>

#ifdef __APPLE__

#define MAC_OSX_TK
#import <Cocoa/Cocoa.h>
#include "ApplicationServices/ApplicationServices.h"

CGContextRef flipCairoAxes(CGContextRef context, int height)
{
  CGContextTranslateCTM(context, 0.0, height);
  CGContextScaleCTM(context, 1.0, -1.0);
  return context;
}

#endif
