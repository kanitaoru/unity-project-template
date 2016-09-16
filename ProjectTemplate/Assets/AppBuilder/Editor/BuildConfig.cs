using System.IO;
using UnityEngine;
using UnityEditor;

public partial class BuildConfig
{
    const string ConfigDir = "../BuildFiles/Configs";
    const string AndroidKeystoreDir = "../BuildFiles/AndroidKeystore";
    const string ExportDir = "../Build";

    static readonly string[] RSP_FILE_PATHs = new string[3] { "Assets/smcs.rsp", "Assets/gmcs.rsp", "Assets/us.rsp" };
    const char DEFINE_DELIMITER = ';';
    const string RSP_DEFINE_OPTION = "-define:";

    public string Env { get; protected set; }
    public BuildTarget Target { get; protected set; }
    public string LocationPathName
    {
        get
        {
            string output;

            switch (this.Target)
            {
                case BuildTarget.iOS:
                    output = this.Ios.XcodeProjectName;
                    break;

                case BuildTarget.Android:
                    if (EditorUserBuildSettings.exportAsGoogleAndroidProject)
                    {
                        output = this.Android.AndroidProjectName;
                    }
                    else
                    {
                        output = this.Android.ApkFileName;
                    }
                    break;

                default:
                    output = this.ProductName;
                    break;
            }

            return Path.Combine(ExportDir, Path.Combine(this.Target.ToString(), output));
        }
    }

    public BuildOptions Options
    {
        get
        {
            BuildOptions options = BuildOptions.ShowBuiltPlayer;

            if (DevelopmentMode)
            {
                options |= BuildOptions.Development;
            }

            if (EditorUserBuildSettings.exportAsGoogleAndroidProject || Target == BuildTarget.iOS)
            {
                options |= BuildOptions.AcceptExternalModificationsToPlayer;
            }

            return options;
        }
    }

    public static BuildConfig Load(string env)
    {
        var configFilePath = Path.Combine(ConfigDir, env + ".yaml");
        Debug.Log("Load build config file: " + configFilePath);

        if (!File.Exists(configFilePath))
        {
            throw new System.ArgumentException("対応する設定ファイルが見つかりませんでした。 path: " + configFilePath);
        }

        var yaml = System.IO.File.ReadAllText(configFilePath);
        var reader = new System.IO.StringReader(yaml);

        var deserializer = new YamlDotNet.Serialization.Deserializer(
            ignoreUnmatched: false,
            namingConvention: new YamlDotNet.Serialization.NamingConventions.UnderscoredNamingConvention()
        );

        var config = deserializer.Deserialize<BuildConfig>(reader);
        config.Env = env;

        return config;
    }

    public void Apply(BuildTarget target)
    {
        this.Target = target;

        PlayerSettings.companyName = this.CompanyName;
        PlayerSettings.productName = this.ProductName;
        PlayerSettings.bundleVersion = this.AppVersion;
        PlayerSettings.iOS.buildNumber = this.BuildNumber.ToString();
        PlayerSettings.Android.bundleVersionCode = this.BuildNumber;
        PlayerSettings.Android.keystoreName = Path.Combine(AndroidKeystoreDir, Path.ChangeExtension(this.Android.KeystoreName, "keystore"));
        PlayerSettings.Android.keystorePass = this.Android.KeystorePassword;
        PlayerSettings.Android.keyaliasName = this.Android.KeyAliasName;
        PlayerSettings.Android.keyaliasPass = this.Android.KeyAliasPassword;

        PlayerSettings.SetScriptingDefineSymbolsForGroup(target.ToBuildTargetGroup(), "");
        SaveRspFile(this.DefineSymbols);

        switch (target)
        {
            case BuildTarget.iOS:
                PlayerSettings.bundleIdentifier = this.Ios.BundleIdentifier;
                break;

            case BuildTarget.Android:
                PlayerSettings.bundleIdentifier = this.Android.BundleIdentifier;
                break;
        }
    }

    void SaveRspFile(string[] inDefineSymbols)
    {
        string appendDefine = "";
        foreach (var defineSymbol in inDefineSymbols)
        {
            if (string.IsNullOrEmpty(defineSymbol)) continue;
            appendDefine += defineSymbol + DEFINE_DELIMITER;
        }

        string rspOption = "";
        if (string.IsNullOrEmpty(appendDefine) == false)
        {
            rspOption += RSP_DEFINE_OPTION + appendDefine;
        }

        foreach (var path in RSP_FILE_PATHs)
        {
            using (StreamWriter writer = new StreamWriter(path))
            {
                writer.Write(rspOption);
            }
        }
    }
}
