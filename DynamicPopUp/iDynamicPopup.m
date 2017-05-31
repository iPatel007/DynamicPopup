//
//  iDynamicPopup.m
//  DynamicPopUp
//
//  Created by iPatel on 5/27/16.
//  Copyright © 2016 iPatel. All rights reserved.
//

#import "iDynamicPopup.h"
#import "defines.h"

#define CLOSE_BTN_HEIGHT (IS_IPHONE ? 46 : 50)
#define POPUP_HEADER_HEIGHT (IS_IPHONE ? 40 : 70)
#define APPLAY_BTN_HEIGHT (IS_IPHONE ? 34 : 45)

@implementation iDynamicPopup


#pragma mark - DrawRect Methods -

- (void)drawRect:(CGRect)rect
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    _MAIN_HEADER = (IS_IPHONE ? 64 : 88);
    POPUP_X = (IS_IPHONE ? (IS_IPHONE_6 ? 35 : (IS_IPHONE_6P ? 50 : 20)) : 100);
    _tblCellHeight = (IS_IPHONE ? 40 : 60);
    _imgRadio = (IS_IPHONE ? [UIImage imageNamed:@"radio.png"] : [UIImage imageNamed:@"radio_iPad.png"]);
    _imgActiveRadio = (IS_IPHONE ? [UIImage imageNamed:@"radio-active.png"] : [UIImage imageNamed:@"radio-active_iPad.png"]);
    _maxHeightOfPopup = 480;
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    
    listOfTitles = [[NSMutableArray alloc] init];
    listOfSelectedItem = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < 20; i ++)
    {
        [listOfTitles addObject:[NSString stringWithFormat:@"Item %d", i]];
        [listOfSelectedItem addObject:[NSNumber numberWithInteger:0]];
    }
    
    if(_dimViewAlpha == 0)
        _dimViewAlpha = 0.6;
    
    if(_dimView)
    {
        for(UIView *subView in _dimView.subviews)
            [subView removeFromSuperview];
    }
    
    _dimView = [[UIView alloc] init];
    _dimView.frame = [UIScreen mainScreen].bounds;
    _dimView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:_dimViewAlpha];
    [self addSubview:_dimView];
    
    float maxPopupHeight = _dimView.frame.size.height - ((_MAIN_HEADER*2) + 50);
    float actualPopupHeight = (listOfTitles.count * _tblCellHeight) + POPUP_HEADER_HEIGHT + CLOSE_BTN_HEIGHT + APPLAY_BTN_HEIGHT + 11;
    BOOL isHeightMax = NO;
    if(actualPopupHeight > maxPopupHeight)
    {
        actualPopupHeight = maxPopupHeight;
        isHeightMax = YES;
    }
    _innerTransparentView = [[UIView alloc] init];
    _innerTransparentView.frame = CGRectMake(_dimView.frame.origin.x, _MAIN_HEADER + 50, _dimView.frame.size.width, actualPopupHeight);
    _innerTransparentView.backgroundColor = [UIColor clearColor];
    _innerTransparentView.clipsToBounds = YES;
    [_dimView addSubview:_innerTransparentView];
    
    _mainPopupView = [[UIView alloc] init];
    _mainPopupView.frame = CGRectMake(POPUP_X, CLOSE_BTN_HEIGHT/2 , _dimView.frame.size.width - (POPUP_X * 2), _innerTransparentView.frame.size.height- 34.5);
    _mainPopupView.backgroundColor = [UIColor whiteColor];
    _mainPopupView.clipsToBounds = YES;
    [_innerTransparentView addSubview:_mainPopupView];
        
    _btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    if([_strLanguageID intValue] == 1)
        _btnClose.frame = CGRectMake((_mainPopupView.frame.origin.x + _mainPopupView.frame.size.width) - (CLOSE_BTN_HEIGHT/2), _mainPopupView.frame.origin.y-(CLOSE_BTN_HEIGHT/2), CLOSE_BTN_HEIGHT, CLOSE_BTN_HEIGHT);
    else
        _btnClose.frame = CGRectMake(_mainPopupView.frame.origin.x - (CLOSE_BTN_HEIGHT/2), _mainPopupView.frame.origin.y-(CLOSE_BTN_HEIGHT/2), CLOSE_BTN_HEIGHT, CLOSE_BTN_HEIGHT);
    
    if(!_imgCloseBtn)
        _imgCloseBtn = (IS_IPHONE ? [UIImage imageNamed:@"close.png"] : [UIImage imageNamed:@"close_iPad.png"]);
    
    [_btnClose setImage:_imgCloseBtn forState:UIControlStateNormal];
    _btnClose.backgroundColor = [UIColor clearColor];
    [_btnClose addTarget:self action:@selector(clickOnBtnClose:) forControlEvents:UIControlEventTouchUpInside];
    [_innerTransparentView addSubview:_btnClose];
    
    _imgViewHeaderBG = [[UIImageView alloc] init];
    _imgViewHeaderBG.frame = CGRectMake(0, 0, _mainPopupView.frame.size.width, POPUP_HEADER_HEIGHT);
    if(_isHeaderBGColor)
    {
        if(!_topHeaderBGColor)
            _topHeaderBGColor = [UIColor grayColor];
        _imgViewHeaderBG.backgroundColor = _topHeaderBGColor;
    }
    else
    {
        if(!_imgHeaderBG)
            _imgHeaderBG = [UIImage imageNamed:@"toHeaderBG.jpg"];
        _imgViewHeaderBG.image = _imgHeaderBG;
    }
    [_mainPopupView addSubview:_imgViewHeaderBG];
        
    _lblHeaderTitle = [[UILabel alloc] init];
    _lblHeaderTitle.frame = CGRectMake(0, 8, _mainPopupView.frame.size.width, _imgViewHeaderBG.frame.size.height - 16);
    _lblHeaderTitle.font = (IS_IPHONE ? [UIFont fontWithName:@"Verdana" size:16] : [UIFont fontWithName:@"Verdana" size:21]);
    _lblHeaderTitle.text = @"Display Popup";
    _lblHeaderTitle.textColor = [UIColor whiteColor];
    _lblHeaderTitle.textAlignment = NSTextAlignmentCenter;
    [_mainPopupView addSubview:_lblHeaderTitle];
    
    _tableView = [[UITableView alloc] init];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    if(isHeightMax)
    {
        int staticRow = 0;
        if(IS_IPHONE)
        {
            staticRow = 6;
            if(IS_IPHONE_4_OR_LESS)
                staticRow = 4;
            else if (IS_IPHONE_6)
                staticRow = 8;
            else if (IS_IPHONE_6P)
                staticRow = 10;
        }
        else
        {
            staticRow = 8;
        }
        
        _tableView.scrollEnabled = YES;
        _tableView.frame = CGRectMake(0, _imgViewHeaderBG.frame.size.height, _mainPopupView.frame.size.width, staticRow * _tblCellHeight);
    }
    else
    {
        _tableView.scrollEnabled = NO;
        _tableView.frame = CGRectMake(0, _imgViewHeaderBG.frame.size.height, _mainPopupView.frame.size.width, listOfTitles.count * _tblCellHeight);
    }
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.tableFooterView = [[UIView alloc] init];
    [_mainPopupView addSubview:_tableView];
    
    _btnApply = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnApply.frame = CGRectMake((_mainPopupView.frame.size.width- (_mainPopupView.frame.size.width/1.5))/2, _tableView.frame.size.height + _tableView.frame.origin.y + (CLOSE_BTN_HEIGHT/2), _mainPopupView.frame.size.width/1.5, APPLAY_BTN_HEIGHT);
    [_btnApply addTarget:self action:@selector(clickOnButtonApplye:) forControlEvents:UIControlEventTouchUpInside];
    _btnApply.backgroundColor = [UIColor redColor];
    [_btnApply setTitle:@"Apply" forState:UIControlStateNormal];
    if (IS_IPHONE)
        _btnApply.titleLabel.font = [UIFont fontWithName:@"Verdana" size:16];
    else
        _btnApply.titleLabel.font = [UIFont fontWithName:@"Verdana" size:21];
    
    [_mainPopupView addSubview:_btnApply];
    
    _mainPopupView.frame = CGRectMake(POPUP_X, 23 , _dimView.frame.size.width - (POPUP_X*2), _btnApply.frame.origin.y + _btnApply.frame.size.height + 11);
    _innerTransparentView.frame = CGRectMake(_dimView.frame.origin.x, (_dimView.frame.size.height+_MAIN_HEADER - (_mainPopupView.frame.origin.y + _mainPopupView.frame.size.height + 5))/2 , _dimView.frame.size.width, _mainPopupView.frame.origin.y + _mainPopupView.frame.size.height + 5);
    
    self.hidden = YES;
}

