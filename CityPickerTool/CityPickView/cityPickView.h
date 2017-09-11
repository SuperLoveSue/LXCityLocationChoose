//
//  cityPickView.h
//  demo2
//
//  Created by 行商驿站 on 2017/9/5.
//  Copyright © 2017年 liuxin. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 选择完成回调
 
 @param arr @[省,市,省ID,市ID]
 */
typedef void(^LXCityBlock)(NSArray *arr);

@interface cityPickView : UIView

@property (strong, nonatomic)UIPickerView *pickerView;
@property (nonatomic,copy)LXCityBlock completeBlcok;

@property(nonatomic,assign)NSInteger provinceRowIndex;
@property(nonatomic,assign)NSInteger cityRowIndex;
@property(nonatomic,assign)NSInteger regionRowIndex;

///弹出城市选择器
+ (cityPickView *)showPickViewWithComplete:(LXCityBlock)block;

@end
