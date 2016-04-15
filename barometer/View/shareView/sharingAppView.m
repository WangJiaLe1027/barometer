//
//  SharingAppView.m
//
//  Created by 王嘉乐 on 15/8/21.
//  Copyright (c) 2015年 wangjiale. All rights reserved.
//

#import "sharingAppView.h"
#import "Header.h"
#import "SVProgressHUD.h"

#import <ShareSDK/ShareSDK.h>

//腾讯开放平台（对应QQ和QQ空间）SDK头文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

//微信SDK头文件
#import "WXApi.h"



typedef enum : NSUInteger {
    ShareTypeWechatSession = 1,     //微信
    ShareTypeWechatTimeline,        //微信朋友圈
    ShareTypeQQ,
    ShareTypeQQzone
} ShareType;

@interface sharingAppView ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *imageName;
@end

@implementation sharingAppView {
    UIView *_bgView;
    CGFloat _padding;
}

- (void)dealloc{
    NSLog(@"%s", __FUNCTION__);
}

+ (sharingAppView *) showView {
    sharingAppView *view = [[sharingAppView alloc] init];
    [view setUpView];
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    [window addSubview:view];
    return view;
}


+ (sharingAppView *)showViewWithtitle:(NSString *)title content:(NSString *)content url:(NSString *)url imageName:(NSString *)imageName {
        sharingAppView *view = [[sharingAppView alloc] init];
        view.title = title;
        view.content = content;
        view.url = url;
        view.imageName = imageName;
        
        [view setUpView];
        UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
        [window addSubview:view];
        return view;
}


- (void) setUpView {
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.backgroundColor = [UIColor clearColor];
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(10, SCREEN_HEIGHT, SCREEN_WIDTH - 20, 200)];
    _bgView.backgroundColor = [UIColor clearColor];
    [self addSubview:_bgView];
    
    UIView *sharingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _bgView.bounds.size.width, 135)];
    sharingView.backgroundColor = [UIColor whiteColor];
    sharingView.layer.cornerRadius = 3.0f;
    sharingView.layer.masksToBounds = YES;
    [_bgView addSubview:sharingView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, sharingView.bounds.size.width, 45)];
    titleLabel.backgroundColor = [UIColor whiteColor];
    titleLabel.text = @"分享到";
    titleLabel.font = [UIFont systemFontOfSize:14.0f];
    titleLabel.textColor = HexColor(0x646464);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [sharingView addSubview:titleLabel];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 44.5, titleLabel.bounds.size.width, 0.5)];
    line.backgroundColor = HexColor(0xdcdcdc);
    [sharingView addSubview:line];
    
    [_bgView addSubview:[self setBtn]];
    
    UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancleBtn.frame = CGRectMake(0, _bgView.bounds.size.height - 55, _bgView.bounds.size.width, 45);
    cancleBtn.backgroundColor = [UIColor whiteColor];
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBtn setTitleColor:HexColor(0x46a0f0) forState:UIControlStateNormal];
    cancleBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    cancleBtn.layer.cornerRadius = 3.0f;
    [_bgView addSubview:cancleBtn];
    [cancleBtn addTarget:self action:@selector(cancleBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        _bgView.frame = CGRectMake(10, SCREEN_HEIGHT - 200, SCREEN_WIDTH - 20, 200);
    } completion:^(BOOL finished) {
    }];
}