#pragma mark - UITableView Datasource Methods -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return listOfTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    UILabel *lblTitle;
    UIButton *btnRadio;
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = nil;
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        lblTitle = [[UILabel alloc] init];
        lblTitle.tag = 101;
        [cell.contentView addSubview:lblTitle];

        btnRadio = [UIButton buttonWithType:UIButtonTypeCustom];
        btnRadio.tag = 102;
        [cell.contentView addSubview:btnRadio];
    }
    
    lblTitle = (UILabel *)[cell viewWithTag:101];
    if([_strLanguageID intValue] == 1)
    {
        if(IS_IPHONE)
        {
            lblTitle.frame = CGRectMake(10, (_tblCellHeight-21)/2, _mainPopupView.frame.size.width - (_tblCellHeight + 10), 21);
            lblTitle.textAlignment = NSTextAlignmentLeft;
            [lblTitle setFont:[UIFont fontWithName:@"Verdana" size:12]];
        }
        else
        {
            lblTitle.frame = CGRectMake(15, (_tblCellHeight-40)/2, _mainPopupView.frame.size.width - 70, 40);
            lblTitle.textAlignment = NSTextAlignmentLeft;
            [lblTitle setFont:[UIFont fontWithName:@"Verdana" size:15]];
        }
    }
    else
    {
        if(IS_IPHONE)
        {
            lblTitle.frame = CGRectMake(_tblCellHeight, (_tblCellHeight-21)/2, _mainPopupView.frame.size.width - (_tblCellHeight + 10), 21);
            lblTitle.textAlignment = NSTextAlignmentRight;
            [lblTitle setFont:[UIFont fontWithName:@"Verdana" size:13]];
        }
        else
        {
            lblTitle.frame = CGRectMake(_tblCellHeight, (_tblCellHeight-40)/2, _mainPopupView.frame.size.width - (_tblCellHeight + 15), 40);
            lblTitle.textAlignment = NSTextAlignmentRight;
            [lblTitle setFont:[UIFont fontWithName:@"Verdana" size:18]];
        }
    }
    
    
    lblTitle.textColor = [UIColor colorWithRed:(78/255.f) green:(82/255.f) blue:(89/255.f) alpha:1.0f];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    lblTitle.text = [listOfTitles objectAtIndex:indexPath.row];
    
    btnRadio = (UIButton *)[cell viewWithTag:102];
    if([_strLanguageID intValue] == 1)
    {
        if(IS_IPHONE)
            btnRadio.frame = CGRectMake(_mainPopupView.frame.size.width - _tblCellHeight, 0, _tblCellHeight, _tblCellHeight);
        else
            btnRadio.frame = CGRectMake(_mainPopupView.frame.size.width - _tblCellHeight, 0, _tblCellHeight, _tblCellHeight);
    }
    else
        btnRadio.frame = CGRectMake(0, 0, _tblCellHeight, _tblCellHeight);

    [btnRadio setImage:_imgRadio forState:UIControlStateNormal];
    btnRadio.backgroundColor = [UIColor clearColor];
    [btnRadio addTarget:self action:@selector(clickOnBtnRadio:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _tblCellHeight;
}

#pragma mark - UITableView Delegate Methods -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    UIButton *btnRadio = (UIButton *)[cell viewWithTag:102];
    
    if(_isSingleSelection)
    {
        [btnRadio setImage:_imgActiveRadio forState:UIControlStateNormal];
        [listOfSelectedItem replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithInteger:1]];
        if(previousIndexPath && ![previousIndexPath isEqual:indexPath])
        {
            UITableViewCell *cell = (UITableViewCell *)[_tableView cellForRowAtIndexPath:previousIndexPath];
            UIButton *btnRadioPrev = (UIButton *)[cell viewWithTag:102];
            [btnRadioPrev setImage:_imgRadio forState:UIControlStateNormal];
            [listOfSelectedItem replaceObjectAtIndex:previousIndexPath.row withObject:[NSNumber numberWithInteger:0]];
            previousIndexPath = nil;
        }
        previousIndexPath = indexPath;
    }
    else
    {
        if([[listOfSelectedItem objectAtIndex:indexPath.row] intValue] == 1)
        {
            [btnRadio setImage:_imgRadio forState:UIControlStateNormal];
            [listOfSelectedItem replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithInteger:0]];
        }
        else
        {
            [btnRadio setImage:_imgActiveRadio forState:UIControlStateNormal];
            [listOfSelectedItem replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithInteger:1]];
        }
    }
    
    if([self.delegate respondsToSelector:@selector(getSelectedItemsIndex:)])
        [self.delegate getSelectedItemsIndex:[NSString stringWithFormat:@"%d", (int)indexPath.row]];

}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    UIButton *btnRadio = (UIButton *)[cell viewWithTag:102];
    [btnRadio setImage:_imgRadio forState:UIControlStateNormal];
    
    [listOfSelectedItem replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithInteger:0]];
}

