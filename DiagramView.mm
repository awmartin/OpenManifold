//
//  DiagramView.m
//  OpenManifold
//
//  Created by Allan William Martin on 8/5/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import "DiagramView.h"


@implementation DiagramView

- (id)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  if( self != nil ){
    dragging = NO;
    dragTarget = -1;
  }
  return self;
}

/* The actual drawing function. */
- (void) draw
{
  [self grid];
  
  glColor3f( 1.0, 0.5, 0.25 );
  [[theController getDocument] drawDiagram:select];
}

- (void) onMouseDown
{
  printf("\n\n--------------------\nOooh click!\n");
  select = YES;
  
  [self setNeedsDisplay:YES];
}

- (void) startDrag:(int) targetPartIndex
{
  dragTarget = targetPartIndex;
  dragging = YES;
}

- (void) onMouseDrag
{
  if( dragging and dragTarget != -1 ){
    //NSNumber* x = [NSNumber numberWithFloat:(mouseX-pMouseX)/scaleFactor];
    //NSNumber* y = [NSNumber numberWithFloat:(mouseY-pMouseY)/scaleFactor];
    [[theController getDocument] dragPartInDiagram:dragTarget dx:(mouseX-pMouseX)/(scaleFactor*zoom) dy:(mouseY-pMouseY)/(scaleFactor*zoom)];
    [self setNeedsDisplay:YES];
  }
}

- (void) onMouseUp
{
  dragging = false;
  dragTarget = -1;
}

- (void) handleMouseDownSelection
{
  if( hits == 0 ){
    //[[theController getDocument] unselectAll];
    return;
  }
  
  unsigned int i;
  GLuint numNames, *ptr;
  
  printf ("number of hits = %d\n", hits);
  
  ptr = (GLuint *) selectBuf;
  
  for (i = 0; i < hits; i++) {
    numNames = *ptr;
    printf (" number of names for this hit = %d\n", numNames);
    
    if( numNames > 0 ){
      
      ptr++;
      // Min and max window-coordinate z values.
      printf (" z1 is %u; ", *ptr);
      ptr++;
      printf ("z2 is %u\n", *ptr);
      
      //The names are:
      printf (" The names are:\n");
      
      if( numNames == 2 ){
        
        ptr++; // This advances to the group.
        int group = *ptr;
        
        if( group == DIAGRAM_PART or group == DIAGRAM_RULE ) {
          ptr++;
          int part = *ptr;
        
          [self startDrag:part];
        }
      } else {
        
        for( int j=0;j<numNames;j++ ){
          ptr++;
          printf( " %d,", *ptr );
        }
        
      }
      
      ptr++;
    } // end numNames > 0 check
    printf("\n");
    
  } // end hits list
}

@end
