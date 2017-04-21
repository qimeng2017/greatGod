//
//  HandpickRankListCell.m
//  LotteryNews
//
//  Created by 邹壮壮 on 2017/3/23.
//  Copyright © 2017年 邹壮壮. All rights reserved.
//

#import "HandpickRankListCell.h"


#define start_x  20
#define space_w  20
#define start_y  20
#define w (kScreenWidth - start_x*2 - space_w*3)/4
@interface HandpickRankListCell ()
@property (weak, nonatomic) IBOutlet UIView *topView;

@property (weak, nonatomic) IBOutlet UILabel *handPickTypeLable;
@property (weak, nonatomic) IBOutlet UIImageView *hankPickImageView;
@property (weak, nonatomic) IBOutlet UIButton *toMoreRankListBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *hankListScrollView;
@property (nonatomic, strong) NSArray *peopleArray;

@end
@implementation HandpickRankListCell


- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    for (NSInteger i = 0; i< 10; i++) {
        UIImageView *peopleImageView = [[UIImageView alloc]initWithFrame:CGRectMake(start_x+(w+space_w)*i, start_y, w, w)];
        peopleImageView.layer.masksToBounds = YES;
        peopleImageView.layer.cornerRadius = w/2;
        peopleImageView.tag = 10+i;
        peopleImageView.userInteractionEnabled = YES;
        [_hankListScrollView addSubview:peopleImageView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        [peopleImageView addGestureRecognizer:tap];
        UILabel *nickNameLable = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(peopleImageView.frame), CGRectGetMaxY(peopleImageView.frame)+10, w, 20)];
        nickNameLable.textAlignment = NSTextAlignmentCenter;
        nickNameLable.font = [UIFont systemFontOfSize:12];
        nickNameLable.textColor = [UIColor grayColor];
        nickNameLable.tag = 20+i;
        [_hankListScrollView addSubview:nickNameLable];
        UILabel *oddsLable = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(peopleImageView.frame), CGRectGetMaxY(nickNameLable.frame)+5, w, 20)];
        oddsLable.textAlignment = NSTextAlignmentCenter;
        oddsLable.font = [UIFont systemFontOfSize:12];
        oddsLable.textColor = RGBA(0, 165, 227, 1);
        oddsLable.tag = 30+i;
        [_hankListScrollView addSubview:oddsLable];
        
    }
   
}
- (IBAction)toMoreRankListAction:(id)sender {
    if (_delegate &&[_delegate respondsToSelector:@selector(toMoreRankList)]) {
        [_delegate toMoreRankList];
    }
}



- (void)setPlayModel:(NSDictionary *)dict indexPath:(NSIndexPath *)indexPath{
    NSString *index = [NSString stringWithFormat:@"shuzi%ld",(long)indexPath.row+1];
    _hankPickImageView.image = [UIImage imageNamed:index];
    NSString *handPickType = [NSString stringWithFormat:@"%@命中榜",[dict objectForKey:@"name"]];
    self.handPickTypeLable.text = handPickType;
    NSArray *arr = [dict objectForKey:@"array"];
    _peopleArray = arr;
    NSInteger arrCount = arr.count;
    //最多出现10条
    if (arrCount >=10) {
        arrCount = 10;
        _hankListScrollView.contentSize = CGSizeMake(start_x*2+w*10+9*space_w, 0);
            }else{
        arrCount = arr.count;
        _hankListScrollView.contentSize = CGSizeMake(start_x*2+w*arrCount+(arrCount-1)*space_w, 0);
    }
    for (NSInteger i = 0; i<arrCount; i++) {
        RankListModel *model = [arr objectAtIndex:i];
        UIImageView *peopleImageView = (UIImageView *)[_hankListScrollView viewWithTag:i+10];
        [peopleImageView sd_setImageWithURL:[NSURL URLWithString:model.images_url] placeholderImage:[UIImage imageNamed:@"Icon-Small"] options:SDWebImageRefreshCached];
        UILabel *nickNameLable = (UILabel *)[_hankListScrollView viewWithTag:i+20];
        nickNameLable.text = model.nickname;
        UILabel *oddsLable = (UILabel *)[_hankListScrollView viewWithTag:i+30];
        //两个空格
        NSArray *foreArray = [model.fore_data componentsSeparatedByString:@"  "];
        oddsLable.text = [foreArray objectAtIndex:1];
    }

}
- (void)tapAction:(UITapGestureRecognizer *)tap{
    UIView *view = tap.view;
    RankListModel *model = [_peopleArray objectAtIndex:view.tag-10];
    if (_delegate&&[_delegate respondsToSelector:@selector(selectedImageView:)]) {
        [_delegate selectedImageView:model];
    }
    
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
