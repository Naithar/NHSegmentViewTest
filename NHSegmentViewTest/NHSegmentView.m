//
//  NHSegmentView.m
//  NHSegmentViewTest
//
//  Created by Sergey Minakov on 27.02.16.
//  Copyright © 2016 Naithar. All rights reserved.
//

#import "NHSegmentView.h"

@interface NHSegmentView ()

@property (nonatomic, strong) CAShapeLayer *borderPathLayer;
@property (nonatomic, strong) CAShapeLayer *contentPathLayer;

@property (nonatomic, strong) NSMutableArray<NSString *> *mutableItemValues;
@property (nonatomic, strong) NSMutableArray<NSString *> *mutableSelectedItemValues;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation NHSegmentView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self __nhCommonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self __nhCommonInit];
    }
    
    return self;
}

- (void)__nhCommonInit {
    self.selectedIndex = -1;
    self.mutableItemValues = [NSMutableArray new];
    self.mutableSelectedItemValues = [NSMutableArray new];
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                 initWithTarget:self action:@selector(tapGestureRecognizerAction:)];
    [self addGestureRecognizer:self.tapGestureRecognizer];
    
    [self __setupLayers];
}

- (void)__setupLayers {
    self.borderPathLayer = [CAShapeLayer layer];
    [self.layer addSublayer:self.borderPathLayer];
    
    self.contentPathLayer = [CAShapeLayer layer];
    [self.layer addSublayer:self.contentPathLayer];
    
    [self __calculateLayerPaths];
}

- (void)__calculateLayerPaths {
#if TARGET_INTERFACE_BUILDER
#else
#endif
}

- (void)prepareForInterfaceBuilder {
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat viewMidX = CGRectGetMidX(self.bounds);
    CGFloat viewMidY = CGRectGetMidY(self.bounds);
    CGPoint viewCenter = CGPointMake(viewMidX, viewMidY);
    self.borderPathLayer.position = viewCenter;
    self.contentPathLayer.position = viewCenter;
}

#pragma mark - Public Methods

- (void)setValues:(NSArray<NSString *> *)itemValues {
    [self.mutableItemValues removeAllObjects];
    [self.mutableSelectedItemValues removeAllObjects];
    
    [self.mutableItemValues addObjectsFromArray:itemValues];
    [self.mutableSelectedItemValues addObjectsFromArray:itemValues];
}

- (void)insertValue:(NSString *)value atIndex:(NSUInteger)index {
    [self insertValue:value selectedValue:nil atIndex:index];
}

- (void)insertValue:(NSString *)value selectedValue:(nullable NSString *)selectedValue atIndex:(NSUInteger)index {
    [self.mutableItemValues insertObject:value atIndex:index];
    [self.mutableSelectedItemValues insertObject:selectedValue ?: value atIndex:index];
}

- (void)appendValue:(NSString *)value {
    [self appendValue:value selectedValue:nil];
}

- (void)appendValue:(NSString *)value selectedValue:(nullable NSString *)selectedValue {
    [self.mutableItemValues addObject:value];
    [self.mutableSelectedItemValues addObject:selectedValue ?: value];
}

- (void)changeValue:(NSString *)value atIndex:(NSUInteger)index {
    [self changeValue:value selectedValue:nil atIndex:index];
}

- (void)changeValue:(nullable NSString *)value selectedValue:(nullable NSString *)selectedValue atIndex:(NSUInteger)index {
    if (index >= self.itemValues.count) {
        return;
    }
    
    if (value) {
        self.mutableItemValues[index] = value;
    }
    
    self.mutableSelectedItemValues[index] = selectedValue ?: value ?: self.mutableItemValues[index];
}

- (void)removeAtIndex:(NSUInteger)index {
    if (index >= self.itemValues.count) {
        return;
    }
    
    [self.mutableItemValues removeObjectAtIndex:index];
    [self.mutableSelectedItemValues removeObjectAtIndex:index];
}

- (nullable NSString *)valueAtIndex:(NSUInteger)index {
    if (index >= self.itemValues.count) {
        return nil;
    }
    
    NSString *value = self.itemValues[index];
    return value;
}

- (nullable NSString *)selectedValueAtIndex:(NSUInteger)index {
    if (index >= self.selectedItemValues.count) {
        return nil;
    }
    
    NSString *value = self.selectedItemValues[index];
    return value;
}


#pragma mark - Actions

- (void)tapGestureRecognizerAction:(UIGestureRecognizer *)recognizer {
}

#pragma mark - Getters and Setters

#if TARGET_INTERFACE_BUILDER
- (NSInteger)itemsCount {
    if (_itemsCount == 0) {
        return 3;
    }
    
    return _itemsCount;
}
#endif

- (CGSize)defaultSize {
    if (CGSizeEqualToSize(CGSizeZero, _defaultSize)) {
        return CGSizeMake(50, 50);
    }
    
    return _defaultSize;
}

- (UIColor *)itemColor {
    return _itemColor ?: [UIColor blackColor];
}

- (UIColor *)itemTextColor {
    return _itemTextColor ?: [UIColor whiteColor];
}

- (UIFont *)itemFont {
    return _itemFont ?: [UIFont systemFontOfSize:17];
}

- (UIColor *)selectedItemColor {
    return _selectedItemColor ?: [UIColor grayColor];
}

- (UIColor *)selectedItemTextColor {
    return _selectedItemTextColor ?: [UIColor blackColor];
}

- (UIFont *)selectedItemFont {
    return _selectedItemFont ?: [UIFont systemFontOfSize:17];
}

- (NSArray<NSString *> *)itemValues {
    return self.mutableItemValues;
}

- (NSArray<NSString *> *)selectedItemValues {
    return self.mutableSelectedItemValues;
}

@end
