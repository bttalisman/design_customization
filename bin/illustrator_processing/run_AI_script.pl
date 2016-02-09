

use Modern::Perl;
use JSON::XS;

my $ASCode = <<EOD;
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

my $config_file=$ARGV[0];

my $json_text = do {
   open(my $json_fh, "<:encoding(UTF-8)", $config_file)
      or die("Can't open \$config_file\": $!\n");
   local $/;
   <$json_fh>
};

my $perl_hash  = decode_json $json_text;


my $SourceFile = $perl_hash->{ "source file" };
my $ScriptFile = $perl_hash->{ "script file" };
my $outputFolder = $perl_hash->{ "output folder" };

$ASCode =~ s/<<source>>/$SourceFile/g;
$ASCode =~ s/<<script>>/$ScriptFile/g;


sub osascript($) {

  system 'osascript', map { ('-e', $_) } split(/\n/, $_[0]);

}


osascript $ASCode;
