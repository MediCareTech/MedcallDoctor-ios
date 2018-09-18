//
//  AppointmentTableViewCell.m
//  SmartRx
//
//  Created by Manju Basha on 14/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import "AppointmentTableViewCell.h"
#import "NSString+DateConvertion.h"
@implementation AppointmentTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setCellData:(NSArray *)arrAppDetails row:(NSInteger)rowIndex
{
//    NSString *name = [[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"name"];
//    if ([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"gender"] integerValue] == 1)
//        self.lblDoctorName.text = [NSString stringWithFormat:@"%@/M",name];
//    else if([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"gender"] integerValue] == 2)
//        self.lblDoctorName.text = [NSString stringWithFormat:@"%@/F",name];
//    else
//        self.lblDoctorName.text = name;
    NSString *name = [[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"name"];
    NSString *age = nil;
    if ([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"age"] integerValue] > 0)
        age = [[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"age"];
    if (age != nil && [age length])
    {
        if ([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"gender"] integerValue] == 1)
            self.lblDoctorName.text = [NSString stringWithFormat:@"%@/%@/M",name,age];
        else if([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"gender"] integerValue] == 2)
            self.lblDoctorName.text = [NSString stringWithFormat:@"%@/%@/F",name,age];
        else
            self.lblDoctorName.text = [NSString stringWithFormat:@"%@/%@",name,age];
    }
    else
    {
        if ([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"gender"] integerValue] == 1)
            self.lblDoctorName.text = [NSString stringWithFormat:@"%@/M",name];
        else if([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"gender"] integerValue] == 2)
            self.lblDoctorName.text = [NSString stringWithFormat:@"%@/F",name];
        else
            self.lblDoctorName.text = name;
        
    }
    
    NSString *strDatTime=[NSString stringWithFormat:@"%@ %@",[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"appdate"],[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"apptime"]];
    self.lblDate.text=[NSString timeFormating:strDatTime funcName:@"appointment"];
    if ([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"status"] integerValue] == 1)
    {
        self.lblStauts.text = @"Pending";
        self.lblStauts.textColor = [UIColor colorWithRed:204.0/255.0 green:102.0/255.0 blue:0.0/255.0 alpha:1];
    }
    else if ([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"status"] integerValue] == 2)
    {
        self.lblStauts.text = @"Confirmed";
        self.lblStauts.textColor = [UIColor colorWithRed:0.0/255.0 green:102.0/255.0 blue:0.0/255.0 alpha:1];
    }
    else if ([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"status"] integerValue] == 3)
    {
        self.lblStauts.text = @"Completed";
        self.lblStauts.textColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:153.0/255.0 alpha:1];
    }
    else if ([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"status"] integerValue] == 4)
    {
        self.lblStauts.text = @"Cancelled";
        self.lblStauts.textColor = [UIColor redColor];
    }
    
    
    NSString *htmlString=[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"reason"];
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    
    if ([[attrStr string] length] > 0)
    {
        NSArray *arr = [[attrStr string] componentsSeparatedByString:@"***"];
        if ([arr count] == 2)
            self.txtMobile.text = [arr objectAtIndex:1];
        if ([arr count]>2 && [[arr objectAtIndex:2] length] && [arr objectAtIndex:2] != nil)
        {
            self.lblReason.hidden = NO;
            self.lblReason.text=[NSString stringWithFormat:@"Reason: %@", [arr objectAtIndex:2]];
            [self.lblReason sizeToFit];
            [self.lblReason setNumberOfLines:0];
        }
        if ([arr count] == 1)
        {
            self.lblReason.hidden = NO;
            self.lblReason.text=[NSString stringWithFormat:@"Reason: %@", [arr objectAtIndex:0]];
            [self.lblReason sizeToFit];
            [self.lblReason setNumberOfLines:0];
        }
        
    }
    else
    {
//        self.lblReason.hidden = YES;
//        self.lblReason.text=@"Reason : Not specified";
//        [self.lblReason sizeToFit];
//        [self.lblReason setNumberOfLines:0];

    }
    if ([[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"primaryphone"])
        self.txtMobile.text = [[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"primaryphone"];
    //[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"reason"];
    NSLog(@"apptype ==== %@",[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"apptype"]);
    if ([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"apptype"]intValue] == 1)
    {
        self.cellImagView.image=[UIImage imageNamed:@"icn_appointment.png"];
    }else if([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"apptype"]intValue] == 2)
    {
        self.cellImagView.image=[UIImage imageNamed:@"icn_econsult.png"];
    }
    
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
