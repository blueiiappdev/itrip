//
//  DSTripRecord.m
//  iTrip
//
//  Created by Ramon Liu on 7/20/12.
//  Copyright (c) 2012 DreamStart. All rights reserved.
//

#import "DSTripRecord.h"

@implementation DSTripDailyRecord

@synthesize tid = m_id,
title = m_title,
date = m_date,
intro = m_intro,
photoUrl = m_photoUrl,
photo = m_photo,
commentCount = m_commentCount,
comments = m_comments,
favCount = m_favCount;

-(id) initWithMap:(NSDictionary*)map 
{
   if (self = [super init])
   {
      self.tid = [map objectForKey:@"id"];
      self.title = [map objectForKey:@"title"];
      self.date = [DSTripRecord stringToDate:[map objectForKey:@"date"]];
      self.intro = [map objectForKey:@"intro"];
      self.photoUrl = [map objectForKey:@"photoUrl"];
      self.commentCount = [[map objectForKey:@"commentCount"] intValue];
      self.favCount = [[map objectForKey:@"favCount"] intValue];
   }
   return self;
}

-(void) dealloc {
   [m_id release];
   [m_title release];
   [m_date release];
   [m_intro release];
   [m_photoUrl release];
   [m_photo release];
   
   [m_comments release];
   
   [super dealloc];
}

@end

@implementation DSTripRecord

@synthesize tid = m_id,
title = m_title,
address = m_address,
authorId = m_authorId,
authorName = m_authorName,
authorPhotoUrl = m_authorPhotoUrl,
authorPhoto = m_authorPhoto,
start = m_start,
end = m_end,
days = m_days,
commentCount = m_commentCount,
favCount = m_favCount,
dailyRecords = m_dailyRecords;

-(id) initWithMap:(NSDictionary*)map
{
   if (self = [super init]) {
      self.tid = [map objectForKey:@"id"];
      self.title = [map objectForKey:@"title"];
      self.address = [map objectForKey:@"address"];
      self.authorId = [map objectForKey:@"authorId"];
      self.authorName = [map objectForKey:@"authorName"];
      self.authorPhotoUrl = [map objectForKey:@"authorPhotoUrl"];
      self.start = [DSTripRecord stringToDate:[map objectForKey:@"start"]];
      self.end = [DSTripRecord stringToDate:[map objectForKey:@"end"]];
      self.days = [[map objectForKey:@"days"] intValue];
      self.commentCount = [[map objectForKey:@"commentCount"] intValue];
      self.favCount = [[map objectForKey:@"favCount"] intValue];
      self.dailyRecords = [[NSMutableArray alloc] initWithCapacity:5];
      NSArray* arr = [map objectForKey:@"dailyRecords"];
      for (NSDictionary* d in arr)
      {
         DSTripDailyRecord* dailyRecord = [[DSTripDailyRecord alloc] initWithMap:d];
         [self.dailyRecords addObject:dailyRecord];
      }
   }
   return self;
}

-(void) dealloc {
   [m_id release];
   [m_title release];
   [m_address release];
   [m_authorId release];
   [m_authorName release];
   [m_authorPhotoUrl release];
   [m_authorPhoto release];
   [m_start release];
   [m_end release];
   
   [m_dailyRecords release];
   
   [super dealloc];
}

-(void) addDialyRecord:(DSTripDailyRecord *)dailyRecord {
   [m_dailyRecords addObject:dailyRecord];
}

+(NSDate*) stringToDate:(NSString *)string {
   static NSDateFormatter *formatter = nil;
   if (!formatter) {
      formatter = [[NSDateFormatter alloc] init];
      [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
//      [formatter setDateFormat:@"yyyy-MM-ddTHH:mm:ss.SSSZ"];
      [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"];
   }
   return [formatter dateFromString:string];
}

@end
