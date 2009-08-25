require 'cgi'
require 'net/https'

module SaasuConnect
	class Rest
		# Replace this API key with your own (http://www.campaignmonitor.com/api/)
		def initialize(access_key=SAASU_ACCESS_KEY, file_uid=SAASU_FILE_UID)
			@access_key = access_key || SAASU_ACCESS_KEY	
			@file_uid = file_uid || SAASU_FILE_UID
			@host = 'https://secure.saasu.com'
			@api = '/webservices/rest/r1'

		  if defined? RAILS_DEFAULT_LOGGER
				@logger = RAILS_DEFAULT_LOGGER
			else
				@logger = Logger.new(STDOUT)
			end
		end

		# Takes a NetAccounts API method name and set of parameters; 
		# returns an XmlSimple object with the response
		def get(method, *params)
			params = params.pop
			begin
				http_get(request_url(method, params))
			rescue SocketError
				raise ConnectionException
			end
		end

		def post(method, *params)
			params = params.pop
			data = params.delete(:data)
			begin
				http_post(request_url(method, params), data)
			rescue SocketError
				raise ConnectionException
			end
		end
		
		def update(method, *params)
			params = params.pop
			
			begin
				http_update(request_url(method, params), params[1])
			rescue SocketError
				raise ConnectionException
			end
		end

		def delete(method, *params)
			params = params.pop
			
			begin
				http_delete(request_url(method, params))
			rescue SocketError
				raise ConnectionException
			end
		end
	  
		# Takes a CampaignMonitor API method name and set of parameters; returns the correct URL for the REST API.
		def request_url(method, *params)
			params = params.pop

			url = "#{@host}#{@api}/#{method}?wsaccesskey=#{@access_key}&fileuid=#{@file_uid}"
			params.each_key { |key| url += "&#{key.to_s.camelize(:lower)}=" + CGI::escape(params[key].to_s) } unless params.nil?
			url
		end
	  
		# Does an HTTP GET on a given URL and returns the response body
		def http_get(url)
			@logger.debug('GETing: ' + url)
			uri = URI.parse(url)
			http = Net::HTTP.new(uri.host, uri.port)
			http.use_ssl = true
			response = http.get(uri.path + "?" + uri.query)
			@logger.debug("Response: "+response.body.to_s)
			
			case response
			when Net::HTTPSuccess
				response.body.to_s
			else
				raise HttpException, "A error occured while trying to retrieve the resource: " + response.code + " " + response.message
			end

		end

		def http_post(url, data)
			@logger.debug('POSTing: ' + url)
			@logger.debug('Data: ' + data)
			uri = URI.parse(url)
			
			http = Net::HTTP.new(uri.host, uri.port)
			http.use_ssl = true
			response = http.request_post(uri.path + "?" + uri.query, data)
			@logger.debug("Response: "+response.body.to_s)

			case response
			when Net::HTTPSuccess
				response.body.to_s
			else
				raise HttpException, "A error occured while trying to retrieve the resource: " + response.code + " " + response.message
			end
		end

		def http_put(url, data)
			@logger.debug('PUTing: ' + url)
			@logger.debug('Data: ' + data)
			# this doesn't work
			uri = URI.parse(url)
			
			http = Net::HTTP.new(uri.host, uri.port)
			http.use_ssl = true

			req = Net::HTTP::Put.new(uri.path + "?" + uri.query)
			req.set_form_data(data)

			response = http.start { |http| http.request(req) }
			@logger.debug("Response: "+response.body.to_s)
			response.body.to_s
		end

		def http_delete(url)
			@logger.debug('DELETEing: ' + url)
			uri = URI.parse(url)
			http = Net::HTTP.new(uri.host, uri.port)
			http.use_ssl = true
			response = http.delete(uri.path + "?" + uri.query)
			@logger.debug("Response: "+response.body.to_s)
			response.body.to_s
		end
	  
		# By overriding the method_missing method, it is possible to easily support all of the methods
		# available in the API
		def method_missing(method_id, *params)
			params = params.pop
			components = method_id.id2name.split("_")
			type = components.shift

			if type != "get" && type != "post" && type != "update" && type != "delete"
				components = type.to_a + components
				type = "get"
			end

			send(type, components.join("_").camelize, params)
		end
	end
end
