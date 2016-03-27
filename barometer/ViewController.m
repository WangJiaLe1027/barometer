//
//  ViewController.m
//  barometer
//
//  Created by wangjiale on 16/3/18.
//  Copyright © 2016年 wangjiale. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController ()
<
CLLocationManagerDelegate
>
@end

@implementation ViewController {
    
    CLLocationManager *locationManager;
    CMAltimeter *myCMA;
    
    
    UILabel *labelForRelativeAltitude;
    UILabel *labelForPressure;
    UILabel *labelForRealP;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *titleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, [UIScreen mainScreen].bounds.size.width, 20)];
    titleLabel1.text = @"当前气压";
    titleLabel1.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel1];
    
    labelForRelativeAltitude = [[UILabel alloc] initWithFrame:CGRectMake(0, 220, [UIScreen mainScreen].bounds.size.width, 200)];
    labelForRelativeAltitude.textAlignment = NSTextAlignmentCenter;
    labelForRelativeAltitude.font = [UIFont systemFontOfSize:50];
    labelForRelativeAltitude.text = @"测量中……";
    [self.view addSubview:labelForRelativeAltitude];
    
    labelForPressure = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 200)];
    labelForPressure.textAlignment = NSTextAlignmentCenter;
    labelForPressure.font = [UIFont systemFontOfSize:50];
    labelForPressure.text = @"测量中……";
    [self.view addSubview:labelForPressure];
    
    labelForRealP = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 300, 300)];
    [self.view addSubview:labelForRealP];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    locationManager.distanceFilter=10;
    locationManager.delegate=self;
    [locationManager requestWhenInUseAuthorization];
    [locationManager startUpdatingLocation];
    
    myCMA = [[CMAltimeter alloc] init];
    if (![CMAltimeter isRelativeAltitudeAvailable]) {
        [self showAlert:@"硬件不支持气压计"];
    }
    [myCMA startRelativeAltitudeUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAltitudeData * _Nullable altitudeData, NSError * _Nullable error) {
        labelForRelativeAltitude.text = [NSString stringWithFormat:@"%.3fm",altitudeData.relativeAltitude.floatValue];
        labelForPressure.text = [NSString stringWithFormat:@"%.2fkPa",altitudeData.pressure.floatValue];
    }];
    
    
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *currLocation = [locations lastObject];
    NSLog(@"latitude%@",[NSString stringWithFormat:@"%f",currLocation.coordinate.latitude]);
    NSLog(@"longitude%@",[NSString stringWithFormat:@"%f",currLocation.coordinate.longitude]);
    NSLog(@"altitude%@",[NSString stringWithFormat:@"%f",currLocation.altitude]);
    NSLog(@"horizontalAccuracy%@",[NSString stringWithFormat:@"%f",currLocation.horizontalAccuracy]);
    NSLog(@"verticalAccuracy%@",[NSString stringWithFormat:@"%f",currLocation.verticalAccuracy]);
    NSLog(@"course%@",[NSString stringWithFormat:@"%f",currLocation.course]);
    NSLog(@"speed%@",[NSString stringWithFormat:@"%f",currLocation.speed]);
    NSLog(@"floor%@",[NSString stringWithFormat:@"%@",currLocation.floor]);
    NSLog(@"description%@",[NSString stringWithFormat:@"%@",currLocation.description]);
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if ([error code]==kCLErrorDenied) {
        NSLog(@"访问被拒绝");
    }
    if ([error code]==kCLErrorLocationUnknown) {
        NSLog(@"无法获取位置信息");
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)timerFireMethod:(NSTimer*)theTimer//弹出框
{
    UIAlertView *promptAlert = (UIAlertView*)[theTimer userInfo];
    [promptAlert dismissWithClickedButtonIndex:0 animated:NO];
    promptAlert = NULL;
}


- (void)showAlert:(NSString *) _message{//时间
    UIAlertView *promptAlert = [[UIAlertView alloc] initWithTitle:@"提示:" message:_message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    
    [NSTimer scheduledTimerWithTimeInterval:1.5f
                                     target:self
                                   selector:@selector(timerFireMethod:)
                                   userInfo:promptAlert
                                    repeats:YES];
    [promptAlert show];
}

@end
