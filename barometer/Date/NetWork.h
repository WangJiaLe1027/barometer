//
//  NetWork.h
//  barometer
//
//  Created by wangjiale on 16/4/1.
//  Copyright © 2016年 wangjiale. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeatherModel.h"

@interface NetWork : NSObject
- (WeatherModel *) requestDate;
@end
