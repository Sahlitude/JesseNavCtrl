//
//  CompanyListViewController.m
//  NavCtrl
//
//  Created by Jesse Sahli on 7/7/16.
//  Copyright © 2016 Aditya Narayan. All rights reserved.
//

#import "CompanyListViewController.h"

@interface CompanyListViewController ()

@end

//SET AS ROOT VIEW CONTROLLER


@implementation CompanyListViewController

//- (void)viewDidLoad {
//    [super viewDidLoad];
//    // Do any additional setup after loading the view from its nib.
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
//    self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    UIBarButtonItem *editBarButton = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editButtonAction)];
    self.navigationItem.leftBarButtonItem = editBarButton;

    UIBarButtonItem *addBarButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"btn-navAdd.png"] style:UIBarButtonItemStylePlain target:self action:@selector(addButtonAction)];
    self.navigationItem.rightBarButtonItem = addBarButton;
    self.tableView.allowsSelectionDuringEditing = YES;
    
    DAO *dataManager = [DAO dataManager];
    NSLog(@"%@", dataManager.companyArray);
    NSLog(@"%@",dataManager.managedCompanyArray);
    self.companyList = dataManager.companyArray;
    self.title = @"Stock Tracker";
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
//    self.tableView.frame = [[UIScreen mainScreen]bounds];
    DAO *dataManager = [DAO dataManager];
    self.companyList = dataManager.companyArray;
    //    self.title = @"Stock Tracker";
    [self.tableView reloadData];
    [self loadStockPrices];
 
    if(self.companyList.count < 1){
        [self.tableView setHidden:YES];
        [self.emptyImage setHidden:NO];
        [self.emptyLabel setHidden:NO];
        [self.addButtonOutlet setHidden:NO];
    } else {
        [self.tableView setHidden:NO];
        [self.emptyImage setHidden:YES];
        [self.emptyLabel setHidden:YES];
        [self.addButtonOutlet setHidden:YES];
    }
    
}

-(void)loadStockPrices {
    
    DAO *dataManager = [DAO dataManager];
    
    //URL before dynamically adding desired stock prices
    NSString* urlShell = @"http://finance.yahoo.com/d/quotes.csv?s=";
    
    //Adding stock symbols to URL by iterating through our companies symbols
    for (Company *company in dataManager.companyArray) {
        urlShell = [urlShell stringByAppendingString:[NSString stringWithFormat:@"+%@",company.stockSymbol]];
    }
    
    //closing out the URL
    urlShell = [urlShell stringByAppendingString:@"&f=sa"];
    NSURL *dynamicURL = [NSURL URLWithString:urlShell];
    
    //NSURLSESSION GET HTTP request to pull CSV data from Yahoo API
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:dynamicURL];
    request.HTTPMethod = @"GET";
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        
        if(error){
            NSLog(@"error with NSURLSESSION!");
        }
        
        // Creating a string with the data and parsing the data into an NSDictionary by seperating components with commas or new lines.
        
        NSString *dataString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSArray *stockArray = [dataString componentsSeparatedByString:@"\n"];
        
        [dataString release];
        
        dataManager.stockDictionary = [[NSMutableDictionary alloc]init];
        
        for (NSString *x in stockArray) {
            
            //Getting rid of quotation marks that came with the data and parsing the CSV string into an NSDictionary
            NSString* newX = [x stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            NSArray *stockValues = [newX componentsSeparatedByString:@","];
            if (stockValues.count < 2) {
                break;
            }
            [dataManager.stockDictionary setObject:stockValues[1] forKey:stockValues[0]];
        }
        
        //        [stockArray release]; WILL CRASH IF I RELEASE HERE
        NSLog(@"%@", dataManager.stockDictionary);
        
        //assigning the stock prices to all companies usinf fast enumeration
        for(Company *company in dataManager.companyArray){
            company.stockPrice = [dataManager.stockDictionary objectForKey:company.stockSymbol];
        }
        
        //reload
        //dispatch main
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    }]
     resume];
    
    [session release];
    [request release];
    [dataManager.stockDictionary release];
    
}

//add button that pushes to the Add/Edit view controller
-(void)addButtonAction {
    self.addEditViewController = [[AddEditViewController alloc]init];
    self.addEditViewController.title = @"New Company";
    self.addEditViewController.editMode = NO;
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    [self.navigationController pushViewController:self.addEditViewController animated:YES];
}