#pragma mark - UIButton Methods -

-(void) clickOnBtnRadio:(UIButton *) sender
{
    NSString *strSeleItems = @"";
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:buttonPosition];
    UITableViewCell *cell = (UITableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
    UIButton *btnRadio = (UIButton *)[cell viewWithTag:102];

    if(_isSingleSelection)
    {
        if(previousIndexPath && ![previousIndexPath isEqual:indexPath])
        {
            UITableViewCell *cell = (UITableViewCell *)[_tableView cellForRowAtIndexPath:previousIndexPath];
            UIButton *btnRadioPrev = (UIButton *)[cell viewWithTag:102];
            [btnRadioPrev setImage:_imgRadio forState:UIControlStateNormal];
            [listOfSelectedItem replaceObjectAtIndex:previousIndexPath.row withObject:[NSNumber numberWithInteger:0]];
            previousIndexPath = nil;
            
            [btnRadio setImage:_imgActiveRadio forState:UIControlStateNormal];
            [listOfSelectedItem replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithInteger:1]];
        }
        else
        {
            [btnRadio setImage:_imgActiveRadio forState:UIControlStateNormal];
            [listOfSelectedItem replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithInteger:1]];
        }
        strSeleItems = [NSString stringWithFormat:@"%d", (int)indexPath.row];
        previousIndexPath = indexPath;
    }
    else
    {
        if([[listOfSelectedItem objectAtIndex:indexPath.row] intValue] == 1)
        {
            [btnRadio setImage:_imgRadio forState:UIControlStateNormal];
            [listOfSelectedItem replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithInteger:0]];
        }
        else
        {
            [btnRadio setImage:_imgActiveRadio forState:UIControlStateNormal];
            [listOfSelectedItem replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithInteger:1]];
        }
        
        NSArray *states = listOfTitles;
        NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:states];
        NSSet *uniqueStates = [orderedSet set];
        NSLog(@"%@", uniqueStates);
    }
    
    if([self.delegate respondsToSelector:@selector(getSelectedItemsIndex:)])
        [self.delegate getSelectedItemsIndex:strSeleItems];

}

