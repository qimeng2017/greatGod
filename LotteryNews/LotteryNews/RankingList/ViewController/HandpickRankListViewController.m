//
//  HandpickRankListViewController.m
//  LotteryNews
//
//  Created by 邹壮壮 on 2017/3/23.
//  Copyright © 2017年 邹壮壮. All rights reserved.
//

#import "HandpickRankListViewController.h"
#import <MJRefresh/MJRefresh.h>
#import "LNLotteryCategories.h"
#import "LNLottoryConfig.h"
#import "UserStore.h"

#import "RankListModel.h"
#import "HandpickRankListCell.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "PersonalHomePageViewController.h"
#import "RankListViewController.h"
#import "LoginViewController.h"
static NSString *HandpickRankListCellCellWithIdentifier = @"HandpickRankListCellCellWithIdentifier";
@interface HandpickRankListViewController ()<UITableViewDelegate,UITableViewDataSource,HandpickRankListCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSArray *playArray;

@property (nonatomic, strong) MJRefreshNormalHeader *header;
@property (nonatomic, assign) BOOL isReceverNotification;
@property (nonatomic, assign) NSInteger index;
@end

@implementation HandpickRankListViewController
NSDictionary *handpickDictionary;

- (NSMutableArray *)dataArray{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _isReceverNotification = YES;
    _index = 0;
    self.view.backgroundColor = LRRandomColor;
    
    [self configUI];
    // Do any additional setup after loading the view.
}
- (void)configUI{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, SCREEN_HEIGHT-kTabBarH-kStatusBarH-kNavigationBarH) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    self.tableView.rowHeight =  200;
    self.tableView.estimatedRowHeight = 200;//必须设置好预估值
    [self.view addSubview:_tableView];
    
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([HandpickRankListCell class]) bundle:nil] forCellReuseIdentifier:HandpickRankListCellCellWithIdentifier];
    _tableView.tableFooterView = [[UIView alloc]init];
   
    
    [self refreshHeader];
    
    //[self refreshFooter];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kLotteryDateSuccessedNotification:) name:kLotteryDateSuccessedNotification object:nil];
    [MobClick beginLogPageView:@"HandpickRankListViewController"];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([LNLotteryCategories sharedInstance].categoryPlayArray.count > 0) {
        
        _playArray = [LNLotteryCategories sharedInstance].categoryPlayArray;
       
    }
    
}

- (void)kLotteryDateSuccessedNotification:(NSNotification *)notification{
    id value = notification.object;
    if ([value isKindOfClass:[NSDictionary class]]) {
        if (_isReceverNotification) {
            if ([LNLotteryCategories sharedInstance].categoryPlayArray.count > 0) {
              _playArray = [LNLotteryCategories sharedInstance].categoryPlayArray;
                [_header beginRefreshing];
                
            }
            
        }
        
    }
}
//递归处理
- (void)loadPlay{
    
    if (_playArray.count > 0) {
        LottoryCategoryModel *lottoryModel = [LNLotteryCategories sharedInstance].currentLottoryModel;
        LottoryPlaytypemodel *playModel = [_playArray objectAtIndex:_index];
        NSDictionary *dict = @{@"playtype":playModel.playtype,@"caipiaoid":lottoryModel.caipiaoid,@"jisu_api_id":lottoryModel.jisu_api_id};
        kWeakSelf(self);
        
        [[UserStore sharedInstance]expert_rank:dict sucess:^(NSURLSessionDataTask *task, id responseObject) {
            NSNumber *codeNum = [responseObject objectForKey:@"code"];
            NSInteger code= [codeNum integerValue];
            if (code == 1) {
                NSArray *datas = [responseObject objectForKey:@"data"];
                NSMutableArray *arr = [NSMutableArray array];
                for (NSDictionary *dict in datas) {
                    RankListModel *model = [[RankListModel alloc]initWithDictionary:dict error:nil];
                    [arr addObject:model];
                }
                NSDictionary *dic = @{@"name":playModel.playtype_name,@"array":arr};
                [weakself.dataArray addObject:dic];
                _index += 1;
                if (_index < _playArray.count) {
                    [self loadPlay];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself.tableView.mj_header endRefreshing];
                    [weakself.tableView reloadData];
                    [SVProgressHUD dismiss];
                    
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself.tableView.mj_header endRefreshing];
                    [weakself.tableView reloadData];
                    [SVProgressHUD dismiss];
                    
                });
            }
            
            
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }]; 
    }
    
}




- (void)refreshHeader{
    _header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    // 设置文字
    [_header setTitle:@"下拉刷新" forState:MJRefreshStateIdle];
    [_header setTitle:@"刷新数据" forState:MJRefreshStatePulling];
    [_header setTitle:@"加载中..." forState:MJRefreshStateRefreshing];
    
    // 设置字体
    _header.stateLabel.font = [UIFont systemFontOfSize:15];
    _header.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:14];
    
    // 设置颜色
    _header.stateLabel.textColor = [UIColor grayColor];
    _header.lastUpdatedTimeLabel.textColor = [UIColor grayColor];
    
    // 马上进入刷新状态
     [_header beginRefreshing];
    
    // 设置刷新控件
    self.tableView.mj_header = _header;
}


- (void)loadNewData{
    if (self.dataArray.count > 0) {
        [_dataArray removeAllObjects];
    }
    _index = 0;
    [SVProgressHUD showWithStatus:@"Loading..."];
    [self loadPlay];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HandpickRankListCell *cell = [tableView dequeueReusableCellWithIdentifier:HandpickRankListCellCellWithIdentifier];
    cell.delegate = self;
    if (_dataArray.count>indexPath.row) {
        NSDictionary *dict = [_dataArray objectAtIndex:indexPath.row];
        [cell setPlayModel:dict indexPath:indexPath];
    }
    
    return cell;
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
- (void)toMoreRankList{
    RankListViewController *rankListVC = [[RankListViewController alloc]init];
    rankListVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:rankListVC animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
    [MobClick endLogPageView:@"HandpickRankListViewController"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end
