package de.robv.android.xposed;

public final class XposedHelpers {
    private XposedHelpers() {}
    public static Object callStaticMethod(Class<?> clazz, String methodName, Object... args) { return null; }
    public static Object callMethod(Object obj, String methodName, Object... args) { return null; }
    public static XC_MethodHook.Unhook findAndHookMethod(Class<?> clazz, String methodName, Object... parameterTypesAndCallback) { return null; }
    public static XC_MethodHook.Unhook findAndHookMethod(String className, ClassLoader classLoader, String methodName, Object... parameterTypesAndCallback) { return null; }
}
