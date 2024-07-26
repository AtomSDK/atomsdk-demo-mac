# ATOM VPN SDK demo for macOS Applications
This is a demo application for macOS Applications with basic usage of ATOM VPN SDK which will help the developers to create smooth applications over ATOM SDK quickly.

## SDK Features covered in this Demo
* Connection with Parameters	
* Connection with Pre-Shared Key (PSK)
* Connection with Dedicated IP
* Connection with Multiple Protocols (Auto-Retry Functionality)
* Connection with Real-time Optimized Servers (Countries based on latency from user in Real-time)
* Connection with Smart Dialing (Use getCountriesForSmartDialing() to get the Advanced VPN Dialing supported countries)
* Connection with Smart Connect (Tags based dialing)


## Compatibility
* Compatible with Xcode 15.3, macOS 10.13 and later
* Compatible with ATOM SDK Version 5.0 and onwards


## Supported Protocols
* IPSec
* IKEv2
* TCP
* UDP
* Wireguard


## SDK Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate AtomSDK into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'AtomSDKBySecure'
pod 'AtomSDKTunnel'
```

### Integrate AtomWireguardTunnel in macOS App for Wireguard Protocol
You can add AtomWireguardTunnel package via Swift Package Manager

1. Open your project in Xcode 15.3 or above
2. Go to File > Swift Packages > Add Package Dependency...
3. In the field Enter package repository URL, enter "https://github.com/AtomSDK/AtomWireguardTunnel"
4. Choose Dependency Rule "Branch", and add the branch name "main"


# Getting Started with the Code
To add the SDK in Xcode:

1. Open your Xcode project.
2. Add your developer account to Xcode from Preferences -> Account if you didn't add before.
3. Select General tab from your app target and then set your developer account details.
4. From your app target select Capabilities tab and select the switch right of the Personal VPN. Then select the capabilties you are going to use.
5. Drag and drop AtomSDK.framework into your project. (Skip if using Cocoapods)
6. Go to your project -> General tab from your app target, add the framework using ‘+’ to the Embedded Binaries section. (Skip if using Cocoapods)
8. After the setup is completed, you should be able to use all the classes from the SDK by including it with the #import <AtomSDK/AtomSDK.h> directive.
9. ATOM SDK needs to be initialized with a “SecretKey” provided to you after you buy the subscription which is typically a hex-numeric literal.

It can be initialized using an instance of AtomConfiguration. It should have a vpnInterfaceName which will be used to create the Network Interface for VPN connection. 

```ruby
    AtomConfiguration *atomConfiguration= [[AtomConfiguration alloc] init];
    atomConfiguration.secretKey = @"SECRETKEY_GOES_HERE";
    atomConfiguration.vpnInterfaceName = @"Atom";
    atomConfiguration.tunnelProviderBundleIdentifier = “ENTER_YOUR _NETWORK_EXTENSION_BUNDLE_ID”;
    atomConfiguration.wireGuardTunnelProviderBundleIdentifier = “ENTER_YOUR_WIREGUARD_NETWORK_EXTENSION_BUNDLE_ID”;
    [AtomManager sharedInstanceWithAtomConfiguration:atomConfiguration];
