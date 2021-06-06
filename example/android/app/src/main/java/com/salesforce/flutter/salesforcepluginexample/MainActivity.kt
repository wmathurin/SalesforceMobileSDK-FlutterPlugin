package com.salesforce.flutter.salesforcepluginexample

import android.os.Bundle
import com.salesforce.androidsdk.app.SalesforceSDKManager
import com.salesforce.flutter.ui.SalesforceFlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : SalesforceFlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        SalesforceSDKManager.initNative(applicationContext, SalesforceFlutterActivity::class.java)
        super.onCreate(savedInstanceState)
    }
}