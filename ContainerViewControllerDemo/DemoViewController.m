//
//  DemoViewController.m
//  ContainerViewControllerDemo
//
//  Created by zhangchao on 15/5/8.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "DemoViewController.h"
#import "DemoModelController.h"

NSString *const IDInStoryBoard = @"ChildViewController";
@interface DemoViewController ()
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *deleteButton;

- (IBAction)addChild:(UIBarButtonItem *)sender;
- (IBAction)deleteCurrentChild:(UIBarButtonItem *)sender;
@end

@implementation DemoViewController

/* override from super*/
- (void)setupScrollModel {
    self.modelController = [[DemoModelController alloc] initWithId:IDInStoryBoard];
    self.targetCacheSize = 5;
    [self rebuildCacheStackStartWith:0];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
    // Do any additional setup after loading the view.
    self.barTintColor = [UIColor lightGrayColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)addChild:(UIBarButtonItem *)sender {
    // TODO 1. add model title array
    NSUInteger count = self.modelController.count;
    NSString *newTitle = [NSString stringWithFormat:@"New %ld", count + 1];
    [self.modelController addChildWithTitle:newTitle];
    // TODO 2. reload current childViewController if need.

}

- (IBAction)deleteCurrentChild:(UIBarButtonItem *)sender {
    // TODO 1. add model title array
    [self.modelController delChildAtIndex:self.currentIndex];
    // TODO 2. reload current childViewController if need.
}
@end