```

PS: ATOM SDK is a singleton, and must be initialized before accessing its methods.

## Enable Local Inventory Support
ATOM SDK offers a feature to enable the local inventory support. This can help Application to fetch Countries and Protocols even when device network is not working.

* To enable it, Log In to the Atom Console
* Download the local data file in json format
* File name should be localdata.json. Please rename the file to localdata.json if you find any discrepancy in the file name.
* Paste the file in root of your application folder.

## Delegates to Register
ATOM SDK offers four delegates to register for the ease of the developer.
* atomManagerDidConnect:
* atomManagerDidDisconnect:
* atomManagerOnRedialing:
* atomManagerDialErrorReceived:
* atomManagerOnUnableToAccessInternet:
* atomManagerDidReceiveConnectedLocation:

## StateDidChangedHandler to monitor a VPN connection status
ATOM SDK offers stateDidChangedHandler for the ease of the developer.
```ruby
[AtomManager sharedInstance].stateDidChangedHandler = ^(AtomVPNState status) { };
```


## VPN Authentication
ATOM SDK provided two ways to authenticate your vpn user.
First one is to offer VPN Credentials directly to the SDK which you may create through the Admin Panel provided by ATOM.

```ruby
[AtomManager sharedInstance].atomCredential = [[AtomCredential alloc] initWithUsername:@"<username>" password:@"<password>"];
```
Alternatively, if you don’t want to take hassle of creating users yourself, leave it on us and we will do the rest for you!

```ruby
[AtomManager sharedInstance].UUID = @<"[[[UIDevice currentDevice] identifierForVendor] UUIDString]>";
```
You just need to provide a Unique User ID for your user e.g. any unique hash or even user’s email which you think remains consistent and unique for your user. ATOM SDK will generate VPN Account behind the scenes automatically and gets your user connected! Easy isn’t it?
# VPN Connection
You need to declare an object of “AtomProperties” Class to define your connection preferences. Details of all the available properties can be seen in the inline documentation of “AtomProperties” Class. For the least, you need to give Country and Protocol with which you want to connect.

```ruby
AtomProperties* properties = [[AtomProperties alloc] initWithCountry:@"<country>" protocol:@"<protocol>"];
```
## Fetch Countries
Countries can be obtained through ATOM SDK as well.
```ruby
[[AtomManager sharedInstance] getCountriesWithSuccess:^(NSArray<AtomCountry *> *success) {}
} errorBlock:^(NSError *error) {}];
```

## Fetch Recommended Country
You can get the Recommended Country for user's location through ATOM SDK.
```ruby
[[AtomManager sharedInstance] getRecommendedCountry:^(AtomCountry *country) {
} errorBlock:^(NSError *error) {
}];
```

## Fetch Countries For Smart Dialing
You can get the Countries those support Smart Dialing through ATOM SDK.
```ruby
[[AtomManager sharedInstance] getCountriesForSmartDialing:^(NSArray<AtomCountry *> *success) {}
} errorBlock:^(NSError *error) {}];
```

## Fetch Protocols
Protocols can be obtained through ATOM SDK as well.

```ruby
[[AtomManager sharedInstance] getProtocolsWithSuccess:^(NSArray<AtomProtocol *> *success) {}
errorBlock:^(NSError *error) {}];
```

## VPN Connection Speed
For VPN connection speed you need to registor onPacketsTransmitted handler from AtomManager class to get the VPN connection speed in bytes per second. This callback is recieve only in VPN connected state.
```ruby
AtomManager.sharedInstance.onPacketsTransmitted = ^(NSNumber *bytesReceived, NSNumber *bytesSent) {
    NSLog(@"bytesIN: %ld | bytesOUT: %ld ",(long)bytesReceived.integerValue,bytesSent.integerValue);
};
```

## Protocol switch
You can enable or disable protocol switch from VPNProperties class. By default its value is set to true.
```ruby
properties.enableProtocolSwitch = false;
```
or
```ruby
properties.enableProtocolSwitch = true;
```

## Recommanded protocol
If you didn't specify the protocol in case of Country, City and Channel dailing then Atom SDK dialed with recommanded protocol according to the specified country, city and channel. It did not work in PSK, Smart connect dialing and dedicated IP.

## Use Failover
Failover is a mechanism in which Atom dialed with nearest server if requested server is busy or not found for any reason. You can control this mechanism from VPNPorperties class. By default its value is set to true.
```ruby
properties.useFailover = false;
```
or
```ruby
properties.useFailover = true;
```

### How to Connect

As soon as you call Connect method, the events you were listening to will get the updates about the states being changed and VPNDialedError  (if any occurs) as well.


### Connection with Parameters
It is the simplest way of connection which is well explained in the steps above. You just need to provide the country and the protocol objects and call the Connect method.
```ruby
AtomProperties* properties = [[AtomProperties alloc] initWithCountry:@"<#country#>" protocol:@"<#protocol#>"];

