//
//  ViewController.m
//  RestaurantPizza
//
//  Created by Maicon Brauwers on 19/06/15.
//  Copyright (c) 2015 Maicon Brauwers. All rights reserved.
//

#import "PizzaRestaurantsMainController.h"
#import <CoreLocation/CoreLocation.h>
#import "RestaurantsTableViewCell.h"

#define kFoursquareClientKey @"S55S3TO5FTVJFNEVLWMEAZE4JYRPXQHD1DL45J3AFYWALSHH"
#define kFoursquareClientSecret @"3ZVMLG1PWLTJZFWO4OLLFRZEN0GLZQTXIMRFBF1MVIE1UV3I"

@interface PizzaRestaurantsMainController () <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblView;
;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *searchActivityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *searchProgressLbl;

@property (weak, nonatomic) IBOutlet UILabel *foundRestLbl;
@property (weak, nonatomic) IBOutlet UIButton *searchAgainBut;

@property (nonatomic) BOOL isDoingSearch;

//our location manager
@property (nonatomic, strong) CLLocationManager* locationManager;

//the places to show in table
@property (nonatomic, strong) NSArray* places;

//current user location
@property (nonatomic, strong) CLLocation* currLocation;

@end

@implementation PizzaRestaurantsMainController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.searchActivityIndicator.hidden = YES;
    self.searchProgressLbl.hidden = YES;
    self.foundRestLbl.hidden = YES;
    self.searchAgainBut.hidden = YES;
    
    //registers custtom nib file
    [self.tblView registerNib: [UINib nibWithNibName:@"RestaurantsTableViewCell" bundle:nil]  forCellReuseIdentifier:@"Cell"];
    
    if (![CLLocationManager locationServicesEnabled]) {
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Please enable location services" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [av show];
        return;
    }
    

}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"auth status: %d", [CLLocationManager authorizationStatus]);
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        //request authorization by the user first before we can have his location
        NSLog(@"this is the case");
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self.locationManager requestWhenInUseAuthorization];
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways ||
             [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        //we can try to get his location immediately
        [self startSignificantChangeUpdates];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)searchAgainTapped:(id)sender {
    if (self.isDoingSearch) { return; }
    
    [self searchForPlaces];
}

- (void)startSignificantChangeUpdates {
    NSLog(@"startSignificantChangeUpdates");
    
    // Create the location manager if this object does not
    // already have one.
    if (nil == self.locationManager) {
        NSLog(@"creating location manager[1]");
        self.locationManager = [[CLLocationManager alloc] init];
    }
    
    NSLog(@"location manager is %@", self.locationManager);
    
    self.locationManager.delegate = self;
}

//start getting the user location
- (void)startStandardLocationUpdates {
    NSLog(@"startStandardLocationUpdates");
    
    // Create the location manager if this object does not
    // already have one.
    if (nil == self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    // Set a movement threshold for new events.
    self.locationManager.distanceFilter = 500; // meters
    
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"didChangeAuthorization %@", manager);
    //this is called when first authrozing as also at each time the user opens the app again
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self startStandardLocationUpdates];
    }
}

// Delegate method from the CLLocationManagerDelegate protocol.
// Cool, we got a location
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    
    NSLog(@"got a new location, it is %@", location);
    
    self.currLocation = location;
    
    //search for places in this area
    [self searchForPlaces];
    
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    NSLog(@"Error with location: %@", error);
}


//searches for places using foursquare API
- (void) searchForPlaces {
    self.foundRestLbl.hidden = YES;
    self.searchAgainBut.hidden = YES;
    self.searchActivityIndicator.hidden = NO;
    self.searchProgressLbl.hidden = NO;
    
    //we perform the API query in background
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        //Foursquare API URL
        NSString* urlStr = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/explore?ll=%.2f,%.2f&query=pizza&limit=5&&client_id=%@&client_secret=%@&v=20150619", self.currLocation.coordinate.latitude, self.currLocation.coordinate.longitude, kFoursquareClientKey, kFoursquareClientSecret];
        NSURL* url = [NSURL URLWithString:urlStr];

        NSLog(@"url is %@", url);
        
        //performs the request
        NSData* data = [NSData dataWithContentsOfURL: url];
        
        if (data == nil) {
            NSLog(@"Data is nil");
            [self showErrorInMainQueue: @"Error getting API data"];
            return;
        }
        
        NSError* error;
        id parsedJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        if (error != nil) {
            NSLog(@"Error parsing JSON: %@", error);
            [self showErrorInMainQueue:@"Error parsing JSON"];
            return;
        }
        
//        NSLog(@"%@", parsedJSON);
        
        if (![parsedJSON isKindOfClass: [NSDictionary class]]) {
            NSLog(@"Returned JSON of wrong kind");
            [self showErrorInMainQueue:@"Wrong Kind of Json Object"];
            return;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateWithDataFromFoursquare: parsedJSON];
        });
        
        
    });
}

//updates with data from foursquare
- (void) updateWithDataFromFoursquare: (NSDictionary*) parsedJSON {
    NSArray* groups = parsedJSON[@"response"][@"groups"];
    NSArray* items = groups[0][@"items"];
    
    
    //sorts by name
    self.places = [items sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDictionary* item1 = (NSDictionary*) obj1;
        NSDictionary* item2 = (NSDictionary*) obj2;
        
        NSString* str1 = item1[@"venue"][@"name"];
        NSString* str2 = item2[@"venue"][@"name"];
        
        return [str1 compare:str2];
    }];
    
    [self.tblView reloadData];
}


- (void) showErrorInMainQueue: (NSString*) errorMsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [av show];
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.places count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RestaurantsTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDictionary* place = self.places[indexPath.row];
    
    NSLog(@"name is %@", place[@"venue"][@"name"]);
    
    cell.nameLbl.text = place[@"venue"][@"name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}


@end
