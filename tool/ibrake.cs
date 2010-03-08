/* ****************************************************************************
*
* Copyright (c) Microsoft Corporation.
*
* This source code is subject to terms and conditions of the Microsoft Public License. A
* copy of the license can be found in the License.html file at the root of this distribution. If
* you cannot locate the Microsoft Public License, please send an email to
* ironruby@microsoft.com. By using this source code in any fashion, you are agreeing to be bound
* by the terms of the Microsoft Public License.
*
* You must not remove this notice, or any other, from this software.
*
*
* ***************************************************************************/
 
using System;
using Microsoft.Scripting;
using Microsoft.Scripting.Hosting;
using Microsoft.Scripting.Hosting.Shell;
using IronRuby;
using IronRuby.Hosting;
using IronRuby.Runtime;
using System.Dynamic.Utils;
using System.Linq;
 
internal sealed class RubyConsoleHost : ConsoleHost {
 
    protected override Type Provider {
        get { return typeof(RubyContext); }
    }
 
    protected override CommandLine/*!*/ CreateCommandLine() {
        return new RubyCommandLine();
    }
 
    protected override OptionsParser/*!*/ CreateOptionsParser() {
        return new RubyOptionsParser();
    }
 
    protected override LanguageSetup CreateLanguageSetup() {
        return Ruby.CreateRubySetup();
    }
 
    private static void SetHome() {
        try {
            PlatformAdaptationLayer platform = PlatformAdaptationLayer.Default;
            string homeDir = RubyUtils.GetHomeDirectory(platform);
            platform.SetEnvironmentVariable("HOME", homeDir);
        } catch (System.Security.SecurityException e) {
            // Ignore EnvironmentPermission exception
            if (e.PermissionType != typeof(System.Security.Permissions.EnvironmentPermission)) {
                throw;
            }
        }
    }
 
[STAThread]
[RubyStackTraceHidden]
    static int Main(string[] args) {
        SetHome();
        return new RubyConsoleHost().Run(new []{"irake"}.Concat(args).ToArray());
    }
}