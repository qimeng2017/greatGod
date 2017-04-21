//
//  BasicViewController.m
//  LotteryNews
//
//  Created by 邹壮壮 on 2016/12/20.
//  Copyright © 2016年 邹壮壮. All rights reserved.
//

#import "BasicViewController.h"

#import "LNLotteryCategories.h"
#import "LNLottoryConfig.h"
#import "LottoryCategoryModel.h"
#import "UserStore.h"
#import "LottoryPlaytypemodel.h"
#import "CKAlertViewController.h"

@interface BasicViewController ()<TopMenuViewDelegate>
{
    UIButton               *_navButton;
    UILabel                *_titleLable;
    
}

@end

@implementation BasicViewController

+ (BasicViewController *)sharedInstance
{
    static BasicViewController *_sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[BasicViewController alloc] init];
    });
    
    return _sharedInstance;
}
- (id)init{
    self = [super init];
    if (self) {
      //[self requestCategories];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
   
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    CGFloat title_h = 44;
    CGFloat button_w = 120;
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), title_h)];
   
        UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(titleView.frame), CGRectGetHeight(titleView.frame))];
        lable.textAlignment = NSTextAlignmentCenter;
        lable.textColor = [UIColor whiteColor];
        lable.font = [UIFont systemFontOfSize:16];
        [titleView addSubview:lable];
    _titleLable = lable;
    _titleLable.hidden = YES;
    
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        //    [button setTitle:@"大乐透" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.frame = CGRectMake((CGRectGetWidth(titleView.frame)-button_w)/2, 0, 120, title_h);
        [button setImage:[UIImage imageNamed:@"grrow_down"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onPopverClick:) forControlEvents:UIControlEventTouchUpInside];
        [titleView addSubview:button];
        _navButton = button;
  
    
    
    
    
    self.navigationItem.titleView = titleView;
    _navigationTitleView = titleView;
    
}
- (void)setKNavigationOpenTitle:(BOOL)kNavigationOpenTitle{
    if (kNavigationOpenTitle) {
        _titleLable.hidden = NO;
        _navButton.hidden = YES;
    }else{
        _titleLable.hidden = YES;
        _navButton.hidden = NO;
    }
}
- (void)setNavigationItemTitle:(NSString *)navigationItemTitle{
    _titleLable.text = navigationItemTitle;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
  LottoryCategoryModel *caModel=  [LNLotteryCategories sharedInstance].currentLottoryModel;
    if (caModel) {
        [_navButton setTitle:caModel.caipiao_name forState:UIControlStateNormal];
        [self requestPlayType:caModel];
    }
    if ([LNLotteryCategories sharedInstance].categoryArray.count > 0) {
       [self.view addSubview:self.ninaSelectionView];
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:LOTTORY_REVIEW_STATUS]) {
        [self checkUpdate];
    }
}
- (void)kLotteryDateSuccessedFirstNotifications:(NSNotification *)notification{
    id value = notification.object;
    if ([value isKindOfClass:[NSArray class]]) {
         NSArray *arr = (NSArray *)value;
        //当前类别
        LottoryCategoryModel *model = [arr objectAtIndex:1];
        [LNLotteryCategories sharedInstance].currentLottoryModel = model;
        [LNLotteryCategories sharedInstance].categoryArray = arr;
        [_navButton setTitle:model.caipiao_name forState:UIControlStateNormal];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view addSubview:self.ninaSelectionView];
        });
        [self requestPlayType:model];
    }
}

#pragma mark - LazyLoad

