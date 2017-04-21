//
//  TriolionViewController.m
//  LotteryNews
//
//  Created by 邹壮壮 on 2016/12/20.
//  Copyright © 2016年 邹壮壮. All rights reserved.
//

#import "TriolionViewController.h"
#import "LottoryCategoryModel.h"
#import "LNLotteryCategories.h"
#import <MJRefresh/MJRefresh.h>
#import "UserStore.h"
#import "LiuXSegmentView.h"
#import "TriolionModel.h"
#import "TriolionCell.h"
#import "TriolionTopAdModel.h"
#import "LNWebViewController.h"
#import "TriolionFootCell.h"
#import "LNLottoryConfig.h"
#import "LNScrollerView.h"
#import <SVProgressHUD.h>
#import "RankListModel.h"
#import "PersonalHomePageViewController.h"
#import "LoginViewController.h"
static NSString *triolionCellCellWithIdentifier = @"triolionCellCellWithIdentifier";
static NSString *TriolionFootCellWithIdentifier = @"TriolionFootCellWithIdentifier";
@interface TriolionViewController ()<UITableViewDelegate,UITableViewDataSource,TriolionFootCellDelagate,LNScrollerViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) LottoryCategoryModel *categoryModel;
@property (nonatomic, strong) LiuXSegmentView *segmentView;
@property (nonatomic, strong) NSMutableArray *adArray;
@property (nonatomic, strong) LNScrollerView *scrollerView;
@property (nonatomic, strong) NSMutableArray *rankListArray;
@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation TriolionViewController
- (NSMutableArray *)dataArray{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
- (NSMutableArray *)adArray{
    if (_adArray == nil) {
        _adArray = [NSMutableArray array];
    }
    return _adArray;
}
- (NSMutableArray *)rankListArray{
    if (_rankListArray == nil) {
        _rankListArray = [NSMutableArray array];
    }
    return _rankListArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configUI];
    self.kNavigationOpenTitle = YES;
    self.navigationItemTitle = @"彩大师  预测资料";
    
    // Do any additional setup after loading the view.
}
- (void)configUI{
    
    _segmentView = [[LiuXSegmentView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 44) segmentType:@"category" titles:[LNLotteryCategories sharedInstance].categoryArray clickBlick:^(NSInteger index) {
        _selectedIndex = index;
        if (_tableView) {
            if (index==0) {
                _tableView.tableHeaderView = _scrollerView;
                
            }else{
                _tableView.tableHeaderView = [[UIView alloc]init];
              
            }
        }
        _categoryModel = [[LNLotteryCategories sharedInstance].categoryArray  objectAtIndex:index];
        [self loadNewData];
    }];
    [self.view addSubview:_segmentView];
    _scrollerView = [[LNScrollerView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 150)];
    _scrollerView.delegate = self;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_segmentView.frame)+1, kScreenWidth, SCREEN_HEIGHT-tabBarHeight-navigationBarHeight-statusBarHeight-CGRectGetHeight(_segmentView.frame)-1) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.view addSubview:_tableView];
    _tableView.tableHeaderView = _scrollerView;
    _tableView.tableFooterView = [[UIView alloc]init];
    _tableView.rowHeight =  115;
    _tableView.estimatedRowHeight = 100;//必须设置好预估值
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([TriolionCell class]) bundle:nil] forCellReuseIdentifier:triolionCellCellWithIdentifier];
    [_tableView registerClass:[TriolionFootCell class] forCellReuseIdentifier:TriolionFootCellWithIdentifier];
    LottoryCategoryModel *caModel=  [LNLotteryCategories sharedInstance].currentLottoryModel;
    _categoryModel = caModel;
    
    [self refreshHeader];
    [self refreshFooter];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kLotteryDataCategoryNotification:) name:kLotteryDataCategoryNotification object:nil];
    [MobClick beginLogPageView:@"TriolionViewController"];
}
#pragma mark - 数据加载
#pragma mark -- 刷新数据
- (void)refreshHeader{
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    // 设置文字
    [header setTitle:@"下拉刷新" forState:MJRefreshStateIdle];
    [header setTitle:@"刷新数据" forState:MJRefreshStatePulling];
    [header setTitle:@"加载中..." forState:MJRefreshStateRefreshing];
    
    // 设置字体
    header.stateLabel.font = [UIFont systemFontOfSize:15];
    header.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:14];
    
    // 设置颜色
    header.stateLabel.textColor = [UIColor grayColor];
    header.lastUpdatedTimeLabel.textColor = [UIColor grayColor];
    
    // 马上进入刷新状态
    [header beginRefreshing];
    
    // 设置刷新控件
    self.tableView.mj_header = header;
     self.tableView.mj_footer.automaticallyChangeAlpha = YES;
}

