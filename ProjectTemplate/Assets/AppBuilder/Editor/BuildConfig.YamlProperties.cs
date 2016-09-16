// Config/dev.yaml などに対応するプロパティを定義する
// yamlからデシリアライズされる
public partial class BuildConfig
{
    public class ConfigForIOS
    {
        public string XcodeProjectName { get; set; }
        public string BundleIdentifier { get; set; }
        public string ProvisioningProfile { get; set; }
    }

    public class ConfigForAndroid
    {
        public string AndroidProjectName { get; set; }
        public string ApkFileName { get; set; }
        public string BundleIdentifier { get; set; }
        public string KeystoreName {get; set;}
        public string KeystorePassword {get; set;}
        public string KeyAliasName {get; set;}
        public string KeyAliasPassword {get; set;}
    }

    public string CompanyName { get; set; }
    public string ProductName { get; set; }
    public string AppVersion { get; set; }
    public int BuildNumber { get; set; }
    public string[] DefineSymbols { get; set; }
    public bool DevelopmentMode { get; set; }
    public ConfigForIOS Ios { get; set; }
    public ConfigForAndroid Android { get; set; }
}
