//
//  EHRDetailsVc.m
//  smartRxDoctor
//
//  Created by Gowtham on 23/01/18.
//  Copyright © 2018 Anil Kumar. All rights reserved.
//

#import "EHRDetailsVc.h"
#import "SmartRxEhrDetailsCell.h"
#import "EhrDetailsResponseModel.h"
#import "SmartRxDashBoardVC.h"

@interface EHRDetailsVc ()
{
    MBProgressHUD *HUD;

}
@end

@implementation EHRDetailsVc
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
    [[SmartRxCommonClass sharedManager] setNavigationTitle:self.titleStr controler:self];
    self.noAppsLbl.hidden = YES;
    [self.tableView setTableFooterView:[UIView new]];
    
    [self navigationBackButton];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self makeRequestForEHRDetails];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
#pragma mark - Request Methods

-(void)makeRequestForEHRDetails{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *doctorId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
    NSString *url=[NSString stringWithFormat:@"%@%@/%@/member/%@",WB_BASEURL,@"ehr/records",_selectedEhrModel.ehrType,self.patientId];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:nil method:@"GET" setHeader:YES  successHandler:^(id response) {
        NSLog(@"ehr response:%@",response);
        if (response == nil)
        {
            
            
            [HUD hide:YES];
            [HUD removeFromSuperview];
            [self customAlertView:@"" Message:@"Internal server error" tag:0];
        }  else {
           
            

            dispatch_async(dispatch_get_main_queue(),^{
                [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                
                NSMutableArray *tempArray = [[NSMutableArray alloc]init];
                
                for (NSDictionary *dict  in response) {
                    //if ([dict[@"_matchingData"][@"a_medication"][@"medication_name"] isKindOfClass:[NSString class]]) {
                    [tempArray addObject:[self dataParsing:dict]];
                    // }
                }
                self.ehrDetailsArr = [tempArray copy];
                if (self.ehrDetailsArr.count < 1 ) {
                    self.tableView.hidden  = YES;
                    self.noAppsLbl.hidden = NO;
                    self.noAppsLbl.text = [NSString stringWithFormat:@"No %@ are added",self.titleStr];
                } else {
                    self.tableView.hidden  = NO;
                    
                    [self.tableView reloadData];
                }
                // [self performSegueWithIdentifier:@"ehrDetailsVC" sender: self.ehrDetailsArray];
                
            });
            
        }
        
        
    }failureHandler:^(id response) {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    }];
    
    
}
-(EhrDetailsResponseModel *)dataParsing:(NSDictionary *)dict{
    EhrDetailsResponseModel *model = [[EhrDetailsResponseModel alloc]init];
    
    if ([_selectedEhrModel.ehrType isEqualToString:@"r_medication"]) {
        if ([dict[@"a_medication_name"] isKindOfClass:[NSString class]]) {
            
            // NSString *tempStr = dict[@"_matchingData"][@"a_medication"][@"medication_name"];
            NSString *tempStr = dict[@"a_medication_name"];
            NSString *startDate ;
            if ([dict[@"started_at"] isKindOfClass:[NSString class]]) {
                startDate  = [self dateConvertor:dict[@"started_at"]];
            }
            
            NSString *endDate = @"";
            if ([dict[@"ended_at"] isKindOfClass:[NSString class]]) {
                endDate = [endDate stringByAppendingString:[NSString stringWithFormat:@"%@",[self dateConvertor:dict[@"ended_at"]]]];
                //endDate = [self dateConvertor:dict[@"ended_at"]];
            }
            tempStr = [tempStr stringByAppendingString:[NSString stringWithFormat:@"- quantity:"]];
            if ([dict[@"a_medication_dosage"] isKindOfClass:[NSString class]]) {
                tempStr = [tempStr stringByAppendingString:dict[@"a_medication_dosage"]];
            }
            if ([dict[@"a_medication_consumption_pattern"] isKindOfClass:[NSString class]]) {
                tempStr = [tempStr stringByAppendingString:[NSString stringWithFormat:@"(%@)",dict[@"a_medication_consumption_pattern"]]];
            }
            
            
            if (![dict[@"number_of_days"] isEqual:[NSNull null]] ) {
                tempStr = [tempStr stringByAppendingString:[NSString stringWithFormat:@" - days:%@",dict[@"number_of_days"]]];
            }
            if (startDate != nil && ![endDate isEqualToString:@""]) {
                tempStr = [tempStr stringByAppendingString:[NSString stringWithFormat:@" From %@ to %@",startDate,endDate]];
            }else if(startDate != nil){
                tempStr = [tempStr stringByAppendingString:[NSString stringWithFormat:@" From %@",startDate]];
                
            }else if(![endDate isEqualToString:@""]){
                tempStr = [tempStr stringByAppendingString:[NSString stringWithFormat:@" to %@",endDate]];
                
            }
            
            //            if (startDate != nil ) {
            //            tempStr = [tempStr stringByAppendingString:[NSString stringWithFormat:@" - quantity:%@(%@) From %@ %@",dict[@"a_medication_dosage"],dict[@"a_medication_consumption_pattern"],startDate,endDate]];
            //            } else {
            //            tempStr = [tempStr stringByAppendingString:[NSString stringWithFormat:@" - quantity:%@(%@) ",dict[@"a_medication_dosage"],dict[@"a_medication_consumption_pattern"]]];
            //                }
            
            
            model.ehrProblem = tempStr;
            
            NSString *dateStr = [NSString stringWithFormat:@"on %@",[self dateConvertor:dict[@"created_date"]]];
            model.date = dateStr;
            
            
            
        }
        
    } else  if ([_selectedEhrModel.ehrType isEqualToString:@"r_symptom"]){
        
        NSString *tempStr = [NSString stringWithFormat:@"%@", dict[@"a_symptom_name"]];
        if ([dict[@"observed_at"] isKindOfClass:[NSString class]]) {
            tempStr = [tempStr stringByAppendingString:[NSString stringWithFormat:@" since %@",[self dateConvertor:dict[@"observed_at"]]]];
            
        }
        model.ehrProblem = tempStr;
        model.date = [self dateConvertor:dict[@"created_date"]];
        
    }else  if ([_selectedEhrModel.ehrType isEqualToString:@"r_diagnosis"]){
        // NSString *tempStr = [NSString stringWithFormat:@"%@ since %@", dict[@"a_diagnosis_name"],[self dateConvertor:dict[@"observed_at"]]];
        NSString *tempStr = [NSString stringWithFormat:@"%@", dict[@"a_diagnosis_name"]];
        if ([dict[@"observed_at"] isKindOfClass:[NSString class]]) {
            tempStr = [tempStr stringByAppendingString:[NSString stringWithFormat:@" since %@",[self dateConvertor:dict[@"observed_at"]]]];
            
        }
        model.date = [self dateConvertor:dict[@"created_date"]];
        
        model.ehrProblem = tempStr;
        
    }else  if ([_selectedEhrModel.ehrType isEqualToString:@"r_allergy"]){
        NSString *alergyStr = dict[@"_matchingData"][@"a_allergen"][@"allergen_name"];
        NSString *alergyReaction = dict[@"_matchingData"][@"a_allergyreaction"][@"allergy_reaction_name"];
        NSString *tempStr = [NSString stringWithFormat:@"%@ - %@", alergyStr,alergyReaction];
        if ([dict[@"started_at"] isKindOfClass:[NSString class]]) {
            tempStr = [tempStr stringByAppendingString:[NSString stringWithFormat:@" since %@",[self dateConvertor:dict[@"started_at"]]]];
        }
        if ([dict[@"ended_at"] isKindOfClass:[NSString class]]) {
            tempStr = [tempStr stringByAppendingString:[NSString stringWithFormat:@" to %@",[self dateConvertor:dict[@"ended_at"]]]];
            
        }
        model.ehrProblem = tempStr;
        model.date = [self dateConvertor:dict[@"created_date"]];
        
    }else  if ([_selectedEhrModel.ehrType isEqualToString:@"r_familyhistory"]){
        NSString *relationshipStr = dict[@"_matchingData"][@"a_relationship"][@"relationship_name"];
        NSString *ageStr = [NSString stringWithFormat:@"%@",dict[@"relationship_age"]];
        NSString *relationStatus ;
        if ([dict[@"alive"] integerValue] == 0) {
            relationStatus = @"not alive";
        } else {
            relationStatus = @"alive";
        }
        NSString *condition = dict[@"con_name"];
        NSString *tempStr;
        if ([ageStr isEqual:[NSNull null]]) {
            tempStr = [NSString stringWithFormat:@"%@ Age:%@ %@ - %@",relationshipStr,ageStr,relationStatus,condition];
        } else {
            tempStr = [NSString stringWithFormat:@"%@ %@ - %@",relationshipStr,relationStatus,condition];
        }
        //tempStr = [NSString stringWithFormat:@"%@ Age:%@ %@ - %@",relationshipStr,ageStr,relationStatus,condition];
        model.ehrProblem = tempStr;
        model.date = [self dateConvertor:dict[@"created_date"]];
        
    }else  if ([_selectedEhrModel.ehrType isEqualToString:@"r_healthissue"]){
        NSString *issueStr = dict[@"a_issue_name"];
        NSString *tempStrr = issueStr;
        if ([dict[@"started_at"] isKindOfClass:[NSString class]]) {
            tempStrr = [tempStrr stringByAppendingString:[NSString stringWithFormat:@" from %@",[self dateConvertor:dict[@"started_at"] ]]];
        }
        if ([dict[@"ended_at"] isKindOfClass:[NSString class]]) {
            tempStrr = [tempStrr stringByAppendingString:[NSString stringWithFormat:@" to %@",[self dateConvertor:dict[@"ended_at"]]]];
        }
        
        //        NSString *tempStr = [NSString stringWithFormat:@"%@ from %@", issueStr,[self dateConvertor:dict[@"started_at"]]];
        //        if ([dict[@"ended_at"] isKindOfClass:[NSString class]]) {
        //            tempStr = [tempStr stringByAppendingString:[NSString stringWithFormat:@" to %@",[self dateConvertor:dict[@"ended_at"]]]];
        //        }
        model.ehrProblem = tempStrr;
        model.date = [self dateConvertor:dict[@"created_date"]];
        
    }else  if ([_selectedEhrModel.ehrType isEqualToString:@"r_lifestyle"]){
        NSString *issueStr = dict[@"_matchingData"][@"a_lifestyle"][@"lifestyle_description"];
        
        NSString *tempStr = [NSString stringWithFormat:@"%@", issueStr];
        if ([dict[@"notes"] isKindOfClass:[NSString class]]) {
            if (![dict[@"notes"] isEqualToString:@""]) {
                tempStr = [tempStr stringByAppendingString:[NSString stringWithFormat:@" \n  %@",dict[@"notes"]]];
            }
            
        }
        model.ehrProblem = tempStr;
        model.date = [self dateConvertor:dict[@"created_date"]];
        
    }else  if ([_selectedEhrModel.ehrType isEqualToString:@"r_vaccination"]){
        NSString *issueStr = dict[@"_matchingData"][@"a_vaccinations"][@"vaccination_name"];
        
        NSString *tempStr = [NSString stringWithFormat:@"%@", issueStr];
        if ([dict[@"adminstered_at"] isKindOfClass:[NSString class]]) {
            
            tempStr = [tempStr stringByAppendingString:[NSString stringWithFormat:@" \n since %@",[self dateConvertor:dict[@"adminstered_at"]]]];
            
            
        }
        model.ehrProblem = tempStr;
        model.date = [self dateConvertor:dict[@"created_date"]];
        
    }
    
    return model;
}

