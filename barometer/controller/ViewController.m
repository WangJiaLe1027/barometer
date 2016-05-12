//
//  ViewController.m
//  barometer
//
//  Created by wangjiale on 16/3/18.
//  Copyright © 2016年 wangjiale. All rights reserved.
//
#import "ViewController.h"

#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import "SVProgressHUD.h"

#import "NetWork.h"
#import "Header.h"
#import "WeatherModel.h"

#import "sharingAppView.h"
#import "ItemView.h"

#import "PressureUnitVC.h"

static const CGFloat topPadding = 40;
@interface ViewController ()
<
CLLocationManagerDelegate,
NetWorkDelegate,
ItemViewDelegate,
PressureUnitVCDelegate
>
@end

@implementation ViewController {
    CMAltimeter *myCMA;
    CLLocationManager *locationManager;
    
    UIView *bgView;
    CGFloat lastPointX;
    
    UILabel *titleLabel;
    UILabel *pressLabel;
    UILabel *heightChangeLabel;
    UILabel *tipsLabel;
    
    NetWork *net;
    WeatherModel *localModel;
    
    NSArray *itemArray;
    ItemView *item;
    
    BOOL shouldUpdateModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setHidden:YES];
    NSString *pressureUnit = [[NSUserDefaults standardUserDefaults] stringForKey:@"pressureUnit"];
    if ([pressureUnit length]>0) {
        
        
        
//        [[NSUserDefaults standardUserDefaults] setObject:newVersion forKey:@"guidePageVersion"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
    
    [self initUI];
    [self getLocation];
    
    localModel = [[WeatherModel alloc] init];
    lastPointX = 0;
    
    UITapGestureRecognizer *tapTipsLabel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refreshTips)];
    [tipsLabel setUserInteractionEnabled:YES];
    [tipsLabel addGestureRecognizer:tapTipsLabel];
    
    UITapGestureRecognizer *tapPressLabel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setUnitForPress)];
    [pressLabel setUserInteractionEnabled:YES];
    [pressLabel addGestureRecognizer:tapPressLabel];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(handlePan:)];
    [bgView addGestureRecognizer:panGestureRecognizer];
    
    net = [NetWork new];
    net.delegate = self;
    
    shouldUpdateModel = YES;
    
    
    myCMA = [[CMAltimeter alloc] init];
    [myCMA startRelativeAltitudeUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAltitudeData * _Nullable altitudeData, NSError * _Nullable error) {
        heightChangeLabel.text = [NSString stringWithFormat:@"海拔变化：%@米",altitudeData.relativeAltitude];
        pressLabel.text = [NSString stringWithFormat:@"%.4f%@",altitudeData.pressure.floatValue,@"kPa"];
    }];
}

- (void) initUI {
    self.view.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
    
    itemArray = @[@"所谓气",@"气压",@"气压与情绪",@"气压与天气",@"气压与健康",@"设置"];
    item = [[ItemView alloc] initWithFrame:CGRectMake(0, 100, SCREEN_WIDTH * 0.618, SCREEN_HEIGHT) itemArray:itemArray itemHeight:50];
    item.delegate = self;
    [self.view addSubview:item];
    
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
    
    heightChangeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, pressLabel.frame.origin.y + pressLabel.frame.size.height, SCREEN_WIDTH, 20)];
    heightChangeLabel.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:heightChangeLabel];
    
    
    tipsLabel = [[UILabel alloc] init];
    tipsLabel.font = [UIFont systemFontOfSize:16];
    tipsLabel.frame = CGRectMake(20,  topPadding * 3 + titleLabel.frame.size.height + pressLabel.frame.size.height, SCREEN_WIDTH - 40, pressLabel.font.lineHeight);
    tipsLabel.textAlignment = NSTextAlignmentLeft;
    tipsLabel.numberOfLines = 0;
    [bgView addSubview:tipsLabel];
    
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 40, SCREEN_WIDTH, 40)];
    btn.backgroundColor = [UIColor blackColor];
    [btn addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"分享气压" forState:0];
    [bgView addSubview:btn];
    
    
}

- (void) getLocation {
    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    locationManager.distanceFilter=10;
    locationManager.delegate = self;
    [locationManager requestWhenInUseAuthorization];
    [locationManager startUpdatingLocation];
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    CLLocation *currLocation = [locations lastObject];
    NSLog(@"altitude%@",[NSString stringWithFormat:@"%f",currLocation.altitude]);
    
    if (shouldUpdateModel) {
        [net requestDate:currLocation];
        shouldUpdateModel = NO;
    }

}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if ([error code]==kCLErrorDenied) {
        [SVProgressHUD showErrorWithStatus:@"访问地理位置被拒绝，请设置"];
    }
    if ([error code]==kCLErrorLocationUnknown) {
        [SVProgressHUD showErrorWithStatus:@"无法获取位置信息"];
    }
}

