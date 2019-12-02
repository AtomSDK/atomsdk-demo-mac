//
//  DedicatedIPViewController.m
//  AtomSDKDemo
//
//
//  Copyright © AtomBySecure 2019 Atom. All rights reserved.
//

#import "DedicatedIPViewController.h"
#import "AppDelegate.h"
#import "TagTableViewCell.h"

#define ButtonTitleConnect @"Connect"
#define ButtonTitleCancel @"Cancel"
#define ButtonTitleDisconnect @"Disconnect"

@interface DedicatedIPViewController () <CellDidChange>
{
    NSMutableArray* protocolArray;
    AppDelegate* appDelegate;
    NSMutableDictionary<NSString*, NSNumber*> *selectedTags;
}
@end

@implementation DedicatedIPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
   
    appDelegate = ((AppDelegate *)[NSApplication sharedApplication].delegate);
    self.shareInstance = [AtomManager sharedInstance];
    [self.shareInstance setDelegate:self];
    [self setupVPNSDKStateChangeManager];
    [self.protocolComboBox setDelegate:self];
    [self.txtLogs setWantsLayer:YES];
    [self.txtLogs setTextColor:[NSColor whiteColor]];
}
- (void)viewWillAppear{
    
    if(protocolArray.count == 0)
        [self getProtocol:nil];
    
    if(self.shareInstance.getCurrentVPNStatus == CONNECTED){
        [self.vpnButton setTitle:ButtonTitleDisconnect];
        
    }else if(self.shareInstance.getCurrentVPNStatus == DISCONNECTED){
        [self.vpnButton setTitle:ButtonTitleConnect];
        
        [self populateTags];
        
        _tagsTableview.dataSource = self;
        _tagsTableview.delegate = self;
        [_tagsTableview setAllowsMultipleSelection:YES];
        
    }
}

- (IBAction)actionSelectConnectionType: (id)sender {
    for (int i=35; i<=36; i++) {
        ((NSButton *)[self.view viewWithTag:i]).state = NSOffState;
    }
    NSButton *radioButton = (NSButton *) sender;
    radioButton.state = NSOnState;
}


