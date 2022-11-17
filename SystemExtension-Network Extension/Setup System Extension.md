Setup System Extension

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

![1.png](../_resources/b55621ea6b6449d580f18b67a824df9b.png)


Now choose Network Extension under System Extension heading. 


![2.png](../_resources/d4ec6dd25a70410f8ffc2c6b2683ad35.png)

Now add relevant information while creating target. 


![3.png](../_resources/172b95aaaa7d4b9a9e0fea618aa44d54.png)


Congrats, new target has been created. But we need to configure it. 



![4.png](../_resources/86f092f5cf0f4ddea4c5d2255f5dbd17.png)

Go to capabilities tab on top of xcode and under Network Extension Capabilities please choose Packet Tunnel and enable Out going connection 


![5.png](../_resources/529b7fbe683b4d8bb1b8a978c1b9784b.png)

In your macOS application target add system extension capability. 


![6.png](../_resources/28511f66b22d438fbe94ed4b048c4791.png)


## Step # 2
Now let add the framework in dependency manager (Cocoapods) using the following command. 

**Note:** This framework must be added to Network extension target since this target will only be running in 10.15 macOS.

![7.png](../_resources/06e87fb1e97e4a948442bece4cec3d76.png)


Let install Pod using, 

**pod install --verbose**

## Step # 3

Since there is a limitation on cocoapod to embed framework in System extension, we will be adding it manually. 

Press Plus sign under **Framework and Libraries**



![8.png](../_resources/ae91f4f992154d3bb4bb6bb598e5629f.png)

and select AtomSDKTunnel.xcframework and openssl.xcframework



![9.png](../_resources/779d8879516d4080b7bbf4870db2c169.png)


## Steps # 4

Here comes to the coding part. Simple pass the tunnel bundle identifier and app group identifier of new created target to AtomConfiguration class. 


![10.png](../_resources/671c1c664f6a4a239536a52bc02b40b6.png)

Note: You can enable/disable OpenVPN connection logs using the bit enableVPNLogs. 


In order to activate System Extension you need to call ExtensionManager's activeExtension method. **Note:**  **This should be done after AtomSDK being initialized.**



![14.png](../_resources/f3f5b8494329431f85d84ff8e5b760bd.png)

You should also listen to the ExtensionManagerDelegate in order to receive events. 



![15.png](../_resources/9bf1cfa5b90a4aa79f74e3b121edbc47.png)




Open **PacketTunnelProvider** class which was created with newly created target and subclass it with **AtomPacketTunnelProvider** after importing **AtomSDKTunnel**.



![13.png](../_resources/d1ac676e6fd942f791aecb884d3c3769.png)


## Step # 5

In your Extension's info.plist, change the value of NEMachServiceName to be the App group's identifier. 



![16.png](../_resources/d435979919c54e7d8a04017b95ebbd10.png)


Wolaa, Integartion is completed. Time to test it. 

If you run your app system extension will ask for user's approval. 


![17.png](../_resources/0ca42163fad74914b8ef3074323b0b46.png)


Which can be allowed from Security Preferences. 



![18.png](../_resources/09554c33130e455b8ed96bb4bde61ed9.png)


Once the system Extension is installed you can verify it using the following command. 

**systemextensionsctl list**



![19.png](../_resources/64563cfe3a6d4deb92e2aa86283310ad.png)


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