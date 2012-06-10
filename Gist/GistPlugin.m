//
//  GistPlugin.m
//  Gist
//
//  Created by Atsushi Nagase on 5/24/12.
//  Copyright (c) 2012 LittleApps Inc. All rights reserved.
//

#import "GistPlugin-APIKey.h"
#import "GistPlugin.h"
#import "AuthWindowController.h"
#import <GitHubKit/GitHubKit.h>

@interface GistPlugin ()

- (id)initWithPlugInController:(CodaPlugInsController*)aController;
- (void)createGist:(BOOL)isPublic fromSelection:(BOOL)fromSelection;
- (void)sendPendingRequest;
- (void)showAuthWindow:(id)sender;

@property (nonatomic, strong) CodaPlugInsController *pluginController;
@property (nonatomic, strong) GHKAPIRequest *pendingRequest;
@property (nonatomic, readonly) AuthWindowController *authWindowController;

@end

@implementation GistPlugin

@synthesize pluginController = _pluginController
, authWindowController = _authWindowController
, pendingRequest = _pendingRequest
, github = _github
;

#pragma mark - CodaPlugin Methods

- (NSString *)name { return @"Gist"; }

- (id)initWithPlugInController:(CodaPlugInsController*)aController
                  plugInBundle:(NSObject <CodaPlugInBundle> *)plugInBundle {
  return self = [self initWithPlugInController:aController];
}

- (id)initWithPlugInController:(CodaPlugInsController *)aController
                        bundle:(NSBundle *)yourBundle {
  return self = [self initWithPlugInController:aController];
}

- (id)initWithPlugInController:(CodaPlugInsController*)aController {
  if(self=[self init]) {
    self.pluginController = aController;
    [aController registerActionWithTitle:NSLocalizedString(@"Create Private Gist", nil)
                   underSubmenuWithTitle:nil
                                  target:self
                                selector:@selector(createPrivateGist:)
                       representedObject:nil
                           keyEquivalent:@"^~@g"
                              pluginName:self.name];
    
    
    [aController registerActionWithTitle:NSLocalizedString(@"Create Public Gist", nil)
                   underSubmenuWithTitle:nil
                                  target:self
                                selector:@selector(createPublicGist:)
                       representedObject:nil
                           keyEquivalent:@"$^~@g"
                              pluginName:self.name];
    [aController registerActionWithTitle:NSLocalizedString(@"Create Private Gist from selection", nil)
                   underSubmenuWithTitle:nil
                                  target:self
                                selector:@selector(createPrivateGistFromSelection:)
                       representedObject:nil
                           keyEquivalent:@"^~@s"
                              pluginName:self.name];
    
    
    [aController registerActionWithTitle:NSLocalizedString(@"Create Public Gist from selection", nil)
                   underSubmenuWithTitle:nil
                                  target:self
                                selector:@selector(createPublicGistFromSelection:)
                       representedObject:nil
                           keyEquivalent:@"$^~@s"
                              pluginName:self.name];
    
    [aController registerActionWithTitle:NSLocalizedString(@"Logout", nil)
                                  target:self
                                selector:@selector(logout:)];
  }
  return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
  CodaTextView *textView = [self.pluginController focusedTextView:self];
  NSString *code = nil;
  if(aSelector == @selector(createPublicGist:) ||
     aSelector == @selector(createPrivateGist:)) {
    code = textView.string;
    return code && code.length > 0;
  }
  if(aSelector == @selector(createPublicGistFromSelection:) ||
     aSelector == @selector(createPrivateGistFromSelection:)) {
    code = textView.selectedText;
    return code && code.length > 0;
  }
  return [super respondsToSelector:aSelector];
}

#pragma mark - Accessors

- (GHKGitHub *)github {
  if(nil==_github) {
    _github = [[GHKGitHub alloc] initWithClientId:kGHClientID secret:kGHSecret callbackUrl:kGHCallback];
  }
  return _github;
}

- (AuthWindowController *)authWindowController {
  if(nil==_authWindowController) {
    _authWindowController = [[AuthWindowController alloc] initWithPlugin:self];
  }
  return _authWindowController;
}


#pragma mark - Actions

- (void)createPrivateGist:(id)sender {
  [self createGist:NO fromSelection:NO];
}

- (void)createPublicGist:(id)sender {
  [self createGist:YES fromSelection:NO];
}

- (void)createPrivateGistFromSelection:(id)sender {
  [self createGist:NO fromSelection:YES];
}

- (void)createPublicGistFromSelection:(id)sender {
  [self createGist:YES fromSelection:YES];
}

- (void)createGist:(BOOL)isPublic fromSelection:(BOOL)fromSelection {
  CodaTextView *tv = [self.pluginController focusedTextView:self];
  if(!tv) return;
  NSString *code = fromSelection ? tv.selectedText : tv.string;
  if(!code || !(code.length > 0)) return;
  GHKGist *gist = [[GHKGist alloc] init];
  GHKGistFile *file = [gist addEmptyFile];
  gist.isPublic = isPublic;
  file.content = code;
  if(tv.path) {
    NSURL *URL = [[NSURL alloc] initFileURLWithPath:tv.path isDirectory:NO];
    file.filename = URL.lastPathComponent;
  }
  self.pendingRequest = [GHKAPIRequest requestWithURL:GHKAPIURL(GHKAPIGists)
                                           HTTPMethod:@"POST"
                                           JSONObject:gist.dictionary];
  if(self.github.isLoggedIn)
    [self sendPendingRequest];
  else
    [self showAuthWindow:self];
}

- (void)sendPendingRequest {
  if(self.pendingRequest)
    [self.github
     sendAsynchronousRequest:self.pendingRequest
     completionHandler:^(GHKAPIResponse *res) {
       GHKGist *gist = res.first;
       [[NSWorkspace sharedWorkspace] openURL:gist.htmlUrl];
     }];
  self.pendingRequest = nil;
}

- (void)logout:(id)sender {
  NSURL *URL = [self.github loginURLWithScope:[NSArray arrayWithObject:@"gist"]];
  NSHTTPCookieStorage *s = [NSHTTPCookieStorage sharedHTTPCookieStorage];
  for (NSHTTPCookie *c in [s cookiesForURL:URL])
    [s deleteCookie:c];
  [self.github logout];
}

- (void)showAuthWindow:(id)sender {
  [self.authWindowController showWindow:self.authWindowController];
  NSURL *URL = [self.github loginURLWithScope:[NSArray arrayWithObject:@"gist"]];
  NSURLRequest *req = [NSURLRequest requestWithURL:URL];
  [[self.authWindowController.webView mainFrame] loadRequest:req];
}

- (void)printText:(NSString *)text {
  [[self.pluginController focusedTextView:self] insertText:text];
}

- (void)didAuthenticationComplete {
  [self sendPendingRequest];
}

#pragma mark - Private

@end
