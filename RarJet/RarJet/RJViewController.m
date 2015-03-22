//
//  ViewController.m
//  RarJet
//
//  Created by Mert Buran on 22/03/15.
//  Copyright (c) 2015 Mert Buran. All rights reserved.
//

#import "RJViewController.h"
#import "RJDataManager.h"
#import "RJLocationManager.h"
#import "RJLocation.h"

static NSString * const RJCellIdentifier = @"autocompletionCell";
static const CGFloat RJVerticalTextFieldMargin = 20.f; //arbitrary value, design spec

@interface RJViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UITextField *fromTextField; //delegate is set from IB
@property (weak, nonatomic) IBOutlet UITextField *toTextField;
@property (nonatomic, strong) RJDataManager *dataManager;
@property (nonatomic, strong) NSArray *dataSourceArray; //RJLocation objects
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomSpaceConstraint;
@property (nonatomic, weak) IBOutlet UITableView *autocompleteTableView;
@end

@implementation RJViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [RJLocationManager manager];
    self.dataManager = [[RJDataManager alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)searchWithString:(NSString *)searchString {
    __weak typeof(self) weakSelf = self;
    [self.dataManager fetchResultsWithSearchString:searchString
                                           success:^(NSDictionary *responseDictionary) {
                                               __strong typeof(self) strongSelf = weakSelf;
                                               if (responseDictionary == nil) {
                                                   strongSelf.dataSourceArray = nil;
                                               }
                                               else {
                                                   NSMutableArray *tempArray = [NSMutableArray array];
                                                   for (NSDictionary *locationDict in responseDictionary) {
                                                       RJLocation *location = [[RJLocation alloc] initWithDictionary:locationDict];
                                                       [tempArray addObject:location];
                                                   }
                                                   strongSelf.dataSourceArray = [tempArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                                                       RJLocation *loc1 = obj1;
                                                       RJLocation *loc2 = obj2;
                                                       return loc1.distance > loc2.distance;
                                                   }];
                                               }
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   [strongSelf.autocompleteTableView reloadData];
                                               });
                                           }
                                           failure:^(NSError *error) {
//                                               __strong typeof(self) strongSelf = weakSelf;
//                                               UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
//                                                                                                              message:@"An error occurred"
//                                                                                                       preferredStyle:UIAlertControllerStyleAlert];
//                                               UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
//                                                                                                     handler:^(UIAlertAction *action) {
//                                                                                                         
//                                                                                                     }];
//                                               [alert addAction:defaultAction];
//                                               [strongSelf presentViewController:alert animated:YES completion:nil];
                                           }];
}

- (void)setNavigationBarHidden:(BOOL)hide {
    if ([self.navigationController isNavigationBarHidden] == !hide) {
        [self.navigationController setNavigationBarHidden:hide animated:YES];
    }
}

- (UITextField *)activeTextField {
    if ([self.fromTextField isFirstResponder]) {
        return self.fromTextField;
    }
    else if ([self.toTextField isFirstResponder]) {
        return self.toTextField;
    }
    else {
        return nil;
    }
}

#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self setNavigationBarHidden:YES];
    CGRect textFieldFrame = [textField.superview convertRect:textField.frame toView:self.mainScrollView];
    CGFloat textFieldYPos = textFieldFrame.origin.y - RJVerticalTextFieldMargin;
    [self.mainScrollView setContentOffset:CGPointMake(0.f, textFieldYPos) animated:YES];
    
    if (textField.text.length > 0) {
        [self searchWithString:textField.text];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.mainScrollView setContentOffset:CGPointMake(0.f, -self.mainScrollView.contentInset.top) animated:YES];
    [self.dataManager cancelNetworkOperations];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSMutableString *currentText = [NSMutableString stringWithString:[textField text]];
    [currentText replaceCharactersInRange:range withString:string];
    [self searchWithString:currentText];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.fromTextField] && [self.toTextField canBecomeFirstResponder] && self.toTextField.text.length == 0) {
        [self.toTextField becomeFirstResponder];
    }
    else {
        [self setNavigationBarHidden:NO];
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *selectedLocationName = [[self.dataSourceArray objectAtIndex:indexPath.row] fullName];
    [[self activeTextField] setText:selectedLocationName];
    [self textFieldShouldReturn:[self activeTextField]];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSourceArray.count > 0 ? self.dataSourceArray.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RJCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RJCellIdentifier];
    }
    [self configureCell:cell withRowIndex:indexPath.row];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell withRowIndex:(NSUInteger)rowIndex {
    //just in case, we do not want to crash because of index out of bounds
    NSString *cellText = rowIndex >= self.dataSourceArray.count ? @"" : [[self.dataSourceArray objectAtIndex:rowIndex] fullName];
    cell.textLabel.text = cellText;
}

#pragma mark - Keyboard animation handling

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardEndFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval keyboardAnimationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSInteger keyboardAnimationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGFloat tableViewHeight = CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.fromTextField.bounds) - CGRectGetHeight(keyboardEndFrame) - 4.f*RJVerticalTextFieldMargin;
    self.tableViewHeightConstraint.constant = tableViewHeight;
    self.tableViewBottomSpaceConstraint.constant = CGRectGetHeight(keyboardEndFrame);
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:keyboardAnimationDuration
                          delay:0.f
                        options:(keyboardAnimationCurve<<16)
                     animations:^{
                         __strong typeof(self) strongSelf = weakSelf;
                         strongSelf.autocompleteTableView.alpha = 1.f;
                         [strongSelf.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSTimeInterval keyboardAnimationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSInteger keyboardAnimationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    self.tableViewHeightConstraint.constant = 0.f;
    self.tableViewBottomSpaceConstraint.constant = 0.f;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:keyboardAnimationDuration
                          delay:0.f
                        options:(keyboardAnimationCurve<<16)
                     animations:^{
                         __strong typeof(self) strongSelf = weakSelf;
                         strongSelf.autocompleteTableView.alpha = 0.f;
                         [strongSelf.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

@end
