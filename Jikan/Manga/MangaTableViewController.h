#import <UIKit/UIKit.h>

@interface MangaTableViewController : UITableViewController <UISearchBarDelegate>

@property (nonatomic, strong) NSArray *topMangas; // Holds the manga data
@property (nonatomic, strong) UISearchBar *searchBar;

@end
