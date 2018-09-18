//
//  EhrDashBoardVc.m
//  smartRxDoctor
//
//  Created by Gowtham on 23/01/18.
//  Copyright © 2018 Anil Kumar. All rights reserved.
//

#import "EhrDashBoardVc.h"
#import "EhrModel.h"
#import "smartRxDashboardVC.h"
#import "TrackListTVC.h"
#import "EhrDetailsResponseModel.h"
#import "EHRDetailsVc.h"

@interface EhrDashBoardVc ()
{
    MBProgressHUD *HUD;
    EhrModel *selectedEhrModel;
    NSString *selectedEhrType;
}

@end

@implementation EhrDashBoardVc
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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"EHR";
    [self.tableView setTableFooterView:[UIView new]];
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
   
    NSArray *ehrTitleArr= [NSArray arrayWithObjects:@"Medication",@"Symptoms",@"Diagnosis",@"Allergies",@"Family History",@"Health Issues",@"Lifestyle",@"Vaccination", nil];
    NSArray *ehrTypeArr= [NSArray arrayWithObjects:@"r_medication",@"r_symptom",@"r_diagnosis",@"r_allergy",@"r_familyhistory",@"r_healthissue",@"r_lifestyle",@"r_vaccination", nil];
    NSMutableArray *tempArry = [[NSMutableArray alloc]init];
    for (int i = 0;i < ehrTypeArr.count; i++) {
        EhrModel *model = [[EhrModel alloc]init];
        model.ehrTitle = ehrTitleArr[i];
        model.ehrType = ehrTypeArr[i];
        [tempArry addObject:model];
    }
    self.ehrArray = [tempArry copy];
    
    [self navigationBackButton];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
#pragma mark - TableView Delegates N datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.ehrArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"TrackerId";
    TrackListTVC *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.thumbnailImageVw.image = [UIImage imageNamed:@"ehr"];
    EhrModel *model = self.ehrArray[indexPath.row];
    cell.lblTrackname.text = model.ehrTitle;
    
    //    for (int i=0; i<_healthMeasures.count; i++)
    //    {
    //        if (indexPath.row == i) {
    //            cell.textLabel.text = [_healthMeasures objectAtIndex:i];
    //        }
    //    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedEhrModel = self.ehrArray[indexPath.row];
    [self performSegueWithIdentifier:@"ehrDetailsVC" sender: nil];
    //[self makeRequestForEHRDetails];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
#pragma mark - Custom AlertView
-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}
#pragma mark - Alertview Delegate methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 987){
        [self backBtnClicked:nil];
    }else if (alertView.tag == 111){
        //[self moveToLogin];
    }
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ehrDetailsVC"]) {
        EHRDetailsVc *controller = segue.destinationViewController;
        //controller.ehrDetailsArr = sender;
        controller.selectedEhrModel = selectedEhrModel;
        controller.titleStr = selectedEhrModel.ehrTitle;
        controller.patientId = self.patientId;
    }
}

@end
