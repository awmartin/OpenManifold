//
//  MainDocumentView.m
//  OpenManifold
//
//  Created by Allan William Martin on 7/22/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import "MainDocumentView.h"
#import "OpenManifoldDocumentController.h"

@implementation MainDocumentView

- (id) initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  if( self != nil ){
    mani = [[Manipulator alloc] init];
    [mani retain];
    
    maniPos = new double[3];
    dirPos = new double[3];
    clickPos = new double[2];
    dragDistance = 0;
  }
  return self;
}

- (void) onKeyDown:(char)key
{
  
  printf("You just pressed: %c.\n", key);
  
  if( key == 27 ){
    [mani reset];
  }
  
  if( key == ' ' )
    [[OpenManifoldDocumentController sharedDocumentController] toggleKeyboardReferencePanel];
  
  if( key == 'a' )
    [[theController getDocument] addPart];
  
  if( key == 'x' )
    [[theController getDocument] refreshView];
  
  if( key == 'e' )
    [mani setMode:SCALE];
  
  if( key == 'r' )
    [mani setMode:ROTATE];
  
  if( key == 't' )
    [mani setMode:TRANSLATE];
  
  if( key == '1' ){
    [[theController getDocument] setEditingMode:PARAMETER];
    [theController setEditingModeSelect:PARAMETER];
  }
  
  if( key == '2' ){
    [[theController getDocument] setEditingMode:GEOMETRY];
    [theController setEditingModeSelect:GEOMETRY];
  }
  
  if( key == '3' ){
    [[theController getDocument] setEditingMode:PART];
    [theController setEditingModeSelect:PART];
  }
  
  if( key == '4' ){
    [[theController getDocument] displayModeOutline:nil];
    [theController setRenderingModeSelect:OUTLINE];
  }
  
  if( key == '5' ){
    [[theController getDocument] displayModeFill:nil];
    [theController setRenderingModeSelect:FILLED];
  }
}

#pragma mark -
#pragma mark Mouse Events.

- (void) onMouseDown
{
  if( altKeyDown ) return; // We're using Maya navigation style, so abort here and let the drag take over.
  
  printf("\n\n--------------------\nOooh click!\n");
  
  select = YES;
  
  startBoxSelectX = mouseX;
  startBoxSelectY = mouseY;
  
  [self setNeedsDisplay:YES];
}

- (void) onMouseUp
{
  [mani stopDrag];
  
  printf("Mouse Up!\n");
  
  if( lastOperation == BOX_SELECT || lastOperation == MOUSE_DOWN ){
    printf("Selecting the box!\n");
    select = YES;
    [self setNeedsDisplay:YES];
  }
}

