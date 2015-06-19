//
//  RestaurantDetailViewController.m
//  RestaurantPizza
//
//  Created by Maicon Brauwers on 19/06/15.
//  Copyright (c) 2015 Maicon Brauwers. All rights reserved.
//

#import "RestaurantDetailViewController.h"
#import "PizzaPlace.h"

@interface RestaurantDetailViewController() <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblView;

@end

@implementation RestaurantDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.pizzaPlace.name;
    [self.tblView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSString* content;
    if (indexPath.row == 0) {
        content = [NSString stringWithFormat:@"Name: %@", self.pizzaPlace.name];
    }
    else if (indexPath.row == 1) {
        content = [NSString stringWithFormat:@"Rating: %@", self.pizzaPlace.rating];
    }
    else if (indexPath.row == 2) {
        
        if (self.pizzaPlace.address != nil) {
            content = [NSString stringWithFormat:@"Address: %@ %@", self.pizzaPlace.address, self.pizzaPlace.city];
        }
        else {
            content = @"Address: Not Provided";
        }
        
    }
    else if (indexPath.row == 3) {
        NSString* phoneContact = self.pizzaPlace.phoneContact;
        if (phoneContact == nil) { phoneContact = @"None"; }
        content = [NSString stringWithFormat:@"Phone Contact: %@", phoneContact];
    }
    
    cell.textLabel.text = content;
    return cell;
}



@end
