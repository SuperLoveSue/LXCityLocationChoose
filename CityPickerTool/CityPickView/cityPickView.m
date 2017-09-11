//
//  cityPickView.m
//  demo2
//
//  Created by 行商驿站 on 2017/9/5.
//  Copyright © 2017年 liuxin. All rights reserved.
//

#import "cityPickView.h"
#import "LocationManager.h"
#import "UIColor+ColorByString.h"

#define kHeaderHeight 40
#define kPickViewHeight 220
#define kSureBtnColor [UIColor colorWithRed:147/255.f green:196/255.f blue:246/255.f alpha:1.0]
#define kCancleBtnColor [UIColor blackColor]
#define kHeaderViewColor [UIColor whiteColor]

//屏幕尺寸
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@interface cityPickView ()<UIPickerViewDataSource,UIPickerViewDelegate>

@property(nonatomic,strong)NSArray *provinceArr;
@property(nonatomic,strong)NSArray *cityArr;
@property(nonatomic,strong)NSArray *regionArr;
@end

@implementation cityPickView


+ (cityPickView *)showPickViewWithComplete:(LXCityBlock)block
{
    return [self showPickViewWithDefaultProvince:nil complete:block];
}


+ (cityPickView *)showPickViewWithDefaultProvince:(NSString *)province complete:(LXCityBlock)block{

    
    cityPickView *pickView= [[cityPickView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:pickView];
    pickView.completeBlcok = block;
    
    
    //[pickView scrollToRow:0 secondRow:0 thirdRow:0];
    return pickView;
}


-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {

        self.provinceRowIndex = 0;
        self.cityRowIndex = 0;
        
        self.provinceArr = [[NSArray alloc]init];
        self.cityArr = [[NSArray alloc]init];
        self.regionArr = [[NSArray alloc]init];
        [self loadData];
        
        [self initWithUI];

        
    }
    return self;
}

-(void)initWithUI
{
    
    CGFloat width = self.frame.size.width;
    
    [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]];
    
    UIView *viewBg = [[UIView alloc] initWithFrame:CGRectMake(0,self.frame.size.height-(kPickViewHeight+kHeaderHeight),width,kPickViewHeight+kHeaderHeight)];
    [viewBg setBackgroundColor:[UIColor whiteColor]];
    viewBg.layer.cornerRadius = 5;
    viewBg.layer.masksToBounds = YES;
    [self addSubview:viewBg];
    
    UIView *viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0,0, width,kHeaderHeight)];
    [viewHeader setBackgroundColor:kHeaderViewColor];
    [viewBg addSubview:viewHeader];
    
    UIButton *cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(0,4, 50, 32)];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:kCancleBtnColor forState:UIControlStateNormal];
    cancelButton.titleLabel.font= [UIFont systemFontOfSize:15];
    [cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:cancelButton];
    
    
    UIButton *sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sureButton setFrame:CGRectMake(viewHeader.frame.size.width-50,4, 50, 32)];
    [sureButton setTitle:@"完成" forState:UIControlStateNormal];
    sureButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [sureButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [sureButton addTarget:self action:@selector(sureACtion:) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:sureButton];
    
    
    self.pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0,kHeaderHeight,width,kPickViewHeight)];
    [self.pickerView setBackgroundColor:[UIColor whiteColor]];
    [viewBg addSubview:self.pickerView];
    
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    
}

//初始化为北京
-(void)loadData
{
    self.provinceArr = [[LocationManager getProvinces] copy];
    self.cityArr = [LocationManager getSubAreasByString:@"北京市"];
    self.regionArr = [[LocationManager getSubCitysByString:@""] copy];
    
}

- (void)cancelAction:(UIButton *)btn{
    [self removeFromSuperview];
}
- (void)sureACtion:(UIButton *)btn
{
    NSArray *arr = [self getChooseCityArr];
    if (self.completeBlcok != nil) {
        self.completeBlcok(arr);
    }
    [self removeFromSuperview];
}

