//
//  LocationManager.h
//  familyUser
//
//  Created by DK on 15/12/27.
//  Copyright © 2015年 JBTM. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    eAreaType_Province = 1, //省
    eAreaType_City,          //城市
    eAreaType_Region         //县市
}eAreaType;

/*
 *********************************************************************************
 *
 * 名称：地址位置Manager
 * 描述：负责读取数据库中的地址位置编码
 *
 *********************************************************************************
 */

@interface LocationManager : NSObject

/**
 *  获取默认省份数组
 *
 *  @return
 */
+ (NSArray *)getProvinces;

/**
 *  获取默认子地区数组
 *
 *  @return
 */
+ (NSArray *)getSubAreas;

/**
 *  根据省份查找相应的子地区
 *
 *  @param provience 省份
 *
 *  @return
 */
+ (NSArray *)getSubAreasByString:(NSString *)provience;

/**
 *  根据省份Id查找相应的子地区
 *
 *  @param provience_id 省份Id
 *
 *  @return
 */
+ (NSArray *)getSubAreasById:(NSInteger)provience_id;

/**
 *  根据地区获取该地区的region_id
 *
 *  @param area
 *
 *  @return
 */
+ (NSInteger)getRegionIDByString:(NSString *)area type:(eAreaType)type;

/**
 *  根据地区region_id 获取地区的名字
 *
 *  @param region_id
 *
 *  @return
 */
+ (NSString *)getAreaNameByRegionID:(NSInteger)region_id;

/**
 *  根据城市查找相应的子地区
 *
 *  @param cityName 城市名
 *
 *  @return
 */
+ (NSArray *)getSubCitysByString:(NSString *)cityName;






@end
