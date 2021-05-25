#import <UIKit/UIKit.h>
#import "MainCollectionViewCell.h"


@interface MainZLSwipeChildView : UIView

- (void)setModel:(LonelyStationUser*)lonelyUser andTarget:(id<MainCollectionViewCellDelegate>)target andIndexPath:(NSIndexPath*)indexPath;

@end
