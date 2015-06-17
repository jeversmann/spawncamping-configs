# Some stuff from Stack Overflow to detect OS
module OS
  class << self
    def windows?
      (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
    end

    def mac?
      (/darwin/ =~ RUBY_PLATFORM) != nil
    end

    def unix?
      !windows?
    end

    def linux?
      unix? and not mac?
    end
  end
end

def brew_install(package, *args)
  versions = `brew list #{package} --versions`
  options = args.last.is_a?(Hash) ? args.pop : {}

  if versions.empty?
    sh "brew install #{package} #{args.join ' '}"
  elsif options[:requires]
    installed_version = versions.split(/\n/).first.split(' ')[1]
    unless version_match?(options[:version], installed_version)
      sh "brew upgrade #{package} #{args.join ' '}"
    end
  end
end

def version_match?(requirement, version)
  # This is a hack, but it lets us avoid a gem dep for version checking.
  Gem::Dependency.new('', requirement).match?('', version)
end

def install_github_bundle(user, package)
  unless File.exist? File.expand_path("~/.vim/bundle/#{package}")
    sh "git clone https://github.com/#{user}/#{package} ~/.vim/bundle/#{package}"
  end
end

def step(description)
  description = "-- #{description} "
  description = description.ljust(80, '-')
  puts
  puts "\e[32m#{description}\e[0m"
end

def app_path(name)
  path = "/Applications/#{name}.app"
  ["~#{path}", path].each do |full_path|
    return full_path if File.directory?(full_path)
  end

  return nil
end

def app?(name)
  return !app_path(name).nil?
end

def get_backup_path(path)
  number = 1
  backup_path = "#{path}.bak"
  loop do
    if number > 1
      backup_path = "#{backup_path}#{number}"
    end
    if File.exists?(backup_path) || File.symlink?(backup_path)
      number += 1
      next
    end
    break
  end
  backup_path
end

def link_file(original_filename, symlink_filename)
  original_path = File.expand_path(original_filename)
  symlink_path = File.expand_path(symlink_filename)
  if File.exists?(symlink_path) || File.symlink?(symlink_path)
    if File.symlink?(symlink_path)
      symlink_points_to_path = File.readlink(symlink_path)
      return if symlink_points_to_path == original_path
      # Symlinks can't just be moved like regular files. Recreate old one, and
      # remove it.
      ln_s symlink_points_to_path, get_backup_path(symlink_path), :verbose => true
      rm symlink_path
    else
      # Never move user's files without creating backups first
      mv symlink_path, get_backup_path(symlink_path), :verbose => true
    end
  end
  ln_s original_path, symlink_path, :verbose => true
end

def unlink_file(original_filename, symlink_filename)
  original_path = File.expand_path(original_filename)
  symlink_path = File.expand_path(symlink_filename)
  if File.symlink?(symlink_path)
    symlink_points_to_path = File.readlink(symlink_path)
    if symlink_points_to_path == original_path
      # the symlink is installed, so we should uninstall it
      rm_f symlink_path, :verbose => true
      backups = Dir["#{symlink_path}*.bak"]
      case backups.size
      when 0
        # nothing to do
      when 1
        mv backups.first, symlink_path, :verbose => true
      else
        $stderr.puts "found #{backups.size} backups for #{symlink_path}, please restore the one you want."
      end
    else
      $stderr.puts "#{symlink_path} does not point to #{original_path}, skipping."
    end
  else
    $stderr.puts "#{symlink_path} is not a symlink, skipping."
  end
end

namespace :install do
  desc 'Update or Install Brew'
  task :brew do
    step 'Homebrew'
    unless system('which brew > /dev/null')
      `ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"` if OS.mac?
      `ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/linuxbrew/go/install)"` if OS.linux?
    end
  end

  desc 'Install The Silver Searcher'
  task :the_silver_searcher do
    step 'the_silver_searcher'
    brew_install 'the_silver_searcher'
  end

  desc 'Install iTerm'
  task :iterm do
    step 'iterm2'
    unless app? 'iTerm'
      brew_install 'iterm2'
    end
  end

  desc 'Install ctags'
  task :ctags do
    step 'ctags'
    brew_install 'ctags'
  end

  desc 'Install reattach-to-user-namespace'
  task :reattach_to_user_namespace do
    step 'reattach-to-user-namespace'
    brew_install 'reattach-to-user-namespace'
  end

  desc 'Install tmux'
  task :tmux do
    step 'tmux'
    # tmux copy-pipe function needs tmux >= 1.8
    brew_install 'tmux', :requires => '>= 1.8'
  end

  desc 'Install oh-my-zsh'
  task :zsh do
    step 'oh-my-zsh'
    brew_install 'zsh'

    sh 'git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh' unless Dir.exist? "#{Dir.home}/.oh-my-zsh"
  end

  desc 'Install Vim'
  task :vim do
    if OS.mac?
      step 'MacVim'
      unless app? 'MacVim'
        brew_install 'macvim'
      end
    elsif OS.linux?
      step 'Vim'
      brew_install 'vim'
    end
  end

  desc 'Install Vundle'
  task :vundle do
    step 'vundle'
    install_github_bundle 'gmarik','vundle'
    sh 'vim -c "PluginInstall!" -c "q" -c "q"'
  end

  desc 'Install RVM'
  task :rvm do
    step 'rvm'
    # Not sure if this key line will go out of date
    sh 'gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3'
    sh '\curl -sSL https://get.rvm.io | bash'
  end
end

def filemap(map)
  map.inject({}) do |result, (key, value)|
    result[File.expand_path(key)] = File.expand_path(value)
    result
  end.freeze
end

COPIED_FILES = filemap(
  'vimrc.local'         => '~/.vimrc.local',
  'vimrc.bundles.local' => '~/.vimrc.bundles.local',
  'zshrc.local'         => '~/.zshrc.local',
  'tmux.conf.local'     => '~/.tmux.conf.local'
)

LINKED_FILES = filemap(
  'vimrc'         => '~/.vimrc',
  'tmux.conf'     => '~/.tmux.conf',
  'zshrc'         => '~/.zshrc',
  'vimrc.bundles' => '~/.vimrc.bundles'
)

desc 'Install these config files.'
task :install do
  if OS.windows?
    puts
    puts 'Currently, installation is not supported on Windows'
    puts
    return
  end

  # Need to make sure brew is available, possible include installation

  puts
  puts 'Ensuring general tools are around to be configured'
  puts

  Rake::Task['install:brew'].invoke
  Rake::Task['install:the_silver_searcher'].invoke
  Rake::Task['install:ctags'].invoke
  Rake::Task['install:vim'].invoke
  Rake::Task['install:tmux'].invoke
  Rake::Task['install:zsh'].invoke
  Rake::Task['install:rvm'].invoke

  if OS.mac?
    puts
    puts 'Installing OSX specific tools'
    puts

    Rake::Task['install:iterm'].invoke
    Rake::Task['install:reattach_to_user_namespace'].invoke
  end

  if OS.linux? && false # I don't think there are any?
    puts
    puts 'Installing Linux specific tools'
    puts
  end

  step 'symlink'

  LINKED_FILES.each do |orig, link|
    link_file orig, link
  end

  COPIED_FILES.each do |orig, copy|
    cp orig, copy, :verbose => true unless File.exist?(copy)
  end

  # Install Vundle and bundles
  Rake::Task['install:vundle'].invoke

  puts
  puts "Enjoy!"
  puts
end

desc 'Uninstall these config files.'
task :uninstall do
  step 'un-symlink'

  # un-symlink files that still point to the installed locations
  LINKED_FILES.each do |orig, link|
    unlink_file orig, link
  end

  # delete unchanged copied files
  COPIED_FILES.each do |orig, copy|
    rm_f copy, :verbose => true if File.read(orig) == File.read(copy)
  end

  step 'homebrew'
  puts
  puts 'Manually uninstall homebrew if you wish: https://gist.github.com/mxcl/1173223.'

  if OS.mac?
    step 'iterm2'
    puts
    puts 'Run this to uninstall iTerm:'
    puts
    puts '  rm -rf /Applications/iTerm.app'

    step 'macvim'
    puts
    puts 'Run this to uninstall MacVim:'
    puts
    puts '  rm -rf /Applications/MacVim.app'
  end

  if OS.linux?
  end
end

task :default => :install
