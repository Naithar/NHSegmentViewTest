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
@property (nonatomic, assign) CGRect selectedRect;

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
#if TARGET_INTERFACE_BUILDER
    self.itemsCount = -1;
#endif
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
    self.borderPathLayer.strokeColor = self.borderColor.CGColor;
    self.borderPathLayer.fillColor = self.borderColor.CGColor;
    self.borderPathLayer.lineWidth = 2 * self.borderWidth;
    [self.layer addSublayer:self.borderPathLayer];
    
    self.contentPathLayer = [CAShapeLayer layer];
    self.contentPathLayer.fillColor = self.itemColor.CGColor;
    [self.layer addSublayer:self.contentPathLayer];
    
    [self resetLayers];
}

- (void)resetLayers {
    
#if TARGET_INTERFACE_BUILDER
    if (self.itemsCount == 0) {
        self.contentPathLayer.path = nil;
        self.contentPathLayer.bounds = CGRectZero;
        self.borderPathLayer.bounds = CGRectZero;
        self.borderPathLayer.path = nil;
        return;
    }
#else
    if (self.itemValues.count == 0) {
        self.contentPathLayer.path = nil;
        self.contentPathLayer.bounds = CGRectZero;
        self.borderPathLayer.bounds = CGRectZero;
        self.borderPathLayer.path = nil;
        return;
    }
#endif
    
    CGPathRef contentLayerPath = [self __calculateLayerPath];
    CGRect contentLayerBounds = CGPathGetBoundingBox(contentLayerPath);
    
    self.contentPathLayer.path = contentLayerPath;
    self.contentPathLayer.bounds = contentLayerBounds;
    
    self.borderPathLayer.path = contentLayerPath;
    self.borderPathLayer.bounds = contentLayerBounds;
    
//    CGFloat borderWidth = self.borderWidth;
//    if (borderWidth) {
//        CGPathRef borderLayerPath = CGPathCreateCopyByStrokingPath(contentLayerPath,
//                                                                   NULL,
//                                                                   borderWidth * 2,
//                                                                   kCGLineCapRound,
//                                                                   kCGLineJoinRound,
//                                                                   1.0);
//        CGRect borderLayerBounds = CGPathGetBoundingBox(borderLayerPath);
//        CGFloat borderLayerWidth = CGRectGetWidth(borderLayerBounds);
//        CGFloat borderLayerHeight = CGRectGetHeight(borderLayerBounds);
//        self.borderPathLayer.bounds = CGRectMake(-borderWidth, -borderWidth, borderLayerWidth, borderLayerHeight);
//        self.borderPathLayer.path = borderLayerPath;
//    }
//    else {
//        self.borderPathLayer.bounds = CGRectZero;
//        self.borderPathLayer.path = nil;
//    }
}

- (CGRect)__calculateLayerRectForIndex:(NSUInteger)index {
    CGSize defaultItemSize = [self defaultSize];
    CGFloat itemSpace = self.itemSpace;
    CGFloat itemWidth = (defaultItemSize.width + itemSpace);
    CGRect itemRect;
    
    if (self.selectedIndex == index) {
        CGPoint itemPoint = CGPointMake(index * itemWidth, 0);
#if TARGET_INTERFACE_BUILDER
        itemRect = (CGRect) { .origin = itemPoint, .size = CGSizeMake(2 * defaultItemSize.width, defaultItemSize.height) };
#else
        
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingMiddle;
        UIFont *font = self.selectedItemFont;
        CGFloat fontSize = [font pointSize] + 2;
        paragraphStyle.minimumLineHeight = fontSize;
        paragraphStyle.maximumLineHeight = fontSize;
        NSDictionary *textAttributes = @{
                                         NSFontAttributeName : font,
                                         NSParagraphStyleAttributeName : paragraphStyle
                                         };
        
        NSString *selectedText = [self selectedValueAtIndex:index];
        CGFloat textWidth = [selectedText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                              options:NSStringDrawingUsesDeviceMetrics|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin
                                           attributes:textAttributes
                                                       context:nil].size.width + 5;
        
        itemRect = (CGRect) {
            .origin = itemPoint,
            .size = CGSizeMake(MAX(textWidth, defaultItemSize.width), defaultItemSize.height)
        };
#endif
        
        self.selectedRect = itemRect;
    }
    else {
        if (index < self.selectedIndex
            || self.selectedIndex < 0) {
            CGPoint itemPoint = CGPointMake(index * itemWidth, 0);
            itemRect = (CGRect) { .origin = itemPoint, .size = defaultItemSize };
        }
        else if (index > self.selectedIndex) {
            NSInteger offsetIndex = index - self.selectedIndex - 1;
            CGFloat startX = CGRectGetMaxX(self.selectedRect) + itemSpace;
            CGPoint itemPoint = CGPointMake(startX + offsetIndex * itemWidth, 0);
            itemRect = (CGRect) { .origin = itemPoint, .size = defaultItemSize };
        }
    }
    
    return itemRect;
}

