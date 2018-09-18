    //
//  smartRxEconsultVC.m
//  smartRxDoctor
//
//  Created by Manju Basha on 14/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import "smartRxEconsultVC.h"
#import "smartRxDashboardVC.h"
#import "smartRxEconsultListVC.h"
#import "NSString+DateConvertion.h"
#import "smartRxEconsultTVC.h"
#import "SmartRxeConsultDetailsVC.h"
@interface smartRxEconsultVC ()
{
    MBProgressHUD *HUD;
    UIActivityIndicatorView *spinner;    
    NSMutableArray *econsultDetailsArr;
    NSInteger econsultIndex;
    BOOL infoShown, viewAppeared;
}
@end

@implementation smartRxEconsultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedDates = [[NSMutableArray alloc] init];
    self.appointmentDetails = [[NSMutableArray alloc] init];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    econsultDetailsArr = [[NSMutableArray alloc] init];
    self.econsultDetails = [[NSMutableArray alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [self.tbleConsults setTableFooterView:[UIView new]];
    [self navigationBackButton];
    [self makeRequestForeConsult];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localeDidChange) name:NSCurrentLocaleDidChangeNotification object:nil];
    //    self.minimumDate = [self.dateFormatter dateFromString:@"20/09/2012"];
    // Do any additional setup after loading the view.
}
- (void)viewWillDisappear:(BOOL)animated {
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count-2] == self) {
        // View is disappearing because a new view controller was pushed onto the stack
        NSLog(@"New view controller was pushed");
    } else if ([viewControllers indexOfObject:self] == NSNotFound) {
        // View is disappearing because it was popped from the stack
        NSLog(@"View controller was popped");
    }
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
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
//    [super viewWillAppear:YES];
    viewAppeared = YES;
    if ( econsultIndex >= 1 && [[NSUserDefaults standardUserDefaults]boolForKey:@"EConsultPush"] == YES)
    {
        [self performSegueWithIdentifier:@"econsultDetails" sender:[self.appointmentDetails objectAtIndex:econsultIndex-1]];
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    viewAppeared = NO;    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"fromModify"] integerValue] == 1)
    {
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"fromModify"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self makeRequestForeConsult];
    }
    else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"firstLoad"] integerValue] != 1)
        [self makeRequestForeConsultInBack];
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
    
    
}