-(void)editButtonAction {
    [self.tableView setEditing:YES animated:YES];
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonAction)];
    
    self.navigationItem.leftBarButtonItem = doneBarButton;
}

-(void)doneButtonAction {
    [self.tableView setEditing:NO animated:YES];
    UIBarButtonItem *editBarButton = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editButtonAction)];
    self.navigationItem.leftBarButtonItem = editBarButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return [self.companyList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        // set the UITABLEVIEWCELLSTYLE to subtitle
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    Company *company = [self.companyList objectAtIndex:[indexPath row]];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", company.companyName, company.stockSymbol];
    cell.detailTextLabel.numberOfLines = 2;
    cell.detailTextLabel.text = company.stockPrice;
    [cell.imageView setImage:company.companyImage];
    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //        DAO *dataManager = [DAO dataManager];
        //        Company *company = [self.companyList objectAtIndex:indexPath.row];
        //REMOVING THE DATA FROM SQL MANAGER FOR PERSISTANCE
        //        [dataManager.sqlManager deleteCompany:company.companyId];
        
        [[DAO dataManager] deleteCompany:[self.companyList objectAtIndex:indexPath.row]];
        //        [self.companyList removeObjectAtIndex:indexPath.row];
        
        [tableView reloadData]; // tell table to refresh now
        if(self.companyList.count < 1){
            [self.tableView setHidden:YES];
            [self.emptyImage setHidden:NO];
            [self.emptyLabel setHidden:NO];
            [self.addButtonOutlet setHidden:NO];
        } else {
            [self.tableView setHidden:NO];
            [self.emptyImage setHidden:YES];
            [self.emptyLabel setHidden:YES];
            [self.addButtonOutlet setHidden:YES];
        }

    }
    
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    
    //CODE FOR REARRANGING TABLE BASED ON ARRAY POSITION
    Company *company = [self.companyList objectAtIndex:fromIndexPath.row];
    [self.companyList removeObjectAtIndex:fromIndexPath.row];
    [self.companyList insertObject:company atIndex:toIndexPath.row];
    
    //    DAO *dataManager = [DAO dataManager];
    //    [dataManager.sqlManager rearrangeCompanyFrom:(int)(fromIndexPath.row + 1) to:(int)(toIndexPath.row + 1)]; DOESNT WORK AS INTENDED
    [tableView reloadData];
}



// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}



#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DAO *dataManager = [DAO dataManager];
    
    if (tableView.editing == YES) {
        Company *company = self.companyList[[indexPath row]];
        self.addEditViewController = [[AddEditViewController alloc]init];
        self.addEditViewController.title = @"Edit Company";
        
        //Setting a specific company and edit mode switch for the add/edit view controller to use
        dataManager.companyToEdit = company;
        self.addEditViewController.editMode = YES;
        
        [self.navigationController pushViewController:self.addEditViewController animated:YES];
        return;
    }
    
    self.productListViewController = [[ProductListViewController alloc]init];
    self.productListViewController.company = self.companyList[[indexPath row]];
    [self.navigationController
     pushViewController:self.productListViewController
     animated:YES];
}





- (IBAction)emptyAddButtonAction:(id)sender {
    self.addEditViewController = [[AddEditViewController alloc]init];
    self.addEditViewController.title = @"New Company";
    self.addEditViewController.editMode = NO;
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    [self.navigationController pushViewController:self.addEditViewController animated:YES];

}

- (IBAction)redoButtonAction:(id)sender {
    DAO *dataManager = [DAO dataManager];
    [dataManager.managedObjectContext redo];
    [dataManager loadData];
    [self.tableView reloadData];
}

- (IBAction)undoButtonAction:(id)sender {
    DAO *dataManager = [DAO dataManager];
    [dataManager.managedObjectContext undo];
    [dataManager loadData];
    [self.tableView reloadData];
    NSLog(@"CODE");
}








/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [_emptyImage release];
    [_emptyLabel release];
    [_addButtonOutlet release];
    [_tableView release];
    [_redoButtonOutlet release];
    [_undoButtonOutlet release];
    [super dealloc];
}

@end