- (void) onMouseDrag
{
  if( currentOperation == MOUSE_DOWN ){
    [self setOperation:BOX_SELECT];
    [self setNeedsDisplay:YES];
    return;
  } else if( currentOperation == BOX_SELECT ){
    [self setNeedsDisplay:YES];
    return;
  }
  
  if( altKeyDown ){
    [self orbit];
    return;
  }
  
  int editingMode = [[theController document] getEditingMode];
  
  if( [mani isDragging] ){

    if( [mani getMode] == TRANSLATE ){
      
      if( [mani getDraggingAxis] == X_AXIS )
        [mani updateX:[self getDeltaDrag]];
      
      
      if( [mani getDraggingAxis] == Y_AXIS )
        [mani updateY:[self getDeltaDrag]];
      
      
      if( [mani getDraggingAxis] == Z_AXIS )
        [mani updateZ:[self getDeltaDrag]];
        
      
      if( editingMode == GEOMETRY ){
        NSArray* parts = [[theController document] parts];
        
        for( int i=0; i<[parts count]; i++ ){
          NSArray* geometryIndices = [[parts objectAtIndex:i] indicesForSelectedGeometry];
          
          for( int j=0; j<[geometryIndices count]; j++ ){
            int geometryIndex = [[geometryIndices objectAtIndex:j] intValue];
            
            if( [mani getDraggingAxis] == X_AXIS )
              [[parts objectAtIndex:i] translateGeometry:geometryIndex dx:[self getDeltaDrag] dy:0 dz:0 ];
            
            if( [mani getDraggingAxis] == Y_AXIS )
              [[parts objectAtIndex:i] translateGeometry:geometryIndex dx:0 dy:[self getDeltaDrag] dz:0 ];
            
            if( [mani getDraggingAxis] == Z_AXIS )
              [[parts objectAtIndex:i] translateGeometry:geometryIndex dx:0 dy:0 dz:[self getDeltaDrag] ];
            
          }
          
        }
      } // end GEOMETRY case
      
      if( editingMode == PART ){
        NSArray* parts = [[theController document] getSelectedParts];
        
        if( [mani getDraggingAxis] == X_AXIS )
          for( int i=0; i<[parts count]; i++ )
            [[parts objectAtIndex:i] translate:[self getDeltaDrag] dy:0 dz:0];
        
        if( [mani getDraggingAxis] == Y_AXIS )
          for( int i=0; i<[parts count]; i++ )
            [[parts objectAtIndex:i] translate:0 dy:[self getDeltaDrag] dz:0];
        
        if( [mani getDraggingAxis] == Z_AXIS )
          for( int i=0; i<[parts count]; i++ )
            [[parts objectAtIndex:i] translate:0 dy:0 dz:[self getDeltaDrag]];
        
      } // end PART case
      
    } // end TRANSLATE case
    
    if( [mani getMode] == ROTATE ){

      if( editingMode == PARAMETER ){
        
      }
      
      if( editingMode == GEOMETRY ){
        NSArray* parts = [[theController document] parts];
        
        for( int i=0; i<[parts count]; i++ ){
          NSArray* geometryIndices = [[parts objectAtIndex:i] indicesForSelectedGeometry];
          
          for( int j=0; j<[geometryIndices count]; j++ ){
            int geometryIndex = [[geometryIndices objectAtIndex:j] intValue];
            
            if( [mani getDraggingAxis] == X_AXIS )
              [[parts objectAtIndex:i] rotateGeometryX:geometryIndex angle:(mouseX-pMouseX)/100.0f centerX:[mani getX] centerY:[mani getY] centerZ:[mani getZ] ];
            
            if( [mani getDraggingAxis] == Y_AXIS )
              [[parts objectAtIndex:i] rotateGeometryY:geometryIndex angle:(mouseX-pMouseX)/100.0f centerX:[mani getX] centerY:[mani getY] centerZ:[mani getZ] ];
            
            if( [mani getDraggingAxis] == Z_AXIS )
              [[parts objectAtIndex:i] rotateGeometryZ:geometryIndex angle:(mouseX-pMouseX)/100.0f centerX:[mani getX] centerY:[mani getY] centerZ:[mani getZ] ];
            
          }
          
        }
      } // end GEOMETRY case
      
      if( editingMode == PART ){
        NSArray* parts = [[theController document] getSelectedParts];
        
        if( [mani getDraggingAxis] == X_AXIS )
          for( int i=0; i<[parts count]; i++ )
            [[parts objectAtIndex:i] rotateX:(mouseX-pMouseX)/100.0f centerX:[mani getX] centerY:[mani getY] centerZ:[mani getZ]];
        
        if( [mani getDraggingAxis] == Y_AXIS )
          for( int i=0; i<[parts count]; i++ )
            [[parts objectAtIndex:i] rotateY:(mouseX-pMouseX)/100.0f centerX:[mani getX] centerY:[mani getY] centerZ:[mani getZ]];
        
        if( [mani getDraggingAxis] == Z_AXIS )
          for( int i=0; i<[parts count]; i++ )
            [[parts objectAtIndex:i] rotateZ:(mouseX-pMouseX)/100.0f centerX:[mani getX] centerY:[mani getY] centerZ:[mani getZ]];
        
      } // end PART case
      
    } // end ROTATE case
    
    if( [mani getMode] == SCALE ){
      
      if( editingMode == PARAMETER ){
      
      }
      
      if( editingMode == GEOMETRY ){
        
        NSArray* parts = [[theController document] parts];
        
        for( int i=0; i<[parts count]; i++ ){
          NSArray* geometryIndices = [[parts objectAtIndex:i] indicesForSelectedGeometry];
          
          for( int j=0; j<[geometryIndices count]; j++ ){
            int geometryIndex = [[geometryIndices objectAtIndex:j] intValue];
            
            if( [mani getDraggingAxis] == X_AXIS )
              [[parts objectAtIndex:i] scaleGeometry:geometryIndex x:1+[self getDeltaDrag] y:1 z:1 ];
            
            if( [mani getDraggingAxis] == Y_AXIS )
              [[parts objectAtIndex:i] scaleGeometry:geometryIndex x:1 y:1+[self getDeltaDrag] z:1 ];
            
            if( [mani getDraggingAxis] == Z_AXIS )
              [[parts objectAtIndex:i] scaleGeometry:geometryIndex x:1 y:1 z:1+[self getDeltaDrag] ];
            
          } // end geometries loop
          
        } // end parts loop
        
      } // end GEOMETRY case
      
      if( editingMode == PART ){
        NSArray* parts = [[theController document] getSelectedParts];
        
        if( [mani getDraggingAxis] == X_AXIS )
          for( int i=0; i<[parts count]; i++ )
            [[parts objectAtIndex:i] scale:1+[self getDeltaDrag] y:1 z:1 ];
        
        
        if( [mani getDraggingAxis] == Y_AXIS )
          for( int i=0; i<[parts count]; i++ )
            [[parts objectAtIndex:i] scale:1 y:1+[self getDeltaDrag] z:1 ];
        
        
        if( [mani getDraggingAxis] == Z_AXIS )
          for( int i=0; i<[parts count]; i++ )
            [[parts objectAtIndex:i] scale:1 y:1 z:1+[self getDeltaDrag] ];
        
      } // end PART case
      
    } // end SCALE case
    
    [[theController getDocument] updateGraph];
    
    [self build];
    [self setNeedsDisplay:YES];
  }
}

