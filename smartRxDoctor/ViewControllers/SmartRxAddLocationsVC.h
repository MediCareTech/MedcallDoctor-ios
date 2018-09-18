//
//  SmartRxAddLocationsVC.h
//  SmartRx
//
//  Created by Gowtham on 14/06/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationDetailsResponseModel.h"

typedef NS_ENUM(NSUInteger, TableViewTtype) {
    CitiestableView,
    LocalityTableView,
};

@interface SmartRxAddLocationsVC : UIViewController<MBProgressHUDDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate>
@property(nonatomic,weak)  NSString *titleStr;
@property(nonatomic,strong)   NSString*fromControler;
@property(nonatomic,assign) TableViewTtype tableViewType;
@property(nonatomic,weak) IBOutlet UITextField *addressTypeTF;
@property(nonatomic,weak) IBOutlet UITextField *zipcodeTF;
@property(nonatomic,weak) IBOutlet UITextField *cityTF;
@property(nonatomic,weak) IBOutlet UITextField *addressTF;
@property(nonatomic,weak) IBOutlet UITextField *localityTF;
@property(nonatomic,weak) IBOutlet UITextField *zoneTF;
@property(nonatomic,weak) IBOutlet UIView *menuView;
@property(nonatomic,weak) IBOutlet UITableView *tableView;
@property(nonatomic,weak) IBOutlet UIButton *citiesBtn;
@property(nonatomic,weak) IBOutlet UIButton *localityBtn;
@property(nonatomic,weak) IBOutlet UIButton *zoneBtn;

@property(nonatomic,strong) LocationDetailsResponseModel *selectedLocationModel;
@property(nonatomic,strong) NSArray *citiesArray;
@property(nonatomic,strong) NSArray *localityArray;
@property(nonatomic,strong) NSArray *zoneArray;
@property(nonatomic,strong) NSArray *citiesMainArray;
@property(nonatomic,strong) NSArray *localityMainArray;

@property (strong, nonatomic) UIButton *currentButton;
@property (nonatomic, strong) UIToolbar *pickerToolbar;
@property (strong, nonatomic) UIView *actionSheet;
@property (retain, nonatomic) UIPickerView *citiesPicker;
@property (retain, nonatomic) UIPickerView *localityPicker;
@property (retain, nonatomic) UIPickerView *zonePicker;


@end
