//
//  NHSegmentView.h
//  NHSegmentViewTest
//
//  Created by Sergey Minakov on 27.02.16.
//  Copyright © 2016 Naithar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NHSegmentViewDelegate <NSObject>

@end

IB_DESIGNABLE
@interface NHSegmentView : UIView

@property (nonatomic, nullable, weak) IBOutlet id<NHSegmentViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
