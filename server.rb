require 'sinatra'
require 'cgi'
require 'base64'
require 'yaml'

set :error_404_file, File.dirname(__FILE__) + '/404.html'

get "/download/:token/:expire/:filename" do
  @secret = YAML::parse( File.open("secret.yml") ).select('/secret')[0].value
  
  if params[:token] == Digest::MD5.hexdigest(@secret + params[:filename] + params[:expire])
    headers \
      "Content-type" => 'application/octet-stream',
      "Content-Disposition" => "attachment; filename=\"#{CGI.escape(File.basename(Base64.strict_decode64(params[:filename])))}\"",
      'X-Accel-Redirect' => URI.escape("/private" + Base64.strict_decode64(params[:filename]))
  else
    status 404
    body File.open(settings.error_404_file, 'r') { |file| file.read }
  end
end

not_found do
  status 404
  body File.open(settings.error_404_file, 'r') { |file| file.read }
end