//
//  NHSegmentView.h
//  NHSegmentViewTest
//
//  Created by Sergey Minakov on 27.02.16.
//  Copyright © 2016 Naithar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NHSegmentView;

NS_ASSUME_NONNULL_BEGIN

@protocol NHSegmentViewDelegate <NSObject>

- (void)nhSegmentView:(NHSegmentView *)segmentView didChangeIndex:(NSInteger)index;

@end

IB_DESIGNABLE
@interface NHSegmentView : UIView

@property (nonatomic, nullable, weak) IBOutlet id<NHSegmentViewDelegate> delegate;

#if TARGET_INTERFACE_BUILDER
@property (nonatomic, assign) IBInspectable NSUInteger itemsCount;
#endif

@property (nonatomic, assign) IBInspectable CGSize defaultSize;
@property (nonatomic, assign) IBInspectable CGFloat itemSpace;
@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;
@property (nonatomic, nullable, assign) IBInspectable UIColor *borderColor;

@property (nonatomic, null_resettable, strong) IBInspectable UIColor *itemColor;
@property (nonatomic, null_resettable, strong) IBInspectable UIColor *itemTextColor;
@property (nonatomic, null_resettable, strong) UIFont *itemFont;

@property (nonatomic, null_resettable, strong) IBInspectable UIColor *selectedItemColor;
@property (nonatomic, null_resettable, strong) IBInspectable UIColor *selectedItemTextColor;
@property (nonatomic, null_resettable, strong) UIFont *selectedItemFont;

@property (nonatomic, strong, readonly) NSArray<NSString *> *itemValues;
@property (nonatomic, strong, readonly) NSArray<NSString *> *selectedItemValues;

@property (nonatomic, assign, readonly) IBInspectable NSInteger selectedIndex;

- (void)setValues:(NSArray<NSString *> *)itemValues;

- (void)insertValue:(NSString *)value atIndex:(NSUInteger)index;
- (void)insertValue:(NSString *)value selectedValue:(nullable NSString *)selectedValue atIndex:(NSUInteger)index;

- (void)appendValue:(NSString *)value;
- (void)appendValue:(NSString *)value selectedValue:(nullable NSString *)selectedValue;

- (void)changeValue:(NSString *)value atIndex:(NSUInteger)index;
- (void)changeValue:(nullable NSString *)value selectedValue:(nullable NSString *)selectedValue atIndex:(NSUInteger)index;

- (void)removeAtIndex:(NSUInteger)index;

- (nullable NSString *)valueAtIndex:(NSUInteger)index;
- (nullable NSString *)selectedValueAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
