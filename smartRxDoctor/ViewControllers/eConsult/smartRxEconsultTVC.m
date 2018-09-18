//
//  smartRxEconsultTVC.m
//  smartRxDoctor
//
//  Created by Manju Basha on 14/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import "smartRxEconsultTVC.h"
#import "NSString+DateConvertion.h"
@implementation smartRxEconsultTVC

- (void)awakeFromNib {
    // Initialization code
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
-(void)setCellData:(NSArray *)arrAppDetails row:(NSInteger)rowIndex
{
    if ([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"app_method"] integerValue] == 2)
    {
        self.econsultMethodLbl.text = @"Phone Call";
        self.econsultMethodImage.image = [UIImage imageNamed:@"mobile.png"];
    }
    else
    {
        self.econsultMethodLbl.text = @"Video Conference";
        self.econsultMethodImage.image = [UIImage imageNamed:@"video_call.png"];
    }
    NSString *name = [[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"name"];
    NSString *age = nil;
    if ([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"age"] integerValue] > 0)
        age = [[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"age"];
    if (age != nil && [age length])
    {
        if ([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"gender"] integerValue] == 1)
            self.lblName.text = [NSString stringWithFormat:@"%@/%@/M",name,age];
        else if([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"gender"] integerValue] == 2)
            self.lblName.text = [NSString stringWithFormat:@"%@/%@/F",name,age];
        else
            self.lblName.text = [NSString stringWithFormat:@"%@/%@",name,age];
    }
    else
    {
        if ([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"gender"] integerValue] == 1)
            self.lblName.text = [NSString stringWithFormat:@"%@/M",name];
        else if([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"gender"] integerValue] == 2)
            self.lblName.text = [NSString stringWithFormat:@"%@/F",name];
        else
            self.lblName.text = name;
        
    }
    
//    self.lblName.text=[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"name"];
    NSString *strDatTime=[NSString stringWithFormat:@"%@ %@",[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"appdate"],[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"apptime"]];
    self.lblDate.text=[NSString timeFormating:strDatTime funcName:@"appointment"];
    //    self.lblStauts.text=[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"status"];
    if ([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"status"] integerValue] == 1)
    {
        self.lblStauts.text = @"Pending";
        self.cellImagView.image = [UIImage imageNamed:@"econsult_pending.png"];
        self.lblStauts.textColor = [UIColor colorWithRed:204.0/255.0 green:102.0/255.0 blue:0.0/255.0 alpha:1];
    }
    else if ([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"status"] integerValue] == 2)
    {
        self.lblStauts.text = @"Confirmed";
        self.cellImagView.image = [UIImage imageNamed:@"econsult_booked.png"];
        self.lblStauts.textColor = [UIColor colorWithRed:0.0/255.0 green:102.0/255.0 blue:0.0/255.0 alpha:1];
    }
    else if ([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"status"] integerValue] == 3)
    {
        self.lblStauts.text = @"Completed";
        self.cellImagView.image = [UIImage imageNamed:@"econsult_completed.png"];
        self.lblStauts.textColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:153.0/255.0 alpha:1];
    }
    else if ([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"status"] integerValue] == 4)
    {
        self.lblStauts.text = @"Cancelled";
        self.cellImagView.image = [UIImage imageNamed:@"econsult_completed.png"];
        self.lblStauts.textColor = [UIColor redColor];
    }

    
//    NSString *htmlString=[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"reason"];
//    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
//    
//    if ([[attrStr string] length] > 0)
//    {
//        NSArray *arr = [[attrStr string] componentsSeparatedByString:@"***"];
//        self.txtMobile.text = [arr objectAtIndex:1];
//        if ([arr count]>2)
//            self.lblReason.text=[arr objectAtIndex:2];
//    }
    if ([[arrAppDetails objectAtIndex:rowIndex] objectForKey:@"primaryphone"])
        self.txtMobile.text = [[arrAppDetails objectAtIndex:rowIndex] objectForKey:@"primaryphone"];
    
    //[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"reason"];
    
}

- (IBAction)callBtnClicked:(id)sender
{
    NSString *phoneNumber=self.txtMobile.text;
    NSString *number = [NSString stringWithFormat:@"%@",phoneNumber];
    NSURL* callUrl=[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",number]];
    //check  Call Function available only in iphone
    if([[UIApplication sharedApplication] canOpenURL:callUrl])
    {
        [[UIApplication sharedApplication] openURL:callUrl];
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"ALERT" message:@"This function is only available on the iPhone"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }
}

@end
