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
package com.salesforce.flutter;

import android.app.Activity;
import android.content.Context;

import androidx.annotation.NonNull;

import com.salesforce.flutter.bridge.SalesforceFlutterBridge;
import com.salesforce.flutter.bridge.SalesforceNetFlutterBridge;
import com.salesforce.flutter.bridge.SalesforceOauthFlutterBridge;
import com.salesforce.flutter.bridge.SmartStoreFlutterBridge;
import com.salesforce.flutter.bridge.SmartSyncFlutterBridge;
import com.salesforce.flutter.ui.SalesforceFlutterActivity;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * Salesforce flutter plugin
 */
public class SalesforcePlugin implements MethodCallHandler, FlutterPlugin, ActivityAware {

    private static final String CHANNEL_NAME = "com.salesforce.flutter.SalesforcePlugin";
    private static final String TAG = "SalesforcePlugin";


    private Activity activity;
    private Context context;

    private SalesforceOauthFlutterBridge oauthBridge;
    private SalesforceNetFlutterBridge networkBridge;
    private SmartStoreFlutterBridge smartStoreFlutterBridge;
    private SmartSyncFlutterBridge smartSyncFlutterBridge;

    private MethodChannel methodChannel;

    public SalesforcePlugin() { }

    public SalesforcePlugin(Activity activity) {
        this.setActivity(activity);
    }

    /**
     * Plugin registration.
     */
    @SuppressWarnings("deprecation")
    public static void registerWith(io.flutter.plugin.common.PluginRegistry.Registrar registrar) {
        final SalesforcePlugin plugin = new SalesforcePlugin(registrar.activity());
        plugin.onAttachedToEngine(registrar.context(), registrar.messenger());
    }

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        onAttachedToEngine(binding.getApplicationContext(), binding.getBinaryMessenger());
    }

    private void onAttachedToEngine(Context applicationContext, BinaryMessenger messenger) {
        this.context = applicationContext;
        this.methodChannel = new MethodChannel(messenger, CHANNEL_NAME);
        this.methodChannel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        this.context = null;
        this.methodChannel.setMethodCallHandler(null);
        this.methodChannel = null;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        this.setActivity(binding.getActivity());
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        onAttachedToActivity(binding);
    }

    @Override
    public void onDetachedFromActivity() {
        this.activity = null;
        this.methodChannel.setMethodCallHandler(null);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        final String prefix = call.method.substring(0, call.method.indexOf("#"));
        for (SalesforceFlutterBridge bridge : new SalesforceFlutterBridge[]{ this.oauthBridge, this.networkBridge, this.smartStoreFlutterBridge, this.smartSyncFlutterBridge }) {
            if (prefix.equals(bridge.getPrefix())) {
                bridge.onMethodCall(call, result);
                return;
            }
        }
        result.notImplemented();
    }

    public void setActivity(Activity activity) {
        if (activity != null){
            this.activity = activity;
            this.networkBridge = new SalesforceNetFlutterBridge((SalesforceFlutterActivity) this.activity);
            this.oauthBridge = new SalesforceOauthFlutterBridge((SalesforceFlutterActivity) this.activity);
            this.smartStoreFlutterBridge = new SmartStoreFlutterBridge((SalesforceFlutterActivity) this.activity);
            this.smartSyncFlutterBridge = new SmartSyncFlutterBridge((SalesforceFlutterActivity) this.activity);
        }
    }
}