- (UIView *) setBtn {
    UIView *sharingBtnView = [[UIView alloc] initWithFrame:CGRectMake(0, 45, SCREEN_WIDTH - 20, 90)];
    sharingBtnView.layer.cornerRadius = 3.0f;
    sharingBtnView.backgroundColor = [UIColor whiteColor];
    
    if ([WXApi isWXAppInstalled] && [QQApiInterface isQQInstalled]) {
        _padding = (sharingBtnView.frame.size.width - 160) / 8;
    } else {
        _padding = (sharingBtnView.frame.size.width - 80) / 4;
    }
    
    if ([WXApi isWXAppInstalled] ) {
        UIButton * btn1 = [self initialBtnWithTitle:@"微信"
                                               font:[UIFont systemFontOfSize:12.0f]
                                              actio:@selector(shareBtnClick:)
                                    normalTitlColor:HexColor(0x969696)
                                          imageName:@"btn_articleShare_WechatSession.png"];
        btn1.tag = ShareTypeWechatSession;
        btn1.frame = CGRectMake(_padding, 15, 40, 40);
        [sharingBtnView addSubview:btn1];
        
        UIButton * btn2 = [self initialBtnWithTitle:@"朋友圈"
                                               font:[UIFont systemFontOfSize:12.0f]
                                              actio:@selector(shareBtnClick:)
                                    normalTitlColor:HexColor(0x969696)
                                          imageName:@"btn_articleShare_WechatTimeline.png"];
        
        btn2.tag = ShareTypeWechatTimeline;
        btn2.frame = CGRectMake(_padding * 3 + 40, 15, 40, 40);
        [sharingBtnView addSubview:btn2];
    }
    
    
    if ([QQApiInterface isQQInstalled]) {
        UIButton * btn3 = [self initialBtnWithTitle:@"QQ好友"
                                               font:[UIFont systemFontOfSize:12.0f]
                                              actio:@selector(shareBtnClick:)
                                    normalTitlColor:HexColor(0x969696)
                                          imageName:@"btn_articleShare_QQ.png"];
        btn3.tag = ShareTypeQQ;
        if ([WXApi isWXAppInstalled]) {
            btn3.frame = CGRectMake(_padding * 5 + 80, 15, 40, 40);
        }else {
            btn3.frame = CGRectMake(_padding, 15, 40, 40);
        }
        [sharingBtnView addSubview:btn3];
        
        UIButton * btn4 = [self initialBtnWithTitle:@"QQ空间"
                                               font:[UIFont systemFontOfSize:12.0f]
                                              actio:@selector(shareBtnClick:)
                                    normalTitlColor:HexColor(0x969696)
                                          imageName:@"btn_articleShare_QQzone.png"];
        btn4.tag = ShareTypeQQzone;
        if ([WXApi isWXAppInstalled]) {
            btn4.frame = CGRectMake(_padding * 7 + 120 , 15, 40, 40);
        }else {
            btn4.frame = CGRectMake(_padding * 3 + 40, 15, 40, 40);
        }
        [sharingBtnView addSubview:btn4];
    }
    return sharingBtnView;
}

-(UIButton *)initialBtnWithTitle:(NSString *)title font:(UIFont *)font actio:(SEL)action normalTitlColor:(UIColor *)normalTitleColor imageName:(NSString *)imageName
{
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateSelected];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn setTitleColor:normalTitleColor forState:UIControlStateNormal];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = font;
    btn.titleEdgeInsets = UIEdgeInsetsMake(70, -43, 0, 0);
    return btn;
}