- (TopMenuView *)ninaSelectionView {
  
    if (!_topMenuView) {
        _topMenuView = [[TopMenuView alloc] initWithTitles:[LNLotteryCategories sharedInstance].categoryArray PopDirection:NinaPopFromAboveToTop];
        _topMenuView.ninaSelectionDelegate = self;
        _topMenuView.defaultSelected = [LNLotteryCategories sharedInstance].categorySelectedIndex? [LNLotteryCategories sharedInstance].categorySelectedIndex:2;
        _topMenuView.shadowEffect = YES;
        _topMenuView.shadowAlpha = 0.5;
    }
    return _topMenuView;
}
- (void)onPopverClick:(id)sender{
    _topMenuView.defaultSelected = [LNLotteryCategories sharedInstance].categorySelectedIndex? [LNLotteryCategories sharedInstance].categorySelectedIndex:2;
     [self.topMenuView showOrDismissNinaViewWithDuration:0.5 usingNinaSpringWithDamping:0.8 initialNinaSpringVelocity:0.3];
}
#pragma mark - SelectionDelegate
- (void)selectNinaAction:(UIButton *)button {
    //NSLog(@"Choose %li button",(long)button.tag);
   
    [LNLotteryCategories sharedInstance].currentLottoryModel = [[LNLotteryCategories sharedInstance].categoryArray objectAtIndex:button.tag-1];
    [[NSNotificationCenter defaultCenter] postNotificationName:kLotteryDataCategoryNotification object:[LNLotteryCategories sharedInstance].currentLottoryModel];
   NSString *changeStr = button.titleLabel.text;
    [_navButton setTitle:changeStr forState:UIControlStateNormal];
    [self requestPlayType:[LNLotteryCategories sharedInstance].currentLottoryModel];
    [LNLotteryCategories sharedInstance].categorySelectedIndex = button.tag;
    _topMenuView.defaultSelected = [LNLotteryCategories sharedInstance].categorySelectedIndex? [LNLotteryCategories sharedInstance].categorySelectedIndex:2;
    [self.ninaSelectionView showOrDismissNinaViewWithDuration:0.3];
    
}
- (void)requestPlayType:(LottoryCategoryModel *)model{
   
    [[UserStore sharedInstance] requestPlayType:model sucess:^(NSURLSessionDataTask *task, id responseObject) {
       
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
    
}

#pragma mark -检测版本
- (void)checkUpdate{
    NSString *userid = UserDefaultObjectForKey(LOTTORY_AUTHORIZATION_UID);
    if (!userid) {
        return;
    }
    [[UserStore sharedInstance]version_update:userid sucess:^(NSURLSessionDataTask *task, id responseObject) {
        NSNumber *code = [responseObject objectForKey:@"code"];
        NSInteger codeInteger = [code integerValue];
        NSNumber *mode = [responseObject objectForKey:@"mode"];
        NSInteger modeInteger = [mode integerValue];
        NSString *title = [responseObject objectForKey:@"title"];
        NSString *message = [responseObject objectForKey:@"message"];
        NSString * download_url = [responseObject objectForKey:@"download_url"];
        if (codeInteger==1) {
            if (modeInteger==0) {
                [self accordingUpdate:title content:message downloadURL:download_url type:YES];
                
            }else{
                [self accordingUpdate:title content:message downloadURL:download_url type:NO];
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

- (void)accordingUpdate:(NSString *)title content:(NSString *)message downloadURL:(NSString *)downloadUrl type:(BOOL)isAccord{
    
    CKAlertViewController *alertVC = [CKAlertViewController alertControllerWithTitle:title  message:message ];
    
    CKAlertAction *cancel = [CKAlertAction actionWithTitle:@"我知道了" handler:^(CKAlertAction *action) {
        NSLog(@"点击了 %@ 按钮",action.title);
    }];
    
    CKAlertAction *sure = [CKAlertAction actionWithTitle:@"立即更新" handler:^(CKAlertAction *action) {
        NSLog(@"点击了 %@ 按钮",action.title);
        [self didSelectedSureButtonClick:downloadUrl];
    }];
    
    //    CKAlertAction *skip = [CKAlertAction actionWithTitle:@"跳过此版本" handler:^(CKAlertAction *action) {
    //        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:appid];
    //    }];
    
    
    
    if (isAccord) {
        [alertVC addAction:sure];
    }else{
        
        [alertVC addAction:cancel];
        //[alertVC addAction:skip];
        [alertVC addAction:sure];
    }
    //    if ([[NSUserDefaults standardUserDefaults] boolForKey:appid]) {
    //        return;
    //    }
    [self presentViewController:alertVC animated:NO completion:nil];
}
- (void)didSelectedSureButtonClick:(NSString *)download_url{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:download_url]];
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
     [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
