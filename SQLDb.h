
#import <Foundation/Foundation.h>
#import "sqlite3.h"

@interface SQLDb : NSObject
{
    sqlite3 *_database;
    NSString *savedDate;
}

@property (readwrite) sqlite3* _database;
@property (nonatomic, strong) NSString *savedDate;

+(SQLDb *) initEngine;
+ (SQLDb*) database ;
+(void)releaseEngine;
- (void) executeQuery:(NSString *)query;


-(void) insertBannerInTable:(NSMutableDictionary *) dicOfBanner;
-(void) insertPopularPlacesInTheTable:(NSMutableDictionary *) dicOfPlace;
-(void) insertBlockedUserJIDin_blockUserTableWhereJIDis:(NSString *) strJID andWithUser_id:(NSString *) strUserID;


-(void) updateUserImageURL:(NSString *)strTotalProduct ProductID:(NSString *) strProductID name:(NSString *)strUserName;



-(NSMutableArray *) getBannerFrom_bannerTable;
-(NSMutableArray *) getAllPopularPlacesWithAllVideos;
-(NSMutableArray *) getAllBlockedUserList;

-(NSMutableArray *)CheckIfUserExistInChatGroup :(NSString *) strJabberId;
-(NSMutableArray *)getAllUsersFromChatListing;
-(BOOL) check_Jabber_id_AlreadyExistIn_user_Group_ChatList:(NSString *) strJID;

-(void) insertUserInChatListTable:(NSString *)name andWithUser_Jid:(NSString *) strUserID imagedate:(NSData *)imgData isonline:(NSString *)is_online url:(NSString *)strImageURL;



-(void) updateOnlineUser:(NSString *)strTotalProduct ProductID:(NSString *) strProductID;
-(NSMutableArray *)getOnlyJIdFromList;

-(void) deleteAllDataFrom_Banner_Table;
-(void) deleteAllDataFrom_PopularPlaces_Table;
-(void) deleteAllDataFrom_Videos_Table;
-(void) deleteBlockedUserFrom_blockUserTableWhereUserIDis:(NSString *) strJID;

-(void) deleteAllDataFrom_user_Group_ChatList;
-(void) deleteAllDataFrom_blockUserTable;

@end
