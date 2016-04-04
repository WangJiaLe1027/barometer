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
#import "WeatherModel.h"

#import "sharingAppView.h"

static const CGFloat topPadding = 40;
@interface ViewController ()
@end

@implementation ViewController {
    CMAltimeter *myCMA;
    
    UILabel *titleLabel;
    UILabel *pressLabel;
    UILabel *heightChangeLabel;
    UILabel *tipsLabel;
    
    BOOL tap;
    NetWork *net;
    WeatherModel *model;
    UIView *bgView;
    
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
    
    [bgView addGestureRecognizer:leftSwipeGestureRecognizer];
    [bgView addGestureRecognizer:rightSwipeGestureRecognizer];
    
    
    net = [NetWork new ];
    model = [net requestDate];
    
    
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 30, 30)];
    btn.backgroundColor = [UIColor blackColor];
    [btn addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:btn];
    
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
    [self.view setBackgroundColor:HexColor(0x646464)];
    
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [bgView setBackgroundColor:HexColor(0xffffff)];
    [self.view addSubview:bgView];
    
    titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.frame = CGRectMake(0, topPadding, SCREEN_WIDTH, titleLabel.font.lineHeight);
    titleLabel.text = @"当前气压";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:titleLabel];
    
    pressLabel = [[UILabel alloc] init];
    pressLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:55];
    pressLabel.frame = CGRectMake(0,  topPadding * 2 + titleLabel.frame.size.height, SCREEN_WIDTH, pressLabel.font.lineHeight);
    pressLabel.textAlignment = NSTextAlignmentCenter;
    pressLabel.text = @"测量中...";
    [bgView addSubview:pressLabel];
    
    tipsLabel = [[UILabel alloc] init];
    tipsLabel.font = [UIFont systemFontOfSize:16];
    tipsLabel.frame = CGRectMake(20,  topPadding * 3 + titleLabel.frame.size.height + pressLabel.frame.size.height, SCREEN_WIDTH - 40, pressLabel.font.lineHeight);
    tipsLabel.textAlignment = NSTextAlignmentLeft;
    tipsLabel.numberOfLines = 0;
    tipsLabel.text = @"tips:\n        昼夜温差较大，较易发生感冒，请适当增减衣服。体质较弱的朋友请注意防护。";
    [bgView addSubview:tipsLabel];
    
    
}

- (void) btnClick {
    CGRect normalFrame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    CGRect tapFrame = CGRectMake(200, 0, SCREEN_WIDTH, SCREEN_HEIGHT);

    [UIView animateWithDuration:0.2 animations:^{
        bgView.frame = tap ? normalFrame : tapFrame;
    }];
    tap = !tap;
}

- (void)handleSwipes:(UISwipeGestureRecognizer *)sender
{
    CGRect normalFrame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    CGRect tapFrame = CGRectMake(200, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        [UIView animateWithDuration:0.2 animations:^{
            bgView.frame = normalFrame;
        }];
    }
    
    if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
        [UIView animateWithDuration:0.2 animations:^{
            bgView.frame = tapFrame;
        }];
    }
}

- (void) share {
    
    [sharingAppView showViewWithtitle:@"气压计情绪" content:pressLabel.text url:@"http://wangjiale1027.github.io/qiyaji" imageName:@"icon"];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
