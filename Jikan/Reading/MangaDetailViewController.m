#import "MangaDetailViewController.h"
#import "Chapter/ChapterView.h"

@interface MangaDetailViewController ()
@property(nonatomic,strong) NSDictionary *mangaDetails;
@end

@implementation MangaDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    [self fetchMangaDetails];
}

- (void)fetchMangaDetails {
    NSDictionary *headers = @{ @"x-rapidapi-key": @"800e15615amshe0277d164f315b7p133ea3jsn601a7fd1b919",
                                @"x-rapidapi-host": @"mangaverse-api.p.rapidapi.com" };

    NSString *urlString = [NSString stringWithFormat:@"https://mangaverse-api.p.rapidapi.com/manga?id=%@", self.mangaId];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:headers];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error fetching manga details: %@", error);
            return;
        }

        NSError *jsonError;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (jsonError) {
            NSLog(@"JSON Error: %@", jsonError);
            return;
        }

        self.mangaDetails = json[@"data"];
        NSString *thumbUrl = self.mangaDetails[@"thumb"];

        [self loadMangaImageFromURL:thumbUrl];

        [self fetchChapters];
    }];

    [dataTask resume];
}

- (void)loadMangaImageFromURL:(NSString *)urlString {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mangaImage.contentMode = UIViewContentModeScaleAspectFit;
    });

    NSURL *imageUrl = [NSURL URLWithString:urlString];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:imageUrl
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error loading image: %@", error.localizedDescription);
            return;
        }

        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.mangaImage.image = image;
                });
            }
        }
    }];

    [dataTask resume];
}


- (void)fetchChapters {
    NSDictionary *headers = @{ @"x-rapidapi-key": @"800e15615amshe0277d164f315b7p133ea3jsn601a7fd1b919",
                                @"x-rapidapi-host": @"mangaverse-api.p.rapidapi.com" };

    NSString *urlString = [NSString stringWithFormat:@"https://mangaverse-api.p.rapidapi.com/manga/chapter?id=%@", self.mangaId];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:headers];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error fetching chapters: %@", error);
            return;
        }

        NSError *jsonError;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (jsonError) {
            NSLog(@"JSON Error: %@", jsonError);
            return;
        }

        self.chapters = json[@"data"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];

    [dataTask resume];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chapters.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChapterCell" forIndexPath:indexPath];

    NSDictionary *chapter = self.chapters[indexPath.row];
    cell.textLabel.text = chapter[@"title"];

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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([[segue identifier]isEqualToString:@"showChapterImg"]){
        ChapterView *view = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSLog(@"%@",self.chapters[indexPath.row][@"id"]);
        view.chapterID = self.chapters[indexPath.row][@"id"];
        view.title = self.mangaDetails[@"title"];
        NSLog(@"%@",self.mangaDetails[@"title"]);
    }
    
}


@end
