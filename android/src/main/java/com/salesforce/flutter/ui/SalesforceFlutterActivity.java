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
import android.widget.Toast;

import com.salesforce.androidsdk.app.SalesforceSDKManager;
import com.salesforce.androidsdk.mobilesync.util.MobileSyncLogger;
import com.salesforce.androidsdk.rest.ClientManager;
import com.salesforce.androidsdk.rest.RestClient;
import com.salesforce.androidsdk.ui.SalesforceActivityDelegate;
import com.salesforce.androidsdk.ui.SalesforceActivityInterface;
import com.salesforce.androidsdk.util.SalesforceSDKLogger;

import io.flutter.embedding.android.FlutterActivity;

/**
 * Super class for all Salesforce flutter activities.
 */
public abstract class SalesforceFlutterActivity extends FlutterActivity implements SalesforceActivityInterface {

    private static final String TAG = "SfFlutterActivity";

    // Delegate
    private final SalesforceActivityDelegate delegate;

    // Rest client
    private RestClient client;
    private ClientManager clientManager;

    protected SalesforceFlutterActivity() {
        super();
        this.delegate = new SalesforceActivityDelegate(this);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        SalesforceSDKLogger.i(TAG, "onCreate called");
        super.onCreate(savedInstanceState);
        // Get clientManager
        this.clientManager = buildClientManager();

        // Delegate create
        this.delegate.onCreate();
    }

    @Override
    public void onResume() {
        super.onResume();
        this.delegate.onResume(false);
        // will call this.onResume(RestClient client) with a null client
    }

    @Override
    public void onResume(RestClient c) {
        // Called from delegate with null

        // Get client (if already logged in)
        try {
            this.client = clientManager.peekRestClient();
        } catch (ClientManager.AccountInfoNotFoundException e) {
            this.client = null;
        }

        // Not logged in
        if (this.client == null) {
            onResumeNotLoggedIn();
        }

        // Logged in
        else {
            // Done
        }
    }

    @Override
    public void onUserInteraction() {
        this.delegate.onUserInteraction();
    }

    @Override
    public void onPause() {
        super.onPause();
        this.delegate.onPause();
    }

    @Override
    public void onDestroy() {
        this.delegate.onDestroy();
        super.onDestroy();
    }

    @Override
    public boolean onKeyUp(int keyCode, KeyEvent event) {
        return this.delegate.onKeyUp(keyCode, event) || super.onKeyUp(keyCode, event);
    }

    @Override
    public void onLogoutComplete() {
    }

    @Override
    public void onUserSwitched() {
        this.delegate.onResume(true);
    }

    /**
     * @return true if you want login to happen as soon as activity is loaded
     *         false if you want do login at a later point
     */
    public boolean shouldAuthenticate() {
        return true;
    }

    /**
     * Called if shouldAuthenticate() returned true but device is offline
     */
    public void onErrorAuthenticateOffline() {
        Toast t = Toast.makeText(this, "Should authenticate but is offline" /* XXX move to resource*/, Toast.LENGTH_LONG);
        t.show();
    }

    /**
     * Called when resuming activity and user is not authenticated
     */
    private void onResumeNotLoggedIn() {
        // Need to be authenticated
        if (shouldAuthenticate()) {

            // Online
            if (SalesforceSDKManager.getInstance().hasNetwork()) {
                SalesforceSDKLogger.i(TAG, "onResumeNotLoggedIn - should authenticate/online - authenticating");
                login();
            }

            // Offline
            else {
                SalesforceSDKLogger.w(TAG, "onResumeNotLoggedIn - should authenticate/offline - can not proceed");
                onErrorAuthenticateOffline();
            }
        }

        // Does not need to be authenticated
        else {
            MobileSyncLogger.i(TAG, "onResumeNotLoggedIn - should not authenticate");
        }
    }

    public RestClient getRestClient() {
        return this.client;
    }

    protected void setRestClient(RestClient restClient) {
        this.client = restClient;
    }

    protected ClientManager buildClientManager() {
        return new ClientManager(this, SalesforceSDKManager.getInstance().getAccountType(),
                SalesforceSDKManager.getInstance().getLoginOptions(),
                SalesforceSDKManager.getInstance().shouldLogoutWhenTokenRevoked());
    }

    protected void login() {
        SalesforceSDKLogger.i(TAG, "login called");
        this.clientManager.getRestClient(this, client -> {
            if (client == null) {
                MobileSyncLogger.i(TAG, "login callback triggered with null client");
                logout();
            } else {
                MobileSyncLogger.i(TAG, "login callback triggered with actual client");
                recreate();
            }
        });
    }

    public void logout() {
        SalesforceSDKLogger.i(TAG, "logout called");
        SalesforceSDKManager.getInstance().logout(this, true);
    }
}