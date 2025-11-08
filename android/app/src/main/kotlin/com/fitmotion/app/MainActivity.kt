package com.fitmotion.app

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import android.os.Bundle
import android.util.Log

class MainActivity: FlutterFragmentActivity() {
    
    private val TAG = "FitMotionActivity"
    
    override fun onCreate(savedInstanceState: Bundle?) {
        try {
            Log.d(TAG, "MainActivity onCreate started")
            super.onCreate(savedInstanceState)
            Log.d(TAG, "MainActivity onCreate completed successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Error in MainActivity onCreate", e)
            // Don't let the activity fail completely
            try {
                super.onCreate(savedInstanceState)
            } catch (fallbackError: Exception) {
                Log.e(TAG, "Critical error in MainActivity onCreate fallback", fallbackError)
            }
        }
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        try {
            Log.d(TAG, "Configuring Flutter engine for A55 compatibility")
            GeneratedPluginRegistrant.registerWith(flutterEngine)
            
            // A55 specific optimizations
            configureForMidRangeDevice(flutterEngine)
            
            Log.d(TAG, "Flutter engine configuration completed")
        } catch (e: Exception) {
            Log.e(TAG, "Error configuring Flutter engine", e)
            // Fallback to basic configuration
            try {
                GeneratedPluginRegistrant.registerWith(flutterEngine)
            } catch (fallbackError: Exception) {
                Log.e(TAG, "Critical error in Flutter engine fallback configuration", fallbackError)
            }
        }
    }
    
    private fun configureForMidRangeDevice(flutterEngine: FlutterEngine) {
        try {
            // Memory and performance optimizations for A55
            Log.d(TAG, "Applying A55 device optimizations")
            
            // Enable hardware acceleration if available
            window?.setFlags(
                android.view.WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED,
                android.view.WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED
            )
            
            Log.d(TAG, "A55 optimizations applied successfully")
        } catch (e: Exception) {
            Log.w(TAG, "Some A55 optimizations failed, continuing with defaults", e)
        }
    }
    
    override fun onResume() {
        try {
            Log.d(TAG, "MainActivity onResume")
            super.onResume()
        } catch (e: Exception) {
            Log.e(TAG, "Error in MainActivity onResume", e)
            try {
                super.onResume()
            } catch (fallbackError: Exception) {
                Log.e(TAG, "Critical error in onResume fallback", fallbackError)
            }
        }
    }
    
    override fun onPause() {
        try {
            Log.d(TAG, "MainActivity onPause")
            super.onPause()
        } catch (e: Exception) {
            Log.e(TAG, "Error in MainActivity onPause", e)
        }
    }
    
    override fun onDestroy() {
        try {
            Log.d(TAG, "MainActivity onDestroy")
            super.onDestroy()
        } catch (e: Exception) {
            Log.e(TAG, "Error in MainActivity onDestroy", e)
        }
    }
}