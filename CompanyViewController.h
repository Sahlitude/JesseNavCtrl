//
//  CompanyViewController.h
//  NavCtrl
//
//  Created by Aditya Narayan on 10/22/13.
//  Copyright (c) 2013 Aditya Narayan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAO.h"
#import "Company.h"
#import "AddEditViewController.h"
#import "DBManager.h"
#import "ProductListViewController.h"

//@class ProductListViewController;

@interface CompanyViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource>


@property (nonatomic, retain) NSMutableArray *companyList;
//@property (nonatomic, retain) IBOutlet ProductViewController * productViewController;
@property (nonatomic, retain) ProductListViewController * productListViewController;
@property (nonatomic, retain) AddEditViewController *addEditViewController;


@end
