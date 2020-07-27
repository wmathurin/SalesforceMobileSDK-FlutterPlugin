package com.salesforce.flutter.salesforcepluginexample;

import java.util.Map;
import android.os.Bundle;
import com.salesforce.androidsdk.app.SalesforceSDKManager;
import com.salesforce.androidsdk.push.PushNotificationInterface;
import com.salesforce.flutter.SalesforcePlugin;
import com.salesforce.flutter.ui.SalesforceFlutterActivity;

public class MainActivity extends SalesforceFlutterActivity implements PushNotificationInterface {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        initSalesforceSDK();
        super.onCreate(savedInstanceState);

        SalesforcePlugin.registerWith(registrarFor("com.salesforce.flutter.SalesforcePlugin"));
    }
    /**
     * @return true if you want login to happen when application launches
     * false otherwise
     */
    @Override
    public boolean shouldAuthenticate() {
        return true;
    }

    private void initSalesforceSDK() {
        SalesforceSDKManager.initNative(getApplicationContext(), MainActivity.class);
        SalesforceSDKManager.getInstance().setPushNotificationReceiver(this);

        /*
         * Uncomment the following line to enable IDP login flow. This will allow the user to
         * either authenticate using the current app or use a designated IDP app for login.
         * Replace 'idpAppURIScheme' with the URI scheme of the IDP app meant to be used.
         */
        //SmartSyncSDKManager.getInstance().setIDPAppURIScheme(idpAppURIScheme);

        /*
         * Uncomment the following line to enable browser based login. This will use a
         * Chrome custom tab to login instead of the default WebView. You will also need
         * to uncomment a few lines of code in SalesforceSDK library project's AndroidManifest.xml.
         */
        // SmartSyncSDKManager.getInstance().setBrowserLoginEnabled(true);

        /*
         * Un-comment the line below to enable push notifications in this app.
         * Replace 'pnInterface' with your implementation of 'PushNotificationInterface'.
         * Add your Google package ID in 'bootonfig.xml', as the value
         * for the key 'androidPushNotificationClientId'.
         */
        //SmartSyncSDKManager.getInstance().setPushNotificationReceiver(pnInterface);
    }

    @Override
    public void onPushMessageReceived(Map<String, String> data) {

    }
}


