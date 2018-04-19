//
//  ParamViewController.m
//  AtomSDKSample
//
//      
//  Copyright © 2018  Atom. All rights reserved.
//

#import "ParamViewController.h"
#import "AppDelegate.h"

#define ButtonTitleConnect @"Connect"
#define ButtonTitleCancel @"Cancel"
#define ButtonTitleDisconnect @"Disconnect"


@interface ParamViewController ()
{
    NSMutableArray* countryArray;
    NSMutableArray* allCountryArray;
    NSMutableArray* protocolArray;
    BOOL useOptimize;
    AppDelegate* appDelegate;
}
@end

@implementation ParamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    appDelegate = ((AppDelegate *)[NSApplication sharedApplication].delegate);
    self.shareInstance = [AtomManager sharedInstance];
    [self.shareInstance setDelegate:self];
    [self setupVPNSDKStateChangeManager];
    [self.txtLogs setTextColor:[NSColor whiteColor]];
    protocolArray = [NSMutableArray new];
}
- (void)viewWillAppear{
    if(protocolArray.count == 0)
        [self getProtocol:nil];
    if(countryArray.count == 0)
        [self getCountries:nil];
    
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
            if(useOptimize) [self connectWithOptimizeParams:sender];
            else
                [self connectWithParams:sender];
            
        }else {
            [self.vpnButton setTitle:ButtonTitleCancel];
            [self.shareInstance cancelVPN];
        }
    }
}
- (IBAction)actionUserOptimize:(id)sender {
    NSButton* btnUseOptimize = (NSButton*)sender;
    
    if(btnUseOptimize.state){
        useOptimize = true;
    }else{
        useOptimize = false;
    }
}
- (void)cancleConnection{
    [self.shareInstance cancelVPN];
}
- (void)disconnectConnection{
    [self.shareInstance disconnectVPN];
}

#pragma mark VPNConnection Examples

- (void)connectWithOptimizeParams:(id)sender {
    
    //Implement statusDidChangedHandler
    [self setupVPNSDKStateChangeManager];
    
    if(appDelegate.isAutoGenerateUserCredential){
        //Initialize with universally unique identifiers
        self.shareInstance.UUID = appDelegate.uuid;
    }else{
        //Initialize with credential
        [AtomManager sharedInstance].atomCredential = [[AtomCredential alloc] initWithAtomCredentialUsername:appDelegate.username setPassword:appDelegate.userPassword];
    }
    //initialize with country
    AtomCountry* countryObj = [self getUserSelectedCountryObject];//COUNTRY_ID
    
    //initialize with protocol
    AtomProtocol* protocolObj = [self getUserSelectedProtocolObject];//PROTOCOL
    
    //initialize with property
    AtomProperties* properties = [[AtomProperties alloc] initWithCountry:countryObj protocol:protocolObj];
    [properties setUseOptimization:YES];
    
    //Connect with params
    [self.shareInstance connectWithProperties:properties completion:^(NSString *success) {
        NSLog(@"success");
    } errorBlock:^(NSError *error) {
        NSLog(@"error  %@",error);
        [self.txtLogs setString: error.description];
        [self.vpnButton setTitle:ButtonTitleConnect];
    }];
}

