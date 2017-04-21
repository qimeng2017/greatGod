//
//  TriolionFootCell.h
//  LotteryNews
//
//  Created by 邹壮壮 on 2017/3/21.
//  Copyright © 2017年 邹壮壮. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RankListModel.h"
@protocol TriolionFootCellDelagate <NSObject>

- (void)selectedImageView:(RankListModel *)model;

@end
@interface TriolionFootCell : UITableViewCell
@property (nonatomic, weak)id<TriolionFootCellDelagate>delegate;
- (void)reloadScrollerView:(NSArray *)personalArray;
@end
