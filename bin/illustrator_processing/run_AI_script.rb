require 'json'


ASCode = <<-EOD
    on run
    		tell application "Adobe Illustrator"
    			activate

          open "<<source>>"
    			try
    				close windows
    			end try

    			open "<<script>>"
    			try
    				close windows
    			end try

    			close current document

    		end tell
    end run
EOD



config_file = ARGV[0]

puts "config_file: " + config_file.to_s


f = File.open(config_file.to_s, "r")
s = f.read


config_hash = JSON.parse( s )

source_file = config_hash[ "source file" ]
script_file = config_hash[ "script file" ]
output_folder = config_hash[ "output folder" ]


puts "source_file: " + source_file.to_s
puts "script_file: " + script_file.to_s
puts "output_folder: " + output_folder.to_s

ASCode.gsub! '<<source>>', source_file
ASCode.gsub! '<<script>>', script_file



def osascript(script)
  system 'osascript', *script.split(/\n/).map { |line| ['-e', line] }.flatten
end


osascript ASCode;
