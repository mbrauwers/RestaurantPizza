//
//  PizzaPlace.m
//  RestaurantPizza
//
//  Created by Maicon Brauwers on 19/06/15.
//  Copyright (c) 2015 Maicon Brauwers. All rights reserved.
//

#import "PizzaPlace.h"


@implementation PizzaPlace

@dynamic name;
@dynamic address;
@dynamic city;
@dynamic rating;
@dynamic phoneContact;
@dynamic foursquareId;

+ (NSArray*) getAllRestaurantsWithContext: (NSManagedObjectContext*) context {
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"PizzaPlace" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"name" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    
    return array;
}

+ (PizzaPlace*) findPlaceWithFoursquareId: (NSString*) foursquareId OnContext: (NSManagedObjectContext*) context {
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"PizzaPlace" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"foursquareId LIKE %@", foursquareId];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (array != nil && [array count] > 0) {
        return array[0];
    }
    else {
        return nil;
    }
}
@end
