//
//  smartRxAppointmentVC.m
//  smartRxDoctor
//
//  Created by Manju Basha on 14/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import "smartRxAppointmentVC.h"
#import "smartRxDashboardVC.h"
#import "smartRxAppointmentDetailsVC.h"
#import "AppointmentTableViewCell.h"

@interface smartRxAppointmentVC ()
{
    CGFloat heightLbl;
    MBProgressHUD *HUD;
    NSMutableArray *appointmentDetailsArr;
}
@end

@implementation smartRxAppointmentVC
//- (id)init {
//    self = [super init];
//    if (self) {
//
//    }
//    return self;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedDates = [[NSMutableArray alloc] init];
    self.appointmentDetails = [[NSMutableArray alloc] init];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    appointmentDetailsArr = [[NSMutableArray alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [self makeRequestForAppointments];    
    [self navigationBackButton];


    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localeDidChange) name:NSCurrentLocaleDidChangeNotification object:nil];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"firstLoadAppointment"] integerValue] != 1)
        [self makeRequestForAppointmentsBack];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initCalendar
{
    CKCalendarView *calendar = [[CKCalendarView alloc] initWithStartDay:startMonday];
    self.calendar = calendar;
    calendar.delegate = self;
    calendar.onlyShowCurrentMonth = NO;
    calendar.adaptHeightToNumberOfWeeksInMonth = YES;
    
    calendar.frame = CGRectMake(0, 0, 320, 320);
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.calendarContainer addSubview:calendar];
    
//    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(calendar.frame) + 4, self.view.bounds.size.width, 24)];
    [self.view addSubview:self.dateLabel];

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
    [btnFaq addTarget:self action:@selector(showOrHideCalendar:) forControlEvents:UIControlEventTouchUpInside];
    btnFaq.frame = CGRectMake(20, -2, 60, 40);
    UIView *btnFaqView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 47)];
    btnFaqView.bounds = CGRectOffset(btnFaqView.bounds, 0, -7);
    [btnFaqView addSubview:btnFaq];
    UIBarButtonItem *rightbutton = [[UIBarButtonItem alloc] initWithCustomView:btnFaqView];
    self.navigationItem.rightBarButtonItem = rightbutton;

    
//    UIButton *btnFaq = [UIButton buttonWithType:UIButtonTypeCustom];
//    UIImage *faqBtnImag = [UIImage imageNamed:@"icn_home.png"];
//    [btnFaq setImage:faqBtnImag forState:UIControlStateNormal];
//    [btnFaq addTarget:self action:@selector(homeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    btnFaq.frame = CGRectMake(20, -2, 60, 40);
//    UIView *btnFaqView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 47)];
//    btnFaqView.bounds = CGRectOffset(btnFaqView.bounds, 0, -7);
//    [btnFaqView addSubview:btnFaq];
//    UIBarButtonItem *rightbutton = [[UIBarButtonItem alloc] initWithCustomView:btnFaqView];
//    self.navigationItem.rightBarButtonItem = rightbutton;
    
    
}

#pragma mark - Request method
-(void)makeRequestForAppointments
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&type=1",@"sessionid",sectionId];
    NSString *url =[NSString stringWithFormat:@"%@%@",WB_BASEURL,@"dapt"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 27 %@",response);
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [HUD hide:YES];
                [HUD removeFromSuperview];
                NSMutableArray *responseDict = [response objectForKey:@"app"];
                [self.selectedDates removeAllObjects];
                [self.appointmentDetails removeAllObjects];
                if ([responseDict count])
                {
                    for (int i=0; i<[responseDict count]; i++)
                    {
//                        if ([[[responseDict objectAtIndex:i] objectForKey:@"app_method"] integerValue] == 0)
//                        {
                            NSString *appDate = [[responseDict objectAtIndex:i] objectForKey:@"appdate"];
                            [self.selectedDates addObject:[self.dateFormatter dateFromString:appDate]];
                            [self.appointmentDetails addObject:[responseDict objectAtIndex:i]];
//                        }
                    }
                }
                [self initCalendar];

                if ([self.appointmentDetails count])
                {
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT+5:30"];
                    [dateFormat setTimeZone:gmt];
                    [dateFormat setDateFormat:@"yyyy-MM-dd"];
                    NSDate *today = [NSDate date];
                    NSString *dateString = [self.dateFormatter stringFromDate:today];
                    today = [self.dateFormatter dateFromString:dateString];
                    [appointmentDetailsArr removeAllObjects];
                    [self.selectedDates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                     {
                         if ([obj isEqualToDate:today])
                         {
                             NSDictionary *tempDict = [self.appointmentDetails objectAtIndex:idx];
                             [appointmentDetailsArr addObject:tempDict];
                         }
                     }];
                    if ([appointmentDetailsArr count])
                        self.noAptLbl.hidden = YES;
                    else
                        self.noAptLbl.hidden = NO;
                }
                else
                {
                    self.noAptLbl.hidden = NO;
                }
                self.view.userInteractionEnabled = YES;
                
            });
        }
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }];
}


