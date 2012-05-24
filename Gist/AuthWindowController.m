//
//  AuthWindowController.m
//  Gist
//
//  Created by Atsushi Nagase on 5/24/12.
//  Copyright (c) 2012 LittleApps Inc. All rights reserved.
//

#import "AuthWindowController.h"
#import "GistPlugin.h"
#import <GitHubKit/GitHubKit.h>

@interface AuthWindowController ()

@end

@implementation AuthWindowController
@synthesize progressIndicator
, webView
, plugin = _plugin
;

- (id)initWithPlugin:(GistPlugin *)plugin {
  if(self=[super initWithWindowNibName:@"AuthWindowController" owner:self]) {
    self.plugin = plugin;
  }
  return self;
}

#pragma mark - NSWindowController Methods

- (void)windowDidLoad {
  [super windowDidLoad];
}

- (void)showWindow:(id)sender {
  self.window.alphaValue = 0;
  [super showWindow:self];
  [self.window makeKeyAndOrderFront:self];
  [self.progressIndicator startAnimation:self];
  while (self.window.alphaValue < 1) {
    self.window.alphaValue += 0.1;
    [NSThread sleepForTimeInterval:0.020];
  }
}

- (void)close {
  while (self.window.alphaValue > 0) {
    self.window.alphaValue -= 0.1;
    [NSThread sleepForTimeInterval:0.020];
  }
  [super close];
}

#pragma mark - WebResourceLoadDelegate Methods

- (NSURLRequest *)webView:(WebView *)sender
                 resource:(id)identifier willSendRequest:(NSURLRequest *)request
         redirectResponse:(NSURLResponse *)redirectResponse
           fromDataSource:(WebDataSource *)dataSource {
  if([self.plugin.github handleOpenURL:request.URL completionHandler:^(GHKAPIResponse *res){
    NSString *accessToken = self.plugin.github.accessToken;
    if([accessToken isKindOfClass:[NSString class]] && ![accessToken isEqualToString:@""])
      [self.plugin didAuthenticationComplete];
    [self close];
  }]) return nil;
  return request;
}

- (void)webView:(WebView *)sender resource:(id)identifier didFinishLoadingFromDataSource:(WebDataSource *)dataSource {
  [self.progressIndicator stopAnimation:self];
}


@end
