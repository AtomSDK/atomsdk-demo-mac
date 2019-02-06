//
//  PSKViewController.m
//  AtomSDKDemo
//
//        
//  Copyright © 2018  Atom. All rights reserved.
//

#import "PSKViewController.h"
#import "AppDelegate.h"
#define ButtonTitleConnect @"Connect"
#define ButtonTitleCancel @"Cancel"
#define ButtonTitleDisconnect @"Disconnect"

@interface PSKViewController ()
{
    AppDelegate* appDelegate;
}
@end

@implementation PSKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    appDelegate = ((AppDelegate *)[NSApplication sharedApplication].delegate);
    self.shareInstance = [AtomManager sharedInstance];
    [self.shareInstance setDelegate:self];
    [self setupVPNSDKStateChangeManager];
    [self.txtLogs setTextColor:[NSColor whiteColor]];
}

- (void)viewWillAppear{
    if(self.shareInstance.getCurrentVPNStatus == CONNECTED){
        [self.vpnButton setTitle:ButtonTitleDisconnect];
    }else if(self.shareInstance.getCurrentVPNStatus == DISCONNECTED){
        [self.vpnButton setTitle:ButtonTitleConnect];
    }

}
- (IBAction)buttonAction:(id)sender {
    if([self validateCredentials]){
        if(self.shareInstance.getCurrentVPNStatus == CONNECTED){
            [self.shareInstance disconnectVPN];
        }else if(self.shareInstance.getCurrentVPNStatus == DISCONNECTED){
            [self.vpnButton setTitle:ButtonTitleCancel];
            [self connectWithPsk:sender];
        }else {
            [self.vpnButton setTitle:ButtonTitleCancel];
            [self.shareInstance cancelVPN];
        }
    }
}
- (void)cancleConnection{
    [self.shareInstance cancelVPN];
}
- (void)disconnectConnection{
    [self.shareInstance disconnectVPN];
}
- (void)connectWithPsk:(id)sender {
    
    //Implement statusDidChangedHandler
    [self setupVPNSDKStateChangeManager];
    
    if(appDelegate.isAutoGenerateUserCredential){
        //Initialize with universally unique identifiers
        self.shareInstance.UUID = appDelegate.uuid;
    }else{
        //Initialize with credential
        self.shareInstance.atomCredential = [[AtomCredential alloc] initWithUsername:appDelegate.username password:appDelegate.userPassword];
    }
    //initialize with property
    AtomProperties* properties = [[AtomProperties alloc] initWithPreSharedKey:self.txtPreSharedKey.stringValue];
    
    //Connect with properties
    [self.shareInstance connectWithProperties:properties completion:^(NSString *success) {
        
    } errorBlock:^(NSError *error) {
        //NSLog(@"error  %@",error);
        [self.txtLogs setString: error.description];
        [self.vpnButton setTitle:ButtonTitleConnect];
    }];
}
- (BOOL)validateCredentials{
     [self.txtLogs setString: @""];
    if(self.txtPreSharedKey.stringValue.length == 0){
        [self showAlert:@"Enter your Pre-Shared Key to continue."];
        return false;
    }else
    if(appDelegate.isAutoGenerateUserCredential){
        if(appDelegate.uuid.length == 0){
            [self showAlert:@"UUID is required for generating vpn credentials to connect VPN."];
            return false;
        }else return true;
    }else{
        if(appDelegate.username.length == 0){
            [self showAlert:@"Username & Password is required for connecting VPN."];
            return false;
        }else if(appDelegate.userPassword.length == 0){
            [self showAlert:@"Username & Password is required for connecting VPN."];
            return false;
        }
    }
    return true;
}
-(void)showAlert:(NSString*) message{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:message];
    [alert runModal];
}
#pragma mark sdk delegates
- (void)atomManagerDidConnect:(AtomConnectionDetails *)atomConnectionDetails{
    //NSLog(@"%s",__PRETTY_FUNCTION__);
}
- (void)atomManagerDidDisconnect:(AtomConnectionDetails *)atomConnectionDetails{
    //NSLog(@"%s",__PRETTY_FUNCTION__);
}
- (void)atomManagerOnRedialing:(AtomConnectionDetails *)atomConnectionDetails withError:(NSError *)error{
    //NSLog(@"%s",__PRETTY_FUNCTION__);
}
- (void)atomManagerDialErrorReceived:(NSError *)error withConnectionDetails:(AtomConnectionDetails *)atomConnectionDetails{
    //NSLog(@"%s",__PRETTY_FUNCTION__);
}
#pragma mark statusDidChangedHandler
- (void)setupVPNSDKStateChangeManager {
    
    NSMutableString *strStatus = [[NSMutableString alloc]init];
    __weak typeof(self) weakSelf = self;
    
    [AtomManager sharedInstance].stateDidChangedHandler = ^(AtomVPNState status) {
        switch (status) {
            case AtomStatusInvalid:
                [strStatus setString:@"AtomStatusInvalid"];
                [self.vpnButton setTitle:ButtonTitleConnect];
                break;
            case AtomStatusConnected:
                [strStatus setString:@"AtomStatusConnected"];
                [self.vpnButton setTitle:ButtonTitleDisconnect];
                break;
            case AtomStatusDisconnected:
                [strStatus setString:@"AtomStatusDisconnected"];
                [self.vpnButton setTitle:ButtonTitleConnect];
                break;
            case AtomStatusConnecting:
                [strStatus setString:@"AtomStatusConnecting"];
                break;
            case AtomStatusDisconnecting:
                [strStatus setString:@"AtomStatusDisconnecting"];
                break;
            case AtomStatusValidating:
                [strStatus setString:@"AtomStatusValidating"];
                break;
            case AtomStatusAuthenticating:
                [strStatus setString:@"AtomStatusAuthenticating"];
                break;
            case AtomStatusGettingFastestServer:
                [strStatus setString:@"AtomStatusGettingFastestServer"];
                break;
            case AtomStatusOptimizingConnection:
                [strStatus setString:@"AtomStatusOptimizingConnection"];
                break;
            case AtomStatusGeneratingCredentials:
                [strStatus setString:@"AtomStatusGeneratingCredentials"];
                break;
            default:
                break;
                
        }
        [weakSelf.txtLogs setString:[NSString stringWithFormat:@"%@ \n %@",weakSelf.txtLogs.string,strStatus]];
    };
}

@end
