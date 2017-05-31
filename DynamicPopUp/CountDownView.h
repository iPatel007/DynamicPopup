//
//  CountDownView.h
//  Ticket Alert
//
//  Created by iPatel on 8/9/16.
//  Copyright © 2016 iPatel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CountDownView : UIView

@property (nonatomic, strong) IBOutlet UILabel *lblHours;
@property (nonatomic, strong) IBOutlet UILabel *lblMinutes;
@property (nonatomic, strong) IBOutlet UILabel *lblSecounds;

@property (nonatomic, strong) IBOutlet UIButton *btnChangeTimer;

@end
