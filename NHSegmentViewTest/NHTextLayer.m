//
//  NHTextLayer.m
//  NHSegmentViewTest
//
//  Created by Sergey Minakov on 28.02.16.
//  Copyright © 2016 Naithar. All rights reserved.
//

#import "NHTextLayer.h"

@implementation NHTextLayer

- (void)layoutSublayers {
    [super layoutSublayers];
    [self setNeedsDisplay];
}

- (void)drawInContext:(CGContextRef)ctx {
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat fontSize = self.fontSize;
    CGFloat translation = (height - fontSize) / 2 - fontSize / 10;
    
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, 0.0, translation);
    [super drawInContext:ctx];
    CGContextRestoreGState(ctx);
}

@end
