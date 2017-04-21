//
//  HandpickRankListCell.h
//  LotteryNews
//
//  Created by 邹壮壮 on 2017/3/23.
//  Copyright © 2017年 邹壮壮. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RankListModel.h"
@protocol HandpickRankListCellDelegate <NSObject>

- (void)selectedImageView:(RankListModel *)model;
- (void)toMoreRankList;

@end
@interface HandpickRankListCell : UITableViewCell
@property (nonatomic, weak)id<HandpickRankListCellDelegate>delegate;
- (void)setPlayModel:(NSDictionary *)dict indexPath:(NSIndexPath *)indexPath;
@end
