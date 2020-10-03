package com.salesforce.flutter.salesforcepluginexample;

import androidx.annotation.NonNull;

import com.salesforce.flutter.ui.SalesforceFlutterActivity;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends SalesforceFlutterActivity {

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
    }
}


