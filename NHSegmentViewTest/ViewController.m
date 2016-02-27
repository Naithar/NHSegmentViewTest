//
//  ViewController.m
//  NHSegmentViewTest
//
//  Created by Sergey Minakov on 27.02.16.
//  Copyright © 2016 Naithar. All rights reserved.
//

#import "ViewController.h"
#import "NHSegmentView.h"

@interface ViewController ()

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
    self.segmentView.backgroundColor = [UIColor redColor];
    
    [self.view addSubview:self.segmentView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
