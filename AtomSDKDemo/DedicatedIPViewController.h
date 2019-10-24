//
//  DedicatedIPViewController.h
//  AtomSDKDemo
//
//        
//  Copyright © 2018  Atom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AtomSDK/AtomSDK.h>

@interface DedicatedIPViewController : NSViewController<AtomManagerDelegate,NSComboBoxDelegate,NSComboBoxDataSource, NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, strong) AtomManager* shareInstance;
@property (weak) IBOutlet NSComboBox *protocolComboBox;
@property (weak) IBOutlet NSButton *vpnButton;
@property (weak) IBOutlet NSTextField *txtDedicatedIP;
@property (unsafe_unretained) IBOutlet NSTextView *txtLogs;
@property (weak) IBOutlet NSTableView *tagsTableview;
@property (nonatomic) NSArray *tagList;

@end
