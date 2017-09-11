//
//  LocationManager.m
//  familyUser
//
//  Created by DK on 15/12/27.
//  Copyright © 2015年 JBTM. All rights reserved.
//

#import "LocationManager.h"
#import "FMDatabase.h"

@interface LocationManager ()

@end

static FMDatabase *_db;
static NSMutableArray *_provinceArr;    //存放省份名称
static NSMutableArray *_cityArr;        //存放城市名称
static NSMutableArray *_province_idArr; //存放省份id
static NSMutableArray *_city_idArr;     //存放城市id
static NSMutableArray *_regionArr;        //存放第二级城市名称
static NSMutableArray *_region_idArr;     //存放第二级城市id

@implementation LocationManager

+ (void)initialize {
    [self getLocationDateBase];
}

+ (FMDatabase *)getLocationDateBase {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dbPath = [path stringByAppendingPathComponent:@"city.db"];
    NSError *error;
    
    //如果不存在就拷贝
    if (![fileManager fileExistsAtPath:dbPath]) {
        NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"city" ofType:@"db"];
        [fileManager copyItemAtPath:resourcePath toPath:dbPath error:&error];
        if (error) {
            NSLog(@"%@", error);
        }
    } else {
        //如果存在就移除原来的，拷贝新的进去（防止本地数据库更新而读取不到）
        if ([fileManager removeItemAtPath:dbPath error:&error]) {
            if (error) {
                NSLog(@"%@", error);
            }
            
            NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"city" ofType:@"db"];
            [fileManager copyItemAtPath:resourcePath toPath:dbPath error:&error];
            if (error) {
                NSLog(@"%@", error);
            }
        }
    }
    
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    _db = db;
    
    _provinceArr = [NSMutableArray array];
    _cityArr = [NSMutableArray array];
    _province_idArr = [NSMutableArray array];
    _city_idArr = [NSMutableArray array];
    _regionArr = [NSMutableArray array];
    _region_idArr = [NSMutableArray array];
    
    
    [self getProvinces];
    [self getSubAreas];
    
    return _db;
}

+ (NSArray *)getProvinces {
    [_db open];
    FMResultSet *result = [_db executeQuery:@"SELECT * FROM AREA_MMM WHERE pid = 0"];
    
    //移除原来的老数据
    [_provinceArr removeAllObjects];
    [_province_idArr removeAllObjects];
    
    while ([result next]) {
        int region_id = [result intForColumn:@"id"];
        NSString *name = [result stringForColumn:@"name"];
        [_provinceArr addObject:name];
        [_province_idArr addObject:[NSNumber numberWithInt:region_id]];
    }
    
    [_db close];
    
    return _provinceArr;
}

+ (NSArray *)getSubAreas {
    [_db open];
    
    FMResultSet *result = [_db executeQueryWithFormat:@"SELECT * FROM AREA_MMM WHERE pid = 52"];
    [_cityArr removeAllObjects];
    [_city_idArr removeAllObjects];
    while ([result next]) {
        int region_id = [result intForColumn:@"id"];
        NSString *name = [result stringForColumn:@"name"];
        [_cityArr addObject:name];
        [_city_idArr addObject:[NSNumber numberWithInt:region_id]];
    }
    [_db close];
    
    return _cityArr;
}

+ (NSArray *)getSubAreasByString:(NSString *)provience {
    [_db open];
    
    
    //根据省份名称，获取省份的id
    NSInteger index = [_provinceArr indexOfObject:provience];
    NSInteger province_id = [[_province_idArr objectAtIndex:index] integerValue];
    
    [_cityArr removeAllObjects];
    [_city_idArr removeAllObjects];
    
    //根据省份id查找子地区
    FMResultSet *result = [_db executeQueryWithFormat:@"SELECT * FROM AREA_MMM WHERE pid = %ld", (long)province_id];
    while ([result next]) {
        int region_id = [result intForColumn:@"nid"];
        NSString *name = [result stringForColumn:@"name"];
        [_cityArr addObject:name];
        [_city_idArr addObject:[NSNumber numberWithInt:region_id]];
    }
    
    //过滤直辖市(如果子地区数量只有一个则为直辖市)
    if (_cityArr.count == 1) {
    
        
        //获取直辖市的id
        NSInteger region_id = [_city_idArr.lastObject integerValue];
        
        if ([provience isEqualToString:@"台湾省"] || [provience isEqualToString:@"香港特别行政区"]  || [provience isEqualToString:@"澳门特别行政区"] )
        {
            //根据直辖市的id获取子地区
            result = [_db executeQueryWithFormat:@"SELECT * FROM AREA_MMM WHERE nid = %ld", region_id];
            
            [_cityArr removeAllObjects];
            [_city_idArr removeAllObjects];
            
            while ([result next]) {
                int region_id = [result intForColumn:@"nid"];
                NSString *name = [result stringForColumn:@"name"];
                [_cityArr addObject:name];
                [_city_idArr addObject:[NSNumber numberWithInt:region_id]];
            }
        }
        else
        {
            //根据直辖市的id获取子地区
            result = [_db executeQueryWithFormat:@"SELECT * FROM AREA_MMM WHERE pid = %ld", region_id];
            
            [_cityArr removeAllObjects];
            [_city_idArr removeAllObjects];
            
            while ([result next]) {
                int region_id = [result intForColumn:@"nid"];
                NSString *name = [result stringForColumn:@"name"];
                [_cityArr addObject:name];
                [_city_idArr addObject:[NSNumber numberWithInt:region_id]];
            }
        }

        
        

    }
    
    [_db close];
    
    return _cityArr;
}

