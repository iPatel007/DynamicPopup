
#import "SQLDb.h"

@implementation SQLDb

@synthesize _database, savedDate;

static SQLDb* _database = nil;


#pragma mark -  Initialization Methods -

+ (SQLDb*)database
{
    if (_database == nil)
        _database = [[SQLDb alloc] init];
    
    return _database;
}

+(SQLDb *) initEngine
{
	if ( !_database )
	{
        NSString *databaseName = @"CheckedInDB.sqlite";
		[SQLDb createEditableCopyOfFileIfNeeded:databaseName];
		sqlite3 *db = nil;
    	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *path = [documentsDirectory stringByAppendingPathComponent:databaseName];
        NSLog(@"DB path - %@", path);
		const char* dbName = [path UTF8String];
		if ( sqlite3_open(dbName,&db) != SQLITE_OK )
		{
			NSException* initException;
			initException = [NSException exceptionWithName:@"SQL Exception" reason:@"Database Initialization Failed" userInfo:nil];
			@throw initException;
		}
        
		_database = [[self allocWithZone: NULL] init] ;
		_database._database = db;
	}
    
	return _database;
}

+ (void)createEditableCopyOfFileIfNeeded:(NSString *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:fileName];
    BOOL success = [fileManager fileExistsAtPath:writableDBPath];
    if (success)
		return;
	
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    
    NSLog(@"Database Path - %@", writableDBPath);
    if (!success)
        NSLog(@"Failed to create writable database file with message '%@'.", [error localizedDescription]);
}

-(void) executeQuery:(NSString *)query
{
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        char *selectQuery = sqlite3_mprintf([query UTF8String]);
        sqlite3_free(selectQuery);
        sqlite3_step(statement);
        sqlite3_finalize(statement);
    }
}

+(void) releaseEngine
{
	sqlite3_close(_database._database);
    _database._database = nil;
	_database = nil;
}


#pragma mark - Inser Places, Videos and Banners for Explore Screen -

