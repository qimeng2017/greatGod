//
//  LNScrollerView.h
//  LotteryNews
//
//  Created by 邹壮壮 on 2017/3/20.
//  Copyright © 2017年 邹壮壮. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LNScrollerViewDelegate <NSObject>
@optional
-(void)LNScrollerViewDidClicked:(NSUInteger)index;
@end
@interface LNScrollerView : UIView<UIScrollViewDelegate>
@property (nonatomic, strong)NSArray *imageArray;
@property (nonatomic,weak)id<LNScrollerViewDelegate>delegate;
@end
