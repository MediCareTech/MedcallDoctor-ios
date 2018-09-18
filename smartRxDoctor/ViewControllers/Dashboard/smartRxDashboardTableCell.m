//
//  smartRxDashboardTableCell.m
//  smartRxDoctor
//
//  Created by Manju Basha on 05/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import "smartRxDashboardTableCell.h"

@implementation smartRxDashboardTableCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


-(void)setCellData:(NSString *)string imgName:(NSString *)imageName;
{
    self.menuName.text = string;
    self.menuImage.image = [UIImage imageNamed:imageName];
}

@end
