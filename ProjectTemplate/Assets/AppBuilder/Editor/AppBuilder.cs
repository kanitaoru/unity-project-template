using System;
using UnityEngine;
using UnityEditor;
using UnityEditor.Callbacks;
using UnityEditor.iOS.Xcode;
using System.Linq;
using System.IO;

public static partial class AppBuilder
{
    // usage:
    // /Applications/Unity/Unity.app/Contents/MacOS/Unity -batchmode -projectPath PATH/TO/PROJECT -buildTarget ios -env dev -executeMethod AppBuilder.BuildByCommand -logFile 2>&1 -quit
    public static void BuildByCommand()
    {
        var args = CommandArgs.Get();
        EditorUserBuildSettings.exportAsGoogleAndroidProject = args.ExportAsProject;
        Debug.Log("BuildEnv:" + args.Env);

        var config = BuildConfig.Load(args.Env);

        BuildTarget target;

        // -buildTarget オプションを指定すればコマンドからの起動でも判定できる
        #if UNITY_IOS
        target = BuildTarget.iOS;
        #elif UNITY_ANDROID
        target = BuildTarget.Android;
        #else
        target = BuildTarget.StandaloneOSXUniversal;
        #endif

        // もしコマンドライン引数にビルド番号が指定されていたら優先して使う
        if (args.BuildNumber != 0)
        {
            config.BuildNumber = args.BuildNumber;
        }

        Build(config, target);
    }

    /// PreBuild for UnityCloudBuild
    /// CloudBuildの設定から PreBuildを設定、DefineSymbolにenvを設定
    /// Build自体はCloudBuilder.Builderが自動で行うので、Applyまでしておく
    public static void PreBuild()
    {
        Debug.Log("PreBuild");

        BuildConfig config = null;

        #if DEV
        config = BuildConfig.Load("dev");
        #else
        config = BuildConfig.Load("release");
        #endif

        var target = BuildTarget.StandaloneOSXUniversal;

        #if UNITY_IOS
        target = BuildTarget.iOS;
        #elif UNITY_ANDROID
        target = BuildTarget.Android;
        #else
        target = BuildTarget.StandaloneOSXUniversal;
        #endif

        config.Apply(target);
    }

    public static void Build(BuildTarget target, string env)
    {
        var config = BuildConfig.Load(env);
        Build(config, target);
    }

    public static void Build(BuildConfig config, BuildTarget target)
    {
        Debug.Log("Build for " + target + " " + config.Env);
        config.Apply(target);

        Directory.CreateDirectory(Path.GetDirectoryName(config.LocationPathName));

        var errorMessage = BuildPipeline.BuildPlayer(
                               levels: EditorBuildSettings.scenes.Select(s => s.path).ToArray(),
                               locationPathName: config.LocationPathName,
                               target: config.Target,
                               options: config.Options
                           );

        if (!string.IsNullOrEmpty(errorMessage))
        {
            Debug.LogError(errorMessage);
            throw new UnityException(errorMessage);
        }
    }

    [PostProcessBuild(1)]
    public static void OnPostProcessBuild(BuildTarget target, string path)
    {
        Debug.Log("Build Done. path: " + path);

        // Xcode向け設定
        if (target == BuildTarget.iOS)
        {
            ModifyXcodeProject(path);
        }
    }

    // Xcode向け設定
    // Note: Android向け設定なども増えてきたらビルドクラスを分けた方がすっきりしそう
    public static void ModifyXcodeProject(string path)
    {
        string projectPath = PBXProject.GetPBXProjectPath(path);
        var pbxProject = new PBXProject();
        pbxProject.ReadFromFile(projectPath);

        string targetGuid = pbxProject.TargetGuidByName(PBXProject.GetUnityTargetName());

        pbxProject.SetBuildProperty(targetGuid, "ENABLE_BITCODE", "NO");

        // 書き出し
        pbxProject.WriteToFile(projectPath);
    }

    struct CommandArgs
    {
        public string Env { get; set; }
        public bool ExportAsProject { get; set; }
        public int BuildNumber { get; set; }

        public static CommandArgs Get()
        {
            var ret = new CommandArgs();

            var args = System.Environment.GetCommandLineArgs();

            for (int i = 0; i < args.Length; ++i)
            {
                var arg = args[i];

                switch (arg)
                {
                    case "-env":
                        if (args.Length - 1 <= i || args[i + 1].StartsWith("-"))
                        {
                            throw new ArgumentException("'-env' オプションには引数が必要です");
                        }
                        ret.Env = args[i + 1];
                        break;

                    case "-exportAsProject":
                        ret.ExportAsProject = true;
                        break;

                    case "-buildNumber":
                        if (args.Length - 1 <= i || args[i + 1].StartsWith("-"))
                        {
                            throw new ArgumentException("'-buildNumber' オプションには引数が必要です");
                        }
                        ret.BuildNumber = int.Parse(args[i + 1]);
                        break;
                }
            }

            return ret;
        }
    }
}
