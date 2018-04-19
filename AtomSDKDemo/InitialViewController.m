//
//  InitialViewController.m
//  AtomSDKSample
//
//       
//  Copyright © 2018  Atom. All rights reserved.
//

#import "InitialViewController.h"
#import "AppDelegate.h"

@interface InitialViewController ()
@end

@implementation InitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    // Insert code here to initialize your application
   
}
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if (self.txtSecretKey.stringValue.length>0) {
        AppDelegate* appDelegate = ((AppDelegate *)[NSApplication sharedApplication].delegate);
        appDelegate.secretKey = self.txtSecretKey.stringValue;
        
        self.shareInstance = [AtomManager sharedInstanceWithSecretKey:self.txtSecretKey.stringValue];
        /*
         AtomConfiguration *atomConfiguration = [[AtomConfiguration alloc] init];
         atomConfiguration.secretKey = @"<#SECRETKEY_GOES_HERE#>>";
         atomConfiguration.vpnInterfaceName = @"Atom";
         atomConfiguration.baseUrl = [NSURL URLWithString:@"<#YOUR_BASE_URL#>"];
         [AtomManager sharedInstanceWithAtomConfiguration:atomConfiguration];
        */
        
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
