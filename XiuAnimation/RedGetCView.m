//
//  RedGetCView.m
//  iOS_FanmoreIndiana
//
//  Created by 7_______。 on 16/3/9.
//  Copyright © 2016年 7_______。. All rights reserved.
//

#import "RedGetCView.h"

@implementation RedGetCView

- (void)awakeFromNib {
    // Initialization code
//    [UILabel changeLabel:_labelCount AndFont:30 AndColor:COLOR_SHINE_RED];
//    [UILabel changeLabel:_labelMoney AndFont:30 AndColor:COLOR_SHINE_RED];
    _labelCount.text = @"恭喜你获得了一个红包";
    _labelMoney.text = @"可免费获得一次1次0.5元购买";
    _imageVBack.image = [UIImage imageNamed:@"hbbb"];
    _imageVRed.image = [UIImage imageNamed:@"hb"];
    _viewBase.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.8];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
