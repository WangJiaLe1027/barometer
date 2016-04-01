//
//  ViewController.m
//  barometer
//
//  Created by wangjiale on 16/3/18.
//  Copyright © 2016年 wangjiale. All rights reserved.
//
#import "ViewController.h"

#import <CoreMotion/CoreMotion.h>
#import "SVProgressHUD.h"
#import "NetWork.h"
#import "Header.h"

static const CGFloat topPadding = 40;
@interface ViewController ()
@end

@implementation ViewController {
    CMAltimeter *myCMA;
    
    UILabel *titleLabel;
    UILabel *pressLabel;
    UILabel *heightChangeLabel;
    
    BOOL tap;
    NetWork *net;
    
    UISwipeGestureRecognizer *leftSwipeGestureRecognizer;
    UISwipeGestureRecognizer *rightSwipeGestureRecognizer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    tap = NO;
    
    
    leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    
    leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.view addGestureRecognizer:leftSwipeGestureRecognizer];
    [self.view addGestureRecognizer:rightSwipeGestureRecognizer];
    
    
    net = [NetWork new ];
    [net requestDate];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 30, 30)];
    btn.backgroundColor = [UIColor blackColor];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btn];
    
    myCMA = [[CMAltimeter alloc] init];
    if (![CMAltimeter isRelativeAltitudeAvailable]) {
        [SVProgressHUD showErrorWithStatus:@"当前设备不支持气压计"];
    }
    [myCMA startRelativeAltitudeUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAltitudeData * _Nullable altitudeData, NSError * _Nullable error) {
//        .text = [NSString stringWithFormat:@"%@",altitudeData.relativeAltitude];
        pressLabel.text = [NSString stringWithFormat:@"%.4fkPa",altitudeData.pressure.floatValue];
    }];
    
    
}
- (void) initUI {
    titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.frame = CGRectMake(0, topPadding, SCREEN_WIDTH, titleLabel.font.lineHeight);
    titleLabel.text = @"当前气压";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    
    pressLabel = [[UILabel alloc] init];
    pressLabel.font = [UIFont systemFontOfSize:55];
    pressLabel.frame = CGRectMake(0,  topPadding * 2 + titleLabel.frame.size.height, SCREEN_WIDTH, pressLabel.font.lineHeight);
    pressLabel.textAlignment = NSTextAlignmentCenter;
    pressLabel.text = @"测量中...";
    [self.view addSubview:pressLabel];
}

- (void) btnClick {
    CGRect normalFrame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    CGRect tapFrame = CGRectMake(200, 0, SCREEN_WIDTH, SCREEN_HEIGHT);

    [UIView animateWithDuration:0.2 animations:^{
        self.view.frame = tap ? normalFrame : tapFrame;
    }];
    tap = !tap;
}

- (void)handleSwipes:(UISwipeGestureRecognizer *)sender
{
    CGRect normalFrame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    CGRect tapFrame = CGRectMake(200, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        [UIView animateWithDuration:0.2 animations:^{
            self.view.frame = normalFrame;
        }];
    }
    
    if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
        [UIView animateWithDuration:0.2 animations:^{
            self.view.frame = tapFrame;
        }];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
