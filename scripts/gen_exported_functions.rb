# Generates EXPORTED_FUNCTIONS argument

require 'fileutils'

BASE_PATH = File.expand_path(File.join(File.dirname(__FILE__),
                                       %w(.. modules mruby mrbgems g)))

def gen_exported_funcs(gem_file)
  funcs = ['main']

  gems = File.readlines(gem_file)
  FileUtils.cd(BASE_PATH) do
    gems.each do |gem|
      func_file = File.join(gem.strip, 'EXPORTED_FUNCTIONS')
      if File.exists?(func_file)
        File.readlines(func_file).each do |f|
          f = f.strip
          funcs << f if !f.empty?
        end
      end
    end
  end

  funcs.uniq
end

def gen_exported_funcs_arg(gem_file)
  funcs = gen_exported_funcs gem_file
  func_str = funcs.map {|f| "'_#{f}'"}.join ', '

  "-s EXPORTED_FUNCTIONS=\\\"[#{func_str}]\\\""
end
