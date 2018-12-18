class IkabotController < ApplicationController
    require 'line/bot'
    require 'net/http'
    require 'json'
    

    # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery :except => [:callback]

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end


    #text_params = params["events"][0]["message"]["text"] #メッセージイベントからテキストの取得
    
    events = client.parse_events_from(body)
    events.each { |event|

    if event.message['text'] == "ナワバリ"
      spla2 = 'https://spla2.yuu26.com/regular/now'
      uri = URI.parse(spla2)
      res = Net::HTTP.get(uri)
      json = JSON.parse(res)
      response = json
    else event.message['text']  == "ガチマッチ"
      spla2 = 'https://spla2.yuu26.com/gachi/now'
      uri = URI.parse(spla2)
      res = Net::HTTP.get(uri)
      json = JSON.parse(res)
      response = json
    end

    # spla2 = 'https://spla2.yuu26.com/regular/now'
    # uri = URI.parse(spla2)
    # res = Net::HTTP.get(uri)
    # json = JSON.parse(res)

    # result = json["result"][0]
    # rule_name = result["rule"]
    # map1 = result["maps"][0]
    # map2 = result["maps"][1]
    # image1 = result["maps_ex"][0]["image"]
    # image2 = result["maps_ex"][1]["image"]

    # response = "【バトル】" + "\n" + rule_name + "\n" + "【マップ】" + "\n" + map1 + ":" +image1 + "\n" + map2 + ":" + image2 + "\n" 

      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
             type: 'text',
             text: response
           }
           client.reply_message(event['replyToken'], message)

        when Line::Bot::Event::MessageType::Sticker
          message = {
            type: 'sticker',
            packageId: event.message['packageId'],
            stickerId: event.message['stickerId']
          }
          client.reply_message(event['replyToken'], message)
        end
      end
    }

    head :ok
  end
end

