package com.hadobedo.hdcwebviewbypass;

import android.app.Activity;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;

import de.robv.android.xposed.IXposedHookLoadPackage;
import de.robv.android.xposed.XC_MethodHook;
import de.robv.android.xposed.XposedBridge;
import de.robv.android.xposed.XposedHelpers;
import de.robv.android.xposed.callbacks.XC_LoadPackage;

public final class HookEntry implements IXposedHookLoadPackage {
    private static final String TARGET = "com.thehomedepotca";
    private static final String BASE_SPLASH = "com.thehomedepotca.app.splash.activity.BaseSplashActivity";
    private static final String HOME_ACTIVITY = "com.thehomedepotca.app.home.activities.HomeActivity";

    @Override
    public void handleLoadPackage(XC_LoadPackage.LoadPackageParam lpparam) {
        if (!TARGET.equals(lpparam.packageName)) {
            return;
        }

        XposedBridge.log("HDWebViewSpoof: active in " + lpparam.processName);
        hookUnsupportedDialog(lpparam.classLoader);
    }

    private static void hookUnsupportedDialog(ClassLoader loader) {
        try {
            XposedHelpers.findAndHookMethod(BASE_SPLASH, loader, "showNotSupportedDialog",
                    String.class, new XC_MethodHook() {
                        @Override
                        protected void beforeHookedMethod(MethodHookParam param) {
                            XposedBridge.log("HDWebViewSpoof: bypassing showNotSupportedDialog: " + param.args[0]);
                            final Object splash = param.thisObject;
                            final ClassLoader loader = splash.getClass().getClassLoader();
                            new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
                                @Override
                                public void run() {
                                    try {
                                        XposedBridge.log("HDWebViewSpoof: starting HomeActivity");
                                        Activity activity = (Activity) splash;
                                        Class<?> home = Class.forName(HOME_ACTIVITY, false, loader);
                                        activity.startActivity(new Intent(activity, home));
                                        activity.finish();
                                    } catch (Throwable t) {
                                        XposedBridge.log("HDWebViewSpoof: start HomeActivity failed: " + t);
                                    }
                                }
                            }, 300);
                            param.setResult(null);
                        }
                    });
        } catch (Throwable t) {
            XposedBridge.log("HDWebViewSpoof: cannot hook unsupported dialog: " + t);
        }
    }
}
