//
//  Company.h
//  NavCtrl
//
//  Created by Jesse Sahli on 6/14/16.
//  Copyright © 2016 Aditya Narayan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Product.h"

@interface Company : NSObject

//@property NSMutableArray<Product *> *products; Should I make it specifically product objects?
@property (nonatomic, retain) NSString *companyName;
@property (nonatomic, retain) NSMutableArray<Product*> *products;

- (id)initWithName: (NSString*) company
       andProducts: (NSMutableArray*) productArray;

@end