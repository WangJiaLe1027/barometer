//
//  ViewController.m
//  barometer
//
//  Created by wangjiale on 16/3/18.
//  Copyright © 2016年 wangjiale. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
#import "Header.h"
#import "SVProgressHUD.h"
#import "ViewController.h"
#import "IGLDropDownItem.h"
#import "IGLDropDownMenu.h"
#import "NetWork.h"

@interface ViewController ()
@end

@implementation ViewController {
    CLLocationManager *locationManager;
    CMAltimeter *myCMA;
    
    UILabel *labelForA;
    UILabel *labelForP;
    UILabel *labelForRealP;
    NetWork *net;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
     net = [NetWork new ];
    [net requestDate];
    
    labelForA = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 300, 100)];
    [self.view addSubview:labelForA];
    labelForP = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 300, 200)];
    [self.view addSubview:labelForP];
    labelForRealP = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 300, 300)];
    [self.view addSubview:labelForRealP];
    
    
    
    myCMA = [[CMAltimeter alloc] init];
    if (![CMAltimeter isRelativeAltitudeAvailable]) {
        [SVProgressHUD showErrorWithStatus:@"当前设备不支持气压计"];
    }
    [myCMA startRelativeAltitudeUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAltitudeData * _Nullable altitudeData, NSError * _Nullable error) {
        labelForA.text = [NSString stringWithFormat:@"%@",altitudeData.relativeAltitude];
        labelForP.text = [NSString stringWithFormat:@"%@",altitudeData.pressure];
    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
