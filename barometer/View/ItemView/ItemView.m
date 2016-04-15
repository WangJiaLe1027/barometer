//
//  ItemView.m
//  barometer
//
//  Created by wangjiale on 16/4/15.
//  Copyright © 2016年 wangjiale. All rights reserved.
//

#import "ItemView.h"

@implementation ItemView{
    CGFloat itemHeight;
    NSArray *itemArray;
}
- (id) initWithFrame:(CGRect)frame itemArray:(NSArray *)arr itemHeight:(CGFloat )height{
    self = [super initWithFrame:frame];
    if (self) {
        itemArray = arr;
        itemHeight = height;
        [self initUI];
    }
    return self;
}

- (void) initUI {
    for (NSInteger i = 0 ; i < [itemArray count]; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, i*itemHeight, self.frame.size.width, itemHeight)];
        [self addSubview:btn];
        [btn setTitle:itemArray[i] forState:0];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i;
    }
}

- (void) btnClick:(UIButton *)btn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickItemView:)]) {
        [self.delegate clickItemView:btn.tag];
    }
}

- (void) show3D {
    
}

@end
