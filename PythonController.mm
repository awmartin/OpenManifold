
#import "PythonController.h"
#import "ScriptingPanelController.h"

#ifdef PYTHON
#import <Python/Python.h>

// Global pointer to python controller
PythonController* g_pPythonController;

// Log function for redirecting stdout to the NSTextView
PyObject* log_CaptureStdout(PyObject* self, PyObject* pArgs)
{
	char* LogStr = NULL;
	if (!PyArg_ParseTuple(pArgs, "s", &LogStr)) return NULL;

	[g_pPythonController pythonOut: [NSString stringWithUTF8String: LogStr]];

	Py_INCREF(Py_None);
	return Py_None;
}

// Log function for redirecting stderr to the NSTextView
PyObject* log_CaptureStderr(PyObject* self, PyObject* pArgs)
{
	char* LogStr = NULL;
	if (!PyArg_ParseTuple(pArgs, "s", &LogStr)) return NULL;

	[g_pPythonController pythonOut: [NSString stringWithUTF8String: LogStr]];

	Py_INCREF(Py_None);
	return Py_None;
}

static PyMethodDef logMethods[] = {
	{"CaptureStdout", log_CaptureStdout, METH_VARARGS, "Logs stdout"},
	{"CaptureStderr", log_CaptureStderr, METH_VARARGS, "Logs stderr"},
	{NULL, NULL, 0, NULL}
};

#endif

// Controller implementation

@implementation PythonController

#ifdef PYTHON
- (void)awakeFromNib
{
	g_pPythonController = self;

	// Set program name
	Py_SetProgramName("Python Console");

	// Initialize the Python interpreter.
	Py_Initialize();

	Py_InitModule("log", logMethods);
	
	PyRun_SimpleString(
		"import log\n"
		"import sys\n"
		"class StdoutCatcher:\n"
		"\tdef write(self, str):\n"
		"\t\tlog.CaptureStdout(str)\n"
		"class StderrCatcher:\n"
		"\tdef write(self, str):\n"
		"\t\tlog.CaptureStderr(str)\n"
		"sys.stdout = StdoutCatcher()\n"
		"sys.stderr = StderrCatcher()\n"
    "from objc import *\n"
    "from Foundation import *\n"
    "import math\n"
    "_documentController = NSDocumentController.sharedDocumentController()\n"
		);

	PyRun_SimpleString("print 'Python console ready'\n");
}
#endif

- (void) evaluatePython: (NSString*)stringToEvaluate
{
#ifdef PYTHON
  NSString* prepended = [@"_openmanifold = _documentController.currentDocument()\n" stringByAppendingString: stringToEvaluate];
	PyRun_SimpleString([[prepended stringByAppendingString: @"\n"] UTF8String]);
#endif
}


- (void) pythonOut: (NSString*)string
{
  [ scriptingPanel addStringToResult:string ];
}

@end
