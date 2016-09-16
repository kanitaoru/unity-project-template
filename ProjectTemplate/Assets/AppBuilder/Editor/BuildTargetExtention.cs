using UnityEditor;

public static class BuildTargetExtention
{
    public static BuildTargetGroup ToBuildTargetGroup(this BuildTarget target)
    {
        switch (target)
        {
            case BuildTarget.StandaloneOSXIntel:
            case BuildTarget.StandaloneOSXIntel64:
            case BuildTarget.StandaloneOSXUniversal:
            case BuildTarget.StandaloneWindows:
                return BuildTargetGroup.Standalone;

            case BuildTarget.iOS:
                return BuildTargetGroup.iOS;

            case BuildTarget.Android:
                return BuildTargetGroup.Android;

            default:
                throw new System.ArgumentException(string.Format("対応していないBuildTarget: " + target));
        }
    }
}