-(void) clickOnBtnClose:(UIButton *) sender
{
    [self closeDynamicPopupView];
}

-(void) clickOnButtonApplye:(UIButton *) sender
{
    [self closeDynamicPopupView];
}

#pragma mark - Popup Animation Methods -

- (void)openDynamicPopupView
{
    self.hidden = NO;
    _dimView.hidden = NO;
    _innerTransparentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
    [UIView animateWithDuration:0.3/1.5 animations:^{
        _innerTransparentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/2 animations:^{
            _innerTransparentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2 animations:^{
                _innerTransparentView.transform = CGAffineTransformIdentity;
            }];
        }];
    }];
}

- (void)closeDynamicPopupView
{
    _innerTransparentView.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:0.3/1.5 animations:^{
        _innerTransparentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/2 animations:^{
            _innerTransparentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
        }completion:^(BOOL finished) {
            _dimView.hidden = YES;
            self.hidden = YES;
            
            if(previousIndexPath)
            {
                UITableViewCell *cell = (UITableViewCell *)[_tableView cellForRowAtIndexPath:previousIndexPath];
                UIButton *btnRadioPrev = (UIButton *)[cell viewWithTag:102];
                [btnRadioPrev setImage:_imgRadio forState:UIControlStateNormal];
                [listOfSelectedItem replaceObjectAtIndex:previousIndexPath.row withObject:[NSNumber numberWithInteger:0]];
                previousIndexPath = nil;
            }
            
        }];
    }];
}

