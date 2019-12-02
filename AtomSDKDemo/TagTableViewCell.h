//
//  TagTableViewCell.h
//  AtomSDKDemo
//
//  Copyright © 2019 AtomBySecure. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol CellDidChange

- (void) cellDidSelected: (BOOL) isSelected withName: (NSString *_Nullable) name atRow: (NSNumber *_Nullable) row;

@end

NS_ASSUME_NONNULL_BEGIN

@interface TagTableViewCell : NSTableCellView

@property (weak) IBOutlet NSButton *tagCell;
@property (nonatomic, weak) id <CellDidChange> delegate;
@property (nonatomic) NSInteger rowNumber;

@end

NS_ASSUME_NONNULL_END
