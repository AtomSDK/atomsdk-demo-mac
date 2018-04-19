//
//  PSKViewController.h
//  AtomSDKSample
//
//        
//  Copyright © 2018  Atom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AtomSDK/AtomSDK.h>

@interface PSKViewController : NSViewController<AtomManagerDelegate>

@property (nonatomic, strong) AtomManager* shareInstance;
@property (weak) IBOutlet NSButton *vpnButton;
@property (weak) IBOutlet NSTextField *txtPreSharedKey;
@property (unsafe_unretained) IBOutlet NSTextView *txtLogs;
@end
