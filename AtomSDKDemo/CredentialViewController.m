//
//  ViewController.m
//   AtomSDKDemo
//
//  Copyright © AtomBySecure 2019 Atom. All rights reserved.
//

#import "CredentialViewController.h"
#import "AppDelegate.h"
#import <AtomSDK/AtomSDK.h>

@interface CredentialViewController()<NSTextFieldDelegate>{
    AppDelegate* appDelegate;
}
@property (weak) IBOutlet NSTextField *txtUserName;
@property (weak) IBOutlet NSTextField *txtPassword;

@end

@implementation CredentialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSWindow *window = [NSApplication sharedApplication].windows[0];
    [window setDelegate:self];
    appDelegate = ((AppDelegate *)[NSApplication sharedApplication].delegate);
    [self.lblSecretKey setStringValue:appDelegate.secretKey];
    [self.txtUserName setDelegate:self];
    [self.txtPassword setDelegate:self];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    // Update the view, if already loaded.
}

- (IBAction) removeVPNProfile :(id)sender {
    [[AtomManager sharedInstance] removeVPNProfileWithCompletion:^(BOOL isSuccess) {
        [self getVPNRemoveProfileUpdateWithMessage: isSuccess ? @"YES" : @"NO"];
    }];
}

- (void) getVPNRemoveProfileUpdateWithMessage: (NSString *) message {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText: [NSString stringWithFormat:@"VPN Profile Removed: %@", message]];
    [alert runModal];
}

#pragma mark NSTextFiled delegate

-(void)controlTextDidEndEditing:(NSNotification *)aNotification{
}
-(void)controlTextDidChange:(NSNotification *)aNotification{
    NSTextField *textField = [aNotification object];
    if(textField.tag == 201) {
        //update user name
        appDelegate.username = textField.stringValue;
    } else if (textField.tag == 202) {
        //update password
        appDelegate.userPassword = textField.stringValue;
    }
    
}
-(void)controlTextDidBeginEditing:(NSNotification *)aNotification{
}
- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize{
    return CGSizeMake(450, 572);
}



@end