- (void) Model:(WeatherModel *)model {
    localModel = model;
    if (![CMAltimeter isRelativeAltitudeAvailable]) {
        [SVProgressHUD showErrorWithStatus:@"当前设备不支持气压计"];
        pressLabel.text = [NSString stringWithFormat:@"%@mBar",localModel.now.pres];
        heightChangeLabel.text = @"气压数据来源于网络";
    }
    [self refreshTips];
}

- (void) setUnitForPress {
    PressureUnitVC *vc = [[PressureUnitVC alloc] init];
    vc.delegate = self;
    [UIView animateWithDuration:0.2 animations:^{
        bgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    }];
    lastPointX = bgView.frame.origin.x;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) unit:(NSString *)unit {
    pressLabel.text = unit;
}


- (void) refreshTips {
    int rand = arc4random()%70;
    if(rand < 10) {
        tipsLabel.text = [NSString stringWithFormat:@"tips:\n       %@",localModel.suggestion.flu.txt];
    }else
    if(rand < 20) {
        tipsLabel.text = [NSString stringWithFormat:@"tips:\n       %@",localModel.suggestion.comf.txt];
    }else
    if(rand < 30) {
        tipsLabel.text = [NSString stringWithFormat:@"tips:\n       %@",localModel.suggestion.cw.txt];
    }else
    if(rand < 40) {
        tipsLabel.text = [NSString stringWithFormat:@"tips:\n       %@",localModel.suggestion.drsg.txt];
    }else
    if(rand < 50) {
        tipsLabel.text = [NSString stringWithFormat:@"tips:\n       %@",localModel.suggestion.sport.txt];
    }else
    if(rand < 60) {
        tipsLabel.text = [NSString stringWithFormat:@"tips:\n       %@",localModel.suggestion.trav.txt];
    }else
    if(rand < 70) {
        tipsLabel.text = [NSString stringWithFormat:@"tips:\n       %@",localModel.suggestion.uv.txt];
    }
    tipsLabel.text = [NSString stringWithFormat:@"%@\naqi:%@\npm2.5:%@\n当地气压:%@\n当地气温:%@",tipsLabel.text,localModel.aqi.city.aqi,localModel.aqi.city.pm25,localModel.now.pres,localModel.now.tmp];
    tipsLabel.frame = CGRectMake(20,  topPadding * 3 + titleLabel.frame.size.height + pressLabel.frame.size.height, SCREEN_WIDTH - 40, [tipsLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH - 40, MAXFLOAT)].height);
}

- (void) share {
    [sharingAppView showViewWithtitle:@"气压计情绪" content:pressLabel.text url:@"http://wangjiale1027.github.io/qiyaji" imageName:@"icon"];
}


- (void) clickItemView:(NSInteger)row {
    UIViewController *vc = [[UIViewController alloc] init];
    [vc.view setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    label.text = itemArray[row];
    label.textAlignment = NSTextAlignmentCenter;
    [vc.view addSubview:label];
    
    [UIView animateWithDuration:0.2 animations:^{
        bgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    }];
    lastPointX = bgView.frame.origin.x;
    [self.navigationController pushViewController:vc animated:YES];
}



- (void) handlePan:(UIPanGestureRecognizer*) recognizer {
    CGPoint point = [recognizer translationInView:self.view];
    CGRect normalFrame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    CGRect tapFrame = CGRectMake(SCREEN_WIDTH * 0.618, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    if(recognizer.state == UIGestureRecognizerStateBegan) {
        
    }else if(recognizer.state == UIGestureRecognizerStateChanged){
        if (lastPointX == 0) {
            if (bgView.frame.origin.x < SCREEN_WIDTH * 0.618) {
                [self changeView:bgView x:point.x];
            }
        }else{
            if (bgView.frame.origin.x > 0) {
                [self changeViewLeft:bgView x:point.x];
            }
            
        }
    }else if(recognizer.state == UIGestureRecognizerStateEnded){
        if (bgView.frame.origin.x > SCREEN_WIDTH * 0.25 && lastPointX == 0) {
            [UIView animateWithDuration:0.2 animations:^{
                bgView.frame = tapFrame;
            }];
            [item show3D];
        }else if(bgView.frame.origin.x < SCREEN_WIDTH*0.6){
            [UIView animateWithDuration:0.2 animations:^{
                bgView.frame = normalFrame;
            }];
            [item show3D];
        }else {
            [UIView animateWithDuration:0.2 animations:^{
                bgView.frame = tapFrame;
            }];
        }
        lastPointX = bgView.frame.origin.x;
    }
}

- (void)changeView:(UIView*)view x:(CGFloat)x {
    if (x<0) {
        return;
    }
    CGRect viewFrame = view.frame;
    viewFrame.origin.x = x;
    view.frame = viewFrame;
}

- (void)changeViewLeft:(UIView*)view x:(CGFloat)x {
    if (x>0) {
        return;
    }
    CGRect viewFrame = view.frame;
    viewFrame.origin.x = SCREEN_WIDTH*0.618 + x;
    view.frame = viewFrame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
