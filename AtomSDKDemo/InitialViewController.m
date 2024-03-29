//
//  InitialViewController.m
//  AtomSDKDemo
//
//
//  Copyright © AtomBySecure 2019 Atom. All rights reserved.
//

#import "InitialViewController.h"
#import "AppDelegate.h"

@interface InitialViewController ()
@end

@implementation InitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if (self.txtSecretKey.stringValue.length>0) {
        AppDelegate* appDelegate = ((AppDelegate *)[NSApplication sharedApplication].delegate);
        appDelegate.secretKey = self.txtSecretKey.stringValue;
        
         AtomConfiguration *atomConfiguration = [[AtomConfiguration alloc] init];
         atomConfiguration.secretKey = self.txtSecretKey.stringValue;
         atomConfiguration.vpnInterfaceName = @"Atom";
        self.shareInstance = [AtomManager sharedInstanceWithAtomConfiguration:atomConfiguration];
        
        
        if(self.shareInstance) return YES;
        return NO;
    }else{
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Secret Key is required."];
        [alert runModal];
    }
    return NO;
}

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
}


@end