-(void)logOutId:(id)sender
{
}
#pragma mark - Request method
-(void)makeRequestForeConsult
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&type=2",@"sessionid",sectionId];
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
                [HUD hide:YES];
                [HUD removeFromSuperview];
                NSMutableArray *responseDict = [response objectForKey:@"app"];
                if ([responseDict count])
                {
                    for (int i=0; i<[responseDict count]; i++)
                    {
                        NSString *strDatTime=[NSString stringWithFormat:@"%@ %@",[[[response objectForKey:@"app"] objectAtIndex:i]objectForKey:@"appdate"],[[[response objectForKey:@"app"] objectAtIndex:i]objectForKey:@"apptime"]];
                        NSString *str =[NSString timeFormating:strDatTime funcName:@"eConsult"];
                        if(![str isEqualToString:@"(null) (null)"])
                        {
                            NSString *appDate = [[responseDict objectAtIndex:i] objectForKey:@"appdate"];
                            [self.selectedDates addObject:[self.dateFormatter dateFromString:appDate]];
                            [self.appointmentDetails addObject:[responseDict objectAtIndex:i]];
                        }
                        if ([[NSUserDefaults standardUserDefaults]boolForKey:@"EConsultPush"] == YES)
                        {
                            if ([[NSUserDefaults standardUserDefaults]boolForKey:@"EConsultVideoPush"] == YES)
                            {
                                if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"pushEconsultID"] isEqualToString:[[[response objectForKey:@"app"] objectAtIndex:i]objectForKey:@"appid"]])
                                {
                                    econsultIndex = i+1;
                                }
                                
                            }
                            else
                            {
                                if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"pushEconsultID"] isEqualToString:[[[response objectForKey:@"app"] objectAtIndex:i]objectForKey:@"conid"]])
                                {
                                    econsultIndex = i+1;
                                }
                            }
                        }
                        if (econsultIndex > 1)
                            break;
                    }
                }
                [self initCalendar];
                NSDate *today = [NSDate date];
                NSString *dateString = [self.dateFormatter stringFromDate:today];
                today = [self.dateFormatter dateFromString:dateString];
                [econsultDetailsArr removeAllObjects];
                [self.econsultDetails removeAllObjects];
                [self.selectedDates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                 {
                     if ([obj isEqualToDate:today])
                     {
                         NSDictionary *tempDict = [self.appointmentDetails objectAtIndex:idx];
                         [econsultDetailsArr addObject:tempDict];
                     }
                 }];
                self.econsultDetails = econsultDetailsArr;
                
                if ([[NSUserDefaults standardUserDefaults]boolForKey:@"EConsultPush"] != YES)
                {
                    if (![self.econsultDetails count])
                    {
                        self.eConsultEmptyLbl.hidden = NO;
                        self.eConsultEmptyLbl.frame = CGRectMake(self.eConsultEmptyLbl.frame.origin.x, self.calendar.frame.origin.y + self.calendar.frame.size.height - 40, self.eConsultEmptyLbl.frame.size.width, self.eConsultEmptyLbl.frame.size.width);
                        self.tbleConsults.hidden = YES;
                    }
                    else
                        [self showOrHideCalendar:nil];
                    self.view.userInteractionEnabled = YES;
                }
                else
                {
                    if (viewAppeared)
                        [self performSegueWithIdentifier:@"econsultDetails" sender:[[response objectForKey:@"app"] objectAtIndex:econsultIndex-1]];
                }
                
            });
        }
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }];
}

