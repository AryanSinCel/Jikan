#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MangaDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *mangaImage;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString *mangaId; // Manga ID for fetching details
@property (strong, nonatomic) NSArray *chapters; // Array to hold chapter data

@end

NS_ASSUME_NONNULL_END
