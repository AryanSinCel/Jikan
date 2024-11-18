#import "MangaTableViewController.h"
#import "MangaViewController.h"
#import "MangaTableViewCell.h"


@interface MangaTableViewController ()

@property (nonatomic, strong) NSArray *filteredMangas; 

@end

@implementation MangaTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.topMangas = @[];
    self.filteredMangas = @[];
    
    // Initialize and set up search bar
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Search Manga";
    self.navigationItem.titleView = self.searchBar;
    
    [self fetchTopMangas];
}

- (void)fetchTopMangas {
    NSURL *url = [NSURL URLWithString:@"https://api.jikan.moe/v4/top/manga"];
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSError *jsonError;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (!jsonError) {
                self.topMangas = json[@"data"];
                self.filteredMangas = self.topMangas;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        } else {
            NSLog(@"Error fetching data: %@", error);
        }
    }];
    
    [dataTask resume];
}

- (void)fetchMangaWithSearchText:(NSString *)searchText {
    NSString *urlString;
    if (searchText.length > 0) {
        urlString = [NSString stringWithFormat:@"https://api.jikan.moe/v4/manga?q=%@", [searchText stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet]];
    } else {
        urlString = @"https://api.jikan.moe/v4/top/manga";
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSError *jsonError;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (!jsonError) {
                self.topMangas = json[@"data"];
                self.filteredMangas = self.topMangas;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        } else {
            NSLog(@"Error fetching data: %@", error);
        }
    }];
    
    [dataTask resume];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredMangas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    MangaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // Configure the cell
    NSDictionary *manga = self.filteredMangas[indexPath.row];
    NSString *imageUrl = manga[@"images"][@"jpg"][@"large_image_url"];
    
//    cell.imageView.image = nil;
    
    NSURL *url = [NSURL URLWithString:imageUrl];
    NSURLSessionDataTask *imageTask = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            UIImage *image = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                MangaTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                if(cell){
                    cell.mangaImageView.image = image;
                    cell.label.text = manga[@"titles"][0][@"title"];
                }
            });
        }
    }];
    
    [imageTask resume];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200;
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self fetchMangaWithSearchText:searchText];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showMangaInfo"]) {
        MangaViewController *view = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *selectedManga = self.filteredMangas[indexPath.row];
        view.mangaInfo = selectedManga;
    }
}

@end
