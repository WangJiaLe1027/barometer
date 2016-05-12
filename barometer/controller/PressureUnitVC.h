//
//  PressureUnitVC.h
//  barometer
//
//  Created by WangJiaLe on 5/12/16.
//  Copyright © 2016 wangjiale. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PressureUnitVCDelegate <NSObject>
- (void) unit:(NSString *)unit ;
@end

@interface PressureUnitVC : UIViewController
@property (nonatomic, copy) NSString *pressStr;
@property (nonatomic, assign) id<PressureUnitVCDelegate> delegate;
@end
