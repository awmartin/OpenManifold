/* PythonController 
 Tobias Lensing 
 http://www.tlensing.org
 http://blog.tlensing.org/2008/11/04/embedding-python-in-a-cocoa-application/
 */


#import <Cocoa/Cocoa.h>

@interface PythonController : NSObject
{
  IBOutlet id scriptingPanel;
}

- (void) evaluatePython: (NSString*)stringToEvaluate;
- (void) pythonOut: (NSString*)string;

@end