#pragma mark -
#pragma mark Drawing.

- (void) build
{
  [[theController getDocument] build];
}

/* The actual drawing function. */
- (void) draw
{
  // If we're selecting, then we need to rebuild the displaylist.
  if( select )
    [self build];
  
  [mani draw:select zoom:zoomFactor];

  [[theController getDocument] draw:select zoom:zoomFactor];
}

- (void) drawHUD
{
  
  if( currentOperation == BOX_SELECT ){
    glDisable(GL_LIGHTING);
    glDisable(GL_DEPTH_TEST);
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();

    glOrtho (0, width, height, 0, 0, 1);
    
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    glLoadIdentity();
    
    glTranslatef(0.375, 0.375, 0);
    glScalef( 1.0, -1.0, 1.0 );
    glTranslatef( 0, -height, 0 );

    glColor4f( 1.0f, 1.0f, 1.0f, 0.1f );
    glBegin( GL_LINE_LOOP );
    
    glVertex3f( startBoxSelectX, startBoxSelectY, 0 );
    glVertex3f( startBoxSelectX, mouseY, 0 );
    glVertex3f( mouseX, mouseY, 0 );
    glVertex3f( mouseX, startBoxSelectY, 0 );
    glEnd();
    
    glPopMatrix();
    
    glEnable(GL_LIGHTING);
    glEnable(GL_DEPTH_TEST);
  }
}

- (void) setManipulatorTarget:(Parameter *)param
{
  [mani setTarget:param];
}

- (void) calculateDragPath:(int)axis
{
  glPushMatrix();
  
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  gluPerspective( 60, aspect, 1.0, 200.0 );
  glMatrixMode(GL_MODELVIEW);
  glPushMatrix();
  glLoadIdentity();
  
  gluLookAt(eyeX, eyeY, eyeZ, originX, originY, originZ, 0.0f, 1.0f, 0.0f);
  
  GLdouble modelMatrix[16];
  glGetDoublev(GL_MODELVIEW_MATRIX,modelMatrix);
  
  GLdouble projMatrix[16];
  glGetDoublev(GL_PROJECTION_MATRIX,projMatrix);
  
  int view[4];
  glGetIntegerv(GL_VIEWPORT,view);
  
  int success = gluProject( [mani getX], [mani getY], [mani getZ],
               modelMatrix, projMatrix, view,
               &maniPos[0], &maniPos[1], &maniPos[2] );
  if( !success ) return;
  
  if( axis == X_AXIS ){
    int success = gluProject( [mani getX] + 1.0f, [mani getY], [mani getZ],
               modelMatrix, projMatrix, view,
               &dirPos[0], &dirPos[1], &dirPos[2] );
    if( !success ) return;
  } else if ( axis == Y_AXIS ) {
    int success = gluProject( [mani getX], [mani getY] + 1.0f, [mani getZ],
               modelMatrix, projMatrix, view,
               &dirPos[0], &dirPos[1], &dirPos[2] );
    if( !success ) return;
  } else if ( axis == Z_AXIS ){
    int success = gluProject( [mani getX], [mani getY], [mani getZ] + 1.0f,
               modelMatrix, projMatrix, view,
               &dirPos[0], &dirPos[1], &dirPos[2] );
    if( !success ) return;
  }
  
  clickPos[0] = mouseX;
  clickPos[1] = mouseY;
  
  dragDistance = 0;
  
  glPopMatrix();
  [self getDeltaDrag];
}

