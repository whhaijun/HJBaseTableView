//
//  HJBaseTableView.m
//  CMSPaaS
//
//  Created by HJ on 2020/9/17.
//

#import "HJBaseTableView.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import <objc/runtime.h>

@implementation HJBaseTableSectionModel

-(instancetype)initWithRowData:(NSArray *)datas {
    if (self = [super init]) {
        self.rowDatas = datas;
    }
    return self;
}

@end


@interface HJBaseTableView()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>

@end

@interface HJBaseTableView()
@property (nonatomic,strong)NSMutableDictionary *estimatedRowHeightDic;
@property (nonatomic,strong)NSMutableArray *cellIsRegist;
@property (nonatomic,assign)CGFloat contentOffsetY;
@end

@implementation HJBaseTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self configTableViewMethod];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configTableViewMethod];
    }
    return self;
}

- (void)configTableViewMethod {
    self.delegate = self;
    self.dataSource = self;
    _estimatedRowHeightDic = @{}.mutableCopy;
    /// 默认没有线
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (@available(iOS 11.0, *)) {
        self.estimatedRowHeight = 0;
        self.estimatedSectionHeaderHeight = 0;
        self.estimatedSectionFooterHeight = 0;
    }
    self.cellIsRegist = @[].mutableCopy;
}

- (void)registerCellOfClass:(Class)cellClass indentifier:(NSString *)indentifier {
    NSString *cellClassName = NSStringFromClass(cellClass);
    NSString *xibPath = [[NSBundle mainBundle] pathForResource:cellClassName ofType:@"nib"];
    if (xibPath) {
        [self registerNib:[UINib nibWithNibName:cellClassName bundle:[NSBundle mainBundle]] forCellReuseIdentifier:indentifier];
    }
    else {
        [self registerClass:cellClass forCellReuseIdentifier:indentifier];
    }
}

