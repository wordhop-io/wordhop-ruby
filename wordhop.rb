require 'rubygems'
require 'socket.io-client-simple'
require 'httparty'

module Wordhop

    
    class Partay
        include HTTParty
        base_uri 'https://wordhopapi.herokuapp.com/api/v1'
    end
    
    EVENTS = [:'chat response', :'socket_id_set'].freeze
    WORDHOP_API_KEY = ENV['WORDHOP_API_KEY']
    WORDHOP_CLIENT_KEY = ENV['WORDHOP_CLIENT_KEY']
    WORDHOP_HEADERS = {'apikey':WORDHOP_API_KEY,'clientkey':WORDHOP_CLIENT_KEY,'platform':'messenger', 'token': ENV['ACCESS_TOKEN']}
    
    class << self
    
        socket = SocketIO::Client::Simple.connect 'https://wordhop-socket-server.herokuapp.com'
        
        socket.on :socket_id_set do |data|
            socket_id = data
            x = {'socket_id': socket_id, 'clientkey': WORDHOP_CLIENT_KEY}
            options = {
                body: x,
                headers: WORDHOP_HEADERS
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

        # Return a Hash of hooks.
        def hooks
            @hooks ||= {}
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
            options = {'body':x, 'headers':WORDHOP_HEADERS}
            return Partay.post('/in', options)
        end
            
        def hopOut(x)
            puts x
            puts 'hopOut'
            options = {'body':x, 'headers':WORDHOP_HEADERS}
            return Partay.post('/out', options)
        end
            
        def logUnknownIntent(x)
            puts 'logUnknownIntent'
            options = {'body':x, 'headers':WORDHOP_HEADERS}
            return Partay.post('/unknown', options)
        end
            
        def assistanceRequested(x)
            puts 'assistanceRequested'
            options = {'body':x, 'headers':WORDHOP_HEADERS}
            return Partay.post('/human', options)
        end
    end
end

