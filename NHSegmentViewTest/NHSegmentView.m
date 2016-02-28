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

@property (nonatomic, strong) NSMutableArray<CATextLayer *> *textLayers;

@property (nonatomic, strong) NSMutableArray<NSString *> *mutableItemValues;
@property (nonatomic, strong) NSMutableArray<NSString *> *mutableSelectedItemValues;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) CGRect selectedRect;

@end

@implementation NHSegmentView

@synthesize defaultSize = _defaultSize;
@synthesize borderColor = _borderColor;
@synthesize itemColor = _itemColor;
@synthesize itemTextColor = _itemTextColor;
@synthesize itemFont = _itemFont;
@synthesize selectedItemColor = _selectedItemColor;
@synthesize selectedItemTextColor = _selectedItemTextColor;
@synthesize selectedItemFont = _selectedItemFont;

- (void)dealloc {
}

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
    _selectedIndex = -1;
    _mutableItemValues = [NSMutableArray new];
#if TARGET_INTERFACE_BUILDER
    _mutableItemValues = @[@"1", @"2", @"3"];
#endif
    _mutableSelectedItemValues = [NSMutableArray new];
#if TARGET_INTERFACE_BUILDER
    _mutableSelectedItemValues = @[@"1", @"2 selected", @"3 long selected"];
#endif
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                 initWithTarget:self action:@selector(tapGestureRecognizerAction:)];
    [self addGestureRecognizer:_tapGestureRecognizer];
    
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
    self.contentPathLayer.masksToBounds = true;
    [self.layer addSublayer:self.contentPathLayer];
    
    [self resetLayers];
}

- (void)resetLayers {
    if (self.itemValues.count == 0) {
        self.contentPathLayer.path = nil;
        self.contentPathLayer.bounds = CGRectZero;
        self.borderPathLayer.bounds = CGRectZero;
        self.borderPathLayer.path = nil;
        self.selectedRect = CGRectZero;
        self.selectedIndex = -1;
        return;
    }
    
    CGPathRef contentLayerPath = [self __calculateLayerPath];
    CGRect contentLayerBounds = CGPathGetBoundingBox(contentLayerPath);
    
    self.contentPathLayer.path = contentLayerPath;
    self.contentPathLayer.bounds = contentLayerBounds;
    
    self.borderPathLayer.path = contentLayerPath;
    self.borderPathLayer.bounds = contentLayerBounds;
}

