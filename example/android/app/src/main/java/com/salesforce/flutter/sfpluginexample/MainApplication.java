package com.salesforce.flutter.sfpluginexample;

import com.salesforce.androidsdk.smartsync.app.SmartSyncSDKManager;

import io.flutter.app.FlutterApplication;

public class MainApplication extends FlutterApplication {

    @Override
    public void onCreate() {
        super.onCreate();
        SmartSyncSDKManager.initNative(getApplicationContext(), EmbeddingV1Activity.class);

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

}
