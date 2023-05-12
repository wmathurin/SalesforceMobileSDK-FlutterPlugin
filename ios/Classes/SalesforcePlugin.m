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

 #import "SfpluginPlugin.h"
 #import "SFOauthFlutterBridge.h"
 #import "SFNetFlutterBridge.h"
 #import "SFSmartStoreFlutterBridge.h"
 #import "SFSmartSyncFlutterBridge.h"

 @interface SfpluginPlugin ()

 @property(nonatomic, strong, readwrite) SFOauthFlutterBridge* oauthBridge;
 @property(nonatomic, strong, readwrite) SFNetFlutterBridge* networkBridge;
 @property(nonatomic, strong, readwrite) SFSmartStoreFlutterBridge* smartstoreBridge;
 @property(nonatomic, strong, readwrite) SFSmartSyncFlutterBridge* smartsyncBridge;

 @end

 @implementation SfpluginPlugin
 + (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
     FlutterMethodChannel* channel = [FlutterMethodChannel
                                      methodChannelWithName:@"com.salesforce.flutter.SalesforcePlugin"
                                      binaryMessenger:[registrar messenger]];
     SfpluginPlugin* instance = [[SfpluginPlugin alloc] init];
     [registrar addMethodCallDelegate:instance channel:channel];
 }

 - (instancetype) init {
     self = [super init];
     if (self) {
         self.oauthBridge = [SFOauthFlutterBridge new];
         self.networkBridge = [SFNetFlutterBridge new];
         self.smartstoreBridge = [SFSmartStoreFlutterBridge new];
         self.smartsyncBridge = [SFSmartSyncFlutterBridge new];
     }
     return self;
 }

 - (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
     NSString* prefix = [call.method componentsSeparatedByString:@"#"][0];

     for (SFNetFlutterBridge* bridge in @[self.oauthBridge, self.networkBridge, self.smartstoreBridge, self.smartsyncBridge]) {
         if ([prefix isEqualToString:bridge.prefix]) {
             [bridge handleMethodCall:call result:result];
             return;
         }
     }
     result(FlutterMethodNotImplemented);
 }

 @end