- (void) cancleBtnClick {
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundColor = [UIColor clearColor];
        _bgView.frame = CGRectMake(10, SCREEN_HEIGHT, SCREEN_WIDTH - 20, 200);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma  -mark 分享内容
-(void)shareBtnClick:(UIButton *)btn {
    NSString *title= self.title ? self.title : @"";
    NSString *body= self.content ? self.content : @"";
    NSString *url = self.url ? self.url : @"";
    UIImage *image = [UIImage imageNamed:self.imageName ? self.imageName : @"icon"];
    [self share:btn title:title content:body url:url image:image];
}

- (void)share:(UIButton *)btn title:(NSString *)title content:(NSString *)body url:(NSString *)url image:(UIImage *)image {
    NSArray* imageArray = @[image];
    switch (btn.tag) {
        case ShareTypeWechatSession:{
            if (![WXApi isWXAppInstalled]){
                [SVProgressHUD showErrorWithStatus:@"无法分享"];
                return;
            }
            
            if (imageArray) {
                NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
                [shareParams SSDKSetupShareParamsByText:[NSString stringWithFormat:@"气压会影响情绪，我这里气压为%@，这种气压让可能让你感到情绪平稳。",body]
                                                 images:imageArray
                                                    url:[NSURL URLWithString:url]
                                                  title:title
                                                   type:SSDKContentTypeAuto];
            [ShareSDK share:SSDKPlatformSubTypeWechatSession parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                switch (state) {
                    case SSDKResponseStateSuccess:
                    {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                            message:nil
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"确定"
                                                                  otherButtonTitles:nil];
                        [alertView show];
                        break;
                    }
                    case SSDKResponseStateFail:
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                        message:[NSString stringWithFormat:@"%@",error]
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil, nil];
                        [alert show];
                        break;
                    }
                    default:
                        break;
                }
            }];
                [self cancleBtnClick];
            }
            break;
        }
        case ShareTypeWechatTimeline:
        {
            if (![WXApi isWXAppInstalled]){
                [SVProgressHUD showErrorWithStatus:@"无法分享"];
                return;
            }
            if (imageArray) {
                NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
                [shareParams SSDKSetupShareParamsByText:body
                                                 images:imageArray
                                                    url:[NSURL URLWithString:url]
                                                  title:[NSString stringWithFormat:@"我这里气压为%@，这种气压可能让你感到情绪平稳。",body]
                                                   type:SSDKContentTypeAuto];
                [ShareSDK share:SSDKPlatformSubTypeWechatTimeline parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                    switch (state) {
                        case SSDKResponseStateSuccess:
                        {
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                                message:nil
                                                                               delegate:nil
                                                                      cancelButtonTitle:@"确定"
                                                                      otherButtonTitles:nil];
                            [alertView show];
                            break;
                        }
                        case SSDKResponseStateFail:
                        {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                            message:[NSString stringWithFormat:@"%@",error]
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil, nil];
                            [alert show];
                            break;
                        }
                        default:
                            break;
                    }
                }];
                [self cancleBtnClick];
            }
            break;
        }
        case ShareTypeQQ:
        {
            if (![WXApi isWXAppInstalled]){
                [SVProgressHUD showErrorWithStatus:@"无法分享"];
                return;
            }
            if (imageArray) {
                NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
                [shareParams SSDKSetupShareParamsByText:body
                                                 images:imageArray
                                                    url:[NSURL URLWithString:url]
                                                  title:title
                                                   type:SSDKContentTypeAuto];
                [ShareSDK share:SSDKPlatformSubTypeQQFriend parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                    switch (state) {
                        case SSDKResponseStateSuccess:
                        {
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                                message:nil
                                                                               delegate:nil
                                                                      cancelButtonTitle:@"确定"
                                                                      otherButtonTitles:nil];
                            [alertView show];
                            break;
                        }
                        case SSDKResponseStateFail:
                        {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                            message:[NSString stringWithFormat:@"%@",error]
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil, nil];
                            [alert show];
                            break;
                        }
                        default:
                            break;
                    }
                }];
                [self cancleBtnClick];
            }
            break;
        }
        case ShareTypeQQzone:
        {
            if (![WXApi isWXAppInstalled]){
                [SVProgressHUD showErrorWithStatus:@"无法分享"];
                return;
            }
            if (imageArray) {
                NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
                [shareParams SSDKSetupShareParamsByText:body
                                                 images:imageArray
                                                    url:[NSURL URLWithString:url]
                                                  title:title
                                                   type:SSDKContentTypeAuto];
                [ShareSDK share:SSDKPlatformSubTypeQZone parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                    switch (state) {
                        case SSDKResponseStateSuccess:
                        {
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                                message:nil
                                                                               delegate:nil
                                                                      cancelButtonTitle:@"确定"
                                                                      otherButtonTitles:nil];
                            [alertView show];
                            break;
                        }
                        case SSDKResponseStateFail:
                        {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                            message:[NSString stringWithFormat:@"%@",error]
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil, nil];
                            [alert show];
                            break;
                        }
                        default:
                            break;
                    }
                }];
                [self cancleBtnClick];
            }
            break;
        }
        default:
            break;
    }
}
    
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    CGPoint cotentViewPoint = [self convertPoint:touchPoint toView:_bgView];
    BOOL inside = [_bgView pointInside:cotentViewPoint withEvent:event];
    if (!inside) {
        [self cancleBtnClick];
    }
}


@end
