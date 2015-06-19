//
//  PizzaPlace.h
//  RestaurantPizza
//
//  Created by Maicon Brauwers on 19/06/15.
//  Copyright (c) 2015 Maicon Brauwers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PizzaPlace : NSManagedObject

@property (nonatomic, retain) NSString * foursquareId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSString * phoneContact;

+ (NSArray*) getAllRestaurantsWithContext: (NSManagedObjectContext*) context;

+ (PizzaPlace*) findPlaceWithFoursquareId: (NSString*) foursquareId OnContext: (NSManagedObjectContext*) context;

@end