-(void)makeRequestForAppointmentsBack
{

    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&type=1",@"sessionid",sectionId];
    NSString *url =[NSString stringWithFormat:@"%@%@",WB_BASEURL,@"dapt"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 27 %@",response);
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.selectedDates removeAllObjects];
                [self.appointmentDetails removeAllObjects];
                NSMutableArray *responseDict = [response objectForKey:@"app"];
                if ([responseDict count])
                {
                    for (int i=0; i<[responseDict count]; i++)
                    {
                        //                        if ([[[responseDict objectAtIndex:i] objectForKey:@"app_method"] integerValue] == 0)
                        //                        {
                        NSString *appDate = [[responseDict objectAtIndex:i] objectForKey:@"appdate"];
                        [self.selectedDates addObject:[self.dateFormatter dateFromString:appDate]];
                        [self.appointmentDetails addObject:[responseDict objectAtIndex:i]];
                        //                        }
                    }
                }
//                [self initCalendar];
                [self.calendar reloadDates:self.selectedDates];
                if ([self.appointmentDetails count])
                {
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT+5:30"];
                    [dateFormat setTimeZone:gmt];
                    [dateFormat setDateFormat:@"yyyy-MM-dd"];
                    NSDate *today = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedAptDate"];//[NSDate date];
                    NSString *dateString = [self.dateFormatter stringFromDate:today];
                    today = [self.dateFormatter dateFromString:dateString];
                    [appointmentDetailsArr removeAllObjects];
                    [self.selectedDates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                     {
                         if ([obj isEqualToDate:today])
                         {
                             NSDictionary *tempDict = [self.appointmentDetails objectAtIndex:idx];
                             [appointmentDetailsArr addObject:tempDict];
                         }
                     }];
                    if ([appointmentDetailsArr count])
                        self.noAptLbl.hidden = YES;
                    else
                        self.noAptLbl.hidden = NO;
                }
                else
                {
                    self.noAptLbl.hidden = NO;
                }
                self.view.userInteractionEnabled = YES;
                
            });
        }
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
    }];
}
-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
}
#pragma mark - Action Methods
- (void)localeDidChange {
    [self.calendar setLocale:[NSLocale currentLocale]];
}
- (void)showOrHideCalendar:(id)sender
{
    if ([appointmentDetailsArr count])
        [self performSegueWithIdentifier:@"appointmentDetails" sender:appointmentDetailsArr];
    else
    {
        if ([self.calendar isHidden])
        {
            self.calendar.hidden = NO;
            self.noAptLbl.hidden = NO;
            self.noAptLbl.frame = CGRectMake(self.noAptLbl.frame.origin.x, self.calendar.frame.origin.y + self.calendar.frame.size.height-20, self.noAptLbl.frame.size.width, self.noAptLbl.frame.size.width);
        }
        else
        {
            self.calendar.hidden = YES;
            self.noAptLbl.hidden = NO;
            self.noAptLbl.frame = CGRectMake(self.noAptLbl.frame.origin.x, 100, self.noAptLbl.frame.size.width, self.noAptLbl.frame.size.width);
        }
    }

//    if ([self.calendar isHidden])
//    {
//        self.calendar.hidden = NO;
//        self.aptScroll.hidden = YES;
//        if ([appointmentDetailsArr count])
//            self.noAptLbl.hidden = YES;
//        else
//        {
//            self.noAptLbl.hidden = NO;
//            self.noAptLbl.frame = CGRectMake(self.noAptLbl.frame.origin.x, self.calendar.frame.origin.y + self.calendar.frame.size.height-20, self.noAptLbl.frame.size.width, self.noAptLbl.frame.size.width);
//        }
//    }
//    else
//    {
//        self.calendar.hidden = YES;
//        if ([appointmentDetailsArr count])
//        {
//            self.noAptLbl.hidden = YES;
//            self.aptScroll.hidden = NO;
//            [self.tbleAppointments reloadData];
//            [self.tbleAppointments setTableFooterView:[UIView new]];
//            CGFloat tableHeight = 0.0f;
//            for (int i = 0; i < [appointmentDetailsArr count]; i ++) {
//                tableHeight += [self tableView:self.tbleAppointments heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
//            }
//            
//            self.tbleAppointments.frame = CGRectMake(self.tbleAppointments.frame.origin.x, self.tbleAppointments.frame.origin.y, self.tbleAppointments.frame.size.width, tableHeight);
//            if (tableHeight > self.aptScroll.frame.size.height)
//            {
//                [self.aptScroll setContentSize:CGSizeMake(self.aptScroll.frame.size.width, tableHeight+200)];
//            }
////            self.aptScroll.frame = CGRectMake(self.aptScroll.frame.origin.x, 64, self.aptScroll.frame.size.width, self.aptScroll.frame.size.height);
////            if ([self.econsultDetails count] > 4)
////            {
////                int val = ([self.econsultDetails count]-4)*111;
////                self.tbleConsults.contentSize = CGSizeMake(self.tbleConsults.contentSize.width, self.tbleConsults.contentSize.height+val+111);
////            }
//        }
//        else
//        {
//            self.noAptLbl.hidden = NO;
//            self.noAptLbl.frame = CGRectMake(self.noAptLbl.frame.origin.x, 100, self.noAptLbl.frame.size.width, self.noAptLbl.frame.size.width);
//            self.aptScroll.hidden = YES;
//        }
//        
//    }
    
}

