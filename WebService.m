//
//  webService.m
//  AbijjaNights
//
//  Created by iPatel Macmini on 11/07/13.
//  Copyright (c) 2013 iPatel Macmini. All rights reserved.
//


#import "webService.h"
#import "AFHTTPRequestOperationManager.h"

@implementation WebService
@synthesize _delegate;

#pragma mark -
#pragma mark - Webservice Methods

+(WebService*)WebServiceClass
{
    WebService *webUrlObject;
    if (webUrlObject==nil)
        webUrlObject=[[WebService alloc] init];
    
    return webUrlObject;
}

-(void)callWebService:(NSString *)urlString dictionaryWithData:(NSMutableDictionary *) dicOfData withType:(NSString *) type
{
    NSLog(@"%@", type);
    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
    requestManager.responseSerializer = [AFHTTPResponseSerializer serializer];
   // requestManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    requestManager.requestSerializer.timeoutInterval = 500;
    NSMutableDictionary *params = dicOfData;
    if([type isEqualToString:@"POST"])
    {
        [requestManager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSString *returnString=[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
             NSString *returnString1=[returnString stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
             returnString1=[returnString1 stringByReplacingOccurrencesOfString:@"&amp" withString:@"&"];
             returnString1=[returnString1 stringByReplacingOccurrencesOfString:@"&#039;" withString:@"'"];
             returnString1=[returnString1 stringByReplacingOccurrencesOfString:@"&#034;" withString:@"\""];
             
             if ([_delegate respondsToSelector:@selector(webServiceResponce:)])
                 [_delegate webServiceResponce:returnString1];
         }
                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"Error: %@", error);
             [_delegate webServiceFailure];
         }];
    }
    else if ([type isEqualToString:@"SPECIAL"])
    {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        
        NSDictionary *params = dicOfData;
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSString *jsonString =  [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
             
             if ([_delegate respondsToSelector:@selector(webServiceResponce:)])
             {
                 [_delegate webServiceResponce:jsonString];
             }
         }
             failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"%@",[error description]);
             NSLog(@"Error: %@", error);
             [_delegate webServiceFailure];
         }];
    }
    else
    {
        [requestManager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSString *returnString=[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
             NSString *returnString1=[returnString stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
             returnString1=[returnString1 stringByReplacingOccurrencesOfString:@"&amp" withString:@"&"];
             returnString1=[returnString1 stringByReplacingOccurrencesOfString:@"&#039;" withString:@"'"];
             returnString1=[returnString1 stringByReplacingOccurrencesOfString:@"&#034;" withString:@"\""];
             
             if ([_delegate respondsToSelector:@selector(webServiceResponce:)])
                 [_delegate webServiceResponce:returnString1];
         }
                    failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"Error: %@", error);
             [_delegate webServiceFailure];
         }];
    }
    
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
}

@end
