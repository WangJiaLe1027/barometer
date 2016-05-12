//
//  PressureUnitVC.m
//  barometer
//
//  Created by WangJiaLe on 5/12/16.
//  Copyright © 2016 wangjiale. All rights reserved.
//

#import "PressureUnitVC.h"
#import "Header.h"

@interface PressureUnitVC ()
<
UITextViewDelegate,
UITableViewDataSource,
UITableViewDelegate
>

@end

@implementation PressureUnitVC {
    UITableView *unitTableView;
    NSArray *unitArray;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    unitArray = @[@"兆帕(MPa)",@"千帕(kPa)",@"帕(Pa)",@"磅力/英寸²(lbf/in²=psi)",@"毫米汞柱(mmHg)",@"毫米水柱(mmH2O)",@"英寸水柱(inH2O)",@"千克力/厘米²(kgf/cm²)",@"标准大气压(atm)",@"巴(bar)",@"毫巴(mbar)",@"托(Torr)"];
    
    unitTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
    unitTableView.delegate = self;
    unitTableView.dataSource = self;
    [self.view addSubview:unitTableView];
    
    [self.view setBackgroundColor:[UIColor colorWithWhite:1 alpha:1]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    label.text = @"选择单位";
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView setEditing:NO animated:YES];
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"编辑数值" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        NSLog(@"!@#");
    }];
    editAction.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
    return @[editAction];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [unitArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.frame = CGRectMake(0, 0, SCREEN_WIDTH, 100);
    }
    cell.textLabel.text = unitArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self didSelect:indexPath.row];
}

- (void) didSelect:(NSInteger)lineNumber {
    if (self.delegate && [self.delegate respondsToSelector:@selector(unit:)]) {
        [self.delegate unit:unitArray[lineNumber]];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end