- (CGPathRef)__calculateLayerPath {
    
    CGMutablePathRef layerPath = CGPathCreateMutable();
    CGFloat itemCornerRadius = self.cornerRadius;
    CGFloat lineWidth = self.itemSpaceLineWidth;
    CGSize defaultItemSize = [self defaultSize];
    
#if TARGET_INTERFACE_BUILDER
    for (int index = 0; index < self.itemsCount; index++) {
        CGRect itemRect = [self __calculateLayerRectForIndex:index];
        CGPathAddRoundedRect(layerPath, nil, itemRect, itemCornerRadius, itemCornerRadius);
    }
#else
    [self.itemValues enumerateObjectsUsingBlock:^(NSString * _Nonnull obj,
                                                  NSUInteger index,
                                                  BOOL * _Nonnull stop) {
        CGRect itemRect = [self __calculateLayerRectForIndex:index];
        CGPathAddRoundedRect(layerPath, nil, itemRect, itemCornerRadius, itemCornerRadius);
    }];
#endif
    
    if (lineWidth) {
        CGRect pathRect = CGPathGetBoundingBox(layerPath);
        CGFloat pathWidth = CGRectGetWidth(pathRect);
        CGFloat pathHeight = CGRectGetHeight(pathRect);
        CGFloat lineRectHeight = MIN(lineWidth, pathHeight);
        CGFloat lineOffset = defaultItemSize.width;
        CGRect lineRect = CGRectMake(lineOffset / 2, pathHeight / 2 - lineRectHeight / 2, pathWidth - lineOffset, lineRectHeight);
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
    [self resetLayers];
}

- (void)insertValue:(NSString *)value atIndex:(NSUInteger)index {
    [self insertValue:value selectedValue:nil atIndex:index];
}

- (void)insertValue:(NSString *)value selectedValue:(nullable NSString *)selectedValue atIndex:(NSUInteger)index {
    [self.mutableItemValues insertObject:value atIndex:index];
    [self.mutableSelectedItemValues insertObject:selectedValue ?: value atIndex:index];
    [self resetLayers];
}

- (void)appendValue:(NSString *)value {
    [self appendValue:value selectedValue:nil];
}

- (void)appendValue:(NSString *)value selectedValue:(nullable NSString *)selectedValue {
    [self.mutableItemValues addObject:value];
    [self.mutableSelectedItemValues addObject:selectedValue ?: value];
    [self resetLayers];
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
    [self resetLayers];
}

- (void)removeAtIndex:(NSUInteger)index {
    if (index >= self.itemValues.count) {
        return;
    }
    
    [self.mutableItemValues removeObjectAtIndex:index];
    [self.mutableSelectedItemValues removeObjectAtIndex:index];
    [self resetLayers];
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

- (void)selectIndex:(NSUInteger)index {
    [self selectIndex:index animated:NO];
}

- (void)selectIndex:(NSUInteger)index animated:(BOOL)animated {
    if (animated) {
        CGPathRef prevContentPath = self.contentPathLayer.path;
        CGRect prevContentBounds = self.contentPathLayer.bounds;
        self.selectedIndex = index;
        [self resetLayers];
        
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        pathAnimation.fromValue = (__bridge id _Nullable)(prevContentPath);
        pathAnimation.toValue = (__bridge id _Nullable)(self.contentPathLayer.path);
        CABasicAnimation *boundsAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
        boundsAnimation.fromValue = [NSValue valueWithCGRect:prevContentBounds];
        boundsAnimation.toValue = [NSValue valueWithCGRect:self.contentPathLayer.bounds];
        CAAnimationGroup *animationGroup = [CAAnimationGroup new];
        [animationGroup setAnimations:@[pathAnimation, boundsAnimation]];
        animationGroup.duration = 0.35;
        animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [self.contentPathLayer addAnimation:animationGroup forKey:@"path|bounds"];
        
        if (self.borderWidth) {
            [self.borderPathLayer addAnimation:animationGroup forKey:@"path|bounds"];
        }
    }
    else {
        self.selectedIndex = index;
        [self resetLayers];
    }
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
    if (_itemsCount < 0) {
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
    if (_defaultSize.width == 0
        || _defaultSize.height == 0) {
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
    self.borderPathLayer.lineWidth = 2 * borderWidth;
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    self.borderPathLayer.strokeColor = borderColor.CGColor;
    self.borderPathLayer.fillColor = borderColor.CGColor;
}

- (UIColor *)borderColor {
    return _borderColor ?: [UIColor blackColor];
}

- (void)setItemColor:(UIColor *)itemColor {
    _itemColor = itemColor;
    self.contentPathLayer.fillColor = itemColor.CGColor;
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

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
#if TARGET_INTERFACE_BUILDER
    [self resetLayers];
#endif
}

@end