-(void) insertBannerInTable:(NSMutableDictionary *) dicOfBanner
{
    int ret;
    const char *sql = "INSERT INTO `bannerTable` ('banner_id', 'banner_image', 'banner_type', 'banner_description', 'banner_link') VALUES (?, ?, ?, ?, ?);";
    
    sqlite3_stmt *insStmt = NULL;
    if ( !insStmt )
        if ( (ret = sqlite3_prepare_v2(_database, sql, -1, &insStmt, NULL)) != SQLITE_OK ) {
            
            NSLog(@"Proble to insert record in bannerTable");
        }
    
    // bind values
    
    sqlite3_bind_text(insStmt, 1, [[NSString stringWithFormat:@"%@", [dicOfBanner objectForKey:@"advertisement_id"]] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insStmt, 2, [[NSString stringWithFormat:@"%@", [dicOfBanner objectForKey:@"advertisement_image"]] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insStmt, 3, [[NSString stringWithFormat:@"%@", [dicOfBanner objectForKey:@"is_image_url"]] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insStmt, 4, [[NSString stringWithFormat:@"%@", [dicOfBanner objectForKey:@"advertisement_description"]] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insStmt, 5, [[NSString stringWithFormat:@"%@", [dicOfBanner objectForKey:@"advertisement_link"]] UTF8String], -1, SQLITE_TRANSIENT);
    
    NSMutableArray *arrForVideo = (NSMutableArray *)[dicOfBanner objectForKey:@"video_list"];
    if(arrForVideo.count > 0)
    {
        for (NSMutableDictionary *dictForVideo in arrForVideo)
            [self insertPopularPlacesInTheTable:dictForVideo];
    }
    
    if ((ret = sqlite3_step(insStmt)) != SQLITE_DONE) {NSLog(@"error while inserting data in 'bannerTable' table");}
    sqlite3_reset(insStmt);
}

-(void) insertPopularPlacesInTheTable:(NSMutableDictionary *) dicOfPlace
{
 
    int ret;
    const char *sql = "INSERT INTO `PopularPlacesTbl` ('place_id', 'place_name', 'address', 'total_peoples') VALUES (?, ?, ?, ?);";
    
    sqlite3_stmt *insStmt = NULL;
    if ( !insStmt )
        if ( (ret = sqlite3_prepare_v2(_database, sql, -1, &insStmt, NULL)) != SQLITE_OK ) {
            
            NSLog(@"Proble to insert record in PopularPlacesTbl");
        }
    
    // bind values
    
    sqlite3_bind_text(insStmt, 1, [[NSString stringWithFormat:@"%@", [dicOfPlace objectForKey:@"place_id"]] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insStmt, 2, [[NSString stringWithFormat:@"%@", [dicOfPlace objectForKey:@"place_name"]] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insStmt, 3, [[NSString stringWithFormat:@"%@", [dicOfPlace objectForKey:@"address"]] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insStmt, 4, [[NSString stringWithFormat:@"%@", [dicOfPlace objectForKey:@"total_peoples"]] UTF8String], -1, SQLITE_TRANSIENT);
    
    if ((ret = sqlite3_step(insStmt)) != SQLITE_DONE) {NSLog(@"error while inserting data in 'PopularPlacesTbl' table");}
    sqlite3_reset(insStmt);
    
    NSMutableArray *arrForVideo = (NSMutableArray *)[dicOfPlace objectForKey:@"video_list"];
    
    if(arrForVideo.count > 0)
        for (NSMutableDictionary *dictForVideo in arrForVideo)
            [self insertVideoForPopularPlaceInTheTable:dictForVideo WithPlaceID:[dicOfPlace objectForKey:@"place_id"]];
}

-(void) insertVideoForPopularPlaceInTheTable:(NSMutableDictionary *) dicOfVideos WithPlaceID:(NSString *) strPlaceID
{
    
    int ret;
    const char *sql = "INSERT INTO `palcevideoTbl` ('place_id', 'url_id', 'video_img', 'video_url') VALUES (?, ?, ?, ?);";
    
    sqlite3_stmt *insStmt = NULL;
    if ( !insStmt )
        if ( (ret = sqlite3_prepare_v2(_database, sql, -1, &insStmt, NULL)) != SQLITE_OK ) {
            
            NSLog(@"Proble to insert record in palcevideoTbl");
        }
    
    // bind values
    
    sqlite3_bind_text(insStmt, 1, [[NSString stringWithFormat:@"%@", strPlaceID] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insStmt, 2, [[NSString stringWithFormat:@"%@", [dicOfVideos objectForKey:@"url_id"]] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insStmt, 3, [[NSString stringWithFormat:@"%@", [dicOfVideos objectForKey:@"video_img"]] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insStmt, 4, [[NSString stringWithFormat:@"%@", [dicOfVideos objectForKey:@"video_url"]] UTF8String], -1, SQLITE_TRANSIENT);
    
    if ((ret = sqlite3_step(insStmt)) != SQLITE_DONE) {NSLog(@"error while inserting data in 'palcevideoTbl' table");}
    sqlite3_reset(insStmt);
}

-(void) insertBlockedUserJIDin_blockUserTableWhereJIDis:(NSString *) strJID andWithUser_id:(NSString *) strUserID
{
    if([self checkBlcoked_UserID_AlreadyExistOrNot:[NSString stringWithFormat:@"%@", strUserID]])
        return;
    
    int ret;
    const char *sql = "INSERT INTO `blockUserTable` ('blockJID', 'userid') VALUES (?, ?);";
    
    sqlite3_stmt *insStmt = NULL;
    if ( !insStmt )
        if ( (ret = sqlite3_prepare_v2(_database, sql, -1, &insStmt, NULL)) != SQLITE_OK ) {
            
            NSLog(@"Proble to insert record in blockUserTable");
        }
    
    // bind values
    
    sqlite3_bind_text(insStmt, 1, [[NSString stringWithFormat:@"%@", strJID] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insStmt, 2, [[NSString stringWithFormat:@"%@", strUserID] UTF8String], -1, SQLITE_TRANSIENT);
    
    if ((ret = sqlite3_step(insStmt)) != SQLITE_DONE) {NSLog(@"error while inserting data in 'blockUserTable' table");}
    sqlite3_reset(insStmt);
}

-(void) insertUserInChatListTable:(NSString *)name andWithUser_Jid:(NSString *) strUserID imagedate:(NSData *)imgData isonline:(NSString *)is_online url:(NSString *)strImageURL
{
    if([self check_Jabber_id_AlreadyExistIn_user_Group_ChatList:[NSString stringWithFormat:@"%@", strUserID]])
        return;
    
    int ret;
    const char *sql = "INSERT INTO `user_Group_ChatList` ('name', 'Jabber_id', 'user_image' , 'is_online', 'user_image_URL') VALUES (?, ? , ?, ? ,?);";
    
    sqlite3_stmt *insStmt = NULL;
    if ( !insStmt )
        if ( (ret = sqlite3_prepare_v2(_database, sql, -1, &insStmt, NULL)) != SQLITE_OK ) {
            
            NSLog(@"Proble to insert record in user_Group_ChatList");
        }
    
    // bind values
    
    sqlite3_bind_text(insStmt, 1, [[NSString stringWithFormat:@"%@", name] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insStmt, 2, [[NSString stringWithFormat:@"%@", strUserID] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insStmt, 4, [[NSString stringWithFormat:@"%@", is_online] UTF8String], -1, SQLITE_TRANSIENT);
    
    sqlite3_bind_text(insStmt, 5, [[NSString stringWithFormat:@"%@", strImageURL] UTF8String], -1, SQLITE_TRANSIENT);
    
    sqlite3_bind_blob(insStmt, 3, [imgData bytes], [imgData length], SQLITE_TRANSIENT);
    
    if ((ret = sqlite3_step(insStmt)) != SQLITE_DONE) {NSLog(@"error while inserting data in 'user_Group_ChatList' table");}
    sqlite3_reset(insStmt);
}

-(BOOL) check_Jabber_id_AlreadyExistIn_user_Group_ChatList:(NSString *) strJID
{
    BOOL isExist = NO;
    sqlite3_stmt *selStmt = NULL;
    NSString *query = [NSString stringWithFormat:@"SELECT Jabber_id FROM user_Group_ChatList WHERE Jabber_id = ?"];
    
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &selStmt, nil) == SQLITE_OK)
    {
        sqlite3_bind_text(selStmt, 1, [strJID UTF8String], -1, SQLITE_TRANSIENT);
        while (sqlite3_step(selStmt) == SQLITE_ROW)
            isExist = YES;
        sqlite3_finalize(selStmt);
    }
    return isExist;
}


-(BOOL) checkBlcoked_UserID_AlreadyExistOrNot:(NSString *) strUserID
{
    BOOL isExist = NO;
    sqlite3_stmt *selStmt = NULL;
    NSString *query = [NSString stringWithFormat:@"SELECT userid FROM blockUserTable WHERE userid = ?"];
    
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &selStmt, nil) == SQLITE_OK)
    {
        sqlite3_bind_text(selStmt, 1, [strUserID UTF8String], -1, SQLITE_TRANSIENT);
        while (sqlite3_step(selStmt) == SQLITE_ROW)
            isExist = YES;
        sqlite3_finalize(selStmt);
    }
    return isExist;
}

#pragma mark - Get Places, Videos and Banners for Explore Screen -

-(NSMutableArray *) getBannerFrom_bannerTable
{
    NSMutableArray *listofBanner = [[NSMutableArray alloc] init];
    sqlite3_stmt *statement = NULL;
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM bannerTable"];
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            //('banner_id', 'banner_image', 'banner_type', 'banner_description', 'banner_link') VALUES (?, ?, ?, ?, ?)
            
            char *mainIDChars = (char *) sqlite3_column_text(statement, 0);
            char *bnrIdChars = (char *) sqlite3_column_text(statement, 1);
            char *bnrImgChars = (char *) sqlite3_column_text(statement, 2);
            char *bnrTypChars = (char *) sqlite3_column_text(statement, 3);
            char *bnrDesChars = (char *) sqlite3_column_text(statement, 4);
            char *bnrLinkChars = (char *) sqlite3_column_text(statement, 5);
            
            NSString *mainID = @"", *advertisement_id  = @"", *advertisement_image = @"", *advertisement_type  = @"", *advertisement_description  = @"", *advertisement_link = @"";
            
            if(mainIDChars != NULL)
                mainID  = [[NSString alloc] initWithUTF8String:mainIDChars];
            if(bnrIdChars != NULL)
                advertisement_id  = [[NSString alloc] initWithUTF8String:bnrIdChars];
            if(bnrImgChars != NULL)
                advertisement_image  = [[NSString alloc] initWithUTF8String:bnrImgChars];
            if(bnrTypChars != NULL)
                advertisement_type  = [[NSString alloc] initWithUTF8String:bnrTypChars];
            if(bnrDesChars != NULL)
                advertisement_description  = [[NSString alloc] initWithUTF8String:bnrDesChars];
            if(bnrLinkChars != NULL)
                advertisement_link  = [[NSString alloc] initWithUTF8String:bnrLinkChars];
            
            NSMutableDictionary *dicOfBanner = [[ NSMutableDictionary alloc] init];
            [dicOfBanner setObject:mainID forKey:@"main_id"];
            [dicOfBanner setObject:advertisement_id forKey:@"advertisement_id"];
            [dicOfBanner setObject:advertisement_image forKey:@"advertisement_image"];
            [dicOfBanner setObject:advertisement_type forKey:@"is_image_url"];
            [dicOfBanner setObject:advertisement_description forKey:@"advertisement_description"];
            [dicOfBanner setObject:advertisement_link forKey:@"advertisement_link"];
            [listofBanner addObject:dicOfBanner];
        }
        sqlite3_finalize(statement);
    }
    
    return listofBanner;
}

-(NSMutableArray *) getAllBlockedUserList
{
    NSMutableArray *listofBlockedPeople = [[NSMutableArray alloc] init];
    sqlite3_stmt *statement = NULL;
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM blockUserTable"];
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            //TABLE "blockUserTable" ("id" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , "blockJID" TEXT, "userid" TEXT)
            
            char *mainIDChars = (char *) sqlite3_column_text(statement, 0);
            char *blkIdChars = (char *) sqlite3_column_text(statement, 1);
            char *uidChars = (char *) sqlite3_column_text(statement, 2);
            
            NSString *mainID = @"", *blockJID  = @"", *userid = @"";
            
            if(mainIDChars != NULL)
                mainID  = [[NSString alloc] initWithUTF8String:mainIDChars];
            if(blkIdChars != NULL)
                blockJID  = [[NSString alloc] initWithUTF8String:blkIdChars];
            if(uidChars != NULL)
                userid  = [[NSString alloc] initWithUTF8String:uidChars];
            
            NSMutableDictionary *dicOfPlace = [[ NSMutableDictionary alloc] init];
            [dicOfPlace setObject:mainID forKey:@"main_id"];
            [dicOfPlace setObject:blockJID forKey:@"blocked_jid"];
            [dicOfPlace setObject:userid forKey:@"user_id"];
            [listofBlockedPeople addObject:dicOfPlace];
        }
        sqlite3_finalize(statement);
    }
    
    return listofBlockedPeople;
}

-(NSMutableArray *) getAllPopularPlacesWithAllVideos
{
    NSMutableArray *listofPlaces = [[NSMutableArray alloc] init];
    sqlite3_stmt *statement = NULL;
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM PopularPlacesTbl ORDER BY total_peoples DESC"];
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            //('place_id', 'place_name', 'address', 'total_peoples') VALUES (?, ?, ?, ?);";

            
            char *mainIDChars = (char *) sqlite3_column_text(statement, 0);
            char *plcIdChars = (char *) sqlite3_column_text(statement, 1);
            char *plcNmChars = (char *) sqlite3_column_text(statement, 2);
            char *plcAddChars = (char *) sqlite3_column_text(statement, 3);
            char *ttlPplChars = (char *) sqlite3_column_text(statement, 4);
            
            NSString *mainID = @"", *place_id  = @"", *place_name = @"", *address  = @"", *total_peoples  = @"";
            
            if(mainIDChars != NULL)
                mainID  = [[NSString alloc] initWithUTF8String:mainIDChars];
            if(plcIdChars != NULL)
                place_id  = [[NSString alloc] initWithUTF8String:plcIdChars];
            if(plcNmChars != NULL)
                place_name  = [[NSString alloc] initWithUTF8String:plcNmChars];
            if(plcAddChars != NULL)
                address  = [[NSString alloc] initWithUTF8String:plcAddChars];
            if(ttlPplChars != NULL)
                total_peoples  = [[NSString alloc] initWithUTF8String:ttlPplChars];
            
            NSMutableDictionary *dicOfPlace = [[ NSMutableDictionary alloc] init];
            [dicOfPlace setObject:mainID forKey:@"main_id"];
            [dicOfPlace setObject:place_id forKey:@"place_id"];
            [dicOfPlace setObject:place_name forKey:@"place_name"];
            [dicOfPlace setObject:address forKey:@"address"];
            [dicOfPlace setObject:total_peoples forKey:@"total_peoples"];
            
            NSMutableArray *listofVideos = [self getAllPopularPlaceVideosWherePlaceId:place_id];
            [dicOfPlace setObject:listofVideos forKey:@"video_list"];
            
            [listofPlaces addObject:dicOfPlace];
        }
        sqlite3_finalize(statement);
    }
    
    return listofPlaces;
}


-(NSMutableArray *) getAllPopularPlaceVideosWherePlaceId:(NSString *) strPlaceId
{
    NSMutableArray *listofVideos = [[NSMutableArray alloc] init];
    sqlite3_stmt *statement = NULL;
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM palcevideoTbl WHERE place_id = %@", strPlaceId];
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            // ('place_id', 'url_id', 'video_img', 'video_url') VALUES (?, ?, ?, ?)
            
            char *mainIDChars = (char *) sqlite3_column_text(statement, 0);
            char *plcIdChars = (char *) sqlite3_column_text(statement, 1);
            char *urlIDChars = (char *) sqlite3_column_text(statement, 2);
            char *vdoImgChars = (char *) sqlite3_column_text(statement, 3);
            char *vdoUrlChars = (char *) sqlite3_column_text(statement, 4);
            
            NSString *mainID = @"", *place_id  = @"", *url_id = @"", *video_img  = @"", *video_url  = @"";
            
            if(mainIDChars != NULL)
                mainID  = [[NSString alloc] initWithUTF8String:mainIDChars];
            if(plcIdChars != NULL)
                place_id  = [[NSString alloc] initWithUTF8String:plcIdChars];
            if(urlIDChars != NULL)
                url_id  = [[NSString alloc] initWithUTF8String:urlIDChars];
            if(vdoImgChars != NULL)
                video_img  = [[NSString alloc] initWithUTF8String:vdoImgChars];
            if(vdoUrlChars != NULL)
                video_url  = [[NSString alloc] initWithUTF8String:vdoUrlChars];
            
            NSMutableDictionary *dicOfVideo = [[ NSMutableDictionary alloc] init];
            [dicOfVideo setObject:mainID forKey:@"main_id"];
            [dicOfVideo setObject:place_id forKey:@"place_id"];
            [dicOfVideo setObject:url_id forKey:@"url_id"];
            [dicOfVideo setObject:video_img forKey:@"video_img"];
            [dicOfVideo setObject:video_url forKey:@"video_url"];
            
            [listofVideos addObject:dicOfVideo];
        }
        sqlite3_finalize(statement);
    }
    
    return listofVideos;
}

#pragma mark - Delete Places, Videos and Banners Tables -

-(void) deleteAllDataFrom_Banner_Table
{
    int ret;
    const char *sql = "DELETE FROM bannerTable";
    
    sqlite3_stmt *dltStmt = NULL;
    if ( !dltStmt )
        if ( (ret = sqlite3_prepare_v2(_database, sql, -1, &dltStmt, NULL)) != SQLITE_OK ) {}
    
    if ((ret = sqlite3_step(dltStmt)) != SQLITE_DONE) {NSLog(@"Error : While Deleting Record From  bannerTable Table");}
    sqlite3_reset(dltStmt);
}

-(void) deleteAllDataFrom_PopularPlaces_Table
{
    int ret;
    const char *sql = "DELETE FROM PopularPlacesTbl";
    
    sqlite3_stmt *dltStmt = NULL;
    if ( !dltStmt )
        if ( (ret = sqlite3_prepare_v2(_database, sql, -1, &dltStmt, NULL)) != SQLITE_OK ) {}
    
    if ((ret = sqlite3_step(dltStmt)) != SQLITE_DONE) {NSLog(@"Error : While Deleting Record From  PopularPlacesTbl Table");}
    sqlite3_reset(dltStmt);
}

-(void) deleteAllDataFrom_Videos_Table
{
    int ret;
    const char *sql = "DELETE FROM palcevideoTbl";
    
    sqlite3_stmt *dltStmt = NULL;
    if ( !dltStmt )
        if ( (ret = sqlite3_prepare_v2(_database, sql, -1, &dltStmt, NULL)) != SQLITE_OK ) {}
    
    if ((ret = sqlite3_step(dltStmt)) != SQLITE_DONE) {NSLog(@"Error : While Deleting Record From  palcevideoTbl Table");}
    sqlite3_reset(dltStmt);
}

-(void) deleteBlockedUserFrom_blockUserTableWhereUserIDis:(NSString *) strJID
{
    int ret;
    const char *sql = "DELETE FROM blockUserTable WHERE userid = ?";
    
    sqlite3_stmt *dltStmt = NULL;
    if ( !dltStmt )
        if ( (ret = sqlite3_prepare_v2(_database, sql, -1, &dltStmt, NULL)) != SQLITE_OK ) {}
    
    sqlite3_bind_text(dltStmt, 1, [strJID UTF8String], -1, SQLITE_TRANSIENT);
    
    if ((ret = sqlite3_step(dltStmt)) != SQLITE_DONE) {NSLog(@"Error : While Deleting Record From  blockUserTable Table");}
    sqlite3_reset(dltStmt);
}


-(NSMutableArray *)CheckIfUserExistInChatGroup :(NSString *) strJabberId
{
    NSMutableArray *listofBlockedPeople = [[NSMutableArray alloc] init];
    sqlite3_stmt *statement = NULL;
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM user_Group_ChatList where Jabber_id = %@",strJabberId];
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            //TABLE "blockUserTable" ("id" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , "blockJID" TEXT, "userid" TEXT)
            
            char *mainIDChars = (char *) sqlite3_column_text(statement, 1);
            char *blkIdChars = (char *) sqlite3_column_text(statement, 2);
            char *uidChars = (char *) sqlite3_column_text(statement, 3);
            
            NSString *mainID = @"", *blockJID  = @"", *userid = @"";
            
            if(mainIDChars != NULL)
                mainID  = [[NSString alloc] initWithUTF8String:mainIDChars];
            if(blkIdChars != NULL)
                blockJID  = [[NSString alloc] initWithUTF8String:blkIdChars];
            if(uidChars != NULL)
                userid  = [[NSString alloc] initWithUTF8String:uidChars];
            
            NSMutableDictionary *dicOfPlace = [[ NSMutableDictionary alloc] init];
            [dicOfPlace setObject:mainID forKey:@"name"];
            [dicOfPlace setObject:blockJID forKey:@"Jabber_id"];
            [dicOfPlace setObject:@"" forKey:@"user_image"];
            [listofBlockedPeople addObject:dicOfPlace];
        }
        sqlite3_finalize(statement);
    }
    
    return listofBlockedPeople;
}


