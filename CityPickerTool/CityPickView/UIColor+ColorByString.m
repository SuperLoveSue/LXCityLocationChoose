//
//  UIColor+ColorByString.m
//  TodayHotComment
//
//  Created by 今言网络 on 2017/1/17.
//  Copyright © 2017年 JinYan. All rights reserved.
//

#import "UIColor+ColorByString.h"

@implementation UIColor (ColorByString)


+(UIColor *) stringTOColor:(NSString *)str
{
    
    if (!str || [str isEqualToString:@""]) {
        
        return nil;
        
    }
    
    unsigned red,green,blue;
    
    NSRange range;
    
    range.length = 2;
    
    range.location = 1;
    
    [[NSScanner scannerWithString:[str substringWithRange:range]] scanHexInt:&red];
    
    range.location = 3;
    
    [[NSScanner scannerWithString:[str substringWithRange:range]] scanHexInt:&green];
    
    range.location = 5;
    
    [[NSScanner scannerWithString:[str substringWithRange:range]] scanHexInt:&blue];
    
    UIColor *color= [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:1];
    
    return color;
    
}


@end
