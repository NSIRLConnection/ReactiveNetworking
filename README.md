# ReactiveNetworking

ReactiveNetworking is a Cocoa and Cocoa Touch framework for interacting with some API via HTTP, built using
[AFNetworking](https://github.com/AFNetworking/AFNetworking),
[Mantle](https://github.com/MantleFramework/Mantle), and
[ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa).

Most of the code is shamelessly copied from [Github's OctoKit](https://github.com/octokit/octokit.objc).

# Usage

Let's assume an API, that returns for `GET /users/plu` the following
JSON response:

```json
{
    "user": {
        "id": 42,
        "login": "plu",
        "name": "Johannes Plunien"
    }
}
```

The model the user object:

```objc
@interface RNReadmeUser : RNObject

@property (nonatomic, copy, readonly) NSString *login;
@property (nonatomic, copy, readonly) NSString *name;

@end

@implementation RNReadmeUser

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *mapping = @{@"login": @"login",
                              @"name": @"name"};
    return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:mapping];
}

@end
```

The API client:

```objc
@interface RNReadmeClient : RNClient

- (RACSignal *)fetchUser:(NSString *)username;

@end

@implementation RNReadmeClient

- (instancetype)initWithBaseURL:(NSURL *)url
{
    if (url == nil) url = [NSURL URLWithString:@"https://api.example.com"];
    self = [super initWithBaseURL:url];
    if (self) {
        [self registerHTTPOperationClass:AFJSONRequestOperation.class];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
    }
    return self;
}

- (RACSignal *)fetchUser:(NSString *)username
{
    NSString *path = [NSString stringWithFormat:@"/users/%@", username];
    NSURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil];
    return [self enqueueRequest:request
                    resultClass:RNReadmeUser.class
                       keyPaths:@[@"user"]];
}

@end
```

How to use it:

```objc
RNReadmeClient *client = [[RNReadmeClient alloc] initWithBaseURL:nil];
[[client fetchUser:@"plu"] subscribeNext:^(RNResponse *response) {
    NSLog(@"%@", response.parsedResult);
}];
```

It will log something like:

```
<RNReadmeUser: 0x10052a140> {
    login = plu;
    name = "Johannes Plunien";
    objectID = 42;
}
```

# License (MIT)

Copyright (c) 2014 Johannes Plunien

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
