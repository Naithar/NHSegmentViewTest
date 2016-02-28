//
//  ViewController.m
//  NHSegmentViewTest
//
//  Created by Sergey Minakov on 27.02.16.
//  Copyright © 2016 Naithar. All rights reserved.
//

#import "ViewController.h"
#import "NHSegmentView.h"

@interface ViewController ()<NHSegmentViewDelegate>

@property (nonatomic, strong) NHSegmentView *segmentView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self __setupViews];
}

- (void)__setupViews {
    
    CGFloat viewWidth = CGRectGetWidth(self.view.bounds);
    CGFloat viewMidY = CGRectGetMidY(self.view.bounds);
    
    CGRect segmentRect = CGRectMake(15, viewMidY - 50, viewWidth - 30, 100);
    self.segmentView = [[NHSegmentView alloc] initWithFrame:segmentRect];
    self.segmentView.delegate = self;
    self.segmentView.backgroundColor = [UIColor redColor];
    
    [self.view addSubview:self.segmentView];
    
    [self.segmentView setValues:@[@"1", @"2", @"3"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Segment View Delegate
- (void)nhSegmentView:(NHSegmentView *)segmentView didChangeIndex:(NSInteger)index {
    NSLog(@"changed index to %ld", index);
}

@end
