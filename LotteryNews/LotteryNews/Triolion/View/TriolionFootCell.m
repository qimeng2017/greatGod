//
//  TriolionFootCell.m
//  LotteryNews
//
//  Created by 邹壮壮 on 2017/3/21.
//  Copyright © 2017年 邹壮壮. All rights reserved.
//

#import "TriolionFootCell.h"

@interface TriolionFootCell ()<UIScrollViewDelegate>
{
    CGRect viewSize;
    UIScrollView *scrollView;
    NSArray *array;
}
@end
@implementation TriolionFootCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        scrollView=[[UIScrollView alloc]init];
        scrollView.pagingEnabled = YES;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.scrollsToTop = NO;
        scrollView.delegate = self;
        [scrollView setContentOffset:CGPointMake(0, 0)];
        [self addSubview:scrollView];
    }
    return self;
}
- (void)reloadScrollerView:(NSArray *)personalArray{
    array = personalArray;
    [self layoutIfNeeded];
    
}
- (void)layoutSubviews{
    for (UIView *view in scrollView.subviews) {
        [view removeFromSuperview];
    }
    viewSize = self.frame;
    scrollView.frame = CGRectMake(0, 0, viewSize.size.width, viewSize.size.height);
    CGFloat start_x = 20;
    CGFloat start_y = 10;
    CGFloat space = 20;
    CGFloat nameLable_h = 20;
    CGFloat button_w = scrollView.frame.size.height -start_y*3-nameLable_h;
    
    NSInteger arrCount = array.count;
    scrollView.contentSize = CGSizeMake(start_x*2+arrCount*button_w+(arrCount -1)*space, 0);
    
    for (NSInteger i = 0; i< arrCount; i++) {
        RankListModel *model = [array objectAtIndex:i];
        UIImageView *imageView = [UIImageView new];
        imageView.userInteractionEnabled = YES;
        imageView.backgroundColor = [UIColor redColor];
        [imageView sd_setImageWithURL:[NSURL URLWithString:model.images_url] placeholderImage:nil options:SDWebImageRefreshCached];
        imageView.frame = CGRectMake(start_x+(space+button_w)*i, start_y, button_w, button_w);
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = button_w/2;
        [scrollView addSubview:imageView];
        UIButton *btn = [UIButton new];
        btn.tag = i;
        btn.frame = CGRectMake(0, 0, button_w, button_w);
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = button_w/2;
        [btn addTarget:self action:@selector(selectedPersonal:) forControlEvents:UIControlEventTouchUpInside];
        [imageView addSubview:btn];
        UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(start_x+(space+button_w)*i, CGRectGetMaxY(imageView.frame)+start_y, button_w, nameLable_h)];
        lable.textAlignment = NSTextAlignmentCenter;
        lable.textColor = [UIColor grayColor];
        lable.font = [UIFont systemFontOfSize:14];
        lable.text = model.nickname;
        [scrollView addSubview:lable];
    }
}
- (void)selectedPersonal:(UIButton *)sender{
    RankListModel *model = [array objectAtIndex:sender.tag];
    if (_delegate&&[_delegate respondsToSelector:@selector(selectedImageView:)]) {
        [_delegate selectedImageView:model];
    }
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
