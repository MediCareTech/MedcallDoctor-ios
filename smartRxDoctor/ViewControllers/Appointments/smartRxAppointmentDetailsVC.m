//
//  smartRxAppointmentDetailsVC.m
//  smartRxDoctor
//
//  Created by Manju Basha on 14/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import "smartRxAppointmentDetailsVC.h"
#import "AppointmentTableViewCell.h"
#import "smartRxDashboardVC.h"

@interface smartRxAppointmentDetailsVC ()
{
    CGFloat heightLbl;
    MBProgressHUD *HUD;
}
@end

@implementation smartRxAppointmentDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
//    if ([self.appointmentDetails count] > 5)
//    {
//        self.tblAppointments.contentSize = CGSizeMake(self.tblAppointments.contentSize.width, self.tblAppointments.contentSize.height+150);
//    }
    [self.tblAppointments setTableFooterView:[UIView new]];
    CGFloat tableHeight = 0.0f;
    for (int i = 0; i < [self.appointmentDetails count]; i ++) {
        tableHeight += [self tableView:self.tblAppointments heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
    }

        self.tblAppointments.frame = CGRectMake(self.tblAppointments.frame.origin.x, self.tblAppointments.frame.origin.y, self.tblAppointments.frame.size.width, tableHeight);
    if (tableHeight > self.aptScroll.frame.size.height-100)
    {
        [self.aptScroll setContentSize:CGSizeMake(self.aptScroll.frame.size.width, tableHeight+200)];
    }
    
    [self navigationBackButton];
    // Do any additional setup after loading the view.
}
-(void)navigationBackButton
{
    self.navigationItem.hidesBackButton=YES;
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backBtnImage = [UIImage imageNamed:@"icn_back.png"];
    [backBtn setImage:backBtnImage forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame = CGRectMake(-40, -2, 100, 40);
    UIView *backButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 47)];
    backButtonView.bounds = CGRectOffset(backButtonView.bounds, 0, -7);
    [backButtonView addSubview:backBtn];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backButtonView];
    self.navigationItem.leftBarButtonItem = backButton;
    
    UIButton *btnFaq = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *faqBtnImag = [UIImage imageNamed:@"nav_calendar.png"];
    [btnFaq setImage:faqBtnImag forState:UIControlStateNormal];
    [btnFaq addTarget:self action:@selector(homeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    btnFaq.frame = CGRectMake(20, -2, 60, 40);
    UIView *btnFaqView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 47)];
    btnFaqView.bounds = CGRectOffset(btnFaqView.bounds, 0, -7);
    [btnFaqView addSubview:btnFaq];
    UIBarButtonItem *rightbutton = [[UIBarButtonItem alloc] initWithCustomView:btnFaqView];
    self.navigationItem.rightBarButtonItem = rightbutton;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Tableview Delegate/Datasource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.appointmentDetails count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"APPCell";
    AppointmentTableViewCell *cell=(AppointmentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    UIView *separatorLine;
    if (cell == nil)
    {        
        cell = [[AppointmentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        separatorLine = [[UIView alloc] initWithFrame:CGRectZero];
        separatorLine.backgroundColor = [UIColor grayColor];
        separatorLine.tag = 100;
        [cell.contentView addSubview:separatorLine];
    }
    separatorLine = (UIView *)[cell.contentView viewWithTag:100];
    
    separatorLine.frame = CGRectMake(0, cell.frame.size.height-1, cell.frame.size.width, 1);
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setCellData:self.appointmentDetails row:indexPath.row];
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *htmlString=[[self.appointmentDetails objectAtIndex:indexPath.row]objectForKey:@"reason"];
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    
    CGFloat estHeight = 112.0;
    [self estimatedHeight:[attrStr string]];
    estHeight = estHeight+heightLbl;    
    
    return estHeight;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT+5:30"];
    [dateFormat setTimeZone:gmt];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[self.appointmentDetails objectAtIndex:0]objectForKey:@"appdate"]];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    return [dateFormat stringFromDate:date];
    
//    return [[self.appointmentDetails objectAtIndex:0]objectForKey:@"appdate"];
}
-(void)estimatedHeight:(NSString *)strToCalCulateHeight
{
    UILabel *lblHeight = [[UILabel alloc]initWithFrame:CGRectMake(40,30, 300,21)];
    lblHeight.text = strToCalCulateHeight;
    lblHeight.font = [UIFont systemFontOfSize:17];// [UIFont fontWithName:@"HelveticaNeue" size:16];
    CGSize maximumLabelSize = CGSizeMake(300,9999);
    CGSize expectedLabelSize;
    expectedLabelSize = [lblHeight.text  sizeWithFont:lblHeight.font constrainedToSize:maximumLabelSize lineBreakMode:lblHeight.lineBreakMode];
    heightLbl=expectedLabelSize.height;
    //[self setLblYPostionAndHeight:expectedLabelSize.height+20];
}
#pragma mark - Action Methods
-(void)backBtnClicked:(id)sender
{
    for (UIViewController *controller in [self.navigationController viewControllers])
    {
        if ([controller isKindOfClass:[smartRxDashboardVC class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
}
-(void)homeBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)callBtnClicked:(id)sender {
}
@end
