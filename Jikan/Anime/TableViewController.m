#import "TableViewController.h"
#import "AnimeView.h"
#import "TableViewCell.h"

@interface TableViewController () <UISearchBarDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSArray *searchResults; 

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.topAnimes = @[];
    self.searchResults = @[];
    
    // Set up search bar
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Search Animes";
    self.navigationItem.titleView = self.searchBar;
    
    [self fetchTopAnimes];
}

- (void)fetchTopAnimes {
    NSURL *url = [NSURL URLWithString:@"https://api.jikan.moe/v4/top/anime"];
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSError *jsonError;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (!jsonError) {
                NSArray *results = json[@"data"];
                if ([results isKindOfClass:[NSArray class]]) {
                    self.topAnimes = results;
                } else {
                    self.topAnimes = @[];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        } else {
            NSLog(@"Error fetching data: %@", error.localizedDescription);
        }
    }];
    
    [dataTask resume];
}

- (void)fetchSearchResults:(NSString *)query {
    NSString *encodedQuery = [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *urlString = [NSString stringWithFormat:@"https://api.jikan.moe/v4/anime?q=%@", encodedQuery];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSError *jsonError;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (!jsonError) {
                NSArray *results = json[@"data"];
                if ([results isKindOfClass:[NSArray class]]) {
                    self.searchResults = results;
                } else {
                    self.searchResults = @[];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        } else {
            NSLog(@"Error fetching data: %@", error.localizedDescription);
        }
    }];
    
    [dataTask resume];
}

#pragma mark - UISearchBarDelegate methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length > 0) {
        [self fetchSearchResults:searchText];
    } else {
        self.searchResults = @[];
        [self.tableView reloadData];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder]; // Dismiss the keyboard
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchBar.text.length > 0 && self.searchResults.count > 0) {
        return self.searchResults.count;
    }
    return self.topAnimes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
      
    NSDictionary *anime;
    if (self.searchBar.text.length > 0 && self.searchResults.count > 0) {
        anime = self.searchResults[indexPath.row];
    } else {
        anime = self.topAnimes[indexPath.row];
    }
    
    NSString *imageUrl = [anime[@"images"][@"jpg"][@"large_image_url"] isKindOfClass:[NSNull class]] ? nil : anime[@"images"][@"jpg"][@"large_image_url"];
    

    // Load the image asynchronously
    if (imageUrl) {
        NSURL *url = [NSURL URLWithString:imageUrl];
        NSURLSessionDataTask *imageTask = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (data && !error) {
                UIImage *image = [UIImage imageWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    TableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                    if(cell){
                        cell.animeImage.image = image;
                        NSString *title = [anime[@"titles"][0][@"title"] isKindOfClass:[NSNull class]] ? @"Unknown Title" : anime[@"titles"][0][@"title"];
                        cell.label.text = title;
                    }
                });
            }
        }];
        
        [imageTask resume];
    } else {
        cell.textLabel.text = @"Image not available";
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showAnimeInfo"]) {
        AnimeView *view = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *selectedAnime;
        
        if (self.searchBar.text.length > 0 && self.searchResults.count > 0) {
            selectedAnime = self.searchResults[indexPath.row];
        } else {
            selectedAnime = self.topAnimes[indexPath.row];
            NSLog(@"Default :  %@",selectedAnime);
        }
        
        view.animeInfo = selectedAnime;
        
    }
}


@end