-(void)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)homeBtnClicked:(id)sender
{
    
    for (UIViewController *controller in [self.navigationController viewControllers])
    {
        if ([controller isKindOfClass:[smartRxDashboardVC class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
}
- (BOOL)dateIsApt:(NSDate *)date
{
    if ([self.selectedDates count])
    {
        for (NSDate *enableDate in self.selectedDates) {
            if ([enableDate isEqualToDate:date]) {
                return YES;
            }
        }
    }
    return NO;
    
}
#pragma mark - CKCalendarDelegate
- (void)calendar:(CKCalendarView *)calendar configureDateItem:(CKDateItem *)dateItem forDate:(NSDate *)date {
    // TODO: play with the coloring if we want to...
    if ([self dateIsApt:date])
    {
        dateItem.backGroundImg = [UIImage imageNamed:@"dayMarked.png"];
    }
}
- (void)calendar:(CKCalendarView *)calendar didSelectDate:(NSDate *)date {
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    self.dateLabel.text = [self.dateFormatter stringFromDate:date];
    [appointmentDetailsArr removeAllObjects];
    if ([self dateIsApt:date])
    {
        [self.selectedDates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             if ([obj isEqualToDate:date])
             {
                 [[NSUserDefaults standardUserDefaults]setObject:date forKey:@"selectedAptDate"];
                 NSDictionary *tempDict = [self.appointmentDetails objectAtIndex:idx];
                 [appointmentDetailsArr addObject:tempDict];
             }
         }];
        if (![HUD isHidden]) {
            [HUD hide:YES];
        }
        self.noAptLbl.hidden = YES;
        [[NSUserDefaults standardUserDefaults]synchronize];        
        [self showOrHideCalendar:nil];        
//        [self performSegueWithIdentifier:@"appointmentDetails" sender:appointmentDetailsArr];
    }
    else
    {
        self.noAptLbl.hidden = NO;
        [HUD hide:YES];
        [HUD removeFromSuperview];
//        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"No appointments are available on selected date"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];

    }
}

- (BOOL)calendar:(CKCalendarView *)calendar willChangeToMonth:(NSDate *)date {
    return [date laterDate:self.minimumDate] == date;
}

/*
#pragma mark - Tableview Delegate/Datasource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([appointmentDetailsArr count])
        return [appointmentDetailsArr count];
    else
        return 1;
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
    if ([appointmentDetailsArr count])
        [cell setCellData:appointmentDetailsArr row:indexPath.row];
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if ([appointmentDetailsArr count])
    if ([self.calendar isHidden])
    {
        NSString *htmlString=[[appointmentDetailsArr objectAtIndex:indexPath.row]objectForKey:@"reason"];
        NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        CGFloat estHeight = 112.0;
        [self estimatedHeight:[attrStr string]];
        estHeight = estHeight+heightLbl;
        return estHeight;
    }
    else
    {
        return 112.0;
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
//    if ([appointmentDetailsArr count])
    if ([self.calendar isHidden])
    {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT+5:30"];
        [dateFormat setTimeZone:gmt];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        NSDate *date = [dateFormat dateFromString:[[appointmentDetailsArr objectAtIndex:0]objectForKey:@"appdate"]];
        [dateFormat setDateFormat:@"dd-MM-yyyy"];
        return [dateFormat stringFromDate:date];
    }
    else
        return @"";//    return [[self.appointmentDetails objectAtIndex:0]objectForKey:@"appdate"];
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
*/

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"appointmentDetails"])
    {
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"firstLoadAppointment"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        ((smartRxAppointmentDetailsVC *)segue.destinationViewController).appointmentDetails = [[NSMutableArray alloc] init];
        ((smartRxAppointmentDetailsVC *)segue.destinationViewController).appointmentDetails = appointmentDetailsArr;
    }
}

@end