- (IBAction)buttonAction:(id)sender {
    if([self validateCredentials]){
        if(self.shareInstance.getCurrentVPNStatus == CONNECTED){
            [self.vpnButton setTitle:ButtonTitleConnect];
            [self.shareInstance disconnectVPN];
        }
        else if(self.shareInstance.getCurrentVPNStatus == DISCONNECTED){
            [self.vpnButton setTitle:ButtonTitleCancel];
            [self connectVPN:sender];
        }
        else {
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

- (void) connectVPN: (id)sender {
    NSButton *radioDedicated = (NSButton *) [self.view viewWithTag:35];
    if (radioDedicated.state == NSOnState) {
        [self connectWithDedicatedIP:sender];
    }
    else {
        [self connectWithTags];
    }
}

- (void)connectWithDedicatedIP:(id)sender {
    if (_txtDedicatedIP.stringValue != nil && _txtDedicatedIP.stringValue.length > 0) {
        //initialize with protocol
        AtomProtocol* protocolObj = [self validateAndGetProtocol];
    
        //initialize Property
        AtomProperties* properties = [[AtomProperties alloc] initWithDedicatedHostName:self.txtDedicatedIP.stringValue protocol:protocolObj];
    
        //Connect with properties
        [self.shareInstance connectWithProperties:properties completion:^(NSString *success) {
            //NSLog(@"success");
        } errorBlock:^(NSError *error) {
            //NSLog(@"error  %@",error);
            [self.txtLogs setString: error.description];
            [self.vpnButton setTitle:ButtonTitleConnect];
        }];
    }
    else {
        [self showAlert: @"Please provide Dedicated Host/IP"];
    }
    
}


- (void)connectWithTags {
    //initialize with protocol
    AtomProtocol* protocolObj = [self validateAndGetProtocol];
    
    //initialize with tags - optional
    NSMutableArray *selectedAtomTags = nil;
    if (selectedTags.count > 0) {
        NSArray<NSNumber *> *selectedTagsValues = [selectedTags allValues];
        selectedAtomTags = [NSMutableArray new];
        if (selectedTagsValues != nil && selectedTagsValues.count > 0) {
            for (int i=0; i<selectedTagsValues.count; i++) {
                [selectedAtomTags addObject: @([[selectedTagsValues objectAtIndex:i] intValue])];
            }
        }
    }
    
    @try {
        if ([self.shareInstance isSmartConnectAvailableOnProtocol:protocolObj andTags:selectedAtomTags]) {
        
            //initialize with property
            AtomProperties* properties = [[AtomProperties alloc] initWithProtocol: protocolObj andTags: selectedAtomTags];
        
            //Connect with properties
            [self.shareInstance connectWithProperties:properties completion:^(NSString *success) {
                //NSLog(@"success");
            } errorBlock:^(NSError *error) {
                //NSLog(@"error  %@",error);
                [self.txtLogs setString: error.description];
                [self.vpnButton setTitle:ButtonTitleConnect];
            }];
        }
        else {
            [self showAlert: @"Smart Connect Not Available"];
        }
    } @catch (NSException *exception) {
        [self.vpnButton setTitle:ButtonTitleConnect];
        [self showAlert:exception.reason];
        
    } @finally {
        
    }
    
}

- (AtomProtocol *) validateAndGetProtocol {
    //Implement statusDidChangedHandler
    [self setupVPNSDKStateChangeManager];
    
    if(appDelegate.isAutoGenerateUserCredential){
        //Initialize with universally unique identifiers
        self.shareInstance.UUID = appDelegate.uuid;
    }else{
        //Initialize with credential
        self.shareInstance.atomCredential = [[AtomCredential alloc] initWithUsername:appDelegate.username password:appDelegate.userPassword];
    }
    
    //Return Protocol
    return [self getUserSelectedProtocolObject];//PROTOCOL
}

- (BOOL)validateCredentials{
    [self.txtLogs setString: @""];
    
    if(appDelegate.isAutoGenerateUserCredential){
        if(appDelegate.uuid.length == 0){
            [self showAlert:@"UUID is required for generating vpn credentials to connect VPN."];
            return false;
        }
        else if(self.txtDedicatedIP.stringValue.length == 0 || (protocolArray.count == 0)){
            [self showAlert:@"Enter a host and select a protocol to continue."];
            return false;
        }
        return true;
    }
    else{
        if(appDelegate.username.length == 0){
            [self showAlert:@"Username & Password is required for connecting VPN."];
            return false;
        }
        else if(appDelegate.userPassword.length == 0){
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
- (AtomProtocol*)getUserSelectedProtocolObject{
    return [protocolArray objectAtIndex:self.protocolComboBox.indexOfSelectedItem];
}
#pragma mark sdk delegates
- (void)atomManagerDidConnect{
    //NSLog(@"%s",__PRETTY_FUNCTION__);
}
- (void)atomManagerDidDisconnect:(BOOL)manuallyDisconnected{
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

#pragma mark Invantory
- (void)getProtocol:(id)sender {
    [self.protocolComboBox removeAllItems];
    
    [[AtomManager sharedInstance] getProtocolsWithSuccess:^(NSArray<AtomProtocol *> *success) {
        protocolArray = [[NSMutableArray alloc] initWithArray:success];
        NSMutableArray*   protocolTitleArray = [NSMutableArray new];
        for(int i =0; i<[success count];i++){
            AtomProtocol * obj = [success objectAtIndex:i];
            [protocolTitleArray addObject:obj.name];
        }
        [self.protocolComboBox addItemsWithObjectValues:protocolTitleArray];
        [self.protocolComboBox selectItemAtIndex:0];
        [self.protocolComboBox reloadData];
    } errorBlock:^(NSError *error) {
        //NSLog(@"error  %@",error);
    }];
}

- (void) populateTags {
    _tagList = [[NSArray alloc] initWithObjects:
                @"SmartConnectAutomatic",
                @"SmartConnectFileSharing",
                @"SmartConnectFreeFilesharing",
                @"SmartConnectAutomaticFileSharing",
                @"SmartConnectFreeUsers",
                @"SmartConnectNatted",
                @"SmartConnectNattedFileSharing",
                @"SmartConnectPaid",
                @"SmartConnectAvfFileSharing",
                @"SmartConnectAvfSecurity",
                nil];
    
    if (selectedTags == nil) selectedTags = [NSMutableDictionary new];
}
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.tagList.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return [_tagList objectAtIndex: row];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    TagTableViewCell *cell = [tableView makeViewWithIdentifier: @"TagCell" owner:self];
    cell.tagCell.title = [_tagList objectAtIndex:row];
    cell.delegate = self;
    cell.rowNumber = row;
    return cell;
}

- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn {
    NSLog(@"Selection");
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    
}

- (void) cellDidSelected: (BOOL) isSelected withName: (NSString *_Nullable) name atRow: (NSNumber *) row {
    if (isSelected)
        selectedTags[name] = row;
    else
        [selectedTags removeObjectForKey: name];
}


@end
