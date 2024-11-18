#import "ReadingTableViewController.h"
#import "ReadingTableViewCell.h"
#import "MangaDetailViewController.h"

@interface ReadingTableViewController () <UISearchBarDelegate>

@property (nonatomic, strong) NSArray *filteredMangas; 

@end

@implementation ReadingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.filteredMangas = @[];
    
    // Initialize and set up search bar
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Search Manga";
    self.navigationItem.titleView = self.searchBar;
    
    [self.tableView reloadData];
}

- (void)fetchMangaWithSearchText:(NSString *)searchText {
    NSDictionary *headers = @{ @"x-rapidapi-key": @"800e15615amshe0277d164f315b7p133ea3jsn601a7fd1b919",
                                @"x-rapidapi-host": @"mangaverse-api.p.rapidapi.com" };

    NSString *urlString = [NSString stringWithFormat:@"https://mangaverse-api.p.rapidapi.com/manga/search?text=%@&nsfw=true&type=all",
                           [searchText stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error fetching data: %@", error);
            return;
        }
        
        NSError *jsonError;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (jsonError) {
            NSLog(@"JSON Error: %@", jsonError);
            return;
        }
        
        self.filteredMangas = json[@"data"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
    
    [dataTask resume];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredMangas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    if (self.filteredMangas.count > 0) {
        NSDictionary *manga = self.filteredMangas[indexPath.row];
        
        NSString *imageUrl = manga[@"thumb"];
        cell.imageView.image = nil;
        
        NSURL *url = [NSURL URLWithString:imageUrl];
        NSURLSessionDataTask *imageTask = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (data && !error) {
                UIImage *image = [UIImage imageWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    UITableViewCell *updateCell = [tableView cellForRowAtIndexPath:indexPath];
                    if (updateCell) {
                        updateCell.imageView.image = image;
                        updateCell.imageView.contentMode = UIViewContentModeScaleAspectFill;
                        updateCell.imageView.clipsToBounds = YES;

                        // Set title
                        updateCell.textLabel.text = manga[@"title"];
                        updateCell.textLabel.numberOfLines = 2;
                        updateCell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
                        [updateCell setNeedsLayout];
                    }
                });
            }
        }];
        
        [imageTask resume];
    } else {
        cell.textLabel.text = @"No results found";
        cell.imageView.image = nil;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200;
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length > 0) {
        [self fetchMangaWithSearchText:searchText];
    } else {
        self.filteredMangas = @[];
        [self.tableView reloadData];
    }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier]isEqualToString:@"showChapters"]){
        MangaDetailViewController *view = [segue destinationViewController];
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        view.mangaId = self.filteredMangas[path.row][@"id"];
        NSLog(@"%@",self.filteredMangas[path.row][@"id"]);
    }
}

@end
