//
//  OpenManifoldDocument.h
//  OpenManifold
//
//  Created by Allan William Martin on 7/22/09.
//  Copyright Anomalus Design 2009 . All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "opennurbs_interface.h"


#define GEOMETRY      1
#define UI            2
#define PARAMETER     3
#define PART          4
#define ASSEMBLY      5

#define DIAGRAM_PART  6
#define DIAGRAM_RULE  7


#define OUTLINE       1
#define FILLED        2

@interface OpenManifoldDocument : NSDocument
{
  NSMutableArray* parts;
  NSMutableArray* rules;
  NSMutableArray* animators;
  NSMutableArray* dirtyNodeList;
  
  ON_Wrapper* wrap;
  
  id wc;
  id scriptingPanel;
  id scriptsBrowserPanel;
  id diagramPanel;
  
  int editingMode;
  int renderingMode;
  
  NSTimer* timer;
}

/** An array of all the part contained in this document.
 *  This will soon be replaced by assemblies.
 */
@property (nonatomic, retain) NSMutableArray* parts;

@property (nonatomic, retain) NSMutableArray* rules;

@property (nonatomic, retain) NSMutableArray* animators;

@property (nonatomic, retain) NSMutableArray* dirtyNodeList;

/** Writes a 3dm file of all the Geometry objects in the scene.
 */
- (IBAction) export:(id)sender;

- (void) import:(id)sender;

- (void) openInScriptingPanel:(NSString*)path;

- (IBAction) pickEditingMode:(id)sender;

- (IBAction) pickRenderingMode:(id)sender;

- (void) setEditingMode:(int)newMode;

- (int) getEditingMode;

/** Method updates all the relations.
 */
- (void) updateGraph;

- (NSMutableArray*) getAllDirtyNodes;

- (void) draw:(BOOL)select zoom:(float)zoom;

- (void) drawDiagram:(BOOL)select;

- (void) dragPartInDiagram: (int)partIndex dx:(float)dx dy:(float)dy;

- (void) refreshView;

/** Rebuilds the display list during the selection/picking process. 
 *  This makes sure the opengl names are added to the selectBuffer.
 */
- (void) build;

- (void) addToSelection:(int)globalObjectIndex;

- (void) unselectAll;

/** Adds an empty part with no geometry. 
 *  First renders as a wire cube. This adds the part to the parts
 *  array. Sending addSurface to the new part will add a generic NURBS surface.
 *  @return An id to the new Part.
 */
- (id) addPart;

- (void) refreshMainWindow;

/** Menu item action to render in OpenGL fill mode.
 *  @param sender The sender of the action.
 */
- (IBAction) displayModeFill:(id)sender;

/** Menu item action to render in OpenGL outline mode.
 *  @param sender The sender of the action.
 */
- (IBAction) displayModeOutline:(id)sender;

/** Toggles the document-level scripting panel on and off. 
 *  @param sender The sender of the action.
 */
- (IBAction) toggleScriptingPanel:(id)sender;

/** Toggles the scripts browser panel on and off. 
 *  @param sender The sender of the action.
 */
- (IBAction) toggleScriptsBrowserPanel:(id)sender;

/** Toggles the diagram panel on and off. 
 *  @param sender The sender of the action.
 */
- (IBAction) toggleDiagramPanel:(id)sender;

/** Toggles the floating or non-floating status of all panels.
 *  Useful for sending windows to the back when needed.
 */
- (IBAction) toggleFloating:(id)sender;

/** Calls all the animation objects.
 */
- (void) animate;

- (void) addAnimator:(id)anim;

/** An action that passes an evaluate message to the scripting window.
 *  @param sender The sender of the action.
 */
- (IBAction) evaluate:(id)sender;

/** An action that evaluates the Ruby code in the scripting panel.
 *  The scripting panel has an action that receives the event, then it passes the 
 *  event and the script  to the document where it is evaluated. This action sets 
 *  the @openmanifold Ruby instance variable so it refers to the current document. It will 
 *  probably also set other instance variables available depending on the script and 
 *  either the selected parts or according to the diagram view.
 *  @param sender The sender of the action.
 */
- (NSString *) evaluateRuby:(NSString *)stringToEvaluate;

/** Returns a reference to the main window controller.
 */
- (id) getWindowController;

/** Returns an array of all the selected parts.
 */
- (NSMutableArray *) getSelectedParts;


- (IBAction) showPreferences:(id)sender;

- (IBAction) toggleInspectorPanel:(id)sender;

@end
