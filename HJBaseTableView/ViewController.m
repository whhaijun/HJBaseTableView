//
//  ViewController.m
//  HJBaseTableView
//
//  Created by admin on 2020/12/8.
//  Copyright © 2020 HJ. All rights reserved.
//

#import "ViewController.h"
#import "HJBaseTableView.h"

@interface HJCellModel : NSObject
@property (nonatomic, strong) NSString *title;
@end

@implementation HJCellModel

@end

@interface ViewController ()
@property (nonatomic, strong) HJBaseTableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSources;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _dataSources = @[].mutableCopy;
    [self getDatasMethod];
    
    [self.view addSubview:self.tableView];
    
    HJBaseTableSectionModel *sectionModel = [[HJBaseTableSectionModel alloc] initWithRowData:self.dataSources];
    self.tableView.datas = @[sectionModel];
    [self.tableView reloadData];
    self.tableView.cellIdAndClassOfModelCallBack = ^NSDictionary * _Nonnull(id  _Nonnull model, NSIndexPath * _Nonnull indexPath) {
        return @{@"cellIdentifier":[UITableViewCell class]};
    };
    
    self.tableView.configCellIndexPathWithModelCallBack = ^(id  _Nonnull model, UITableViewCell * _Nonnull cell, NSIndexPath * _Nonnull indexPath, BOOL isCellTap, BOOL isCellHeight) {
        HJCellModel *cellModel = model;
        cell.textLabel.text = cellModel.title;
    };
}

- (void)getDatasMethod {
    for (int i = 0; i < 50; i ++) {
        HJCellModel *model = [HJCellModel new];
        model.title = [NSString stringWithFormat:@"我是第%d行的title",i];
        [self.dataSources addObject:model];
    }
}

- (HJBaseTableView *)tableView {
    if (!_tableView) {
        _tableView = [[HJBaseTableView alloc] initWithFrame:self.view.frame];
    }
    return _tableView;
}

@end
