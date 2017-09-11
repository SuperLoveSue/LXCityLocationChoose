# LXCityLocationChoose

省市县查询

不断完善中


[cityPickView showPickViewWithComplete:^(NSArray *arr) {

    NSLog(@"%@",arr);


    if (arr.count == 6)
    {
        [self.choseButton setTitle:[NSString stringWithFormat:@"%@ %@ %@",arr[0],arr[1],arr[2]] forState:UIControlStateNormal];

    }
    else
    {
        [self.choseButton setTitle:[NSString stringWithFormat:@"%@ %@",arr[0],arr[1]] forState:UIControlStateNormal];

    }}];
    
# LXCityLocationChoose
