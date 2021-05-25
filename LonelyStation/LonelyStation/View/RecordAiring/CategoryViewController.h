//
//  CategoryVC.h
//  LonelyStation
//
//  Created by zk on 16/8/13.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMViewController.h"
#import "RecordAiringVM.h"

@protocol CategoryViewSelectProtocol <NSObject>

- (void)didSelectCategory:(RecordCategoryObj*)obj andController:(id)controller;

@end
@interface CategoryViewController : EMViewController

@property (nonatomic,assign)id<CategoryViewSelectProtocol> delegate;
@end
