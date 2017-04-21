//
//  TermsServiceViewController.m
//  LotteryNews
//
//  Created by 邹壮壮 on 2017/3/27.
//  Copyright © 2017年 邹壮壮. All rights reserved.
//

#import "TermsServiceViewController.h"

@interface TermsServiceViewController ()

@end

@implementation TermsServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIView *cancaleView = [[UIView alloc]init];
    UITapGestureRecognizer *cancleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [cancaleView addGestureRecognizer:cancleTap];
    [self.view addSubview:cancaleView];
    
    UIImageView *cancaleImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"关闭"]];
    [cancaleView addSubview:cancaleImageView];
    [cancaleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).with.offset(0);
        make.left.mas_equalTo(self.view.mas_left).with.offset(0);
        make.size.mas_equalTo(CGSizeMake(80, 80));
    }];
    [cancaleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cancaleView.mas_top).with.offset(20);
        make.left.mas_equalTo(cancaleView.mas_left).with.offset(30);
    }];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"TermsService" ofType:@"txt"];
    NSString *TermsService = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, self.view.frame.size.height-30)];
    textView.text = TermsService;
    textView.editable = NO;
    textView.font = [UIFont systemFontOfSize:16];
    
    [self.view addSubview:textView];
    [self.view bringSubviewToFront:cancaleView];
    // Do any additional setup after loading the view.
}
- (void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
