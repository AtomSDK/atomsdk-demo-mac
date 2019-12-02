//
//  TagTableViewCell.m
//  AtomSDKDemo
//
//  Copyright © AtomBySecure 2019 Atom. All rights reserved.
//

#import "TagTableViewCell.h"

@implementation TagTableViewCell

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

-(IBAction) actionAddTag:(id) sender {
    BOOL isSelected = _tagCell.state ? YES : NO;
    [_delegate cellDidSelected: isSelected withName: _tagCell.title atRow: @(_rowNumber)];
}

@end
