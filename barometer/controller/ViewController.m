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

#import "IGLDropDownMenu.h"

static const CGFloat topPadding = 40;
@interface ViewController ()
<
CLLocationManagerDelegate,
NetWorkDelegate
>
@end

@implementation ViewController {
    CMAltimeter *myCMA;
    CLLocationManager *locationManager;
    
    UIView *bgView;
    CGFloat lastPointX;
    
    IGLDropDownMenu *dropDownMenu;
    
    UILabel *titleLabel;
    UILabel *pressLabel;
    UILabel *heightChangeLabel;
    UILabel *tipsLabel;
    
    NetWork *net;
    WeatherModel *localModel;
    
    BOOL shouldUpdateModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self getLocation];
    
    localModel = [[WeatherModel alloc] init];
    
    lastPointX = 0;
    
    
    UITapGestureRecognizer *tapTipsLabel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refreshTips)];
    [tipsLabel setUserInteractionEnabled:YES];
    [tipsLabel addGestureRecognizer:tapTipsLabel];
    
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
        pressLabel.text = [NSString stringWithFormat:@"%.4fkPa",altitudeData.pressure.floatValue];
    }];
}


- (void) initBtn {
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topView];
    
    NSArray *titleArray = @[@"气压",@"气压与情绪",@"气压与死亡",@"气压与天气"];
    NSMutableArray *dropdownItems = [[NSMutableArray alloc] init];
    for (NSString *title in titleArray) {
        IGLDropDownItem *item = [[IGLDropDownItem alloc] init];
        [item setText:title];
        [dropdownItems addObject:item];

    }
    dropDownMenu = [[IGLDropDownMenu alloc] init];
    [dropDownMenu setFrame:CGRectMake(0, 20, SCREEN_WIDTH * 0.618, 50)];
    dropDownMenu.menuText = @"当前气压";
    dropDownMenu.backgroundColor = [UIColor whiteColor];
    dropDownMenu.paddingLeft = 20;
    
    dropDownMenu.type = IGLDropDownMenuTypeFlipFromLeft;
    dropDownMenu.itemAnimationDelay = 0.1;
    dropDownMenu.rotate = IGLDropDownMenuRotateNone;
    dropDownMenu.dropDownItems = dropdownItems;
    
    [self.view addSubview:dropDownMenu];
    [dropDownMenu reloadView];
}


- (void) initUI {
    [self initBtn];
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
           [dropDownMenu setExpanding:YES];
        }else if(bgView.frame.origin.x < SCREEN_WIDTH*0.6){
            [UIView animateWithDuration:0.2 animations:^{
                bgView.frame = normalFrame;
            }];
            [dropDownMenu setExpanding:NO];
        }else {
            [UIView animateWithDuration:0.2 animations:^{
                bgView.frame = tapFrame;
            }];
            [dropDownMenu setExpanding:YES];
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