+ (NSArray *)getSubAreasById:(NSInteger)provience_id {
    NSString *provience = [self getAreaNameByRegionID:provience_id];
    [self getSubAreasByString:provience];
    
    return [self getSubAreasByString:provience];
}

+ (NSInteger)getRegionIDByString:(NSString *)area type:(eAreaType)type {
    if (type == eAreaType_Province) {
        NSInteger index = 0;
        if ([_provinceArr containsObject:area]) {
            index = [_provinceArr indexOfObject:area];
        }
        
        NSInteger region_id = [[_province_idArr objectAtIndex:index] integerValue];
        return region_id;
    } else if (type == eAreaType_City) {
        NSInteger index = 0;
        if ([_cityArr containsObject:area]) {
            index = [_cityArr indexOfObject:area];
        }
        
        NSInteger region_id = [[_city_idArr objectAtIndex:index] integerValue];
        return region_id;
    }else if (type == eAreaType_Region) {
        NSInteger index = 0;
        if ([_regionArr containsObject:area]) {
            index = [_regionArr indexOfObject:area];
        }
        
        NSInteger region_id = [[_region_idArr objectAtIndex:index] integerValue];
        return region_id;
    }
    

    return -1;
}

+ (NSString *)getAreaNameByRegionID:(NSInteger)region_id {
    [_db open];
    
    FMResultSet *result = [_db executeQueryWithFormat:@"SELECT * FROM AREA_MMM WHERE id = %ld", (long)region_id];
    
    NSString *name;
    
    while ([result next]) {
        name = [result stringForColumn:@"name"];
    }
    
    [_db close];
    
    return name;
}

+ (NSArray *)getSubCitysByString:(NSString *)cityName{
    [_db open];
    

    
    
    if (![cityName isEqualToString:@""])
    {
        //根据城市名称，获取城市的nid
        NSInteger index = [_cityArr indexOfObject:cityName];
        NSInteger city_id = [[_city_idArr objectAtIndex:index] integerValue];
        
        [_regionArr removeAllObjects];
        [_region_idArr removeAllObjects];
        
        
        if (![cityName isEqualToString:@""])
        {
            //根据省份id查找子地区
            FMResultSet *result = [_db executeQueryWithFormat:@"SELECT * FROM AREA_MMM WHERE pid = %ld", (long)city_id];
            while ([result next]) {
                int region_id = [result intForColumn:@"nid"];
                NSString *name = [result stringForColumn:@"name"];
                [_regionArr addObject:name];
                [_region_idArr addObject:[NSNumber numberWithInt:region_id]];
            }
            
            //过滤直辖市(如果子地区数量只有一个则为直辖市)
            if (_cityArr.count == 0) {
                
                
                //        //获取直辖市的id
                //        NSInteger region_id = [_city_idArr.lastObject integerValue];
                //
                //        if ([provience isEqualToString:@"台湾省"] || [provience isEqualToString:@"香港特别行政区"]  || [provience isEqualToString:@"澳门特别行政区"] )
                //        {
                //            //根据直辖市的id获取子地区
                //            result = [_db executeQueryWithFormat:@"SELECT * FROM AREA_MMM WHERE nid = %ld", region_id];
                //
                //            [_cityArr removeAllObjects];
                //            [_city_idArr removeAllObjects];
                //
                //            while ([result next]) {
                //                int region_id = [result intForColumn:@"nid"];
                //                NSString *name = [result stringForColumn:@"name"];
                //                [_cityArr addObject:name];
                //                [_city_idArr addObject:[NSNumber numberWithInt:region_id]];
                //            }
                //        }
                //        else
                //        {
                //            //根据直辖市的id获取子地区
                //            result = [_db executeQueryWithFormat:@"SELECT * FROM AREA_MMM WHERE pid = %ld", region_id];
                //
                //            [_cityArr removeAllObjects];
                //            [_city_idArr removeAllObjects];
                //
                //            while ([result next]) {
                //                int region_id = [result intForColumn:@"nid"];
                //                NSString *name = [result stringForColumn:@"name"];
                //                [_cityArr addObject:name];
                //                [_city_idArr addObject:[NSNumber numberWithInt:region_id]];
                //            }
                //        }
                
                
                
                
            }

        }
    }

    
    [_db close];

    return _regionArr;
}



@end
