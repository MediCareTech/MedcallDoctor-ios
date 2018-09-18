//
//  smartRxDashboardTableCell.h
//  smartRxDoctor
//
//  Created by Manju Basha on 05/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface smartRxDashboardTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *nameContainer;
@property (weak, nonatomic) IBOutlet UILabel *menuName;
@property (weak, nonatomic) IBOutlet UIImageView *menuImage;
-(void)setCellData:(NSString *)string imgName:(NSString *)imageName;
@end
