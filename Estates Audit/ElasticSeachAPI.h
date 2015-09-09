//
//  ElasticSeachAPI.h
//  Estates Audit
//
//  Created by Colin Gormley on 02/09/2015.
//  Copyright (c) 2015 Colin Gormley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ElasticSeachAPI : NSObject

+ (ElasticSeachAPI *)sharedInstance;

- (void)getAllTypesWithCompletion:(void (^)(NSMutableArray *aggregations))completion;

- (void)getAllAreasWithCompletion:(void (^)(NSMutableArray *aggregations))completion;

- (void)searchForBuildingsWithQueryJson: (NSDictionary *)queryJson
                         withCompletion:(void (^)(NSMutableDictionary *locations))completion;

- (void)postBuildingFacilityToBuilding:(NSString *) buildingId
                         withQueryJson:(NSDictionary *)queryJson
                        withCompletion:(void (^)(NSDictionary *locations))completion;

- (void)searchForBuildingWithId: (NSString *)buildingId
                 withCompletion:(void (^)(NSMutableDictionary *source))completion;

@end
