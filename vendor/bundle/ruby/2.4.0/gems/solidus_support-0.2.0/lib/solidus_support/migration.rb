module SolidusSupport
  module Migration
    def self.[](version)
      if Rails.gem_version >= Gem::Version.new('5.x')
        ActiveRecord::Migration[version]
      else
        # Rails < 5 doesn't support specifying rails version of migrations, but
        # it _is_ rails 4.2, so we can use that when requested.
        if version.to_s == '4.2'
          ActiveRecord::Migration
        else
          raise ArgumentError, %q{Unknown migration version "#{version}"; expected one of "4.2"}
        end
      end
    end
  end
end
