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

#if TARGET_INTERFACE_BUILDER
@synthesize itemsCount = _itemsCount;
#endif

@synthesize defaultSize = _defaultSize;
@synthesize borderColor = _borderColor;
@synthesize itemColor = _itemColor;
@synthesize itemTextColor = _itemTextColor;
@synthesize itemFont = _itemFont;
@synthesize selectedItemColor = _selectedItemColor;
@synthesize selectedItemTextColor = _selectedItemTextColor;
@synthesize selectedItemFont = _selectedItemFont;

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
    self.borderPathLayer.fillColor = self.borderColor.CGColor;
    [self.layer addSublayer:self.borderPathLayer];
    
    self.contentPathLayer = [CAShapeLayer layer];
    self.contentPathLayer.fillColor = self.itemColor.CGColor;
    [self.layer addSublayer:self.contentPathLayer];
    
    [self resetLayers];
}

- (void)resetLayers {
    CGPathRef contentLayerPath = [self __calculateLayerPath];
    CGRect contentLayerBounds = CGPathGetBoundingBox(contentLayerPath);
    
    self.contentPathLayer.path = contentLayerPath;
    self.contentPathLayer.bounds = contentLayerBounds;
    
    CGFloat borderWidth = self.borderWidth;
    if (borderWidth) {
        CGPathRef borderLayerPath = CGPathCreateCopyByStrokingPath(contentLayerPath,
                                                                   NULL,
                                                                   borderWidth * 2,
                                                                   kCGLineCapRound,
                                                                   kCGLineJoinRound,
                                                                   1.0);
        CGRect borderLayerBounds = CGPathGetBoundingBox(borderLayerPath);
        CGFloat borderLayerWidth = CGRectGetWidth(borderLayerBounds);
        CGFloat borderLayerHeight = CGRectGetHeight(borderLayerBounds);
        self.borderPathLayer.bounds = CGRectMake(-borderWidth, -borderWidth, borderLayerWidth, borderLayerHeight);
        self.borderPathLayer.path = borderLayerPath;
    }
    else {
        self.borderPathLayer.bounds = CGRectZero;
        self.borderPathLayer.path = nil;
    }
}

- (CGPathRef)__calculateLayerPath {
    
    CGMutablePathRef layerPath = CGPathCreateMutable();
    CGSize defaultItemSize = [self defaultSize];
    CGFloat itemSpace = self.itemSpace;
    CGFloat itemCornerRadius = self.cornerRadius;
    CGFloat lineWidth = self.itemSpaceLineWidth;
    
    //calculate path, add path -- loop, close path
    
#if TARGET_INTERFACE_BUILDER
    for (int index = 0; index < self.itemsCount; index++) {
        @autoreleasepool {
            CGFloat itemWidth = (defaultItemSize.width + itemSpace);
            CGPoint itemPoint = CGPointMake(index * itemWidth, 0);
            CGSize itemSize = defaultItemSize;
            CGRect itemRect = (CGRect) {
                .origin = itemPoint,
                .size = itemSize
            };
            
            CGPathAddRoundedRect(layerPath, nil, itemRect, itemCornerRadius, itemCornerRadius);
        }
    }
#else
    
#endif
    
    if (lineWidth) {
        CGRect pathRect = CGPathGetBoundingBox(layerPath);
        CGFloat pathWidth = CGRectGetWidth(pathRect);
        CGFloat pathHeight = CGRectGetHeight(pathRect);
        CGFloat lineRectHeight = MIN(lineWidth, pathHeight);
        CGRect lineRect = CGRectMake(0, pathHeight / 2 - lineRectHeight / 2, pathWidth, lineRectHeight);
        CGPathAddRect(layerPath, nil, lineRect);
    }
    
    CGPathCloseSubpath(layerPath);
    
    return layerPath;
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

- (void)setItemsCount:(NSInteger)itemsCount {
    _itemsCount = itemsCount;
    [self resetLayers];
}

- (NSInteger)itemsCount {
    if (_itemsCount == 0) {
        return 3;
    }
    
    return _itemsCount;
}

#endif

- (void)setDefaultSize:(CGSize)defaultSize {
    _defaultSize = defaultSize;
    [self resetLayers];
}

- (CGSize)defaultSize {
    if (CGSizeEqualToSize(CGSizeZero, _defaultSize)) {
        return CGSizeMake(50, 50);
    }
    
    return _defaultSize;
}

- (void)setItemSpace:(CGFloat)itemSpace {
    _itemSpace = itemSpace;
    [self resetLayers];
}

- (void)setItemSpaceLineWidth:(CGFloat)itemSpaceLineWidth {
    _itemSpaceLineWidth = itemSpaceLineWidth;
    [self resetLayers];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    [self resetLayers];
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    [self resetLayers];
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    self.borderPathLayer.fillColor = self.borderColor.CGColor;
}

- (UIColor *)borderColor {
    return _borderColor ?: [UIColor blackColor];
}

- (void)setItemColor:(UIColor *)itemColor {
    _itemColor = itemColor;
    self.contentPathLayer.fillColor = self.itemColor.CGColor;
}

- (UIColor *)itemColor {
    return _itemColor ?: [UIColor blackColor];
}

- (void)setItemTextColor:(UIColor *)itemTextColor {
    _itemTextColor = itemTextColor;
    //TODO: !!!
}

- (UIColor *)itemTextColor {
    return _itemTextColor ?: [UIColor whiteColor];
}

- (void)setItemFont:(UIFont *)itemFont {
    _itemFont = itemFont;
    //TODO: !!!
}

- (UIFont *)itemFont {
    return _itemFont ?: [UIFont systemFontOfSize:17];
}

- (void)setSelectedItemColor:(UIColor *)selectedItemColor {
    _selectedItemColor = selectedItemColor;
    //TODO: !!!
}

- (UIColor *)selectedItemColor {
    return _selectedItemColor ?: [UIColor grayColor];
}

- (void)setSelectedItemTextColor:(UIColor *)selectedItemTextColor {
    _selectedItemTextColor = selectedItemTextColor;
    //TODO: !!!
}

- (UIColor *)selectedItemTextColor {
    return _selectedItemTextColor ?: [UIColor blackColor];
}

- (void)setSelectedItemFont:(UIFont *)selectedItemFont {
    _selectedItemFont = selectedItemFont;
    //TODO: !!!
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