#pragma mark - Tool
-(NSArray *)getChooseCityArr{
    NSArray *arr;
    
    if (self.provinceArr != 0 && self.cityArr != 0 )
    {
        
        if (self.regionArr.count != 0)
        {
            NSString *province = self.provinceArr[self.provinceRowIndex];
            NSString *city = self.cityArr[self.cityRowIndex];
            NSString *region = self.regionArr[self.regionRowIndex];
            
            NSInteger provinceID = [LocationManager getRegionIDByString:province type:eAreaType_Province];
            NSInteger cityID = [LocationManager getRegionIDByString:city type:eAreaType_City];
            NSInteger regionID = [LocationManager getRegionIDByString:region type:eAreaType_Region];
            
            arr = @[province,city,region,[NSString stringWithFormat:@"%ld",provinceID],[NSString stringWithFormat:@"%ld",cityID],[NSString stringWithFormat:@"%ld",regionID]];
        }
        else
        {
            NSString *province = self.provinceArr[self.provinceRowIndex];
            NSString *city = self.cityArr[self.cityRowIndex];
            
            NSInteger provinceID = [LocationManager getRegionIDByString:province type:eAreaType_Province];
            NSInteger cityID = [LocationManager getRegionIDByString:city type:eAreaType_City];
            arr = @[province,city,[NSString stringWithFormat:@"%ld",provinceID],[NSString stringWithFormat:@"%ld",cityID]];
        }

        
//        NSLog(@"返回的当前省会名字：%@",province);
//        NSLog(@"返回的当前城市名字：%@",city);
//        NSLog(@"返回的数组内容：%@",arr);
//        
        
    }
    
    
    return arr;
}



#pragma mark - PickerView的数据源方法
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{

    if (component == 0) {
        //返回省个数
        return self.provinceArr.count;
    }
    
    if (component == 1) {
        //返回市个数

        return self.cityArr.count;
    }
    
    if (component == 2) {
        //返回市个数
        return self.regionArr.count;
    }
    
    return 0;
    
}
#pragma mark - PickerView的代理方法
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSString *showTitleValue=@"";
    if (component==0)
    {//省
        NSString *province = self.provinceArr[row];
        showTitleValue = province;
    }
    if (component==1)
    {//市
        //NSString *province = self.cityArr[row];
        NSString *city = self.cityArr[row];
        showTitleValue = city;
    }
    if (component==2)
    {//县
        if (self.regionArr.count != 0)
        {
            NSString *region = self.regionArr[row];
            showTitleValue = region;
        }
    }
    return showTitleValue;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view {
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, ([UIScreen mainScreen].bounds.size.width - 30) / 3,40)];
    label.textAlignment=NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:16];
    label.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    return label;
}


//选中时回调的委托方法，在此方法中实现省份和城市间的联动
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    switch (component) {
        case 0://选中省份表盘时，根据row的值改变城市数组，刷新城市数组
            self.cityArr = [LocationManager getSubAreasByString:self.provinceArr[row]];
            self.provinceRowIndex = row;
            
            self.regionArr = [LocationManager getSubCitysByString:self.cityArr[0]];
            self.cityRowIndex = 0;
            
            [self.pickerView reloadComponent:1];
            [self.pickerView reloadComponent:2];
            break;
        case 1:
            self.regionArr = [LocationManager getSubCitysByString:self.cityArr[row]];
            self.cityRowIndex = row;
            [self.pickerView reloadComponent:2];
            break;
        case 2:
            //NSLog(@"当前选择目的地为：%@%@",self.provinces[[self.pickerView selectedRowInComponent:0]][@"State"],self.cities[[self.pickerView selectedRowInComponent:1]][@"city"]);
            //NSLog(@"%@",self.cityArr[row]);
            self.regionRowIndex = row;
            break;
            
        default:
            break;
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
