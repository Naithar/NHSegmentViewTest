//
//  NHSegmentView.m
//  NHSegmentViewTest
//
//  Created by Sergey Minakov on 27.02.16.
//  Copyright © 2016 Naithar. All rights reserved.
//

#import "NHSegmentView.h"

@interface NHSegmentView ()


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
    
}

- (void)prepareForInterfaceBuilder {
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
