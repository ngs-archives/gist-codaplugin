//
//  AuthWindowController.h
//  Gist
//
//  Created by Atsushi Nagase on 5/24/12.
//  Copyright (c) 2012 LittleApps Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class GistPlugin;
@interface AuthWindowController : NSWindowController

@property (weak) IBOutlet WebView *webView;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) GistPlugin *plugin;

- (id)initWithPlugin:(GistPlugin *)plugin;

@end
