//
//  DSTripRecord.m
//  iTrip
//
//  Created by Ramon Liu on 7/20/12.
//  Copyright (c) 2012 DreamStart. All rights reserved.
//

#import "DSTripRecord.h"

@implementation DSTripDailyRecord

@synthesize title = m_title,
date = m_date,
intro = m_intro,
photoUrl = m_photoUrl,
commentCount = m_commmentCount,
comments = m_comments;

-(void) dealloc {
   [m_title release];
   [m_date release];
   [m_intro release];
   [m_photoUrl release];
   
   [m_comments release];
   
   [super dealloc];
}

@end

@implementation DSTripRecord

@synthesize title = m_title,
address = m_address,
authorId = m_authorId,
authorName = m_authorName,
start = m_start,
end = m_end,
days = m_days,
commentCount = m_commentCount,
favCount = m_favCount,
dailyRecords = m_dailyRecords;

-(id) init {
   if (self = [super init]) {
      m_dailyRecords = [[NSMutableArray alloc] initWithCapacity:5];
   }
   return self;
}

-(void) dealloc {
   [m_title release];
   [m_address release];
   [m_authorId release];
   [m_authorName release];
   [m_start release];
   [m_end release];
   
   [m_dailyRecords release];
   
   [super dealloc];
}

-(void) addDialyRecord:(DSTripDailyRecord *)dailyRecord {
   [m_dailyRecords addObject:dailyRecord];
}

@end