-(NSMutableArray *)getAllUsersFromChatListing
{
    NSMutableArray *listofBuddy = [[NSMutableArray alloc] init];
    sqlite3_stmt *statement = NULL;
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM user_Group_ChatList"];
    
    int len = 0;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *mainIDChars = (char *) sqlite3_column_text(statement, 1);
            char *blkIdChars = (char *) sqlite3_column_text(statement, 2);
            char *blkISONLINE = (char *) sqlite3_column_text(statement, 4);
            char *bUserImageURL = (char *) sqlite3_column_text(statement, 5);
            
            NSString *mainID = @"", *blockJID  = @"" ,*strIsOnline = @"" ,*strUserImageURL = @"";
            
            if(mainIDChars != NULL)
                mainID  = [[NSString alloc] initWithUTF8String:mainIDChars];
            if(blkIdChars != NULL)
                blockJID  = [[NSString alloc] initWithUTF8String:blkIdChars];
             if(blkISONLINE != NULL)
                strIsOnline  = [[NSString alloc] initWithUTF8String:blkISONLINE];
            
            
            if(bUserImageURL != NULL)
                strUserImageURL  = [[NSString alloc] initWithUTF8String:bUserImageURL];

            len = sqlite3_column_bytes(statement, 3);
            NSData *imgData;
            imgData = [[NSData alloc] initWithBytes: sqlite3_column_blob(statement, 3) length: len];

            NSMutableDictionary *dicOfChatPpl = [[ NSMutableDictionary alloc] init];
            [dicOfChatPpl setObject:mainID forKey:@"name"];
            [dicOfChatPpl setObject:blockJID forKey:@"Jabber_id"];
            [dicOfChatPpl setObject:imgData forKey:@"user_image"];
            [dicOfChatPpl setObject:strUserImageURL forKey:@"user_imageURL"];
            [dicOfChatPpl setObject:strIsOnline forKey:@"isOnline"];
            [listofBuddy addObject:dicOfChatPpl];
        }
        sqlite3_finalize(statement);
    }
    
    return listofBuddy;
}

