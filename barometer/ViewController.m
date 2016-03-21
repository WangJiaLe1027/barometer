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
    
    __weak IBOutlet UIButton *starBtn;
    __weak IBOutlet UIButton *endBtn;
    
    CLLocationManager *locationManager;
    CMAltimeter *myCMA;
    
    UILabel *labelForA;
    UILabel *labelForP;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *httpUrl = @"http://apis.baidu.com/heweather/weather/free";
    NSString *httpArg = @"city=beijing";
    [self request: httpUrl withHttpArg: httpArg];
    
    labelForA = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 300, 100)];
    [self.view addSubview:labelForA];
    labelForP = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 300, 200)];
    [self.view addSubview:labelForP];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    locationManager.distanceFilter=10;
    locationManager.delegate=self;
    [locationManager requestWhenInUseAuthorization];
    [locationManager startUpdatingLocation];
    
    myCMA = [[CMAltimeter alloc] init];
    if (![CMAltimeter isRelativeAltitudeAvailable]) {
        [self showAlert:@"iPhone6以前设备，硬件不支持气压计"];
    }
    [myCMA startRelativeAltitudeUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAltitudeData * _Nullable altitudeData, NSError * _Nullable error) {
        labelForA.text = [NSString stringWithFormat:@"%@",altitudeData.relativeAltitude];
        labelForP.text = [NSString stringWithFormat:@"%@",altitudeData.pressure];
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


-(void)request: (NSString*)httpUrl withHttpArg: (NSString*)HttpArg  {
    NSString *urlStr = [[NSString alloc]initWithFormat: @"%@?%@", httpUrl, HttpArg];
    NSURL *url = [NSURL URLWithString: urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 10];
    [request setHTTPMethod: @"GET"];
    [request addValue: @"" forHTTPHeaderField: @"apikey"];
    [NSURLConnection sendAsynchronousRequest: request
                                       queue: [NSOperationQueue mainQueue]
                           completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error){
                               if (error) {
                                   NSLog(@"Httperror: %@%ld", error.localizedDescription, error.code);
                               } else {
                                   NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                   NSArray *vl = [dic allValues];
                                   NSDictionary *dic2 = vl[0][0];
                                   NSDictionary *dic3 = [dic2 objectForKey:@"now"];
                                   NSLog(@"stauts:%@",[dic2 objectForKey:@"status"]);
                                   NSLog(@"123");
                               }
                           }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)timerFireMethod:(NSTimer*)theTimer//弹出框
{
    UIAlertView *promptAlert = (UIAlertView*)[theTimer userInfo];
    [promptAlert dismissWithClickedButtonIndex:0 animated:NO];
    promptAlert =NULL;
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
