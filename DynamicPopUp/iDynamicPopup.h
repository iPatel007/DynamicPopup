//
//  iDynamicPopup.h
//  DynamicPopUp
//
//  Created by iPatel on 5/27/16.
//  Copyright © 2016 iPatel. All rights reserved.
//

#import <UIKit/UIKit.h>


@class iDynamicPopup;  //define class, so protocol can see it's MyClass

@protocol iDynamicPopupDelegate <NSObject>   //define delegate protocol

@required  // Required method must need to imaplement in the defined class

@optional
-(void)getSelectedItemsIndex:(NSString *) strItemsIndex;

@end

@interface iDynamicPopup : UIView <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *listOfTitles;
    NSMutableArray *listOfSelectedItem;
    NSIndexPath *previousIndexPath;
    
    float POPUP_X;
}

@property (nonatomic, weak) id <iDynamicPopupDelegate> delegate;

@property (strong, nonatomic) NSString *strLanguageID;

//// PopupVuew Creation /////
@property (strong, nonatomic) UIView *dimView;
@property (strong, nonatomic) UIView *innerTransparentView;
@property (strong, nonatomic) UIView *mainPopupView;

@property (strong, nonatomic) UIImageView *imgViewHeaderBG;
@property (strong, nonatomic) UILabel *lblHeaderTitle;
@property (strong, nonatomic) UIButton *btnClose;

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIButton *btnApply;

////// Manage Popup ////
@property float dimViewAlpha;
@property float MAIN_HEADER;
@property CGFloat maxHeightOfPopup;
@property UIImage *imgCloseBtn;
@property UIImage *imgHeaderBG;
@property UIColor *topHeaderBGColor;
@property BOOL isHeaderBGColor;

@property BOOL isSingleSelection;

@property CGFloat tblCellHeight;
@property UIImage *imgRadio;
@property UIImage *imgActiveRadio;

- (void)openDynamicPopupView;
- (void)closeDynamicPopupView;

-(void) setupFrameBasedOnDeviceOrientation;

@end
