//
//  NetWork.h
//  barometer
//
//  Created by wangjiale on 16/4/1.
//  Copyright © 2016年 wangjiale. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeatherModel.h"

@protocol NetWorkDelegate <NSObject>
- (void)Model:(WeatherModel *)model;
@end


@interface NetWork : NSObject
- (void) requestDate:(CLLocation *)currLocation;
@property (nonatomic, assign) id<NetWorkDelegate> delegate;
@end
