//
//  Header.h
//  barometer
//
//  Created by WangJiaLe on 3/31/16.
//  Copyright © 2016 wangjiale. All rights reserved.
//

#ifndef Header_h
#define Header_h


#define umengAppkey @""
#define baiduApiKey @""

#define wechatAppID @""
#define wechatAppSecret @""

#define QQAppId @""
#define QQAppKey @""

#define shareSDKAppKey @""
#define forgreen 1


#define PRE_IOS_8 ([UIDevice currentSystemVersion] < 8.0)//小于ios8.0的版本
#define ONE_PIXEL ([[UIScreen mainScreen] scale] > 0.0 ? 1.0 / [[UIScreen mainScreen] scale] : 1.0)

#define CurrentLanguage ([[NSLocale preferredLanguages] objectAtIndex:0])   //当前的设备的默认语言
#define isRetina ([[UIScreen mainScreen] scale]== 2 ? YES : NO)    //是否是高清屏

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)      //屏幕宽度
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)    //屏幕高度

//设置颜色
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

// rgb颜色转换（16进制->10进制）
#define HexColor(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#endif /* Header_h */