- (void)registerSectionViewOfClass:(Class)cellClass indentifier:(NSString *)indentifier {
    NSString *cellClassName = NSStringFromClass(cellClass);
    NSString *xibPath = [[NSBundle mainBundle] pathForResource:cellClassName ofType:@"nib"];
    if (xibPath) {
        [self registerNib:[UINib nibWithNibName:cellClassName bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:indentifier];
    }
    else {
        [self registerClass:cellClass forHeaderFooterViewReuseIdentifier:indentifier];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.datas.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.datas.count > section) {
        HJBaseTableSectionModel *model = self.datas[section];
        return model.rowDatas.count;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isEstimatedHeight) {
        if (_contentOffsetY < tableView.contentOffset.y) {
            CGFloat cellHeight = 0.0;
            if ([self.fd_indexPathHeightCache existsHeightAtIndexPath:indexPath]) {
                cellHeight = [self.fd_indexPathHeightCache heightForIndexPath:indexPath];
            }
            else {
                if (self.datas.count > indexPath.section) {
                    HJBaseTableSectionModel *model = self.datas[indexPath.section];
                    if (model.rowDatas.count > indexPath.row) {
                        id model1 = model.rowDatas[indexPath.row];
                        cellHeight = [self.estimatedRowHeightDic[NSStringFromClass([model1 class])] floatValue];
                    }
                }
                if (cellHeight == 0) {
                    if (indexPath.row > 1) {
                        NSIndexPath *index = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
                        cellHeight = [tableView rectForRowAtIndexPath:index].size.height;
                    }
                }
            }
            self.estimatedRowHeight = cellHeight;
        }
        _contentOffsetY = tableView.contentOffset.y;
    }
    if (self.configCellWillDisplayBlock) {
        if (self.datas.count > indexPath.section) {
            HJBaseTableSectionModel *model = self.datas[indexPath.section];
            if (model.rowDatas.count > indexPath.row) {
                id model1 = model.rowDatas[indexPath.row];
                self.configCellWillDisplayBlock(model1, cell, indexPath,NO);
            }
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.datas.count > indexPath.section) {
        HJBaseTableSectionModel *model = self.datas[indexPath.section];
        if (model.rowDatas.count > indexPath.row) {
            id model1 = model.rowDatas[indexPath.row];
            
            if (self.cellIdAndClassOfModelCallBack) {

                NSDictionary *dic = self.cellIdAndClassOfModelCallBack(model1,indexPath);
                NSString *cellId = dic.allKeys.firstObject;

                if (![self.cellIsRegist containsObject:cellId]) {
                    [self registerCellOfClass:dic.allValues.firstObject indentifier:cellId];
                }
                else {
                    [self.cellIsRegist addObject:cellId];
                }
//                /// 为了兼容绑定数据先调用高度计算
//                [self tableView:tableView heightForRowAtIndexPath:indexPath];
                
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
                if (self.configCellIndexPathWithModelCallBack) {
                    self.configCellIndexPathWithModelCallBack(model1, cell, indexPath, NO, NO);
                    return cell;
                }
                return cell;
            }
        }
    }
    return [[UITableViewCell alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isun_fd_height) {
        return UITableViewAutomaticDimension;
    }
    if ([self.fd_indexPathHeightCache existsHeightAtIndexPath:indexPath]) {
        return [self.fd_indexPathHeightCache heightForIndexPath:indexPath];
    }
    
    if (self.datas.count > indexPath.section) {
        HJBaseTableSectionModel *model = self.datas[indexPath.section];
        if (model.rowDatas.count > indexPath.row) {
            
            if (self.cellIdAndClassOfModelCallBack) {
                id model1 = model.rowDatas[indexPath.row];
                
                NSDictionary *dic = self.cellIdAndClassOfModelCallBack(model1,indexPath);
                NSString *cellId = dic.allKeys.firstObject;

                if (![self.cellIsRegist containsObject:cellId]) {
                    [self registerCellOfClass:dic.allValues.firstObject indentifier:cellId];
                }
                else {
                    [self.cellIsRegist addObject:cellId];
                }
                CGFloat height = [self fd_heightForCellWithIdentifier:cellId cacheByIndexPath:indexPath configuration:^(id cell) {
                    if (self.configCellIndexPathWithModelCallBack) {
                        self.configCellIndexPathWithModelCallBack(model1, cell, indexPath, NO, YES);
                    }
                    if (self.configCellWillDisplayBlock) {
                        self.configCellWillDisplayBlock(model1, cell, indexPath, YES);
                    }
                }];
                if (!self.estimatedRowHeightDic[NSStringFromClass([model1 class])]) {
                    self.estimatedRowHeightDic[NSStringFromClass([model1 class])] = @(height);
                }
                return height;
            }
        }
    }
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
       
    if (self.datas.count > indexPath.section) {
        HJBaseTableSectionModel *model = self.datas[indexPath.section];
        if (model.rowDatas.count > indexPath.row) {
            id model1 = model.rowDatas[indexPath.row];
            
            if (self.cellIdAndClassOfModelCallBack) {
                NSDictionary *dic = self.cellIdAndClassOfModelCallBack(model1,indexPath);
                NSString *cellId = dic.allKeys.firstObject;
                
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
                if (self.configCellIndexPathWithModelCallBack) {
                    self.configCellIndexPathWithModelCallBack(model1, cell, indexPath, YES, NO);
                }
                if (cell.selectCellAtRowModelCallBack) {
                    cell.selectCellAtRowModelCallBack(model1, indexPath);
                }
            }
        }
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.isCanEdit;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (self.delectCellWithModelCallBack) {
            if (self.datas.count > indexPath.section) {
                HJBaseTableSectionModel *model = self.datas[indexPath.section];
                if (model.rowDatas.count > indexPath.row) {
                    id model1 = model.rowDatas[indexPath.row];
                    NSDictionary *dic = self.cellIdAndClassOfModelCallBack(model1,indexPath);
                    NSString *cellId = dic.allKeys.firstObject;
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
                    self.delectCellWithModelCallBack(model1, cell,indexPath);
                }
            }
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [self sectionViewHeader:YES tableView:tableView Section:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [self sectionViewHeader:NO tableView:tableView Section:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [self sectionViewHeight:YES tableView:tableView Section:section];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return [self sectionViewHeight:NO tableView:tableView Section:section];
}

- (UIView *)sectionViewHeader:(BOOL)isHeader tableView:(UITableView *)tableView Section:(NSInteger)section {
    if (self.configSectionViewWithModelCallBack) {
    
        if (self.datas.count > section) {
            HJBaseTableSectionModel *model = self.datas[section];
            if (self.sectionViewIdAndClassOfModelCallBack) {
                NSDictionary *dic = self.sectionViewIdAndClassOfModelCallBack(isHeader,model,section);
                if (dic.count == 0) {
                    return [UIView new];
                }
                NSString *viewId = dic.allKeys.firstObject;
                [self registerSectionViewOfClass:dic.allValues.firstObject indentifier:viewId];
                
                UIView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:viewId];
            
                self.configSectionViewWithModelCallBack(model, view);
                return view;
            }
        }
    }
    return [UIView new];
}

- (CGFloat)sectionViewHeight:(BOOL)isHeader tableView:(UITableView *)tableView Section:(NSInteger)section {
    if (self.configSectionViewWithModelCallBack) {
        if (self.datas.count > section) {
            HJBaseTableSectionModel *model = self.datas[section];
            if (self.sectionViewIdAndClassOfModelCallBack) {
                NSDictionary *dic = self.sectionViewIdAndClassOfModelCallBack(isHeader,model,section);
                if (dic.count == 0) {
                    return 0.01;
                }
                NSString *viewId = dic.allKeys.firstObject;
                [self registerSectionViewOfClass:dic.allValues.firstObject indentifier:viewId];

                CGFloat height = [self cms_heightForHeaderFooterViewWithIdentifier:viewId configuration:^(UIView *view) {
                    self.configSectionViewWithModelCallBack(model, view);
                }];
                
                return height;
            }
        }
    }
    return 0.01;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.scrollViewDidScrollCallBack) {
        self.scrollViewDidScrollCallBack(scrollView);
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.scrollViewDidEndDraggingCallBack) {
        self.scrollViewDidEndDraggingCallBack(scrollView, decelerate);
    }
}

- (CGFloat )cms_heightForHeaderFooterViewWithIdentifier:(NSString *)identifier configuration:(void (^)(UIView *))configuration {
    UITableViewHeaderFooterView *templateHeaderFooterView = [self dequeueReusableHeaderFooterViewWithIdentifier:identifier];
    if (configuration) {
        configuration(templateHeaderFooterView);
    }
    NSLayoutConstraint *widthFenceConstraint = [NSLayoutConstraint constraintWithItem:templateHeaderFooterView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:CGRectGetWidth(self.frame)];
    [templateHeaderFooterView addConstraint:widthFenceConstraint];
    CGFloat fittingHeight = [templateHeaderFooterView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    [templateHeaderFooterView removeConstraint:widthFenceConstraint];

    if (fittingHeight == 0) {
        fittingHeight = [templateHeaderFooterView sizeThatFits:CGSizeMake(CGRectGetWidth(self.frame), 0)].height;
        if (fittingHeight == 0) {
            fittingHeight = templateHeaderFooterView.frame.size.height;
        }
    }

    return fittingHeight;
}

@end

static const char *tapCellCallBackkey = "CSMTapCellCallBackkey";

@implementation UITableViewCell (CMSTableViewCellTapCallBack)

- (CMSSelectCellAtRowModelBlock)selectCellAtRowModelCallBack {
    return objc_getAssociatedObject(self, tapCellCallBackkey);
}

- (void)setSelectCellAtRowModelCallBack:(CMSSelectCellAtRowModelBlock)selectCellAtRowModelCallBack {
    objc_setAssociatedObject(self, tapCellCallBackkey, selectCellAtRowModelCallBack, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

