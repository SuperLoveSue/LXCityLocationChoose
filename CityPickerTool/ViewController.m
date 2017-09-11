//
//  ViewController.m
//  CityPickerTool
//
//  Created by 行商驿站 on 2017/9/11.
//  Copyright © 2017年 LianShangChe. All rights reserved.
//

#import "ViewController.h"
#import "LocationManager.h"
#import "cityPickView.h"

@interface ViewController ()

@property(nonatomic,strong)UIButton *choseButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    self.choseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.choseButton.frame = CGRectMake(50, 150, 300, 30);
    [self.choseButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.choseButton setTitle:@"选择城市" forState:UIControlStateNormal];
    [self.choseButton addTarget:self action:@selector(choseCityButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.choseButton];
    
    
}

-(void)choseCityButtonClicked:(UIButton *)btn
{
    [cityPickView showPickViewWithComplete:^(NSArray *arr) {
        
        NSLog(@"%@",arr);
        
        
        if (arr.count == 6)
        {
            [self.choseButton setTitle:[NSString stringWithFormat:@"%@ %@ %@",arr[0],arr[1],arr[2]] forState:UIControlStateNormal];

        }
        else
        {
            [self.choseButton setTitle:[NSString stringWithFormat:@"%@ %@",arr[0],arr[1]] forState:UIControlStateNormal];

        }
        
        
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
