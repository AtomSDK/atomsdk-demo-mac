//
//  AppDelegate.h
//  AtomSDKDemo
//
//  Copyright ©  2018  Atom. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AppDelegate : NSObject <NSApplicationDelegate>

@property(nonatomic,strong) NSString* username;
@property(nonatomic,strong) NSString* userPassword;
@property(nonatomic,strong) NSString* uuid;
@property(nonatomic,strong) NSString* secretKey;
@property(nonatomic) BOOL isAutoGenerateUserCredential;


@end

