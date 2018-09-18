//
//  SmartRxeConsultRequestCell.m
//  SmartRx
//
//  Created by Anil Kumar on 25/02/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import "SmartRxeConsultRequestCell.h"

@implementation SmartRxeConsultRequestCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    // Your implementation
}
- (void)setCellData:(NSDictionary *)arrayRequestData row:(NSInteger)rowIndex
{
    CGSize viewSize = [[UIScreen mainScreen] bounds].size;
    self.requestData.frame = CGRectMake(self.requestData.frame.origin.x, self.requestData.frame.origin.y, viewSize.width-20, self.requestData.frame.size.height);
    self.requestData.text = [arrayRequestData objectForKey:@"replyMsg"];
    [self.requestData sizeToFit];
    
    UILabel *lblHeight = [[UILabel alloc]initWithFrame:CGRectMake(40,30, 300,21)];
    lblHeight.text = [arrayRequestData objectForKey:@"replyTime"];
    lblHeight.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
    CGSize maximumLabelSize = CGSizeMake(300,9999);
    CGSize expectedLabelSize;
    expectedLabelSize = [lblHeight.text  sizeWithFont:lblHeight.font constrainedToSize:maximumLabelSize lineBreakMode:lblHeight.lineBreakMode];
    
    self.requestPostedBy.frame = CGRectMake(self.requestPostedBy.frame.origin.x, self.requestData.frame.origin.y+self.requestData.frame.size.height+10, self.requestPostedBy.frame.size.width, expectedLabelSize.height);

    self.requestPostedBy.text = [arrayRequestData objectForKey:@"replyTime"];
}
@end
