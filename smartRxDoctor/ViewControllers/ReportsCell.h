//
//  ReportsCell.h
//  smartRxDoctor
//
//  Created by Gowtham on 19/01/18.
//  Copyright © 2018 Anil Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CellDelegate <NSObject>

-(void)viewBtnClicked:(NSIndexPath *)indexPath;
-(void)downloadBtnClicked:(NSIndexPath *)indexPath;


@end

@interface ReportsCell : UITableViewCell

@property(nonatomic,weak) IBOutlet UILabel *descriptionLbl;
@property(nonatomic,weak) IBOutlet UILabel *dateLbl;
@property(nonatomic,weak) IBOutlet UIImageView *thumbnailImageVw;
@property(nonatomic,strong) NSIndexPath *cellId;

@property(nonatomic,weak) id <CellDelegate> delegate;

-(IBAction)clickOnViewBtn:(id)sender;
-(IBAction)clickOnDownloadBtn:(id)sender;

@end
