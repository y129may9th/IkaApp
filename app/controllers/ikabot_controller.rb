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

    text_params = params["events"][0]["message"]["text"] #メッセージイベントからテキストの取得

    if text_params == "ナワバリ" then
      rule = "regular"
    elsif text_params == "ガチマッチ" then
      rule = "gachi"
    elsif text_params == "サーモンラン" then
      rule = "gachi"
    end

    spla2 = "https://spla2.yuu26.com/#{rule}/now"
    uri = URI.parse(spla2)
    res = Net::HTTP.get(uri)
    json = JSON.parse(res)

    result = json["result"][0]
    rule = result["rule"]
    map1 = result["maps"][0]
    map2 = result["maps"][1]
    image1 = result["maps_ex"][0]["image"]
    image2 = result["maps_ex"][1]["image"]

    response = "【バトル】" + "\n" + rule + "\n" + "【マップ】" + "\n" + map1 + "\n" +image1 + "\n" + map2 + "\n" + image2 + "\n" 

    events = client.parse_events_from(body)
    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          messages = [
            {
              type: 'text',
              text: response
            },
            {
              type: 'image',
              originalContentUrl: image1,
              previewImageUrl: image1
            }
          ]
          # message = {
          #    type: 'text',
          #    text: response,
          #    type: 'image',
          #    originalContentUrl: image1,
          #    previewImageUrl: image1
          #  }
           client.reply_message(event['replyToken'], messages)

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