-(NSString *)dateConvertor:(NSString *)dateStr{
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    // NSTimeZone *gmt = [NSTimeZone systemTimeZone];
    //[format setTimeZone:gmt];
    [format setDateFormat:@"yyyy-MM-dd'T'HH:mm:SS"];
    NSDate *date = [format dateFromString:dateStr];
    [format setDateFormat:@"dd MMM yyyy"];
    
    NSString *str = [format stringFromDate:date];
    return str;
    
}

#pragma mark - TableView Delegates N datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.ehrDetailsArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SmartRxEhrDetailsCell *cell= [tableView dequeueReusableCellWithIdentifier:@"EHRDetailCell"];
    EhrDetailsResponseModel *model = self.ehrDetailsArr[indexPath.row];
    cell.titleLbl.text = model.ehrProblem;
    cell.titleLbl.numberOfLines = 100;
    cell.dateLbl.text = model.date;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EhrDetailsResponseModel *model = self.ehrDetailsArr[indexPath.row];
    CGFloat cellHeight = [self estimatedHeight:model.ehrProblem];
    return cellHeight;
}
-(CGFloat)estimatedHeight:(NSString *)strToCalCulateHeight
{
    UILabel *lblHeight = [[UILabel alloc]initWithFrame:CGRectMake(8,16, 250,21)];
    lblHeight.text = strToCalCulateHeight;
    
    //[UIFont fontWithName:@"HelveticaNeue" size:15]
    lblHeight.font =  [UIFont systemFontOfSize:17];
    //    NSLog(@"The number of lines is : %d\n and the text length is: %d", [lblHeight numberOfLines], [strToCalCulateHeight length]);
    CGSize maximumLabelSize = CGSizeMake(self.view.frame.size.width-30,9999);
    CGSize expectedLabelSize;
    expectedLabelSize = [lblHeight.text  sizeWithFont:lblHeight.font constrainedToSize:maximumLabelSize lineBreakMode:lblHeight.lineBreakMode];
    CGFloat heightLbl=expectedLabelSize.height;
    
    heightLbl = heightLbl+ 60;
    
    return heightLbl;
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