- (double) getDeltaDrag
{
  // Calculates the dot product.
  double handleAngle = atan2( dirPos[1] - maniPos[1], dirPos[0] - maniPos[0] );
  double handleLength = sqrt( pow(dirPos[0] - maniPos[0], 2) + pow( dirPos[1] - maniPos[1], 2) );
  
  double dragAngle = atan2( mouseY - pMouseY, mouseX - pMouseX );
  double dragLength = sqrt( pow(mouseX - pMouseX,2) + pow(mouseY - pMouseY,2) );
  
  double angle = dragAngle - handleAngle;
  
  // Dot product without the handle length to scale the drag down.
  double dotProduct = dragLength * cos(angle);
  
  return dotProduct/handleLength;
}

- (void) handleMouseDownSelection
{
  if( hits == 0 ){
    [[theController getDocument] unselectAll];
    return;
  }
  
  unsigned int i;
  GLuint numNames, *ptr;
  
  printf("number of hits = %d\n", hits);
  
  ptr = (GLuint *) selectBuf;
  
  for (i = 0; i < hits; i++) {
    numNames = *ptr;
    printf(" number of names for this hit = %d\n", numNames);
    
    if( numNames > 0 ){
      
      ptr++;
      // Min and max window-coordinate z values.
      printf(" z1 is %u; ", *ptr);
      ptr++;
      printf(" z2 is %u\n", *ptr);
      
      
      //The names are:
      printf(" The names are:\n");
      
      if( numNames == 2 ) {
        // The first name is the group. The second is the opengl name of the object.
        ptr++;
        int group = *ptr;
        printf( "  object group = %d | ", group );
        
        if( group == GEOMETRY or group == PART ){
          // Do nothing.
          for( int j=0;j<numNames-1;j++ ){
            ptr++;
            printf( " %d,", *ptr );
          }
          
        } else if( group == UI ){
          // Only check for UI elements to drag.
          
          ptr++;
          int globalInterfaceIndex = *ptr;
          printf("interface object = %d\n", globalInterfaceIndex);
          
          if( globalInterfaceIndex >= 0 and globalInterfaceIndex <= 8 ){
            [self calculateDragPath:(globalInterfaceIndex%3)];
            [mani startDrag:globalInterfaceIndex];
            [self setOperation:MANIPULATE];
          }
          
        } else {
          // Nothing.
          for( int j=0;j<numNames-1;j++ ){
            ptr++;
            printf( " %d,", *ptr );
          }
        }
        
      } else if( numNames == 3 ){
        ptr++;
        int group = *ptr;
        printf( "  object group = %d | ", group );
        
        if( group == PARAMETER ){
          // Do nothing.
          
          for( int j=0;j<numNames-1;j++ ){
            ptr++;
            printf( " %d,", *ptr );
          }
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


- (void) handleMouseUpSelection
{
  // Handles the selection of geometry on mouse up events.
  if( !shiftKeyDown )
    [mani clearSelection];
  
  unsigned int i;
  GLuint numNames, *ptr;
  
  printf("number of hits = %d\n", hits);
  
  ptr = (GLuint *) selectBuf;
  
  for (i = 0; i < hits; i++) {
    numNames = *ptr;
    printf(" number of names for this hit = %d\n", numNames);
    
    if( numNames > 0 ){
      
      ptr++;
      // Min and max window-coordinate z values.
      printf(" z1 is %u; ", *ptr);
      ptr++;
      printf(" z2 is %u\n", *ptr);
      
      //The names are:
      printf(" The names are:\n");
      
      if( numNames == 2 ) {
        // The first name is the group. The second is the opengl name of the object.
        ptr++;
        int group = *ptr;
        printf( "  object group = %d | ", group );
        
        if( group == GEOMETRY or group == PART ){
          
          ptr++;
          int globalObjectIndex = *ptr;
          printf("geometry object = %d\n", globalObjectIndex);
          [[theController getDocument] addToSelection:globalObjectIndex];
          
        } else if( group == UI ){
          
          // Do nothing.
          for( int j=0;j<numNames-1;j++ ){
            ptr++;
            printf( " %d,", *ptr );
          }
          
        } else {
          // Nothing.
          for( int j=0;j<numNames-1;j++ ){
            ptr++;
            printf( " %d,", *ptr );
          }
        }
        
      } else if( numNames == 3 ){
        ptr++;
        int group = *ptr;
        printf( "  object group = %d | ", group );
        
        if( group == PARAMETER ){
          ptr++;
          int partIndex = *ptr;
          printf( "part = %d | ", partIndex );
          
          ptr++;
          int parameterIndex = *ptr;
          printf( "parameter = %d | ", parameterIndex );
          
          id doc = [theController getDocument];
          id part = [[doc parts] objectAtIndex:partIndex];
          id parameter = [[part parameters] objectAtIndex:parameterIndex];
          
          [mani addTarget:parameter];
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
