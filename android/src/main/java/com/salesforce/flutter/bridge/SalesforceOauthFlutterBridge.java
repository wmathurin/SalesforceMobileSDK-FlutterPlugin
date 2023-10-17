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
package com.salesforce.flutter.bridge;

import static com.salesforce.flutter.ui.SalesforceFlutterActivity.getRestClient;
import static com.salesforce.flutter.ui.SalesforceFlutterActivity.setRestClient;

import androidx.annotation.NonNull;

import com.salesforce.androidsdk.app.SalesforceSDKManager;
import com.salesforce.androidsdk.rest.RestClient;
import com.salesforce.androidsdk.util.SalesforceSDKLogger;
import com.salesforce.flutter.ui.SalesforceFlutterActivity;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * Flutter bridge for oauth operations
 */
public class SalesforceOauthFlutterBridge extends SalesforceFlutterBridge {

    public static final String PREFIX = "oauth";

    private enum Method {
        getAuthCredentials,
        getClientInfo,
        authenticate,
        logoutCurrentUser
    }

    private static final String TAG = "SalesforceOauthFlutterBridge";

    public SalesforceOauthFlutterBridge(SalesforceFlutterActivity currentActivity) {
        super(currentActivity);
    }

    @Override
    public String getPrefix() {
        return PREFIX;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        final Method method = Method.valueOf(call.method.substring(PREFIX.length() + 1));
        switch(method) {
            case getAuthCredentials:
                getAuthCredentials(result);
                break;
            case getClientInfo:
                getClientInfo(result);
                break;
            case authenticate:
                authenticate(result);
                break;
            case logoutCurrentUser:
                logoutCurrentUser(result);
                break;
            default:
                result.notImplemented();
        }
    }

    protected void getAuthCredentials(final MethodChannel.Result callback) {
        try {
            // Getting restClient
            final RestClient restClient = getRestClient();
            if (restClient == null) {
                callback.error("No restClient - getAuthCredentials", null, null);
                return;
            }

            callback.success(restClient.getJSONCredentials().toString());

        } catch (Exception exception) {
            returnError("sendRequest failed", exception, callback);
        }
    }

    protected void getClientInfo(final MethodChannel.Result callback) {
        try {
            // Getting restClient
            final RestClient restClient = getRestClient();
            if (restClient == null) {
                callback.error("No restClient - getClientInfo", null, null);
                return;
            }

            callback.success(restClient.getClientInfo().toString());

        } catch (Exception exception) {
            returnError("sendRequest failed", exception, callback);
        }
    }

    protected void authenticate(final MethodChannel.Result callback) {
        SalesforceSDKManager.getInstance().getClientManager().getRestClient(currentActivity, client -> {
            setRestClient(client);
            callback.success("success");
        });
    }

    protected void logoutCurrentUser(final MethodChannel.Result callback) {
        try {
            SalesforceSDKManager.getInstance().logout(currentActivity);
            callback.success("success");
        } catch (Exception exception) {
            returnError("sendRequest failed", exception, callback);
        }
    }

    private void returnError(String message, Exception exception, MethodChannel.Result callback) {
        SalesforceSDKLogger.e(TAG, message, exception);
        callback.error(exception.getClass().getName(), exception.getMessage(), exception);
    }
}