- (CGRect)__calculateLayerRectForIndex:(NSUInteger)index {
    CGSize defaultItemSize = [self defaultSize];
    CGFloat itemSpace = self.itemSpace;
    CGFloat itemWidth = (defaultItemSize.width + itemSpace);
    CGRect itemRect;
    
    if (self.selectedIndex == index) {
        CGPoint itemPoint = CGPointMake(index * itemWidth, 0);
        
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.alignment = NSTextAlignmentCenter;
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
                                                       options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:textAttributes
                                                       context:nil].size.width + 20;
        
        itemRect = (CGRect) {
            .origin = itemPoint,
            .size = CGSizeMake(MAX(textWidth, defaultItemSize.width), defaultItemSize.height)
        };
        
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
    
    [self.itemValues enumerateObjectsUsingBlock:^(NSString * _Nonnull obj,
                                                  NSUInteger index,
                                                  BOOL * _Nonnull stop) {
        CGRect itemRect = [self __calculateLayerRectForIndex:index];
        
        CATextLayer *textLayer = self.textLayers[index];
        textLayer.frame = itemRect;
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        if (index == self.selectedIndex) {
            textLayer.backgroundColor = self.selectedItemColor.CGColor;
            textLayer.foregroundColor = self.selectedItemTextColor.CGColor;
            textLayer.string = [self selectedValueAtIndex:index];
        }
        else {
            textLayer.backgroundColor = [UIColor clearColor].CGColor;
            textLayer.foregroundColor = self.itemTextColor.CGColor;
            textLayer.string = [self valueAtIndex:index];
        }
        
        [CATransaction commit];
        
        CGPathAddRoundedRect(layerPath, nil, itemRect, itemCornerRadius, itemCornerRadius);
    }];
    
    if (lineWidth) {
        CGRect pathRect = CGPathGetBoundingBox(layerPath);
        CGFloat pathWidth = CGRectGetWidth(pathRect);
        CGFloat pathHeight = CGRectGetHeight(pathRect);
        CGFloat lineRectHeight = MIN(lineWidth, pathHeight);
        CGFloat lineOffset = defaultItemSize.width;
        CGRect lineRect = CGRectMake(lineOffset / 2,
                                     pathHeight / 2 - lineRectHeight / 2,
                                     pathWidth - lineOffset,
                                     lineRectHeight);
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
    
    self.mutableSelectedItemValues[index] = selectedValue
    ?: value
    ?: self.mutableItemValues[index];
    
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

- (void)selectIndex:(NSInteger)index {
    [self selectIndex:index animated:NO];
}

- (void)selectIndex:(NSInteger)index animated:(BOOL)animated {
    if (index == -1) {
        self.selectedRect = CGRectZero;
    }
    
    if (animated) {
        CGPathRef prevContentPath = self.contentPathLayer.path;
        CGRect prevContentBounds = self.contentPathLayer.bounds;
        NSMutableArray *textLayerBounds = [NSMutableArray new];
        NSMutableArray *textLayerPosition = [NSMutableArray new];
        
        for (CALayer *layer in self.textLayers) {
            [textLayerBounds addObject:[NSValue valueWithCGRect:layer.bounds]];
            [textLayerPosition addObject:[NSValue valueWithCGPoint:layer.position]];
        }
        
        self.selectedIndex = index;
        [self resetLayers];
        
        [self.textLayers enumerateObjectsUsingBlock:^(CATextLayer * _Nonnull layer,
                                                      NSUInteger index,
                                                      BOOL * _Nonnull stop) {
            CABasicAnimation *boundsAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
            boundsAnimation.fromValue = textLayerBounds[index];
            CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
            positionAnimation.fromValue = textLayerPosition[index];
            CAAnimationGroup *animationGroup = [CAAnimationGroup new];
            [animationGroup setAnimations:@[boundsAnimation, positionAnimation]];
            animationGroup.duration = 0.35;
            animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [layer addAnimation:animationGroup forKey:@"bounds|position"];
        }];
        
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        pathAnimation.fromValue = (__bridge id _Nullable)(prevContentPath);
        CABasicAnimation *boundsAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
        boundsAnimation.fromValue = [NSValue valueWithCGRect:prevContentBounds];
        CAAnimationGroup *animationGroup = [CAAnimationGroup new];
        [animationGroup setAnimations:@[pathAnimation, boundsAnimation]];
        animationGroup.duration = 0.35;
        animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        [self.contentPathLayer addAnimation:animationGroup forKey:@"path|bounds"];
        
        if (self.borderWidth) {
            [self.borderPathLayer addAnimation:animationGroup forKey:@"path|bounds"];
        }
    }
    else {
        self.selectedIndex = index;
        [self resetLayers];
    }
    
    __weak __typeof(self) weakSelf = self;
    if ([weakSelf.delegate respondsToSelector:@selector(nhSegmentView:didChangeIndex:)]) {
        [weakSelf.delegate nhSegmentView:weakSelf didChangeIndex:index];
    }
}


#pragma mark - Actions

- (void)tapGestureRecognizerAction:(UIGestureRecognizer *)recognizer {
    
    CGPoint viewLocation = [recognizer locationInView:self];
    
    if (CGRectContainsPoint(self.contentPathLayer.frame, viewLocation)) {
        CGPoint layerLocation = [self.layer convertPoint:viewLocation toLayer:self.contentPathLayer];
        
        if (CGRectEqualToRect(CGRectZero, self.selectedRect)
            || !CGRectContainsPoint(self.selectedRect, layerLocation)) {
            NSInteger index = [self __calculateIndexFromPoint:layerLocation];
            if (index != -1) {
                [self selectIndex:index animated:YES];
            }
        }
    }
}

- (NSInteger)__calculateIndexFromPoint:(CGPoint)point {
    NSInteger resultIndex = -1;
    
    CGSize defaultItemSize = [self defaultSize];
    CGFloat itemWidth = defaultItemSize.width + self.itemSpace;
    
    if (CGRectEqualToRect(CGRectZero, self.selectedRect)) {
        resultIndex = floor(point.x / itemWidth);
    }
    else {
        CGFloat rectMinX = CGRectGetMinX(self.selectedRect);
        CGFloat rectMaxX = CGRectGetMaxX(self.selectedRect);
        
        if (point.x < rectMinX) {
            resultIndex = floor(point.x / itemWidth);
        }
        else if (point.x > rectMaxX) {
            CGFloat pointXValue = point.x - rectMaxX;
            NSInteger pointIndex = floor(pointXValue / itemWidth);
            resultIndex = self.selectedIndex + pointIndex + 1;
        }
    }
    
    return resultIndex;
}

#pragma mark - Getters and Setters

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
    for (CALayer *layer in self.textLayers) {
        layer.cornerRadius = cornerRadius;
    }
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
    for (CATextLayer *layer in self.textLayers) {
        layer.foregroundColor = itemTextColor.CGColor;
    }
}

- (UIColor *)itemTextColor {
    return _itemTextColor ?: [UIColor whiteColor];
}

- (void)setItemFont:(UIFont *)itemFont {
    _itemFont = itemFont;
    for (CATextLayer *layer in self.textLayers) {
        layer.font = (__bridge CFTypeRef _Nullable)(itemFont.fontName);
        layer.fontSize = itemFont.pointSize;
    }
}

- (UIFont *)itemFont {
    return _itemFont ?: [UIFont systemFontOfSize:17];
}

- (void)setSelectedItemColor:(UIColor *)selectedItemColor {
    _selectedItemColor = selectedItemColor;
    
    if (self.selectedIndex >= 0) {
        self.textLayers[self.selectedIndex].backgroundColor = self.selectedItemColor.CGColor;
    }
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

- (void)setSelectedRect:(CGRect)selectedRect {
    _selectedRect = selectedRect;
}

- (NSMutableArray<CATextLayer *> *)textLayers {
    if (_textLayers.count != self.itemValues.count) {
        for (CALayer *layer in _textLayers) {
            [layer removeFromSuperlayer];
        }
        
        _textLayers = [NSMutableArray new];
        for (int i = 0; i < self.itemValues.count; i++) {
            CATextLayer *layer = [CATextLayer layer];
            layer.backgroundColor = [UIColor clearColor].CGColor;
            layer.cornerRadius = self.cornerRadius;
            layer.font = (__bridge CFTypeRef _Nullable)(self.itemFont.fontName);
            layer.fontSize = self.itemFont.pointSize;
            layer.foregroundColor = self.itemTextColor.CGColor;
            layer.masksToBounds = YES;
            layer.alignmentMode = kCAAlignmentCenter;
            [self.contentPathLayer addSublayer:layer];
            
            [_textLayers addObject:layer];
        }
    }
    
    return _textLayers;
}

@end
