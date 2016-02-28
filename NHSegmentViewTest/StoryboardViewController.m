//
//  StoryboardViewController.m
//  NHSegmentViewTest
//
//  Created by Sergey Minakov on 27.02.16.
//  Copyright © 2016 Naithar. All rights reserved.
//

#import "StoryboardViewController.h"
#import "NHSegmentView.h"

@interface StoryboardViewController ()

@property (strong, nonatomic) IBOutlet NHSegmentView *segmentView;
@property (strong, nonatomic) IBOutlet UILabel *segmentLabel;

@end

@implementation StoryboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.segmentView setValues:@[@"1", @"2", @"3"]];
    [self.segmentView changeValue:nil selectedValue:@"1 long text to select" atIndex:0];
    [self.segmentView changeValue:nil selectedValue:@"2 long text to select" atIndex:1];
    [self.segmentView changeValue:nil selectedValue:@"3 long text to select" atIndex:2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

@interface StoryboardViewController (SegmentDelegate)<NHSegmentViewDelegate>

@end

@implementation StoryboardViewController (SegmentDelegate)

- (void)nhSegmentView:(NHSegmentView *)segmentView didChangeIndex:(NSInteger)index {
    NSLog(@"changed index to %ld", index);
    
    self.segmentLabel.text = [@(index) stringValue];
}

@end