//
//  InitialViewController.h
//  AtomSDKSample
//
//       
//  Copyright © 2018  Atom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AtomSDK/AtomSDK.h>

@interface InitialViewController : NSViewController

@property (weak) IBOutlet NSTextField *txtSecretKey;
@property (nonatomic, strong) AtomManager* shareInstance;
@end
