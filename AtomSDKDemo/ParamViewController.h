//
//  ParamViewController.h
//  AtomSDKDemo
//
//      
//  Copyright © 2018  Atom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AtomSDK/AtomSDK.h>

@interface ParamViewController : NSViewController<AtomManagerDelegate,NSComboBoxDelegate,NSComboBoxDataSource>

@property (nonatomic, strong) AtomManager* shareInstance;

@property (weak) IBOutlet NSButton *btnOptimizeCountry;
@property (weak) IBOutlet NSButton *btnSmartDialing;
@property (unsafe_unretained) IBOutlet NSTextView *txtLogs;
@property (weak) IBOutlet NSButton *vpnButton;
@property (weak) IBOutlet NSComboBox *countryComboBox;
@property (weak) IBOutlet NSComboBox *protocolComboBox;
@end
