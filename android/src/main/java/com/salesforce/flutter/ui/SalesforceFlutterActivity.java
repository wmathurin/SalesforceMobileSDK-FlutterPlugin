/*
 * Copyright (c) 2018-present, salesforce.com, inc.
 * All rights reserved.
 * Redistribution and use of this software in source and binary forms, with or
 * without modification, are permitted provided that the following conditions
 * are met:
 * - Redistributions of source code must retain the above copyright notice, this
 * list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 * - Neither the name of salesforce.com, inc. nor the names of its contributors
 * may be used to endorse or promote products derived from this software without
 * specific prior written permission of salesforce.com, inc.
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */
package com.salesforce.flutter.ui;

import android.os.Bundle;
import android.view.KeyEvent;

import com.salesforce.androidsdk.rest.RestClient;
import com.salesforce.androidsdk.ui.SalesforceActivityDelegate;
import com.salesforce.androidsdk.ui.SalesforceActivityInterface;
import com.salesforce.androidsdk.util.SalesforceSDKLogger;

import io.flutter.embedding.android.FlutterActivity;

/**
 * Super class for all Salesforce flutter activities.
 */
public abstract class SalesforceFlutterActivity extends FlutterActivity implements SalesforceActivityInterface {

    private static final String TAG = "SalesforceFlutterActivity";

    // Delegate
    private final SalesforceActivityDelegate delegate;

    // Rest client
    private RestClient client;

    protected SalesforceFlutterActivity() {
        super();
        this.delegate = new SalesforceActivityDelegate(this);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        SalesforceSDKLogger.i(TAG, "onCreate called");
        super.onCreate(savedInstanceState);
        delegate.onCreate();
    }

    @Override
    public void onResume() {
        SalesforceSDKLogger.i(TAG, "onResume called");
        super.onResume();
        delegate.onResume(true);
    }

    @Override
    public void onResume(RestClient restClient) {
        this.client = restClient;
    }

    @Override
    public void onUserInteraction() {
        delegate.onUserInteraction();
    }

    @Override
    public void onPause() {
        SalesforceSDKLogger.i(TAG, "onPause called");
        super.onPause();
        delegate.onPause();
    }

    @Override
    public void onDestroy() {
        SalesforceSDKLogger.i(TAG, "onDestroy called");
        delegate.onDestroy();
        super.onDestroy();
    }

    @Override
    public boolean onKeyUp(int keyCode, KeyEvent event) {
        return delegate.onKeyUp(keyCode, event) || super.onKeyUp(keyCode, event);
    }

    @Override
    public void onLogoutComplete() { }

    @Override
    public void onUserSwitched() {
        delegate.onResume(true);
    }

    public RestClient getRestClient() {
        return this.client;
    }
}