//
//  ParamViewController.m
//  AtomSDKDemo
//
//
//  Copyright © AtomBySecure 2019 Atom. All rights reserved.
//

#import "ParamViewController.h"
#import "AppDelegate.h"
#define ButtonTitleConnect @"Connect"
#define ButtonTitleCancel @"Cancel"
#define ButtonTitleDisconnect @"Disconnect"


@interface ParamViewController () {
    NSMutableArray* countryArray;
    NSMutableArray* allCountryArray;
    NSMutableArray* protocolArray;
    
    NSMutableArray<AtomCity *> *allCityArray;
    NSMutableArray<AtomChannel *> *allChannelArray;
    
    NSArray<AtomCity *> *filteredCityArray;
    NSArray<AtomChannel *> *filteredChannelArray;
    BOOL useOptimize;
    BOOL useSmartDialing;
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
    allCityArray = [NSMutableArray new];
    allChannelArray = [NSMutableArray new];
}
- (void)viewWillAppear{
    if(protocolArray.count == 0)
        [self getProtocol:nil];
    
    if(countryArray.count == 0)
        [self getCountries:nil];
    
    if(allCityArray.count == 0)
        [self getCities:nil];
    
    if(allChannelArray.count == 0)
        [self getChannels:nil];
    
    if(self.shareInstance.getCurrentVPNStatus == CONNECTED){
        [self.vpnButton setTitle:ButtonTitleDisconnect];
    }
    else if(self.shareInstance.getCurrentVPNStatus == DISCONNECTED){
        [self.vpnButton setTitle:ButtonTitleConnect];
    }
    [self countryFilterByProtocol];
}

- (IBAction)actionSelectConnectionType: (id)sender {
    for (int i=30; i<=32; i++) {
        ((NSButton *)[self.view viewWithTag:i]).state = NSOffState;
    }
    NSButton *radioButton = (NSButton *) sender;
    radioButton.state = NSOnState;
}

- (IBAction)buttonAction:(id)sender {
    if([self validateCredentials]){
        if(self.shareInstance.getCurrentVPNStatus == CONNECTED){
            [self.shareInstance disconnectVPN];
        }else if(self.shareInstance.getCurrentVPNStatus == DISCONNECTED){
            [self.vpnButton setTitle:ButtonTitleCancel];
            [self connectWithParams:sender];
            
        }else {
            [self.vpnButton setTitle:ButtonTitleCancel];
            [self.shareInstance cancelVPN];
        }
    }
}
-(IBAction)actionBtnOptimizeCountry:(id)sender {
    if(self.btnOptimizeCountry.state) {
        [self.btnSmartDialing setState:NSControlStateValueOff];
    }
}

-(IBAction)actionBtnSmartDialing:(id)sender {
    if(self.btnSmartDialing.state) {
        [self getSmartCountries];
        [self.btnOptimizeCountry setState:NSControlStateValueOff];
    }
    else {
        [self getCountries:nil];
    }
}

- (void)cancleConnection{
    [self.shareInstance cancelVPN];
}
- (void)disconnectConnection{
    [self.shareInstance disconnectVPN];
}

#pragma mark VPNConnection Examples