- (void)refreshFooter{
    // 添加默认的上拉刷新
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
    // 设置文字
    [footer setTitle:@"点击或上拉刷新" forState:MJRefreshStateIdle];
    [footer setTitle:@"加载更多" forState:MJRefreshStateRefreshing];
    [footer setTitle:@"没有更多数据了" forState:MJRefreshStateNoMoreData];
    
    // 设置字体
    footer.stateLabel.font = [UIFont systemFontOfSize:17];
    
    // 设置颜色
    footer.stateLabel.textColor = [UIColor  grayColor];
    footer.automaticallyHidden = YES;
    footer.automaticallyRefresh = NO;
    // 设置footer
    
    self.tableView.mj_footer = footer;
}


//- (void)kLotteryDataCategoryNotification:(NSNotification *)notification{
//    id value = notification.object;
//    if ([value isKindOfClass:[LottoryCategoryModel class]]) {
//        _categoryModel = (LottoryCategoryModel *)value;
//        [self loadNewData];
//    }
//}
- (void)loadNewData{
     _currentPage = 1;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queue, ^{
         [self loadData:ScrollDirectionDown];
    });
     dispatch_group_async(group, queue, ^{
         if (_selectedIndex == 0) {
             [self rankList];
         }
         });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [_tableView.mj_header endRefreshing];
        [_tableView reloadData];
        [SVProgressHUD dismiss];
        });


   
}
- (void)loadMoreData{
    if (_selectedIndex != 0) {
        _currentPage += 1;
        [self loadData:ScrollDirectionUp];
    }else{
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
        self.tableView.mj_footer.hidden = YES;
    }
    
    
}
- (void)loadData:(ScrollDirection)direction{
    [SVProgressHUD showWithStatus:@"Loading..."];
    kWeakSelf(self);
    [[UserStore sharedInstance] newsCategory:_categoryModel.caipiaoid page:_currentPage sucess:^(NSURLSessionDataTask *task, id responseObject) {
        //NSLog(@"%@",responseObject);
        NSNumber *codeNum = [responseObject objectForKey:@"code"];
        NSInteger code = [codeNum integerValue];
        if (code == 1) {
            NSArray *datas = [responseObject objectForKey:@"data"];
            NSMutableArray *arrayM = [NSMutableArray array];
            for (NSDictionary *dict in datas) {
                TriolionModel *model = [[TriolionModel alloc]initWithDictionary:dict error:nil];
                [arrayM addObject:model];
                
            }
            if (direction == ScrollDirectionDown) {
                weakself.dataArray = [arrayM mutableCopy];
            }else{
                [weakself.dataArray addObjectsFromArray:arrayM];
               
            }
            //顶部滚动数据
            NSArray *topadArray = [responseObject objectForKey:@"top_ad"];
            //请求到数据再清空原有数据
            if (topadArray.count > 0) {
                if (_adArray.count > 0) {
                    [_adArray  removeAllObjects];
                }
            }
            for (NSDictionary *dict in topadArray) {
                TriolionTopAdModel *topadModel = [[TriolionTopAdModel alloc]initWithDictionary:dict error:nil];
                [weakself.adArray addObject:topadModel];
            }
            
        }else{
            [weakself.tableView.mj_footer endRefreshingWithNoMoreData];
            weakself.tableView.mj_footer.hidden = YES;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_adArray.count>0) {
                _scrollerView.imageArray = _adArray;
            }
            
            [SVProgressHUD dismissWithDelay:1];
            if (direction == ScrollDirectionDown) {
                
                [weakself.tableView.mj_header endRefreshing];
                [weakself.tableView reloadData];
            }else if(direction == ScrollDirectionUp){
                
                [weakself.tableView reloadData];
                [weakself.tableView.mj_footer endRefreshing];
                
            }
        });
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}
- (void)rankList{
    NSDictionary *dict = @{@"playtype":@"1039",@"caipiaoid":@"1001",@"jisu_api_id":@"11"};
    
        kWeakSelf(self);
        
        [[UserStore sharedInstance]expert_rank:dict sucess:^(NSURLSessionDataTask *task, id responseObject) {
            
            //NSLog(@"%@",responseObject);
            NSNumber *codeNum = [responseObject objectForKey:@"code"];
            NSInteger code= [codeNum integerValue];
            if (code == 1) {
                NSArray *datas = [responseObject objectForKey:@"data"];
                if (datas.count > 0) {
                    if (_rankListArray.count > 0) {
                        [_rankListArray removeAllObjects];
                    }
                }
                for (NSDictionary *dict in datas) {
                    RankListModel *model = [[RankListModel alloc]initWithDictionary:dict error:nil];
                    [weakself.rankListArray addObject:model];
                }
               
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.tableView.mj_header endRefreshing];
                [weakself.tableView reloadData];
                [SVProgressHUD dismiss];
                
            });
            
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
    
}




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_selectedIndex == 0) {
        if (self.rankListArray.count > 0) {
            return 2;
        }else{
            return 1;
        }
    }else{
        return 1;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0) {
        return _dataArray.count;
    }else{
        return 1;
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 115;
    }else{
        return 140;
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return 20;
    }else{
        return 30;
    }
}
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"";
    }else{
        return @"推荐专家";
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        TriolionCell *cell = [tableView dequeueReusableCellWithIdentifier:triolionCellCellWithIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (self.dataArray.count > indexPath.row) {
            TriolionModel *model = [self.dataArray objectAtIndex:indexPath.row];
            cell.triolionModel = model;
        }
        return cell;
    }else{
        TriolionFootCell *cell = [tableView dequeueReusableCellWithIdentifier:TriolionFootCellWithIdentifier];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (self.rankListArray.count > 0) {
            [cell reloadScrollerView:_rankListArray];
        }
        return cell;
    }
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_dataArray.count > indexPath.row) {
        TriolionModel *model = [self.dataArray objectAtIndex:indexPath.row];
        NSURL *url = [NSURL URLWithString:model.url];
        LNWebViewController *web = [[LNWebViewController alloc]initWithURL:url];
        web.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:web animated:NO];
    }
    
}
- (void)selectedImageView:(RankListModel *)model{
    NSString *userID = UserDefaultObjectForKey(LOTTORY_AUTHORIZATION_UID);
    if (userID) {
        PersonalHomePageViewController *personalHomeVC = [[PersonalHomePageViewController alloc]init];
        personalHomeVC.expert_id = model.expert_id;
        personalHomeVC.nickname = model.nickname;
        personalHomeVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:personalHomeVC animated:YES];
    }else{
        [self presentViewController:[[LoginViewController alloc]init] animated:YES completion:nil];
    }
    
}
- (void)LNScrollerViewDidClicked:(NSUInteger)index{
    TriolionTopAdModel *model = [_adArray objectAtIndex:index];
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:model.link]];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
    [MobClick endLogPageView:@"TriolionViewController"];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView)
    {
        CGFloat sectionHeaderHeight = 20;//此高度为heightForHeaderInSection高度值
        if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
}

@end
