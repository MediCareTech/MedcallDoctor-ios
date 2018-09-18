//
//  ReportsCell.m
//  smartRxDoctor
//
//  Created by Gowtham on 19/01/18.
//  Copyright © 2018 Anil Kumar. All rights reserved.
//

#import "ReportsCell.h"

@implementation ReportsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(IBAction)clickOnViewBtn:(id)sender{
    if ([self.delegate respondsToSelector:@selector(viewBtnClicked:)]) {
        [self.delegate viewBtnClicked:self.cellId];
    }
}
-(IBAction)clickOnDownloadBtn:(id)sender{
    if ([self.delegate respondsToSelector:@selector(downloadBtnClicked:)]) {
        [self.delegate downloadBtnClicked:self.cellId];
    }
}
@end
