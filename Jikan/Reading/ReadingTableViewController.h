//
//  ReadingTableViewController.h
//  Jikan
//
//  Created by Celestial on 29/10/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReadingTableViewController : UITableViewController<UISearchBarDelegate>

@property (nonatomic, strong) NSArray *topMangas; 
@property (nonatomic, strong) UISearchBar *searchBar;


@end

NS_ASSUME_NONNULL_END
