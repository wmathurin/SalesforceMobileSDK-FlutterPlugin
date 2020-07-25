package com.salesforce.flutter.sfplugin;

import android.app.Activity;
import android.content.Context;

import com.salesforce.flutter.sfplugin.bridge.SalesforceFlutterBridge;
import com.salesforce.flutter.sfplugin.bridge.SalesforceNetFlutterBridge;
import com.salesforce.flutter.sfplugin.bridge.SalesforceOauthFlutterBridge;
import com.salesforce.flutter.sfplugin.bridge.SmartStoreFlutterBridge;
import com.salesforce.flutter.sfplugin.bridge.SmartSyncFlutterBridge;
import com.salesforce.flutter.sfplugin.ui.SalesforceFlutterActivity;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MethodCallHandlerImpl implements MethodChannel.MethodCallHandler {

    private final Context context;
    private Activity activity;

    private SalesforceOauthFlutterBridge oauthBridge;
    private SalesforceNetFlutterBridge networkBridge;
    private SmartStoreFlutterBridge smartStoreFlutterBridge;
    private SmartSyncFlutterBridge smartSyncFlutterBridge;

    MethodCallHandlerImpl(Context context, Activity activity) {
        this.context = context;
        this.activity = activity;

        this.networkBridge = new SalesforceNetFlutterBridge((SalesforceFlutterActivity) activity);
        this.oauthBridge = new SalesforceOauthFlutterBridge((SalesforceFlutterActivity) activity);
        this.smartStoreFlutterBridge = new SmartStoreFlutterBridge((SalesforceFlutterActivity) activity);
        this.smartSyncFlutterBridge = new SmartSyncFlutterBridge((SalesforceFlutterActivity) activity);
    }

    void setActivity(Activity activity) {
        this.activity = activity;


    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        String prefix = call.method.substring(0, call.method.indexOf("#"));

        for (SalesforceFlutterBridge bridge : new SalesforceFlutterBridge[] { oauthBridge, networkBridge, smartStoreFlutterBridge, smartSyncFlutterBridge}) {
            if (call.method.startsWith(bridge.getPrefix() + "#")) {
                bridge.onMethodCall(call, result);
                return;
            }
        }
        result.notImplemented();
    }

}