-(void) setupFrameBasedOnDeviceOrientation
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    NSLog(@"Orien %ld", (long)orientation);
    if(orientation == 1 || orientation == 2)
    {
        _MAIN_HEADER = (IS_IPHONE ? 64 : 88);
        POPUP_X = (IS_IPHONE ? (IS_IPHONE_6 ? 35 : (IS_IPHONE_6P ? 50 : 20)) : 100);
         self.frame = [UIScreen mainScreen].bounds;
    }
    else
    {
        _MAIN_HEADER = (IS_IPHONE ? 35 : 64);
        POPUP_X = (IS_IPHONE ? (IS_IPHONE_6 ? 115 : (IS_IPHONE_6P ? 160 : 80)) : 100);
         self.frame = [UIScreen mainScreen].bounds;
    }
    
    _dimView.frame = [UIScreen mainScreen].bounds;
    
    float maxPopupHeight = _dimView.frame.size.height - ((_MAIN_HEADER*2) + 50);
    float actualPopupHeight = (listOfTitles.count * _tblCellHeight) + POPUP_HEADER_HEIGHT + CLOSE_BTN_HEIGHT + APPLAY_BTN_HEIGHT + 11;
    BOOL isHeightMax = NO;
    if(actualPopupHeight > maxPopupHeight)
    {
        actualPopupHeight = maxPopupHeight;
        isHeightMax = YES;
    }
    
    _innerTransparentView.frame = CGRectMake(_dimView.frame.origin.x, _MAIN_HEADER + 50, _dimView.frame.size.width, actualPopupHeight);
    _mainPopupView.frame = CGRectMake(POPUP_X, CLOSE_BTN_HEIGHT/2 , _dimView.frame.size.width - (POPUP_X *2), _innerTransparentView.frame.size.height- 34.5);
    if([_strLanguageID intValue] == 1)
        _btnClose.frame = CGRectMake((_mainPopupView.frame.origin.x + _mainPopupView.frame.size.width) - (CLOSE_BTN_HEIGHT/2), _mainPopupView.frame.origin.y-(CLOSE_BTN_HEIGHT/2), CLOSE_BTN_HEIGHT, CLOSE_BTN_HEIGHT);
    else
        _btnClose.frame = CGRectMake(_mainPopupView.frame.origin.x - (CLOSE_BTN_HEIGHT/2), _mainPopupView.frame.origin.y-(CLOSE_BTN_HEIGHT/2), CLOSE_BTN_HEIGHT, CLOSE_BTN_HEIGHT);
    _imgViewHeaderBG.frame = CGRectMake(0, 0, _mainPopupView.frame.size.width, POPUP_HEADER_HEIGHT);
    _lblHeaderTitle.frame = CGRectMake(0, 8, _mainPopupView.frame.size.width, _imgViewHeaderBG.frame.size.height - 16);
    if(isHeightMax)
    {
        int staticRow = 0;
        if(orientation == 1 || orientation == 2)
        {
            if(IS_IPHONE)
            {
                staticRow = 6;
                if(IS_IPHONE_4_OR_LESS)
                    staticRow = 4;
                else if (IS_IPHONE_6)
                    staticRow = 8;
                else if (IS_IPHONE_6P)
                    staticRow = 4;
            }
            else
                staticRow = 10;
        }
        else
        {
            if(IS_IPHONE)
            {
                staticRow = 3;
                if (IS_IPHONE_6 || IS_IPHONE_6P)
                    staticRow = 4;
            }
            else
                staticRow = 6;
        }
        
        _tableView.scrollEnabled = YES;
        _tableView.frame = CGRectMake(0, _imgViewHeaderBG.frame.size.height, _mainPopupView.frame.size.width, staticRow * _tblCellHeight);
    }
    else
    {
        _tableView.scrollEnabled = NO;
        _tableView.frame = CGRectMake(0, _imgViewHeaderBG.frame.size.height, _mainPopupView.frame.size.width, listOfTitles.count * _tblCellHeight);
    }
    _btnApply.frame = CGRectMake((_mainPopupView.frame.size.width- (_mainPopupView.frame.size.width/1.5))/2, _tableView.frame.size.height + _tableView.frame.origin.y + (CLOSE_BTN_HEIGHT/2), _mainPopupView.frame.size.width/1.5, APPLAY_BTN_HEIGHT);
    _mainPopupView.frame = CGRectMake(POPUP_X, 23 , _dimView.frame.size.width - (POPUP_X * 2), _btnApply.frame.origin.y + _btnApply.frame.size.height + 11);
    _innerTransparentView.frame = CGRectMake(_dimView.frame.origin.x, (_dimView.frame.size.height+_MAIN_HEADER - (_mainPopupView.frame.origin.y + _mainPopupView.frame.size.height + 5))/2 , _dimView.frame.size.width, _mainPopupView.frame.origin.y + _mainPopupView.frame.size.height + 5);
    
    [_tableView reloadData];
}


-(void) layoutSubviews
{
    [super layoutSubviews];
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    NSLog(@"Orien %ld", (long)orientation);
    
    [self setupFrameBasedOnDeviceOrientation];

}


@end
