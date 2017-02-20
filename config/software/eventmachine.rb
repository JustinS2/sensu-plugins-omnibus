name "eventmachine"

dependency "libstdc++"
dependency "ruby"
dependency "ruby-windows-devkit" if windows?

source git: "https://github.com/eventmachine/eventmachine.git"

default_version "v1.2.2"

version "v1.2.2" do
  source git: "https://github.com/eventmachine/eventmachine.git"
end

build do
  env = with_standard_compiler_flags(with_embedded_path)
  patch_env = env.dup

  if aix?
    patch_env["PATH"] = "/opt/freeware/bin/:#{patch_env['ENV']}"
  end

  # these are needed to get eventmachine to compile on Solaris
  # but eventmachine segfaults at runtime :(
  #env['CXX'] = "g++ -m64"
  #env['cppflags'] = "-D_XOPEN_SOURCE=700"

  command "gem install --no-document rake-compiler", env: env
  command "rake clean", env: env

  windows_install_prefix = "C:\\opt\\sensu\\embedded"

  # disable C++ extensions so we don't need to compile them on platforms
  # we're only using pure_ruby with
  if aix? || solaris?
    patch source: "disable-extensions.patch", plevel: 1, env: patch_env
  elsif windows?
    command "rake compile -- --with-ssl-dir=#{windows_install_prefix}\\bin", env: env
  else
    command "rake compile", env: env
  end

  command "rake gem", env: env

  compile_options = ''

  if windows?
    compile_options << " --with-ssl-dir=#{windows_install_prefix}\\bin"
    compile_options << " --with-ssl-lib=#{windows_install_prefix}\\lib"
    compile_options << " --with-ssl-include=#{windows_install_prefix}\\include"
    compile_options << " --with-opt-include=#{windows_install_prefix}\\include"
  end

  command "gem install --no-document pkg/eventmachine-1.2.2.gem -- #{compile_options}", env: env
end