[[AtomManager sharedInstance] connectWithProperties:properties completion:^(NSString *success) {}
errorBlock:^(NSError *error) {}];
```

### Include or Exclude Server with Nas Identifier
When connecting with parameters, a server can be included or excluded with its Nas Identifier
```ruby
AtomProperties* properties = [[AtomProperties alloc] initWithCountry:@"<#country#>" protocol:@"<#protocol#>"];
NSMutableArray<ServerFilter *> *serverFilters = [NSMutableArray new];
[serverFilters addObject:[[ServerFilter alloc] initWithNasIdentifier:@"nas-identifier-here"" andFilter:INCLUDE]];
[serverFilters addObject:[[ServerFilter alloc] initWithNasIdentifier:@"nas-identifier-here" andFilter:EXCLUDE]];
[properties setServerFilters:serverFilters];
[[AtomManager sharedInstance] connectWithProperties:properties completion:^(NSString *success) {}
errorBlock:^(NSError *error) {}];
``` 

### Connection with Pre-Shared Key (PSK)
In this way of connection, it is pre-assumed that you have your own backend server which communicates with ATOM Backend APIs directly and creates a Pre-Shared Key (usually called as PSK) which you can then provide to the SDK for dialing. While providing PSK, no VPN Property other than PSK is required to make the connection. ATOM SDK will handle the rest.
```ruby
AtomProperties *properties = [[AtomProperties alloc] initWithPreSharedKey:@"<#PSK#>"];

[[AtomManager sharedInstance] connectWithProperties:properties completion:^(NSString *success) {}
errorBlock:^(NSError *error) {}];
```
### Connection with Dedicated IP
You can also make your user comfortable with this type of connection by just providing them with a Dedicated IP/Host and they will always connect to a dedicated server! For this purpose, ATOM SDK provides you with the following constructor.
```ruby
AtomProperties *properties = [[AtomProperties alloc] initWithDedicatedHostName:@"<#DedicatedIP/Host#>" protocol:@"<#protocol#>"];

[[AtomManager sharedInstance] connectWithProperties:properties completion:^(NSString *success) {}
errorBlock:^(NSError *error) {}];
```

### Connection with Real-time Optimized Servers
This one is same as the first one i.e. “Connection with Parameters” with a slight addition of using Real-time optimized servers best from your user’s location. You just need to set this property to TRUE and rest will be handled by the ATOM SDK.
```ruby
AtomProperties* properties = [[AtomProperties alloc] initWithCountry:@"<#country#>" protocol:@"<#protocol#>"];
[properties setUseOptimization:YES];

[[AtomManager sharedInstance] connectWithPropertiesconnectWithProperties:properties completion:^(NSString *success) {}
errorBlock:^(NSError *error) {}];
```

If you want to show your user the best location for him on your GUI then ATOM SDK have it ready for you as well! ATOM SDK has a method exposed namely “getOptimizedCountries” which adds a property “RoundTripTime” in the country object which has the real-time latency of all countries from your user’s location (only if ping is enabled on your user’s system and ISP doesn’t blocks any of our datacenters). You can use this property to find the best speed countries from your user’s location.

### Connection with Smart Dialing
“Connection with Parameters” with a slight addition of using smart dialing to connect. You just need to call "withSmartDialing" and rest will handled by the ATOM SDK.
```ruby
AtomProperties* properties = [[AtomProperties alloc] initWithCountry:@"<#country#>" protocol:@"<#protocol#>"];
[properties setUseSmartDialing:YES];
[[AtomManager sharedInstance] connectWithProperties:properties completion:^(NSString *success) {}
errorBlock:^(NSError *error) {}];
```

For more information, please see the inline documentation of AtomProperties Class.

### Connection with Multiple Protocols (Auto-Retry Functionality)
You can provide three protocols at max so ATOM SDK can attempt automatically on your behalf to get your user connected with the Secondary or Tertiary protocol if your base Protocol fails to connect. 

```ruby
properties.secondaryProtocol = @"<protocol2>";
properties.tertiaryProtocol = @"<protocol3>";
```

### Connection with Smart Connect
If you want us to connect your user with what's best for him, you can now do it using *_SmartConnect_* feature. Atom has introduced an enum list of feature a.k.a *_Tags_* you want to apply over those smart connections which can be found under  *_Atom.Core.AtomSmartConnectTag_*. An example usage of SmartConnect is depicted below.
```ruby
NSArray *selectedAtomTags = [[NSArray alloc] initWithObjects: @(AtomSmartConnectTagFileSharing),@(AtomSmartConnectTagPaid), nil];
AtomProperties *properties = [[AtomProperties alloc] initWithProtocol:selectedProtocol andTags:selectedAtomTags];
[[AtomManager  sharedInstance] connectWithProperties:properties completion:^(NSString *success) {
} errorBlock:^(NSError *error) {
}];
```

Tags aren't mandatory and are nil parameter. You can only provide Protocol to connect and rest Atom will manage.

# Cancel VPN Connection
You can cancel connection between dialing process by calling the cancelVPN method.
```ruby
[[AtomManager sharedInstance] cancelVPN];
```
# Disconnect VPN Connection
To disconnect, simply call the disconnectVPN method of AtomManager.
```ruby
[[AtomManager sharedInstance] disconnectVPN];
```

# Remove VPN Profile
To remove VPN profile, simply call the removeVPNProfileWithCompletion method of AtomManager.
```ruby
[[AtomManager sharedInstance] removeVPNProfileWithCompletion:^(BOOL isSuccess) {
}];
```

## Setup System Extension

We are going to integrate AtomSDKTunnel in macOS application for dialing with TCP/UDP protocol. 

There are few steps that needs to followed carefully. 

Lets start setting up system extension. 

## Requirement
#### Operation System 
macOS 10.15

#### Capabilities
SystemExtension
Packet Tunnel (Network Extension)
Keychain Groups
App Groups


## Step # 1
## 
We need to add a new target. Press plus sign on bottom left of xcode where all the targets are listed. 

![1.png](./_resources/b55621ea6b6449d580f18b67a824df9b.png)


Now choose Network Extension under System Extension heading. 


![2.png](./_resources/d4ec6dd25a70410f8ffc2c6b2683ad35.png)

Now add relevant information while creating target. 


![3.png](./_resources/172b95aaaa7d4b9a9e0fea618aa44d54.png)


Congrats, new target has been created. But we need to configure it. 



![4.png](./_resources/86f092f5cf0f4ddea4c5d2255f5dbd17.png)

Go to capabilities tab on top of xcode and under Network Extension Capabilities please choose Packet Tunnel and enable Out going connection 


![5.png](./_resources/529b7fbe683b4d8bb1b8a978c1b9784b.png)

In your macOS application target add system extension capability. 


![6.png](./_resources/28511f66b22d438fbe94ed4b048c4791.png)


## Step # 2
Now let add the framework in dependency manager (Cocoapods) using the following command. 

**Note:** This framework must be added to Network extension target since this target will only be running in 10.15 macOS.

![7.png](./_resources/06e87fb1e97e4a948442bece4cec3d76.png)


Let install Pod using, 

**pod install --verbose**

## Step # 3

Since there is a limitation on cocoapod to embed framework in System extension, we will be adding it manually. 

Press Plus sign under **Framework and Libraries**



![8.png](./_resources/ae91f4f992154d3bb4bb6bb598e5629f.png)

and select AtomOPVPNTunnel.xcframework, AtomSDKTunnel.xcframework, LZ4.xcframework, mbedTLS.xcframework, OpenVPNClient.xcframework for OpenVPN specific System Extension


![9.png](./_resources/779d8879516d4080b7bbf4870db2c169.2.png)


and select AtomWireguardTunnel for Wireguard specific System Extension


![9.1.png](./_resources/779d8879516d4080b7bbf4870db2c169.1.png)


## Steps # 4

Here comes to the coding part. Simple pass the tunnel bundle identifier and app group identifier of new created target to AtomConfiguration class. 


![10.png](./_resources/671c1c664f6a4a239536a52bc02b40b6.png)

Note: You can enable/disable OpenVPN connection logs using the bit enableVPNLogs. 


In order to activate System Extension you need to call ExtensionManager's activeExtension method. **Note:**  **This should be done after AtomSDK being initialized.**



![14.png](./_resources/f3f5b8494329431f85d84ff8e5b760bd.png)

You should also listen to the ExtensionManagerDelegate in order to receive events. 



![15.png](./_resources/9bf1cfa5b90a4aa79f74e3b121edbc47.png)




Open **PacketTunnelProvider** class which was created with newly created target and subclass it with **AtomPacketTunnelProvider** after importing **AtomSDKTunnel**.



![13.png](./_resources/d1ac676e6fd942f791aecb884d3c3769.png)


## Step # 5

In your Extension's info.plist, change the value of NEMachServiceName to be the App group's identifier. 



![16.png](./_resources/d435979919c54e7d8a04017b95ebbd10.png)


Wolaa, Integartion is completed. Time to test it. 

If you run your app system extension will ask for user's approval. 


![17.png](./_resources/0ca42163fad74914b8ef3074323b0b46.png)


Which can be allowed from Security Preferences. 



![18.png](./_resources/09554c33130e455b8ed96bb4bde61ed9.png)


Once the system Extension is installed you can verify it using the following command. 

**systemextensionsctl list**



![19.png](./_resources/64563cfe3a6d4deb92e2aa86283310ad.png)


## Releasing App

In order to release the system extension there are few requirement. 

Entitlement file of Extension manager in release must have the following key value pair. 

```
<key>com.apple.developer.networking.networkextension</key>
	<array>
		<string>packet-tunnel-provider-systemextension</string>
	</array>
```

While in debug it should be the following 

```
<key>com.apple.developer.networking.networkextension</key>
	<array>
		<string>packet-tunnel-provider</string>
	</array>
```