-(NSMutableArray *)getOnlyJIdFromList
{
    NSMutableArray *listofBlockedPeople = [[NSMutableArray alloc] init];
    sqlite3_stmt *statement = NULL;
    NSString *query = [NSString stringWithFormat:@"SELECT Jabber_id FROM user_Group_ChatList"];
    
  
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            
            char *mainIDChars = (char *) sqlite3_column_text(statement, 2);
            
            NSString *mainID = @"";
            
            if(mainIDChars != NULL)
                mainID  = [[NSString alloc] initWithUTF8String:mainIDChars];
            
            [listofBlockedPeople addObject:mainID];
        }
        sqlite3_finalize(statement);
    }
    
    return listofBlockedPeople;
}




-(void) updateOnlineUser:(NSString *)strTotalProduct ProductID:(NSString *) strProductID
{
    int ret;
    const char *sql = "update user_Group_ChatList set is_online = ? where Jabber_id = ?;";
    sqlite3_stmt *updtStmt = NULL;
    if ( !updtStmt )
        if ( (ret = sqlite3_prepare_v2(_database, sql, -1, &updtStmt, NULL)) != SQLITE_OK ) {}
    
    // bind values
    sqlite3_bind_text(updtStmt, 1, [[NSString stringWithFormat:@"%@", strProductID] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updtStmt, 2, [strTotalProduct UTF8String], -1, SQLITE_TRANSIENT);
    
    if ((ret = sqlite3_step(updtStmt)) != SQLITE_DONE) {NSLog(@"error while updating  QTY from ProductsCart Table");}
    sqlite3_reset(updtStmt);
    
}

-(void) updateUserImageURL:(NSString *)strTotalProduct ProductID:(NSString *) strProductID name:(NSString *)strUserName
{
    int ret;
    const char *sql = "update user_Group_ChatList set user_image_URL = ? ,name = ? where Jabber_id = ?;";
    sqlite3_stmt *updtStmt = NULL;
    if ( !updtStmt )
        if ( (ret = sqlite3_prepare_v2(_database, sql, -1, &updtStmt, NULL)) != SQLITE_OK ) {}
    
    // bind values
    sqlite3_bind_text(updtStmt, 1, [[NSString stringWithFormat:@"%@", strProductID] UTF8String], -1, SQLITE_TRANSIENT);
    
    sqlite3_bind_text(updtStmt, 2, [[NSString stringWithFormat:@"%@", strUserName] UTF8String], -1, SQLITE_TRANSIENT);
    
    sqlite3_bind_text(updtStmt, 3, [strTotalProduct UTF8String], -1, SQLITE_TRANSIENT);
    
    if ((ret = sqlite3_step(updtStmt)) != SQLITE_DONE) {NSLog(@"error while updating  QTY from ProductsCart Table");}
    sqlite3_reset(updtStmt);
}

-(void) deleteAllDataFrom_user_Group_ChatList
{
    int ret;
    const char *sql = "DELETE FROM user_Group_ChatList";
    
    sqlite3_stmt *dltStmt = NULL;
    if ( !dltStmt )
        if ( (ret = sqlite3_prepare_v2(_database, sql, -1, &dltStmt, NULL)) != SQLITE_OK ) {}
    
    if ((ret = sqlite3_step(dltStmt)) != SQLITE_DONE) {NSLog(@"Error : While Deleting Record From  user_Group_ChatList Table");}
    sqlite3_reset(dltStmt);
}

-(void) deleteAllDataFrom_blockUserTable
{
    int ret;
    const char *sql = "DELETE FROM blockUserTable";
    
    sqlite3_stmt *dltStmt = NULL;
    if ( !dltStmt )
        if ( (ret = sqlite3_prepare_v2(_database, sql, -1, &dltStmt, NULL)) != SQLITE_OK ) {}
    
    if ((ret = sqlite3_step(dltStmt)) != SQLITE_DONE) {NSLog(@"Error : While Deleting Record From  blockUserTable Table");}
    sqlite3_reset(dltStmt);
}


@end
