//
//  smartRxAssignedCarePlanVC.m
//  smartRxDoctor
//
//  Created by Manju Basha on 10/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import "smartRxAssignedCarePlanVC.h"
#import "smartRxDashboardVC.h"
#import "smartRxAssignedCarePlanTVC.h"
#import "SmartRxCarePlaneSubVC.h"
@interface smartRxAssignedCarePlanVC ()
{
    MBProgressHUD *HUD;
    UIRefreshControl *refreshControl;
}
@end

@implementation smartRxAssignedCarePlanVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lblNoQes.hidden=YES;
    self.navigationItem.title = [NSString stringWithFormat:@"%@ - Care Plan(s)", self.patName];
    [self navigationBackButton];
    [self.tblCarePlans setTableFooterView:[UIView new]];
    [[SmartRxCommonClass sharedManager] setNavigationTitle:_strTitle controler:self];
    [self makeRequestForCarePlansAssigned];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    UIImage *faqBtnImag = [UIImage imageNamed:@"icn_home.png"];
    [btnFaq setImage:faqBtnImag forState:UIControlStateNormal];
    [btnFaq addTarget:self action:@selector(homeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    btnFaq.frame = CGRectMake(20, -2, 60, 40);
    UIView *btnFaqView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 47)];
    btnFaqView.bounds = CGRectOffset(btnFaqView.bounds, 0, -7);
    [btnFaqView addSubview:btnFaq];
    UIBarButtonItem *rightbutton = [[UIBarButtonItem alloc] initWithCustomView:btnFaqView];
    self.navigationItem.rightBarButtonItem = rightbutton;
    
    
}
-(void)addSpinnerView
{
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
}

#pragma mark - Request method
-(void)makeRequestForCarePlansAssigned
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&patid=%@",@"sessionid",sectionId, self.patientID];
    NSString *url=[NSString stringWithFormat:@"%@%@",WB_BASEURL,@"dpatbyid"];
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
                self.view.userInteractionEnabled = YES;
                self.patName = [[[response objectForKey:@"pdetails"] objectForKey:@"0"] objectForKey:@"dispname"];
                [refreshControl endRefreshing];
                self.arrCarePlans=[response objectForKey:@"cdetails"];
                if ([self.arrCarePlans count])
                {
                    self.tblCarePlans.hidden=NO;
                    [self.tblCarePlans reloadData];
                }
                else{
                    self.lblNoQes.hidden=NO;
                }
                
            });
        }
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }];
}

#pragma mark - TableView DataSource/Delegates

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrCarePlans count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"assignedCarePlanCell";
    smartRxAssignedCarePlanTVC *cell=(smartRxAssignedCarePlanTVC *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;    
    [cell setCellData:[self.arrCarePlans copy] :indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     NSDictionary *dictTemp=[NSDictionary dictionaryWithObjectsAndKeys:[[self.arrCarePlans objectAtIndex:indexPath.row]objectForKey:@"postopcareid"],@"careid",[[self.arrCarePlans objectAtIndex:indexPath.row]objectForKey:@"rehabname"],@"Title", nil];
    [self performSegueWithIdentifier:@"cpAssignedToCPSub" sender:dictTemp];
}

#pragma mark - Action Methods
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


#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"cpAssignedToCPSub"])
    {
        ((SmartRxCarePlaneSubVC *)segue.destinationViewController).strOpId=[sender objectForKey:@"careid"];
        ((SmartRxCarePlaneSubVC *)segue.destinationViewController).strTitle=[sender objectForKey:@"Title"];
    }
}
@end
