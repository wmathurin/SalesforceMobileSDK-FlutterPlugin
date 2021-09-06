package com.salesforce.flutter.salesforce_example

import com.salesforce.androidsdk.app.SalesforceSDKManager
import io.flutter.app.FlutterApplication

class MainApplication : FlutterApplication() {

    override fun onCreate() {
        super.onCreate()
        SalesforceSDKManager.initNative(applicationContext, MainActivity::class.java)
    }
}