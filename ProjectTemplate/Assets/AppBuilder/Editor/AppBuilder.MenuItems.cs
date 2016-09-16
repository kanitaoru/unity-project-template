using UnityEditor;

public static partial class AppBuilder
{
    [MenuItem("Build/Dev/OSX")]
    static void BuildForOSX_Dev()
    {
        Build(BuildTarget.StandaloneOSXUniversal, "dev");
    }

    [MenuItem("Build/Release/OSX")]
    static void BuildForOSX_Release()
    {
        Build(BuildTarget.StandaloneOSXUniversal, "release");
    }

    [MenuItem("Build/Dev/iOS")]
    static void BuildForIOS_Dev()
    {
        Build(BuildTarget.iOS, "dev");
    }

    [MenuItem("Build/Release/iOS")]
    static void BuildForIOS_Release()
    {
        Build(BuildTarget.iOS, "release");
    }

    [MenuItem("Build/Dev/Android")]
    static void BuildForAndroid_Dev()
    {
        Build(BuildTarget.Android, "dev");
    }

    [MenuItem("Build/Release/Android")]
    static void BuildForAndroid_Release()
    {
        Build(BuildTarget.Android, "release");
    }
}
