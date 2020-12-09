//
//  HJBaseTableView.h
//  CMSPaaS
//
//  Created by HJ on 2020/9/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HJBaseTableSectionModel : NSObject

/// 作为 row 的数据源  （类型  id  ） model
@property (nonatomic,strong) NSArray *rowDatas;

/// 作为 headerView 的数据源  （类型  id  ） model
@property (nonatomic,strong) id headerModel;
/// 作为 footerView 的数据源  （类型  id  ） model
@property (nonatomic,strong) id footerModel;

/// 作为扩展字段  （类型  id  ） remark
@property (nonatomic,strong) id remark;

-(instancetype)initWithRowData:(NSArray *)datas;

@end

/// cell 获取重用标识符和 cell Class
typedef NSDictionary *_Nonnull(^CMSCellIdentifierAndClassOfModelBlock)(id model,NSIndexPath *indexPath);
///// cell 设置数据 没有 indexPath
//typedef void(^CMSConfigCellWithModelBlock)(id model,UITableViewCell *cell, BOOL isCellTap);
/// cell 设置数据 有 indexPath 有 isCellCacheHeight
typedef void(^CMSConfigCellIndexPathWithModelBlock)(id model, UITableViewCell *cell, NSIndexPath *indexPath, BOOL isCellTap, BOOL isCellHeight);
typedef void(^CMSDelectCellWithModelBlock)(id model,UITableViewCell *cell,NSIndexPath *indexPath);

typedef void(^CMSConfigCellWillDisplayBlock)(id model, UITableViewCell *cell, NSIndexPath *indexPath,BOOL getHeight);
typedef NSDictionary *_Nonnull(^CMSSectionViewIdentifierAndClassOfModelBlock)(BOOL isHeaderView,HJBaseTableSectionModel * sectionModel,NSInteger section);
typedef void(^CMSConfigSectionViewWithModelBlock)(HJBaseTableSectionModel * sectionModel,UIView *sectionView);
//typedef void(^CMSSectionViewTapGestureWithModelBlock)(HJBaseTableSectionModel * sectionModel,UIView *);

typedef void(^CMSScrollViewDidScrollBlock)(UIScrollView *scrollView);
typedef void(^CMSScrollViewDidEndDraggingBlock)(UIScrollView *scrollView,BOOL decelerate);


@interface HJBaseTableView : UITableView

/// 数据源  数组中放的 HJBaseTableSectionModel
@property (nonatomic,strong) NSArray *datas;

/// tableViewcell 是否可以编辑
@property (nonatomic,assign,getter=isCanEdit) BOOL canEdit;
/// tableViewcell 是否需要预算高度
@property (nonatomic,assign,getter=isEstimatedHeight) BOOL estimatedHeight;
/// tableViewcell 是否使用FD计算高度缓存 默认启用
@property (nonatomic,assign,getter=isun_fd_height) BOOL un_fd_height;
#pragma mark - 设置cell
/// 获取cell   class 作为 Identifier  通过model   return  @{"id":class}
@property (nonatomic,copy) CMSCellIdentifierAndClassOfModelBlock cellIdAndClassOfModelCallBack;
/// 设置 cell  的 数据 Model    return void    参数：model, cell, indexPath, isCache
@property (nonatomic,copy) CMSConfigCellIndexPathWithModelBlock configCellIndexPathWithModelCallBack;
/// 设置 cell  的 数据 即将显示cell    return  void  参数：model, cell, indexPath
@property (nonatomic,copy) CMSConfigCellWillDisplayBlock configCellWillDisplayBlock;

/// 删除cell 和数据源  通过 canEdit 属性来控制
@property (nonatomic,copy) CMSDelectCellWithModelBlock delectCellWithModelCallBack;

#pragma mark - 设置sectionView(headerView and footerView)
/// 获取headerFooter  class 作为 Identifier  通过model   return  @{"id":class}   根据是否是header 判断 headerView 或者 footerView
@property (nonatomic,copy) CMSSectionViewIdentifierAndClassOfModelBlock sectionViewIdAndClassOfModelCallBack;
/// headerFooter 配置数据
@property (nonatomic,copy) CMSConfigSectionViewWithModelBlock configSectionViewWithModelCallBack;
///// headerFooter 点击回调方法
//@property (nonatomic,copy) CMSSectionViewTapGestureWithModelBlock sectionViewTapGestureWithModelCallBack;

#pragma mark - 设置scrollView 滚动代理block
/// scrollViewDidScroll 滑动回调方法
@property (nonatomic,copy) CMSScrollViewDidScrollBlock scrollViewDidScrollCallBack;

@property (nonatomic,copy) CMSScrollViewDidEndDraggingBlock scrollViewDidEndDraggingCallBack;
@end

#pragma mark - 设置UITableViewCell 动态添加Tap block

typedef void(^CMSSelectCellAtRowModelBlock)(id ,NSIndexPath *);

@interface UITableViewCell (CMSTableViewCellTapCallBack)

/// cell  点击回调方法
@property (nonatomic,copy) CMSSelectCellAtRowModelBlock selectCellAtRowModelCallBack;

@end


NS_ASSUME_NONNULL_END
