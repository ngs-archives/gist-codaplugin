//
//  GistPlugin.h
//  Gist
//
//  Created by Atsushi Nagase on 5/24/12.
//  Copyright (c) 2012 LittleApps Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CodaPlugInsController.h"

@class GHKGitHub;
@interface GistPlugin : NSObject<CodaPlugIn>

@property (readonly) GHKGitHub *github;

- (void)didAuthenticationComplete;
- (void)createPrivateGist:(id)sender;
- (void)createPublicGist:(id)sender;
- (void)logout:(id)sender;
- (void)printText:(NSString *)text;

@end
