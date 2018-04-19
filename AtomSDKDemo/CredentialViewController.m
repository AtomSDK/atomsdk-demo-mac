//
//  ViewController.m
//   AtomSDKDemo
//
//  Copyright ©  2018  Atom. All rights reserved.
//

#import "CredentialViewController.h"
#import "AppDelegate.h"

@interface CredentialViewController()<NSTextFieldDelegate>{
    AppDelegate* appDelegate;
}
@property (weak) IBOutlet NSButton *autoGenerateUserCredential;
@property (weak) IBOutlet NSTextField *txtUUID;
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
    [self.txtUUID setDelegate:self];

}
- (void)viewWillAppear{
}
- (IBAction)autoGenerateUserCredential:(id)sender {
    NSButton* btnUseOptimize = (NSButton*)sender;
    
    if(btnUseOptimize.state){
        appDelegate.isAutoGenerateUserCredential = true;
        [self.txtPassword setEnabled:NO];
        [self.txtUserName setEnabled:NO];
        [[self.txtUserName window] makeFirstResponder:nil];
        [self.txtUUID setEnabled:YES];
        [[self.view window] makeFirstResponder:[self txtUUID]];
        
    }else{
        appDelegate.isAutoGenerateUserCredential = false;
        [self.txtUUID setEnabled:NO];
        [[self.txtUUID window] makeFirstResponder:nil];
        [self.txtPassword setEnabled:YES];
        [self.txtUserName setEnabled:YES];
        [[self.view window] makeFirstResponder:[self txtUserName]];
        
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    // Update the view, if already loaded.
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
    } else if (textField.tag == 203) {
        //update uuid
        appDelegate.uuid = textField.stringValue;
    }
    
}
-(void)controlTextDidBeginEditing:(NSNotification *)aNotification{
}
- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize{
    return CGSizeMake(450, 572);
}



@end
