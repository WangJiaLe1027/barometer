//
//  NetWork.m
//  barometer
//
//  Created by wangjiale on 16/4/1.
//  Copyright © 2016年 wangjiale. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "SVProgressHUD.h"
#import "Header.h"
#import "NetWork.h"
#import "YYModel.h"
#import "WeatherModel.h"

@interface NetWork ()
<
CLLocationManagerDelegate
>
@end

@implementation NetWork{
    CLLocationManager *locationManager;
    WeatherModel *model;
}

- (void) requestDate {
    if (!model) {
        [self getLocation];
    }else {
        
    }
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
    
    CLLocation *c = [[CLLocation alloc] initWithLatitude:currLocation.coordinate.latitude longitude:currLocation.coordinate.longitude];
    
    NSMutableArray *userDefaultLanguages = [[NSUserDefaults standardUserDefaults]objectForKey:@"AppleLanguages"];
    
    //简体中文
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:@"zh-hans",nil,nil] forKey:@"AppleLanguages"];
    
    CLGeocoder *revGeo = [[CLGeocoder alloc] init];
    [revGeo reverseGeocodeLocation:c
                 completionHandler:^(NSArray *placemarks, NSError *error) {
                     if (!error && [placemarks count] > 0)
                     {
                         NSDictionary *dict = [[placemarks objectAtIndex:0] addressDictionary];
                         
                         NSString *httpUrl = @"http://apis.baidu.com/heweather/weather/free";
                         NSString *httpArg = [NSString stringWithFormat:@"city=%@",[dict objectForKey:@"City"]];
                         if ([httpArg length]) {
                             NSMutableString *ms = [[NSMutableString alloc] initWithString:httpArg];
                             
                             if (CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformMandarinLatin, NO)) {
                             }
                             
                             if (CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformStripDiacritics, NO)) {
                                 NSLog(@"pinyin: %@", ms);
                                 httpArg = ms;
                             }
                             
                         }
                         httpArg = [httpArg stringByReplacingOccurrencesOfString:@" " withString:@""];
                         httpArg = [httpArg substringToIndex:httpArg.length-3];
                         
                         [self request: httpUrl withHttpArg: httpArg];
                         [[NSUserDefaults standardUserDefaults] setObject:userDefaultLanguages forKey:@"AppleLanguages"];
                     }
                     
                     else
                     {
                         NSLog(@"ERROR: %@", error); }
                 }];
    
}



-(void)request: (NSString*)httpUrl withHttpArg: (NSString*)HttpArg  {
    NSString *urlStr = [[NSString alloc]initWithFormat: @"%@?%@", httpUrl, HttpArg];
    NSURL *url = [NSURL URLWithString: urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 10];
    [request setHTTPMethod: @"GET"];
    [request addValue: baiduApiKey forHTTPHeaderField: @"apikey"];
    
    [NSURLConnection sendAsynchronousRequest: request
                                       queue: [NSOperationQueue mainQueue]
                           completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error){
                               if (error) {
                                   NSLog(@"Httperror: %@%ld", error.localizedDescription, error.code);
                               } else {
                                   
                                   NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                   
                                   
                                   NSArray *vl = [dic allValues];
                                   NSDictionary *dic2 = vl[0][0];
                                   
                                   WeatherModel *model = [WeatherModel yy_modelWithDictionary:dic2];
                                   NSLog(@"%@",model.suggestion.flu.txt);

                                   
                                   if (![[dic2 objectForKey:@"status"] isEqualToString:@"ok"]
                                       ) {
                                       [SVProgressHUD showErrorWithStatus:[dic2 objectForKey:@"status"]];
                                   }
                               }
                           }];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if ([error code]==kCLErrorDenied) {
        [SVProgressHUD showErrorWithStatus:@"访问地理位置被拒绝，请设置"];
    }
    if ([error code]==kCLErrorLocationUnknown) {
        [SVProgressHUD showErrorWithStatus:@"无法获取位置信息"];
    }
}


@end
