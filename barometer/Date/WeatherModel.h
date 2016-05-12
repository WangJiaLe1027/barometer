//
//  WeatherModel.h
//  barometer
//
//  Created by wangjiale on 16/4/1.
//  Copyright © 2016年 wangjiale. All rights reserved.
//

#import <Foundation/Foundation.h>

//suggestion
@interface suggestionTextModel : NSObject
@property (nonatomic, copy) NSString *brf;//指数
@property (nonatomic, copy) NSString *txt;//内容
@end

@interface suggestionModel : NSObject
@property (nonatomic, strong) suggestionTextModel *comf;//舒适指数
@property (nonatomic, strong) suggestionTextModel *cw;//洗车指数
@property (nonatomic, strong) suggestionTextModel *drsg;//穿衣指数
@property (nonatomic, strong) suggestionTextModel *flu;//感冒指数
@property (nonatomic, strong) suggestionTextModel *sport;//运动指数
@property (nonatomic, strong) suggestionTextModel *trav;//旅游指数
@property (nonatomic, strong) suggestionTextModel *uv;//紫外线指数
@end

//now
@interface nowCondModel : NSObject
@property (nonatomic, copy) NSString *code;//天气状况代码
@property (nonatomic, copy) NSString *text;//天气状况描述
@end

@interface nowWindModel : NSObject
@property (nonatomic, copy) NSString *deg;//风向（360度）
@property (nonatomic, copy) NSString *dir;//风向
@property (nonatomic, copy) NSString *sc;//风力
@property (nonatomic, copy) NSString *spd;//风速kmph
@end

@interface nowModel : NSObject
@property (nonatomic, strong) nowCondModel *cond; //天气状况
@property (nonatomic, strong) NSString *fl;   //30,体感温度
@property (nonatomic, strong) NSString *hum;  //20%",相对湿度（%）
@property (nonatomic, strong) NSString *pcpn; //0.0",降水量（mm）
@property (nonatomic, strong) NSString *pres; //1001",气压mBar
@property (nonatomic, strong) NSString *tmp;  //32",温度
@property (nonatomic, strong) NSString *vis;  //10", 能见度（km）
@property (nonatomic, strong) nowWindModel *wind; //风力风向
@end

//aqi
@interface aqiModel : NSObject
@property (nonatomic, copy) NSString *aqi;  //30",空气质量指数
@property (nonatomic, copy) NSString *co;   //0",一氧化碳1小时平均值(ug/m³)
@property (nonatomic, copy) NSString *no2;  //10",二氧化氮1小时平均值(ug/m³)
@property (nonatomic, copy) NSString *o3;   //94",臭氧1小时平均值(ug/m³)
@property (nonatomic, copy) NSString *pm10; //10",PM10 1小时平均值(ug/m³)
@property (nonatomic, copy) NSString *pm25; //7",PM2.5 1小时平均值(ug/m³)
@property (nonatomic, copy) NSString *qlty; //优",空气质量类别
@property (nonatomic, copy) NSString *so2;  //3"二氧化硫1小时平均值(ug/m³)
@end

@interface aqiCityModel : NSObject
@property (nonatomic, strong) aqiModel *city;
@end

//model
@interface WeatherModel : NSObject
@property (nonatomic, strong) aqiCityModel *aqi;
@property (nonatomic, strong) nowModel *now;
@property (nonatomic, strong) suggestionModel *suggestion;

@end
