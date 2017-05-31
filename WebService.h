//
//  webService.h
//  AbijjaNights
//
//  Created by iPatel Macmini on 11/07/13.
//  Copyright (c) 2013 iPatel Macmini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol WebServiceDelegate;

@interface WebService : NSObject
{
    id<WebServiceDelegate>_delegate;
}



@property(nonatomic,strong)id<WebServiceDelegate>_delegate;

+(WebService*) WebServiceClass;
-(void)callWebService:(NSString *)urlString dictionaryWithData:(NSDictionary *) dicOfData withType:(NSString *) type;

@end


@protocol WebServiceDelegate <NSObject>

@optional
-(void)webServiceResponce:(NSString*)srtResponce;
-(void)webServiceFailure;

@end


