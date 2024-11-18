#import "RecommendViewController.h"
#import "TableViewCell.h"
#import "AnimeView.h"

@interface RecommendViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray *recommendations;
@end

@implementation RecommendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.animeId) {
        self.recommendationTableView.delegate = self;
        self.recommendationTableView.dataSource = self;
        [self fetchRecommendations];
    }
}

- (void)fetchRecommendations {
    NSString *urlString = @"";
    if([self.mode isEqualToString:@"anime"]){
       urlString = [NSString stringWithFormat:@"https://api.jikan.moe/v4/anime/%@/recommendations", self.animeId];
    }
    if([self.mode isEqualToString:@"manga"]){
        urlString = [NSString stringWithFormat:@"https://api.jikan.moe/v4/manga/%@/recommendations", self.animeId];
    }
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSError *jsonError;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (!jsonError) {
                NSArray *results = json[@"data"];
                
                if ([results isKindOfClass:[NSArray class]] && results.count > 0) {
                    self.recommendations = results;
                } else {
                    [self fetchDefaultRecommendations];
                    return;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.recommendationTableView reloadData];
                });
            }
        } else {
            NSLog(@"Error fetching recommendations: %@", error.localizedDescription);
        }
    }];
    
    [dataTask resume];
}

// Method to fetch default recommendations for mal_id 1
- (void)fetchDefaultRecommendations {
    NSString *defaultUrlString = @"https://api.jikan.moe/v4/anime/1/recommendations";
    NSURL *defaultUrl = [NSURL URLWithString:defaultUrlString];
    NSURLSessionDataTask *defaultDataTask = [[NSURLSession sharedSession] dataTaskWithURL:defaultUrl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSError *jsonError;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (!jsonError) {
                NSArray *defaultResults = json[@"data"];
                
                if ([defaultResults isKindOfClass:[NSArray class]]) {
                    self.recommendations = defaultResults;
                } else {
                    self.recommendations = @[];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.recommendationTableView reloadData];
                });
            }
        } else {
            NSLog(@"Error fetching default recommendations: %@", error.localizedDescription);
        }
    }];
    
    [defaultDataTask resume];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.recommendations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
       
    NSDictionary *recommendation = self.recommendations[indexPath.row];
    NSDictionary *entry = recommendation[@"entry"];
    NSString *title = entry[@"title"];
    
    NSString *imageURLString = entry[@"images"][@"jpg"][@"image_url"];
    NSURL *imageURL = [NSURL URLWithString:imageURLString];

    // Asynchronous image loading
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession] dataTaskWithURL:imageURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    TableViewCell *updateCell = [tableView cellForRowAtIndexPath:indexPath];
                    if (updateCell) {
                        updateCell.animeImage.image = image;
                        updateCell.label.text = title ? : @"No Title Available";
                        [updateCell setNeedsLayout];
                    }
                });
            }
        }
    }];
    [downloadTask resume];
    
    return cell;
}



@end
