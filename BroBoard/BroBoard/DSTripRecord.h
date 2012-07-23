//
//  DSTripRecord.h
//  iTrip
//
//  Created by Ramon Liu on 7/20/12.
//  Copyright (c) 2012 DreamStart. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DSTripDailyRecord : NSObject
{
   NSString*         m_id;
   NSString*         m_title;
   NSDate*           m_date;
   NSString*         m_intro;
   NSString*         m_photoUrl;
   UIImage*          m_photo;
   
   NSMutableArray*   m_comments;
   int               m_commentCount;
   int               m_favCount;
}

@property(nonatomic, retain) NSString* tid;
@property(nonatomic, retain) NSString* title;
@property(nonatomic, retain) NSDate* date;
@property(nonatomic, retain) NSString* intro;
@property(nonatomic, retain) NSString* photoUrl;
@property(nonatomic, retain) UIImage* photo;
@property(atomic, assign) int commentCount;
@property(atomic, assign) int favCount;
@property(nonatomic, retain) NSMutableArray* comments;

-(id) initWithMap:(NSDictionary*)map;
@end

@interface DSTripRecord : NSObject 
{
   NSString*         m_id;
   NSString*         m_title;
   NSString*         m_address;        //TODO: geography info
   
   NSString*         m_authorId;
   NSString*         m_authorName;
   NSString*         m_authorPhotoUrl;
   UIImage*         m_authorPhoto;
   
   NSDate*           m_start;
   NSDate*           m_end;
   
   int               m_days;           // m_end - m_start + 1
   int               m_commentCount;   // sum of all comments
   int               m_favCount;
   
   NSMutableArray*   m_dailyRecords;
}

@property(nonatomic, retain) NSString*    tid;
@property(nonatomic, retain) NSString*    title;
@property(nonatomic, retain) NSString*    address;
@property(nonatomic, retain) NSString*    authorId;
@property(nonatomic, retain) NSString*    authorName;
@property(nonatomic, retain) NSString*    authorPhotoUrl;
@property(nonatomic, retain) UIImage*     authorPhoto;
@property(nonatomic, retain) NSDate*      start;
@property(nonatomic, retain) NSDate*      end;

@property(atomic, assign) int days;
@property(atomic, assign) int commentCount;
@property(atomic, assign) int favCount;

@property(nonatomic, retain) NSMutableArray* dailyRecords;

+(NSDate*) stringToDate:(NSString*)string;
-(id) initWithMap:(NSDictionary*)map;
-(void) addDialyRecord:(DSTripDailyRecord*) dailyRecord;

@end

