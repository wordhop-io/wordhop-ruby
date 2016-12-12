require 'rubygems'
require 'socket.io-client-simple'
require 'httparty'

module Wordhop

    
    class Partay
        include HTTParty
        base_uri 'https://wordhopapi.herokuapp.com/api/v1'
    end
    
    EVENTS = [:'chat response', :'socket_id_set'].freeze
    
    class << self
    
        attr_accessor :apikey, :clientkey, :token, :platform

        def initialize
            @apikey
            @clientkey
            @token
            @platform
        end
        
        def new(*args, &block)
            obj = allocate
            obj.initialize(*args, &block)
            obj
        end
    
        # Return a Hash of hooks.
        def apikey
            @apikey ||= ENV['WORDHOP_API_KEY']
        end
        
        def clientkey
            @clientkey ||= ENV['WORDHOP_CLIENT_KEY']
        end
        
        def token
            @token ||= ENV['ACCESS_TOKEN'] ||= ''
        end
        
        def platform
            @platform ||= "messenger"
        end
        
        def headers
            @headers = {'apikey':apikey,'clientkey':clientkey,'platform':platform, 'token': token}
        end
        
        def hooks
            @hooks ||= {}
        end
    
        socket = SocketIO::Client::Simple.connect 'https://wordhop-socket-server.herokuapp.com'
        
        socket.on :socket_id_set do |data|
            socket_id = data
            x = {'socket_id': socket_id, 'clientkey': WORDHOP_CLIENT_KEY}
            options = {
                body: x,
                headers: headers
            }
            Partay.post('/update_bot_socket_id', options)
        end

        socket.on :'chat response' do |data|
            channel = data['channel']
            text = data['text']
            messageData = {'recipient': {'id': channel},'message': {'text': text}}
            Wordhop.hopOut(messageData)
            Wordhop.trigger(:'chat response', messageData)
        end

        def on(event, &block)
            unless EVENTS.include? event
                raise ArgumentError,
                "#{event} is not a valid event; " \
                "available events are #{EVENTS.join(',')}"
            end
            hooks[event] = block
        end

        def trigger(event, *args)
            hooks.fetch(event).call(*args)
        rescue KeyError
            $stderr.puts "Ignoring #{event} (no hook registered)"
        end

        def hopIn(x)
            puts 'hopIn'
            options = {'body':x, 'headers':headers}
            return Partay.post('/in', options)
        end
            
        def hopOut(x)
            puts 'hopOut'
            options = {'body':x, 'headers':headers}
            return Partay.post('/out', options)
        end
            
        def logUnknownIntent(x)
            puts 'logUnknownIntent'
            options = {'body':x, 'headers':headers}
            return Partay.post('/unknown', options)
        end
            
        def assistanceRequested(x)
            puts 'assistanceRequested'
            options = {'body':x, 'headers':headers}
            return Partay.post('/human', options)
        end
    end
end

