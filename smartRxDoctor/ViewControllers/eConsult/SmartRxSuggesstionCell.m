//
//  SmartRxSuggesstionCell.m
//  SmartRx
//
//  Created by Manju Basha on 25/04/15.
//  Copyright (c) 2015 smartrx. All rights reserved.
//

#import "SmartRxSuggesstionCell.h"

@implementation SmartRxSuggesstionCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (void)setCellData:(NSDictionary *)arrAppDetails row:(NSInteger)rowIndex
{
    NSArray *arrImg = [[arrAppDetails objectForKey:@"content_images"] componentsSeparatedByString:@"patient/data/pat_uploaded_files/"];
    NSArray *underSplit = [[arrImg objectAtIndex:1] componentsSeparatedByString:@"_"];
    self.suggestionImageName.text = [underSplit objectAtIndex:1];//[NSString stringWithFormat:@"%@", [arrImg objectAtIndex:1]];
    self.downloadBtn.tag = rowIndex;
    self.viewBtn.tag = rowIndex;
}

- (IBAction)viewBtnClicked:(id)sender {
    
    NSArray *arrFileType = [NSArray arrayWithObjects:@"pdf", @"doc", @"docx", @"rtf", @"csv", @"text", @"xlsx",@"xlsm", @"xls", @"xlt", nil];
    NSArray *arrExtensionType = [[[self.arrImages objectAtIndex:((UIButton *)sender).tag] objectForKey:@"content_images"] componentsSeparatedByString:@"."];
    if ([arrExtensionType count] && [arrFileType containsObject:arrExtensionType[([arrExtensionType count]-1)]]) {
        [self.delegateImg openQlPreview:[[self.arrImages objectAtIndex:((UIButton *)sender).tag] objectForKey:@"content_images"]];
    }else
        [self.delegateImg ShowImageInMainView:[[self.arrImages objectAtIndex:((UIButton *)sender).tag] objectForKey:@"content_images"]];
}

- (IBAction)downloadBtnClicked:(id)sender
{
    NSArray *arrFileType = [NSArray arrayWithObjects:@"pdf", @"doc", @"docx", @"rtf", @"csv", @"text", @"xlsx",@"xlsm", @"xls", @"xlt", nil];
    NSArray *arrExtensionType = [[[self.arrImages objectAtIndex:((UIButton *)sender).tag] objectForKey:@"filelocation"] componentsSeparatedByString:@"."];
    if ([arrExtensionType count] && [arrFileType containsObject:arrExtensionType[([arrExtensionType count]-1)]]) {
        [self.delegateImg openQlPreview:[[self.arrImages objectAtIndex:((UIButton *)sender).tag] objectForKey:@"content_images"]];
    }else
        [self.delegateImg ShowImageInMainView:[[self.arrImages objectAtIndex:((UIButton *)sender).tag] objectForKey:@"content_images"]];}


@end