-(void)makeRequestForeConsultInBack
{
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&type=2",@"sessionid",sectionId];
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
                
                NSMutableArray *responseDict = [response objectForKey:@"app"];
                [self.selectedDates removeAllObjects];
                [self.appointmentDetails removeAllObjects];
                if ([responseDict count])
                {
                    for (int i=0; i<[responseDict count]; i++)
                    {
                        NSString *strDatTime=[NSString stringWithFormat:@"%@ %@",[[[response objectForKey:@"app"] objectAtIndex:i]objectForKey:@"appdate"],[[[response objectForKey:@"app"] objectAtIndex:i]objectForKey:@"apptime"]];
                        NSString *str =[NSString timeFormating:strDatTime funcName:@"eConsult"];
                        if(![str isEqualToString:@"(null) (null)"])
                        {
                            NSString *appDate = [[responseDict objectAtIndex:i] objectForKey:@"appdate"];
                            [self.selectedDates addObject:[self.dateFormatter dateFromString:appDate]];
                            [self.appointmentDetails addObject:[responseDict objectAtIndex:i]];
                        }
                    }
                }
                //                [self initCalendar];
                [self.calendar reloadDates:self.selectedDates];
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT+5:30"];
                [dateFormat setTimeZone:gmt];
                [dateFormat setDateFormat:@"yyyy-MM-dd"];
                if ([self.econsultDetails count])
                {
                    NSDate *date = [dateFormat dateFromString:[[self.econsultDetails objectAtIndex:0]objectForKey:@"appdate"]];
                    [econsultDetailsArr removeAllObjects];
                    [self.econsultDetails removeAllObjects];
                    [self.selectedDates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                     {
                         if ([obj isEqualToDate:date])
                         {
                             NSDictionary *tempDict = [self.appointmentDetails objectAtIndex:idx];
                             [econsultDetailsArr addObject:tempDict];
                         }
                     }];
                    self.econsultDetails = econsultDetailsArr;
                    if ([self.econsultDetails count])
                    {
                        self.calendar.hidden = YES;                        
                        self.eConsultEmptyLbl.hidden = YES;
                        self.tbleConsults.hidden = NO;
                        if ([self.econsultDetails count] > 4)
                        {
                            int val = ([self.econsultDetails count]-4)*90;
                            self.tbleConsults.contentSize = CGSizeMake(self.tbleConsults.contentSize.width, self.tbleConsults.contentSize.height+val+90);
                        }
                        [self.tbleConsults reloadData];                        
                    }
                    else
                    {
                        self.eConsultEmptyLbl.hidden = NO;
                        self.eConsultEmptyLbl.frame = CGRectMake(self.eConsultEmptyLbl.frame.origin.x, 100, self.eConsultEmptyLbl.frame.size.width, self.eConsultEmptyLbl.frame.size.width);
                        self.tbleConsults.hidden = YES;
                    }
                }
                else
                {
                    [self showOrHideCalendar:nil];
                    self.eConsultEmptyLbl.hidden = NO;
                    self.eConsultEmptyLbl.frame = CGRectMake(self.eConsultEmptyLbl.frame.origin.x, 100, self.eConsultEmptyLbl.frame.size.width, self.eConsultEmptyLbl.frame.size.width);
                    self.tbleConsults.hidden = YES;
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
    if ([self.calendar isHidden])
    {
        self.calendar.hidden = NO;
        self.tbleConsults.hidden = YES;
        if ([self.econsultDetails count])
            self.eConsultEmptyLbl.hidden = YES;
        else
        {
            self.eConsultEmptyLbl.hidden = NO;
            self.eConsultEmptyLbl.frame = CGRectMake(self.eConsultEmptyLbl.frame.origin.x, self.calendar.frame.origin.y + self.calendar.frame.size.height-40, self.eConsultEmptyLbl.frame.size.width, self.eConsultEmptyLbl.frame.size.width);
        }
    }
    else
    {
        self.calendar.hidden = YES;
        if ([self.econsultDetails count])
        {
            self.eConsultEmptyLbl.hidden = YES;
            self.tbleConsults.hidden = NO;
            [self.tbleConsults reloadData];
            if ([self.econsultDetails count] > 4)
            {
                int val = ([self.econsultDetails count]-4)*90;
                self.tbleConsults.contentSize = CGSizeMake(self.tbleConsults.contentSize.width, self.tbleConsults.contentSize.height+val+90);
            }
        }
        else
        {
            self.eConsultEmptyLbl.hidden = NO;
            self.eConsultEmptyLbl.frame = CGRectMake(self.eConsultEmptyLbl.frame.origin.x, 100, self.eConsultEmptyLbl.frame.size.width, self.eConsultEmptyLbl.frame.size.width);
            self.tbleConsults.hidden = YES;
        }
        
    }

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
        //        dateItem.backgroundColor = [UIColor blackColor];
        //        dateItem.textColor = [UIColor whiteColor];
        dateItem.backGroundImg = [UIImage imageNamed:@"dayMarked.png"];
    }
}
- (void)calendar:(CKCalendarView *)calendar didSelectDate:(NSDate *)date {
    self.dateLabel.text = [self.dateFormatter stringFromDate:date];
    [econsultDetailsArr removeAllObjects];
    [self.econsultDetails removeAllObjects];
    if ([self dateIsApt:date])
    {
        NSLog(@"%@",[self.appointmentDetails objectAtIndex:[self.selectedDates indexOfObject:date]]);
        [self.selectedDates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             if ([obj isEqualToDate:date])
             {
                 NSDictionary *tempDict = [self.appointmentDetails objectAtIndex:idx];
                 [econsultDetailsArr addObject:tempDict];
             }
         }];
        self.econsultDetails = econsultDetailsArr;
        [self showOrHideCalendar:nil];
//        [self performSegueWithIdentifier:@"econsultListVC" sender:econsultDetailsArr];
    }
    else
    {
        self.eConsultEmptyLbl.hidden = NO;
        self.eConsultEmptyLbl.frame = CGRectMake(self.eConsultEmptyLbl.frame.origin.x, self.calendar.frame.origin.y + self.calendar.frame.size.height-40, self.eConsultEmptyLbl.frame.size.width, self.eConsultEmptyLbl.frame.size.width);
    }

}

