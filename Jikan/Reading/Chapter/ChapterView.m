//
//  ChapterView.m
//

#import "ChapterView.h"
#import "ChapterCell.h"

@interface ChapterView ()
@property (nonatomic, strong) NSMutableDictionary *imageCache;
@end

@implementation ChapterView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageCache = [NSMutableDictionary dictionary];

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    
    if (self.chapterID) {
        [self fetchChapterImage];
    }
}

- (void)fetchChapterImage {
    NSDictionary *headers = @{ @"x-rapidapi-key": @"800e15615amshe0277d164f315b7p133ea3jsn601a7fd1b919",
                               @"x-rapidapi-host": @"mangaverse-api.p.rapidapi.com" };

    NSString *urlString = [NSString stringWithFormat:@"https://mangaverse-api.p.rapidapi.com/manga/image?id=%@", self.chapterID];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:headers];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error) {
                                                        NSLog(@"Error fetching chapters: %@", error.localizedDescription);
                                                        return;
                                                    }

                                                    NSError *jsonError;
                                                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                                                    if (jsonError) {
                                                        NSLog(@"JSON Parsing Error: %@", jsonError.localizedDescription);
                                                        return;
                                                    }

                                                    NSArray *dataArray = json[@"data"];
                                                    NSMutableArray *imageLinks = [NSMutableArray array];
                                                    for (NSDictionary *item in dataArray) {
                                                        NSString *link = item[@"link"];
                                                        if (link) {
                                                            [imageLinks addObject:link];
                                                        }
                                                    }
                                                    self.chapterImages = [imageLinks copy];

                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        [self.tableView reloadData];
                                                    });
                                                }];
    [dataTask resume];
}

- (void)adjustCellHeightForImage:(UIImage *)image inCell:(ChapterCell *)cell {
    CGFloat aspectRatio = image.size.height / image.size.width;
    CGFloat cellWidth = self.tableView.frame.size.width;
    CGFloat calculatedHeight = cellWidth * aspectRatio;

    [cell.chapterImg.heightAnchor constraintEqualToConstant:calculatedHeight].active = YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chapterImages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChapterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.chapterImg.image = [UIImage imageNamed:@"placeholder"];
    
    NSString *imageURL = self.chapterImages[indexPath.row];

    if (self.imageCache[imageURL]) {
        cell.chapterImg.image = self.imageCache[imageURL];
    } else {
        NSURL *url = [NSURL URLWithString:imageURL];
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                NSLog(@"Failed to load image: %@", error.localizedDescription);
                return;
            }
            
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                self.imageCache[imageURL] = image;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    ChapterCell *updateCell = (id)[tableView cellForRowAtIndexPath:indexPath];
                    if (updateCell) {
                        updateCell.chapterImg.image = image;

                        // Adjust cell height dynamically
                        [self adjustCellHeightForImage:image inCell:updateCell];
                        
                        // Trigger layout recalculation
                        [tableView beginUpdates];
                        [tableView endUpdates];
                    }
                });
            }
        }];
        [task resume];
    }

    return cell;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

@end
