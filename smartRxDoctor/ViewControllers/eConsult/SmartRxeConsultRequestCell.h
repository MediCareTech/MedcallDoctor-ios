//
//  SmartRxeConsultRequestCell.h
//  SmartRx
//
//  Created by Anil Kumar on 25/02/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxeConsultRequestCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *requestData;
@property (weak, nonatomic) IBOutlet UILabel *requestPostedBy;

- (void)setCellData:(NSArray *)arrayRequestData row:(NSInteger)rowIndex;
@end