- (void)connectWithParams:(id)sender {
    
    //Implement statusDidChangedHandler
    [self setupVPNSDKStateChangeManager];
    
    if(appDelegate.isAutoGenerateUserCredential){
        //Initialize with universally unique identifiers
        self.shareInstance.UUID = appDelegate.uuid;
    }else{
        //Initialize with credential
        self.shareInstance.atomCredential = [[AtomCredential alloc] initWithAtomCredentialUsername:appDelegate.username setPassword:appDelegate.userPassword];
    }
    //initialize with country
    AtomCountry* countryObj = [self getUserSelectedCountryObject];//COUNTRY_ID
    
    //initialize with protocol
    AtomProtocol* protocolObj = [self getUserSelectedProtocolObject];//PROTOCOL
    
    
    //initialize with property
    AtomProperties* properties = [[AtomProperties alloc] initWithCountry:countryObj protocol:protocolObj];
    
    //Connect with properties
    [self.shareInstance connectWithProperties:properties completion:^(NSString *success) {
        NSLog(@"success");
    } errorBlock:^(NSError *error) {
        NSLog(@"error  %@",error);
         [self.txtLogs setString: error.description];
        [self.vpnButton setTitle:ButtonTitleConnect];
    }];
}
- (BOOL)validateCredentials{
    [self.txtLogs setString: @""];
    if(appDelegate.isAutoGenerateUserCredential){
        if(appDelegate.uuid.length == 0){
            [self showAlert:@"UUID is required for generating vpn credentials to connect VPN."];
            return false;
        }else if(countryArray.count == 0 && protocolArray.count == 0){
            [self showAlert:@"Select a protocol and country to connect"];
            return false;
        }else return true;
    }else{
        if(appDelegate.username.length == 0){
            [self showAlert:@"Username & Password is required for connecting VPN."];
            return false;
        }else if(appDelegate.userPassword.length == 0){
            [self showAlert:@"Username & Password is required for connecting VPN."];
            return false;
        }else if(countryArray.count == 0 && protocolArray.count == 0){
            [self showAlert:@"Select a protocol and country to connect"];
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
- (void)atomManagerDidConnect{
    NSLog(@"%s",__PRETTY_FUNCTION__);
}
- (void)atomManagerDidDisconnect:(BOOL)manuallyDisconnected{
    NSLog(@"%s",__PRETTY_FUNCTION__);
}
- (void)atomManagerOnRedialing:(AtomConnectionDetails *)atomConnectionDetails withError:(NSError *)error{
    NSLog(@"%s",__PRETTY_FUNCTION__);
}
- (void)atomManagerDialErrorReceived:(NSError *)error withConnectionDetails:(AtomConnectionDetails *)atomConnectionDetails{
    NSLog(@"%s",__PRETTY_FUNCTION__);
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
#pragma mark comboBox Notifications
- (void)comboBoxSelectionDidChange:(NSNotification *)notification{
    
    if(notification.object == self.protocolComboBox && countryArray.count){
        [self countryFilterByProtocol];
    }
}
- (void)countryFilterByProtocol{
    [countryArray removeAllObjects];
    AtomProtocol* protocol = [protocolArray objectAtIndex:self.protocolComboBox.indexOfSelectedItem];
    
    for(int i = 0; i<allCountryArray.count; i++ ){
        AtomCountry* countryObject = [allCountryArray objectAtIndex:i];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"number == %d", protocol.number];
        NSArray *protocol = [countryObject.protocol filteredArrayUsingPredicate:predicate];
        if(protocol.count)
            [countryArray addObject:countryObject];
        
    }
    [self loadCountryInComboBox:countryArray];
}
#pragma mark Invantory
- (void)getOptimizCountries:(id)sender {
    [[AtomManager sharedInstance] getOptimizeCountriesWithSuccess:^(NSArray<AtomCountry *> *success) {
        //NSLog(@"%@",success);
        for(int i =0; i<[success count];i++){
            AtomCountry * obj = [success objectAtIndex:i];
            NSLog(@"%lu %d",(unsigned long)[obj.protocol count],obj.latency);
        }
    } errorBlock:^(NSError *error) {
        
    }];
}
- (AtomCountry*)getUserSelectedCountryObject{
    return [countryArray objectAtIndex:self.countryComboBox.indexOfSelectedItem];
}
- (AtomProtocol*)getUserSelectedProtocolObject{
    return [protocolArray objectAtIndex:self.protocolComboBox.indexOfSelectedItem];
}

- (void)getProtocol:(id)sender {
    [self.protocolComboBox removeAllItems];
    
    [[AtomManager sharedInstance] getProtocolsWithSuccess:^(NSArray<AtomProtocol *> *success) {
        protocolArray = [[NSMutableArray alloc] initWithArray:success];
        NSMutableArray*   protocolTitleArray = [NSMutableArray new];
        for(int i =0; i<[success count];i++){
            AtomProtocol * obj = [success objectAtIndex:i];
            [protocolTitleArray addObject:obj.name];
        }
        [self.protocolComboBox setDelegate:self];
        [self.protocolComboBox addItemsWithObjectValues:protocolTitleArray];
        [self.protocolComboBox selectItemAtIndex:0];
        [self.protocolComboBox reloadData];
        
    } errorBlock:^(NSError *error) {
        NSLog(@"error  %@",error);
    }];
}
- (void)getCountries:(id)sender {
    [[AtomManager sharedInstance] getCountriesWithSuccess:^(NSArray<AtomCountry *> *success) {
        allCountryArray = [[NSMutableArray alloc] initWithArray:success];
        countryArray = [[NSMutableArray alloc] initWithArray:allCountryArray];
        
        [self loadCountryInComboBox:allCountryArray];
        
        
    } errorBlock:^(NSError *error) {
        NSLog(@"error  %@",error);
        
    }];
}
- (void)loadCountryInComboBox:(NSArray*)countryObjects{
   NSMutableArray *countryTitleArray = [NSMutableArray new];
    for(int i =0; i<[countryObjects count];i++){
        AtomCountry * obj = [countryObjects objectAtIndex:i];
        [countryTitleArray addObject:obj.name];
    }
    [self.countryComboBox removeAllItems];
    [self.countryComboBox setDelegate:self];
    [self.countryComboBox addItemsWithObjectValues:countryTitleArray];
    [self.countryComboBox selectItemAtIndex:0];
    [self.countryComboBox reloadData];
    
}
@end
