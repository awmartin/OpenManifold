//
//  FSBrowserCell.h
//
//  Copyright (c) 2001-2007, Apple Inc. All rights reserved.
//
//  FSBrowserCell knows how to display file system info obtained from an FSNodeInfo object.

#import <Cocoa/Cocoa.h>

@interface ScriptsBrowserCell : NSBrowserCell { 
@private
    NSImage *iconImage;
    ScriptsNodeInfo *nodeInfo;
    BOOL drawsBackground;
}

- (void)setNodeInfo:(ScriptsNodeInfo *)value;
- (ScriptsNodeInfo *)nodeInfo;

- (void)setIconImage:(NSImage *)image;
- (NSImage *)iconImage;

- (void)loadCellContents;

@end