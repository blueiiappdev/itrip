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
   NSString*         m_title;
   NSDate*           m_date;
   NSString*         m_intro;
   NSString*         m_photoUrl;
   
   NSMutableArray*   m_comments;
   int               m_commmentCount;
}

@property(nonatomic, retain) NSString* title;
@property(nonatomic, retain) NSDate* date;
@property(nonatomic, retain) NSString* intro;
@property(nonatomic, retain) NSString* photoUrl;
@property(atomic, assign) int commentCount;
@property(nonatomic, readonly) NSMutableArray* comments;
@end

@interface DSTripRecord : NSObject 
{
   NSString*         m_title;
   NSString*         m_address;        //TODO: geography info
   
   NSString*         m_authorId;
   NSString*         m_authorName;
   
   NSDate*           m_start;
   NSDate*           m_end;
   
   int               m_days;           // m_end - m_start + 1
   int               m_commentCount;   // sum of all comments
   int               m_favCount;
   
   NSMutableArray*   m_dailyRecords;
}

@property(nonatomic, retain) NSString*    title;
@property(nonatomic, retain) NSString*    address;
@property(nonatomic, retain) NSString*    authorId;
@property(nonatomic, retain) NSString*    authorName;
@property(nonatomic, retain) NSDate*      start;
@property(nonatomic, retain) NSDate*      end;

@property(atomic, assign) int days;
@property(atomic, assign) int commentCount;
@property(atomic, assign) int favCount;

@property(nonatomic, readonly) NSMutableArray* dailyRecords;

-(id) init;
-(void) addDialyRecord:(DSTripDailyRecord*) dailyRecord;

@end