- (void)connectWithParams:(id)sender {
    
    //Implement statusDidChangedHandler
    [self setupVPNSDKStateChangeManager];
    
    if(appDelegate.isAutoGenerateUserCredential){
        //Initialize with universally unique identifiers
        self.shareInstance.UUID = appDelegate.uuid;
    }else{
        //Initialize with credential
        self.shareInstance.atomCredential = [[AtomCredential alloc] initWithUsername:appDelegate.username password:appDelegate.userPassword];
    }
    
    //initialize with protocol
    AtomProtocol* protocolObj = [self getUserSelectedProtocolObject];//PROTOCOL
    
    //initialize with country
    AtomCountry* countryObj = [self getUserSelectedCountryObject];//Country
    AtomCity *selectedCity = [self getUserSelectedCityObject]; //City
    AtomChannel *selectedChannel = [self getUserSelectedChannelObject]; //Channel
    
    AtomProperties* properties = nil;
    
    //Check Selected Connection Type
    NSButton *radioCountry = [self.view viewWithTag:30];
    NSButton *radioCity = [self.view viewWithTag:31];
    NSButton *radioChannel = [self.view viewWithTag:32];
    
    //Initialize Property
    if (selectedCity != nil && selectedCity.name.length > 0 && radioCity.state == NSOnState) {
        properties = [[AtomProperties alloc] initWithCity:selectedCity protocol:protocolObj];
    }
    else if (countryObj!= nil && countryObj.country.length > 0 && radioCountry.state == NSOnState) {
        properties = [[AtomProperties alloc] initWithCountry:countryObj protocol:protocolObj];
    }
    else if (selectedChannel != nil && selectedChannel.channelId > 0 && radioChannel.state == NSOnState) {
        properties = [[AtomProperties alloc] initWithChannel:selectedChannel protocol:protocolObj];
    }
    else {
        [self showAlert: @"Please select any source (Country, City or Channel)"];
    }
    
    
    //Mutate the Property
    properties.useOptimization = self.btnOptimizeCountry.state;
    properties.useSmartDialing = self.btnSmartDialing.state;
    
    //Connect with properties
    [self.shareInstance connectWithProperties:properties completion:^(NSString *success) {
        //NSLog(@"success");
    } errorBlock:^(NSError *error) {
        //NSLog(@"error  %@",error);
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

-(void)atomManagerDidConnect:(AtomConnectionDetails *)atomConnectionDetails{
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
#pragma mark comboBox Notifications
- (void)comboBoxSelectionDidChange:(NSNotification *)notification{
    NSComboBox *comboxBox = (NSComboBox *) notification.object;
    if(comboxBox.tag == 1 && countryArray.count > 0){
        [self countryFilterByProtocol];
    }
    else if (comboxBox.tag == 2) {
        [self filterCityByCountry];
    }
}

- (void)countryFilterByProtocol{
    [countryArray removeAllObjects];
    NSInteger index = self.protocolComboBox.indexOfSelectedItem;
    index = index > 0 ? index : 0;
    AtomProtocol* protocol = [protocolArray objectAtIndex: index];
    
    for (AtomCountry *country in allCountryArray) {
        if ([country.protocols filteredArrayUsingPredicate: [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary*  bindings) {
            AtomProtocol *selectedProtocol = (AtomProtocol *) evaluatedObject;
            return [selectedProtocol.protocol isEqualToString: protocol.protocol];
        }]].firstObject != nil) {
            [countryArray addObject:country];
        }
    }
    [self loadCountryInComboBox:countryArray];
}

-(void) filterCityByCountry {
    AtomCountry *selectedCountry = [self getUserSelectedCountryObject];
    filteredCityArray = [allCityArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        AtomCity *city = (AtomCity *) evaluatedObject;
        return [city.country isEqualToString:selectedCountry.country];
    }]];
    [self loadCityInComboBox:filteredCityArray];
}


#pragma mark Invantory
- (void)getOptimizCountries:(id)sender {
    [[AtomManager sharedInstance] getOptimizedCountriesWithSuccess:^(NSArray<AtomCountry *> *success) {
        for(int i =0; i<[success count];i++){
            AtomCountry * obj = [success objectAtIndex:i];
            //NSLog(@"%lu %d",(unsigned long)[obj.protocols count],obj.latency);
        }
    } errorBlock:^(NSError *error) {
        
    }];
}
- (AtomCountry*)getUserSelectedCountryObject{
    NSInteger index = self.countryComboBox.indexOfSelectedItem;
    index = index >= 0 ? index : 0;
    return [countryArray objectAtIndex:index];
}

- (AtomProtocol*)getUserSelectedProtocolObject{
    NSInteger index = self.protocolComboBox.indexOfSelectedItem;
    index = index >= 0 ? index : 0;
    return [protocolArray objectAtIndex:index];
}

- (AtomCity*)getUserSelectedCityObject{
    NSInteger index = self.cityComboBox.indexOfSelectedItem;
    if (filteredCityArray != nil && filteredCityArray.count > 0 && index >= 0 && index < filteredCityArray.count) {
        return [filteredCityArray objectAtIndex:index];
    }
    else if (index >= 0 && index < allCityArray.count)
        return [allCityArray objectAtIndex:index];
    else
        return nil;
}

- (AtomChannel*)getUserSelectedChannelObject{
    NSInteger index = self.channelComboBox.indexOfSelectedItem;
    if (index >= 0 && index < countryArray.count)
        return [allChannelArray objectAtIndex:index];
    else
        return nil;
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
        //NSLog(@"error  %@",error);
    }];
}
- (void)getCountries:(id)sender {
    [[AtomManager sharedInstance] getCountriesWithSuccess:^(NSArray<AtomCountry *> *success) {
        allCountryArray = [[NSMutableArray alloc] initWithArray:success];
        countryArray = [[NSMutableArray alloc] initWithArray:allCountryArray];
        [self loadCountryInComboBox:allCountryArray];
    } errorBlock:^(NSError *error) {
        
    }];
}

- (void)getCities:(id) sender {
    [[AtomManager sharedInstance] getCitiesWithSuccess:^(NSArray<AtomCity *> *success) {
        allCityArray = [[NSMutableArray alloc] initWithArray:success];
        [self loadCityInComboBox:allCityArray];
    } errorBlock:^(NSError *error) {
        
    }];
}

- (void)getChannels:(id)sender {
    [[AtomManager sharedInstance] getChannelsWithSuccess:^(NSArray<AtomChannel *> *success) {
        allChannelArray = [[NSMutableArray alloc] initWithArray:success];
        [self loadChannelInComboBox:allChannelArray];
    } errorBlock:^(NSError *error) {
        
    }];
}

-(void)getSmartCountries {
    [[AtomManager sharedInstance] getCountriesForSmartDialing:^(NSArray<AtomCountry *> *countriesList) {
        allCountryArray = [[NSMutableArray alloc] initWithArray:countriesList];
        countryArray = [[NSMutableArray alloc] initWithArray:allCountryArray];
        if (countryArray.count > 0)
            [self loadCountryInComboBox:allCountryArray];
    } errorBlock:^(NSError *error) {
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
    [self.countryComboBox reloadData];
    
}

- (void)loadCityInComboBox:(NSArray*) cityObjects {
   NSMutableArray *cityTitleArray = [NSMutableArray new];
    for(int i =0; i<[cityObjects count];i++){
        AtomCity * obj = [cityObjects objectAtIndex:i];
        [cityTitleArray addObject:obj.name];
    }
    [self.cityComboBox removeAllItems];
    [self.cityComboBox setDelegate:self];
    [self.cityComboBox addItemsWithObjectValues:cityTitleArray];
    [self.cityComboBox reloadData];
    
}

- (void)loadChannelInComboBox:(NSArray*) channelObjects {
   NSMutableArray *channelTitleArray = [NSMutableArray new];
    for(int i =0; i<[channelObjects count];i++){
        AtomChannel * obj = [channelObjects objectAtIndex:i];
        [channelTitleArray addObject:obj.name];
    }
    [self.channelComboBox removeAllItems];
    [self.channelComboBox setDelegate:self];
    [self.channelComboBox addItemsWithObjectValues:channelTitleArray];
    [self.channelComboBox reloadData];
    
}

@end