- (BOOL)calendar:(CKCalendarView *)calendar willChangeToMonth:(NSDate *)date {
    return [date laterDate:self.minimumDate] == date;
}
- (void)calendar:(CKCalendarView *)calendar didChangeToMonth:(NSDate *)date
{
    if (![self.eConsultEmptyLbl isHidden])
    {
//        - (NSInteger)_numberOfWeeksInMonthContainingDate:(NSDate *)date

        NSDate *dateToSend = [self.calendar _firstDayOfNextMonthContainingDate:date];
        NSLog(@"Date : %@", dateToSend);
        NSLog(@"Month changed %d", [self.calendar _numberOfWeeksInMonthContainingDate:dateToSend]);
        if ([self.calendar _numberOfWeeksInMonthContainingDate:dateToSend] > 5)
            self.eConsultEmptyLbl.frame = CGRectMake(self.eConsultEmptyLbl.frame.origin.x, self.calendar.frame.origin.y + 340-20, self.eConsultEmptyLbl.frame.size.width, self.eConsultEmptyLbl.frame.size.width);
        else
            self.eConsultEmptyLbl.frame = CGRectMake(self.eConsultEmptyLbl.frame.origin.x, self.calendar.frame.origin.y + 300-30, self.eConsultEmptyLbl.frame.size.width, self.eConsultEmptyLbl.frame.size.width);
    }
    
}

#pragma mark - Custom delegates for section id
-(void)sectionIdGenerated:(id)sender;
{
    [spinner stopAnimating];
    [spinner removeFromSuperview];
    spinner = nil;
    self.view.userInteractionEnabled = YES;
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForeConsult];
    }
    else{
        
        [self customAlertView:@"" Message:@"Network not available" tag:0];
        
    }
    
    
}
-(void)errorSectionId:(id)sender
{
    NSLog(@"error");
    [spinner stopAnimating];
    [spinner removeFromSuperview];
    spinner = nil;
    self.view.userInteractionEnabled = YES;
}
#pragma mark - Custom AlertView

-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"econsultListVC"])
    {
        ((smartRxEconsultListVC *)segue.destinationViewController).econsultDetails = [[NSMutableArray alloc] init];
        ((smartRxEconsultListVC *)segue.destinationViewController).econsultDetails = econsultDetailsArr;
    }
    if ([segue.identifier isEqualToString:@"econsultDetails"])
    {
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"firstLoad"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        ((SmartRxeConsultDetailsVC *)segue.destinationViewController).dictResponse = [[NSMutableDictionary alloc] initWithDictionary:sender];
        //        [((smartRxAppointmentDetailsVC *)segue.destinationViewController).appointmentDetails addObject:sender];
    }

}

#pragma mark - Tableview Delegate/Datasource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.calendar isHidden])
        return [self.econsultDetails count];
    else
        return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *cellIdentifier=@"eCell";
    smartRxEconsultTVC *cell=(smartRxEconsultTVC *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if ([self.calendar isHidden])
        [cell setCellData:self.econsultDetails row:indexPath.row];
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"econsultDetails" sender:[self.econsultDetails objectAtIndex:indexPath.row]];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([self.calendar isHidden])
    {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT+5:30"];
        [dateFormat setTimeZone:gmt];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        NSDate *date = [dateFormat dateFromString:[[self.econsultDetails objectAtIndex:0]objectForKey:@"appdate"]];
        [dateFormat setDateFormat:@"dd-MM-yyyy"];
        return [dateFormat stringFromDate:date];
    }
    else
        return @"";
    
    //    return [[self.appointmentDetails objectAtIndex:0]objectForKey:@"appdate"];
}

@end
