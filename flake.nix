{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      system = "x86_64-linux";
      pkgs = (
        import nixpkgs {
          inherit system;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
        }
      );
    in
    {
      devShells.${system}.default =
        with pkgs;
        let
          buildToolsVersion = "34.0.0";
          android = androidenv.composeAndroidPackages {
            platformVersions = [ "34" ];
            buildToolsVersions = [ buildToolsVersion ];
            abiVersions = [ "arm64-v8a" ];
            includeNDK = true;
            ndkVersion = "23.1.7779620";
            cmakeVersions = [ "3.22.1" ];
          };
          jdk = jdk17_headless;
        in
        mkShell rec {
          JAVA_HOME = jdk.home;
          ANDROID_SDK_ROOT = "${android.androidsdk}/libexec/android-sdk";
          GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${ANDROID_SDK_ROOT}/build-tools/${buildToolsVersion}/aapt2";

          nativeBuildInputs = [
            nixfmt-rfc-style
            android.androidsdk
            android.platform-tools
            jdk
            flutter
          ];
        };
    };
}
