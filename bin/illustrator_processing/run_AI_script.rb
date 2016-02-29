require 'json'
require 'FileUtils'


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


def osascript(script)
  system 'osascript', *script.split(/\n/).map { |line| ['-e', line] }.flatten
end


def move_all( dir, dest )

    puts "RUN_AI_SCRIPT - move_all - dir: " + dir
    puts "RUN_AI_SCRIPT - move_all - dest: " + dest



	  Dir.entries(dir).each do |name|

        puts "RUN_AI_SCRIPT - name: " + name

        next if File.directory? name

	      from_path = File.join(dir, name)
        to_path = dest

        puts "RUN_AI_SCRIPT - move_all - about to MV: " + from_path.to_s + " to " + to_path.to_s
	      FileUtils.mv from_path, to_path

	  end
end



# Load configuration json, get settings

config_file = ARGV[0]

f = File.open(config_file.to_s, "r")
s = f.read
config_hash = JSON.parse( s )

source_file = config_hash[ "source file" ]
script_file = config_hash[ "script file" ]
output_folder = config_hash[ "output folder" ]

puts "RUN_AI_SCRIPT - source_file: " + source_file.to_s
puts "RUN_AI_SCRIPT - script_file: " + script_file.to_s
puts "RUN_AI_SCRIPT - output_folder: " + output_folder.to_s



# Search and replace values in ASCode

ASCode.gsub! '<<source>>', source_file
ASCode.gsub! '<<script>>', script_file


# Run the applescript

osascript ASCode;


# the source folder is the folder containing the source file
source_folder = File.dirname( source_file )

# AI places all new files in /output/
AI_output_files = source_folder + "/output/."


move_all( AI_output_files, output_folder )
