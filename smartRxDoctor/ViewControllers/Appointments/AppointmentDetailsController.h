//
//  AppointmentDetailsController.h
//  smartRxDoctor
//
//  Created by Gowtham on 28/09/17.
//  Copyright © 2017 Anil Kumar. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "HMSegmentedControl.h"
#import "SmartRxeConsultReportCell.h"
#import "SmartRxSuggesstionCell.h"
#import "SmartRxeConsultRequestCell.h"
#import "BookingItemResponseModel.h"
#import "LocationsModel.h"
@interface AppointmentDetailsController : UIViewController<UITextViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,MBProgressHUDDelegate,UITableViewDataSource,UITableViewDelegate,loginDelegate,UIAlertViewDelegate,ImageSelected,UIGestureRecognizerDelegate,UIScrollViewDelegate, UIGestureRecognizerDelegate,UIDocumentMenuDelegate,UIDocumentPickerDelegate>

@property(nonatomic,strong) BookingItemResponseModel *selectedModel;
@property (strong, nonatomic) NSString *locationName;
@property (strong, nonatomic) LocationsModel *selectedLocation;

@property (strong, nonatomic) NSMutableDictionary *dictResponse;
@property (weak, nonatomic) IBOutlet UILabel *docName;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UILabel *eConsultDateTime;
@property (weak, nonatomic) IBOutlet UIImageView *eConsultStatusImage;
@property (weak, nonatomic) IBOutlet UILabel *statusLbl;
@property (weak, nonatomic) IBOutlet UILabel *econsultMethodLbl;
@property (weak, nonatomic) IBOutlet UILabel *paymentStatus;
@property (retain, nonatomic) UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIScrollView *suggestionScroll;
@property (retain, nonatomic) IBOutlet UIScrollView *symptomScroll;
@property (weak, nonatomic) IBOutlet UIView *segmentView;
@property (weak, nonatomic) IBOutlet UIView *videoConsultView;
@property (nonatomic, strong) HMSegmentedControl *segmentedControl4;

@property (strong, nonatomic) UIView *currentView;
@property (retain, nonatomic) NSString *publisherName;

@property (weak, nonatomic) IBOutlet UIView *symptomsViewEdit;
@property (weak, nonatomic) IBOutlet UIButton *symptomsContent;
@property (weak, nonatomic) IBOutlet UITextView *symptomsContentLabel;
@property (nonatomic, strong) NSString *pdfPath;
@property (assign, nonatomic) NSString *strTitle;

@property (weak, nonatomic) IBOutlet UIView *suggestionViewEdit;
@property (weak, nonatomic) IBOutlet UIButton *suggestionContent;
@property (weak, nonatomic) IBOutlet UILabel *suggestionContentLabel;
@property (weak, nonatomic) IBOutlet UITableView *suggestionContentTable;

@property (weak, nonatomic) IBOutlet UIView *reportViewEdit;
@property (weak, nonatomic) IBOutlet UIButton *reportContent;
@property (retain, nonatomic) IBOutlet UIScrollView *reportScroll;
@property (weak, nonatomic) IBOutlet UITableView *reportContentTable;

@property (weak, nonatomic) IBOutlet UIView *requestViewEdit;
@property (weak, nonatomic) IBOutlet UIButton *requestContent;
@property (weak, nonatomic) IBOutlet UITableView *requestContentTable;

@property (weak, nonatomic) IBOutlet UIView *familyViewEdit;
@property (weak, nonatomic) IBOutlet UITextView *familyContentLabel;
@property (weak, nonatomic) IBOutlet UIButton *familyContent;

@property (weak, nonatomic) IBOutlet UIView *medicationViewEdit;
@property(nonatomic,weak) IBOutlet UITableView *medicationTable;
@property (weak, nonatomic) IBOutlet UILabel *medicationErrorLbl;

@property (weak, nonatomic) IBOutlet UIView *updateView;
@property (weak, nonatomic) IBOutlet UILabel *updateLbl;
@property (weak, nonatomic) IBOutlet UIButton *updateBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UITextView *updateTextView;
@property (weak, nonatomic) IBOutlet UILabel *updateViewTitle;
@property (strong, nonatomic) IBOutlet UIImageView *imgViwPhoto;

@property (strong, nonatomic) NSArray *arrayReportFiles;
@property (strong, nonatomic) NSArray *arrayDoctorSuggestionFiles;
@property (strong, nonatomic) NSArray *arrayData;
@property (strong, nonatomic) NSMutableArray *arrayRequestData;
@property (strong, nonatomic) NSArray *medicationArray;

@end
