/*
 Copyright (c) 2018-present, salesforce.com, inc. All rights reserved.

 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "SalesforceSDKCore.h"
#import "SFNetFlutterBridge.h"
#import <SalesforceSDKCore/NSDictionary+SFAdditions.h>
#import <SalesforceSDKCore/SFRestAPI+Blocks.h>

// Private constants
static NSString * const kMethodArg       = @"method";
static NSString * const kPathArg         = @"path";
static NSString * const kEndPointArg     = @"endPoint";
static NSString * const kQueryParams     = @"queryParams";
static NSString * const kHeaderParams    = @"headerParams";
static NSString * const kfileParams      = @"fileParams";
static NSString * const kFileMimeType    = @"fileMimeType";
static NSString * const kFileUrl         = @"fileUrl";
static NSString * const kFileName        = @"fileName";
static NSString * const kReturnBinary    = @"returnBinary";
static NSString * const kEncodedBody     = @"encodedBody";
static NSString * const kContentType     = @"contentType";
static NSString * const kHttpContentType = @"content-type";

static NSString * const kInstanceUrl = @"instanceUrl";
static NSString * const kLoginUrl = @"loginUrl";
static NSString * const kAccountName = @"accountName";
static NSString * const kUsername = @"username";
static NSString * const kUserId = @"userId";
static NSString * const kOrgId = @"orgId";
static NSString * const kFirstName = @"firstName";
static NSString * const kLastName = @"lastName";
static NSString * const kDisplayName = @"displayName";
static NSString * const kEmail = @"email";
static NSString * const kPhotoUrl = @"photoUrl";
static NSString * const kThumbnailUrl = @"thumbnailUrl";

@implementation SFNetFlutterBridge

- (NSString*) prefix {
    return @"network";
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"network#sendRequest" isEqualToString:call.method]) {
        [self sendRequest:call.arguments result:result];
    } else if ([@"network#getClientInfo" isEqualToString:call.method]) {
        [self getClientInfo:call.arguments result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void) sendRequest:(NSDictionary *)argsDict result:(FlutterResult)callback
{
    SFRestMethod method = [SFRestRequest sfRestMethodFromHTTPMethod:[argsDict nonNullObjectForKey:kMethodArg]];
    NSString* endPoint = [argsDict nonNullObjectForKey:kEndPointArg];
    NSString* path = [argsDict nonNullObjectForKey:kPathArg];
    NSDictionary* queryParams = [argsDict nonNullObjectForKey:kQueryParams];
    NSMutableDictionary* headerParams = [argsDict nonNullObjectForKey:kHeaderParams];
    NSDictionary* fileParams = [argsDict nonNullObjectForKey:kfileParams];
    BOOL returnBinary = [argsDict nonNullObjectForKey:kReturnBinary] != nil && [[argsDict nonNullObjectForKey:kReturnBinary] boolValue];
    SFRestRequest* request = nil;

    // Sets HTTP body explicitly for a POST, PATCH or PUT request.
    if (method == SFRestMethodPOST || method == SFRestMethodPATCH || method == SFRestMethodPUT) {
        request = [SFRestRequest requestWithMethod:method path:path queryParams:nil];
        [request setCustomRequestBodyDictionary:queryParams contentType:@"application/json"];
    } else {
        request = [SFRestRequest requestWithMethod:method path:path queryParams:queryParams];
    }

    // Custom headers
    [request setCustomHeaders:headerParams];
    if (endPoint) {
        [request setEndpoint:endPoint];
    }

    // Files post
    if (fileParams) {

        // File params expected to be of the form:
        // {<fileParamNameInPost>: {fileMimeType:<someMimeType>, fileUrl:<fileUrl>, fileName:<fileNameForPost>}}
        for (NSString* fileParamName in fileParams) {
            NSDictionary* fileParam = fileParams[fileParamName];
            NSString* fileMimeType = [fileParam nonNullObjectForKey:kFileMimeType];
            NSString* fileUrl = [fileParam nonNullObjectForKey:kFileUrl];
            NSString* fileName = [fileParam nonNullObjectForKey:kFileName];
            NSData* fileData = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileUrl]];
            [request addPostFileData:fileData paramName:fileParamName fileName:fileName mimeType:fileMimeType params:fileParam];
        }
    }

    // Disable parsing for binary request
    if (returnBinary) {
        request.parseResponse = NO;
    }


    [[SFRestAPI sharedInstance] sendRequest:request
                                   failureBlock:^(id  _Nullable response, NSError * _Nullable e, NSURLResponse * _Nullable rawResponse) {
                                          // XXX callback(@[RCTMakeError(@"sendRequest failed", e, nil)]);
        if ([e.userInfo[@"error"]  isEqual: @"invalid_client"]) {
            [SFUserAccountManager.sharedInstance logout];
        } else {
            callback([FlutterError errorWithCode:@"ERROR" message:@"sendRequest failed" details:e.description]);
        }
                                      }
                                   successBlock:^(id  _Nullable response, NSURLResponse * _Nullable rawResponse) {
                                      id result;

                                      // Binary response
                                      if (returnBinary) {
                                          result = @{
                                                     kEncodedBody:[((NSData*) response) base64EncodedStringWithOptions:0],
                                                     kContentType:((NSHTTPURLResponse*) rawResponse).allHeaderFields[kHttpContentType]
                                                     };
                                      }
                                      // Some response
                                      else if (response) {
                                          if ([response isKindOfClass:[NSDictionary class]]) {
                                              result = response;
                                          } else if ([response isKindOfClass:[NSArray class]]) {
                                              result = response;
                                          } else {
                                              NSData* responseAsData = response;
                                              NSStringEncoding encodingType = rawResponse.textEncodingName == nil ? NSUTF8StringEncoding :  CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)rawResponse.textEncodingName));
                                              result = [[NSString alloc] initWithData:responseAsData encoding:encodingType];
                                          }
                                      }
                                      // No response
                                      else {
                                          result = nil;
                                      }

                                      callback(result);
                                  }
     ];
}

- (void) getClientInfo:(NSDictionary *)argsDict result:(FlutterResult)callback
{
    SFUserAccount* currentUser = SFUserAccountManager.sharedInstance.currentUser;
    if (currentUser == nil) {
        callback([FlutterError errorWithCode:@"ERROR" message:@"No userAccount" details:nil]);
    } else {
        id useInfo = @{
                   kInstanceUrl: currentUser.idData.idUrl.absoluteString,
                   kUsername: currentUser.idData.username,
                   kUserId: currentUser.idData.userId,
                   kOrgId: currentUser.idData.orgId,
                   kFirstName: currentUser.idData.firstName,
                   kLastName: currentUser.idData.lastName,
                   kDisplayName: currentUser.idData.displayName,
                   kEmail: currentUser.idData.email,
                   kPhotoUrl: currentUser.idData.pictureUrl.absoluteString,
                   kThumbnailUrl: currentUser.idData.thumbnailUrl.absoluteString,
                };
        callback(useInfo);
    }
}

@end