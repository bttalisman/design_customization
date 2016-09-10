require 'google/apis/drive_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'

require 'fileutils'


OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
APPLICATION_NAME = 'Drive API Ruby Quickstart'
CLIENT_SECRETS_PATH = 'client_secret.json'
CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                             "drive-ruby-quickstart.yaml")
SCOPE = Google::Apis::DriveV3::AUTH_DRIVE

##
# Ensure valid credentials, either by restoring from the saved credentials
# files or intitiating an OAuth2 authorization. If authorization is required,
# the user's default browser will be launched to approve the request.
#
# @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
def authorize
  FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

  client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
  token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(
    client_id, SCOPE, token_store)
  user_id = 'default'
  credentials = authorizer.get_credentials(user_id)
  if credentials.nil?
    url = authorizer.get_authorization_url(
      base_url: OOB_URI)
    puts "Open the following URL in the browser and enter the " +
         "resulting code after authorization"
    puts url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: OOB_URI)
  end
  credentials
end

# Initialize the API
service = Google::Apis::DriveV3::DriveService.new
service.client_options.application_name = APPLICATION_NAME
service.authorization = authorize


folder_id = '0B0Pbgd52b3LYU3pheTJVVzZvVW8'
file_metadata = {
  name: 'test.png',
  parents: [ '0B0Pbgd52b3LYU3pheTJVVzZvVW8' ]
}
file = service.create_file(file_metadata,
                           fields: 'id',
                           upload_source: 'output/nicks/A test version_final.png',
                           content_type: 'image/png')

# List the 10 most recently modified files.
#response = service.list_files(page_size: 10,
#                              fields: 'nextPageToken, files(id, name)')
#puts 'Files:'
#puts 'No files found' if response.files.empty?
#response.files.each do |file|
#  puts "#{file.name} (#{file.id})"
#end
