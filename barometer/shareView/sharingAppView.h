//
//  SharingAppView.h
//
//  Created by 王嘉乐 on 15/8/21.
//  Copyright (c) 2015年 wangjiale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface sharingAppView : UIView

+ (sharingAppView *)showView;

+ (sharingAppView *)showViewWithtitle:(NSString *)title content:(NSString *)content url:(NSString *)url imageName:(NSString *)imageName;
@end
