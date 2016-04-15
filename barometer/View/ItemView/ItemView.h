//
//  ItemView.h
//  barometer
//
//  Created by wangjiale on 16/4/15.
//  Copyright © 2016年 wangjiale. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ItemViewDelegate <NSObject>

-(void)clickItemView:(NSInteger)row;

@end


@interface ItemView : UIView
- (id) initWithFrame:(CGRect)frame itemArray:(NSArray *)arr itemHeight:(CGFloat )height;

- (void) show3D;

@property (nonatomic,assign) id<ItemViewDelegate> delegate;
@end
